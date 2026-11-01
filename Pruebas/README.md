# Pruebas

Pruebas en Oracle y generadores en Python.

| Archivo | Qué hace |
|---|---|
| `PRUEBAS_ORACLE.sql` | 15 casos con resultado esperado sobre los datos de ejemplo. |
| `PRUEBAS_NEGATIVAS_ORACLE.sql` | 17 datos inválidos que deben detectarse. Solo sin las validaciones instaladas. |
| `CARGA_Y_PRUEBA_VALIDACIONES.sql` | Carga un colegio y comprueba que las validaciones rechacen 19 errores y den 3 avisos. |
| `datos/` | Datos de ejemplo, catálogo de reglas y casos inválidos (JSON). Se generan. |

## scripts/

Se corren desde esta carpeta con Python 3 (`pip install -r requirements.txt`). Generan los scripts SQL a partir de `General/modelo_logico.json`. Si cambias el modelo, regenera todo en este orden:

```
python construir_datos.py && python contrato_staging.py && python generar_sql.py \
  && python casos_sql.py && python casos_invalidos.py && python sincronizar_validaciones.py \
  && python generar_reglas_por_tabla.py && python generar_prueba_carga.py
```

Después corre `python regresiones.py` y `python comprobar_paquete.py`: los dos deben terminar en `OK`.

| Archivo | Qué hace |
|---|---|
| `construir_datos.py` | Genera los datos de ejemplo. |
| `contrato_staging.py` | Define staging y el catálogo de reglas. |
| `generar_sql.py` | Genera los scripts SQL del OLTP y de staging, y el diccionario de staging. |
| `casos_sql.py`, `casos_invalidos.py` | Generan `PRUEBAS_ORACLE.sql` y `PRUEBAS_NEGATIVAS_ORACLE.sql`. |
| `generar_prueba_carga.py` | Genera `CARGA_Y_PRUEBA_VALIDACIONES.sql`. |
| `generar_reglas_por_tabla.py` | Genera `Validacion/Reglas_por_tabla.md`. |
| `generar_carga_masiva.py` | Genera los CSV de la carga masiva. |
| `sincronizar_validaciones.py` | Copia las reglas del catálogo a `Validacion/09_CATALOGO_REGLAS.sql` y al cargador. |
| `regresiones.py`, `comprobar_paquete.py` | Pruebas rápidas del paquete. |
| `revisar_tres_veces.py` | Tres revisiones completas seguidas; deja los registros en `Pruebas/resultados/` (no se suben a git). |
| `validacion_local.py` | Réplica en SQLite que usan las pruebas. |
| `rutas.py` | Dónde está cada archivo del proyecto. |
| `requirements.txt` | Dependencias de Python. |
