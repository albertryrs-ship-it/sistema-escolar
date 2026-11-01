OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_inscripcion.csv'
APPEND
INTO TABLE trx_inscripcion
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_inscripcion,
  id_estudiante,
  id_curso,
  fecha_inscripcion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_inicio DATE "YYYY-MM-DD",
  fecha_fin DATE "YYYY-MM-DD",
  estado,
  motivo_fin_inscripcion,
  resultado_cierre
)
