-- =====================================================================
-- Vistas_Materializadas/INSTALAR_VISTAS.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- Cinco vistas materializadas sobre el modelo estrella:
--   1. MV_RENDIMIENTO_POR_DOCENTE   desempeno de los estudiantes de cada docente
--   2. MV_PROMEDIO_ASIGNATURAS      estadisticas de notas por asignatura y grado
--   3. MV_ASISTENCIA_ESTUDIANTES    asistencia por estudiante (NIE) y periodo
--   4. MV_ALERTA_RIESGO             estudiantes que necesitan apoyo, con nivel de alerta
--   5. MV_PROGRESO_ACADEMICO        promedio anual por asignatura contra el anio anterior
--
-- Estrategia de refresco:
--   - BUILD IMMEDIATE: se llenan al crearlas.
--   - REFRESH COMPLETE ON DEMAND: el modelo estrella se carga por lotes (ETL), no fila
--     por fila, y las vistas usan funciones analiticas (RANK, LAG) y MEDIAN, que no
--     admiten refresco rapido (FAST). Se recalculan completas despues de cada ETL.
--   - PR_REFRESCAR_VISTAS_DM refresca las cinco y muestra cuanto tardo cada una.
--     El 03_ETL_CARGA_ESTRELLA.sql la llama al terminar, si existe.
--   - JOB_REFRESCAR_VISTAS_DM (DBMS_SCHEDULER) la ejecuta todos los dias a las 02:00
--     como respaldo, por si alguien carga datos sin pasar por el 03.
--
-- Requiere: Data_Mart/02_MODELO_ESTRELLA/ y Data_Mart/03 ejecutados (modelo estrella con datos). Ejecutar como el usuario del proyecto:
--   @INSTALAR_VISTAS.sql  (desde esta carpeta; el script maestro lo ejecuta en su paso 11)
-- Re-ejecutable: vuelve a crear las vistas, el procedimiento y el job (no guardan datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'HECHOS_RESULTADOS';
  IF n = 0 THEN
    RAISE_APPLICATION_ERROR(-20120, 'Falta HECHOS_RESULTADOS: ejecute primero Data_Mart/02 y 03.');
  END IF;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM hechos_resultados' INTO n;
  IF n = 0 THEN
    RAISE_APPLICATION_ERROR(-20121, 'HECHOS_RESULTADOS esta vacia: ejecute primero Data_Mart/03_ETL_CARGA_ESTRELLA.sql');
  END IF;
END;
/

@@MV_RENDIMIENTO_POR_DOCENTE.sql
@@MV_PROMEDIO_ASIGNATURAS.sql
@@MV_ASISTENCIA_ESTUDIANTES.sql
@@MV_ALERTA_RIESGO.sql
@@MV_PROGRESO_ACADEMICO.sql
@@REFRESCO.sql

-- VERIFICACION
COLUMN mview_name FORMAT A28
COLUMN refresh_method FORMAT A8
COLUMN refresh_mode FORMAT A8
COLUMN staleness FORMAT A12
SELECT mview_name, refresh_mode, refresh_method, staleness,
       TO_CHAR(last_refresh_date, 'YYYY-MM-DD HH24:MI:SS') AS ultimo_refresco
  FROM user_mviews
 ORDER BY mview_name;

SELECT 'MV_RENDIMIENTO_POR_DOCENTE' AS vista, COUNT(*) AS filas FROM mv_rendimiento_por_docente
UNION ALL SELECT 'MV_PROMEDIO_ASIGNATURAS', COUNT(*) FROM mv_promedio_asignaturas
UNION ALL SELECT 'MV_ASISTENCIA_ESTUDIANTES', COUNT(*) FROM mv_asistencia_estudiantes
UNION ALL SELECT 'MV_ALERTA_RIESGO', COUNT(*) FROM mv_alerta_riesgo
UNION ALL SELECT 'MV_PROGRESO_ACADEMICO', COUNT(*) FROM mv_progreso_academico;

-- Muestras
COLUMN docente FORMAT A30
COLUMN asignatura FORMAT A25
PROMPT Top 5 docentes por promedio (ultimo anio, periodo 1)
SELECT docente, asignatura, anio, periodo_numero, estudiantes, promedio, pct_aprobados, pct_asistencia
  FROM mv_rendimiento_por_docente
 WHERE anio = (SELECT MAX(anio) FROM mv_rendimiento_por_docente) AND periodo_numero = 1
 ORDER BY promedio DESC
 FETCH FIRST 5 ROWS ONLY;

PROMPT Alertas por nivel y anio
SELECT anio, nivel_alerta, COUNT(*) AS casos, COUNT(DISTINCT sk_estudiante) AS estudiantes
  FROM mv_alerta_riesgo
 GROUP BY anio, nivel_alerta, orden_alerta
 ORDER BY anio, orden_alerta;

PROMPT Tendencia del progreso academico (anio con comparacion)
SELECT anio, tendencia, COUNT(*) AS estudiante_asignatura
  FROM mv_progreso_academico
 GROUP BY anio, tendencia
 ORDER BY anio, tendencia;

PROMPT Prueba del procedimiento de refresco
EXEC pr_refrescar_vistas_dm;
