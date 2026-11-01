OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_sesion_clase.csv'
APPEND
INTO TABLE trx_sesion_clase
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_sesion,
  id_ponderacion_periodo,
  id_asignacion,
  fecha_academica DATE "YYYY-MM-DD",
  inicio TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fin TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  estado,
  observaciones
)
