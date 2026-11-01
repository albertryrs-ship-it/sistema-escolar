-- =====================================================================
-- Vistas_Materializadas/MV_RENDIMIENTO_POR_DOCENTE.sql
-- Rendimiento por docente. Lee del modelo estrella (Data_Mart/02 y 03).
-- Re-ejecutable: si la vista ya existe, la borra y la vuelve a crear (no guarda datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews WHERE mview_name = 'MV_RENDIMIENTO_POR_DOCENTE') LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || m.mview_name;
  END LOOP;
END;
/

-- 1. RENDIMIENTO POR DOCENTE
-- Grano: docente + asignatura + anio + periodo. Ranking del docente entre los que dan
-- la misma asignatura en el mismo anio y periodo.
CREATE MATERIALIZED VIEW mv_rendimiento_por_docente
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
SELECT x.*,
       RANK() OVER (PARTITION BY x.anio, x.periodo_numero, x.sk_asignatura, x.tipo_institucion
                    ORDER BY x.promedio DESC NULLS LAST) AS ranking_en_asignatura
  FROM (SELECT d.sk_docente, d.id_docente, d.nombre_completo AS docente, d.especialidad,
               d.anios_experiencia, d.institucion,
               a.sk_asignatura, a.nombre AS asignatura,
               c.tipo_institucion,
               h.anio, h.periodo_numero,
               COUNT(*)                                             AS resultados,
               COUNT(DISTINCT h.sk_estudiante)                      AS estudiantes,
               COUNT(DISTINCT h.sk_curso)                           AS cursos,
               ROUND(AVG(h.nota), 2)                                AS promedio,
               ROUND(100 * AVG(h.aprobado), 2)                      AS pct_aprobados,
               ROUND(100 * SUM(CASE WHEN h.aprobado = 0 THEN 1 ELSE 0 END)
                         / NULLIF(COUNT(h.aprobado), 0), 2)         AS pct_reprobados,
               ROUND(100 * SUM(h.presencias)
                         / NULLIF(SUM(h.sesiones_registradas), 0), 2) AS pct_asistencia,
               COUNT(DISTINCT CASE WHEN h.en_riesgo = 1 THEN h.sk_estudiante END) AS estudiantes_en_riesgo
          FROM hechos_resultados h
          JOIN dim_docente d    ON d.sk_docente = h.sk_docente
          JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
          JOIN dim_curso c      ON c.sk_curso = h.sk_curso
         GROUP BY d.sk_docente, d.id_docente, d.nombre_completo, d.especialidad,
                  d.anios_experiencia, d.institucion,
                  a.sk_asignatura, a.nombre, c.tipo_institucion, h.anio, h.periodo_numero) x;

COMMENT ON MATERIALIZED VIEW mv_rendimiento_por_docente IS
  'Rendimiento de los estudiantes por docente, asignatura, anio y periodo. Refresco completo despues de cada ETL.';

-- Indice para las consultas del dashboard
CREATE INDEX ix_mv_doc_anio      ON mv_rendimiento_por_docente (anio, periodo_numero);
