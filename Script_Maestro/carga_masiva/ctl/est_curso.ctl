OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_curso.csv'
APPEND
INTO TABLE est_curso
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_curso,
  id_institucion,
  id_ciclo,
  id_grado,
  id_jornada,
  id_modalidad,
  codigo,
  nombre,
  seccion,
  capacidad_maxima,
  estado
)
