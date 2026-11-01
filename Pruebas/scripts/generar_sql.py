"""Genera los scripts desde el contrato único; no ejecuta SQL en ninguna base."""
import json,re
from pathlib import Path
from contrato_staging import ROOT,SCHEMA,projections,all_rules,academic_rules
from rutas import ruta

P=projections();RULES=all_rules()
HEAD="""-- Oracle Database 23ai (también 19c y 21c). Ejecutar como script en SQL*Plus o SQLcl.
-- Sesión dedicada, sin trabajo pendiente. No usar SYS/SYSTEM.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';
"""

def caja(titulo,*desc):
    # Encabezado de sección: título y descripción.
    return ['-- '+'='*62,'-- '+titulo,'-- Descripción: '+desc[0]]+['--   '+d for d in desc[1:]]+['-- '+'='*62]
def sub(t):return ['',f'-- === {t} ===']
GRUPOS=[('CATÁLOGOS','Listas de valores: tipos de documento, departamentos, zonas, niveles, grados…',lambda t:t.startswith('cat_')),
        ('MAESTROS','Personas, estudiantes, docentes, instituciones y asignaturas.',lambda t:t.startswith('mae_')),
        ('ESTRUCTURA ACADÉMICA','Ciclos, períodos, cursos, oferta de materias, planes de pesos y plazos de notas.',lambda t:t.startswith('est_')),
        ('TRANSACCIONES ACADÉMICAS','Inscripciones, docentes asignados, calificaciones, resultados, clases, asistencia y becas.',lambda t:t.startswith('trx_') and t!='trx_control_carga'),
        ('CONTROL DE CARGA Y AUDITORÍA','Cobertura de los datos recibidos y registro de cada ejecución de carga y sus errores.',lambda t:t in ('trx_control_carga','auditoria_etl_evaluaciones','errores_etl_evaluaciones'))]
def grupo(t):return next(i for i,(_,_,f) in enumerate(GRUPOS) if f(t))
def comentarios(table,desc,campos):
    # COMMENT ON: la descripción se ve en el panel de Oracle (SQL Developer, pestaña Columnas).
    out=[f'COMMENT ON TABLE {table} IS {quote(desc)};']
    out+=[f"COMMENT ON COLUMN {table}.{f['name']} IS {quote(f['description'][:4000])};" for f in campos if f.get('description')]
    return out
def quote(s):return "'"+str(s).replace("'","''")+"'"
def literal(value,f):
    if value is None:return 'NULL'
    if f['type']=='date':return 'DATE '+quote(value)
    if f['type']=='timestamp':return 'TIMESTAMP '+quote(value)
    if f['type'] in ('int','decimal','boolean'):return str(value)
    return quote(value)
def q(sql):
    assert "~'" not in sql
    return "q'~"+sql+"~'"
def order():
    pending=set(SCHEMA);done=set();out=[]
    while pending:
        ready=[n for n in SCHEMA if n in pending and {f['references']['table'] for f in SCHEMA[n]['foreign_keys'] if f['references']['table']!=n}<=done]
        assert ready,pending
        for n in ready:out.append(n);done.add(n);pending.remove(n)
    return out

