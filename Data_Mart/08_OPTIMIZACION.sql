-- =====================================================================
-- Data_Mart/08_OPTIMIZACION.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- Optimizacion: mide consultas clave ANTES y DESPUES de optimizar, con estadisticas reales
-- de ejecucion (hint GATHER_PLAN_STATISTICS + DBMS_XPLAN.DISPLAY_CURSOR 'ALLSTATS LAST').
--
--   Q1  Docentes con mayor impacto (KPI)            tecnica: vista materializada
--   Q2  Notas de un estudiante por NIE              tecnica: indices (NIE y FK de hechos)
--   Q3  Estudiantes en riesgo por departamento      tecnica: vista materializada + indice
--   Q4  ETL staging -> modelo estrella              tecnica: tablas de trabajo, estadisticas
--                                                   y HASH JOIN (medido en la carga real)
--
-- Cada consulta se ejecuta dos veces y se mide la segunda (cache caliente), para comparar en
-- igualdad de condiciones. Se guardan filas (A-Rows), buffers, lecturas de disco y tiempo
-- (A-Time) en OPT_MEDICIONES, y se imprime el plan real de cada medicion.
--
-- Requiere: 02, 03 y las vistas materializadas (Vistas_Materializadas/) instalados, y 07_PERMISOS_OPTIMIZACION_SYSTEM.sql (una vez, como SYSTEM).
-- Re-ejecutable: borra los indices de Q2 al inicio para medir de nuevo el "antes".
-- Ejecutar como el usuario del proyecto:
--   @08_OPTIMIZACION.sql  (desde la carpeta Data_Mart)
-- =====================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF
SET SQLBLANKLINES ON
SET LINESIZE 250
SET PAGESIZE 200
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- ==============================================================
-- SECCIÓN 0: COMPROBACIONES Y PUNTO DE PARTIDA
-- Descripción: Requisitos y estado inicial, sin los índices nuevos.
-- ==============================================================
DECLARE
  n NUMBER;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM v$sql_plan_statistics_all WHERE ROWNUM = 1' INTO n;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20160,
        'El usuario del proyecto no puede leer los planes reales. Ejecute primero 07_PERMISOS_OPTIMIZACION_SYSTEM.sql como administrador.');
  END;
  SELECT COUNT(*) INTO n FROM user_mviews WHERE mview_name IN ('MV_RENDIMIENTO_POR_DOCENTE', 'MV_ALERTA_RIESGO');
  IF n <> 2 THEN
    RAISE_APPLICATION_ERROR(-20161, 'Faltan las vistas materializadas: ejecute Vistas_Materializadas/INSTALAR_VISTAS.sql');
  END IF;

  -- Sin los indices de la optimizacion, para que el "antes" sea real
  FOR i IN (SELECT index_name FROM user_indexes
             WHERE index_name IN ('IX_HECHOS_ESTUDIANTE', 'IX_DIM_ESTUDIANTE_NIE')) LOOP
    EXECUTE IMMEDIATE 'DROP INDEX ' || i.index_name;
  END LOOP;

  -- Estadisticas actuales del modelo (linea base justa para el optimizador)
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'HECHOS_RESULTADOS');
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'DIM_ESTUDIANTE');
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'DIM_DOCENTE');
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'DIM_ASIGNATURA');
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'DIM_CURSO');
END;
/

BEGIN
  FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN ('OPT_PLANES', 'OPT_MEDICIONES')
             ORDER BY CASE table_name WHEN 'OPT_PLANES' THEN 1 ELSE 2 END) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' PURGE';
  END LOOP;
END;
/

