-- =====================================================================
-- MASIVA_2_STAGING_Y_ESTRELLA.sql  -  Modo masiva desde Windows (parte 2 de 2)
-- Despues de cargar.bat: verifica conteos, crea staging y validaciones, carga
-- el staging, crea y llena el modelo estrella, las vistas
-- materializadas y los expedientes JSON.
-- Ejecutar conectado como el usuario del proyecto:
--   @MASIVA_2_STAGING_Y_ESTRELLA.sql  (desde la carpeta Script_Maestro)
-- Tarda varios minutos (unos 4 millones de filas).
-- =====================================================================
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
COLUMN hora FORMAT A30 HEADING 'Hora'

PROMPT ==== 1/6 Verificacion de la carga masiva (conteos y estadisticas)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@carga_masiva/post_carga.sql

PROMPT ==== 2/6 Estructura staging
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Staging/CREACION_STAGING.sql

PROMPT ==== 3/6 Validaciones (reglas, triggers y procedimientos)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
SET DEFINE ON
@@../Validacion/INSTALAR_VALIDACIONES.sql

PROMPT ==== 4/6 Carga de staging
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
EXEC pr_cargar_staging;

PROMPT ==== 5/6 Diagnostico
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
EXEC pr_diagnosticar_validaciones;
EXEC pr_diagnosticar_validaciones('STAGING');

PROMPT ==== 6/6 Data mart: calendario, modelo estrella y ETL
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Data_Mart/01_CALENDARIO.sql
@@../Data_Mart/02_MODELO_ESTRELLA/INSTALAR_MODELO_ESTRELLA.sql
@@../Data_Mart/03_ETL_CARGA_ESTRELLA.sql

PROMPT ==== Vistas materializadas y expedientes JSON
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Vistas_Materializadas/INSTALAR_VISTAS.sql
@@../Data_Mart/05_EXPEDIENTE_JSON.sql

SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
PROMPT Instalacion masiva terminada.
