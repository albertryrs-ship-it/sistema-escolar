OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/est_plazo_registro_notas.csv'
APPEND
INTO TABLE est_plazo_registro_notas
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_plazo_registro_notas,
  id_institucion,
  id_ciclo,
  id_grado,
  id_periodo,
  tipo_intento,
  fecha_inicio_recuperacion DATE "YYYY-MM-DD",
  fecha_fin_recuperacion DATE "YYYY-MM-DD",
  fecha_apertura_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_limite_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  fecha_cierre_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS",
  estado
)
