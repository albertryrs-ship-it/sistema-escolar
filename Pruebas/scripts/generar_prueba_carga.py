"""Genera Pruebas/CARGA_Y_PRUEBA_VALIDACIONES.sql: carga un escenario completo por las vías validadas y
comprueba que las validaciones rechazan los casos inválidos. Antes de escribir el SQL, reproduce el escenario
en la referencia SQLite: los datos válidos no deben incumplir ninguna regla y cada caso negativo debe
incumplir exactamente la regla esperada. SQLite no sustituye una ejecución en Oracle."""
import json,re,sqlite3
from rutas import ruta,texto_validaciones
from validacion_local import connect,translate,prepare
from contrato_staging import SCHEMA

FT={t:{f['name']:f['type'] for f in d['fields']} for t,d in SCHEMA.items()}
PK={t:[f['name'] for f in d['fields'] if 'PK' in f['key']] for t,d in SCHEMA.items()}

# ---------------------------------------------------------------- escenario válido
# Colegio bilingüe con calendario agosto–junio (cruza años) y bachillerato de cuatro períodos.
I,C,G,CU=9901,9901,9901,9901
P=[990101,990102,990103,990104]
MAT,LEN=990101,990102                 # ofertas
DA,DB=9901,9902                       # docentes
E=[990111,990112,990113]              # estudiantes = inscripciones
AS_A_MAT,AS_B_MAT,AS_A_LEN=990101,990102,990103
pond=lambda oferta,p:oferta*100+p
STEPS=[]
def ins(t,**r):STEPS.append(('insert',t,r))
def guardar(t,**r):STEPS.append(('guardar',t,r))
ins('cat_tipo_documento',id_tipo_documento=9901,codigo='PRB_DUI',descripcion='Documento de prueba',activo=1)
ins('cat_tipo_institucion',id_tipo_institucion=9901,codigo='PRB_PRIVADA',descripcion='Privada (prueba)',activo=1)
ins('cat_departamento',id_departamento=9901,codigo='PRB-01',nombre='Departamento de prueba',activo=1)
ins('cat_zona',id_zona=9901,nombre='Zona de prueba',activo=1)
ins('cat_modalidad',id_modalidad=9901,codigo='PRB_PRESENCIAL',descripcion='Presencial (prueba)',activo=1)
ins('cat_jornada',id_jornada=9901,codigo='PRB_MATUTINA',descripcion='Matutina (prueba)',activo=1)
ins('cat_area_conocimiento',id_area=9901,codigo='PRB_CIENCIAS',descripcion='Ciencias (prueba)',activo=1)
ins('cat_area_conocimiento',id_area=9902,codigo='PRB_LENGUAJE',descripcion='Lenguaje (prueba)',activo=1)
ins('cat_tipo_beca',id_tipo_beca=9901,codigo='PRB_MERITO',descripcion='Mérito académico (prueba)',activo=1)
ins('cat_nivel',id_nivel=9901,codigo='PRB_BAC',nombre='Bachillerato (prueba)',orden=9)
ins('cat_grado',id_grado=G,id_nivel=9901,codigo='1',nombre='Primero de bachillerato (prueba)',orden=1,es_ultimo_grado=0)
ins('mae_institucion',id_institucion=I,codigo_institucion='PRB-CE-001',nombre='Colegio Bilingüe de Prueba',id_tipo_institucion=9901,id_departamento=9901,id_zona=9901,permite_becas=1,direccion='Dirección de prueba',telefono=None,email=None,fecha_creacion='2010-01-15',activo=1)
ins('est_ciclo',id_ciclo=C,codigo='PRB-2025-2026',nombre='Año escolar 2025-2026 (prueba)',anio=2025,fecha_inicio='2025-08-11',fecha_fin='2026-06-19',estado='ABIERTO')
for pid,n,a,b in zip(P,range(1,5),['2025-08-11','2025-10-20','2026-01-12','2026-04-06'],['2025-10-17','2025-12-19','2026-03-27','2026-06-19']):
    ins('est_periodo_academico',id_periodo=pid,id_ciclo=C,numero=n,nombre=f'Período {n}',fecha_inicio=a,fecha_fin=b)
ins('est_institucion_ciclo',id_institucion=I,id_ciclo=C,id_tipo_institucion=9901,id_departamento=9901,id_zona=9901,permite_becas=1,fecha_corte_matricula='2025-09-15',estado='ABIERTO')
ins('est_curso',id_curso=CU,id_institucion=I,id_ciclo=C,id_grado=G,id_jornada=9901,id_modalidad=9901,codigo='PRB-1BA-A',nombre='Primero de bachillerato A (prueba)',seccion='A',capacidad_maxima=30,estado='ACTIVO')
ins('mae_asignatura',id_asignatura=9901,codigo='PRB_MAT',nombre='Matemática (prueba)',id_area=9901,descripcion=None,activo=1)
ins('mae_asignatura',id_asignatura=9902,codigo='PRB_LEN',nombre='Lenguaje (prueba)',id_area=9902,descripcion=None,activo=1)
ins('est_curso_asignatura',id_curso_asignatura=MAT,id_curso=CU,id_asignatura=9901,horas_semanales=5,creditos=None,tipo_resultado='NUMERICA',regla_recuperacion='MEJOR_NOTA',estado='ACTIVA')
ins('est_curso_asignatura',id_curso_asignatura=LEN,id_curso=CU,id_asignatura=9902,horas_semanales=4,creditos=None,tipo_resultado='NUMERICA',regla_recuperacion='MEJOR_NOTA',estado='ACTIVA')
for oferta,peso in [(MAT,25),(LEN,1)]:
    for n,pid in enumerate(P,1):ins('est_ponderacion_periodo',id_ponderacion_periodo=pond(oferta,n),id_curso_asignatura=oferta,id_periodo=pid,peso=peso,estado='BORRADOR')
