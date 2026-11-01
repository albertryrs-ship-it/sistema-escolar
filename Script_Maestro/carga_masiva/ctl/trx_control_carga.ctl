OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_control_carga.csv'
APPEND
INTO TABLE trx_control_carga
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_control,
  id_curso,
  id_periodo,
  dominio,
  fecha_corte DATE "YYYY-MM-DD",
  estado,
  registros_declarados,
  fecha_recepcion TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  id_ejecucion
)
