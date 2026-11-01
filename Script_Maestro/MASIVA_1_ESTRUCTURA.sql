-- =====================================================================
-- MASIVA_1_ESTRUCTURA.sql  -  Modo masiva desde Windows (parte 1 de 2)
-- Crea el OLTP vacio (DDL del equipo) y revisa que este listo para la carga.
-- Ejecutar conectado como el usuario del proyecto (usuario recien creado y vacio):
--   @MASIVA_1_ESTRUCTURA.sql  (desde la carpeta Script_Maestro)
-- Despues: doble clic en Script_Maestro\carga_masiva\cargar.bat
-- =====================================================================
SET DEFINE OFF
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

@@comprobar_permisos.sql

PROMPT ==== 1/2 Estructura transaccional (OLTP)
@@../General/SCRIPT_BASE.sql

PROMPT ==== 2/2 Revision previa a la carga masiva
@@carga_masiva/pre_carga.sql

PROMPT Parte 1 terminada. Ahora ejecute Script_Maestro\carga_masiva\cargar.bat
