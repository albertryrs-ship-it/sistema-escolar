OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_calificacion.csv'
APPEND
INTO TABLE trx_calificacion
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_calificacion,
  id_inscripcion,
  id_ponderacion_periodo,
  tipo_intento,
  numero_intento,
  version,
  id_calificacion_ordinaria,
  id_calificacion_sustituida,
  id_asignacion_docente,
  id_docente_registra,
  nota,
  resultado_cualitativo,
  fecha_evaluacion DATE "YYYY-MM-DD",
  fecha_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_validacion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_anulacion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  motivo_anulacion
)
