OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_beca.csv'
APPEND
INTO TABLE trx_beca
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_beca,
  id_inscripcion,
  id_tipo_beca,
  porcentaje,
  fecha_otorgamiento DATE "YYYY-MM-DD",
  fecha_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  observaciones
)