PROFILE_PROC="""
    PROCEDURE comprobar_columna(p_tabla VARCHAR2,p_pos NUMBER,p_col VARCHAR2,
      p_tipo VARCHAR2,p_precision NUMBER,p_escala NUMBER,p_largo NUMBER,p_null VARCHAR2) IS
      v_tipo VARCHAR2(128);v_prec NUMBER;v_esc NUMBER;v_largo NUMBER;
      v_char VARCHAR2(1);v_null VARCHAR2(1);v_pos NUMBER;
    BEGIN
      SELECT data_type,data_precision,data_scale,char_length,char_used,nullable,column_id
        INTO v_tipo,v_prec,v_esc,v_largo,v_char,v_null,v_pos
        FROM user_tab_columns WHERE table_name=UPPER(p_tabla) AND column_name=UPPER(p_col);
      IF v_tipo<>p_tipo OR v_null<>p_null OR (p_pos IS NOT NULL AND v_pos<>p_pos)
        OR (p_tipo='NUMBER' AND (NVL(v_prec,-1)<>NVL(p_precision,-1) OR NVL(v_esc,-1)<>NVL(p_escala,-1)))
        OR (p_tipo='VARCHAR2' AND (v_largo<>p_largo OR v_char<>'C')) THEN
        RAISE_APPLICATION_ERROR(-20011,'Estructura incompatible: '||p_tabla||'.'||p_col||'. Revisar el contrato y migrar explícitamente.');
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20012,'Falta la columna requerida: '||p_tabla||'.'||p_col);
    END;
    PROCEDURE comprobar_clave(p_tabla VARCHAR2,p_tipo VARCHAR2,p_cols VARCHAR2,
      p_padre VARCHAR2 DEFAULT NULL,p_cols_padre VARCHAR2 DEFAULT NULL) IS
      v_total NUMBER;
    BEGIN
      SELECT COUNT(*) INTO v_total FROM user_constraints c
      WHERE c.table_name=UPPER(p_tabla) AND c.constraint_type=p_tipo
        AND c.status='ENABLED' AND c.validated='VALIDATED'
        AND (SELECT LISTAGG(k.column_name,',') WITHIN GROUP (ORDER BY k.position)
               FROM user_cons_columns k WHERE k.constraint_name=c.constraint_name)=UPPER(p_cols)
        AND (p_tipo<>'R' OR EXISTS (SELECT 1 FROM user_constraints r
          WHERE r.constraint_name=c.r_constraint_name AND r.table_name=UPPER(p_padre)
          AND (SELECT LISTAGG(z.column_name,',') WITHIN GROUP (ORDER BY z.position)
                 FROM user_cons_columns z WHERE z.constraint_name=r.constraint_name)=UPPER(p_cols_padre)));
      IF v_total=0 THEN
        RAISE_APPLICATION_ERROR(-20015,'Falta clave activa y validada: '||p_tabla||' ('||p_cols||') tipo '||p_tipo);
      END IF;
    END;
    PROCEDURE comprobar_segmento(p_tabla VARCHAR2) IS
      v_segmento VARCHAR2(3); v_pendientes NUMBER;
    BEGIN
      SELECT segment_created INTO v_segmento FROM user_tables WHERE table_name=UPPER(p_tabla);
      SELECT COUNT(*) INTO v_pendientes FROM user_indexes WHERE table_name=UPPER(p_tabla) AND segment_created='NO';
      IF v_segmento<>'YES' OR v_pendientes>0 THEN
        RAISE_APPLICATION_ERROR(-20016,'Segmento pendiente: '||p_tabla||'. Materializar antes de la carga y repetir creación/verificación.');
      END IF;
    END;
"""
def profile_call(table,pos,f):
    typ=f['oracle_type'];prec=scale=length=None
    if typ.startswith('NUMBER'):
      m=re.fullmatch(r'NUMBER(?:\((\d+)(?:,(\d+))?\))?',typ)
      prec=int(m.group(1)) if m.group(1) else None;scale=int(m.group(2) or 0) if m.group(1) else None;typ='NUMBER'
    elif typ.startswith('VARCHAR2'):
      length=int(re.search(r'\((\d+)',typ).group(1));typ='VARCHAR2'
    num=lambda n:'NULL' if n is None else str(n)
    return '    comprobar_columna('+','.join([quote(table),num(pos),quote(f['name']),quote(typ),num(prec),num(scale),num(length),quote('Y' if f['nullable'] else 'N')])+');'