CREATE TABLE opt_mediciones (
    id_medicion     NUMBER GENERATED ALWAYS AS IDENTITY,
    codigo          VARCHAR2(5 CHAR)    NOT NULL,
    consulta        VARCHAR2(120 CHAR)  NOT NULL,
    fase            VARCHAR2(10 CHAR)   NOT NULL,
    tecnica         VARCHAR2(200 CHAR),
    sql_id          VARCHAR2(13),
    child_number    NUMBER,
    plan_hash_value NUMBER,
    filas           NUMBER,
    buffers         NUMBER,
    lecturas_disco  NUMBER,
    tiempo_ms       NUMBER(12,2),
    nota            VARCHAR2(400 CHAR),
    fecha           TIMESTAMP DEFAULT LOCALTIMESTAMP,
    CONSTRAINT pk_opt_mediciones PRIMARY KEY (id_medicion),
    CONSTRAINT chk_opt_fase CHECK (fase IN ('ANTES', 'DESPUES'))
);

-- El plan real se guarda en cuanto se mide: al crear un indice, Oracle invalida los cursores
-- de las consultas sobre esa tabla y el plan del ANTES ya no se podria consultar despues.
CREATE TABLE opt_planes (
    id_medicion NUMBER        NOT NULL,
    linea       NUMBER        NOT NULL,
    texto       VARCHAR2(400 CHAR),
    CONSTRAINT pk_opt_planes PRIMARY KEY (id_medicion, linea),
    CONSTRAINT fk_opt_planes_medicion FOREIGN KEY (id_medicion) REFERENCES opt_mediciones (id_medicion)
);

-- ==============================================================
-- SECCIÓN 1: PROCEDIMIENTO DE MEDICIÓN
-- Descripción: Ejecuta una consulta y guarda su plan real con ALLSTATS LAST.
-- ==============================================================
CREATE OR REPLACE PROCEDURE pr_medir_consulta (
  p_codigo   VARCHAR2,
  p_consulta VARCHAR2,
  p_fase     VARCHAR2,
  p_tecnica  VARCHAR2,
  p_sql      VARCHAR2      -- debe incluir /*+ GATHER_PLAN_STATISTICS */ y la etiqueta OPT_<codigo>_<fase>
) AS
  v_bloque  VARCHAR2(32767) := 'BEGIN FOR r IN (' || p_sql || ') LOOP NULL; END LOOP; END;';
  v_tag     VARCHAR2(40)    := 'OPT_' || p_codigo || '_' || p_fase;
  v_sql_id  VARCHAR2(13);
  v_child   NUMBER;
  v_phv     NUMBER;
  v_filas   NUMBER;
  v_buf     NUMBER;
  v_disco   NUMBER;
  v_us      NUMBER;
  v_id      NUMBER;
BEGIN
  EXECUTE IMMEDIATE v_bloque;   -- 1.a ejecucion: calienta la cache
  EXECUTE IMMEDIATE v_bloque;   -- 2.a ejecucion: la que se mide

  EXECUTE IMMEDIATE q'[
    SELECT sql_id, child_number, plan_hash_value
      FROM v$sql
     WHERE sql_text LIKE '%' || :tag || '%'
       AND command_type = 3
       AND UPPER(sql_text) NOT LIKE '%V$SQL%'
     ORDER BY last_active_time DESC
     FETCH FIRST 1 ROW ONLY]'
    INTO v_sql_id, v_child, v_phv USING v_tag;

  EXECUTE IMMEDIATE q'[
    SELECT last_output_rows, last_cr_buffer_gets + last_cu_buffer_gets, last_disk_reads, last_elapsed_time
      FROM v$sql_plan_statistics_all
     WHERE sql_id = :1 AND child_number = :2
       AND id = (SELECT MIN(id) FROM v$sql_plan_statistics_all
                  WHERE sql_id = :3 AND child_number = :4 AND last_starts IS NOT NULL)]'
    INTO v_filas, v_buf, v_disco, v_us USING v_sql_id, v_child, v_sql_id, v_child;

  INSERT INTO opt_mediciones (codigo, consulta, fase, tecnica, sql_id, child_number, plan_hash_value,
                              filas, buffers, lecturas_disco, tiempo_ms)
  VALUES (p_codigo, p_consulta, p_fase, p_tecnica, v_sql_id, v_child, v_phv,
          v_filas, v_buf, v_disco, ROUND(v_us / 1000, 2))
  RETURNING id_medicion INTO v_id;

  INSERT INTO opt_planes (id_medicion, linea, texto)
  SELECT v_id, ROWNUM, SUBSTR(p.plan_table_output, 1, 400)
    FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(v_sql_id, v_child, 'ALLSTATS LAST')) p;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE(RPAD(p_codigo || ' ' || p_fase, 12) || ' sql_id ' || v_sql_id
                       || ' | filas ' || v_filas || ' | buffers ' || v_buf
                       || ' | ' || ROUND(v_us / 1000, 2) || ' ms');
