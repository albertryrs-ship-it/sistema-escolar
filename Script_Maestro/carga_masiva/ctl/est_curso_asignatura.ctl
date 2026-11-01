OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_curso_asignatura.csv'
APPEND
INTO TABLE est_curso_asignatura
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_curso_asignatura,
  id_curso,
  id_asignatura,
  horas_semanales,
  creditos,
  tipo_resultado,
  regla_recuperacion,
  estado
)
