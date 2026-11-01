OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_asignacion_docente.csv'
APPEND
INTO TABLE trx_asignacion_docente
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_asignacion,
  id_docente,
  id_curso_asignatura,
  fecha_asignacion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_inicio DATE "YYYY-MM-DD",
  fecha_fin DATE "YYYY-MM-DD",
  estado
)
