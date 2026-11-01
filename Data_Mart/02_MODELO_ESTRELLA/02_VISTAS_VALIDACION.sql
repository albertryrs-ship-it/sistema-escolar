-- ==============================================================
-- SECCIÓN 2: VISTAS DE VALIDACIÓN
-- Descripción: Una vista por entidad (estudiantes, cursos, inscripciones, calificaciones, asistencias).
--   Cada fila trae motivo_rechazo: NULL si es válida, o el tipo de error (NOTA_FUERA_DE_RANGO, CLAVE_HUERFANA…).
--   El 03 carga las válidas y registra las rechazadas en errores_etl_evaluaciones.
-- ==============================================================

-- Se ejecuta desde INSTALAR_MODELO_ESTRELLA.sql, que fija las opciones de la sesión.

-- === VW_ETL_VAL_ESTUDIANTES ===
CREATE OR REPLACE VIEW vw_etl_val_estudiantes AS
SELECT x.id_estudiante, x.id_persona, x.nie, x.fecha_registro_estudiante, x.estudiante_activo, x.fecha_nacimiento, x.sexo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'DUPLICADO'
         WHEN x.rn_nie > 1
           THEN 'NIE_DUPLICADO'
         WHEN x.sexo IS NOT NULL AND x.sexo NOT IN ('M', 'F', 'OTRO')
           THEN 'DOMINIO_INVALIDO'
         WHEN x.fecha_nacimiento > SYSDATE
           THEN 'FECHA_INVALIDA'
       END AS motivo_rechazo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'id_estudiante repetido en staging'
         WHEN x.rn_nie > 1
           THEN 'El NIE ya pertenece a otro estudiante'
         WHEN x.sexo IS NOT NULL AND x.sexo NOT IN ('M', 'F', 'OTRO')
           THEN 'Sexo fuera del dominio M/F/OTRO'
         WHEN x.fecha_nacimiento > SYSDATE
           THEN 'Fecha de nacimiento futura'
       END AS detalle
  FROM (SELECT t.*,
               ROW_NUMBER() OVER (PARTITION BY t.id_estudiante ORDER BY t.id_estudiante) AS rn_dup,
               ROW_NUMBER() OVER (PARTITION BY t.nie ORDER BY t.id_estudiante) AS rn_nie
          FROM vw_etl_stg_estudiantes t) x;

-- === VW_ETL_VAL_CURSOS ===
CREATE OR REPLACE VIEW vw_etl_val_cursos AS
SELECT x.id_curso, x.id_institucion, x.id_ciclo, x.id_grado, x.id_jornada, x.id_modalidad, x.codigo, x.nombre, x.seccion, x.capacidad_maxima, x.estado,
       CASE
         WHEN x.rn_dup > 1
           THEN 'DUPLICADO'
         WHEN m.id_modalidad IS NULL
           THEN 'MODALIDAD_INVALIDA'
         WHEN g.id_grado IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN ic.id_institucion IS NULL
           THEN 'CLAVE_HUERFANA'
       END AS motivo_rechazo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'id_curso repetido en staging'
         WHEN m.id_modalidad IS NULL
           THEN 'Modalidad de entrega inexistente'
         WHEN g.id_grado IS NULL
           THEN 'Grado inexistente'
         WHEN ic.id_institucion IS NULL
           THEN 'Institucion/ciclo inexistente'
       END AS detalle
  FROM (SELECT t.*,
               ROW_NUMBER() OVER (PARTITION BY t.id_curso ORDER BY t.id_curso) AS rn_dup
          FROM vw_etl_stg_cursos t) x
  LEFT JOIN (SELECT DISTINCT id_modalidad FROM vw_etl_stg_modalidades) m
         ON m.id_modalidad = x.id_modalidad
  LEFT JOIN (SELECT DISTINCT id_grado FROM vw_etl_stg_grados) g
         ON g.id_grado = x.id_grado
  LEFT JOIN (SELECT DISTINCT id_institucion, id_ciclo FROM vw_etl_stg_instituciones_ciclo) ic
         ON ic.id_institucion = x.id_institucion AND ic.id_ciclo = x.id_ciclo;

