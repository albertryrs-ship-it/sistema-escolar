"""Verificación documental, relacional y de gramática SQL; no compila PL/SQL."""
import json,re,sys,unittest
from collections import Counter,defaultdict
from decimal import Decimal
from fractions import Fraction
from pathlib import Path
from contrato_staging import ROOT,SCHEMA,projections,all_rules
from rutas import ruta,texto_cargador
from validacion_local import prepare,violations,translate,AcademicReference
from casos_sql import CASES as SQL_CASES
from casos_invalidos import CASES as INVALID_CASES

try:import sqlglot
except ImportError:
    sys.path.insert(0,str(ROOT.parents[1]/'tmp/correccion_staging/deps'))
    import sqlglot
from sqlglot import exp
from sqlglot.errors import ErrorLevel

def parse(sql):
    # Limitación conocida de SQLGlot 30.24: STRICT en IS JSON se interpreta mal.
    # Solo la copia destinada al lint se normaliza. El SQL Oracle conserva STRICT.
    lint_sql=re.sub(r'\bIS\s+JSON\s+STRICT\b','IS JSON',sql,flags=re.I)
    # La propiedad física Oracle tampoco está implementada en este parser.
    # test_35 comprueba que se mantiene en cada CTAS del entregable.
    lint_sql=re.sub(r'\bSEGMENT\s+CREATION\s+IMMEDIATE\b','',lint_sql,flags=re.I)
    result=sqlglot.parse_one(lint_sql,read='oracle',error_level=ErrorLevel.RAISE)
    if isinstance(result,exp.Command):raise AssertionError('Sentencia no reconocida por el parser: '+sql[:80])
    return result

def value(node):
    if isinstance(node,exp.Null):return None
    if isinstance(node,exp.Literal):
      if node.is_string:return node.this
      d=Decimal(node.this);return int(d) if d==d.to_integral_value() else float(d)
    if isinstance(node,(exp.Cast,exp.DateStrToDate,exp.StrToTime)):return value(node.this)
    raise AssertionError('Expresión inesperada en datos fijos: '+repr(node))

