"""Contrato único de proyecciones de staging y verificaciones académicas."""
import json,re
from pathlib import Path

from rutas import ROOT,ruta
SCHEMA=json.loads((ruta('modelo_logico.json')).read_text())
MAPPINGS=[
 ('STG_CALIFICACIONES','trx_calificacion'),('STG_ASISTENCIAS','trx_asistencia'),
 ('STG_INSCRIPCIONES','trx_inscripcion'),('STG_ESTUDIANTES','mae_estudiante'),
 ('STG_CICLOS','est_ciclo'),('STG_PERIODOS','est_periodo_academico'),
 ('STG_CURSOS','est_curso'),('STG_CURSOS_ASIGNATURAS','est_curso_asignatura'),
 ('STG_PONDERACIONES','est_ponderacion_periodo'),('STG_RESULTADOS_PERIODO','trx_resultado_periodo'),
 ('STG_SESIONES','trx_sesion_clase'),('STG_ASIGNACIONES_DOCENTES','trx_asignacion_docente'),
 ('STG_INSTITUCIONES','mae_institucion'),('STG_INSTITUCIONES_CICLO','est_institucion_ciclo'),
 ('STG_GRADOS','cat_grado'),('STG_NIVELES','cat_nivel'),
 ('STG_BECAS','trx_beca'),('STG_BECAS_VIGENCIA','trx_beca_vigencia'),
 ('STG_PLAZOS_NOTAS','est_plazo_registro_notas'),('STG_CONTROL_CARGA','trx_control_carga'),
 ('STG_ASIGNATURAS','mae_asignatura'),('STG_DEPARTAMENTOS','cat_departamento'),
 ('STG_TIPOS_BECA','cat_tipo_beca'),('STG_TIPOS_INSTITUCION','cat_tipo_institucion'),
 ('STG_JORNADAS','cat_jornada'),('STG_MODALIDADES','cat_modalidad'),
 ('STG_DOCENTES','mae_docente'),('STG_ZONAS','cat_zona'),('STG_AREAS_CONOCIMIENTO','cat_area_conocimiento')]
# Atributos de mae_persona por rol: estudiantes solo lo necesario para KPI; docentes, nombre como etiqueta del BI.
# No se copian documento ni contacto.
PERSONA={'mae_estudiante':['fecha_nacimiento','sexo'],'mae_docente':['primer_nombre','segundo_nombre','primer_apellido','segundo_apellido']}
ROL={'mae_estudiante':'estudiante','mae_docente':'docente'}
OMIT={'mae_institucion':{'direccion','telefono','email'},'trx_sesion_clase':{'observaciones'},'trx_beca':{'observaciones'}}
TO_STAGE=dict((source,stage) for stage,source in MAPPINGS)

def projections():
    out={}
    for stage,source in MAPPINGS:
        fields=[]
        for f in SCHEMA[source]['fields']:
            if f['name'] in OMIT.get(source,set()):continue
            name=f['name']
            if source in ROL:
                name={'fecha_registro':'fecha_registro_'+ROL[source],'activo':ROL[source]+'_activo'}.get(name,name)
            fields.append({**f,'name':name,'source_table':source,'source_column':f['name'],'expression':'s.'+f['name'],'origin_key':f['key'],'key':''})
        if source in PERSONA:
            for name in PERSONA[source]:
                f=next(x for x in SCHEMA['mae_persona']['fields'] if x['name']==name)
                fields.append({**f,'source_table':'mae_persona','source_column':name,'expression':'p.'+name,'origin_key':'','key':''})
        fields+= [
          {'name':'id_ejecucion_carga','type':'int','oracle_type':'NUMBER(10,0)','nullable':False,'key':'FK','description':'Ejecución técnica que insertó esta copia; referencia auditoria_etl_evaluaciones. Es distinta del id_ejecucion de origen en STG_CONTROL_CARGA.','expression':'v_ejecucion','source_table':None,'source_column':None,'values':None},
          {'name':'fecha_carga','type':'timestamp','oracle_type':'TIMESTAMP(6)','nullable':False,'key':'','description':'Fecha y hora de extracción, igual para las filas de una ejecución. No sustituye las fechas académicas.','expression':'v_fecha_carga','source_table':None,'source_column':None,'values':None}
        ]
        out[stage]={'source_table':source,'from_sql':source+' s'+(' JOIN mae_persona p ON p.id_persona = s.id_persona' if source in PERSONA else ''),'fields':fields}
    return out