plazos=[(1,'2025-10-01 00:00:00','2025-10-24 23:59:59','CERRADA','2025-10-24 18:00:00'),(2,'2025-12-01 00:00:00','2025-12-19 23:59:59','CERRADA','2025-12-19 18:00:00'),
        (3,'2026-03-16 00:00:00','2026-03-31 23:59:59','ABIERTA',None),(4,'2026-06-08 00:00:00','2026-06-26 23:59:59','ABIERTA',None)]
for n,a,l,est,cierre in plazos:
    ins('est_plazo_registro_notas',id_plazo_registro_notas=9901000+n,id_institucion=I,id_ciclo=C,id_grado=G,id_periodo=P[n-1],tipo_intento='ORDINARIA',fecha_inicio_recuperacion=None,fecha_fin_recuperacion=None,fecha_apertura_registro=a,fecha_limite_registro=l,fecha_cierre_registro=cierre,estado=est)
ins('est_plazo_registro_notas',id_plazo_registro_notas=9901011,id_institucion=I,id_ciclo=C,id_grado=G,id_periodo=P[0],tipo_intento='RECUPERACION',fecha_inicio_recuperacion='2025-10-27',fecha_fin_recuperacion='2025-10-31',fecha_apertura_registro='2025-10-27 00:00:00',fecha_limite_registro='2025-11-07 23:59:59',fecha_cierre_registro='2025-11-07 18:00:00',estado='CERRADA')
STEPS.append(('publicar',MAT));STEPS.append(('publicar',LEN))
# Personas por la entrada JSON validada
guardar('mae_persona',id_persona=990101,id_tipo_documento=9901,numero_documento='PRB-DOC-001',primer_nombre='Marta',segundo_nombre=None,primer_apellido='Docente',segundo_apellido='Prueba',fecha_nacimiento='1985-04-20',sexo='F',email='marta@example.invalid',telefono=None,direccion=None,fecha_registro='2025-07-01 08:00:00')
guardar('mae_persona',id_persona=990102,id_tipo_documento=9901,numero_documento='PRB-DOC-002',primer_nombre='Raúl',segundo_nombre=None,primer_apellido='Docente',segundo_apellido='Prueba',fecha_nacimiento='1979-11-02',sexo='M',email=None,telefono=None,direccion=None,fecha_registro='2025-07-01 08:05:00')
for k,(nom,ape,sx) in enumerate([('Andrea','Prueba','F'),('Bruno','Prueba','M'),('Camila','Prueba','F')]):
    guardar('mae_persona',id_persona=E[k],id_tipo_documento=None,numero_documento=None,primer_nombre=nom,segundo_nombre=None,primer_apellido=ape,segundo_apellido=None,fecha_nacimiento='2009-03-1'+str(k),sexo=sx,email=None,telefono=None,direccion=None,fecha_registro='2025-07-15 09:00:00')
guardar('mae_docente',id_docente=DA,id_persona=990101,especialidad='Matemática y lenguaje',fecha_registro='2025-07-01 08:10:00',activo=1)
guardar('mae_docente',id_docente=DB,id_persona=990102,especialidad='Matemática',fecha_registro='2025-07-01 08:15:00',activo=1)
for k,e in enumerate(E):guardar('mae_estudiante',id_estudiante=e,id_persona=e,nie=f'PRB{k+1:08}',fecha_registro='2025-07-15 09:10:00',activo=1)
# Responsables: A en Matemática hasta diciembre y B desde enero; A en Lenguaje todo el ciclo
ins('trx_asignacion_docente',id_asignacion=AS_A_MAT,id_docente=DA,id_curso_asignatura=MAT,fecha_asignacion='2025-08-01 10:00:00',fecha_inicio='2025-08-11',fecha_fin='2025-12-19',estado='FINALIZADA')
ins('trx_asignacion_docente',id_asignacion=AS_B_MAT,id_docente=DB,id_curso_asignatura=MAT,fecha_asignacion='2025-12-15 10:00:00',fecha_inicio='2026-01-12',fecha_fin=None,estado='VIGENTE')
ins('trx_asignacion_docente',id_asignacion=AS_A_LEN,id_docente=DA,id_curso_asignatura=LEN,fecha_asignacion='2025-08-01 10:00:00',fecha_inicio='2025-08-11',fecha_fin=None,estado='VIGENTE')
for e in E:ins('trx_inscripcion',id_inscripcion=e,id_estudiante=e,id_curso=CU,fecha_inscripcion='2025-08-04 09:00:00',fecha_inicio='2025-08-11',fecha_fin=None,estado='VIGENTE',motivo_fin_inscripcion=None,resultado_cierre=None)
for sid,oferta,asig,dia,h in [(99010001,MAT,AS_A_MAT,'2025-08-18','07'),(99010002,MAT,AS_A_MAT,'2025-08-20','07'),(99010003,LEN,AS_A_LEN,'2025-08-18','08')]:
    ins('trx_sesion_clase',id_sesion=sid,id_ponderacion_periodo=pond(oferta,1),id_asignacion=asig,fecha_academica=dia,inicio=f'{dia} {h}:00:00',fin=f'{dia} {h}:45:00',estado='IMPARTIDA',observaciones=None)
