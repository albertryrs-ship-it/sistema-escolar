"""Carga masiva sintética: 42 colegios (3 por departamento), ~150 alumnos cada uno, de 1.º de básica a 3.º de
bachillerato, años 2024 y 2025. Asistencia completa por clase solo en 8 colegios. Escribe CSV y archivos de
control de SQL*Loader en Script_Maestro/carga_masiva/.

Uso:
  python generar_carga_masiva.py            genera todo (varios cientos de MB)
  python generar_carga_masiva.py --verificar   genera un departamento con pocas semanas de clases y lo
                                               pasa por todas las reglas de las validaciones en SQLite
Los nombres, documentos y NIE son ficticios. Los departamentos son los 14 de El Salvador."""
import argparse,csv,json,random,re,sqlite3,sys,time
from collections import defaultdict,Counter
from datetime import date,datetime,timedelta
from pathlib import Path
from rutas import ROOT,ruta,texto_validaciones
from contrato_staging import SCHEMA

OUT=ROOT/'Script_Maestro/carga_masiva'
FIELDS={t:[f['name'] for f in d['fields']] for t,d in SCHEMA.items()}
TYPES={t:{f['name']:f['type'] for f in d['fields']} for t,d in SCHEMA.items()}
D=lambda s:date.fromisoformat(s)
iso=lambda d:d.isoformat()
ts=lambda d,h=8,m=0:f'{iso(d)} {h:02}:{m:02}:00'

DEPARTAMENTOS=['Ahuachapán','Santa Ana','Sonsonate','Chalatenango','La Libertad','San Salvador','Cuscatlán','La Paz','Cabañas','San Vicente','Usulután','San Miguel','Morazán','La Unión']
# Código ISO 3166-2:SV de cada departamento, en el mismo orden; lo usa el mapa del data mart.
ISO=['SV-AH','SV-SA','SV-SO','SV-CH','SV-LI','SV-SS','SV-CU','SV-PA','SV-CA','SV-SV','SV-US','SV-SM','SV-MO','SV-UN']
ANIOS=[2024,2025]
GRADOS=[(g,'BAS' if g<=9 else 'BAC',(f'{g}.º de básica' if g<=9 else f'{g-9}.º de bachillerato')) for g in range(1,13)]
# (código, nombre, área, horas por nivel: 1-6, 7-9, bachillerato); 30 horas semanales por curso
ASIGNATURAS=[('MAT','Matemática','MAT',5,5,5),('LEN','Lenguaje y Literatura','LEN',6,5,4),('CIE','Ciencia y Tecnología','CIE',4,5,5),
 ('SOC','Estudios Sociales','SOC',4,4,3),('ING','Inglés','IDI',3,4,4),('EDF','Educación Física','EDF',3,3,2),
 ('ART','Educación Artística','ART',2,2,0),('MOR','Moral, Urbanidad y Cívica','CIU',3,2,0),('INF','Informática','TEC',0,0,4),('ORV','Orientación para la Vida','CIU',0,0,3)]
AREAS=[('MAT','Matemática'),('LEN','Lenguaje'),('CIE','Ciencias'),('SOC','Ciencias Sociales'),('IDI','Idiomas'),('EDF','Educación Física'),('ART','Artes'),('CIU','Formación Ciudadana'),('TEC','Tecnología')]
NOMBRES_F=['María','Ana','Sofía','Valeria','Camila','Daniela','Gabriela','Andrea','Fernanda','Isabel','Lucía','Paola','Rebeca','Diana','Karla']
NOMBRES_M=['José','Carlos','Luis','Juan','Diego','Daniel','Kevin','Fernando','Mario','Ricardo','Andrés','Javier','Óscar','Roberto','Miguel']
APELLIDOS=['Hernández','López','Martínez','García','Rodríguez','Pérez','Flores','Ramírez','Rivera','Cruz','Mejía','Guzmán','Ayala','Romero','Alvarado','Castillo','Reyes','Orellana','Portillo','Menjívar']
VACACIONES={2024:[(D('2024-03-25'),D('2024-03-29')),(D('2024-08-01'),D('2024-08-06'))],2025:[(D('2025-04-14'),D('2025-04-18')),(D('2025-08-01'),D('2025-08-06'))]}
HORAS=[(7,0),(7,50),(8,40),(9,50),(10,40),(11,30)]

def periodos(anio,cuatro):
    y=str(anio)
    if cuatro:return [(D(y+'-01-15'),D(y+'-03-31')),(D(y+'-04-01'),D(y+'-06-14')),(D(y+'-06-15'),D(y+'-08-31')),(D(y+'-09-01'),D(y+'-11-28'))]
    return [(D(y+'-01-15'),D(y+'-04-30')),(D(y+'-05-01'),D(y+'-08-31')),(D(y+'-09-01'),D(y+'-11-28'))]

class Datos:
    def __init__(s):s.rows=defaultdict(list)
    def add(s,t,**r):
        assert set(r)==set(FIELDS[t]),(t,set(r)^set(FIELDS[t]))
        s.rows[t].append(r);return r

