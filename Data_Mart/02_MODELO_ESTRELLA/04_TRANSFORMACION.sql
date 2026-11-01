-- ==============================================================
-- SECCIÓN 4: TRANSFORMACIÓN
-- Descripción: vw_etl_hechos_resultados arma una fila por estudiante, materia y período con nota, asistencia,
--   riesgo, promedios, ranking en el curso y variación interanual (funciones analíticas).
--   wk_etl_hechos guarda su resultado para que el MERGE de hechos no la recalcule.
-- ==============================================================

-- Se ejecuta desde INSTALAR_MODELO_ESTRELLA.sql, que fija las opciones de la sesión.

-- === VW_ETL_HECHOS_RESULTADOS ===
CREATE OR REPLACE VIEW vw_etl_hechos_resultados AS
WITH res AS (      -- ultima version del resultado oficial por estudiante, materia y periodo
  SELECT r.*,
         ROW_NUMBER() OVER (PARTITION BY r.id_estudiante, r.id_asignatura, r.id_periodo
                            ORDER BY r.version DESC, r.id_resultado DESC) AS rv
    FROM vw_etl_stg_resultados_periodo r
), ins AS (
  SELECT * FROM wk_etl_ins     -- filas validas, llenadas por el 03
), cal AS (
  SELECT * FROM wk_etl_cal
), asi AS (
  SELECT * FROM wk_etl_asi
), base AS (       -- grano: estudiante + asignatura + periodo (una fila por resultado oficial)
  SELECT r.id_resultado, r.id_estudiante, r.id_asignatura, r.id_periodo, r.criterio,
         k.id_calificacion, k.id_inscripcion, k.id_ponderacion_periodo, k.nota,
         k.resultado_cualitativo, k.tipo_intento, k.fecha_evaluacion,
         ad.id_docente, i.id_curso, c.id_modalidad,
         pp.peso, pp.id_curso_asignatura,
         per.numero AS periodo_numero, cy.anio
    FROM res r
    JOIN cal k                       ON k.id_calificacion = r.id_calificacion_seleccionada
    JOIN ins i                       ON i.id_inscripcion = k.id_inscripcion
    JOIN vw_etl_val_cursos c         ON c.id_curso = i.id_curso AND c.motivo_rechazo IS NULL
    JOIN wk_etl_pp pp                ON pp.id_ponderacion_periodo = k.id_ponderacion_periodo
    JOIN vw_etl_stg_periodos per     ON per.id_periodo = r.id_periodo
    JOIN vw_etl_stg_ciclos cy        ON cy.id_ciclo = per.id_ciclo
    JOIN wk_etl_ad ad                ON ad.id_asignacion = k.id_asignacion_docente
   WHERE r.rv = 1
     AND k.fecha_anulacion IS NULL   -- una nota anulada deja el periodo pendiente
), asist AS (      -- asistencia por inscripcion y ponderacion, ya calculada por el 03
  SELECT * FROM wk_etl_asist
), pesos_plan AS (
  SELECT id_curso_asignatura, SUM(peso) AS peso_plan
    FROM wk_etl_pp
   GROUP BY id_curso_asignatura
), beca AS (       -- inscripciones con beca vigente en algun momento del periodo
  SELECT DISTINCT b.id_inscripcion, per.id_periodo
    FROM vw_etl_stg_becas b
    JOIN vw_etl_stg_becas_vigencia v ON v.id_beca = b.id_beca
    JOIN ins i                       ON i.id_inscripcion = b.id_inscripcion
    JOIN vw_etl_stg_cursos c         ON c.id_curso = i.id_curso
    JOIN vw_etl_stg_periodos per     ON per.id_ciclo = c.id_ciclo
   WHERE v.fecha_inicio <= per.fecha_fin
     AND NVL(v.fecha_fin, per.fecha_fin) >= per.fecha_inicio
), f AS (
  SELECT b.*,
         NVL(a.aplicables, 0)  AS aplicables,
         NVL(a.registradas, 0) AS registradas,
         NVL(a.presencias, 0)  AS presencias,
         pl.peso_plan,
         CASE WHEN bc.id_inscripcion IS NULL THEN 0 ELSE 1 END AS beca_vigente
    FROM base b
    JOIN pesos_plan pl ON pl.id_curso_asignatura = b.id_curso_asignatura
    LEFT JOIN asist a  ON a.id_inscripcion = b.id_inscripcion AND a.id_ponderacion_periodo = b.id_ponderacion_periodo
    LEFT JOIN beca bc  ON bc.id_inscripcion = b.id_inscripcion AND bc.id_periodo = b.id_periodo
), g AS (          -- transformaciones con funciones analiticas
  SELECT f.*,
         AVG(f.nota)        OVER (PARTITION BY f.id_inscripcion, f.id_periodo) AS prom_est_per,
         SUM(f.presencias)  OVER (PARTITION BY f.id_inscripcion, f.id_periodo) AS pres_est_per,
         SUM(f.registradas) OVER (PARTITION BY f.id_inscripcion, f.id_periodo) AS reg_est_per,
         SUM(f.aplicables)  OVER (PARTITION BY f.id_inscripcion, f.id_periodo) AS apl_est_per,
         SUM(f.nota * f.peso) OVER (PARTITION BY f.id_inscripcion, f.id_asignatura) AS suma_nota_peso,
         SUM(CASE WHEN f.nota IS NOT NULL THEN f.peso END)
                            OVER (PARTITION BY f.id_inscripcion, f.id_asignatura) AS suma_peso,
         AVG(f.nota)        OVER (PARTITION BY f.id_curso, f.id_asignatura, f.id_periodo) AS prom_curso,
         CASE WHEN f.nota IS NOT NULL THEN
              PERCENT_RANK() OVER (PARTITION BY f.id_curso, f.id_asignatura, f.id_periodo, NVL2(f.nota, 1, 0)
                                   ORDER BY f.nota) END AS pct_rank,
         CASE WHEN f.nota IS NOT NULL THEN
              NTILE(4) OVER (PARTITION BY f.id_curso, f.id_asignatura, f.id_periodo, NVL2(f.nota, 1, 0)
                             ORDER BY f.nota DESC, f.id_estudiante) END AS cuartil,   -- desempate fijo: NTILE con notas iguales no es determinista
         LAG(f.nota) OVER (PARTITION BY f.id_estudiante, f.id_asignatura, f.periodo_numero ORDER BY f.anio) AS nota_ant,
         LAG(f.anio) OVER (PARTITION BY f.id_estudiante, f.id_asignatura, f.periodo_numero ORDER BY f.anio) AS anio_ant
    FROM f
)
SELECT g.id_resultado, g.id_estudiante, g.id_docente, g.id_asignatura, g.id_curso, g.id_modalidad,
       TO_NUMBER(TO_CHAR(g.fecha_evaluacion, 'YYYYMMDD')) AS id_tiempo,
       g.id_periodo, g.anio, g.periodo_numero,
       g.nota, g.resultado_cualitativo, g.peso,
       CASE WHEN g.nota IS NULL THEN NULL WHEN g.nota >= 60 THEN 1 ELSE 0 END AS aprobado,
       g.tipo_intento, g.criterio,
       g.aplicables  AS sesiones_aplicables,
       g.registradas AS sesiones_registradas,
       g.presencias,
       ROUND(100 * g.presencias / NULLIF(g.registradas, 0), 2) AS asistencia_pct,
       ROUND(g.prom_est_per, 2) AS promedio_periodo_estudiante,
       ROUND(100 * g.pres_est_per / NULLIF(g.reg_est_per, 0), 2) AS asistencia_periodo_estudiante,
       -- riesgo: promedio < 60 Y asistencia < 75 %; NULL = informacion insuficiente
       CASE WHEN g.prom_est_per IS NULL OR g.reg_est_per = 0 OR g.reg_est_per < g.apl_est_per THEN NULL
            WHEN g.prom_est_per < 60 AND 100 * g.pres_est_per / g.reg_est_per < 75 THEN 1
            ELSE 0 END AS en_riesgo,
       ROUND(g.suma_nota_peso / NULLIF(g.suma_peso, 0), 2) AS promedio_anual_materia,
       ROUND(100 * g.suma_peso / NULLIF(g.peso_plan, 0), 2) AS cobertura_anual_pct,
       ROUND(g.prom_curso, 2) AS promedio_curso,
       ROUND(g.pct_rank, 4) AS percentil_curso,
       g.cuartil AS cuartil_curso,
       CASE WHEN g.anio_ant = g.anio - 1 THEN g.nota_ant END AS nota_anio_anterior,
       CASE WHEN g.anio_ant = g.anio - 1 THEN ROUND(g.nota - g.nota_ant, 2) END AS variacion_interanual,
       g.beca_vigente
  FROM g;

CREATE TABLE wk_etl_hechos AS SELECT * FROM vw_etl_hechos_resultados WHERE 1 = 0;