aid=99020000
for sid,dia,h in [(99010001,'2025-08-18','07'),(99010003,'2025-08-18','08')]:
    for e,(est,lleg) in zip(E,[('PRESENTE',f'{dia} {h}:00:00'),('TARDE',f'{dia} {h}:12:00'),('AUSENTE',None)]):
        aid+=1;ins('trx_asistencia',id_asistencia=aid,id_inscripcion=e,id_sesion=sid,estado=est,hora_llegada=lleg,fecha_registro=f'{dia} 12:00:00',observaciones=None)
# Notas: registro y validación con su procedimiento (cada validación crea la selección del período)
cal,res=99011000,99012000
NOTAS={}
def nota(e,oferta,n,valor,asig,ev,reg,val,tipo='ORDINARIA',intento=1,ordinaria=None):
    global cal,res
    cal+=1;res+=1
    row=dict(id_calificacion=cal,id_inscripcion=e,id_ponderacion_periodo=pond(oferta,n),tipo_intento=tipo,numero_intento=intento,version=1,id_calificacion_ordinaria=ordinaria,id_calificacion_sustituida=None,id_asignacion_docente=asig,id_docente_registra=DA,nota=valor,resultado_cualitativo=None,fecha_evaluacion=ev,fecha_registro=reg)
    STEPS.append(('nota',row,res,val));NOTAS[(e,oferta,n,tipo)]=cal
for e,v in zip(E,[50,82,90]):nota(e,MAT,1,v,AS_A_MAT,'2025-10-10','2025-10-15 08:00:00','2025-10-16 09:00:00')
for e,v in zip(E,[70,88,64]):nota(e,LEN,1,v,AS_A_LEN,'2025-10-09','2025-10-15 08:30:00','2025-10-16 09:30:00')
nota(E[0],MAT,1,75,AS_A_MAT,'2025-10-29','2025-10-30 10:00:00','2025-10-30 12:00:00',tipo='RECUPERACION',intento=2,ordinaria=NOTAS[(E[0],MAT,1,'ORDINARIA')])
for e,v in zip(E,[68,74,95]):nota(e,MAT,2,v,AS_A_MAT,'2025-12-12','2025-12-15 08:00:00','2025-12-16 09:00:00')
# Beca del segundo estudiante: otorgada, suspendida en diciembre y reanudada en enero
STEPS.append(('beca',dict(id_beca=99013001,id_inscripcion=E[1],id_tipo_beca=9901,porcentaje=50,fecha_otorgamiento='2025-08-05',fecha_registro='2025-08-05 09:00:00',observaciones=None),99013101,'2025-08-11'))
STEPS.append(('suspender',99013001,'2025-11-30','SUSPENSION'))
STEPS.append(('reanudar',99013001,99013102,'2026-01-12'))

# ---------------------------------------------------------------- casos inválidos
def nota_row(**k):
    base=dict(id_calificacion=99019001,id_inscripcion=E[2],id_ponderacion_periodo=pond(LEN,2),tipo_intento='ORDINARIA',numero_intento=1,version=1,id_calificacion_ordinaria=None,id_calificacion_sustituida=None,id_asignacion_docente=AS_A_LEN,id_docente_registra=DA,nota=80,resultado_cualitativo=None,fecha_evaluacion='2025-12-10',fecha_registro='2025-12-15 08:00:00')
    base.update(k);return base