def colegios():
    """Perfil fijo de los 42 colegios."""
    out=[]
    for d in range(1,15):
        for k in range(1,4):
            cid=d*100+k;rnd=random.Random(cid)
            privado=(k==3) or (d in (5,6,12) and k==2)
            out.append(dict(id=cid,dep=d,k=k,privado=privado,rural=(k==1 and d not in (5,6,12)),
              vespertina=(k==2 and d%3==0),bac4=(cid in (602,503,1202,203,903,1103)),
              ultima=(cid in (301,702,1001,1302)),asistencia=(cid in (601,602,501,1201,301,803,1102,1401)),
              parcial=(cid==1201),nombre=('Colegio' if privado else 'Centro Escolar')+f' Sintético {DEPARTAMENTOS[d-1]} {k}'))
    return out

def generar(deps=None,semanas=None,seed=20241):
    """Devuelve Datos. deps limita los departamentos; semanas limita las semanas con clases por período (verificación)."""
    X=Datos();R=random.Random(seed)
    # ---------------- catálogos
    X.add('cat_tipo_documento',id_tipo_documento=1,codigo='SINT',descripcion='Documento sintético de prueba',activo=1)
    X.add('cat_tipo_institucion',id_tipo_institucion=1,codigo='PUBLICA',descripcion='Pública',activo=1)
    X.add('cat_tipo_institucion',id_tipo_institucion=2,codigo='PRIVADA',descripcion='Privada',activo=1)
    for i,n in enumerate(DEPARTAMENTOS,1):X.add('cat_departamento',id_departamento=i,codigo=ISO[i-1],nombre=n,activo=1)
    X.add('cat_zona',id_zona=1,nombre='Urbana',activo=1);X.add('cat_zona',id_zona=2,nombre='Rural',activo=1)
    X.add('cat_modalidad',id_modalidad=1,codigo='PRESENCIAL',descripcion='Presencial',activo=1)
    X.add('cat_jornada',id_jornada=1,codigo='MATUTINA',descripcion='Matutina',activo=1)
    X.add('cat_jornada',id_jornada=2,codigo='VESPERTINA',descripcion='Vespertina',activo=1)
    area_id={c:i for i,(c,_) in enumerate(AREAS,1)}
    for c,n in AREAS:X.add('cat_area_conocimiento',id_area=area_id[c],codigo=c,descripcion=n,activo=1)
    for i,(c,n) in enumerate([('SOCIOECONOMICA','Apoyo socioeconómico'),('MERITO','Mérito académico'),('DEPORTIVA','Deportiva')],1):
        X.add('cat_tipo_beca',id_tipo_beca=i,codigo=c,descripcion=n,activo=1)
    X.add('cat_nivel',id_nivel=1,codigo='BAS',nombre='Educación básica',orden=2)
    X.add('cat_nivel',id_nivel=2,codigo='BAC',nombre='Bachillerato',orden=3)
    for g,nv,nom in GRADOS:X.add('cat_grado',id_grado=g,id_nivel=1 if nv=='BAS' else 2,codigo=str(g if g<=9 else g-9),nombre=nom,orden=g if g<=9 else g-9,es_ultimo_grado=int(g==12))
    asig_id={a[0]:i for i,a in enumerate(ASIGNATURAS,1)}
    for i,(c,n,ar,*_) in enumerate(ASIGNATURAS,1):X.add('mae_asignatura',id_asignatura=i,codigo=c,nombre=n,id_area=area_id[ar],descripcion=None,activo=1)
    # ---------------- ciclos y períodos (calendario nacional y bachillerato de 4 períodos)
    ciclos={}
    for a in ANIOS:
        for cuatro in (False,True):
            cid=a+(10000 if cuatro else 0);ps=periodos(a,cuatro)
            X.add('est_ciclo',id_ciclo=cid,codigo=('BAC4-' if cuatro else 'NAC-')+str(a),nombre=(f'Bachillerato de cuatro períodos {a}' if cuatro else f'Año escolar {a}'),anio=a,fecha_inicio=iso(ps[0][0]),fecha_fin=iso(ps[-1][1]),estado='CERRADO')
            for n,(i,f) in enumerate(ps,1):X.add('est_periodo_academico',id_periodo=cid*10+n,id_ciclo=cid,numero=n,nombre=f'Período {n}',fecha_inicio=iso(i),fecha_fin=iso(f))
            ciclos[(a,cuatro)]=dict(id=cid,ps=ps,ini=ps[0][0],fin=ps[-1][1])
    X.add('auditoria_etl_evaluaciones',id_ejecucion=1,fuente='Carga masiva sintética 2024',inicio=ts(D('2024-12-22'),9),fin=ts(D('2024-12-22'),11),estado='COMPLETADA',total_leidos=0,insertados=0,actualizados=0,rechazados=0)
    X.add('auditoria_etl_evaluaciones',id_ejecucion=2,fuente='Carga masiva sintética 2025',inicio=ts(D('2025-12-22'),9),fin=ts(D('2025-12-22'),11),estado='COMPLETADA',total_leidos=0,insertados=0,actualizados=0,rechazados=0)

    COLS=[c for c in colegios() if deps is None or c['dep'] in deps]
    porid={c['id']:c for c in COLS}
    seq=defaultdict(int)
    def nid(tabla,colegio,base):seq[(tabla,colegio)]+=1;return colegio*base+seq[(tabla,colegio)]
    # ---------------- instituciones y docentes (los mismos los dos años)
    docentes={}
    for c in COLS:
        X.add('mae_institucion',id_institucion=c['id'],codigo_institucion=f"CE-{c['id']:05}",nombre=c['nombre'],id_tipo_institucion=2 if c['privado'] else 1,
              id_departamento=c['dep'],id_zona=2 if c['rural'] else 1,permite_becas=int(c['privado']),direccion=f"Dirección sintética {c['k']}, {DEPARTAMENTOS[c['dep']-1]}",
              telefono=None,email=f"centro{c['id']}@example.invalid",fecha_creacion='1998-01-15',activo=1)
        r=random.Random(c['id']*7)
        for g in list(range(1,13))+[13]:              # 12 responsables de curso y un suplente
            pid=nid('persona',c['id'],10000);sexo=r.choice('FM')
            X.add('mae_persona',id_persona=pid,id_tipo_documento=1,numero_documento=f'SINT-D-{pid:09}',primer_nombre=r.choice(NOMBRES_F if sexo=='F' else NOMBRES_M),segundo_nombre=None,
                  primer_apellido=r.choice(APELLIDOS),segundo_apellido=r.choice(APELLIDOS),fecha_nacimiento=iso(date(r.randint(1965,1995),r.randint(1,12),r.randint(1,28))),sexo=sexo,
                  email=None,telefono=None,direccion=None,fecha_registro='2023-12-01 08:00:00')
            X.add('mae_docente',id_docente=pid,id_persona=pid,especialidad='Educación básica' if g<=9 else ('Bachillerato' if g<=12 else 'Suplencias'),fecha_registro='2023-12-01 08:10:00',activo=1)
            docentes[(c['id'],g)]=pid
    # ---------------- alumnos: plantilla inicial 2024
    alumnos={}                                       # id -> perfil
    def nuevo_alumno(c,grado,anio):
        r=random.Random(c['id']*1000+seq[('persona',c['id'])])
        pid=nid('persona',c['id'],10000);sexo=r.choice('FM')
        nac=date(anio-6-grado-(1 if r.random()<0.15 else 0),r.randint(1,12),r.randint(1,28))
        X.add('mae_persona',id_persona=pid,id_tipo_documento=None,numero_documento=None,primer_nombre=r.choice(NOMBRES_F if sexo=='F' else NOMBRES_M),segundo_nombre=r.choice(NOMBRES_F if sexo=='F' else NOMBRES_M) if r.random()<0.6 else None,
              primer_apellido=r.choice(APELLIDOS),segundo_apellido=r.choice(APELLIDOS),fecha_nacimiento=iso(nac),sexo=sexo,email=None,telefono=None,direccion=None,fecha_registro=ts(date(anio-1,12,1),9))
        X.add('mae_estudiante',id_estudiante=pid,id_persona=pid,nie=f'9{pid:09}',fecha_registro=ts(date(anio-1,12,1),9,5),activo=1)
        alumnos[pid]=dict(habilidad=min(98,max(35,r.gauss(75,11))),asiste=(0.70 if r.random()<0.06 else 0.95))
        return pid
    plantilla={}                                     # (colegio,anio) -> {alumno: grado}
    for c in COLS:
        plantilla[(c['id'],2024)]={nuevo_alumno(c,g,2024):g for g in range(1,13) for _ in range(13 if g<=6 else 12)}
    # ---------------- generación por año
    asis_seq=defaultdict(int);asis_cnt=defaultdict(int)
    for anio in ANIOS:
        # traslados (básica, mismo departamento, al cierre del período 1) y retiros (a mitad del período 2)
        traslados={};retiros=set()
        for dep in sorted({c['dep'] for c in COLS}):
            cs=[c for c in COLS if c['dep']==dep];rd=random.Random(anio*100+dep)
            for c in cs:
                cand=[a for a,g in sorted(plantilla[(c['id'],anio)].items()) if g<=9]
                for a in rd.sample(cand,2):traslados[a]=rd.choice([o for o in cs if o['id']!=c['id']])['id']
                resto=[a for a in sorted(plantilla[(c['id'],anio)]) if a not in traslados]
                retiros.update(rd.sample(resto,2))
        resultados_finales={}
        for c in COLS:
            cid=c['id'];r=random.Random(anio*10000+cid)
            nac=ciclos[(anio,False)];b4=ciclos[(anio,True)]
            cal_de=lambda g:b4 if (c['bac4'] and g>=10) else nac
            for cic in ([nac,b4] if c['bac4'] else [nac]):
                X.add('est_institucion_ciclo',id_institucion=cid,id_ciclo=cic['id'],id_tipo_institucion=2 if c['privado'] else 1,id_departamento=c['dep'],id_zona=2 if c['rural'] else 1,
                      permite_becas=int(c['privado']),fecha_corte_matricula=iso(cic['ini']+timedelta(days=45)),estado='CERRADO')
            regla='ULTIMA_RECUPERACION' if c['ultima'] else 'MEJOR_NOTA'
            cursos={};ofertas={};asign={}
            for g,nv,nom in GRADOS:
                cic=cal_de(g);cur=nid('curso',cid,1000)
                X.add('est_curso',id_curso=cur,id_institucion=cid,id_ciclo=cic['id'],id_grado=g,id_jornada=2 if c['vespertina'] else 1,id_modalidad=1,codigo=f'{cid}-{anio}-{g:02}A',
                      nombre=f'{nom} A',seccion='A',capacidad_maxima=40,estado='CERRADO')
                cursos[g]=(cur,cic)
                for a in ASIGNATURAS:
                    horas=a[3] if g<=6 else (a[4] if g<=9 else a[5])
                    if not horas:continue
                    of=nid('oferta',cid,1000)
                    X.add('est_curso_asignatura',id_curso_asignatura=of,id_curso=cur,id_asignatura=asig_id[a[0]],horas_semanales=horas,creditos=None,tipo_resultado='NUMERICA',regla_recuperacion=regla,estado='ACTIVA')
                    escala=10 if (cid+g)%2 else 1                # mismo vector normalizado en todos los colegios
                    for n,(pi,pf) in enumerate(cic['ps'],1):
                        X.add('est_ponderacion_periodo',id_ponderacion_periodo=of*10+n,id_curso_asignatura=of,id_periodo=cic['id']*10+n,peso=escala,estado='PUBLICADO')
                    # responsable del curso; en 9.º Matemática pasa al suplente desde el período 2
                    suplente=(g==9 and a[0]=='MAT')
                    p2=cic['ps'][1][0]
                    tramos=[(docentes[(cid,g)],cic['ini'],cic['ps'][0][1] if suplente else cic['fin'])]+([(docentes[(cid,13)],p2,cic['fin'])] if suplente else [])
                    lst=[]
                    for doc,i,f in tramos:
                        asg=nid('asignacion',cid,1000)
                        X.add('trx_asignacion_docente',id_asignacion=asg,id_docente=doc,id_curso_asignatura=of,fecha_asignacion=ts(i-timedelta(days=10),10),fecha_inicio=iso(i),fecha_fin=iso(f),estado='FINALIZADA')
                        lst.append((asg,i,f))
                    ofertas[(g,a[0])]=(of,horas);asign[of]=lst
                for n,(pi,pf) in enumerate(cic['ps'],1):
                    w=nid('plazo',cid,1000)
                    X.add('est_plazo_registro_notas',id_plazo_registro_notas=w,id_institucion=cid,id_ciclo=cic['id'],id_grado=g,id_periodo=cic['id']*10+n,tipo_intento='ORDINARIA',fecha_inicio_recuperacion=None,fecha_fin_recuperacion=None,
                          fecha_apertura_registro=ts(pf-timedelta(days=10),0),fecha_limite_registro=f'{iso(pf+timedelta(days=10))} 23:59:59',fecha_cierre_registro=ts(pf+timedelta(days=10),18),estado='CERRADA')
                    wi,wf=pf+timedelta(days=14),pf+timedelta(days=18)
                    w=nid('plazo',cid,1000)
                    X.add('est_plazo_registro_notas',id_plazo_registro_notas=w,id_institucion=cid,id_ciclo=cic['id'],id_grado=g,id_periodo=cic['id']*10+n,tipo_intento='RECUPERACION',fecha_inicio_recuperacion=iso(wi),fecha_fin_recuperacion=iso(wf),
                          fecha_apertura_registro=ts(wi,0),fecha_limite_registro=f'{iso(wf+timedelta(days=4))} 23:59:59',fecha_cierre_registro=ts(wf+timedelta(days=4),18),estado='CERRADA')
            c['_cursos'],c['_ofertas'],c['_asign'],c['_regla']=cursos,ofertas,asign,regla
        # inscripciones (origen y destino de traslados)
        insc=defaultdict(list)                        # colegio -> [(ins, alumno, grado, ini, fin, estado)]
        for c in COLS:
            for a,g in sorted(plantilla[(c['id'],anio)].items()):
                cur,cic=c['_cursos'][g]
                if a in traslados:fin,est,mot=cic['ps'][0][1],'TRASLADADA','Traslado a otro centro educativo'
                elif a in retiros:fin,est,mot=cic['ps'][1][0]+timedelta(days=30),'RETIRADA','Retiro voluntario informado por la familia'
                else:fin,est,mot=cic['fin'],'FINALIZADA','Fin del año escolar'
                ins=nid('inscripcion',c['id'],1000)
                insc[c['id']].append(dict(id=ins,alumno=a,grado=g,cur=cur,cic=cic,ini=cic['ini'],fin=fin,estado=est,motivo=mot))
                if a in traslados:
                    d=porid[traslados[a]];cur2,cic2=d['_cursos'][g];ins2=nid('inscripcion',d['id'],1000)
                    insc[d['id']].append(dict(id=ins2,alumno=a,grado=g,cur=cur2,cic=cic2,ini=cic2['ps'][1][0],fin=cic2['fin'],estado='FINALIZADA',motivo='Fin del año escolar',origen=True))
        for c in COLS:
            cid=c['id'];r=random.Random(anio*20000+cid)
            for i in insc[cid]:
                i['notas']={}
                for (g,cod),(of,horas) in c['_ofertas'].items():
                    if g!=i['grado']:continue
                    for n,(pi,pf) in enumerate(i['cic']['ps'],1):
                        ev=pf-timedelta(days=3)
                        if ev<i['ini'] or ev>i['fin']:continue
                        asg=next(x for x in c['_asign'][of] if x[1]<=ev<=x[2])[0]
                        hab=alumnos[i['alumno']]['habilidad']+{'MAT':-5,'ING':-2,'EDF':6,'ART':5}.get(cod,0)
                        nota=int(min(100,max(0,round(r.gauss(hab,9)))))
                        reg=pf+timedelta(days=2);val=reg+timedelta(days=1)
                        cal=nid('calificacion',cid,100000)
                        X.add('trx_calificacion',id_calificacion=cal,id_inscripcion=i['id'],id_ponderacion_periodo=of*10+n,tipo_intento='ORDINARIA',numero_intento=1,version=1,id_calificacion_ordinaria=None,id_calificacion_sustituida=None,
                              id_asignacion_docente=asg,id_docente_registra=docentes[(cid,i['grado'])],nota=nota,resultado_cualitativo=None,fecha_evaluacion=iso(ev),fecha_registro=ts(reg,10,r.randint(0,59)),
                              fecha_validacion=ts(val,9),fecha_anulacion=None,motivo_anulacion=None)
                        sel=[(cal,nota,'ORDINARIA',ts(val,9))]
                        if nota<60 and r.random()<0.7:
                            wi=pf+timedelta(days=14);rev=wi+timedelta(days=1);rreg=rev+timedelta(days=1);rval=rreg+timedelta(days=1)
                            rnota=int(min(100,max(0,nota+(r.randint(5,25) if r.random()<0.85 else -r.randint(1,8)))))
                            rc=nid('calificacion',cid,100000)
                            i.setdefault('recup',[]).append(dict(id_calificacion=rc,id_inscripcion=i['id'],id_ponderacion_periodo=of*10+n,tipo_intento='RECUPERACION',numero_intento=2,version=1,id_calificacion_ordinaria=cal,id_calificacion_sustituida=None,
                              id_asignacion_docente=asg,id_docente_registra=docentes[(cid,i['grado'])],nota=rnota,resultado_cualitativo=None,fecha_evaluacion=iso(rev),fecha_registro=ts(rreg,11),
                              fecha_validacion=ts(rval,9),fecha_anulacion=None,motivo_anulacion=None))
                            sel.append((rc,rnota,'RECUPERACION',ts(rval,9)))
                        # selecciones: una versión por validación, como PR_SELECCIONAR_RESULTADO
                        for v in range(1,len(sel)+1):
                            vista=sel[:v]
                            if c['_regla']=='ULTIMA_RECUPERACION':elegida=max(vista,key=lambda x:x[2]=='RECUPERACION')
                            else:elegida=max(vista,key=lambda x:(x[1],x[2]=='ORDINARIA'))
                            crit='ORDINARIA' if elegida[2]=='ORDINARIA' else c['_regla']
                            X.add('trx_resultado_periodo',id_resultado=nid('resultado',cid,100000),id_estudiante=i['alumno'],id_asignatura=asig_id[cod],id_periodo=i['cic']['id']*10+n,
                                  id_calificacion_seleccionada=elegida[0],version=v,criterio=crit,fecha_seleccion=vista[-1][3],fecha_cierre=(f'{anio}-12-20 12:00:00' if v==len(sel) else None))
                        i['notas'][(cod,n)]=max(sel,key=lambda x:x[1])[1] if c['_regla']=='MEJOR_NOTA' else sel[-1][1]
        for c in COLS:
            for i in insc[c['id']]:
                for rc in i.get('recup',[]):X.add('trx_calificacion',**rc)
        # resultado de cierre y plantilla del año siguiente
        sig=defaultdict(dict)
        for c in COLS:
            for i in insc[c['id']]:
                res=None
                if i['estado']=='FINALIZADA':
                    prom=defaultdict(list)
                    for (cod,n),v in i['notas'].items():prom[cod].append(v)
                    reprobadas=sum(sum(v)/len(v)<60 for v in prom.values())
                    res='REPITE' if reprobadas>=3 else ('GRADUADO' if i['grado']==12 else 'PROMOVIDO')
                    if res!='GRADUADO' and random.Random(i['alumno']+anio).random()>0.03:
                        sig[c['id']][i['alumno']]=i['grado']+(res=='PROMOVIDO')
                X.add('trx_inscripcion',id_inscripcion=i['id'],id_estudiante=i['alumno'],id_curso=i['cur'],fecha_inscripcion=ts(i['ini']-timedelta(days=20),9),fecha_inicio=iso(i['ini']),
                      fecha_fin=iso(i['fin']),estado=i['estado'],motivo_fin_inscripcion=i['motivo'],resultado_cierre=res)
        # becas (solo colegios con becas; alumnos que terminan el año en el mismo colegio)
        for c in [c for c in COLS if c['privado']]:
            r=random.Random(anio*30000+c['id'])
            for i in insc[c['id']]:
                if i['estado']!='FINALIZADA' or i.get('origen') or r.random()>0.15:continue
                b=nid('beca',c['id'],1000);i['beca']=True
                X.add('trx_beca',id_beca=b,id_inscripcion=i['id'],id_tipo_beca=r.choice([1,1,2,3]),porcentaje=r.choice([25,50,50,100]),fecha_otorgamiento=iso(i['ini']-timedelta(days=10)),fecha_registro=ts(i['ini']-timedelta(days=10),9),observaciones=None)
                tramos=[(i['ini'],i['fin'],'FIN_VIGENCIA')]
                if r.random()<0.15:
                    p2=i['cic']['ps'][1][0];tramos=[(i['ini'],p2+timedelta(days=20),'SUSPENSION'),(p2+timedelta(days=50),i['fin'],'FIN_VIGENCIA')]
                for ini,fin,mot in tramos:
                    X.add('trx_beca_vigencia',id_vigencia=nid('vigencia',c['id'],1000),id_beca=b,fecha_inicio=iso(ini),fecha_fin=iso(fin),motivo_fin=mot,fecha_registro=ts(ini,8))
        # sesiones y asistencia (8 colegios)
        for c in [c for c in COLS if c['asistencia']]:
            cid=c['id'];r=random.Random(anio*40000+cid);h0=6 if c['vespertina'] else 0
            for g,(cur,cic) in c['_cursos'].items():
                horario=[]                               # 30 franjas: (día, franja) -> oferta
                for (gg,cod),(of,horas) in c['_ofertas'].items():
                    if gg==g:horario+= [of]*horas
                r.shuffle(horario);slots=[(d,s) for d in range(5) for s in range(6)]
                alumnos_curso=[i for i in insc[cid] if i['cur']==cur]
                for n,(pi,pf) in enumerate(cic['ps'],1):
                    dia=pi;semana=0;inicio_semana=None
                    while dia<=pf:
                        if dia.weekday()<5 and not any(a<=dia<=b for a,b in VACACIONES[anio]):
                            wk=dia.isocalendar()[1]
                            if wk!=inicio_semana:inicio_semana=wk;semana+=1
                            if semanas and semana>semanas:break
                            for (d,s),of in zip(slots,horario):
                                if d!=dia.weekday():continue
                                asg=next(x for x in c['_asign'][of] if x[1]<=dia<=x[2])[0]
                                hh,mm=HORAS[s];hh+=h0;ini=datetime(dia.year,dia.month,dia.day,hh,mm);fin=ini+timedelta(minutes=45)
                                cancel=r.random()<0.015;sid=nid('sesion',cid,100000)
                                X.add('trx_sesion_clase',id_sesion=sid,id_ponderacion_periodo=of*10+n,id_asignacion=asg,fecha_academica=iso(dia),inicio=ini.strftime('%Y-%m-%d %H:%M:%S'),fin=fin.strftime('%Y-%m-%d %H:%M:%S'),
                                      estado='CANCELADA' if cancel else 'IMPARTIDA',observaciones='Actividad institucional' if cancel else None)
                                if cancel:continue
                                for i in alumnos_curso:
                                    if not (i['ini']<=dia<=i['fin']):continue
                                    if c['parcial'] and r.random()<0.03:continue          # captura incompleta
                                    p=alumnos[i['alumno']]['asiste'];x=r.random()
                                    est='PRESENTE' if x<p-0.03 else ('TARDE' if x<p else ('JUSTIFICADA' if x<p+0.015 else 'AUSENTE'))
                                    lleg=ini if est=='PRESENTE' else (ini+timedelta(minutes=r.randint(5,20)) if est=='TARDE' else None)
                                    asis_seq[cid]+=1;asis_cnt[(cur,n)]+=1
                                    X.add('trx_asistencia',id_asistencia=cid*1000000+asis_seq[cid],id_inscripcion=i['id'],id_sesion=sid,estado=est,hora_llegada=lleg.strftime('%Y-%m-%d %H:%M:%S') if lleg else None,
                                          fecha_registro=(fin+timedelta(hours=2)).strftime('%Y-%m-%d %H:%M:%S'),observaciones='Constancia presentada' if est=='JUSTIFICADA' else None)
                        dia+=timedelta(days=1)
        # control de cobertura por curso, período y dominio
        for c in COLS:
            cid=c['id']
            for g,(cur,cic) in c['_cursos'].items():
                for n,(pi,pf) in enumerate(cic['ps'],1):
                    vig=sum(1 for i in insc[cid] if i['cur']==cur and i['ini']<=pf and i['fin']>=pi)
                    nnotas=sum(1 for i in insc[cid] if i['cur']==cur for (cod,k) in i['notas'] if k==n)
                    nbecas=sum(1 for i in insc[cid] if i['cur']==cur and i.get('beca'))
                    doms=[('MATRICULA','COMPLETA',vig),('NOTAS','COMPLETA',nnotas),('BECAS','COMPLETA' if c['privado'] else 'NO_APLICA',nbecas)]
                    if c['asistencia']:doms.append(('ASISTENCIA','PARCIAL' if c['parcial'] else 'COMPLETA',asis_cnt[(cur,n)]))
                    for dom,est,cant in doms:
                        X.add('trx_control_carga',id_control=nid('control',cid,10000),id_curso=cur,id_periodo=cic['id']*10+n,dominio=dom,fecha_corte=iso(pf),estado=est,registros_declarados=cant,
                              fecha_recepcion=ts(pf+timedelta(days=12),10),id_ejecucion=1 if anio==2024 else 2)
        # plantilla 2025: continúan, repiten o vienen trasladados; entran alumnos nuevos para mantener ~150
        if anio==ANIOS[-1]:break
        for c in COLS:
            pl=dict(sig[c['id']]);cuenta=Counter(pl.values())
            for g in range(1,13):
                meta=13 if g<=6 else 12
                for _ in range(max(0,meta-cuenta[g])):pl[nuevo_alumno(c,g,anio+1)]=g
            plantilla[(c['id'],anio+1)]=pl
    for t in X.rows:
        if t=='trx_calificacion':X.rows[t].sort(key=lambda r:(r['tipo_intento']!='ORDINARIA',r['id_calificacion']))
    # conteos de auditoría
    for a in X.rows['auditoria_etl_evaluaciones']:
        a['total_leidos']=a['insertados']=sum(1 for r in X.rows['trx_calificacion'] if r['fecha_evaluacion'].startswith(a['fuente'][-4:]))
    return X

