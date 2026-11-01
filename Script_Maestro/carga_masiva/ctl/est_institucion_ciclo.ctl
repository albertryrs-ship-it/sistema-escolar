OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_institucion_ciclo.csv'
APPEND
INTO TABLE est_institucion_ciclo
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_institucion,
  id_ciclo,
  id_tipo_institucion,
  id_departamento,
  id_zona,
  permite_becas,
  fecha_corte_matricula DATE "YYYY-MM-DD",
  estado
)