def profile_calls(stage=True):
    out=[]
    for table,t in SCHEMA.items():
      for f in t['fields']:out.append(profile_call(table,None,f))
      pk=[f['name'] for f in t['fields'] if 'PK' in f['key']]
      out.append('    comprobar_clave('+','.join([quote(table),"'P'",quote(','.join(pk))])+');')
      unique=[tuple(u) for u in t['unique']]+[(f['name'],) for f in t['fields'] if 'UK' in f['key']]
      for cols in dict.fromkeys(unique):
        if list(cols)!=pk:out.append('    comprobar_clave('+','.join([quote(table),"'U'",quote(','.join(cols))])+');')
      for fk in t['foreign_keys']:
        out.append('    comprobar_clave('+','.join([quote(table),"'R'",quote(','.join(fk['columns'])),quote(fk['references']['table']),quote(','.join(fk['references']['columns']))])+');')
    if stage:
      for f in [{'name':'id_control','oracle_type':'NUMBER(1,0)','nullable':False},{'name':'version_carga','oracle_type':'NUMBER(10,0)','nullable':False}]:
        out.append(profile_call('ctl_carga_staging',None,f))
      out += ["    comprobar_clave('ctl_carga_staging','P','id_control');","    comprobar_segmento('ctl_carga_staging');","    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ctl_carga_staging WHERE id_control=1 AND version_carga>=0' INTO v_n;","    IF v_n<>1 THEN RAISE_APPLICATION_ERROR(-20017,'Falta la fila singleton de control de carga.'); END IF;","    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ctl_carga_staging' INTO v_n;","    IF v_n<>1 THEN RAISE_APPLICATION_ERROR(-20017,'La guardia de carga debe tener una sola fila.'); END IF;"]
      for table,t in P.items():
        out.append('    comprobar_segmento('+quote(table)+');')
        out.append(f"    SELECT COUNT(*) INTO v_n FROM user_tab_columns WHERE table_name='{table}';")
        out.append(f"    IF v_n<>{len(t['fields'])} THEN RAISE_APPLICATION_ERROR(-20013,'Cantidad de columnas incompatible: {table}'); END IF;")
        for i,f in enumerate(t['fields'],1):out.append(profile_call(table,i,f))
        out.append('    comprobar_clave('+','.join([quote(table),"'R'","'id_ejecucion_carga'","'auditoria_etl_evaluaciones'","'id_ejecucion'"])+');')
    return '\n'.join(out)

def corto(table):
    # Nombre corto de la tabla para sus restricciones: sin prefijo de capa (cat_, mae_, est_, trx_).
    return {'auditoria_etl_evaluaciones':'auditoria_etl','errores_etl_evaluaciones':'errores_etl'}.get(table,re.sub(r'^(cat|mae|est|trx)_','',table))

def cols_nombre(cols):
    return '_'.join(re.sub(r'^id_','',c) for c in cols)