REGLA=lambda r:('regla','OPERACION_'+r)
NEG=[
 ('Nota mayor que 100',[('guardar','trx_calificacion',nota_row(nota=101))],('check',)),
 ('Ordinaria registrada como intento 2',[('guardar','trx_calificacion',nota_row(numero_intento=2))],('check',)),
 ('Recuperación a cargo de un docente de otro período',[('guardar','trx_calificacion',nota_row(id_inscripcion=E[1],id_ponderacion_periodo=pond(MAT,1),tipo_intento='RECUPERACION',numero_intento=2,id_calificacion_ordinaria=NOTAS[(E[1],MAT,1,'ORDINARIA')],id_asignacion_docente=AS_B_MAT,nota=85,fecha_evaluacion='2025-10-29',fecha_registro='2025-10-30 10:00:00'))],REGLA('RECUPERACION_RESPONSABLE')),
 ('Inscripción ordinaria solapada',[('insert','trx_inscripcion',dict(id_inscripcion=99019002,id_estudiante=E[0],id_curso=CU,fecha_inscripcion='2025-08-25 09:00:00',fecha_inicio='2025-09-01',fecha_fin=None,estado='VIGENTE',motivo_fin_inscripcion=None,resultado_cierre=None))],REGLA('INSCRIPCIONES_SOLAPADAS')),
 ('Dos docentes responsables a la vez',[('insert','trx_asignacion_docente',dict(id_asignacion=99019003,id_docente=DB,id_curso_asignatura=MAT,fecha_asignacion='2025-08-25 10:00:00',fecha_inicio='2025-09-01',fecha_fin='2025-09-30',estado='VIGENTE'))],REGLA('ASIGNACIONES_SOLAPADAS')),
 ('Período fuera de su ciclo',[('insert','est_ciclo',dict(id_ciclo=9902,codigo='PRB-NEG-1',nombre='Ciclo negativo',anio=2027,fecha_inicio='2027-02-01',fecha_fin='2027-11-30',estado='PLANIFICADO')),
   ('insert','est_periodo_academico',dict(id_periodo=990201,id_ciclo=9902,numero=1,nombre='Período 1',fecha_inicio='2027-02-01',fecha_fin='2027-12-15'))],REGLA('PERIODO_CICLO')),
 ('Sesión que empieza otro día que su fecha académica',[('insert','trx_sesion_clase',dict(id_sesion=99019004,id_ponderacion_periodo=pond(MAT,1),id_asignacion=AS_A_MAT,fecha_academica='2025-08-25',inicio='2025-08-26 07:00:00',fin='2025-08-26 07:45:00',estado='IMPARTIDA',observaciones=None))],REGLA('SESION_CONTEXTO')),
 ('Asistencia registrada antes de terminar la clase',[('insert','trx_asistencia',dict(id_asistencia=99019005,id_inscripcion=E[0],id_sesion=99010002,estado='PRESENTE',hora_llegada='2025-08-20 07:00:00',fecha_registro='2025-08-20 07:10:00',observaciones=None))],REGLA('ASISTENCIA_CONTEXTO')),
 ('Ausente con hora de llegada',[('insert','trx_asistencia',dict(id_asistencia=99019006,id_inscripcion=E[0],id_sesion=99010002,estado='AUSENTE',hora_llegada='2025-08-20 07:05:00',fecha_registro='2025-08-20 12:00:00',observaciones=None))],('check',)),
 ('Beca mayor al 100 %',[('insert','trx_beca',dict(id_beca=99019007,id_inscripcion=E[2],id_tipo_beca=9901,porcentaje=150,fecha_otorgamiento='2025-08-05',fecha_registro='2025-08-05 09:00:00',observaciones=None))],('check',)),
 ('Vigencia de beca anterior a la inscripción',[('insert','trx_beca',dict(id_beca=99019008,id_inscripcion=E[2],id_tipo_beca=9901,porcentaje=30,fecha_otorgamiento='2025-07-20',fecha_registro='2025-07-20 09:00:00',observaciones=None)),
   ('insert','trx_beca_vigencia',dict(id_vigencia=99019009,id_beca=99019008,fecha_inicio='2025-08-01',fecha_fin=None,motivo_fin=None,fecha_registro='2025-07-20 09:00:00'))],REGLA('BECA_VIGENCIA')),
 ('Retiro sin fecha de fin ni motivo',[('update','trx_inscripcion',{'estado':'RETIRADA'},{'id_inscripcion':E[2]})],('check',)),
 ('Plan publicado con un período faltante',[('insert','mae_asignatura',dict(id_asignatura=9903,codigo='PRB_CIE',nombre='Ciencias (prueba)',id_area=9901,descripcion=None,activo=1)),
   ('insert','est_curso_asignatura',dict(id_curso_asignatura=990103,id_curso=CU,id_asignatura=9903,horas_semanales=3,creditos=None,tipo_resultado='NUMERICA',regla_recuperacion='MEJOR_NOTA',estado='ACTIVA'))]+
   [('insert','est_ponderacion_periodo',dict(id_ponderacion_periodo=pond(990103,n),id_curso_asignatura=990103,id_periodo=P[n-1],peso=1,estado='BORRADOR')) for n in (1,2,3)]+[('publicar',990103)],('error',-20810)),
 ('Modificar una nota ya validada',[('update','trx_calificacion',{'nota':60},{'id_calificacion':NOTAS[(E[1],MAT,1,'ORDINARIA')]})],('error',-20805)),
 ('Borrar una calificación',[('delete','trx_calificacion',{'id_calificacion':NOTAS[(E[1],MAT,1,'ORDINARIA')]})],('error',-20805)),
 ('Cambiar el peso de un plan con notas validadas',[('update','est_ponderacion_periodo',{'peso':40},{'id_ponderacion_periodo':pond(MAT,1)})],('error',-20805)),
 ('Cerrar el ciclo sin procedimiento',[('update','est_ciclo',{'estado':'CERRADO'},{'id_ciclo':C})],('error',-20805)),
 ('Entrada JSON: identificador con decimales',[('json','cat_zona','{"id_zona":9902.5,"nombre":"Zona decimal","activo":1}')],('error',-20803)),
 ('Entrada JSON: campo desconocido',[('json','cat_zona','{"id_zona":9902,"nombre":"Zona extra","activo":1,"color":"rojo"}')],('error',-20804)),
]
AVISOS=[
 ('Numeración de períodos con hueco',[('insert','est_ciclo',dict(id_ciclo=9903,codigo='PRB-AVISO-1',nombre='Ciclo con hueco',anio=2027,fecha_inicio='2027-02-01',fecha_fin='2027-11-30',estado='PLANIFICADO')),
   ('insert','est_periodo_academico',dict(id_periodo=990302,id_ciclo=9903,numero=2,nombre='Período 2',fecha_inicio='2027-02-01',fecha_fin='2027-05-31'))],'OPERACION_PERIODOS_CONSECUTIVOS'),
 ('Año de referencia distinto del inicio del ciclo',[('insert','est_ciclo',dict(id_ciclo=9904,codigo='PRB-AVISO-2',nombre='Ciclo con año incorrecto',anio=2026,fecha_inicio='2027-02-01',fecha_fin='2027-11-30',estado='PLANIFICADO'))],'OPERACION_CICLO_ANIO_INICIO'),
 ('Oferta activa con matrícula y sin plan',[('insert','mae_asignatura',dict(id_asignatura=9904,codigo='PRB_ART',nombre='Artes (prueba)',id_area=9902,descripcion=None,activo=1)),
   ('insert','est_curso_asignatura',dict(id_curso_asignatura=990104,id_curso=CU,id_asignatura=9904,horas_semanales=2,creditos=None,tipo_resultado='NUMERICA',regla_recuperacion='MEJOR_NOTA',estado='ACTIVA'))],'OPERACION_OFERTA_CON_PLAN'),
]