-- === VW_ETL_VAL_INSCRIPCIONES ===
CREATE OR REPLACE VIEW vw_etl_val_inscripciones AS
SELECT x.id_inscripcion, x.id_estudiante, x.id_curso, x.fecha_inscripcion, x.fecha_inicio, x.fecha_fin, x.estado, x.motivo_fin_inscripcion, x.resultado_cierre,
       CASE
         WHEN x.rn_dup > 1
           THEN 'DUPLICADO'
         WHEN ve.id_estudiante IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN vc.id_curso IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN x.fecha_fin < x.fecha_inicio
           THEN 'FECHA_INVALIDA'
         WHEN x.estado NOT IN ('VIGENTE', 'FINALIZADA', 'RETIRADA', 'TRASLADADA', 'ANULADA')
           THEN 'DOMINIO_INVALIDO'
         WHEN x.resultado_cierre IS NOT NULL AND x.resultado_cierre NOT IN ('PROMOVIDO', 'REPITE', 'GRADUADO')
           THEN 'DOMINIO_INVALIDO'
       END AS motivo_rechazo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'id_inscripcion repetido en staging'
         WHEN ve.id_estudiante IS NULL
           THEN 'Estudiante inexistente o rechazado'
         WHEN vc.id_curso IS NULL
           THEN 'Curso inexistente o rechazado'
         WHEN x.fecha_fin < x.fecha_inicio
           THEN 'Fecha de fin anterior a la de inicio'
         WHEN x.estado NOT IN ('VIGENTE', 'FINALIZADA', 'RETIRADA', 'TRASLADADA', 'ANULADA')
           THEN 'Estado de inscripcion fuera del dominio'
         WHEN x.resultado_cierre IS NOT NULL AND x.resultado_cierre NOT IN ('PROMOVIDO', 'REPITE', 'GRADUADO')
           THEN 'Resultado de cierre fuera del dominio'
       END AS detalle
  FROM (SELECT t.*,
               ROW_NUMBER() OVER (PARTITION BY t.id_inscripcion ORDER BY t.id_inscripcion) AS rn_dup
          FROM vw_etl_stg_inscripciones t) x
  LEFT JOIN (SELECT DISTINCT id_estudiante FROM vw_etl_val_estudiantes WHERE motivo_rechazo IS NULL) ve
         ON ve.id_estudiante = x.id_estudiante
  LEFT JOIN (SELECT DISTINCT id_curso FROM vw_etl_val_cursos WHERE motivo_rechazo IS NULL) vc
         ON vc.id_curso = x.id_curso;

