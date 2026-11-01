-- =====================================================================
-- Data_Mart/07_PERMISOS_OPTIMIZACION_SYSTEM.sql
-- Ejecutar UNA VEZ como administrador (por ejemplo SYSTEM), conectado a la misma base (PDB)
-- donde está instalado el proyecto, antes de 08_OPTIMIZACION.sql.
-- Da al usuario del proyecto permiso para leer los planes de ejecucion reales (V$SQL,
-- V$SQL_PLAN_STATISTICS_ALL) que usan DBMS_XPLAN.DISPLAY_CURSOR(..., 'ALLSTATS LAST').
-- Pide el nombre del usuario del proyecto al ejecutarse.
-- =====================================================================
SET VERIFY OFF
ACCEPT usuario CHAR PROMPT 'Usuario del proyecto: '

GRANT SELECT ANY DICTIONARY TO &usuario;

SELECT grantee, privilege FROM dba_sys_privs
 WHERE grantee = UPPER('&usuario') AND privilege = 'SELECT ANY DICTIONARY';
