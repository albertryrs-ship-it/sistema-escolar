-- =====================================================================
-- Vistas_Materializadas/REFRESCO.sql
-- PR_REFRESCAR_VISTAS_DM refresca las cinco vistas (completo) y muestra cuanto tardo cada una.
-- Data_Mart/03_ETL_CARGA_ESTRELLA.sql la llama al terminar, si existe.
-- JOB_REFRESCAR_VISTAS_DM (DBMS_SCHEDULER) la ejecuta todos los dias a las 02:00 como respaldo.
-- Re-ejecutable: reemplaza el procedimiento y vuelve a crear el job.
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- 1. PROCEDIMIENTO DE REFRESCO
CREATE OR REPLACE PROCEDURE pr_refrescar_vistas_dm AS
  TYPE t_lista IS TABLE OF VARCHAR2(30);
  v_mvs    t_lista := t_lista('MV_RENDIMIENTO_POR_DOCENTE', 'MV_PROMEDIO_ASIGNATURAS',
                              'MV_ASISTENCIA_ESTUDIANTES', 'MV_ALERTA_RIESGO',
                              'MV_PROGRESO_ACADEMICO');
  v_inicio TIMESTAMP;
  v_total  TIMESTAMP := LOCALTIMESTAMP;
BEGIN
  FOR i IN 1 .. v_mvs.COUNT LOOP
    v_inicio := LOCALTIMESTAMP;
    -- 'C' = completo; atomic_refresh FALSE: TRUNCATE + INSERT directo, mas rapido que DELETE
    DBMS_MVIEW.REFRESH(list => v_mvs(i), method => 'C', atomic_refresh => FALSE);
    DBMS_OUTPUT.PUT_LINE(RPAD(v_mvs(i), 30) || ' refrescada en '
                         || TO_CHAR(EXTRACT(SECOND FROM (LOCALTIMESTAMP - v_inicio))
                                    + 60 * EXTRACT(MINUTE FROM (LOCALTIMESTAMP - v_inicio)), 'FM9990.00')
                         || ' s');
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Vistas materializadas refrescadas. Total: '
                       || TO_CHAR(EXTRACT(SECOND FROM (LOCALTIMESTAMP - v_total))
                                  + 60 * EXTRACT(MINUTE FROM (LOCALTIMESTAMP - v_total)), 'FM9990.00')
                       || ' s');
END pr_refrescar_vistas_dm;
/
SHOW ERRORS PROCEDURE pr_refrescar_vistas_dm

-- 2. JOB DE RESPALDO: todos los dias a las 02:00
BEGIN
  FOR j IN (SELECT job_name FROM user_scheduler_jobs WHERE job_name = 'JOB_REFRESCAR_VISTAS_DM') LOOP
    DBMS_SCHEDULER.DROP_JOB(j.job_name, force => TRUE);
  END LOOP;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'JOB_REFRESCAR_VISTAS_DM',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'PR_REFRESCAR_VISTAS_DM',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Refresco completo de las 5 vistas materializadas del data mart (respaldo del 03)');
END;
/

