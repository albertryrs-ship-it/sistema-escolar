"""Copia a los archivos de Validacion/ el SQL, la descripción y la severidad de las reglas del catálogo.

Las validaciones se mantienen a mano, pero sus reglas del catálogo deben ser idénticas a contrato_staging.all_rules():
actualiza cada INSERT INTO val_regla (09_CATALOGO_REGLAS.sql) y cada comprobar_regla(...) (07_CARGADOR_STAGING.sql).
No agrega ni quita reglas.
"""
import re

from contrato_staging import all_rules
from rutas import archivos_validaciones


def sincronizar():
    esc=lambda s:s.replace("'","''")
    reglas={r['id']:r for r in all_rules()};cambios=set()
    for p in archivos_validaciones():
        lineas=p.read_text().split('\n');antes=list(lineas)
        for k,l in enumerate(lineas):
            m=re.match(r"INSERT INTO val_regla VALUES \('([^']+)','[A-Z]+','[^']+','[A-Z]+','(?:[^']|'')*','(?:[^']|'')*'\);$",l)
            if m and m.group(1) in reglas:
                r=reglas[m.group(1)]
                nueva=f"INSERT INTO val_regla VALUES ('{r['id']}','{r['layer']}','{r['table']}','{r['severity']}','{esc(r['description'])}','{esc(r['sql'])}');"
                if nueva!=l:lineas[k]=nueva;cambios.add(r['id'])
            m=re.match(r"(\s*comprobar_regla\('([^']+)','[^']+',q'~)(.*?)(~',q'~.*)$",l)
            if m and m.group(2) in reglas and m.group(3)!=reglas[m.group(2)]['sql']:
                lineas[k]=m.group(1)+reglas[m.group(2)]['sql']+m.group(4);cambios.add(m.group(2))
        if lineas!=antes:p.write_text('\n'.join(lineas))
    return sorted(cambios)


if __name__=='__main__':
    c=sincronizar()
    print('Validacion/:',len(c),'reglas actualizadas',c if c else '')