END pr_medir_consulta;
/
SHOW ERRORS PROCEDURE pr_medir_consulta

-- ==============================================================
-- SECCIÓN 2: MEDICIONES ANTES
-- Descripción: Sin índices nuevos, leyendo el modelo estrella completo.
-- ==============================================================
DECLARE
  v_nie dim_estudiante.nie%TYPE;
BEGIN
  SELECT nie INTO v_nie FROM dim_estudiante ORDER BY sk_estudiante FETCH FIRST 1 ROW ONLY;
  DBMS_OUTPUT.PUT_LINE('NIE usado en Q2: ' || v_nie);

  pr_medir_consulta('Q1', 'Docentes con mayor impacto en 2025 (top 10 por promedio)', 'ANTES',
    'Agregacion sobre HECHOS_RESULTADOS (306 mil filas) con joins a dimensiones', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q1_ANTES' AS etiqueta,
           d.nombre_completo AS docente, a.nombre AS asignatura, h.anio, h.periodo_numero,
           COUNT(DISTINCT h.sk_estudiante) AS estudiantes,
           ROUND(AVG(h.nota), 2) AS promedio,
           ROUND(100 * AVG(h.aprobado), 2) AS pct_aprobados
      FROM hechos_resultados h
      JOIN dim_docente d    ON d.sk_docente = h.sk_docente
      JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
     WHERE h.anio = 2025
     GROUP BY d.nombre_completo, a.nombre, h.anio, h.periodo_numero
     ORDER BY promedio DESC NULLS LAST, docente
     FETCH FIRST 10 ROWS ONLY]');

  pr_medir_consulta('Q2', 'Notas de un estudiante por NIE (consulta tipo expediente)', 'ANTES',
    'Sin indice en DIM_ESTUDIANTE.NIE ni en la FK HECHOS_RESULTADOS.SK_ESTUDIANTE', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q2_ANTES' AS etiqueta,
           e.nie, a.nombre AS asignatura, h.anio, h.periodo_numero, h.nota, h.asistencia_pct
      FROM hechos_resultados h
      JOIN dim_estudiante e ON e.sk_estudiante = h.sk_estudiante
      JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
     WHERE e.nie = ']' || v_nie || q'['
     ORDER BY h.anio, a.nombre, h.periodo_numero]');

  pr_medir_consulta('Q3', 'Estudiantes en riesgo por departamento y nivel de alerta (2025)', 'ANTES',
    'Agregacion por estudiante y periodo sobre HECHOS_RESULTADOS, luego por departamento', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q3_ANTES' AS etiqueta,
           c.departamento,
           CASE WHEN x.en_riesgo = 1 THEN 'ALTO'
                WHEN x.promedio < 60 OR x.asistencia < 75 THEN 'MEDIO'
                ELSE 'BAJO' END AS nivel_alerta,
           COUNT(*) AS casos,
           COUNT(DISTINCT x.sk_estudiante) AS estudiantes
      FROM (SELECT h.sk_estudiante, h.sk_curso, h.periodo_numero,
                   MAX(h.promedio_periodo_estudiante)   AS promedio,
                   MAX(h.asistencia_periodo_estudiante) AS asistencia,
                   MAX(h.en_riesgo)                     AS en_riesgo,
                   SUM(CASE WHEN h.aprobado = 0 THEN 1 ELSE 0 END) AS reprobadas
              FROM hechos_resultados h
             WHERE h.anio = 2025
             GROUP BY h.sk_estudiante, h.sk_curso, h.periodo_numero) x
      JOIN dim_curso c ON c.sk_curso = x.sk_curso
     WHERE x.en_riesgo = 1 OR x.promedio < 60 OR x.asistencia < 75 OR x.reprobadas >= 2
     GROUP BY c.departamento,
              CASE WHEN x.en_riesgo = 1 THEN 'ALTO'
                   WHEN x.promedio < 60 OR x.asistencia < 75 THEN 'MEDIO'
                   ELSE 'BAJO' END
     ORDER BY c.departamento, nivel_alerta]');
