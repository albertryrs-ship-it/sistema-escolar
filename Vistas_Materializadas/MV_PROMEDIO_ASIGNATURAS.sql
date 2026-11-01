-- =====================================================================
-- Vistas_Materializadas/MV_PROMEDIO_ASIGNATURAS.sql
-- Promedio por asignatura. Lee del modelo estrella (Data_Mart/02 y 03).
-- Re-ejecutable: si la vista ya existe, la borra y la vuelve a crear (no guarda datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews WHERE mview_name = 'MV_PROMEDIO_ASIGNATURAS') LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || m.mview_name;
  END LOOP;
END;
/

-- 2. PROMEDIO POR ASIGNATURA
-- Grano: asignatura + grado + anio + periodo.
CREATE MATERIALIZED VIEW mv_promedio_asignaturas
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
SELECT a.sk_asignatura, a.codigo AS codigo_asignatura, a.nombre AS asignatura, a.area_conocimiento,
       c.nivel, c.grado, c.orden_grado, c.tipo_institucion,
       h.anio, h.periodo_numero,
       COUNT(*)                                        AS resultados,
       COUNT(h.nota)                                   AS notas,
       ROUND(AVG(h.nota), 2)                           AS promedio,
       ROUND(MEDIAN(h.nota), 2)                        AS mediana,
       MIN(h.nota)                                     AS nota_minima,
       MAX(h.nota)                                     AS nota_maxima,
       ROUND(STDDEV(h.nota), 2)                        AS desviacion_estandar,
       ROUND(100 * AVG(h.aprobado), 2)                 AS pct_aprobados,
       ROUND(100 * SUM(CASE WHEN h.aprobado = 0 THEN 1 ELSE 0 END)
                 / NULLIF(COUNT(h.aprobado), 0), 2)    AS pct_reprobados,
       ROUND(100 * SUM(h.presencias)
                 / NULLIF(SUM(h.sesiones_registradas), 0), 2) AS pct_asistencia
  FROM hechos_resultados h
  JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
  JOIN dim_curso c      ON c.sk_curso = h.sk_curso
 GROUP BY a.sk_asignatura, a.codigo, a.nombre, a.area_conocimiento,
          c.nivel, c.grado, c.orden_grado, c.tipo_institucion, h.anio, h.periodo_numero;

COMMENT ON MATERIALIZED VIEW mv_promedio_asignaturas IS
  'Promedio, mediana, extremos, dispersion y aprobacion por asignatura, grado, anio y periodo.';

-- Indice para las consultas del dashboard
CREATE INDEX ix_mv_asig_anio     ON mv_promedio_asignaturas (anio, sk_asignatura);