def table_name(source,layer):return TO_STAGE.get(source,source) if layer=='STAGING' else source

def academic_rules(layer):
    # Consultas de infracciones, no consultas que "arreglen" o borren datos.
    t=lambda source:table_name(source,layer)
    rules=[]
    def add(id,table,statement,body,severity='BLOQUEO'):
        for source in sorted(SCHEMA,key=len,reverse=True):body=re.sub(r'\b'+source+r'\b',t(source),body)
        rules.append({'id':layer+'_'+id,'layer':layer,'table':t(table),'severity':severity,'description':statement,'sql':body})
    add('PERIODO_CICLO','est_periodo_academico','Períodos configurables positivos, contenidos en su ciclo, sin duración fija.',"""SELECT p.* FROM est_periodo_academico p JOIN est_ciclo c ON c.id_ciclo=p.id_ciclo WHERE (p.numero<1 OR p.numero<>TRUNC(p.numero)) OR p.fecha_inicio<c.fecha_inicio OR p.fecha_fin>c.fecha_fin OR p.fecha_fin<p.fecha_inicio""")
    add('PERIODOS_SOLAPADOS','est_periodo_academico','No solapar períodos del mismo ciclo.',"""SELECT p.* FROM est_periodo_academico p WHERE EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND q.fecha_inicio<=p.fecha_fin AND p.fecha_inicio<=q.fecha_fin)""")
    add('PERIODOS_CONSECUTIVOS','est_periodo_academico','Períodos numerados 1..N sin huecos y en el orden de sus fechas; un hueco puede indicar un período no cargado.',"""SELECT p.* FROM est_periodo_academico p WHERE EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo GROUP BY q.id_ciclo HAVING MAX(q.numero)<>COUNT(*)) OR EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND ((q.numero<p.numero AND q.fecha_inicio>p.fecha_inicio) OR (q.numero>p.numero AND q.fecha_inicio<p.fecha_inicio)))""",'AVISO')
    add('CICLO_ANIO_INICIO','est_ciclo','El año de referencia es el año de inicio del ciclo, aunque cruce años calendario.',"""SELECT c.* FROM est_ciclo c WHERE c.anio<>EXTRACT(YEAR FROM c.fecha_inicio)""",'AVISO')
    add('PLAN_CICLO','est_ponderacion_periodo','Curso y período deben pertenecer al mismo ciclo.',"""SELECT p.* FROM est_ponderacion_periodo p JOIN est_curso_asignatura a ON a.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo WHERE c.id_ciclo<>x.id_ciclo""")
    # Conteos precalculados (COUNT() OVER y GROUP BY): los COUNT correlacionados se evaluaban fila por fila en STG sin índices.
    add('PLAN_COMPLETO','est_ponderacion_periodo','Un plan publicado cubre todos los períodos configurados de su ciclo.',"""SELECT p.* FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo IN (SELECT q.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_curso_asignatura,COUNT(*) OVER (PARTITION BY w.id_curso_asignatura) AS publicados FROM est_ponderacion_periodo w WHERE w.estado='PUBLICADO') q LEFT JOIN est_curso_asignatura a ON a.id_curso_asignatura=q.id_curso_asignatura LEFT JOIN est_curso c ON c.id_curso=a.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM est_periodo_academico GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE q.publicados<>COALESCE(v.periodos,0))""")
    add('OFERTA_CON_PLAN','est_curso_asignatura','Una oferta activa con matrícula no puede ocultar un plan anual ausente.',"""SELECT o.* FROM est_curso_asignatura o LEFT JOIN (SELECT id_curso_asignatura,COUNT(*) AS publicados FROM est_ponderacion_periodo WHERE estado='PUBLICADO' GROUP BY id_curso_asignatura) w ON w.id_curso_asignatura=o.id_curso_asignatura LEFT JOIN est_curso c ON c.id_curso=o.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM est_periodo_academico GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE o.estado='ACTIVA' AND EXISTS (SELECT 1 FROM trx_inscripcion i WHERE i.id_curso=o.id_curso AND i.estado<>'ANULADA') AND COALESCE(w.publicados,0)<>COALESCE(v.periodos,0)""",'PENDIENTE')
    add('PLAN_CON_PLAZO','est_ponderacion_periodo','Todo componente publicado tiene plazo ordinario del contexto correspondiente.',"""SELECT p.* FROM est_ponderacion_periodo p JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso WHERE p.estado='PUBLICADO' AND NOT EXISTS (SELECT 1 FROM est_plazo_registro_notas w WHERE w.id_institucion=c.id_institucion AND w.id_ciclo=c.id_ciclo AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA')""",'PENDIENTE')
    # Totales por oferta con SUM() OVER: la versión con subconsultas escalares recorría la tabla por cada pareja (horas en STG sin índices).
    add('PESOS_COMPARABLES','est_ponderacion_periodo','Mismo ciclo, grado y asignatura: igual vector normalizado.',"""SELECT p.* FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo IN (SELECT x.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM est_ponderacion_periodo w JOIN est_curso_asignatura a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') x JOIN (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM est_ponderacion_periodo w JOIN est_curso_asignatura a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') y ON y.id_periodo=x.id_periodo AND y.id_ciclo=x.id_ciclo AND y.id_grado=x.id_grado AND y.id_asignatura=x.id_asignatura WHERE ABS(x.peso*y.total-y.peso*x.total)>0.00000001)""")
    add('INSCRIPCION_CICLO','trx_inscripcion','Pertenencia dentro del ciclo, con intervalos inclusivos.',"""SELECT i.* FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE i.fecha_inicio<x.fecha_inicio OR i.fecha_inicio>x.fecha_fin OR (i.fecha_fin IS NOT NULL AND (i.fecha_fin<i.fecha_inicio OR i.fecha_fin>x.fecha_fin))""")
    # Intervalos inclusivos ordenados por inicio (LEAD/LAG sobre el máximo acumulado), como en SESIONES_SIMULTANEAS. Exacta con fin>=inicio,
    # que garantizan el CHECK de la tabla y la regla INSCRIPCION_CICLO.
    add('INSCRIPCIONES_SOLAPADAS','trx_inscripcion','No solapar matrículas ordinarias del mismo estudiante y ciclo.',"""SELECT i.* FROM trx_inscripcion i WHERE i.id_inscripcion IN (SELECT w.id_inscripcion FROM (SELECT v.*,LAG(v.max_fin) OVER (PARTITION BY v.id_estudiante,v.id_ciclo ORDER BY v.fecha_inicio,v.id_inscripcion) AS fin_previo FROM (SELECT t.id_inscripcion,t.id_estudiante,c.id_ciclo,t.fecha_inicio,COALESCE(t.fecha_fin,x.fecha_fin) AS fin,MAX(COALESCE(t.fecha_fin,x.fecha_fin)) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion ROWS UNBOUNDED PRECEDING) AS max_fin,LEAD(t.fecha_inicio) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion) AS inicio_siguiente FROM trx_inscripcion t JOIN est_curso c ON c.id_curso=t.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE t.estado<>'ANULADA') v) w WHERE w.fin_previo>=w.fecha_inicio OR w.inicio_siguiente<=w.fin)""")
    add('ASIGNACION_CICLO','trx_asignacion_docente','La responsabilidad ordinaria pertenece al ciclo de la oferta.',"""SELECT a.* FROM trx_asignacion_docente a JOIN est_curso_asignatura o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE a.fecha_inicio<x.fecha_inicio OR a.fecha_inicio>x.fecha_fin OR (a.fecha_fin IS NOT NULL AND (a.fecha_fin<a.fecha_inicio OR a.fecha_fin>x.fecha_fin))""")
    add('ASIGNACIONES_SOLAPADAS','trx_asignacion_docente','Un responsable por oferta y fecha.',"""SELECT a.* FROM trx_asignacion_docente a JOIN est_curso_asignatura o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE a.estado<>'ANULADA' AND EXISTS (SELECT 1 FROM trx_asignacion_docente b WHERE b.id_asignacion<>a.id_asignacion AND b.id_curso_asignatura=a.id_curso_asignatura AND b.estado<>'ANULADA' AND a.fecha_inicio<=COALESCE(b.fecha_fin,x.fecha_fin) AND b.fecha_inicio<=COALESCE(a.fecha_fin,x.fecha_fin))""")
    add('PLAZO_CICLO','est_plazo_registro_notas','El período del plazo pertenece a su ciclo.',"""SELECT w.* FROM est_plazo_registro_notas w JOIN est_periodo_academico p ON p.id_periodo=w.id_periodo WHERE w.id_ciclo<>p.id_ciclo""")
    add('RECUPERACION_FECHAS','est_plazo_registro_notas','Recuperación exige intervalo ordenado; ordinaria lo deja vacío.',"""SELECT w.* FROM est_plazo_registro_notas w WHERE (w.tipo_intento='ORDINARIA' AND (w.fecha_inicio_recuperacion IS NOT NULL OR w.fecha_fin_recuperacion IS NOT NULL)) OR (w.tipo_intento='RECUPERACION' AND (w.fecha_inicio_recuperacion IS NULL OR w.fecha_fin_recuperacion IS NULL OR w.fecha_fin_recuperacion<w.fecha_inicio_recuperacion))""")
    add('CALIFICACION_CONTEXTO','trx_calificacion','Calificación, inscripción y asignación corresponden a la misma oferta publicada.',"""SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE i.id_curso<>o.id_curso OR a.id_curso_asignatura<>o.id_curso_asignatura OR i.estado='ANULADA' OR a.estado='ANULADA' OR p.estado<>'PUBLICADO'""")
    add('TIPO_RESULTADO','trx_calificacion','Resultado numérico o cualitativo coherente con la oferta.',"""SELECT n.* FROM trx_calificacion n JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE (o.tipo_resultado='NUMERICA' AND (n.nota IS NULL OR n.resultado_cualitativo IS NOT NULL)) OR (o.tipo_resultado='CUALITATIVA' AND (n.nota IS NOT NULL OR n.resultado_cualitativo IS NULL))""")
    add('ORDINARIA_VIGENCIA','trx_calificacion','La fecha académica ordinaria está en período, matrícula y responsabilidad.',"""SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='ORDINARIA' AND (n.fecha_evaluacion<x.fecha_inicio OR n.fecha_evaluacion>x.fecha_fin OR n.fecha_evaluacion<i.fecha_inicio OR n.fecha_evaluacion>COALESCE(i.fecha_fin,x.fecha_fin) OR n.fecha_evaluacion<a.fecha_inicio OR n.fecha_evaluacion>COALESCE(a.fecha_fin,x.fecha_fin))""")
    add('RECUPERACION_RESPONSABLE','trx_calificacion','La recuperación queda a cargo de una asignación vigente en algún momento del período que recupera.',"""SELECT n.* FROM trx_calificacion n JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='RECUPERACION' AND (a.fecha_inicio>x.fecha_fin OR COALESCE(a.fecha_fin,x.fecha_fin)<x.fecha_inicio)""")
    add('ORIGEN_RECUPERACION','trx_calificacion','La recuperación referencia su ordinaria y conserva inscripción y plan.',"""SELECT n.* FROM trx_calificacion n JOIN trx_calificacion b ON b.id_calificacion=n.id_calificacion_ordinaria WHERE n.tipo_intento='RECUPERACION' AND (b.tipo_intento<>'ORDINARIA' OR b.numero_intento<>1 OR b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.fecha_evaluacion>n.fecha_evaluacion)""")
    add('VERSION_ANTERIOR','trx_calificacion','La sustituida es la versión previa del mismo intento y contexto.',"""SELECT n.* FROM trx_calificacion n JOIN trx_calificacion b ON b.id_calificacion=n.id_calificacion_sustituida WHERE b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.tipo_intento<>n.tipo_intento OR b.numero_intento<>n.numero_intento OR b.version+1<>n.version OR b.fecha_registro>n.fecha_registro""")
    # Calificaciones con plazo compatible por join directo y anti-join sobre la PK: el NOT EXISTS correlacionado con tres tablas
    # externas se evaluaba fila por fila en STG sin índices.
    add('CAPTURA_AUTORIZADA','trx_calificacion','Existe plazo compatible y la captura no precede apertura ni supera cierre real.',"""SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE n.id_calificacion NOT IN (SELECT m.id_calificacion FROM trx_calificacion m JOIN trx_inscripcion j ON j.id_inscripcion=m.id_inscripcion JOIN est_curso d ON d.id_curso=j.id_curso JOIN est_ponderacion_periodo q ON q.id_ponderacion_periodo=m.id_ponderacion_periodo JOIN est_plazo_registro_notas w ON w.id_institucion=d.id_institucion AND w.id_ciclo=d.id_ciclo AND w.id_grado=d.id_grado AND w.id_periodo=q.id_periodo AND w.tipo_intento=m.tipo_intento WHERE m.fecha_registro>=w.fecha_apertura_registro AND (w.fecha_cierre_registro IS NULL OR m.fecha_registro<=w.fecha_cierre_registro) AND (m.tipo_intento='ORDINARIA' OR m.fecha_evaluacion BETWEEN w.fecha_inicio_recuperacion AND w.fecha_fin_recuperacion))""")
    add('REGISTRO_NO_ANTICIPADO','trx_calificacion','El registro no precede al hecho académico.',"""SELECT n.* FROM trx_calificacion n WHERE TRUNC(n.fecha_registro)<n.fecha_evaluacion""")
    add('RESULTADO_CORRESPONDE','trx_resultado_periodo','La referencia seleccionada corresponde a estudiante, materia y período.',"""SELECT r.* FROM trx_resultado_periodo r JOIN trx_calificacion n ON n.id_calificacion=r.id_calificacion_seleccionada JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE r.id_estudiante<>i.id_estudiante OR r.id_asignatura<>o.id_asignatura OR r.id_periodo<>p.id_periodo OR n.fecha_validacion IS NULL OR r.fecha_seleccion<n.fecha_validacion OR (r.fecha_cierre IS NOT NULL AND r.fecha_cierre<r.fecha_seleccion) OR (n.fecha_anulacion IS NOT NULL AND n.fecha_anulacion<=r.fecha_seleccion)""")
    add('SELECCION_VERSION_VIGENTE','trx_resultado_periodo','Una selección usa la última versión validada de su intento en ese momento.',"""SELECT r.* FROM trx_resultado_periodo r JOIN trx_calificacion n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=n.id_inscripcion AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.tipo_intento=n.tipo_intento AND v.numero_intento=n.numero_intento AND v.version>n.version AND v.fecha_validacion<=r.fecha_seleccion)""")
    # Join explícito con las otras notas del contexto y última versión como NOT EXISTS de una posterior: el EXISTS con MAX correlacionado
    # no se desanidaba en Oracle y recorría las notas por cada resultado (horas en STG sin índices).
    add('SELECCION_POLITICA','trx_resultado_periodo','La elección respeta mejor nota o última recuperación a fecha de selección, sin anticipar eventos futuros.',"""SELECT r.* FROM trx_resultado_periodo r WHERE r.id_resultado IN (SELECT x.id_resultado FROM trx_resultado_periodo x JOIN trx_calificacion n ON n.id_calificacion=x.id_calificacion_seleccionada JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN trx_calificacion m ON m.id_inscripcion=n.id_inscripcion AND m.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE m.fecha_validacion<=x.fecha_seleccion AND (m.fecha_anulacion IS NULL OR m.fecha_anulacion>x.fecha_seleccion) AND ((o.regla_recuperacion='MEJOR_NOTA' AND o.tipo_resultado='NUMERICA' AND m.nota>n.nota) OR (o.regla_recuperacion='ULTIMA_RECUPERACION' AND m.numero_intento>n.numero_intento)) AND NOT EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=m.id_inscripcion AND v.id_ponderacion_periodo=m.id_ponderacion_periodo AND v.tipo_intento=m.tipo_intento AND v.numero_intento=m.numero_intento AND v.version>m.version AND v.fecha_validacion<=x.fecha_seleccion))""")
    add('SESION_CONTEXTO','trx_sesion_clase','Sesión y responsabilidad compatibles; noche puede terminar al día siguiente.',"""SELECT s.* FROM trx_sesion_clase s JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=s.id_asignacion WHERE p.id_curso_asignatura<>a.id_curso_asignatura OR s.fecha_academica<x.fecha_inicio OR s.fecha_academica>x.fecha_fin OR s.fecha_academica<a.fecha_inicio OR s.fecha_academica>COALESCE(a.fecha_fin,x.fecha_fin) OR s.fin<=s.inicio OR TRUNC(s.inicio)<>s.fecha_academica OR a.estado='ANULADA'""")
    # Ordenadas por inicio: el menor inicio posterior es LEAD y el mayor fin anterior es el máximo acumulado desplazado con LAG.
    # Los marcos ROWS ... 1 PRECEDING / 1 FOLLOWING se recalculaban por fila en Oracle (minutos con 250 mil sesiones).
    add('SESIONES_SIMULTANEAS','trx_sesion_clase','Un docente o grupo no recibe dos sesiones simultáneas.',"""SELECT s.* FROM trx_sesion_clase s WHERE s.id_sesion IN (SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,b.id_docente AS k,MAX(t.fin) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM trx_sesion_clase t JOIN trx_asignacion_docente b ON b.id_asignacion=t.id_asignacion WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin UNION SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,z.id_curso AS k,MAX(t.fin) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM trx_sesion_clase t JOIN est_ponderacion_periodo q ON q.id_ponderacion_periodo=t.id_ponderacion_periodo JOIN est_curso_asignatura z ON z.id_curso_asignatura=q.id_curso_asignatura WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin)""")
    add('ASISTENCIA_CONTEXTO','trx_asistencia','La asistencia pertenece al curso e intervalo de la sesión.',"""SELECT a.* FROM trx_asistencia a JOIN trx_inscripcion i ON i.id_inscripcion=a.id_inscripcion JOIN trx_sesion_clase s ON s.id_sesion=a.id_sesion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE i.id_curso<>o.id_curso OR i.estado='ANULADA' OR s.estado<>'IMPARTIDA' OR s.fecha_academica<i.fecha_inicio OR s.fecha_academica>COALESCE(i.fecha_fin,x.fecha_fin) OR a.fecha_registro<s.fin OR (a.estado IN ('AUSENTE','JUSTIFICADA') AND a.hora_llegada IS NOT NULL)""")
    add('BECA_HABILITADA','trx_beca','El beneficio respeta la habilitación histórica del centro.',"""SELECT b.* FROM trx_beca b JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_institucion_ciclo h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE h.permite_becas<>1 OR i.estado='ANULADA'""")
    add('BECA_VIGENCIA','trx_beca_vigencia','El intervalo efectivo queda dentro de matrícula y ciclo.',"""SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE v.fecha_inicio<i.fecha_inicio OR v.fecha_inicio>COALESCE(i.fecha_fin,x.fecha_fin) OR (v.fecha_fin IS NOT NULL AND (v.fecha_fin<v.fecha_inicio OR v.fecha_fin>COALESCE(i.fecha_fin,x.fecha_fin))) OR (v.fecha_fin IS NULL AND v.motivo_fin IS NOT NULL) OR (v.fecha_fin IS NOT NULL AND v.motivo_fin IS NULL)""")
    add('BECA_SOLAPADA','trx_beca_vigencia','Una beca no tiene intervalos efectivos solapados.',"""SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE EXISTS (SELECT 1 FROM trx_beca_vigencia w WHERE w.id_beca=v.id_beca AND w.id_vigencia<>v.id_vigencia AND v.fecha_inicio<=COALESCE(w.fecha_fin,x.fecha_fin) AND w.fecha_inicio<=COALESCE(v.fecha_fin,x.fecha_fin))""")
    add('PORCENTAJE_SIMULTANEO','trx_beca_vigencia','Beneficios simultáneos de la misma inscripción y base no superan 100.',"""SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE (SELECT SUM(z.porcentaje) FROM trx_beca_vigencia w JOIN trx_beca z ON z.id_beca=w.id_beca WHERE z.id_inscripcion=b.id_inscripcion AND w.fecha_inicio<=v.fecha_inicio AND COALESCE(w.fecha_fin,x.fecha_fin)>=v.fecha_inicio)>100""")
    add('CONTROL_CICLO','trx_control_carga','El curso y período del control pertenecen al mismo ciclo.',"""SELECT z.* FROM trx_control_carga z JOIN est_curso c ON c.id_curso=z.id_curso JOIN est_periodo_academico p ON p.id_periodo=z.id_periodo WHERE c.id_ciclo<>p.id_ciclo""")
    return rules

