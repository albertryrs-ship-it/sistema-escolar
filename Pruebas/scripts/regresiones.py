import argparse,json,re,unittest
from pathlib import Path

from rutas import ROOT as DEFAULT,ruta,texto_cargador
parser=argparse.ArgumentParser();parser.add_argument('--root',type=Path,default=DEFAULT)
args,_=parser.parse_known_args();ROOT=args.root

class Regresiones(unittest.TestCase):
    def test_fechas_recuperacion_conservadas_en_staging(self):
        sql=(ruta('CREACION_STAGING.sql',ROOT)).read_text().upper()
        block=re.search(r'CREATE TABLE STG_PLAZOS_NOTAS\b(.*?)(?:WHERE 1\s*=\s*0|;)',sql,re.S)
        self.assertIsNotNone(block)
        self.assertIn('FECHA_INICIO_RECUPERACION',block.group(1))
        self.assertIn('FECHA_FIN_RECUPERACION',block.group(1))

    def test_carga_utiliza_columnas_explicitas(self):
        sql=re.sub(r'--[^\n]*','',texto_cargador(ROOT))
        self.assertNotRegex(sql,r'(?is)INSERT\s+INTO\s+STG_\w+\s+SELECT\s+\*')

    def test_carga_se_detiene_y_revierte_ante_error(self):
        sql=(ruta('INSTALAR_VALIDACIONES.sql',ROOT)).read_text().upper()
        self.assertIn('WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK',sql)
        self.assertIn('WHENEVER OSERROR EXIT FAILURE ROLLBACK',sql)

    def test_semilla_con_fechas_reproducibles(self):
        code=re.sub(r'--[^\n]*','',(ruta('DATOS_FICTICIOS.sql',ROOT)).read_text()).upper()
        self.assertNotIn('SYSTIMESTAMP',code)
        self.assertNotIn('SYSDATE',code)

    def test_contrato_de_intentos_acordado(self):
        p=ruta('modelo_logico.json',ROOT)
        s=json.loads(p.read_text())
        f=next(f for f in s['trx_calificacion']['fields'] if f['name']=='numero_intento')
        self.assertIn('1 para la ordinaria',f['description'])
        self.assertIn('2 o más',f['description'])

    def test_estructura_operacional_conservada(self):
        p=ruta('modelo_logico.json',ROOT)
        s=json.loads(p.read_text())
        self.assertEqual(len(s),33)
        self.assertEqual(sum(len(t['fields']) for t in s.values()),235)
    def test_perfil_de_columnas_coincide_con_el_contrato(self):
        # Cada comprobar_columna generado debe repetir tipo, precisión, escala, longitud y nulabilidad del contrato.
        oltp=json.loads(ruta('modelo_logico.json',ROOT).read_text())
        stg=json.loads(ruta('modelo_staging.json',ROOT).read_text())
        types={(t.lower(),f['name']):(f['oracle_type'],f['nullable']) for src in (oltp,stg) for t,d in src.items() for f in d['fields']}
        def expected(typ):
            m=re.fullmatch(r'NUMBER\((\d+)(?:,(\d+))?\)',typ)
            if m:return ('NUMBER',m.group(1),m.group(2) or '0','NULL')
            m=re.fullmatch(r'VARCHAR2\((\d+) CHAR\)',typ)
            if m:return ('VARCHAR2','NULL','NULL',m.group(1))
            return (typ,'NULL','NULL','NULL')
        for name,texto in [('CREACION_STAGING.sql',ruta('CREACION_STAGING.sql',ROOT).read_text()),('pr_cargar_staging',texto_cargador(ROOT))]:
            calls=re.findall(r"comprobar_columna\('(\w+)',\w+,'(\w+)','([^']+)',(\w+),(\w+),(\w+),'([YN])'\)",texto)
            self.assertGreater(len(calls),400,name)
            for table,col,typ,prec,scale,length,null in calls:
                if (table.lower(),col) not in types:continue
                otyp,nullable=types[(table.lower(),col)]
                self.assertEqual((typ,prec,scale,length),expected(otyp),(name,table,col))
                self.assertEqual(null,'Y' if nullable else 'N',(name,table,col))

if __name__=='__main__':
    unittest.main(argv=['regresiones'],verbosity=2)
