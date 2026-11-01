# Staging

Copia de los datos de operación preparada para BI. Explicación corta en `Staging_en_resumen.md`.

| Archivo | Qué hace |
|---|---|
| `Staging_en_resumen.md` | Explicación corta de staging. |
| `Diccionario_Staging.md` | Cada tabla y campo de staging. |
| `CREACION_STAGING.sql` | Crea las 29 tablas STG y la tabla técnica `ctl_carga_staging`, que evita dos cargas a la vez. |
| `modelo_staging.json`, `control_tecnico.json` | Definición de staging en formato de datos. Se generan; no editar a mano. |
