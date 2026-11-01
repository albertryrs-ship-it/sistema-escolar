-- =====================================================================
-- Vistas_Materializadas/MV_ALERTA_RIESGO.sql
-- Alerta de riesgo. Lee del modelo estrella (Data_Mart/02 y 03).
-- Re-ejecutable: si la vista ya existe, la borra y la vuelve a crear (no guarda datos propios).
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

BEGIN
  FOR m IN (SELECT mview_name FROM user_mviews WHERE mview_name = 'MV_ALERTA_RIESGO') LOOP
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || m.mview_name;
  END LOOP;
END;
/

-- 4. ALERTA DE RIESGO
-- Grano: estudiante + curso + anio + periodo, solo los que necesitan apoyo.
--   ALTO : promedio del periodo < 60 Y asistencia < 75 % (regla en_riesgo del ETL)
--   MEDIO: solo una de las dos condiciones
--   BAJO : 2 o mas asignaturas reprobadas en el periodo
CREATE MATERIALIZED VIEW mv_alerta_riesgo
  BUILD IMMEDIATE
  REFRESH COMPLETE ON DEMAND
AS
SELECT x.*,
       CASE WHEN x.en_riesgo = 1 THEN 'ALTO'
            WHEN x.promedio_periodo < 60 OR x.asistencia_periodo < 75 THEN 'MEDIO'
            ELSE 'BAJO' END AS nivel_alerta,
       CASE WHEN x.en_riesgo = 1 THEN 1
            WHEN x.promedio_periodo < 60 OR x.asistencia_periodo < 75 THEN 2
            ELSE 3 END AS orden_alerta
  FROM (SELECT e.sk_estudiante, e.nie, e.sexo, e.edad,
               c.sk_curso, c.institucion, c.codigo_institucion, c.tipo_institucion, c.departamento, c.codigo_iso,
               c.zona, c.nivel, c.grado, c.seccion,
               h.anio, h.periodo_numero,
               MAX(h.promedio_periodo_estudiante)                     AS promedio_periodo,
               MAX(h.asistencia_periodo_estudiante)                   AS asistencia_periodo,
               COUNT(*)                                               AS asignaturas,
               SUM(CASE WHEN h.aprobado = 0 THEN 1 ELSE 0 END)        AS asignaturas_reprobadas,
               MAX(h.en_riesgo)                                       AS en_riesgo,
               MAX(h.beca_vigente)                                    AS beca_vigente
          FROM hechos_resultados h
          JOIN dim_estudiante e ON e.sk_estudiante = h.sk_estudiante
          JOIN dim_curso c      ON c.sk_curso = h.sk_curso
         GROUP BY e.sk_estudiante, e.nie, e.sexo, e.edad,
                  c.sk_curso, c.institucion, c.codigo_institucion, c.tipo_institucion, c.departamento, c.codigo_iso,
                  c.zona, c.nivel, c.grado, c.seccion, h.anio, h.periodo_numero
        HAVING MAX(h.en_riesgo) = 1
            OR MAX(h.promedio_periodo_estudiante) < 60
            OR MAX(h.asistencia_periodo_estudiante) < 75
            OR SUM(CASE WHEN h.aprobado = 0 THEN 1 ELSE 0 END) >= 2) x;

COMMENT ON MATERIALIZED VIEW mv_alerta_riesgo IS
  'Estudiantes que necesitan apoyo por periodo. ALTO: promedio < 60 y asistencia < 75 %; MEDIO: una de las dos; BAJO: 2+ reprobadas.';

-- Indice para las consultas del dashboard
CREATE INDEX ix_mv_riesgo_alerta ON mv_alerta_riesgo (anio, orden_alerta);
