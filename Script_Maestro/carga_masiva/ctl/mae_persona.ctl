OPTIONS (ERRORS=0, ROWS=5000, BINDSIZE=20971520, READSIZE=20971520)
LOAD DATA
CHARACTERSET AL32UTF8
INFILE 'datos/mae_persona.csv'
APPEND
INTO TABLE mae_persona
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  id_persona,
  id_tipo_documento,
  numero_documento,
  primer_nombre,
  segundo_nombre,
  primer_apellido,
  segundo_apellido,
  fecha_nacimiento DATE "YYYY-MM-DD",
  sexo,
  email,
  telefono,
  direccion,
  fecha_registro TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
)
