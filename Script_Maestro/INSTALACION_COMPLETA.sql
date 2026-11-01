-- INSTALACION_COMPLETA.sql | Instala el modelo completo en un esquema VACÍO de pruebas.
-- Ejecutar desde la carpeta Script_Maestro, en SQL*Plus o SQLcl (instrucciones en README.md):
--   @INSTALACION_COMPLETA.sql ficticios   semilla pequeña y pruebas de resultados esperados
--   @INSTALACION_COMPLETA.sql masiva      42 colegios con SQL*Loader; antes generar los CSV
--                                        (python ../Pruebas/scripts/generar_carga_masiva.py) y exportar
--                                        ORACLE_CONN=usuario/clave@//host:puerto/servicio en la terminal.
-- Orden: OLTP, datos, estructura staging, validaciones, carga staging, diagnóstico, pruebas, data mart
-- (calendario, modelo estrella y ETL), vistas materializadas y expedientes JSON firmados.
-- - Los datos van antes de crear staging, porque las secuencias ETL arrancan sobre los máximos existentes,
--   y antes de las validaciones, que al instalarse revisan todos los datos con las reglas BLOQUEO.
-- - Staging se crea antes de las validaciones: sus triggers y PR_CARGAR_STAGING dependen de las STG.
-- Se detiene en el primer error. El registro queda en instalacion_<modo>.log.
SET DEFINE ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
DEFINE modo=&1
SPOOL instalacion_&modo..log

BEGIN
 IF '&modo' NOT IN ('ficticios','masiva') THEN
  RAISE_APPLICATION_ERROR(-20090,'Modo invalido: usar ficticios o masiva.');
 END IF;
END;
/
COLUMN datos NEW_VALUE script_datos NOPRINT
COLUMN pruebas NEW_VALUE script_pruebas NOPRINT
SELECT DECODE('&modo','masiva','carga_masiva/carga_masiva.sql','datos_ficticios/DATOS_FICTICIOS.sql') datos,
       DECODE('&modo','masiva','pruebas_masiva.sql','pruebas_ficticios.sql') pruebas FROM dual;
COLUMN hora FORMAT A30 HEADING 'Hora'
@@comprobar_permisos.sql

PROMPT ==== 1/12 Estructura transaccional (OLTP)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../General/SCRIPT_BASE.sql

PROMPT ==== 2/12 Carga de datos
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
SET DEFINE ON
@@&script_datos

PROMPT ==== 3/12 Estructura staging
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Staging/CREACION_STAGING.sql

PROMPT ==== 4/12 Validaciones (reglas, triggers y procedimientos; revisa todos los datos al terminar)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Validacion/INSTALAR_VALIDACIONES.sql

PROMPT ==== 5/12 Carga de staging
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
EXEC pr_cargar_staging;

PROMPT ==== 6/12 Diagnóstico
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
EXEC pr_diagnosticar_validaciones;
EXEC pr_diagnosticar_validaciones('STAGING');
@@../Validacion/VALIDAR_MODELOS.sql

PROMPT ==== 7/12 Pruebas
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
SET DEFINE ON
@@&script_pruebas

PROMPT ==== 8/12 Data mart: calendario (DIM_TIEMPO)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Data_Mart/01_CALENDARIO.sql

PROMPT ==== 9/12 Data mart: modelo estrella (dimensiones, hechos, tablas de trabajo y triggers de auditoría)
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Data_Mart/02_MODELO_ESTRELLA/INSTALAR_MODELO_ESTRELLA.sql

PROMPT ==== 10/12 Data mart: ETL de staging al modelo estrella
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Data_Mart/03_ETL_CARGA_ESTRELLA.sql

PROMPT ==== 11/12 Vistas materializadas
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Vistas_Materializadas/INSTALAR_VISTAS.sql

PROMPT ==== 12/12 Expedientes académicos JSON firmados
SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Data_Mart/05_EXPEDIENTE_JSON.sql

SELECT TO_CHAR(LOCALTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
PROMPT Instalación completa terminada.
SPOOL OFF
