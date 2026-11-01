# Validación

Reglas que impiden guardar datos incoherentes. Explicación corta en `Reglas_principales.md`; todas, tabla por tabla, en `Reglas_por_tabla.md`.

## Instalación

El script maestro las instala en su paso 4. Para instalarlas a mano, sobre un OLTP y un staging ya creados, desde esta carpeta:

```
@INSTALAR_VALIDACIONES.sql
```

Se instalan una sola vez por base: no borran ni corrigen datos, y al terminar revisan todos los datos existentes con las reglas que bloquean.

## Archivos

Cada archivo tiene un solo tipo de objeto y depende solo de los anteriores. Dentro de cada procedimiento y trigger hay un comentario que dice qué hace y qué reglas revisa: se ve al abrirlo en SQL Developer.

| Archivo | Qué contiene |
|---|---|
| `INSTALAR_VALIDACIONES.sql` | Ejecuta los demás en orden. Es el único que se llama. |
| `00_PREVALIDACION.sql` | Revisa la sesión, que no existan objetos con los mismos nombres y que el OLTP tenga las columnas y tipos esperados. No crea nada. |
| `01_TABLAS_CONTROL.sql` | Las 8 tablas propias: catálogo de reglas (`val_regla`), auditoría de cambios (`val_cambio`), política, guardia, incidencias y entradas. |
| `02_RESTRICCIONES.sql` | 44 `CHECK` adicionales (textos no vacíos y condiciones de una fila), cada uno con su descripción. |
| `03_PROCEDIMIENTOS_BASE.sql` | El motor: `pr_validar_operacion`, `pr_diagnosticar_validaciones`, `pr_recalcular_alcance`, la guardia y las funciones de limpieza. |
| `04_TRIGGERS_OLTP.sql` | 31 triggers `trg_val_<tabla>`, uno por tabla, con la lista de reglas que revisa cada uno. |
| `05_CONSULTAS.sql` | 11 vistas de pendientes y avisos (`vw_notas_pendientes`, `vw_avisos_calidad`…) y procedimientos de consulta. |
| `06_OPERACIONES.sql` | Procedimientos de negocio: guardar registro, publicar plan, trasladar, registrar y corregir notas, becas, cerrar y reabrir ciclos, permisos. |
| `07_CARGADOR_STAGING.sql` | `pr_cargar_staging` y los 29 triggers `trg_stg_<tabla>_inmutable` que impiden editar las copias. |
| `08_PRUEBAS.sql` | `pr_probar_validaciones`. Se instala, pero solo se ejecuta en un esquema de pruebas. |
| `09_CATALOGO_REGLAS.sql` | Los datos: 913 reglas, 424 coberturas del DDL, guardia y política. |
| `10_VERIFICACION.sql` | Calcula a qué tablas afecta cada regla, revisa la compilación y valida los datos existentes. |
| `VALIDAR_MODELOS.sql` | Aparte: revisa las 837 reglas del contrato sobre los datos existentes sin modificar nada. Funciona con o sin las validaciones instaladas. Las otras 76 del catálogo (67 de texto no vacío y 9 propias de las validaciones) las revisa `pr_diagnosticar_validaciones`. |
| `Reglas_principales.md` | Las reglas de negocio importantes, en corto. |
| `Reglas_por_tabla.md` | Todas las reglas (913), tabla por tabla, y cómo se aplica cada una. Se genera con `Pruebas/scripts/generar_reglas_por_tabla.py`. |

## Después de instalar

| Para… | Ejecutar |
|---|---|
| Copiar el OLTP a staging | `EXEC pr_cargar_staging;` |
| Revisar todas las reglas sin bloquear | `EXEC pr_diagnosticar_validaciones;` y luego `SELECT * FROM vw_avisos_calidad;` |
| Ver una regla | `SELECT * FROM val_regla WHERE id_regla = 'OPERACION_INSCRIPCIONES_SOLAPADAS';` |
| Ver qué reglas revisa un trigger | Abrir el trigger en SQL Developer, o `SELECT text FROM user_source WHERE name = 'TRG_VAL_TRX_CALIFICACION' ORDER BY line;` |
| Probar las validaciones (solo esquema de pruebas) | `EXEC pr_probar_validaciones;` |
