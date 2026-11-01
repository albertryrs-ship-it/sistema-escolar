OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_periodo_academico.csv'
APPEND
INTO TABLE est_periodo_academico
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_periodo,
  id_ciclo,
  numero,
  nombre,
  fecha_inicio DATE "YYYY-MM-DD",
  fecha_fin DATE "YYYY-MM-DD"
)
