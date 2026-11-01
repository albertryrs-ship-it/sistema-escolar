"""Genera Validacion/Reglas_por_tabla.md desde el código: modelo lógico, DDL de referencia y las validaciones (Validacion/).
No ejecuta SQL; describe qué regla se aplica a cada tabla y con qué mecanismo."""
import json,re
from collections import defaultdict
from rutas import ROOT,ruta,texto_validaciones

SCHEMA=json.loads(ruta('modelo_logico.json').read_text())
STG=json.loads(ruta('modelo_staging.json').read_text())
VAL=texto_validaciones()
DDL=ruta('SCRIPT_BASE.sql').read_text()
DIC=ruta('Diccionario_Datos_Educacion.md').read_text()

TO_STG={d['source_table']:t for t,d in STG.items()}

# Catálogo val_regla
RULES=[]
for m in re.finditer(r"INSERT INTO val_regla VALUES \('([^']+)','([A-Z]+)','([^']+)','([A-Z]+)','((?:[^']|'')*)','((?:[^']|'')*)'\);",VAL):
    RULES.append(dict(id=m.group(1),capa=m.group(2),entidad=m.group(3),sev=m.group(4),desc=m.group(5).replace("''","'")))
LOADER=set(re.findall(r"comprobar_regla\('([^']+)'",VAL))

# Correspondencia con el diccionario (sección de trazabilidad)
DICMAP={}
for m in re.finditer(r'^\| ([A-Z_]+) \| (?:BLOQUEO|AVISO|PENDIENTE)[^|]* \| [^|]+ \| [^|]+ \| ([^|]+) \|$',DIC,re.M):
    DICMAP[m.group(1)]=m.group(2).strip()

# CHECK del DDL de referencia por tabla
DDL_CK=defaultdict(list)
for t,body in re.findall(r'(?ms)^CREATE TABLE (\w+) \((.*?)^\);',DDL):
    for ck in re.findall(r'CONSTRAINT \w+ CHECK \((.*)\),?$',body,re.M):DDL_CK[t].append(ck)

# Restricciones adicionales (Validacion/02_RESTRICCIONES.sql)
EXTRA=defaultdict(list)
for t,name,expr in re.findall(r'ALTER TABLE (\w+) ADD CONSTRAINT (\w+) CHECK \((.*)\) ENABLE VALIDATE;',VAL):EXTRA[t].append((name,expr))

# Triggers OLTP
TRG={}
for name,table,body in re.findall(r'(?ms)^CREATE OR REPLACE TRIGGER (trg_val_\w+)\n FOR INSERT OR UPDATE OR DELETE ON (\w+)\n(.*?)^END;\n/',VAL):
    TRG[table]=(name,body)
STG_TRG={t:n for n,t in re.findall(r'CREATE OR REPLACE TRIGGER (trg_\w+_inmutable)\n BEFORE INSERT OR UPDATE OR DELETE ON (\w+) FOR EACH ROW',VAL)}

