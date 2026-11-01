"""Referencia relacional local. SQLite NO sustituye una ejecución en Oracle."""
import json,re,sqlite3
from collections import defaultdict
from datetime import datetime
from fractions import Fraction
from pathlib import Path
from contrato_staging import SCHEMA,projections,all_rules

from rutas import ROOT,ruta

def translate(sql):
    sql=re.sub(r'(\w+)\s+IS\s+JSON\s+STRICT',r'json_valid(\1)',sql,flags=re.I)
    sql=re.sub(r"\b(?:TIMESTAMP|DATE)\s*('[^']*')",r'\1',sql,flags=re.I)
    sql=re.sub(r'EXTRACT\(YEAR FROM ([\w.]+)\)',r'CAST(substr(\1,1,4) AS INTEGER)',sql,flags=re.I)
    return sql

def keys(table):
    items=[tuple(f['name'] for f in table['fields'] if 'PK' in f['key'])]
    items += [tuple(x) for x in table['unique']]+[(f['name'],) for f in table['fields'] if 'UK' in f['key']]
    return list(dict.fromkeys(items))

def connect():
    db=sqlite3.connect(':memory:');db.row_factory=sqlite3.Row
    db.execute('PRAGMA foreign_keys=ON')
    db.create_function('TRUNC',1,lambda x:None if x is None else (x[:10] if isinstance(x,str) else int(x)))
    for name,t in SCHEMA.items():
      columns=[]
      for f in t['fields']:
        typ='INTEGER' if f['type'] in ('int','boolean') else ('REAL' if f['type']=='decimal' else 'TEXT')
        part=f['name']+' '+typ+(' NOT NULL' if not f['nullable'] else '')
        for check in f.get('oracle_checks',[]):part+=' CHECK ('+translate(check)+')'
        match=re.fullmatch(r'VARCHAR2\((\d+) CHAR\)',f['oracle_type'])
        if match:part+=' CHECK (length('+f['name']+')<='+match.group(1)+')'
        columns.append(part)
      for i,key in enumerate(keys(t)):
        columns.append(('PRIMARY KEY' if i==0 else 'UNIQUE')+' ('+','.join(key)+')')
      for fk in t['foreign_keys']:
        columns.append('FOREIGN KEY ('+','.join(fk['columns'])+') REFERENCES '+fk['references']['table']+' ('+','.join(fk['references']['columns'])+')')
      for rule in t.get('business_constraints',[]):
        if rule.get('oracle_check'):columns.append('CHECK ('+translate(rule['oracle_check'])+')')
      db.execute('CREATE TABLE '+name+' ('+','.join(columns)+')')
    return db

def prepare():
    fixture=json.loads((ruta('datos_sinteticos.json')).read_text())
    db=connect()
    # Orden topológico de dependencias, omitiendo las autorreferencias.
    remaining=set(SCHEMA);done=set()
    while remaining:
      ready=[n for n in SCHEMA if n in remaining and {f['references']['table'] for f in SCHEMA[n]['foreign_keys'] if f['references']['table']!=n}<=done]
      if not ready:raise ValueError('Ciclo entre tablas: '+str(remaining))
      for name in ready:
        columns=[f['name'] for f in SCHEMA[name]['fields']]
        sql='INSERT INTO '+name+' ('+','.join(columns)+') VALUES ('+','.join('?' for _ in columns)+')'
        db.executemany(sql,[[row[c] for c in columns] for row in fixture['tablas'][name]])
        done.add(name);remaining.remove(name)
    db.commit()
    db.execute('CREATE TABLE ctl_carga_staging (id_control INTEGER NOT NULL PRIMARY KEY CHECK(id_control=1),version_carga INTEGER NOT NULL CHECK(version_carga>=0))')
    db.execute('INSERT INTO ctl_carga_staging VALUES (1,0)')
    db.execute('UPDATE ctl_carga_staging SET version_carga=version_carga+1 WHERE id_control=1')
    total=0
    for name,t in projections().items():
      defs=[]
      for f in t['fields']:
        typ='INTEGER' if f['type'] in ('int','boolean') else ('REAL' if f['type']=='decimal' else 'TEXT')
        defs.append(f['name']+' '+typ+(' NOT NULL' if not f['nullable'] else ''))
      defs.append('FOREIGN KEY (id_ejecucion_carga) REFERENCES auditoria_etl_evaluaciones(id_ejecucion)')
      db.execute('CREATE TABLE '+name+' ('+','.join(defs)+')')
    db.execute("INSERT INTO auditoria_etl_evaluaciones VALUES (9002,'CARGA_STAGING_PRUEBA','2026-09-16 10:00:00',NULL,'EN_PROCESO',0,0,0,0)")
    for name,t in projections().items():
      fields=t['fields'];select=','.join(f['expression'] if f.get('source_table') else ("9002" if f['name']=='id_ejecucion_carga' else "'2026-09-16 10:00:00'") for f in fields)
      cur=db.execute('INSERT INTO '+name+' ('+','.join(f['name'] for f in fields)+') SELECT '+select+' FROM '+t['from_sql'])
      total+=cur.rowcount
    db.execute("UPDATE auditoria_etl_evaluaciones SET estado='COMPLETADA',fin='2026-09-16 10:01:00',total_leidos=?,insertados=? WHERE id_ejecucion=9002",(total,total))
    db.commit();return db,fixture

