-- ==============================================================
-- SECCIÓN 3: TABLAS DE TRABAJO DEL ETL
-- Descripción: Tablas WK_ETL_* donde el 03 guarda, en cada corrida, las filas válidas y los cálculos intermedios.
--   Existen por rendimiento: sin ellas Oracle recalculaba las validaciones dentro del MERGE (ver README).
--   No guardan datos propios: se borran y se vuelven a crear vacías en cada instalación.
-- ==============================================================

-- Se ejecuta desde INSTALAR_MODELO_ESTRELLA.sql, que fija las opciones de la sesión.

-- === Borrar las tablas de trabajo anteriores ===
-- Guardan una sola vez las filas validas de inscripciones, calificaciones y asistencias,
-- y el resultado de la transformacion. Asi Oracle no recalcula las validaciones anidadas
-- dentro del MERGE de hechos. El 03 las vacia y las llena en cada corrida.
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
             WHERE table_name IN ('WK_ETL_INS', 'WK_ETL_CAL', 'WK_ETL_ASI', 'WK_ETL_SES_RAW', 'WK_ETL_PP', 'WK_ETL_AD', 'WK_ETL_CA', 'WK_ETL_SES', 'WK_ETL_ASIST', 'WK_ETL_HECHOS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' PURGE';
  END LOOP;
END;
/

-- === WK_ETL_INS ===
CREATE TABLE wk_etl_ins AS SELECT * FROM vw_etl_val_inscripciones WHERE 1 = 0;
CREATE TABLE wk_etl_cal AS SELECT * FROM vw_etl_val_calificaciones WHERE 1 = 0;
CREATE TABLE wk_etl_asi AS
  SELECT id_asistencia, id_inscripcion, id_sesion, estado FROM vw_etl_val_asistencias WHERE 1 = 0;

-- === WK_ETL_SES_RAW ===
-- Sesiones impartidas con su curso. El indice del staging es solo por id_ejecucion_carga y
-- Oracle estima casi costo cero al leerlo, asi que al unir tablas de staging elegia NESTED LOOPS
-- que releian las 252 mil sesiones por cada inscripcion o ponderacion (planes de 79G y 6190M filas).
-- Por eso cada tabla de staging se copia primero sola (sin uniones) a una tabla de trabajo con
-- estadisticas, y las uniones se hacen entre tablas de trabajo con HASH JOIN.
CREATE TABLE wk_etl_ses_raw AS
  SELECT id_sesion, id_ponderacion_periodo, fecha_academica FROM vw_etl_stg_sesiones WHERE 1 = 0;
CREATE TABLE wk_etl_pp AS
  SELECT id_ponderacion_periodo, id_curso_asignatura, id_periodo, peso FROM vw_etl_stg_ponderaciones WHERE 1 = 0;
CREATE TABLE wk_etl_ad AS
  SELECT id_asignacion, id_docente FROM vw_etl_stg_asignaciones_docentes WHERE 1 = 0;
CREATE TABLE wk_etl_ca AS
  SELECT id_curso_asignatura, id_curso FROM vw_etl_stg_cursos_asignaturas WHERE 1 = 0;

-- === VW_ETL_SES_CALC ===
CREATE OR REPLACE VIEW vw_etl_ses_calc AS
SELECT /*+ LEADING(s pp ca) USE_HASH(pp) USE_HASH(ca) */
       s.id_sesion, s.id_ponderacion_periodo, s.fecha_academica, ca.id_curso
  FROM wk_etl_ses_raw s
  JOIN wk_etl_pp pp ON pp.id_ponderacion_periodo = s.id_ponderacion_periodo
  JOIN wk_etl_ca ca ON ca.id_curso_asignatura = pp.id_curso_asignatura;

CREATE TABLE wk_etl_ses AS SELECT * FROM vw_etl_ses_calc WHERE 1 = 0;

-- === VW_ETL_ASIST_CALC ===
-- Asistencia: sesiones impartidas que le correspondian a cada inscripcion y cuantas asistio.
-- Es el calculo mas pesado (cruza con ~3.1 millones de asistencias); el 03 lo guarda en wk_etl_asist.
CREATE OR REPLACE VIEW vw_etl_asist_calc AS
SELECT /*+ LEADING(i s a) USE_HASH(s) USE_HASH(a) */
       i.id_inscripcion, s.id_ponderacion_periodo,
       COUNT(*) AS aplicables,
       COUNT(a.id_asistencia) AS registradas,
       SUM(CASE WHEN a.estado IN ('PRESENTE', 'TARDE') THEN 1 ELSE 0 END) AS presencias
  FROM wk_etl_ins i
  JOIN wk_etl_ses s      ON s.id_curso = i.id_curso
  LEFT JOIN wk_etl_asi a ON a.id_inscripcion = i.id_inscripcion AND a.id_sesion = s.id_sesion
 WHERE s.fecha_academica BETWEEN i.fecha_inicio AND NVL(i.fecha_fin, DATE '9999-12-31')
 GROUP BY i.id_inscripcion, s.id_ponderacion_periodo;

CREATE TABLE wk_etl_asist AS SELECT * FROM vw_etl_asist_calc WHERE 1 = 0;