# ---------------------------------------------------------------- reglas de las validaciones
V=texto_validaciones()
RULES=[(m.group(1),m.group(2),m.group(4),m.group(5).replace("''","'")) for m in re.finditer(r"INSERT INTO val_regla VALUES \('([^']+)','([A-Z]+)','([^']+)','([A-Z]+)','(?:[^']|'')*','((?:[^']|'')*)'\);",V)]
CV=re.findall(r'ALTER TABLE (\w+) ADD CONSTRAINT (\w+) CHECK \((.*)\) ENABLE VALIDATE;',V)
def tr(sql):return translate(sql)

# ---------------------------------------------------------------- emulación en SQLite
def ins_sqlite(db,t,r):db.execute(f"INSERT INTO {t} ({','.join(r)}) VALUES ({','.join('?'*len(r))})",list(r.values()))
def elegir(db,e,asig,per,corte):
    rows=db.execute("""SELECT n.id_calificacion,n.nota,n.numero_intento,n.version,n.tipo_intento,n.id_inscripcion,n.id_ponderacion_periodo FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion
      JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura
      WHERE i.id_estudiante=? AND o.id_asignatura=? AND p.id_periodo=? AND n.fecha_validacion<=? AND (n.fecha_anulacion IS NULL OR n.fecha_anulacion>?)""",(e,asig,per,corte,corte)).fetchall()
    rows=[r for r in rows if not any(x['version']>r['version'] and x['numero_intento']==r['numero_intento'] and x['tipo_intento']==r['tipo_intento'] and x['id_inscripcion']==r['id_inscripcion'] for x in rows)]
    return sorted(rows,key=lambda r:(-r['nota'],r['numero_intento']))[0]
def apply(db,step):
    k=step[0]
    if k in ('insert','guardar'):ins_sqlite(db,step[1],step[2])
    elif k=='json':
        r=json.loads(step[2]);assert set(r)<=set(FT[step[1]]) and all(not isinstance(r[c],float) or r[c]==int(r[c]) for c in r if FT[step[1]][c]=='int'),'entrada inválida'
        ins_sqlite(db,step[1],r)
    elif k=='publicar':
        n=db.execute('SELECT COUNT(*) FROM est_ponderacion_periodo WHERE id_curso_asignatura=? AND estado<>?',(step[1],'ANULADO')).fetchone()[0]
        e=db.execute('SELECT COUNT(*) FROM est_periodo_academico p JOIN est_curso c ON c.id_ciclo=p.id_ciclo JOIN est_curso_asignatura o ON o.id_curso=c.id_curso WHERE o.id_curso_asignatura=?',(step[1],)).fetchone()[0]
        assert e and n==e,'plan incompleto'
        db.execute("UPDATE est_ponderacion_periodo SET estado='PUBLICADO' WHERE id_curso_asignatura=? AND estado='BORRADOR'",(step[1],))
    elif k=='nota':
        row,rid,val=step[1],step[2],step[3];ins_sqlite(db,'trx_calificacion',{**row,'fecha_validacion':val})
        e,asig,per=db.execute('SELECT i.id_estudiante,o.id_asignatura,p.id_periodo FROM trx_inscripcion i,est_ponderacion_periodo p JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE i.id_inscripcion=? AND p.id_ponderacion_periodo=?',(row['id_inscripcion'],row['id_ponderacion_periodo'])).fetchone()
        sel=elegir(db,e,asig,per,val)
        v=db.execute('SELECT COALESCE(MAX(version),0)+1 FROM trx_resultado_periodo WHERE id_estudiante=? AND id_asignatura=? AND id_periodo=?',(e,asig,per)).fetchone()[0]
        crit='ORDINARIA' if sel['tipo_intento']=='ORDINARIA' else 'MEJOR_NOTA'
        ins_sqlite(db,'trx_resultado_periodo',dict(id_resultado=rid,id_estudiante=e,id_asignatura=asig,id_periodo=per,id_calificacion_seleccionada=sel['id_calificacion'],version=v,criterio=crit,fecha_seleccion=val,fecha_cierre=None))
    elif k=='beca':
        ins_sqlite(db,'trx_beca',step[1]);ins_sqlite(db,'trx_beca_vigencia',dict(id_vigencia=step[2],id_beca=step[1]['id_beca'],fecha_inicio=step[3],fecha_fin=None,motivo_fin=None,fecha_registro='2025-08-05 09:00:00'))
    elif k=='suspender':db.execute('UPDATE trx_beca_vigencia SET fecha_fin=?,motivo_fin=? WHERE id_beca=? AND fecha_fin IS NULL',(step[2],step[3],step[1]))
    elif k=='reanudar':ins_sqlite(db,'trx_beca_vigencia',dict(id_vigencia=step[2],id_beca=step[1],fecha_inicio=step[3],fecha_fin=None,motivo_fin=None,fecha_registro='2026-01-12 08:00:00'))
    elif k=='update':db.execute(f"UPDATE {step[1]} SET {','.join(c+'=?' for c in step[2])} WHERE {' AND '.join(c+'=?' for c in step[3])}",list(step[2].values())+list(step[3].values()))
    elif k=='delete':db.execute(f"DELETE FROM {step[1]} WHERE {' AND '.join(c+'=?' for c in step[2])}",list(step[2].values()))
