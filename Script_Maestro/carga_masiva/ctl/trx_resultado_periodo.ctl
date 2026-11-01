OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_resultado_periodo.csv'
APPEND
INTO TABLE trx_resultado_periodo
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_resultado,
  id_estudiante,
  id_asignatura,
  id_periodo,
  id_calificacion_seleccionada,
  version,
  criterio,
  fecha_seleccion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_cierre TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)
