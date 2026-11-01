-- Carga masiva desde SQL*Plus o SQLcl (paso 2 de INSTALACION_COMPLETA.sql).
-- HOST usa la carpeta desde la que se abrió SQL*Plus: debe ser Script_Maestro.
-- cargar.sh necesita ORACLE_CONN exportada y los CSV generados. Si falla, post_carga.sql
-- lo detecta por los conteos y detiene la instalación.
@@pre_carga.sql
HOST bash carga_masiva/cargar.sh
@@post_carga.sql