def failing(db):
    out={}
    for rid,capa,sev,sql in RULES:
        if capa!='OPERACION':continue
        n=db.execute('SELECT COUNT(*) FROM ('+tr(sql)+')').fetchone()[0]
        if n:out[rid]=(sev,n)
    for t,name,expr in CV:
        if db.execute(f'SELECT COUNT(*) FROM {t} WHERE NOT ({tr(expr)})').fetchone()[0]:out[name]=('CHECK',1)
    return out
def fresh(seed):
    if seed:db,_=prepare()
    else:db=connect()
    db.execute('CREATE TABLE val_politica (id INTEGER, capacidad_estricta INTEGER)');db.execute('INSERT INTO val_politica VALUES (1,0)')
    return db

def verify():
    for seed in (False,True):
        db=fresh(seed);base=failing(db)
        for s in STEPS:apply(db,s)
        new={k:v for k,v in failing(db).items() if k not in base}
        assert not new,('datos válidos incumplen',seed,new)
        sel=db.execute('SELECT id_calificacion_seleccionada,criterio,version FROM trx_resultado_periodo WHERE id_estudiante=? AND id_asignatura=9901 AND id_periodo=? ORDER BY version DESC',(E[0],P[0])).fetchone()
        assert tuple(sel)==(NOTAS[(E[0],MAT,1,'RECUPERACION')],'MEJOR_NOTA',2),tuple(sel)
        for name,steps,exp in NEG:
            db.execute('SAVEPOINT caso')
            try:
                try:
                    for s in steps:apply(db,s)
                    got={k:v for k,v in failing(db).items() if k not in base}
                except (sqlite3.IntegrityError,AssertionError):got={'_ddl':('CHECK',1)}
                if exp[0]=='regla':
                    blocking={k for k,(sev,_) in got.items() if sev in ('BLOQUEO','CHECK')}
                    assert blocking=={exp[1]},(name,got)
                    # con validación por sentencia, la regla debe leer alguna tabla que el caso modifica
                    sqlr=next(s for r,_,_,s in RULES if r==exp[1]).upper()
                    tocadas={s[1].upper() for s in steps if s[0] in ('insert','guardar','update','delete')}
                    assert any(re.search(r'(^|[^A-Z0-9_$#])'+t+r'([^A-Z0-9_$#]|$)',sqlr) for t in tocadas),(name,'la regla no lee las tablas modificadas')
                elif exp[0]=='check':assert got and all(v[0] in ('CHECK','BLOQUEO') for v in got.values()) and any(k=='_ddl' or k.startswith('ck_') or '_CK_' in k or '_BC_' in k for k in got),(name,got)
            finally:db.execute('ROLLBACK TO caso');db.execute('RELEASE caso')
        for name,steps,rule in AVISOS:
            db.execute('SAVEPOINT caso')
            try:
                for s in steps:apply(db,s)
                got={k:v for k,v in failing(db).items() if k not in base}
                assert rule in got and all(v[0] in ('AVISO','PENDIENTE') for v in got.values()),(name,got)
            finally:db.execute('ROLLBACK TO caso');db.execute('RELEASE caso')
        db.close()

# ---------------------------------------------------------------- SQL Oracle
def lit(t,c,v):
    if v is None:return 'NULL'
    typ=FT[t][c]
    if typ=='date':return f"DATE '{v}'"
    if typ=='timestamp':return f"TIMESTAMP '{v}'"
    if typ in ('int','decimal','boolean'):return str(v)
    return "'"+str(v).replace("'","''")+"'"
