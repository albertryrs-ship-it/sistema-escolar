"""Mutaciones de staging contenidas en SAVEPOINT/ROLLBACK; no alteran el OLTP."""
import json
from contrato_staging import ROOT,projections,all_rules
from rutas import ruta
from generar_sql import HEAD,q

RULES=all_rules()
def rule(suffix):
    matches=[r for r in RULES if r['layer']=='STAGING' and r['id'].endswith(suffix)]
    assert len(matches)==1,(suffix,[r['id'] for r in matches])
    return matches[0]
def duplicate(table,changes,where):
    cols=[f['name'] for f in projections()[table]['fields']]
    expr=[changes.get(c,c) for c in cols]
    return 'INSERT INTO '+table+' ('+','.join(cols)+') SELECT '+','.join(expr)+' FROM '+table+' WHERE '+where

CASES=[
 {'name':'Nota mayor que 100','rule':rule('TRX_CALIFICACION_CK_nota')['id'],'sql':["UPDATE STG_CALIFICACIONES SET nota=101 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES WHERE nota IS NOT NULL)"]},
 {'name':'Intento cero','rule':rule('TRX_CALIFICACION_CK_numero_intento')['id'],'sql':["UPDATE STG_CALIFICACIONES SET numero_intento=0 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)"]},
 {'name':'Ordinaria marcada como intento dos','rule':rule('TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION')['id'],'sql':["UPDATE STG_CALIFICACIONES SET numero_intento=2 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)"]},
 {'name':'Referencia de curso inexistente','rule':rule('TRX_INSCRIPCION_FK_curso')['id'],'sql':["UPDATE STG_INSCRIPCIONES SET id_curso=-999999 WHERE id_inscripcion=601"]},
 {'name':'Calificación ligada a otro curso','rule':rule('CALIFICACION_CONTEXTO')['id'],'sql':["UPDATE STG_CALIFICACIONES SET id_ponderacion_periodo=30111 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)"]},
 {'name':'Sexo fuera del dominio','rule':rule('MAE_ESTUDIANTE_CK_JOIN_sexo')['id'],'sql':["UPDATE STG_ESTUDIANTES SET sexo='X' WHERE id_estudiante=1001"]},
 {'name':'Clave académica duplicada','rule':rule('TRX_CALIFICACION_PK')['id'],'sql':[duplicate('STG_CALIFICACIONES',{},'id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)')]},
 {'name':'Intervalos de beca solapados','rule':rule('BECA_SOLAPADA')['id'],'sql':["UPDATE STG_BECAS_VIGENCIA SET fecha_inicio=DATE '2026-06-01' WHERE id_vigencia=70061"]},
 {'name':'Fecha académica con hora','rule':rule('TRX_CALIFICACION_CK_fecha_evaluacion')['id'],'sql':["UPDATE STG_CALIFICACIONES SET fecha_evaluacion=fecha_evaluacion+1/24 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)"],'sqlite':["UPDATE STG_CALIFICACIONES SET fecha_evaluacion=datetime(fecha_evaluacion,'+1 hour') WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)"]},
 {'name':'Sesión sin duración positiva','rule':rule('SESION_CONTEXTO')['id'],'sql':["UPDATE STG_SESIONES SET fin=inicio WHERE id_sesion=(SELECT MIN(id_sesion) FROM STG_SESIONES)"]},
 {'name':'Períodos con extremo inclusivo solapado','rule':rule('PERIODOS_SOLAPADOS')['id'],'sql':["UPDATE STG_PERIODOS SET fecha_inicio=DATE '2026-04-30' WHERE id_periodo=20262"]},
 {'name':'Becas simultáneas suman más de 100','rule':rule('PORCENTAJE_SIMULTANEO')['id'],'sql':[
    duplicate('STG_BECAS',{'id_beca':'999999','porcentaje':'60'},'id_beca=7003'),
    duplicate('STG_BECAS_VIGENCIA',{'id_vigencia':'999999','id_beca':'999999'},'id_vigencia=70030')
 ]},
 {'name':'Selección de recuperación peor bajo MEJOR_NOTA','rule':rule('SELECCION_POLITICA')['id'],'sql':["UPDATE STG_RESULTADOS_PERIODO SET id_calificacion_seleccionada=10042,fecha_seleccion=TIMESTAMP '2025-12-15 10:00:00' WHERE id_resultado=8041"]},
 {'name':'Selección de una versión ya corregida','rule':rule('SELECCION_VERSION_VIGENTE')['id'],'sql':[
    "UPDATE STG_CALIFICACIONES SET nota=70 WHERE id_calificacion=(SELECT id_calificacion_seleccionada FROM STG_RESULTADOS_PERIODO WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=2)",
    "UPDATE STG_RESULTADOS_PERIODO SET id_calificacion_seleccionada=(SELECT id_calificacion_seleccionada FROM STG_RESULTADOS_PERIODO WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=1) WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=2"
 ]},
 {'name':'Recuperación a cargo de una asignación ajena al período','rule':rule('RECUPERACION_RESPONSABLE')['id'],'sql':["UPDATE STG_ASIGNACIONES_DOCENTES SET fecha_fin=DATE '2025-08-31' WHERE id_asignacion=2001"]},
 {'name':'Numeración de períodos con hueco','rule':rule('PERIODOS_CONSECUTIVOS')['id'],'sql':["UPDATE STG_PERIODOS SET numero=5 WHERE id_periodo=20263"]},
 {'name':'Año de referencia distinto del inicio del ciclo','rule':rule('CICLO_ANIO_INICIO')['id'],'sql':["UPDATE STG_CICLOS SET anio=2030 WHERE id_ciclo=2024"]}
]

def write():
    byid={r['id']:r for r in RULES}
    out=['-- '+'='*62,'-- PRUEBAS_NEGATIVAS_ORACLE.sql: CASOS INVÁLIDOS EN STAGING','-- Descripción: Mete datos inválidos en las tablas STG y comprueba que cada regla los detecta.','--   Solo toca STG y cada cambio se revierte (SAVEPOINT / ROLLBACK).','-- '+'='*62,HEAD,'DECLARE v_n NUMBER; BEGIN']
    for i,case in enumerate(CASES,1):
      out+=['    SAVEPOINT caso_negativo;']
      for sql in case['sql']:out.append('    EXECUTE IMMEDIATE '+q(sql)+';')
      out+=['    EXECUTE IMMEDIATE '+q('SELECT COUNT(*) FROM ('+byid[case['rule']]['sql']+')')+' INTO v_n;',
        '    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'+"'"+case['name'].replace("'","''")+" no fue detectado.'); END IF;",
        '    ROLLBACK TO caso_negativo;',"    DBMS_OUTPUT.PUT_LINE('OK negativo: "+case['name'].replace("'","''")+"');"]
    out+=['    ROLLBACK;','END;','/']
    (ruta('PRUEBAS_NEGATIVAS_ORACLE.sql')).write_text('\n'.join(out)+'\n')
    (ruta('casos_invalidos.json')).write_text(json.dumps(CASES,ensure_ascii=False,indent=2)+'\n')
if __name__=='__main__':write();print(len(CASES),'casos negativos generados con rollback.')