CUSTOM={
 'Terminalidad utilizada por cierres historicos.':'`es_ultimo_grado` no cambia si el grado ya tiene inscripciones con `resultado_cierre`.',
 'Cierre/reapertura requiere procedimiento y motivo.':'Pasar a CERRADO o salir de CERRADO solo con `PR_CERRAR_CICLO` / `PR_REABRIR_CICLO`, que registran el motivo en `val_cambio` en la misma transacción.',
 'Contexto historico utilizado: requiere migracion revisada.':'Tipo, departamento, zona y `permite_becas` no cambian si el contexto ya tiene cursos.',
 'Grupo con historial; crear otro grupo.':'Institución, ciclo, grado, jornada y sección no cambian si el grupo tiene inscripciones; se crea otro grupo.',
 'Regla/tipo utilizados por notas validadas.':'`tipo_resultado` y `regla_recuperacion` no cambian si la oferta tiene notas validadas.',
 'Plan con notas validadas: no alterar historia.':'Un componente del plan con notas validadas no se modifica ni se borra.',
 'Reabrir plazo mediante procedimiento y motivo.':'Un plazo CERRADO solo se reabre con `PR_REABRIR_PLAZO` y motivo.',
 'No reasignar historial de inscripcion; usar traslado.':'`id_estudiante` e `id_curso` no se reasignan; el cambio de grupo se hace con `PR_TRASLADAR_ESTUDIANTE`.',
 'No se borra historia academica; usar anulacion/correccion.':'No se permite DELETE: se anula o se corrige con una versión nueva.',
}
def trigger_rules(table):
    if table not in TRG:return None,[]
    name,body=TRG[table];out=[]
    if 'No se renumeran claves primarias' in body:out.append('La clave primaria no se renumera en un UPDATE.')
    clean=re.findall(r':NEW\.(\w+):=fn_limpiar_texto',body)
    if clean:out.append('Normaliza espacios de texto antes de guardar: '+', '.join(f'`{c}`' for c in clean)+'.')
    fixed=re.findall(r"no sobrescribir (\w+)\.",body)
    if fixed:out.append('Columnas inmutables (una corrección crea otra versión): '+', '.join(f'`{c}`' for c in fixed)+'.')
    once=re.findall(r"No se reescribe (\w+);",body)
    if once:out.append('Se escriben una sola vez; después solo con nueva versión o reapertura: '+', '.join(f'`{c}`' for c in once)+'.')
    seen=set()
    for msg in re.findall(r"RAISE_APPLICATION_ERROR\(-20805,'([^']+)'\)",body):
        if msg in CUSTOM and msg not in seen:seen.add(msg);out.append(CUSTOM[msg])
    unknown=[m for m in re.findall(r"RAISE_APPLICATION_ERROR\(-\d+,'([^']+)'\)",body) if m not in CUSTOM and not re.match(r'(No se renumeran|Crear nueva version|No se reescribe)',m)]
    assert not unknown,(table,unknown)
    return name,out

# Procedimientos y tablas que modifican
PROCS=defaultdict(list)
for name,body in re.findall(r'(?ms)^CREATE OR REPLACE PROCEDURE (\w+)(.*?)^/$',VAL):
    if name in ('pr_cargar_staging','pr_probar_validaciones','pr_guardar_registro'):continue
    for t in set(x.lower() for x in re.findall(r'(?:INSERT INTO|UPDATE|DELETE FROM)\s+(\w+)',body)):
        if t in SCHEMA:PROCS[t].append(name.upper())
    for t in re.findall(r"pr_guardar_registro\('(\w+)'",body):
        if t in SCHEMA:PROCS[t].append(name.upper())
PROC_DESC={
 'PR_PUBLICAR_PLAN':'publica el plan solo si tiene un peso por cada período del ciclo',
 'PR_TRASLADAR_ESTUDIANTE':'cierra la inscripción de origen y abre la de destino en el mismo ciclo; no deja notas ordinarias posteriores a la salida',
 'PR_SELECCIONAR_RESULTADO':'crea una nueva versión de la selección con FN_ELEGIR_CALIFICACION; un resultado cerrado exige motivo',
 'PR_VALIDAR_CALIFICACION':'registra fecha_validacion y actualiza la selección en la misma transacción',
 'PR_ANULAR_CALIFICACION':'exige fecha y motivo y actualiza la selección; no revive versiones anteriores',
 'PR_SUSPENDER_BECA':'cierra el intervalo abierto con fecha y motivo',
 'PR_REANUDAR_BECA':'abre un intervalo nuevo',
 'PR_REABRIR_CICLO':'reabre un ciclo cerrado con motivo auditado',
 'PR_REABRIR_PLAZO':'reabre un plazo cerrado con motivo auditado',
 'PR_DECLARAR_COBERTURA':'no permite declarar COMPLETA si faltan registros o configuración al corte',
 'PR_CERRAR_CICLO':'cierra solo si el ciclo terminó y no hay notas ni asistencias pendientes',
 'PR_REGISTRAR_CALIFICACION':'inserta la calificación; si se indica fecha de validación, la valida y actualiza la selección en la misma transacción',
 'PR_CORREGIR_CALIFICACION':'exige motivo; agrega una versión nueva sobre la última del intento, la valida y actualiza la selección',
 'PR_OTORGAR_BECA':'registra la beca y abre su primer intervalo de vigencia',
}

