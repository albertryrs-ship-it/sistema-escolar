"""Tres revisiones completas, cada una en procesos nuevos y con evidencia."""
import hashlib,json,subprocess,sys
from pathlib import Path

from rutas import ROOT,ruta
FOCUS=['Estructura, tipos, claves y correspondencia entre origen y staging.',
       'Datos sintéticos, cortes, promedios y resultados esperados de KPI.',
       'Regresión integrada, SQL Oracle, errores, transacciones y documentación.']

def main():
    results=[];ruta('tres_revisiones.json').parent.mkdir(parents=True,exist_ok=True)
    for number,focus in enumerate(FOCUS,1):
      log=[]
      for name in ['regresiones.py','comprobar_paquete.py']:
        p=subprocess.run([sys.executable,str(Path(__file__).resolve().parent/name)],cwd=ROOT,text=True,capture_output=True)
        log.append(p.stdout+p.stderr)
        if p.returncode:
          ruta(f'revision_{number}.log').write_text('\n'.join(log))
          print('Fallo en revisión',number,name);print((p.stdout+p.stderr)[-2500:]);return 1
      details=json.loads((ruta('resultado_ultima_revision.json')).read_text())
      details.update({'revision':number,'focus':focus,'regression_tests':7,'total_test_groups':details['tests']+7})
      results.append(details)
      ruta(f'revision_{number}.log').write_text('\n'.join(log))
      print('Revisión',number,':',details['total_test_groups'],'grupos correctos,',details['rules'],'reglas,',details['sql_cases'],'casos SQL y',details['negative_cases'],'negativos; Oracle no ejecutado.')
    (ruta('tres_revisiones.json')).write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n')
    return 0

if __name__=='__main__':raise SystemExit(main())
