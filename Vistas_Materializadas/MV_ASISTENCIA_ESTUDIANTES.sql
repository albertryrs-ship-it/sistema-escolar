-- =====================================================================
-- Vistas_Materializadas/MV_ASISTENCIA_ESTUDIANTES.sql
-- Asistencia por estudiante. Lee del modelo estrella (Data_Mart/02 y 03).
-- Re-ejecutable: si la vista ya existe, la borra y la vuelve a crear (no guarda datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews WHERE mview_name = 'MV_ASISTENCIA_ESTUDIANTES') LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || m.mview_name;
  END LOOP;
END;
/

-- 3. ASISTENCIA POR ESTUDIANTE
-- Grano: estudiante + curso + anio + periodo (todas sus asignaturas juntas).
CREATE MATERIALIZED VIEW mv_asistencia_estudiantes
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
SELECT x.*,
       CASE WHEN x.pct_asistencia IS NULL THEN NULL
            WHEN x.pct_asistencia < 75 THEN 1 ELSE 0 END AS alerta_asistencia
  FROM (SELECT e.sk_estudiante, e.nie,
               c.sk_curso, c.institucion, c.tipo_institucion, c.departamento, c.codigo_iso, c.zona,
               c.nivel, c.grado, c.seccion,
               h.anio, h.periodo_numero,
               SUM(h.sesiones_aplicables)                      AS sesiones_aplicables,
               SUM(h.sesiones_registradas)                     AS sesiones_registradas,
               SUM(h.presencias)                               AS presencias,
               SUM(h.sesiones_registradas) - SUM(h.presencias) AS inasistencias,
               SUM(h.sesiones_aplicables) - SUM(h.sesiones_registradas) AS sesiones_sin_captura,
               ROUND(100 * SUM(h.presencias)
                         / NULLIF(SUM(h.sesiones_registradas), 0), 2) AS pct_asistencia
          FROM hechos_resultados h
          JOIN dim_estudiante e ON e.sk_estudiante = h.sk_estudiante
          JOIN dim_curso c      ON c.sk_curso = h.sk_curso
         GROUP BY e.sk_estudiante, e.nie, c.sk_curso, c.institucion, c.tipo_institucion, c.departamento,
                  c.codigo_iso, c.zona, c.nivel, c.grado, c.seccion,
                  h.anio, h.periodo_numero) x;

COMMENT ON MATERIALIZED VIEW mv_asistencia_estudiantes IS
  'Asistencia por estudiante (NIE), curso, anio y periodo. alerta_asistencia = 1 si es menor a 75 %.';

-- Indice para las consultas del dashboard
CREATE INDEX ix_mv_asis_nie      ON mv_asistencia_estudiantes (nie);