END;
/

-- ==============================================================
-- SECCIÓN 3: OPTIMIZACIÓN
-- Descripción: Índices para la búsqueda por NIE y la FK más consultada de hechos.
-- ==============================================================
CREATE INDEX ix_dim_estudiante_nie ON dim_estudiante (nie);
CREATE INDEX ix_hechos_estudiante  ON hechos_resultados (sk_estudiante);

-- ==============================================================
-- SECCIÓN 4: MEDICIONES DESPUÉS
-- Descripción: Las mismas consultas, con los índices y las vistas materializadas.
-- ==============================================================
DECLARE
  v_nie dim_estudiante.nie%TYPE;
BEGIN
  SELECT nie INTO v_nie FROM dim_estudiante ORDER BY sk_estudiante FETCH FIRST 1 ROW ONLY;

  pr_medir_consulta('Q1', 'Docentes con mayor impacto en 2025 (top 10 por promedio)', 'DESPUES',
    'Lectura de MV_RENDIMIENTO_POR_DOCENTE (ya agregada) con indice IX_MV_DOC_ANIO', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q1_DESPUES' AS etiqueta,
           docente, asignatura, anio, periodo_numero, estudiantes, promedio, pct_aprobados
      FROM mv_rendimiento_por_docente
     WHERE anio = 2025
     ORDER BY promedio DESC NULLS LAST, docente
     FETCH FIRST 10 ROWS ONLY]');

  pr_medir_consulta('Q2', 'Notas de un estudiante por NIE (consulta tipo expediente)', 'DESPUES',
    'Indices IX_DIM_ESTUDIANTE_NIE e IX_HECHOS_ESTUDIANTE (NESTED LOOPS por indice)', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q2_DESPUES' AS etiqueta,
           e.nie, a.nombre AS asignatura, h.anio, h.periodo_numero, h.nota, h.asistencia_pct
      FROM hechos_resultados h
      JOIN dim_estudiante e ON e.sk_estudiante = h.sk_estudiante
      JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
     WHERE e.nie = ']' || v_nie || q'['
     ORDER BY h.anio, a.nombre, h.periodo_numero]');

  pr_medir_consulta('Q3', 'Estudiantes en riesgo por departamento y nivel de alerta (2025)', 'DESPUES',
    'Lectura de MV_ALERTA_RIESGO (ya filtrada y agregada por estudiante y periodo)', q'[
    SELECT /*+ GATHER_PLAN_STATISTICS */ 'OPT_Q3_DESPUES' AS etiqueta,
           departamento, nivel_alerta,
           COUNT(*) AS casos,
           COUNT(DISTINCT sk_estudiante) AS estudiantes
      FROM mv_alerta_riesgo
     WHERE anio = 2025
     GROUP BY departamento, nivel_alerta
     ORDER BY departamento, nivel_alerta]');
END;
/