def short(rid,capa,tbl):
    return rid[len(capa)+1:]
MIRROR=re.compile(r'_(NN|CK|UK|FK|NN_JOIN|CK_JOIN)_|_PK$|_METADATOS$|^(OPERACION|STAGING)_TEXTO_')

def how(r):
    if r['sev']!='BLOQUEO':return 'Diagnóstico ('+r['sev'].lower()+'): no bloquea'
    if r['id'].endswith('CAPACIDAD_ESTRICTA'):return 'Trigger (fin de sentencia), solo si `val_politica.capacidad_estricta = 1`; desactivada por defecto'
    if r['capa']=='OPERACION':
        return 'Trigger (fin de sentencia)'+(' + cargador' if r['id'] in LOADER else '')
    return 'Cargador ('+('revisión individual' if r['id'] in LOADER else 'validación final')+')'

def mirror_line(rules):
    groups=defaultdict(list)
    for r in rules:
        k=('TEXTO' if '_TEXTO_' in r['id'] else 'METADATOS' if r['id'].endswith('_METADATOS') else 'UK' if r['id'].endswith('_PK') else re.search(r'_(NN_JOIN|CK_JOIN|NN|CK|UK|FK)_',r['id']).group(1))
        groups[k].append(r['id'])
    label={'NN':'obligatorios','CK':'dominio/rango','UK':'claves únicas','FK':'referencias','TEXTO':'texto no vacío','METADATOS':'ejecución de carga','NN_JOIN':'persona obligatoria','CK_JOIN':'dominio de persona'}
    return ', '.join(f"{label[k]} {len(v)}" for k,v in groups.items())