def js(t,r):
    return json.dumps({c:(v if FT[t][c] in ('int','decimal','boolean') or v is None else str(v)) for c,v in r.items()},ensure_ascii=False)
def where(t,d):return ' AND '.join(f'{c}={lit(t,c,v)}' for c,v in d.items())
def sql(step):
    k=step[0]
    if k=='insert':t,r=step[1],step[2];return f"INSERT INTO {t} ({','.join(r)}) VALUES ({','.join(lit(t,c,v) for c,v in r.items())});"
    if k=='guardar':return f"pr_guardar_registro('{step[1]}',q'~{js(step[1],step[2])}~');"
    if k=='json':return f"pr_guardar_registro('{step[1]}',q'~{step[2]}~');"
    if k=='publicar':return f'pr_publicar_plan({step[1]});'
    if k=='nota':return f"pr_registrar_calificacion(q'~{js('trx_calificacion',step[1])}~',{step[2]},TIMESTAMP '{step[3]}');"
    if k=='beca':return f"pr_otorgar_beca(q'~{js('trx_beca',step[1])}~',{step[2]},DATE '{step[3]}');"
    if k=='suspender':return f"pr_suspender_beca({step[1]},DATE '{step[2]}','{step[3]}');"
    if k=='reanudar':return f"pr_reanudar_beca({step[1]},{step[2]},DATE '{step[3]}');"
    if k=='update':return f"UPDATE {step[1]} SET {', '.join(f'{c}={lit(step[1],c,v)}' for c,v in step[2].items())} WHERE {where(step[1],step[3])};"
    if k=='delete':return f"DELETE FROM {step[1]} WHERE {where(step[1],step[2])};"
def block(steps):return 'BEGIN '+' '.join(sql(s) for s in steps)+' END;'
def qq(s):return "q'#"+s+"#'"