def reference_ddl():
    out=caja('SCRIPT_BASE.sql: TABLAS DE OPERACIÓN (OLTP)','Crea las 33 tablas del modelo educativo con sus claves, CHECK y comentarios.',
      'Solo en un esquema vacío: no migra ni reemplaza un OLTP existente.','Las reglas que cruzan tablas se instalan después, con Validacion/INSTALAR_VALIDACIONES.sql.')+[HEAD]
    out+=sub('Requisito: ninguna de las tablas existe')+['DECLARE v_n NUMBER; BEGIN']
    names=','.join(quote(n.upper()) for n in SCHEMA)
    out += [f' SELECT COUNT(*) INTO v_n FROM user_tables WHERE table_name IN ({names});'," IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20070,'El DDL de referencia requiere que no exista ninguna de sus tablas.'); END IF;",'END;','/']
    prefixes=None
    actual=None
    for table,t in sorted(SCHEMA.items(),key=lambda x:grupo(x[0])):
      g=grupo(table)
      if g!=actual:
        actual=g;out+=['']+caja(f'SECCIÓN {g+1}: {GRUPOS[g][0]}',GRUPOS[g][1])
      parts=[]
      for f in t['fields']:
        part='    '+f['name']+' '+f['oracle_type']+(' NOT NULL' if not f['nullable'] else '')
        parts.append(part)
      pk=[f['name'] for f in t['fields'] if 'PK' in f['key']]
      parts.append(f"    CONSTRAINT pk_{corto(table)} PRIMARY KEY ({','.join(pk)})")
      uniques=[tuple(x) for x in t['unique']]+[(f['name'],) for f in t['fields'] if 'UK' in f['key']]
      for cols in dict.fromkeys(uniques):
        if list(cols)==pk:continue
        parts.append(f"    CONSTRAINT uk_{corto(table)}_{cols_nombre(cols)} UNIQUE ({','.join(cols)})")
      # (nombre, condición): el nombre dice qué se comprueba.
      checks=[]
      for f in t['fields']:
        fc=f.get('oracle_checks',[])
        checks+=[(f['name']+(f'_{i}' if len(fc)>1 else ''),c) for i,c in enumerate(fc,1)]
      checks+=[(r['id'].lower(),r['oracle_check']) for r in t.get('business_constraints',[]) if r.get('oracle_check')]
      if {'fecha_inicio','fecha_fin'}<={f['name'] for f in t['fields']}:checks.append(('fechas','fecha_fin IS NULL OR fecha_fin >= fecha_inicio'))
      if table=='trx_sesion_clase':checks.append(('horario','fin > inicio'))
      if table=='est_plazo_registro_notas':checks.append(('recuperacion',"(tipo_intento='ORDINARIA' AND fecha_inicio_recuperacion IS NULL AND fecha_fin_recuperacion IS NULL) OR (tipo_intento='RECUPERACION' AND fecha_inicio_recuperacion IS NOT NULL AND fecha_fin_recuperacion IS NOT NULL AND fecha_fin_recuperacion>=fecha_inicio_recuperacion)"))
      if table=='auditoria_etl_evaluaciones':
        checks+=[('conteos','total_leidos>=0 AND insertados>=0 AND actualizados>=0 AND rechazados>=0'),('cierre',"estado<>'COMPLETADA' OR (fin IS NOT NULL AND fin>=inicio AND total_leidos=insertados+actualizados+rechazados)")]
      vistos=set()
      for nombre,check in checks:
        if check in vistos:continue
        vistos.add(check);parts.append(f'    CONSTRAINT ck_{corto(table)}_{nombre} CHECK ({check})')
      out+=sub(table.upper())+['-- '+t['description']+'.','CREATE TABLE '+table+' (',',\n'.join(parts),');']+comentarios(table,t['description'],t['fields'])
    out+=['']+caja(f'SECCIÓN {len(GRUPOS)+1}: CLAVES FORÁNEAS E ÍNDICES','Se agregan al final, cuando ya existen todas las tablas.',
      'Cada FK sin un índice que empiece por sus columnas recibe uno, para no bloquear la tabla padre.')
    for table,t in SCHEMA.items():
      if t['foreign_keys']:out+=sub(table.upper())
      prefixes=[tuple(f['name'] for f in t['fields'] if 'PK' in f['key'])]+[tuple(x) for x in t['unique']]+[(f['name'],) for f in t['fields'] if 'UK' in f['key']]
      for fk in t['foreign_keys']:
        cols=tuple(fk['columns']);ref=fk['references']
        out.append(f"ALTER TABLE {table} ADD CONSTRAINT fk_{corto(table)}_{cols_nombre(cols)} FOREIGN KEY ({','.join(cols)}) REFERENCES {ref['table']} ({','.join(ref['columns'])});")
        if not any(p[:len(cols)]==cols for p in prefixes):
          out.append(f"CREATE INDEX ix_{corto(table)}_{cols_nombre(cols)} ON {table} ({','.join(cols)});");prefixes.append(cols)
    out+=['PROMPT DDL de referencia creado; las reglas entre filas se comprueban con VALIDAR_MODELOS.sql.']
    (ruta('SCRIPT_BASE.sql')).write_text('\n'.join(out)+'\n')