out=['# Reglas por tabla','','Generado por `Pruebas/scripts/generar_reglas_por_tabla.py` desde `General/modelo_logico.json`, `General/SCRIPT_BASE.sql` y los archivos de `Validacion/` (reglas en `09_CATALOGO_REGLAS.sql`, CHECK en `02_RESTRICCIONES.sql`, triggers en `04_TRIGGERS_OLTP.sql` y `07_CARGADOR_STAGING.sql`).','',
 'Este documento enumera, tabla por tabla, cada regla que protege los datos y el mecanismo que la hace cumplir. Las reglas con nombre del diccionario se indican en la columna **Diccionario**. El resumen de las reglas de negocio más importantes está en `Reglas_principales.md`.','',
 'Las **reglas espejo** repiten en `val_regla` una restricción del DDL para poder diagnosticar datos existentes; aquí solo se cuentan. Se nombran `CAPA_TABLA_TIPO[_columnas]`, con TIPO `NN` (obligatorio), `CK` (dominio o rango), `PK` (clave primaria, sin columnas), `UK` (clave única), `FK` (referencia), `TEXTO` (texto no vacío) o `METADATOS` (ejecución de carga); en `UK` y `FK` las columnas van sin el prefijo `id_`. Por ejemplo, `OPERACION_TRX_BECA_NN_porcentaje` u `OPERACION_TRX_INSCRIPCION_FK_curso`. Toda tabla admite además `PR_GUARDAR_REGISTRO` (entrada por JSON que valida tipos, precisión y claves antes del DML).','',
 '## Mecanismos','',
 '| Mecanismo | Dónde se define | Cuándo actúa | Qué pasa si falla |','|---|---|---|---|',
 '| Estructura: NOT NULL, PK, UK, FK, CHECK | DDL del OLTP (`General/SCRIPT_BASE.sql` como referencia) | En cada fila, por Oracle | Error ORA- y la sentencia se revierte. |',
 '| CHECK adicional `ck_*_no_vacio` y otros | `02_RESTRICCIONES.sql`, `ENABLE VALIDATE` | En cada fila; al instalar también revisa los datos existentes | Error ORA-02290. Si los datos existentes no cumplen, la instalación se detiene. |',
 '| Trigger por fila `trg_val_<tabla>` (BEFORE EACH ROW) | `04_TRIGGERS_OLTP.sql` | Antes de cada INSERT/UPDATE/DELETE | Error -20805. |',
 '| Validación por sentencia `pr_validar_operacion` (AFTER STATEMENT del mismo trigger) | `val_regla`, severidad BLOQUEO, capa OPERACION; alcance en `val_regla_tabla` y `val_regla_ddl` | Al terminar cada sentencia DML; revisa las reglas BLOQUEO que leen la tabla modificada y omite las reglas espejo que una restricción habilitada del DDL ya garantiza. `PR_RECALCULAR_ALCANCE` calcula ese alcance al instalar y debe repetirse si cambia el DDL | Error -20802 con el ID de la regla; la sentencia se revierte. La instalación, el cargador y `pr_probar_validaciones` revisan todas las reglas. |',
 '| Auditoría de cambios (AFTER EACH ROW) | `val_cambio` | Si `val_politica.auditar_cambios = 1` (por defecto) | Guarda antes/después en JSON; no bloquea. |',
 '| Diagnóstico | `val_regla` (todas las severidades) | Al ejecutar `EXEC pr_diagnosticar_validaciones[(\'STAGING\')]` | Registra la cantidad en `val_incidencia`; las abiertas se ven en `VW_AVISOS_CALIDAD`. PENDIENTE y AVISO solo se informan aquí. |',
 '| Procedimientos `PR_*` | `06_OPERACIONES.sql` | Al usar la operación correspondiente (traslado, cierre, anulación…) | Error -208xx con el motivo; la operación se revierte. |',
 '| Cargador `pr_cargar_staging` | `07_CARGADOR_STAGING.sql` | Al cargar staging | Revisa una por una las reglas marcadas “(revisión individual)” y guarda una fila de ejemplo en `errores_etl_evaluaciones`; al final ejecuta `pr_validar_operacion(\'STAGING\')`, que cubre todas las BLOQUEO de staging. Cualquier fallo revierte la copia y deja la ejecución en ERROR. |',
 '| Trigger de staging `trg_stg_<tabla>_inmutable` | `07_CARGADOR_STAGING.sql` | Antes de cada fila STG | Las STG son inmutables: no se actualizan ni borran, y solo se insertan con una ejecución EN_PROCESO compatible. |',
 '','La columna **Cómo se aplica** usa: *Trigger (fin de sentencia)* = validación global en OLTP; *+ cargador* = además se revisa al cargar staging; *Cargador (revisión individual)* = el cargador la revisa una por una y guarda una fila de ejemplo si falla; *Cargador (validación final)* = la cubre `pr_validar_operacion(\'STAGING\')` al terminar la copia; *Diagnóstico* = solo se informa.','',
 '## Resumen','',]
from collections import Counter
c=Counter((r['capa'],r['sev']) for r in RULES)
out+=['| Capa | BLOQUEO | PENDIENTE | AVISO | Total |','|---|---:|---:|---:|---:|']
for capa in ['OPERACION','STAGING']:
    out.append(f"| {capa.title()} | {c[(capa,'BLOQUEO')]} | {c[(capa,'PENDIENTE')]} | {c[(capa,'AVISO')]} | {sum(v for (k,_),v in c.items() if k==capa)} |")
out+=[f"| Total | {sum(v for (_,s),v in c.items() if s=='BLOQUEO')} | {sum(v for (_,s),v in c.items() if s=='PENDIENTE')} | {sum(v for (_,s),v in c.items() if s=='AVISO')} | {len(RULES)} |",'',
 f"Además: {sum(map(len,EXTRA.values()))} CHECK adicionales, {len(TRG)} triggers OLTP, {len(STG_TRG)} triggers de staging. `auditoria_etl_evaluaciones` y `errores_etl_evaluaciones` no tienen trigger propio en las validaciones; sus reglas se aplican con la validación global y el diagnóstico.",'']