# ---------------------------------------------------------------- salida para SQL*Loader
ORDEN=None
def orden():
    rem=set(SCHEMA);done=[];
    while rem:
        ok=[n for n in SCHEMA if n in rem and {f['references']['table'] for f in SCHEMA[n]['foreign_keys'] if f['references']['table']!=n}<=set(done)]
        done+=ok;rem-=set(ok)
    return done
def ctl(t):
    cols=[]
    for c in FIELDS[t]:
        ty=TYPES[t][c]
        cols.append(f'  {c} DATE "YYYY-MM-DD"' if ty=='date' else (f'  {c} TIMESTAMP "YYYY-MM-DD HH24:MI:SS"' if ty=='timestamp' else f'  {c}'))
    return f"""OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/{t}.csv'
APPEND
INTO TABLE {t}
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
{','.join(chr(10)+x for x in cols).lstrip(chr(10))}
)
"""
def escribir(X):
    (OUT/'datos').mkdir(parents=True,exist_ok=True);(OUT/'ctl').mkdir(exist_ok=True)
    conteos={}
    tablas=[t for t in orden() if X.rows.get(t)]
    for t in tablas:
        with open(OUT/'datos'/f'{t}.csv','w',newline='',encoding='utf-8') as f:
            w=csv.writer(f,lineterminator='\n')
            for r in X.rows[t]:w.writerow(['' if r[c] is None else r[c] for c in FIELDS[t]])
        (OUT/'ctl'/f'{t}.ctl').write_text(ctl(t),encoding='utf-8');conteos[t]=len(X.rows[t])
    (OUT/'conteos.json').write_text(json.dumps(conteos,ensure_ascii=False,indent=2)+'\n')
    sh=['#!/usr/bin/env bash','# Carga los CSV en orden de dependencias con SQL*Loader (ruta convencional: Oracle valida PK, UK, FK y CHECK fila a fila).',
        '# Uso: ORACLE_CONN=usuario/clave@//host:puerto/servicio ./cargar.sh','set -euo pipefail','cd "$(dirname "$0")"',': "${ORACLE_CONN:?Definir ORACLE_CONN=usuario/clave@//host:puerto/servicio}"','mkdir -p logs']
    for t in tablas:sh.append(f'echo "Cargando {t} ({conteos[t]:,} filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/{t}.ctl log=logs/{t}.log bad=logs/{t}.bad silent=header,feedback')
    sh.append('echo "Carga terminada. Ejecutar post_carga.sql en SQL*Plus o SQLcl."')
    (OUT/'cargar.sh').write_text('\n'.join(sh)+'\n');(OUT/'cargar.sh').chmod(0o755)
    checks='\n'.join(f" SELECT COUNT(*) INTO n FROM {t}; IF n<>{conteos[t]} THEN DBMS_OUTPUT.PUT_LINE('FALLO {t}: '||n||' filas, se esperaban {conteos[t]}'); f:=f+1; END IF;" for t in tablas)
    (OUT/'pre_carga.sql').write_text("""-- Antes de cargar: el OLTP debe existir y estar vacío. No instalar las validaciones antes de la carga masiva.
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE n NUMBER; t NUMBER:=0; BEGIN
"""+'\n'.join(f" SELECT COUNT(*) INTO n FROM {x}; t:=t+n;" for x in orden())+"""
 IF t>0 THEN RAISE_APPLICATION_ERROR(-20900,'El OLTP no está vacío: '||t||' filas.'); END IF;
 SELECT COUNT(*) INTO n FROM user_objects WHERE object_name='VAL_REGLA';
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20900,'las validaciones ya están instaladas: cargar antes de instalarlo.'); END IF;
 DBMS_OUTPUT.PUT_LINE('OK: OLTP vacío y sin validaciones instaladas.');
END;
/
""")
    (OUT/'post_carga.sql').write_text("""-- Después de cargar: conteos exactos, restricciones habilitadas y estadísticas.
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE n NUMBER; f NUMBER:=0; BEGIN
"""+checks+"""
 SELECT COUNT(*) INTO n FROM user_constraints WHERE table_name IN (SELECT table_name FROM user_tables WHERE table_name NOT LIKE 'STG\\_%' ESCAPE '\\') AND (status<>'ENABLED' OR validated<>'VALIDATED');
 IF n>0 THEN DBMS_OUTPUT.PUT_LINE('FALLO: '||n||' restricciones deshabilitadas o sin validar.'); f:=f+1; END IF;
 IF f>0 THEN RAISE_APPLICATION_ERROR(-20901,f||' comprobaciones fallaron; revisar logs/*.log y logs/*.bad.'); END IF;
 DBMS_OUTPUT.PUT_LINE('OK: conteos exactos y restricciones habilitadas.');
END;
/
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>USER, cascade=>TRUE)
PROMPT Estadísticas actualizadas. Siguiente paso: Staging/CREACION_STAGING.sql y después Validacion/INSTALAR_VALIDACIONES.sql.
""")
    return conteos

