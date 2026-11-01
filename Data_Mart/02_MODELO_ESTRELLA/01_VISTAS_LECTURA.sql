-- ==============================================================
-- SECCIÓN 1: VISTAS DE LECTURA DEL STAGING
-- Descripción: El staging guarda una copia completa por cada carga y no se edita. Estas vistas leen solo
--   la última carga COMPLETADA: vw_etl_ultima_carga da su id y cada vw_etl_stg_<tabla> filtra por él.
-- ==============================================================

-- Se ejecuta desde INSTALAR_MODELO_ESTRELLA.sql, que fija las opciones de la sesión.

-- === VW_ETL_ULTIMA_CARGA ===
CREATE OR REPLACE VIEW vw_etl_ultima_carga AS
SELECT MAX(a.id_ejecucion) AS id_carga
  FROM auditoria_etl_evaluaciones a
 WHERE a.estado = 'COMPLETADA'
   AND EXISTS (SELECT 1 FROM stg_ciclos s WHERE s.id_ejecucion_carga = a.id_ejecucion);

-- === VW_ETL_STG_CALIFICACIONES ===
CREATE OR REPLACE VIEW vw_etl_stg_calificaciones AS
SELECT id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion
  FROM stg_calificaciones
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_ASISTENCIAS ===
CREATE OR REPLACE VIEW vw_etl_stg_asistencias AS
SELECT id_asistencia, id_inscripcion, id_sesion, estado, hora_llegada, fecha_registro, observaciones
  FROM stg_asistencias
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_INSCRIPCIONES ===
CREATE OR REPLACE VIEW vw_etl_stg_inscripciones AS
SELECT id_inscripcion, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, estado, motivo_fin_inscripcion, resultado_cierre
  FROM stg_inscripciones
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_ESTUDIANTES ===
CREATE OR REPLACE VIEW vw_etl_stg_estudiantes AS
SELECT id_estudiante, id_persona, nie, fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, sexo
  FROM stg_estudiantes
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_CICLOS ===
CREATE OR REPLACE VIEW vw_etl_stg_ciclos AS
SELECT id_ciclo, codigo, nombre, anio, fecha_inicio, fecha_fin, estado
  FROM stg_ciclos
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_PERIODOS ===
CREATE OR REPLACE VIEW vw_etl_stg_periodos AS
SELECT id_periodo, id_ciclo, numero, nombre, fecha_inicio, fecha_fin
  FROM stg_periodos
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_CURSOS ===
CREATE OR REPLACE VIEW vw_etl_stg_cursos AS
SELECT id_curso, id_institucion, id_ciclo, id_grado, id_jornada, id_modalidad, codigo, nombre, seccion, capacidad_maxima, estado
  FROM stg_cursos
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_CURSOS_ASIGNATURAS ===
CREATE OR REPLACE VIEW vw_etl_stg_cursos_asignaturas AS
SELECT id_curso_asignatura, id_curso, id_asignatura, horas_semanales, creditos, tipo_resultado, regla_recuperacion, estado
  FROM stg_cursos_asignaturas
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_PONDERACIONES ===
CREATE OR REPLACE VIEW vw_etl_stg_ponderaciones AS
SELECT id_ponderacion_periodo, id_curso_asignatura, id_periodo, peso, estado
  FROM stg_ponderaciones
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_RESULTADOS_PERIODO ===
CREATE OR REPLACE VIEW vw_etl_stg_resultados_periodo AS
SELECT id_resultado, id_estudiante, id_asignatura, id_periodo, id_calificacion_seleccionada, version, criterio, fecha_seleccion, fecha_cierre
  FROM stg_resultados_periodo
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_SESIONES ===
CREATE OR REPLACE VIEW vw_etl_stg_sesiones AS
SELECT id_sesion, id_ponderacion_periodo, id_asignacion, fecha_academica, inicio, fin, estado
  FROM stg_sesiones
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_ASIGNACIONES_DOCENTES ===
CREATE OR REPLACE VIEW vw_etl_stg_asignaciones_docentes AS
SELECT id_asignacion, id_docente, id_curso_asignatura, fecha_asignacion, fecha_inicio, fecha_fin, estado
  FROM stg_asignaciones_docentes
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_INSTITUCIONES ===
CREATE OR REPLACE VIEW vw_etl_stg_instituciones AS
SELECT id_institucion, codigo_institucion, nombre, id_tipo_institucion, id_departamento, id_zona, permite_becas, fecha_creacion, activo
  FROM stg_instituciones
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_INSTITUCIONES_CICLO ===
CREATE OR REPLACE VIEW vw_etl_stg_instituciones_ciclo AS
SELECT id_institucion, id_ciclo, id_tipo_institucion, id_departamento, id_zona, permite_becas, fecha_corte_matricula, estado
  FROM stg_instituciones_ciclo
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_GRADOS ===
CREATE OR REPLACE VIEW vw_etl_stg_grados AS
SELECT id_grado, id_nivel, codigo, nombre, orden, es_ultimo_grado
  FROM stg_grados
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_NIVELES ===
CREATE OR REPLACE VIEW vw_etl_stg_niveles AS
SELECT id_nivel, codigo, nombre, orden
  FROM stg_niveles
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_BECAS ===
CREATE OR REPLACE VIEW vw_etl_stg_becas AS
SELECT id_beca, id_inscripcion, id_tipo_beca, porcentaje, fecha_otorgamiento, fecha_registro
  FROM stg_becas
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_BECAS_VIGENCIA ===
CREATE OR REPLACE VIEW vw_etl_stg_becas_vigencia AS
SELECT id_vigencia, id_beca, fecha_inicio, fecha_fin, motivo_fin, fecha_registro
  FROM stg_becas_vigencia
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_ASIGNATURAS ===
CREATE OR REPLACE VIEW vw_etl_stg_asignaturas AS
SELECT id_asignatura, codigo, nombre, id_area, descripcion, activo
  FROM stg_asignaturas
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_DEPARTAMENTOS ===
CREATE OR REPLACE VIEW vw_etl_stg_departamentos AS
SELECT id_departamento, codigo, nombre, activo
  FROM stg_departamentos
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_TIPOS_INSTITUCION ===
CREATE OR REPLACE VIEW vw_etl_stg_tipos_institucion AS
SELECT id_tipo_institucion, codigo, descripcion, activo
  FROM stg_tipos_institucion
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_JORNADAS ===
CREATE OR REPLACE VIEW vw_etl_stg_jornadas AS
SELECT id_jornada, codigo, descripcion, activo
  FROM stg_jornadas
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_MODALIDADES ===
CREATE OR REPLACE VIEW vw_etl_stg_modalidades AS
SELECT id_modalidad, codigo, descripcion, activo
  FROM stg_modalidades
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_DOCENTES ===
CREATE OR REPLACE VIEW vw_etl_stg_docentes AS
SELECT id_docente, id_persona, especialidad, fecha_registro_docente, docente_activo, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido
  FROM stg_docentes
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_ZONAS ===
CREATE OR REPLACE VIEW vw_etl_stg_zonas AS
SELECT id_zona, nombre, activo
  FROM stg_zonas
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);

-- === VW_ETL_STG_AREAS_CONOCIMIENTO ===
CREATE OR REPLACE VIEW vw_etl_stg_areas_conocimiento AS
SELECT id_area, codigo, descripcion, activo
  FROM stg_areas_conocimiento
 WHERE id_ejecucion_carga = (SELECT id_carga FROM vw_etl_ultima_carga);
