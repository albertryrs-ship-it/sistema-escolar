-- =====================================================================
-- Data_Mart/04_REHACER_ESTRELLA.sql
-- Vuelve a instalar el modelo estrella (02_MODELO_ESTRELLA/), lo llena con el ETL (03) y
-- vuelve a crear las vistas materializadas (Vistas_Materializadas/INSTALAR_VISTAS.sql).
-- No toca el OLTP ni el staging. Ejecutar como el usuario del proyecto, desde la carpeta Data_Mart:
--   @04_REHACER_ESTRELLA.sql
-- =====================================================================
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
COLUMN hora FORMAT A30 HEADING 'Hora'

-- Cierra como ERROR las ejecuciones del data mart que quedaron abiertas por una cancelacion
UPDATE auditoria_etl_evaluaciones
   SET estado = 'ERROR', fin = LOCALTIMESTAMP
 WHERE estado = 'EN_PROCESO' AND fuente LIKE 'Data_Mart/03%';
COMMIT;

SELECT TO_CHAR(LOCALTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@02_MODELO_ESTRELLA/INSTALAR_MODELO_ESTRELLA.sql
SELECT TO_CHAR(LOCALTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@03_ETL_CARGA_ESTRELLA.sql
SELECT TO_CHAR(LOCALTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
@@../Vistas_Materializadas/INSTALAR_VISTAS.sql
SELECT TO_CHAR(LOCALTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') hora FROM dual;
PROMPT Modelo estrella listo.