def write():
    titles={'insert':None}
    out=["""-- ==============================================================
-- CARGA_Y_PRUEBA_VALIDACIONES.sql: CARGA REAL Y RECHAZOS
-- Descripción: Carga un colegio completo a través de las validaciones y comprueba que rechazan los casos inválidos.
--   Oracle 23ai (también 19c y 21c). Generado por Pruebas/scripts/generar_prueba_carga.py.
-- ==============================================================
-- Requiere: OLTP creado, Validacion/INSTALAR_VALIDACIONES.sql instalado y datos existentes que cumplan las reglas BLOQUEO.
-- Ejecutar COMO SCRIPT en un esquema de pruebas. Una sola vez: los identificadores 99xxxx deben estar libres.
-- Parte 1 carga y confirma (COMMIT) un colegio bilingüe con calendario agosto-junio y bachillerato de 4 períodos:
--   catálogos, institución, ciclo, períodos, plazos, planes publicados, personas (entrada JSON), docentes con cambio
--   de responsable, inscripciones, sesiones, asistencia, notas validadas con recuperación y una beca suspendida y reanudada.
-- Parte 2 intenta cambios inválidos: cada uno debe ser rechazado con el error esperado y se revierte.
-- Parte 3 hace cambios que solo generan avisos/pendientes: no deben bloquear y la regla debe detectarlos; se revierten.
-- El resultado se imprime como OK/FALLO; si hay fallos, el script termina con error -20899 sin deshacer la parte 1.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';
PROMPT 0/3 Comprobaciones previas...
DECLARE n NUMBER; BEGIN
 SELECT COUNT(*) INTO n FROM user_objects WHERE object_name IN ('PR_REGISTRAR_CALIFICACION','PR_VALIDAR_OPERACION','VAL_REGLA') AND status='VALID';
 IF n<>3 THEN RAISE_APPLICATION_ERROR(-20890,'Instalar Validacion/INSTALAR_VALIDACIONES.sql antes de este script.'); END IF;
 SELECT COUNT(*) INTO n FROM (SELECT id_ciclo FROM est_ciclo WHERE id_ciclo BETWEEN 9901 AND 9904 UNION ALL SELECT id_institucion FROM mae_institucion WHERE id_institucion=9901
   UNION ALL SELECT id_persona FROM mae_persona WHERE id_persona BETWEEN 990101 AND 990113);
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20890,'El escenario de prueba ya existe; este script se ejecuta una sola vez por esquema.'); END IF;
 pr_validar_operacion;
END;
/
PROMPT 1/3 Carga del escenario valido...
BEGIN"""]
    for s in STEPS:out.append(' '+sql(s))
    out+=["END;","/","COMMIT;",
     "DECLARE c NUMBER; s NUMBER; cr VARCHAR2(30); BEGIN",
     f" SELECT COUNT(*) INTO c FROM trx_calificacion WHERE id_calificacion BETWEEN 99011001 AND 99019999;",
     f" IF c<>{sum(1 for s in STEPS if s[0]=='nota')} THEN RAISE_APPLICATION_ERROR(-20891,'Cantidad de notas inesperada: '||c); END IF;",
     f" SELECT id_calificacion_seleccionada,criterio INTO s,cr FROM trx_resultado_periodo WHERE id_estudiante={E[0]} AND id_asignatura=9901 AND id_periodo={P[0]} AND version=2;",
     f" IF s<>{NOTAS[(E[0],MAT,1,'RECUPERACION')]} OR cr<>'MEJOR_NOTA' THEN RAISE_APPLICATION_ERROR(-20891,'La recuperacion no quedo seleccionada con MEJOR_NOTA.'); END IF;",
     " SELECT COUNT(*) INTO c FROM trx_beca_vigencia WHERE id_beca=99013001;",
     " IF c<>2 THEN RAISE_APPLICATION_ERROR(-20891,'La beca debe tener dos intervalos (suspension y reanudacion).'); END IF;",
     " pr_validar_operacion;",
     " DBMS_OUTPUT.PUT_LINE('OK    Escenario cargado: '||c||' intervalos de beca, recuperacion seleccionada por MEJOR_NOTA, sin infracciones BLOQUEO.');",
     "END;","/",
     "PROMPT 2/3 y 3/3 Casos invalidos y avisos...",
     "WHENEVER SQLERROR EXIT SQL.SQLCODE",
     "DECLARE v_ok PLS_INTEGER:=0; v_fallos PLS_INTEGER:=0;",
     " PROCEDURE esperar(p_nombre VARCHAR2,p_bloque VARCHAR2,p_c1 NUMBER,p_c2 NUMBER DEFAULT NULL,p_texto VARCHAR2 DEFAULT NULL) IS",
     "  v_code NUMBER:=0; v_msg VARCHAR2(4000);",
     " BEGIN",
     "  SAVEPOINT sv_caso;",
     "  BEGIN EXECUTE IMMEDIATE p_bloque; EXCEPTION WHEN OTHERS THEN v_code:=SQLCODE; v_msg:=SQLERRM; END;",
     "  ROLLBACK TO sv_caso;",
     "  IF v_code<>0 AND v_code IN (p_c1,NVL(p_c2,p_c1)) AND (p_texto IS NULL OR INSTR(v_msg,p_texto)>0) THEN",
     "   v_ok:=v_ok+1; DBMS_OUTPUT.PUT_LINE('OK    Rechazado: '||p_nombre||' ('||v_code||')');",
     "  ELSE v_fallos:=v_fallos+1;",
     "   DBMS_OUTPUT.PUT_LINE('FALLO '||p_nombre||': '||CASE WHEN v_code=0 THEN 'no fue rechazado' ELSE SUBSTR(v_msg,1,300) END); END IF;",
     " END;",
     " PROCEDURE avisar(p_nombre VARCHAR2,p_bloque VARCHAR2,p_regla VARCHAR2) IS",
     "  q CLOB; n0 NUMBER; n1 NUMBER; v_msg VARCHAR2(4000);",
     " BEGIN",
     "  SELECT consulta INTO q FROM val_regla WHERE id_regla=p_regla;",
     "  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||')' INTO n0;",
     "  SAVEPOINT sv_aviso;",
     "  BEGIN EXECUTE IMMEDIATE p_bloque; EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||')' INTO n1;",
     "  EXCEPTION WHEN OTHERS THEN v_msg:=SQLERRM; END;",
     "  ROLLBACK TO sv_aviso;",
     "  IF v_msg IS NULL AND n1>n0 THEN v_ok:=v_ok+1; DBMS_OUTPUT.PUT_LINE('OK    Aviso sin bloqueo: '||p_nombre||' ('||p_regla||')');",
     "  ELSE v_fallos:=v_fallos+1; DBMS_OUTPUT.PUT_LINE('FALLO '||p_nombre||': '||NVL(SUBSTR(v_msg,1,300),'la regla no lo detecto')); END IF;",
     " END;",
     "BEGIN"]
    for name,steps,exp in NEG:
        n="'"+name.replace("'","''")+"'"
        if exp[0]=='regla':out.append(f" esperar({n},{qq(block(steps))},-20802,NULL,'{exp[1]}');")
        elif exp[0]=='check':out.append(f" esperar({n},{qq(block(steps))},-2290,-20802);")
        else:out.append(f" esperar({n},{qq(block(steps))},{exp[1]});")
    for name,steps,rule in AVISOS:
        n="'"+name.replace("'","''")+"'"
        out.append(f" avisar({n},{qq(block(steps))},'{rule}');")
    out+=[" DBMS_OUTPUT.PUT_LINE('Resultado: '||v_ok||' correctos, '||v_fallos||' fallidos.');",
     " IF v_fallos>0 THEN RAISE_APPLICATION_ERROR(-20899,v_fallos||' casos no se comportaron como se esperaba.'); END IF;",
     "END;","/",
     "PROMPT Prueba terminada. El escenario valido queda confirmado; los casos invalidos y avisos se revirtieron."]
    text='\n'.join(out)+'\n'
    assert '#' not in ''.join(block(s) for _,s,_ in NEG+AVISOS)
    ruta('CARGA_Y_PRUEBA_VALIDACIONES.sql').write_text(text)
    return text

if __name__=='__main__':
    verify()
    write()
    print(f"CARGA_Y_PRUEBA_VALIDACIONES.sql: {len(STEPS)} pasos de carga, {len(NEG)} casos inválidos y {len(AVISOS)} avisos verificados en la referencia SQLite (vacía y con la semilla).")
