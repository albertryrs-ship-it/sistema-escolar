OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/mae_institucion.csv'
APPEND
INTO TABLE mae_institucion
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_institucion,
  codigo_institucion,
  nombre,
  id_tipo_institucion,
  id_departamento,
  id_zona,
  permite_becas,
  direccion,
  telefono,
  email,
  fecha_creacion DATE "YYYY-MM-DD",
  activo
)