def columnas_nombre(cols):
    # Nombre legible de una clave: sus columnas sin el prefijo id_ (id_curso,id_periodo -> curso_periodo).
    return '_'.join(re.sub(r'^id_','',c) for c in cols)

def all_rules():
    out=[];proj=projections()
    for layer in ['OPERACION','STAGING']:
      tables=list(SCHEMA) if layer=='OPERACION' else list(TO_STAGE)
      for source in tables:
        table=table_name(source,layer)
        field_map={f['source_column']:f['name'] for f in proj[table]['fields'] if f.get('source_table')==source} if layer=='STAGING' else {f['name']:f['name'] for f in SCHEMA[source]['fields']}
        def remap(expr):
          for a,b in field_map.items():expr=re.sub(r'\b'+a+r'\b',b,expr)
          return expr
        def rule(id,desc,sql):out.append({'id':layer+'_'+source.upper()+'_'+id,'layer':layer,'table':table,'severity':'BLOQUEO','description':desc,'sql':sql})
        for f in SCHEMA[source]['fields']:
          if f['name'] not in field_map:continue
          col=field_map[f['name']]
          if not f['nullable']:rule('NN_'+col,'Campo obligatorio.',f'SELECT s.* FROM {table} s WHERE {col} IS NULL')
          checks=f.get('oracle_checks',[])
          for i,check in enumerate(checks,1):
            rule('CK_'+col+('_'+str(i) if len(checks)>1 else ''),'Dominio y rango acordados.',f'SELECT s.* FROM {table} s WHERE NOT ({remap(check)})')
        for r in SCHEMA[source].get('business_constraints',[]):
          check=r.get('oracle_check')
          if check:rule('BC_'+r['id'],r['statement'],f'SELECT s.* FROM {table} s WHERE NOT ({remap(check)})')
        keys=[tuple(f['name'] for f in SCHEMA[source]['fields'] if 'PK' in f['key'])]
        keys+= [tuple(u) for u in SCHEMA[source]['unique']]+[(f['name'],) for f in SCHEMA[source]['fields'] if 'UK' in f['key']]
        for i,key in enumerate(dict.fromkeys(keys),1):
          if not set(key)<=field_map.keys():continue
          cols=[field_map[c] for c in key];nonnull=' OR '.join(c+' IS NOT NULL' for c in cols)
          # La primera clave es la primaria; las demás se nombran por sus columnas.
          rule('PK' if i==1 else 'UK_'+columnas_nombre(key),'La clave de origen no puede repetirse.',f"SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY {','.join(cols)}) AS duplicados FROM {table} s) q WHERE q.duplicados>1 AND ({nonnull})")
        for i,fk in enumerate(SCHEMA[source]['foreign_keys'],1):
          if not set(fk['columns'])<=field_map.keys():continue
          parent=table_name(fk['references']['table'],layer)
          cc=[field_map[c] for c in fk['columns']];pc=fk['references']['columns']
          test=' AND '.join('s.'+c+' IS NOT NULL' for c in cc)
          relation=' AND '.join('p.'+p+'=s.'+c for c,p in zip(cc,pc))
          rule('FK_'+columnas_nombre(fk['columns']),'La referencia de origen debe existir.',f'SELECT s.* FROM {table} s WHERE {test} AND NOT EXISTS (SELECT 1 FROM {parent} p WHERE {relation})')
        if layer=='STAGING':
          for f in proj[table]['fields']:
            if f.get('source_table') and f['source_table']!=source:
              if not f['nullable']:rule('NN_JOIN_'+f['name'],'Campo de persona obligatorio.',f"SELECT s.* FROM {table} s WHERE {f['name']} IS NULL")
              jchecks=f.get('oracle_checks',[])
              for k,check in enumerate(jchecks,1):rule('CK_JOIN_'+f['name']+(str(k) if len(jchecks)>1 else ''),'Dominio de la persona conservado.',f'SELECT s.* FROM {table} s WHERE NOT ({check})')
          rule('METADATOS','Toda copia conserva una ejecución de carga existente.',f'SELECT s.* FROM {table} s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga)')
      out+=academic_rules(layer)
    ids=[r['id'] for r in out]
    assert len(ids)==len(set(ids)),'Hay identificadores de regla repetidos.'
    return out

if __name__=='__main__':
    (ruta('modelo_staging.json')).write_text(json.dumps(projections(),ensure_ascii=False,indent=2)+'\n')
    (ruta('reglas_validacion.json')).write_text(json.dumps(all_rules(),ensure_ascii=False,indent=2)+'\n')
    print('Staging:',len(projections()),'tablas,',sum(len(t['fields']) for t in projections().values()),'campos; reglas:',len(all_rules()))