# ---------------------------------------------------------------- verificación en SQLite
def verificar(semanas=2):
    from validacion_local import connect,translate
    X=generar(deps={6},semanas=semanas)
    db=connect();db.execute('CREATE TABLE val_politica (id INTEGER, capacidad_estricta INTEGER)');db.execute('INSERT INTO val_politica VALUES (1,0)')
    for t in orden():
        for r in X.rows.get(t,[]):db.execute(f"INSERT INTO {t} ({','.join(r)}) VALUES ({','.join('?'*len(r))})",list(r.values()))
    V=texto_validaciones()
    reglas=[(m.group(1),m.group(2),m.group(4),m.group(5).replace("''","'")) for m in re.finditer(r"INSERT INTO val_regla VALUES \('([^']+)','([A-Z]+)','([^']+)','([A-Z]+)','(?:[^']|'')*','((?:[^']|'')*)'\);",V)]
    cv=re.findall(r'ALTER TABLE (\w+) ADD CONSTRAINT (\w+) CHECK \((.*)\) ENABLE VALIDATE;',V)
    malas={};lentas=[]
    for rid,capa,sev,sql in reglas:
        if capa!='OPERACION':continue
        t0=time.time();n=db.execute('SELECT COUNT(*) FROM ('+translate(sql)+')').fetchone()[0];dt=time.time()-t0
        if dt>2:lentas.append((rid,round(dt,1)))
        if n:malas[rid]=(sev,n)
    for t,name,expr in cv:
        n=db.execute(f'SELECT COUNT(*) FROM {t} WHERE NOT ({translate(expr)})').fetchone()[0]
        if n:malas[name]=('CHECK',n)
    cnt={t:len(v) for t,v in X.rows.items()}
    print('Muestra: departamento San Salvador (3 colegios), 2 años,',semanas,'semanas de clases por período:',sum(cnt.values()),'filas')
    print('  ',{k:cnt[k] for k in ['mae_estudiante','trx_inscripcion','trx_calificacion','trx_resultado_periodo','trx_sesion_clase','trx_asistencia','trx_beca','trx_control_carga']})
    print('Reglas lentas en SQLite (>2 s):',lentas)
    assert not malas,('incumplimientos',malas)
    print('OK: la muestra cumple las',sum(1 for r in reglas if r[1]=='OPERACION'),'reglas OPERACION y los',len(cv),'CHECK adicionales de las validaciones.')

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--verificar',action='store_true');a=ap.parse_args()
    if a.verificar:verificar();sys.exit(0)
    t0=time.time();X=generar();conteos=escribir(X)
    print(f'{sum(conteos.values()):,} filas en {len(conteos)} tablas ({time.time()-t0:.0f} s). Principales:',{k:f'{conteos[k]:,}' for k in ['mae_estudiante','trx_inscripcion','trx_calificacion','trx_sesion_clase','trx_asistencia']})
