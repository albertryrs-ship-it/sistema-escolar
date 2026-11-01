OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_ponderacion_periodo.csv'
APPEND
INTO TABLE est_ponderacion_periodo
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_ponderacion_periodo,
  id_curso_asignatura,
  id_periodo,
  peso,
  estado
)
