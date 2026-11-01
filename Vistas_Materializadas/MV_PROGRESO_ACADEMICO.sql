-- =====================================================================
-- Vistas_Materializadas/MV_PROGRESO_ACADEMICO.sql
-- Progreso academico. Lee del modelo estrella (Data_Mart/02 y 03).
-- Re-ejecutable: si la vista ya existe, la borra y la vuelve a crear (no guarda datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews WHERE mview_name = 'MV_PROGRESO_ACADEMICO') LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || m.mview_name;
  END LOOP;
END;
/

-- 5. PROGRESO ACADEMICO
-- Grano: estudiante + asignatura + anio. Compara el promedio anual ponderado con el
-- del anio anterior en la misma asignatura (por ejemplo, octavo 2024 contra noveno 2025).
CREATE MATERIALIZED VIEW mv_progreso_academico
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
SELECT y.*,
       CASE WHEN y.promedio_anio_anterior IS NULL THEN 'SIN COMPARACION'
            WHEN y.variacion >= 5  THEN 'MEJORA'
            WHEN y.variacion <= -5 THEN 'BAJA'
            ELSE 'ESTABLE' END AS tendencia
  FROM (SELECT x.*,
               CASE WHEN LAG(x.anio) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio) = x.anio - 1
                    THEN LAG(x.promedio_anual) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio) END AS promedio_anio_anterior,
               CASE WHEN LAG(x.anio) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio) = x.anio - 1
                    THEN LAG(x.grado) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio) END AS grado_anio_anterior,
               CASE WHEN LAG(x.anio) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio) = x.anio - 1
                    THEN ROUND(x.promedio_anual - LAG(x.promedio_anual) OVER (PARTITION BY x.sk_estudiante, x.sk_asignatura ORDER BY x.anio), 2) END AS variacion
          FROM (SELECT e.sk_estudiante, e.nie,
                       a.sk_asignatura, a.nombre AS asignatura,
                       h.anio,
                       MAX(c.grado)                       AS grado,
                       MAX(c.orden_grado)                 AS orden_grado,
                       MAX(c.departamento)                AS departamento,
                       MAX(c.zona)                        AS zona,
                       MAX(c.tipo_institucion)            AS tipo_institucion,
                       ROUND(MAX(h.promedio_anual_materia), 2) AS promedio_anual,
                       ROUND(MAX(h.cobertura_anual_pct), 2)    AS cobertura_anual_pct,
                       COUNT(h.nota)                      AS periodos_con_nota,
                       MIN(h.aprobado)                    AS aprobo_todos_los_periodos
                  FROM hechos_resultados h
                  JOIN dim_estudiante e ON e.sk_estudiante = h.sk_estudiante
                  JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
                  JOIN dim_curso c      ON c.sk_curso = h.sk_curso
                 GROUP BY e.sk_estudiante, e.nie, a.sk_asignatura, a.nombre, h.anio) x) y;

COMMENT ON MATERIALIZED VIEW mv_progreso_academico IS
  'Promedio anual por estudiante y asignatura contra el anio anterior. Tendencia: MEJORA (+5), BAJA (-5), ESTABLE o SIN COMPARACION.';

-- Indice para las consultas del dashboard
CREATE INDEX ix_mv_prog_nie      ON mv_progreso_academico (nie, sk_asignatura);
