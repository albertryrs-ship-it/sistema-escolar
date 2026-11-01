OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/trx_asistencia.csv'
APPEND
INTO TABLE trx_asistencia
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_asistencia,
  id_inscripcion,
  id_sesion,
  estado,
  hora_llegada TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  observaciones
)