class PackageChecks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.db,cls.fixture=prepare();cls.ref=AcademicReference(cls.fixture)
    @classmethod
    def tearDownClass(cls):cls.db.close()

    def test_01_modelos_tipos_claves_y_conteos(self):
        self.assertEqual((len(SCHEMA),sum(len(t['fields']) for t in SCHEMA.values())),(33,235))
        self.assertEqual(sum(len(t['foreign_keys']) for t in SCHEMA.values()),54)
        p=projections();self.assertEqual((len(p),sum(len(t['fields']) for t in p.values())),(29,260))
        for t in p.values():
          for f in t['fields']:
            if f.get('source_table'):
              origin=next(x for x in SCHEMA[f['source_table']]['fields'] if x['name']==f['source_column'])
              self.assertEqual((f['oracle_type'],f['nullable']),(origin['oracle_type'],origin['nullable']))

    def test_02_dos_diccionarios_corresponden_a_campos(self):
        for file,schema in [('Diccionario_Datos_Educacion.md',SCHEMA),('Diccionario_Staging.md',projections())]:
          current=None;found={}
          for line in ruta(file).read_text().splitlines():
            if line.startswith('### '):current=line[4:];found[current]=[]
            elif line.startswith('## '):current=None
            elif current and line.startswith('| ') and not line.startswith('| Campo '):
              cells=[c.strip() for c in line.split('|')[1:-1]]
              found[current].append(cells)
          self.assertEqual(set(found),set(schema))
          for n,t in schema.items():
            self.assertEqual([r[0] for r in found[n]],[f['name'] for f in t['fields']])
            self.assertEqual([r[1] for r in found[n]],[f['oracle_type'] for f in t['fields']])
            self.assertEqual([r[3] for r in found[n]],['Sí' if f['nullable'] else 'No' for f in t['fields']])

    def test_03_identificadores_ascii_hasta_128(self):
        names=list(SCHEMA)+list(projections())+[f['name'] for t in list(SCHEMA.values())+list(projections().values()) for f in t['fields']]
        ddl=(ruta('SCRIPT_BASE.sql')).read_text()+(ruta('CREACION_STAGING.sql')).read_text()
        names+=re.findall(r'\b(?:CONSTRAINT|INDEX|SEQUENCE)\s+([a-zA-Z][a-zA-Z0-9_]*)',ddl,re.I)
        for name in names:self.assertRegex(name,r'^[A-Za-z][A-Za-z0-9_]{0,127}$')

    def test_04_ddl_oracle_tablas_y_columnas(self):
        text=(ruta('SCRIPT_BASE.sql')).read_text()
        definitions=re.findall(r'(?ms)^CREATE TABLE \w+ \(.*?^\);',text)
        self.assertEqual(len(definitions),33)
        for sql in definitions:
          tree=parse(sql);name=tree.this.this.name.lower()
          columns=[x.name.lower() for x in tree.this.expressions if isinstance(x,exp.ColumnDef)]
          self.assertEqual(columns,[f['name'] for f in SCHEMA[name]['fields']])
        for sql in re.findall(r'(?m)^(?:ALTER TABLE|CREATE INDEX) [^\n]+;',text):parse(sql)

    def test_05_sql_sintetico_decodifica_exactamente_los_casos(self):
        text=(ruta('DATOS_FICTICIOS.sql')).read_text();found=defaultdict(list)
        for sql in re.findall(r'(?ms)^INSERT ALL\n.*?^SELECT 1 FROM dual;',text):
          tree=parse(sql);total_columns=0
          self.assertIsInstance(tree,exp.MultitableInserts)
          for conditional in tree.expressions:
            insert=conditional.this;table=insert.this.this.name.lower();cols=[c.name.lower() for c in insert.this.expressions]
            vals=[value(v) for v in insert.expression.expressions[0].expressions]
            self.assertEqual(len(cols),len(vals));found[table].append(dict(zip(cols,vals)));total_columns+=len(cols)
          self.assertLess(total_columns,999)
        for table,rows in self.fixture['tablas'].items():self.assertEqual(found.get(table,[]),rows,table)

    def test_06_ctas_y_carga_coinciden(self):
        text=(ruta('CREACION_STAGING.sql')).read_text()
        ctas=re.findall(r"q'~(CREATE TABLE STG_.*?WHERE 1 = 0)~'",text,re.S)
        self.assertEqual(len(ctas),29)
        for sql in ctas:parse(sql)
        text=texto_cargador()
        for table,t in projections().items():
          matches=re.findall(r'INSERT INTO '+table+r'\s*\(([^)]+)\)\s*(SELECT [^;]+);',text,re.I)
          self.assertEqual(len(matches),1,table)
          cols,select=matches[0];self.assertEqual([c.strip().lower() for c in cols.split(',')],[f['name'] for f in t['fields']])
          parse('INSERT INTO '+table+' ('+cols+') '+select)

    def test_07_reglas_y_consultas_parsean_como_oracle(self):
        for rule in all_rules():parse(rule['sql'])
        for _,sql,_ in SQL_CASES:parse(sql)
        for case in INVALID_CASES:
          for sql in case['sql']:parse(sql)

    def test_08_relaciones_y_reglas_positivas(self):
        self.assertEqual(self.db.execute('PRAGMA foreign_key_check').fetchall(),[])
        self.assertEqual(violations(self.db),[])

    def test_09_copia_de_valores_y_procedencia(self):
        for table,t in projections().items():
          fields=[f for f in t['fields'] if f.get('source_table')]
          source=[tuple(r) for r in self.db.execute('SELECT '+','.join(f['expression'] for f in fields)+' FROM '+t['from_sql'])]
          target=[tuple(r) for r in self.db.execute('SELECT '+','.join(f['name'] for f in fields)+' FROM '+table)]
          self.assertEqual(Counter(source),Counter(target),table)
          self.assertEqual(self.db.execute('SELECT COUNT(DISTINCT id_ejecucion_carga) FROM '+table).fetchone()[0],1)

    def test_10_promedio_parcial_y_final_separados(self):
        self.assertEqual(self.ref.average(1001,501,2026,'2026-09-15 23:59:59'),(70,Fraction(3,5),None))
        self.assertEqual(self.ref.average(1001,501,2025,'2026-01-16 23:59:59'),(78,1,78))

    def test_11_cero_real_se_conserva(self):
        self.assertEqual(self.ref.average(1005,501,2026,'2026-09-15 23:59:59'),(40,Fraction(3,5),None))
        self.assertTrue(any(n['nota']==0 for n in self.fixture['tablas']['trx_calificacion']))

    def test_12_recuperacion_posterior_al_ciclo(self):
        notes=self.ref.selected('2026-01-16 23:59:59')
        selected=notes[(1002,501,20253)][0]
        self.assertEqual((selected['nota'],selected['numero_intento']),(70,2))
        self.assertGreater(selected['fecha_evaluacion'],'2025-11-30')

    def test_13_anulacion_no_revive_version(self):
        self.assertNotIn((1007,502,20262),self.ref.selected('2026-09-05 12:00:00'))
        self.assertEqual(self.ref.selected('2026-09-18 23:59:59')[(1007,502,20262)][0]['version'],3)

    def test_14_traslado_normaliza_planes_completos(self):
        self.assertEqual(self.ref.average(1004,501,2025,'2026-01-16 23:59:59'),(76,1,76))

    def test_15_riesgo_requiere_periodo_y_datos_completos(self):
        self.assertTrue(self.ref.risk(1002,20252,'2026-01-16 23:59:59'))
        self.assertFalse(self.ref.risk(1001,20252,'2026-01-16 23:59:59'))
        self.assertIsNone(self.ref.risk(1007,20262,'2026-09-15 23:59:59'))
        self.assertIsNone(self.ref.risk(1001,20263,'2026-09-15 23:59:59'))

    def test_16_asistencia_incompleta_no_es_ausencia(self):
        a=self.ref.attendance(1007,20262,'2026-09-15 23:59:59')
        self.assertEqual((a['sessions'],a['captured']),(68,67))
        self.assertEqual(a['coverage'],Fraction(67,68));self.assertIsNone(a['definitive'])
        self.assertEqual(a['observed'],Fraction(34,67))

    def test_17_nocturnidad_no_rompe_fecha_academica(self):
        sessions=self.fixture['tablas']['trx_sesion_clase']
        overnight=[s for s in sessions if s['fin'][:10]>s['fecha_academica']]
        self.assertTrue(overnight)
        self.assertTrue(all(s['inicio'][:10]==s['fecha_academica'] and s['fin']>s['inicio'] for s in overnight))

    def test_18_retencion_excluye_graduados_y_nuevos(self):
        r=self.ref.retention(2025)
        self.assertEqual(r['rate'],Fraction(4,5));self.assertTrue(r['complete'])
        self.assertNotIn(1006,r['cohort']);self.assertNotIn(1007,r['cohort']);self.assertIn(1002,r['continued'])

    def test_19_variacion_interanual_solo_finales(self):
        final=lambda y:sum(self.ref.average(1001,a,y,'2026-01-16 23:59:59')[2] for a in (501,502))/2
        self.assertEqual(final(2025)-final(2024),7)
        self.assertIsNone(self.ref.average(1001,501,2026,'2026-09-15 23:59:59')[2])

    def test_20_beca_interrumpida_y_desconocidos(self):
        self.assertFalse(self.ref.active_benefit(7006,'2026-07-15'))
        self.assertTrue(self.ref.active_benefit(7006,'2026-08-15'))
        controls=self.fixture['tablas']['trx_control_carga']
        self.assertTrue(any(z['id_curso']==301 and z['dominio']=='BECAS' and z['fecha_corte']=='2026-09-15' and z['estado']=='PARCIAL' for z in controls))

    def test_21_riesgo_territorial_comparable(self):
        risk=lambda s:self.ref.risk(s,20252,'2026-01-16 23:59:59')
        self.assertEqual(sum(risk(s) for s in [1001,1002,1003,1005]),2)
        self.assertFalse(risk(1004))
        self.assertEqual(len(self.fixture['tablas']['cat_departamento']),2)
        self.assertEqual({i['id_institucion']:i['id_departamento'] for i in self.fixture['tablas']['mae_institucion']},{1:1,2:2})

    def test_22_cualitativos_no_se_convierten_en_numeros(self):
        self.assertEqual(self.ref.obligations(1008,2026),{})
        self.assertIsNone(self.ref.risk(1008,20262,'2026-09-15 23:59:59'))

    def test_23_consultas_sql_dan_los_resultados_esperados(self):
        for label,sql,expected in SQL_CASES:
          value=self.db.execute(translate(sql)).fetchone()[0]
          if expected is None:self.assertIsNone(value,label)
          else:self.assertAlmostEqual(value,expected,places=8,msg=label)

    def test_24_infracciones_detectadas_y_revertidas(self):
        rules={r['id']:r for r in all_rules()}
        for case in INVALID_CASES:
          self.db.execute('SAVEPOINT caso_negativo')
          try:
            for sql in case.get('sqlite',case['sql']):self.db.execute(translate(sql))
            count=self.db.execute('SELECT COUNT(*) FROM ('+translate(rules[case['rule']]['sql'])+')').fetchone()[0]
            self.assertGreater(count,0,case['name'])
          finally:self.db.execute('ROLLBACK TO caso_negativo');self.db.execute('RELEASE caso_negativo')
        self.assertEqual(violations(self.db),[])

    def test_25_estandares_carga_y_reintento(self):
        sql=texto_cargador()
        for table in projections():self.assertIn('LOCK TABLE '+table+' IN EXCLUSIVE MODE NOWAIT',sql)
        self.assertNotIn('SERIALIZABLE',sql)
        for source in {f['source_table'] for t in projections().values() for f in t['fields'] if f.get('source_table')}:self.assertIn('LOCK TABLE '+source+' IN SHARE MODE WAIT 60',sql)
        self.assertIn('ROLLBACK;',sql);self.assertIn('PRAGMA AUTONOMOUS_TRANSACTION',sql)
        self.assertIn('v_ejecucion:=v_nueva;',sql)
        opening=sql.split('PROCEDURE abrir_ejecucion IS',1)[1].split('PROCEDURE registrar_fallo',1)[0]
        self.assertLess(opening.index('COMMIT;'),opening.index('v_ejecucion:=v_nueva;'))
        self.assertNotRegex(sql,r'(?is)INSERT\s+INTO\s+STG_\w+\s+SELECT\s+\*')

    def test_26_ningun_borrado_ni_promedio_insertado(self):
        for texto in [ruta('CREACION_STAGING.sql').read_text(),ruta('DATOS_FICTICIOS.sql').read_text(),texto_cargador()]:
          sql=re.sub(r'--[^\n]*','',texto)
          self.assertNotRegex(sql,r'(?i)\b(?:DROP|TRUNCATE|DELETE)\b')
        cols={f['name'] for f in SCHEMA['trx_calificacion']['fields']}
        self.assertFalse(any('promedio' in c for c in cols))

    def test_27_reglas_documentadas_y_coordinadas(self):
        stored=json.loads((ruta('reglas_validacion.json')).read_text())
        self.assertEqual(stored,all_rules())
        self.assertEqual(json.loads((ruta('modelo_staging.json')).read_text()),projections())
        for name in ['Acerca_del_modelo.md','Diccionario_Datos_Educacion.md','Diccionario_KPI_Educacion.md']:
          text=ruta(name).read_text()
          self.assertNotRegex(text,r'0 para la ordinaria|usa intento 0')
          self.assertIn('1',text)
        self.assertIn('https://todiagram.com/editor?doc=8c24f0523d8da690df328b98',(ruta('Diccionario_Datos_Educacion.md')).read_text())

    def test_28_parser_no_debilita_json_en_el_entregable(self):
        text=(ruta('SCRIPT_BASE.sql')).read_text()
        self.assertIn('json_original IS JSON STRICT',text)
        tree=parse("SELECT DATE '2024-01-01',TIMESTAMP '2024-01-01 10:00:00' FROM dual")
        self.assertEqual([value(x) for x in tree.expressions],['2024-01-01','2024-01-01 10:00:00'])

    def test_29_validacion_posterior_no_contamina_corte(self):
        self.assertTrue((1007,502,20262) not in self.ref.selected('2026-09-15 23:59:59'))
        self.assertEqual(self.ref.selected('2026-09-18 23:59:59')[(1007,502,20262)][0]['nota'],50)

    def test_30_matricula_activa_incluye_nuevos_y_cualitativos(self):
        active={i['id_estudiante'] for i in self.fixture['tablas']['trx_inscripcion'] if self.ref.by['est_curso'][i['id_curso']]['id_ciclo']==2026 and i['estado']!='ANULADA' and i['fecha_inicio']<='2026-09-15'<=(i['fecha_fin'] or '2026-11-30')}
        self.assertEqual(len(active),6);self.assertIn(1007,active);self.assertIn(1008,active)

    def test_31_aprobacion_sobre_finales_cerrados(self):
        finals=[self.ref.average(s,a,2025,'2026-01-16 23:59:59')[2] for s in range(1001,1007) for a in (501,502)]
        self.assertTrue(all(v is not None for v in finals))
        self.assertEqual(Fraction(sum(v>=60 for v in finals),len(finals)),Fraction(3,4))

    def test_32_completitud_no_incluye_futuras_ni_versiones(self):
        from casos_sql import COMPLETENESS_SQL
        actual=self.db.execute(translate(COMPLETENESS_SQL)).fetchone()[0]
        self.assertAlmostEqual(actual,100*21/22,places=8)

    def test_33_cobertura_becas_separa_desconocidos(self):
        day='2026-09-15';students=set();known=set();positive=set()
        for i in self.fixture['tablas']['trx_inscripcion']:
          c=self.ref.by['est_curso'][i['id_curso']]
          if c['id_ciclo']!=2026 or not i['fecha_inicio']<=day<=(i['fecha_fin'] or '2026-11-30'):continue
          students.add(i['id_estudiante'])
          granted=[b for b in self.fixture['tablas']['trx_beca'] if b['id_inscripcion']==i['id_inscripcion']]
          if any(self.ref.active_benefit(b['id_beca'],day) for b in granted):positive.add(i['id_estudiante']);known.add(i['id_estudiante'])
          if any(z['id_curso']==i['id_curso'] and z['dominio']=='BECAS' and z['fecha_corte']==day and z['estado']=='COMPLETA' for z in self.fixture['tablas']['trx_control_carga']):known.add(i['id_estudiante'])
        self.assertEqual((len(students),len(known),len(positive)),(6,5,2))
        self.assertEqual(Fraction(len(positive),len(known)),Fraction(2,5))
        self.assertEqual(students-known,{1004})

    def test_34_retencion_por_beca_no_cambia_cohorte(self):
        r=self.ref.retention(2025);origin_becados={1001,1004}
        eligible=set(r['cohort']);continued=set(r['continued'])
        self.assertEqual(Fraction(len(continued&origin_becados),len(eligible&origin_becados)),1)
        non=eligible-origin_becados
        self.assertEqual(Fraction(len(continued&non),len(non)),Fraction(2,3))

    def test_35_segmentos_staging_creados_para_serializable(self):
        text=(ruta('CREACION_STAGING.sql')).read_text()
        for table in projections():self.assertIn('CREATE TABLE '+table+' SEGMENT CREATION IMMEDIATE AS',text)
        self.assertIn('segment_created',text.lower())

    def test_36_guardia_persistente_contra_snapshot_anterior(self):
        text=texto_cargador()
        self.assertIn('UPDATE ctl_carga_staging SET version_carga=version_carga+1',text)
        self.assertLess(text.index('UPDATE ctl_carga_staging SET version_carga=version_carga+1'),text.index('    comprobar_columna(',text.index('    -- Guardia de carga')))
        self.assertEqual(tuple(self.db.execute('SELECT id_control,version_carga FROM ctl_carga_staging').fetchone()),(1,1))

    def test_37_seleccion_no_puede_violar_mejor_nota(self):
        self.db.execute('SAVEPOINT seleccion_incorrecta')
        try:
          self.db.execute("UPDATE STG_RESULTADOS_PERIODO SET id_calificacion_seleccionada=10042,fecha_seleccion='2025-12-15 10:00:00' WHERE id_resultado=8041")
          self.assertTrue(any('SELECCION_POLITICA' in v['regla'] for v in violations(self.db)))
        finally:self.db.execute('ROLLBACK TO seleccion_incorrecta');self.db.execute('RELEASE seleccion_incorrecta')

if __name__=='__main__':
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(PackageChecks)
    result=unittest.TextTestRunner(verbosity=2).run(suite)
    details={'tests':result.testsRun,'failures':len(result.failures),'errors':len(result.errors),'skipped':len(result.skipped),'rules':len(all_rules()),'sql_cases':len(SQL_CASES),'negative_cases':len(INVALID_CASES),'sqlglot':sqlglot.__version__,'parser_limitations':['IS JSON STRICT: STRICT se omite solo en el lint local; se conserva en el SQL Oracle.','SEGMENT CREATION IMMEDIATE: se conserva y se comprueba por separado; no lo analiza SQLGlot.','PL/SQL no compilado por este parser.'],'oracle_executed':False}
    ruta('resultado_ultima_revision.json').parent.mkdir(parents=True,exist_ok=True)
    (ruta('resultado_ultima_revision.json')).write_text(json.dumps(details,indent=2)+'\n')
    raise SystemExit(0 if result.wasSuccessful() else 1)