-- === VW_ETL_VAL_CALIFICACIONES ===
CREATE OR REPLACE VIEW vw_etl_val_calificaciones AS
SELECT x.id_calificacion, x.id_inscripcion, x.id_ponderacion_periodo, x.tipo_intento, x.numero_intento, x.version, x.id_calificacion_ordinaria, x.id_calificacion_sustituida, x.id_asignacion_docente, x.id_docente_registra, x.nota, x.resultado_cualitativo, x.fecha_evaluacion, x.fecha_registro, x.fecha_validacion, x.fecha_anulacion, x.motivo_anulacion,
       CASE
         WHEN x.rn_dup > 1
           THEN 'DUPLICADO'
         WHEN x.nota IS NOT NULL AND (x.nota < 0 OR x.nota > 100)
           THEN 'NOTA_FUERA_DE_RANGO'
         WHEN (x.nota IS NULL AND x.resultado_cualitativo IS NULL) OR (x.nota IS NOT NULL AND x.resultado_cualitativo IS NOT NULL)
           THEN 'RESULTADO_INCOMPLETO'
         WHEN x.tipo_intento NOT IN ('ORDINARIA', 'RECUPERACION')
           THEN 'DOMINIO_INVALIDO'
         WHEN x.tipo_intento = 'RECUPERACION' AND x.id_calificacion_ordinaria IS NULL
           THEN 'RECUPERACION_SIN_ORDINARIA'
         WHEN vi.id_inscripcion IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN vp.id_ponderacion_periodo IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN va.id_asignacion IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN x.fecha_evaluacion NOT BETWEEN vy.f_min AND vy.f_max
           THEN 'FECHA_INVALIDA'
       END AS motivo_rechazo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'id_calificacion repetido en staging'
         WHEN x.nota IS NOT NULL AND (x.nota < 0 OR x.nota > 100)
           THEN 'La nota debe estar entre 0 y 100'
         WHEN (x.nota IS NULL AND x.resultado_cualitativo IS NULL) OR (x.nota IS NOT NULL AND x.resultado_cualitativo IS NOT NULL)
           THEN 'Debe tener nota o resultado cualitativo, solo uno'
         WHEN x.tipo_intento NOT IN ('ORDINARIA', 'RECUPERACION')
           THEN 'Tipo de intento fuera del dominio'
         WHEN x.tipo_intento = 'RECUPERACION' AND x.id_calificacion_ordinaria IS NULL
           THEN 'Recuperacion sin calificacion ordinaria de origen'
         WHEN vi.id_inscripcion IS NULL
           THEN 'Inscripcion inexistente o rechazada'
         WHEN vp.id_ponderacion_periodo IS NULL
           THEN 'Ponderacion inexistente'
         WHEN va.id_asignacion IS NULL
           THEN 'Asignacion docente inexistente'
         WHEN x.fecha_evaluacion NOT BETWEEN vy.f_min AND vy.f_max
           THEN 'Fecha de evaluacion fuera de los ciclos registrados'
       END AS detalle
  FROM (SELECT t.*,
               ROW_NUMBER() OVER (PARTITION BY t.id_calificacion ORDER BY t.id_calificacion) AS rn_dup
          FROM vw_etl_stg_calificaciones t) x
  LEFT JOIN (SELECT DISTINCT id_inscripcion FROM vw_etl_val_inscripciones WHERE motivo_rechazo IS NULL) vi
         ON vi.id_inscripcion = x.id_inscripcion
  LEFT JOIN (SELECT DISTINCT id_ponderacion_periodo FROM vw_etl_stg_ponderaciones) vp
         ON vp.id_ponderacion_periodo = x.id_ponderacion_periodo
  LEFT JOIN (SELECT DISTINCT id_asignacion FROM vw_etl_stg_asignaciones_docentes) va
         ON va.id_asignacion = x.id_asignacion_docente
  LEFT JOIN (SELECT MIN(fecha_inicio) AS f_min, MAX(fecha_fin) + 60 AS f_max FROM vw_etl_stg_ciclos) vy
         ON 1 = 1;

-- === VW_ETL_VAL_ASISTENCIAS ===
CREATE OR REPLACE VIEW vw_etl_val_asistencias AS
SELECT x.id_asistencia, x.id_inscripcion, x.id_sesion, x.estado, x.hora_llegada, x.fecha_registro, x.observaciones,
       CASE
         WHEN x.rn_dup > 1
           THEN 'DUPLICADO'
         WHEN x.estado NOT IN ('PRESENTE', 'TARDE', 'AUSENTE', 'JUSTIFICADA')
           THEN 'DOMINIO_INVALIDO'
         WHEN vs.id_sesion IS NULL
           THEN 'CLAVE_HUERFANA'
         WHEN vi.id_inscripcion IS NULL
           THEN 'CLAVE_HUERFANA'
       END AS motivo_rechazo,
       CASE
         WHEN x.rn_dup > 1
           THEN 'id_asistencia repetido en staging'
         WHEN x.estado NOT IN ('PRESENTE', 'TARDE', 'AUSENTE', 'JUSTIFICADA')
           THEN 'Estado de asistencia fuera del dominio'
         WHEN vs.id_sesion IS NULL
           THEN 'Sesion inexistente'
         WHEN vi.id_inscripcion IS NULL
           THEN 'Inscripcion inexistente o rechazada'
       END AS detalle
  FROM (SELECT t.*,
               ROW_NUMBER() OVER (PARTITION BY t.id_asistencia ORDER BY t.id_asistencia) AS rn_dup
          FROM vw_etl_stg_asistencias t) x
  LEFT JOIN (SELECT DISTINCT id_sesion FROM vw_etl_stg_sesiones) vs
         ON vs.id_sesion = x.id_sesion
  LEFT JOIN (SELECT DISTINCT id_inscripcion FROM vw_etl_val_inscripciones WHERE motivo_rechazo IS NULL) vi
         ON vi.id_inscripcion = x.id_inscripcion;