def violations(db):
    out=[]
    for rule in all_rules():
      try:count=db.execute('SELECT COUNT(*) FROM ('+translate(rule['sql'])+')').fetchone()[0]
      except sqlite3.Error as e:raise RuntimeError(rule['id']+': '+str(e)) from e
      if count:out.append({'regla':rule['id'],'cantidad':count})
    return out

class AcademicReference:
    def __init__(self,data):
      self.t=data['tablas'];self.by={n:{r[next(f['name'] for f in SCHEMA[n]['fields'] if 'PK' in f['key'])]:r for r in rows} for n,rows in self.t.items() if len([f for f in SCHEMA[n]['fields'] if 'PK' in f['key']])==1}
    def selected(self,cut):
      attempts={}
      for n in self.t['trx_calificacion']:
        if n['fecha_validacion'] is None or n['fecha_validacion']>cut:continue
        key=(n['id_inscripcion'],n['id_ponderacion_periodo'],n['numero_intento'])
        if key not in attempts or n['version']>attempts[key]['version']:attempts[key]=n
      valid={n['id_calificacion']:n for n in attempts.values() if n['fecha_anulacion'] is None or n['fecha_anulacion']>cut}
      latest={}
      for r in self.t['trx_resultado_periodo']:
        if r['fecha_seleccion']>cut:continue
        key=(r['id_estudiante'],r['id_asignatura'],r['id_periodo'])
        if key not in latest or r['version']>latest[key]['version']:latest[key]=r
      return {k:(valid[r['id_calificacion_seleccionada']],r) for k,r in latest.items() if r['id_calificacion_seleccionada'] in valid}
    def obligations(self,student,year):
      result={}
      for i in self.t['trx_inscripcion']:
        c=self.by['est_curso'][i['id_curso']]
        if i['id_estudiante']!=student or c['id_ciclo']!=year or i['estado']=='ANULADA':continue
        for o in self.t['est_curso_asignatura']:
          if o['id_curso']!=c['id_curso'] or o['tipo_resultado']!='NUMERICA':continue
          plan=[p for p in self.t['est_ponderacion_periodo'] if p['id_curso_asignatura']==o['id_curso_asignatura'] and p['estado']=='PUBLICADO']
          total=sum(Fraction(p['peso']) for p in plan)
          for p in plan:
            period=self.by['est_periodo_academico'][p['id_periodo']]
            if i['fecha_inicio']<=period['fecha_fin'] and (i['fecha_fin'] or f'{year}-11-30')>=period['fecha_inicio']:
              result[(o['id_asignatura'],p['id_periodo'])]=Fraction(p['peso'])/total
      return result
    def average(self,student,subject,year,cut):
      expected={k:w for k,w in self.obligations(student,year).items() if k[0]==subject}
      selection=self.selected(cut);pairs=[];closed=True
      for (a,p),weight in expected.items():
        item=selection.get((student,a,p))
        if item is None or item[0]['nota'] is None:closed=False;continue
        n,r=item;pairs.append((Fraction(n['nota']),weight))
        if r['fecha_cierre'] is None or r['fecha_cierre']>cut:closed=False
      available=sum((w for _,w in pairs),Fraction(0));total=sum(expected.values(),Fraction(0))
      current=sum((n*w for n,w in pairs),Fraction(0))/available if available else None
      cycle=self.by['est_ciclo'][year]
      contexts=[h for h in self.t['est_institucion_ciclo'] if h['id_ciclo']==year and any(i['id_estudiante']==student and self.by['est_curso'][i['id_curso']]['id_institucion']==h['id_institucion'] and self.by['est_curso'][i['id_curso']]['id_ciclo']==year for i in self.t['trx_inscripcion'])]
      final=current if expected and available==total and closed and cycle['estado']=='CERRADO' and cycle['fecha_fin']<=cut[:10] and all(h['estado']=='CERRADO' for h in contexts) else None
      return current,(available/total if total else None),final
    def attendance(self,student,period,cut):
      applicable=[]
      for s in self.t['trx_sesion_clase']:
        p=self.by['est_ponderacion_periodo'][s['id_ponderacion_periodo']]
        if p['id_periodo']!=period or s['estado']!='IMPARTIDA' or s['fin']>cut:continue
        o=self.by['est_curso_asignatura'][p['id_curso_asignatura']]
        for i in self.t['trx_inscripcion']:
          if i['id_estudiante']==student and i['id_curso']==o['id_curso'] and i['estado']!='ANULADA' and i['fecha_inicio']<=s['fecha_academica']<=(i['fecha_fin'] or f'{period//10}-11-30'):
            applicable.append((i['id_inscripcion'],s['id_sesion']))
      recorded={(a['id_inscripcion'],a['id_sesion']):a for a in self.t['trx_asistencia'] if a['fecha_registro']<=cut}
      captured=[recorded[k] for k in applicable if k in recorded]
      present=sum(a['estado'] in ('PRESENTE','TARDE') for a in captured)
      return {'observed':Fraction(present,len(captured)) if captured else None,'coverage':Fraction(len(captured),len(applicable)) if applicable else None,'definitive':Fraction(present,len(applicable)) if applicable and len(captured)==len(applicable) else None,'sessions':len(applicable),'captured':len(captured)}
    def risk(self,student,period,cut):
      if self.by['est_periodo_academico'][period]['fecha_fin']>=cut[:10]:return None
      expected=[a for a,p in self.obligations(student,period//10) if p==period]
      selection=self.selected(cut);notes=[selection.get((student,a,period)) for a in expected]
      att=self.attendance(student,period,cut)
      if not expected or any(x is None or x[0]['nota'] is None for x in notes) or att['coverage']!=1:return None
      mean=sum(Fraction(x[0]['nota']) for x in notes)/len(notes)
      return mean<60 and att['definitive']<Fraction(3,4)
    def active_benefit(self,benefit,day):
      return any(v['id_beca']==benefit and v['fecha_inicio']<=day<=(v['fecha_fin'] or '2026-11-30') for v in self.t['trx_beca_vigencia'])
    def retention(self,year):
      cutoff=f'{year}-02-15';cohort=set();graduates=set()
      for i in self.t['trx_inscripcion']:
        c=self.by['est_curso'][i['id_curso']]
        if c['id_ciclo']!=year or i['estado']=='ANULADA':continue
        if i['fecha_inicio']<=cutoff<=(i['fecha_fin'] or f'{year}-11-30'):cohort.add(i['id_estudiante'])
        if i['resultado_cierre']=='GRADUADO' and self.by['cat_grado'][c['id_grado']]['es_ultimo_grado']:graduates.add(i['id_estudiante'])
      cohort-=graduates;next_year=year+1
      continued={i['id_estudiante'] for i in self.t['trx_inscripcion'] if self.by['est_curso'][i['id_curso']]['id_ciclo']==next_year and i['estado']!='ANULADA' and i['fecha_inicio']<=f'{next_year}-02-15'<=(i['fecha_fin'] or f'{next_year}-11-30')}&cohort
      courses=[c['id_curso'] for c in self.t['est_curso'] if c['id_ciclo']==next_year and c['estado']!='ANULADO']
      complete=all(any(z['id_curso']==c and z['dominio']=='MATRICULA' and z['fecha_corte']==f'{next_year}-02-15' and z['estado']=='COMPLETA' for z in self.t['trx_control_carga']) for c in courses)
      return {'cohort':sorted(cohort),'continued':sorted(continued),'rate':Fraction(len(continued),len(cohort)) if cohort else None,'complete':complete}

if __name__=='__main__':
    db,fixture=prepare();bad=violations(db)
    print(json.dumps({'reglas':len(all_rules()),'infracciones':bad[:30],'total_infracciones':len(bad),'source_rows':sum(len(x) for x in fixture['tablas'].values())},ensure_ascii=False))
    if bad:raise SystemExit(1)
