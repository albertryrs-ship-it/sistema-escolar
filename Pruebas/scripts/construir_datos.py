"""Datos sintéticos reproducibles; no contiene expedientes reales."""
import calendar,json
from collections import defaultdict
from datetime import date,datetime,timedelta
from pathlib import Path

from rutas import ROOT,ruta
SCHEMA=json.loads((ruta('modelo_logico.json')).read_text())
CUT=datetime(2026,9,15,23,59,59)
rows={n:[] for n in SCHEMA}

def add(table,**values):
    fields=SCHEMA[table]['fields'];unknown=set(values)-{f['name'] for f in fields}
    assert not unknown,(table,unknown)
    row={f['name']:values.get(f['name']) for f in fields}
    assert all(row[f['name']] is not None for f in fields if not f['nullable']),(table,row)
    rows[table].append(row);return row
def d(year,month,day):return date(year,month,day).isoformat()
def ts(day,hour='10:00:00'):return day+' '+hour
def stamp(value):return datetime.fromisoformat(value)

def build():
    catalogs={
      'cat_tipo_documento': [('DUI','Documento de prueba')],
      'cat_tipo_institucion':[('PUBLICA','Pública')],
      'cat_departamento':[('SV-CH','Departamento Norte'),('SV-PA','Departamento Sur')],  # ISO de Chalatenango y La Paz, para el mapa
      'cat_modalidad':[('PRESENCIAL','Presencial'),('SEMIPRESENCIAL','Semipresencial')],
      'cat_jornada':[('MATUTINA','Matutina'),('VESPERTINA','Vespertina'),('NOCTURNA','Nocturna')],
      'cat_area_conocimiento':[('MAT','Matemática'),('LEN','Lenguaje'),('DES','Desarrollo infantil')],
      'cat_tipo_beca':[('SOCIOECONOMICA','Apoyo económico'),('MERITO','Mérito académico')]
    }
    for table,items in catalogs.items():
      pk=SCHEMA[table]['fields'][0]['name']
      for i,(code,label) in enumerate(items,1):
        add(table,**{pk:i,'codigo':code,('nombre' if table=='cat_departamento' else 'descripcion'):label,'activo':1})
    for i,name in [(1,'Urbana'),(2,'Rural')]:add('cat_zona',id_zona=i,nombre=name,activo=1)
    for id,code,name,order in [(1,'BAS','Básica',2),(2,'BAC','Bachillerato',3),(3,'PAR','Parvularia',1)]:
      add('cat_nivel',id_nivel=id,codigo=code,nombre=name,orden=order)
    for id,level,code,name,order,terminal in [(1,1,'8','Octavo',8,0),(2,1,'9','Noveno',9,0),(3,2,'3','Tercero de bachillerato',3,1),(4,3,'6','Parvularia 6',1,0),(5,2,'1','Primero de bachillerato',1,0)]:
      add('cat_grado',id_grado=id,id_nivel=level,codigo=code,nombre=name,orden=order,es_ultimo_grado=terminal)
    for i,name in [(1,'Centro Educativo Norte'),(2,'Centro Educativo Sur')]:
      add('mae_institucion',id_institucion=i,codigo_institucion=f'CE-{i:03}',nombre=name,id_tipo_institucion=1,id_departamento=i,id_zona=i,permite_becas=1,direccion=f'Dirección sintética {i}',telefono=None,email=f'centro{i}@example.invalid',fecha_creacion='2000-01-01',activo=1)
    names=[('Ana','López','F'),('Carlos','Martínez','M'),('Luis','Hernández','M'),('Beatriz','Ramírez','F'),('Diego','Gómez','M'),('Elena','Pérez','F'),('Fabio','Santos','M'),('Gabriela','Rivas','F')]
    for offset,(name,last,sex) in enumerate(names,1):
      add('mae_persona',id_persona=100+offset,id_tipo_documento=None,numero_documento=None,primer_nombre=name,segundo_nombre=None,primer_apellido=last,segundo_apellido=None,fecha_nacimiento=('2020-03-15' if offset==8 else '2008-03-15'),sexo=sex,email=None,telefono=None,direccion=None,fecha_registro='2024-01-02 08:00:00')
      add('mae_estudiante',id_estudiante=1000+offset,id_persona=100+offset,nie=f'{1000+offset:08}',fecha_registro='2024-01-02 08:05:00',activo=1)
    for i,name,sex in [(1,'María','F'),(2,'Jorge','M')]:
      add('mae_persona',id_persona=200+i,id_tipo_documento=1,numero_documento=f'DOC-SINT-{i:03}',primer_nombre=name,segundo_nombre=None,primer_apellido='Docente',segundo_apellido=None,fecha_nacimiento='1980-05-12',sexo=sex,email=None,telefono=None,direccion=None,fecha_registro='2024-01-02 08:00:00')
      add('mae_docente',id_docente=300+i,id_persona=200+i,especialidad='Educación escolar',fecha_registro='2024-01-02 08:10:00',activo=1)
    for id,code,name,area in [(501,'MAT','Matemática',1),(502,'LEN','Lenguaje',2),(503,'DES','Desarrollo integral',3)]:
      add('mae_asignatura',id_asignatura=id,codigo=code,nombre=name,id_area=area,descripcion=None,activo=1)
    for year in (2024,2025,2026):
      add('est_ciclo',id_ciclo=year,codigo=f'C-{year}',nombre=f'Año {year}',anio=year,fecha_inicio=d(year,1,15),fecha_fin=d(year,11,30),estado='ABIERTO' if year==2026 else 'CERRADO')
      for p,(sm,sd,em,ed) in enumerate([(1,15,4,30),(5,1,8,31),(9,1,11,30)],1):
        add('est_periodo_academico',id_periodo=year*10+p,id_ciclo=year,numero=p,nombre=f'Trimestre {p}',fecha_inicio=d(year,sm,sd),fecha_fin=d(year,em,ed))
      for inst in (1,2):
        add('est_institucion_ciclo',id_institucion=inst,id_ciclo=year,id_tipo_institucion=1,id_departamento=inst,id_zona=inst,permite_becas=1,fecha_corte_matricula=d(year,2,15),estado='ABIERTO' if year==2026 else 'CERRADO')
    courses=[(100,1,2024,1,1,1,'A'),(200,1,2025,2,1,1,'A'),(201,2,2025,2,3,2,'A'),(202,2,2025,3,2,1,'A'),(300,1,2026,5,1,1,'A'),(301,2,2026,5,3,2,'A'),(302,2,2026,4,1,1,'A'),(303,1,2026,2,1,1,'B')]
    for id,inst,year,grade,shift,mode,section in courses:
      add('est_curso',id_curso=id,id_institucion=inst,id_ciclo=year,id_grado=grade,id_jornada=shift,id_modalidad=mode,codigo=f'CUR-{id}',nombre=f'Grupo {id}',seccion=section,capacidad_maxima=35,estado='ACTIVO' if year==2026 else 'CERRADO')
      for a,subject in enumerate(([503] if id==302 else [501,502]),1):
        offer=id*10+a
        add('est_curso_asignatura',id_curso_asignatura=offer,id_curso=id,id_asignatura=subject,horas_semanales=5 if subject==501 else 4,creditos=None,tipo_resultado='CUALITATIVA' if subject==503 else 'NUMERICA',regla_recuperacion='MEJOR_NOTA',estado='ACTIVA')
        for p,weight in enumerate(([3,3,4] if inst==2 else [30,30,40]),1):
          add('est_ponderacion_periodo',id_ponderacion_periodo=offer*10+p,id_curso_asignatura=offer,id_periodo=year*10+p,peso=weight,estado='PUBLICADO')
        add('trx_asignacion_docente',id_asignacion=offer,id_docente=300+inst,id_curso_asignatura=offer,fecha_asignacion=ts(d(year,1,10)),fecha_inicio=d(year,1,15),fecha_fin=None if year==2026 else d(year,11,30),estado='VIGENTE' if year==2026 else 'FINALIZADA')
    # Plazos por contexto y grado: no duplicar por sección.
    contexts=sorted({(inst,year,grade) for _,inst,year,grade,_,_,_ in courses})
    window_id=3000
    for inst,year,grade in contexts:
      for p,(month,limit_month,limit_year) in enumerate([(4,5,year),(8,9,year),(11,12,year)],1):
        window_id+=1;closed=year<2026 or p<3
        last_day=10 if year==2026 and p==2 else 5
        add('est_plazo_registro_notas',id_plazo_registro_notas=window_id,id_institucion=inst,id_ciclo=year,id_grado=grade,id_periodo=year*10+p,tipo_intento='ORDINARIA',fecha_inicio_recuperacion=None,fecha_fin_recuperacion=None,fecha_apertura_registro=ts(d(year,month,25),'08:00:00'),fecha_limite_registro=ts(d(limit_year,limit_month,last_day),'23:59:59'),fecha_cierre_registro=ts(d(limit_year,limit_month,last_day+1),'00:00:00') if closed else None,estado='CERRADA' if closed else 'ABIERTA')
      if (inst,year,grade)==(1,2025,2):
        window_id+=1
        add('est_plazo_registro_notas',id_plazo_registro_notas=window_id,id_institucion=inst,id_ciclo=year,id_grado=grade,id_periodo=20253,tipo_intento='RECUPERACION',fecha_inicio_recuperacion='2025-12-07',fecha_fin_recuperacion='2025-12-15',fecha_apertura_registro='2025-12-07 08:00:00',fecha_limite_registro='2025-12-20 23:59:59',fecha_cierre_registro='2025-12-21 00:00:00',estado='CERRADA')
    for offset,student in enumerate(range(1001,1006),1):
      add('trx_inscripcion',id_inscripcion=400+offset,id_estudiante=student,id_curso=100,fecha_inscripcion='2024-01-12 09:00:00',fecha_inicio='2024-01-15',fecha_fin='2024-11-30',estado='FINALIZADA',motivo_fin_inscripcion='Fin del año académico',resultado_cierre='PROMOVIDO')
    for offset,student in enumerate([1001,1002,1003,1005],1):
      add('trx_inscripcion',id_inscripcion=500+offset,id_estudiante=student,id_curso=200,fecha_inscripcion='2025-01-12 09:00:00',fecha_inicio='2025-01-15',fecha_fin='2025-11-30',estado='FINALIZADA',motivo_fin_inscripcion='Fin del año académico',resultado_cierre='REPITE' if student in (1002,1003) else 'PROMOVIDO')
    add('trx_inscripcion',id_inscripcion=505,id_estudiante=1004,id_curso=200,fecha_inscripcion='2025-01-12 09:00:00',fecha_inicio='2025-01-15',fecha_fin='2025-04-30',estado='TRASLADADA',motivo_fin_inscripcion='Traslado a Centro Sur',resultado_cierre=None)
    add('trx_inscripcion',id_inscripcion=506,id_estudiante=1004,id_curso=201,fecha_inscripcion='2025-04-29 09:00:00',fecha_inicio='2025-05-01',fecha_fin='2025-11-30',estado='FINALIZADA',motivo_fin_inscripcion='Fin del año académico',resultado_cierre='PROMOVIDO')
    add('trx_inscripcion',id_inscripcion=507,id_estudiante=1006,id_curso=202,fecha_inscripcion='2025-01-12 09:00:00',fecha_inicio='2025-01-15',fecha_fin='2025-11-30',estado='FINALIZADA',motivo_fin_inscripcion='Graduación',resultado_cierre='GRADUADO')
    for id,student,course in [(601,1001,300),(602,1002,303),(604,1004,301),(605,1005,300),(607,1007,300),(608,1008,302)]:
      add('trx_inscripcion',id_inscripcion=id,id_estudiante=student,id_curso=course,fecha_inscripcion='2026-01-12 09:00:00',fecha_inicio='2026-01-15',fecha_fin=None,estado='VIGENTE',motivo_fin_inscripcion=None,resultado_cierre=None)
    course_by={r['id_curso']:r for r in rows['est_curso']}
    offers_by=defaultdict(list)
    for r in rows['est_curso_asignatura']:offers_by[r['id_curso']].append(r)
    periods_by={r['id_periodo']:r for r in rows['est_periodo_academico']}
    def grade(student,year,subject,p):
      a=0 if subject==501 else 1
      if year==2024:return 70 if subject==501 else 75
      if year==2025:
        plans={1001:([80,60,90],[70,80,90]),1002:([50,55,55],[60,60,60]),1003:([45,50,55],[50,55,60]),1004:([75,65,85],[75,70,80]),1005:([70,70,70],[75,75,75]),1006:([85,85,85],[90,90,90])}
        return plans[student][a][p-1]
      plans={1001:([80,60,None],[75,85,None]),1002:([55,60,None],[60,65,None]),1004:([60,70,None],[65,75,None]),1005:([0,80,None],[70,70,None]),1007:([55,55,None],[50,50,None])}
      return plans[student][a][p-1]
    result_id=8000;cal_id=10000
    for ins in rows['trx_inscripcion']:
      c=course_by[ins['id_curso']];year=c['id_ciclo']
      for offer in offers_by[c['id_curso']]:
        for p in (1,2,3):
          per=periods_by[year*10+p]
          if ins['fecha_inicio']>per['fecha_fin'] or (ins['fecha_fin'] and ins['fecha_fin']<per['fecha_inicio']):continue
          if year==2026 and p==3:continue
          numeric=offer['tipo_resultado']=='NUMERICA'
          note=grade(ins['id_estudiante'],year,offer['id_asignatura'],p) if numeric else None
          if numeric and note is None:continue
          month=[4,8,11][p-1];capture_month=[5,9,12][p-1]
          cal_id+=1
          values=dict(id_calificacion=cal_id,id_inscripcion=ins['id_inscripcion'],id_ponderacion_periodo=offer['id_curso_asignatura']*10+p,tipo_intento='ORDINARIA',numero_intento=1,version=1,id_calificacion_ordinaria=None,id_calificacion_sustituida=None,id_asignacion_docente=offer['id_curso_asignatura'],id_docente_registra=300+c['id_institucion'],nota=note,resultado_cualitativo=None if numeric else 'LOGRO_ESPERADO',fecha_evaluacion=d(year,month,29),fecha_registro=ts(d(year,capture_month,2)),fecha_validacion=ts(d(year,capture_month,3)),fecha_anulacion=None,motivo_anulacion=None)
          # La ordinaria base de Ana se corrige antes de cerrar el plazo.
          correction=ins['id_estudiante']==1001 and year==2025 and offer['id_asignatura']==501 and p==1
          if correction:values['nota']=78
          ordinary=add('trx_calificacion',**values)
          result_id+=1
          result=add('trx_resultado_periodo',id_resultado=result_id,id_estudiante=ins['id_estudiante'],id_asignatura=offer['id_asignatura'],id_periodo=year*10+p,id_calificacion_seleccionada=ordinary['id_calificacion'],version=1,criterio='ORDINARIA',fecha_seleccion=ordinary['fecha_validacion'],fecha_cierre=ts(d(year,capture_month,6)))
          if correction:
            result['fecha_cierre']=None
            cal_id+=1;new=add('trx_calificacion',**{**values,'id_calificacion':cal_id,'nota':80,'version':2,'id_calificacion_sustituida':ordinary['id_calificacion'],'fecha_registro':'2025-05-04 10:00:00','fecha_validacion':'2025-05-04 11:00:00'})
            result_id+=1;add('trx_resultado_periodo',**{**result,'id_resultado':result_id,'id_calificacion_seleccionada':new['id_calificacion'],'version':2,'criterio':'CORRECCION','fecha_seleccion':new['fecha_validacion'],'fecha_cierre':'2025-05-06 00:00:00'})
          if ins['id_estudiante']==1002 and year==2025 and offer['id_asignatura']==501 and p==3:
            recovery=None
            for attempt,value,day in [(2,70,10),(3,65,13)]:
              cal_id+=1
              record=add('trx_calificacion',**{**values,'id_calificacion':cal_id,'tipo_intento':'RECUPERACION','numero_intento':attempt,'id_calificacion_ordinaria':ordinary['id_calificacion'],'nota':value,'fecha_evaluacion':d(2025,12,day),'fecha_registro':ts(d(2025,12,day+1)),'fecha_validacion':ts(d(2025,12,day+2))})
              if attempt==2:recovery=record
            result_id+=1;add('trx_resultado_periodo',**{**result,'id_resultado':result_id,'id_calificacion_seleccionada':recovery['id_calificacion'],'version':2,'criterio':'MEJOR_NOTA','fecha_seleccion':recovery['fecha_validacion'],'fecha_cierre':'2025-12-21 10:00:00'})
          if ins['id_estudiante']==1007 and year==2026 and offer['id_asignatura']==502 and p==2:
            # Al 5/sep la última versión validada está anulada: no revivir v1.
            result['fecha_cierre']=None
            cal_id+=1;bad=add('trx_calificacion',**{**values,'id_calificacion':cal_id,'version':2,'id_calificacion_sustituida':ordinary['id_calificacion'],'nota':95,'fecha_registro':'2026-09-03 12:00:00','fecha_validacion':'2026-09-04 10:00:00','fecha_anulacion':'2026-09-05 10:00:00','motivo_anulacion':'Error de captura confirmado'})
            result_id+=1;add('trx_resultado_periodo',**{**result,'id_resultado':result_id,'id_calificacion_seleccionada':bad['id_calificacion'],'version':2,'criterio':'CORRECCION','fecha_seleccion':bad['fecha_validacion'],'fecha_cierre':None})
            cal_id+=1;fixed=add('trx_calificacion',**{**values,'id_calificacion':cal_id,'version':3,'id_calificacion_sustituida':bad['id_calificacion'],'fecha_registro':'2026-09-10 10:00:00','fecha_validacion':'2026-09-17 10:00:00'})
            result_id+=1;add('trx_resultado_periodo',**{**result,'id_resultado':result_id,'id_calificacion_seleccionada':fixed['id_calificacion'],'version':3,'criterio':'CORRECCION','fecha_seleccion':fixed['fecha_validacion'],'fecha_cierre':'2026-09-17 11:00:00'})
    # Dos sesiones semanales por materia: horas 2.5+2.5 o 2+2.
    session_id=20000
    for offer in rows['est_curso_asignatura']:
      c=course_by[offer['id_curso']];year=c['id_ciclo']
      for p in (1,2,3):
        per=periods_by[year*10+p];day=date.fromisoformat(per['fecha_inicio']);end=date.fromisoformat(per['fecha_fin'])
        while day<=end:
          weekdays=(0,2) if (c['id_curso']==303 or (c['id_jornada']==3 and offer['id_asignatura']==502)) else (1,3)
          if day.weekday() in weekdays:
            session_id+=1
            hour=22 if c['id_jornada']==3 else (14 if c['id_jornada']==2 else 8)
            if c['id_jornada']!=3 and offer['id_asignatura']==502:hour+=2.75
            start=datetime.combine(day,datetime.min.time())+timedelta(hours=hour)
            duration=timedelta(hours=float(offer['horas_semanales'])/2)
            finish=start+duration
            add('trx_sesion_clase',id_sesion=session_id,id_ponderacion_periodo=offer['id_curso_asignatura']*10+p,id_asignacion=offer['id_curso_asignatura'],fecha_academica=day.isoformat(),inicio=start.isoformat(' '),fin=finish.isoformat(' '),estado='IMPARTIDA' if finish<=CUT else 'PROGRAMADA',observaciones=None)
          day+=timedelta(days=1)
    plan_by={r['id_ponderacion_periodo']:r for r in rows['est_ponderacion_periodo']}
    offer_by={r['id_curso_asignatura']:r for r in rows['est_curso_asignatura']}
    ins_by_course=defaultdict(list)
    for r in rows['trx_inscripcion']:ins_by_course[r['id_curso']].append(r)
    counters=defaultdict(int);attendance_id=30000;missing_fabio=False
    for session in rows['trx_sesion_clase']:
      if session['estado']!='IMPARTIDA':continue
      plan=plan_by[session['id_ponderacion_periodo']];offer=offer_by[plan['id_curso_asignatura']];year=plan['id_periodo']//10;p=plan['id_periodo']%10
      for ins in ins_by_course[offer['id_curso']]:
        if not (ins['fecha_inicio']<=session['fecha_academica']<=(ins['fecha_fin'] or f'{year}-11-30')):continue
        student=ins['id_estudiante'];key=(student,year,p);idx=counters[key];counters[key]+=1
        if student==1007 and year==2026 and p==2 and not missing_fabio:
          missing_fabio=True;continue
        state='PRESENTE'
        if student==1003:state='AUSENTE' if idx%4<3 else 'PRESENTE'
        elif student==1002 and year==2025 and p==2:state='AUSENTE' if idx%2==0 else 'PRESENTE'
        elif student==1005 and year==2026 and p==1:state='AUSENTE' if idx%2==0 else 'PRESENTE'
        elif student==1007 and year==2026 and p==2:state='AUSENTE' if idx%2==0 else 'PRESENTE'
        elif idx%10==0:state='TARDE'
        arrival=None if state=='AUSENTE' else (stamp(session['inicio'])+timedelta(minutes=10 if state=='TARDE' else 0)).isoformat(' ')
        attendance_id+=1
        add('trx_asistencia',id_asistencia=attendance_id,id_inscripcion=ins['id_inscripcion'],id_sesion=session['id_sesion'],estado=state,hora_llegada=arrival,fecha_registro=(stamp(session['fin'])+timedelta(minutes=5)).isoformat(' '),observaciones=None)
    for id,ins,percentage in [(7001,401,50),(7002,501,50),(7003,601,50),(7004,505,25),(7005,506,25),(7006,602,30)]:
      source=next(r for r in rows['trx_inscripcion'] if r['id_inscripcion']==ins)
      add('trx_beca',id_beca=id,id_inscripcion=ins,id_tipo_beca=1,porcentaje=percentage,fecha_otorgamiento=source['fecha_inicio'],fecha_registro=ts(source['fecha_inicio']),observaciones=None)
      if id==7006:
        for offset,start,end,reason in [(0,'2026-01-15','2026-06-30','SUSPENSION'),(1,'2026-08-01',None,None)]:
          add('trx_beca_vigencia',id_vigencia=id*10+offset,id_beca=id,fecha_inicio=start,fecha_fin=end,motivo_fin=reason,fecha_registro=ts(start))
      else:
        end=source['fecha_fin'];reason='TRASLADO' if source['estado']=='TRASLADADA' else ('FIN_VIGENCIA' if end else None)
        add('trx_beca_vigencia',id_vigencia=id*10,id_beca=id,fecha_inicio=source['fecha_inicio'],fecha_fin=end,motivo_fin=reason,fecha_registro=ts(source['fecha_inicio']))
    # Las declaraciones describen una cobertura conocida; no inventan casos faltantes.
    def selected_at(cut):
      attempts={};selections={}
      for n in rows['trx_calificacion']:
        if n['fecha_validacion'] is None or n['fecha_validacion']>cut:continue
        key=(n['id_inscripcion'],n['id_ponderacion_periodo'],n['numero_intento'])
        if key not in attempts or attempts[key]['version']<n['version']:attempts[key]=n
      valid={n['id_calificacion']:n for n in attempts.values() if n['fecha_anulacion'] is None or n['fecha_anulacion']>cut}
      for r in rows['trx_resultado_periodo']:
        if r['fecha_seleccion']>cut:continue
        key=(r['id_estudiante'],r['id_asignatura'],r['id_periodo'])
        if key not in selections or selections[key]['version']<r['version']:selections[key]=r
      return [valid[r['id_calificacion_seleccionada']] for r in selections.values() if r['id_calificacion_seleccionada'] in valid]
    control_id=9000
    for c in rows['est_curso']:
      year=c['id_ciclo']
      for p in (1,2,3):
        per=periods_by[year*10+p]
        if year==2026 and p==3:continue
        cutoff=per['fecha_fin'];receipt=d(year,[5,9,12][p-1],7)
        enroll=[r for r in ins_by_course[c['id_curso']] if r['fecha_inicio']<=cutoff and (r['fecha_fin'] or f'{year}-11-30')>=per['fecha_inicio']]
        for domain in ['MATRICULA','NOTAS','ASISTENCIA','BECAS']:
          control_id+=1;state='COMPLETA'
          if domain=='MATRICULA':count=len([r for r in enroll if (r['fecha_fin'] or cutoff)>=cutoff])
          elif domain=='NOTAS':
            count=len({(r['id_inscripcion'],r['id_ponderacion_periodo']) for r in selected_at(ts(receipt,'10:00:00')) if r['id_inscripcion'] in {e['id_inscripcion'] for e in enroll} and plan_by[r['id_ponderacion_periodo']]['id_periodo']==year*10+p})
            expected=len(enroll)*len(offers_by[c['id_curso']])
            if count<expected:state='PARCIAL'
          elif domain=='ASISTENCIA':
            session_ids={r['id_sesion'] for r in rows['trx_sesion_clase'] if plan_by[r['id_ponderacion_periodo']]['id_periodo']==year*10+p and offer_by[plan_by[r['id_ponderacion_periodo']]['id_curso_asignatura']]['id_curso']==c['id_curso'] and r['estado']=='IMPARTIDA'}
            count=sum(r['id_sesion'] in session_ids for r in rows['trx_asistencia'])
            if c['id_curso']==300 and year==2026 and p==2:state='PARCIAL'
          else:
            ids={e['id_inscripcion'] for e in enroll};count=sum(r['id_inscripcion'] in ids for r in rows['trx_beca'])
            if c['id_curso']==301 and year==2026:state='PARCIAL'
          add('trx_control_carga',id_control=control_id,id_curso=c['id_curso'],id_periodo=year*10+p,dominio=domain,fecha_corte=cutoff,estado=state,registros_declarados=count,fecha_recepcion=ts(receipt),id_ejecucion=9001)
      if year==2026:
        # Corte de matrícula de retención: no depender de declaraciones futuras.
        control_id+=1
        add('trx_control_carga',id_control=control_id,id_curso=c['id_curso'],id_periodo=20261,dominio='MATRICULA',fecha_corte='2026-02-15',estado='COMPLETA',registros_declarados=len(ins_by_course[c['id_curso']]),fecha_recepcion='2026-02-16 10:00:00',id_ejecucion=9001)
        for domain in ['MATRICULA','BECAS']:
          control_id+=1
          count=len(ins_by_course[c['id_curso']]) if domain=='MATRICULA' else sum(r['id_inscripcion'] in {i['id_inscripcion'] for i in ins_by_course[c['id_curso']]} for r in rows['trx_beca'])
          add('trx_control_carga',id_control=control_id,id_curso=c['id_curso'],id_periodo=20263,dominio=domain,fecha_corte='2026-09-15',estado='PARCIAL' if domain=='BECAS' and c['id_curso']==301 else 'COMPLETA',registros_declarados=count,fecha_recepcion='2026-09-15 23:00:00',id_ejecucion=9001)
    n=len(rows['trx_control_carga'])
    add('auditoria_etl_evaluaciones',id_ejecucion=9001,fuente='DECLARACIONES_SINTETICAS',inicio='2026-09-15 23:20:00',fin='2026-09-15 23:25:00',estado='COMPLETADA',total_leidos=n,insertados=n,actualizados=0,rechazados=0)
    return rows

if __name__=='__main__':
    data=build()
    (ruta('datos_sinteticos.json')).write_text(json.dumps({'fecha_corte':CUT.isoformat(' '),'tablas':data},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({n:len(v) for n,v in data.items()},ensure_ascii=False))