-- Q4: ETL medido en la carga masiva real (29-oct-2026). Planes en Data_Mart/optimizacion/.
INSERT INTO opt_mediciones (codigo, consulta, fase, tecnica, filas, tiempo_ms, nota)
VALUES ('Q4', 'ETL staging -> modelo estrella (MERGE de hechos, 306 mil resultados)', 'ANTES',
        'MERGE leyendo vistas de validacion anidadas sobre staging',
        NULL, 5400000,
        'Cancelado a los 90 min sin terminar. NESTED LOOPS por IX_STG_*_CARGA: 79G filas estimadas (plan_ANTES_insert_wk_etl_hechos.txt)');
INSERT INTO opt_mediciones (codigo, consulta, fase, tecnica, filas, tiempo_ms, nota)
VALUES ('Q4', 'ETL staging -> modelo estrella (MERGE de hechos, 306 mil resultados)', 'DESPUES',
        'Tablas de trabajo WK_ETL_* con estadisticas, cada tabla STG copiada sola y HASH JOIN',
        306464, 177000,
        'Modelo estrella completo (02 + 03) en 2 min 57 s, de 02:21:40 a 02:24:37. La mejora real es mayor: el ANTES nunca termino');
COMMIT;

-- ==============================================================
-- SECCIÓN 5: RESULTADOS
-- Descripción: Comparación de tiempos y lecturas, antes y después.
-- ==============================================================
PROMPT
PROMPT ==== Tabla comparativa antes / despues
COLUMN codigo FORMAT A4
COLUMN consulta FORMAT A58
COLUMN buffers_antes FORMAT 999,999,990
COLUMN buffers_despues FORMAT 999,999,990
COLUMN ms_antes FORMAT 9,999,990.99
COLUMN ms_despues FORMAT 9,999,990.99
COLUMN mejora_buffers FORMAT A14
COLUMN mejora_tiempo FORMAT A14
SELECT a.codigo, a.consulta,
       a.filas AS filas_antes, d.filas AS filas_despues,
       a.buffers AS buffers_antes, d.buffers AS buffers_despues,
       a.tiempo_ms AS ms_antes, d.tiempo_ms AS ms_despues,
       CASE WHEN a.buffers > 0 THEN TO_CHAR(ROUND(100 * (1 - d.buffers / a.buffers), 1), 'FM990.0') || ' %' END AS mejora_buffers,
       CASE WHEN a.tiempo_ms > 0 THEN TO_CHAR(ROUND(100 * (1 - d.tiempo_ms / a.tiempo_ms), 1), 'FM990.0') || ' %' END AS mejora_tiempo
  FROM opt_mediciones a
  JOIN opt_mediciones d ON d.codigo = a.codigo AND d.fase = 'DESPUES'
 WHERE a.fase = 'ANTES'
 ORDER BY a.codigo;

PROMPT ==== Tecnica aplicada en cada caso
COLUMN fase FORMAT A8
COLUMN tecnica FORMAT A95
COLUMN plan_hash_value FORMAT 9999999999
SELECT codigo, fase, tecnica, sql_id, plan_hash_value
  FROM opt_mediciones
 ORDER BY codigo, fase;

PROMPT ==== Planes reales de ejecucion (ALLSTATS LAST): A-Rows, Buffers y A-Time por operacion
BEGIN
  FOR m IN (SELECT id_medicion, codigo, fase
              FROM opt_mediciones
             WHERE sql_id IS NOT NULL
             ORDER BY codigo, fase) LOOP
    DBMS_OUTPUT.PUT_LINE(' ');
    DBMS_OUTPUT.PUT_LINE('######## ' || m.codigo || ' ' || m.fase || ' ########');
    FOR p IN (SELECT texto FROM opt_planes WHERE id_medicion = m.id_medicion ORDER BY linea) LOOP
      DBMS_OUTPUT.PUT_LINE(p.texto);
    END LOOP;
  END LOOP;
END;
/
