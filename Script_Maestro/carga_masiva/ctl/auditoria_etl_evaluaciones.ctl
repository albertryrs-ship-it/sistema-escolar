OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/auditoria_etl_evaluaciones.csv'
APPEND
INTO TABLE auditoria_etl_evaluaciones
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_ejecucion,
  fuente,
  inicio TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fin TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  estado,
  total_leidos,
  insertados,
  actualizados,
  rechazados
)