def seed():
    data=json.loads((ruta('datos_sinteticos.json')).read_text())['tablas']
    out=caja('DATOS_FICTICIOS.sql: DATOS DE EJEMPLO','Datos completamente sintéticos para probar el modelo. Corte académico de demostración: 2026-09-15.',
      'Se ejecuta una sola vez, en el esquema OLTP de pruebas vacío. Las tablas se llenan en orden de dependencias.')+[HEAD]
    out+=sub('Requisito: todas las tablas vacías (se bloquean mientras se revisa)')+['DECLARE v_n NUMBER; BEGIN']
    for table in sorted(SCHEMA):out.append('    LOCK TABLE '+table+' IN EXCLUSIVE MODE NOWAIT;')
    for table in SCHEMA:
      out += [f'    SELECT COUNT(*) INTO v_n FROM {table};',f"    IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20071,'La semilla requiere todas las tablas vacías: {table}'); END IF;"]
    out+=['END;','/']
    for table in order():
      records=data[table];fields=SCHEMA[table]['fields'];cols=','.join(f['name'] for f in fields)
      batch_size=max(1,900//len(fields))
      out+=sub(f'{table.upper()}: {len(records)} filas')+[f"-- {SCHEMA[table]['description']}. Columnas explícitas; lotes de menos de 999 columnas."]
      for start in range(0,len(records),batch_size):
        out.append('INSERT ALL')
        for row in records[start:start+batch_size]:out.append('    INTO '+table+' ('+cols+') VALUES ('+','.join(literal(row[f['name']],f) for f in fields)+')')
        out.append('SELECT 1 FROM dual;')
    out+=['','COMMIT;','PROMPT Datos sintéticos cargados. Revisar PRUEBAS_ORACLE.sql tras cargar staging.']
    (ruta('DATOS_FICTICIOS.sql')).write_text('\n'.join(out)+'\n')

def create_staging():
    out=caja('CREACION_STAGING.sql: TABLAS DE STAGING',f'Crea las {len(P)} tablas STG (copias fechadas del OLTP, sin datos sensibles) y la guardia de carga.',
      'Si una tabla ya existe, comprueba su estructura en vez de recrearla: no borra ni vacía tablas.',
      'La carga la hace después EXEC pr_cargar_staging; (Validacion/07_CARGADOR_STAGING.sql).')+[HEAD]
    out+=sub('Creación y verificación')+['DECLARE','    v_n NUMBER; v_nullable VARCHAR2(1);',PROFILE_PROC,'BEGIN','    -- Contrato del OLTP: columnas y tipos que se van a copiar.',profile_calls(False)]
    for idx,(table,t) in enumerate(P.items(),1):
      expr=[f['expression'] if f.get('source_table') else 'CAST(NULL AS '+f['oracle_type']+')' for f in t['fields']]
      select='SELECT '+','.join(e+' AS '+f['name'] for e,f in zip(expr,t['fields']))+' FROM '+t['from_sql']+' WHERE 1 = 0'
      ddl='CREATE TABLE '+table+' SEGMENT CREATION IMMEDIATE AS '+select
      out += ['',f"    -- {table}: copia de {t['source_table']}",f"    SELECT COUNT(*) INTO v_n FROM user_tables WHERE table_name='{table}';",'    IF v_n=0 THEN','      EXECUTE IMMEDIATE '+q(ddl)+';']
      for f in t['fields']:
        if not f['nullable']:
          out += [f"      SELECT nullable INTO v_nullable FROM user_tab_columns WHERE table_name='{table}' AND column_name='{f['name'].upper()}';",f"      IF v_nullable='Y' THEN EXECUTE IMMEDIATE 'ALTER TABLE {table} MODIFY ({f['name']} NOT NULL)'; END IF;"]
      out += [f"      EXECUTE IMMEDIATE 'ALTER TABLE {table} ADD CONSTRAINT fk_{table.lower()}_carga FOREIGN KEY (id_ejecucion_carga) REFERENCES auditoria_etl_evaluaciones(id_ejecucion)';",f"      EXECUTE IMMEDIATE 'CREATE INDEX ix_{table.lower()}_carga ON {table}(id_ejecucion_carga)';",'    END IF;']
    out += ["    SELECT COUNT(*) INTO v_n FROM user_tables WHERE table_name='CTL_CARGA_STAGING';",'    IF v_n=0 THEN',"      EXECUTE IMMEDIATE 'CREATE TABLE ctl_carga_staging (id_control NUMBER(1,0) NOT NULL,version_carga NUMBER(10,0) NOT NULL,CONSTRAINT pk_ctl_carga_stg PRIMARY KEY (id_control),CONSTRAINT ck_ctl_carga_stg_id CHECK (id_control=1),CONSTRAINT ck_ctl_carga_stg_ver CHECK (version_carga>=0)) SEGMENT CREATION IMMEDIATE';","      EXECUTE IMMEDIATE 'INSERT INTO ctl_carga_staging (id_control,version_carga) VALUES (1,0)';",'      COMMIT;','    END IF;',profile_calls(True)]
    for seq,table,pk in [('SEQ_ETL_CARGA','auditoria_etl_evaluaciones','id_ejecucion'),('SEQ_ETL_ERROR','errores_etl_evaluaciones','id_error')]:
      out += [f"    SELECT COUNT(*) INTO v_n FROM user_sequences WHERE sequence_name='{seq}';",'    IF v_n=0 THEN',f'      SELECT NVL(MAX({pk}),0)+1 INTO v_n FROM {table};',f"      EXECUTE IMMEDIATE 'CREATE SEQUENCE {seq} START WITH '||TO_CHAR(v_n,'FM9999999990')||' INCREMENT BY 1 MAXVALUE 9999999999 NOCYCLE CACHE 20';",'    END IF;']
    out += ["    DBMS_OUTPUT.PUT_LINE('"+str(len(P))+" tablas STG y sus tipos comprobados. No se modificó el contenido existente.');",'END;','/']
    # La FK técnica debe existir también si la tabla ya estaba creada.
    out += ['DECLARE v_n NUMBER; BEGIN']
    for table in P:
      out += [f"SELECT COUNT(*) INTO v_n FROM user_constraints c JOIN user_cons_columns k ON k.constraint_name=c.constraint_name JOIN user_constraints p ON p.constraint_name=c.r_constraint_name WHERE c.table_name='{table}' AND c.constraint_type='R' AND c.status='ENABLED' AND c.validated='VALIDATED' AND k.column_name='ID_EJECUCION_CARGA' AND p.table_name='AUDITORIA_ETL_EVALUACIONES';",f"IF v_n<>1 THEN RAISE_APPLICATION_ERROR(-20014,'Falta FK técnica validada: {table}'); END IF;"]
    out += ['END;','/']
    out += sub('Comentarios de las tablas STG (se ven en el panel de Oracle)')
    for table,t in P.items():
      out += comentarios(table,f"Copia de {t['source_table']} por carga: {SCHEMA[t['source_table']]['description']}.",t['fields'])
    (ruta('CREACION_STAGING.sql')).write_text('\n'.join(out)+'\n')

def validate():
    out=caja('VALIDAR_MODELOS.sql: REVISIÓN DE REGLAS (SOLO LECTURA)',f'Ejecuta las {len(RULES)} reglas del contrato sobre los datos existentes, sin modificar nada. Las demás reglas',
      'del catálogo val_regla (texto no vacío y propias de las validaciones) las revisa pr_diagnosticar_validaciones.',
      'Falla solo si una regla BLOQUEO encuentra filas; PENDIENTE y AVISO solo se informan.','Funciona con o sin las validaciones instaladas.')+[HEAD]
    out+=['DECLARE v_n NUMBER;v_errores NUMBER:=0;','BEGIN']
    ENTRE_TABLAS={r['id'] for capa in ('OPERACION','STAGING') for r in academic_rules(capa)}
    actual=None
    for rule in RULES:
      propia=rule['id'] not in ENTRE_TABLAS
      clave=(rule['layer'],rule['table'],propia)
      if clave!=actual:
        actual=clave;out+=['',f"    -- === {rule['layer']}: {rule['table'].upper()}"+('' if propia else ' (reglas entre tablas)')+" ==="]
      if rule['severity']=='BLOQUEO':
        out += ['    EXECUTE IMMEDIATE '+q('SELECT COUNT(*) FROM ('+rule['sql']+')')+' INTO v_n;',
          '    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('+quote(rule['id']+': ')+'||v_n); END IF;']
      else:
        out += ['    EXECUTE IMMEDIATE '+q('SELECT COUNT(*) FROM ('+rule['sql']+')')+' INTO v_n;',
          '    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('+quote(rule['severity']+' '+rule['id']+': ')+'||v_n); END IF;']
    blocking=sum(r['severity']=='BLOQUEO' for r in RULES)
    out += ["    IF v_errores>0 THEN RAISE_APPLICATION_ERROR(-20040,TO_CHAR(v_errores)||' reglas BLOQUEO con infracciones.'); END IF;",f"    DBMS_OUTPUT.PUT_LINE('{blocking} reglas BLOQUEO sin infracciones; {len(RULES)-blocking} reglas PENDIENTE/AVISO informadas arriba si tienen filas.');",'END;','/']
    (ruta('VALIDAR_MODELOS.sql')).write_text('\n'.join(out)+'\n')

def dictionary():
    n_acad=sum(1 for x in P.values() for f in x["fields"] if f.get("source_table"))
    out=['# Diccionario de staging','', f'**{len(P)} tablas, {sum(len(x["fields"]) for x in P.values())} campos:** {n_acad} copiados del origen y {sum(len(x["fields"]) for x in P.values())-n_acad} metadatos de carga. El resumen para lectura rápida está en `Staging_en_resumen.md`.', '',
      'Cada columna copiada conserva el tipo Oracle, la nulabilidad y el significado de su campo de origen; su descripción está en `General/Diccionario_Datos_Educacion.md`. Las claves del origen se guardan como datos y se validan con reglas, sin PK/UK/FK físicas entre las STG, para poder diagnosticar duplicados y referencias rotas. La única FK física es la técnica: `id_ejecucion_carga` → `auditoria_etl_evaluaciones`. La tabla técnica `ctl_carga_staging` tiene una sola fila: el cargador la bloquea para que no haya dos cargas a la vez.', '',
      'Todas las tablas terminan con dos metadatos: `id_ejecucion_carga`, la ejecución técnica que hizo la copia (distinta del `id_ejecucion` de origen en STG_CONTROL_CARGA), y `fecha_carga`, el momento de la extracción, igual para todas las filas de una ejecución; nunca reemplaza las fechas académicas.', '']
    for name,t in P.items():
      out += ['### '+name,'','Origen: `'+t['from_sql']+'`.','', '| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |','|---|---|---|---|---|']
      for f in t['fields']:
        key='FK técnica' if f['name']=='id_ejecucion_carga' else (('Dato '+f['origin_key']+' del origen') if f.get('origin_key') else '—')
        if not f.get('source_table'):desc={'id_ejecucion_carga':'Ejecución que hizo la copia.','fecha_carga':'Momento de la copia.'}.get(f['name'],f['description'])
        elif f['name']==f['source_column']:desc='= `'+f['source_table']+'.'+f['source_column']+'`'
        else:desc='Renombrado de `'+f['source_table']+'.'+f['source_column']+'`.'
        out.append('| '+' | '.join([f['name'],f['oracle_type'],key,'Sí' if f['nullable'] else 'No',desc])+' |')
      out += ['']
    out+=['## Validación','','Las reglas están en `Pruebas/datos/reglas_validacion.json`; el resumen de las reglas de negocio, en `Validacion/Reglas_principales.md`. Las ejecutan `pr_cargar_staging` (`Validacion/07_CARGADOR_STAGING.sql`) y `VALIDAR_MODELOS.sql`. Solo bloquean las BLOQUEO; una infracción revierte toda la copia y queda registrada en la auditoría.','',
      'De `mae_persona` solo se copia lo necesario para cada rol: fecha de nacimiento y sexo del estudiante, nombres y apellidos del docente. Documento y contacto no se copian.']
    (ruta('Diccionario_Staging.md')).write_text('\n'.join(out)+'\n')

if __name__=='__main__':
    reference_ddl();seed();create_staging();validate();dictionary()
    print('Generados DDL de referencia, datos ficticios, creación de staging, validación y diccionario de staging.')