byent=defaultdict(list)
for r in RULES:byent[r['entidad'].lower()].append(r)
for table,t in SCHEMA.items():
    stg=TO_STG.get(table)
    out+=['---','',f'## {table}','',t['description']+('' if t['description'].endswith('.') else '.')+(f' Copia en staging: `{stg}`.' if stg else ' Sin copia en staging.'),'']
    pk=[f['name'] for f in t['fields'] if 'PK' in f['key']]
    uks=[tuple(u) for u in t['unique']]+[(f['name'],) for f in t['fields'] if 'UK' in f['key']]
    nn=[f['name'] for f in t['fields'] if not f['nullable']]
    out+=['**Estructura (DDL)**','',f"- PK: ({', '.join(pk)})."]
    if uks:out.append('- UK: '+'; '.join('('+', '.join(u)+')' for u in dict.fromkeys(uks))+'.')
    for fk in t['foreign_keys']:out.append(f"- FK: ({', '.join(fk['columns'])}) → `{fk['references']['table']}`.")
    out.append('- NOT NULL: '+', '.join(f'`{x}`' for x in nn)+'.')
    for ck in DDL_CK.get(table,[]):out.append(f'- CHECK: `{ck}`')
    out.append('')
    if EXTRA.get(table):
        out+=['**CHECK adicionales (02_RESTRICCIONES.sql)**','']+[f'- `{n}`: `{e}`' for n,e in EXTRA[table]]+['']
    name,trs=trigger_rules(table)
    if name:
        out+=[f'**Trigger `{name.upper()}`**: '+' '.join(trs),'']
    ops=[r for r in byent[table] if r['capa']=='OPERACION']
    biz=[r for r in ops if not MIRROR.search(r['id'])];mir=[r for r in ops if MIRROR.search(r['id'])]
    if biz:
        out+=['**Reglas de negocio (OLTP)**','','| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |','|---|---|---|---|---|']
        for r in biz:
            k=short(r['id'],'OPERACION',table)
            out.append(f"| `{k}` | {r['sev']} | {r['desc']} | {DICMAP.get(k,'—')} | {how(r)} |")
        out.append('')
    if mir:out+=['**Reglas espejo (OLTP, BLOQUEO)**: '+mirror_line(mir)+'.','']
    if PROCS.get(table):
        out+=['**Procedimientos**','']+[f"- `{p}`: {PROC_DESC.get(p,'operación auditada')}." for p in sorted(set(PROCS[table]))]+['']
    if stg:
        srules=[r for r in byent[stg.lower()] if r['capa']=='STAGING']
        sbiz=[r for r in srules if not MIRROR.search(r['id'])];smir=[r for r in srules if MIRROR.search(r['id'])]
        out+=[f'**Staging `{stg}`** (trigger `{STG_TRG[stg].upper()}`)','']
        if sbiz:out.append('- Reglas de negocio: '+'; '.join(f"`{short(r['id'],'STAGING',stg)}` ({r['sev']}, {how(r).lower()})" for r in sbiz)+'.')
        if smir:out.append('- Reglas espejo (BLOQUEO, cargador): '+mirror_line(smir)+'.')
        out.append('')

# verificación: toda regla del catálogo aparece exactamente en una sección
text='\n'.join(out)
missing=[r['id'] for r in RULES if not MIRROR.search(r['id']) and '`'+r['id']+'`' not in text and '`'+short(r['id'],r['capa'],'')+'`' not in text]
assert not missing,missing[:10]
contadas=sum(int(n) for n in re.findall(r'(?:obligatorios|dominio/rango|claves únicas|referencias|texto no vacío|ejecución de carga|persona obligatoria|dominio de persona) (\d+)',text))
assert contadas==sum(1 for r in RULES if MIRROR.search(r['id'])),(contadas,sum(1 for r in RULES if MIRROR.search(r['id'])))
ruta('Reglas_por_tabla.md').write_text(text+'\n')
print('Reglas_por_tabla.md:',len(RULES),'reglas,',len(SCHEMA),'tablas')
