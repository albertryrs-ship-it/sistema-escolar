-- ==============================================================
-- SCRIPT_BASE.sql: TABLAS DE OPERACIÓN (OLTP)
-- Descripción: Crea las 33 tablas del modelo educativo con sus claves, CHECK y comentarios.
--   Solo en un esquema vacío: no migra ni reemplaza un OLTP existente.
--   Las reglas que cruzan tablas se instalan después, con Validacion/INSTALAR_VALIDACIONES.sql.
-- ==============================================================
-- Oracle Database 23ai (también 19c y 21c). Ejecutar como script en SQL*Plus o SQLcl.
-- Sesión dedicada, sin trabajo pendiente. No usar SYS/SYSTEM.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';


-- === Requisito: ninguna de las tablas existe ===
DECLARE v_n NUMBER; BEGIN
 SELECT COUNT(*) INTO v_n FROM user_tables WHERE table_name IN ('CAT_TIPO_DOCUMENTO','CAT_TIPO_INSTITUCION','CAT_DEPARTAMENTO','CAT_ZONA','CAT_MODALIDAD','CAT_JORNADA','CAT_AREA_CONOCIMIENTO','CAT_TIPO_BECA','CAT_NIVEL','CAT_GRADO','MAE_INSTITUCION','MAE_PERSONA','MAE_ESTUDIANTE','MAE_DOCENTE','MAE_ASIGNATURA','EST_CICLO','EST_PERIODO_ACADEMICO','EST_INSTITUCION_CICLO','EST_CURSO','EST_CURSO_ASIGNATURA','EST_PONDERACION_PERIODO','EST_PLAZO_REGISTRO_NOTAS','TRX_ASIGNACION_DOCENTE','TRX_INSCRIPCION','TRX_CALIFICACION','TRX_RESULTADO_PERIODO','TRX_SESION_CLASE','TRX_ASISTENCIA','TRX_BECA','TRX_BECA_VIGENCIA','AUDITORIA_ETL_EVALUACIONES','ERRORES_ETL_EVALUACIONES','TRX_CONTROL_CARGA');
 IF v_n<>0 THEN RAISE_APPLICATION_ERROR(-20070,'El DDL de referencia requiere que no exista ninguna de sus tablas.'); END IF;
END;
/

-- ==============================================================
-- SECCIÓN 1: CATÁLOGOS
-- Descripción: Listas de valores: tipos de documento, departamentos, zonas, niveles, grados…
-- ==============================================================

-- === CAT_TIPO_DOCUMENTO ===
-- Tipos de documento personal.
CREATE TABLE cat_tipo_documento (
    id_tipo_documento NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_tipo_documento PRIMARY KEY (id_tipo_documento),
    CONSTRAINT uk_tipo_documento_codigo UNIQUE (codigo),
    CONSTRAINT ck_tipo_documento_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_tipo_documento IS 'Tipos de documento personal';
COMMENT ON COLUMN cat_tipo_documento.id_tipo_documento IS 'Identificador interno y único del tipo de documento; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_tipo_documento.codigo IS 'Código único y estable para reconocer el tipo de documento en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_tipo_documento.descripcion IS 'Nombre o descripción legible del tipo de documento; por ejemplo, DUI o pasaporte.';
COMMENT ON COLUMN cat_tipo_documento.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_TIPO_INSTITUCION ===
-- Clasificacion institucional.
CREATE TABLE cat_tipo_institucion (
    id_tipo_institucion NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_tipo_institucion PRIMARY KEY (id_tipo_institucion),
    CONSTRAINT uk_tipo_institucion_codigo UNIQUE (codigo),
    CONSTRAINT ck_tipo_institucion_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_tipo_institucion IS 'Clasificacion institucional';
COMMENT ON COLUMN cat_tipo_institucion.id_tipo_institucion IS 'Identificador interno y único del tipo de institución; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_tipo_institucion.codigo IS 'Código único y estable para reconocer el tipo de institución en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_tipo_institucion.descripcion IS 'Nombre o descripción legible del tipo de institución; por ejemplo, pública, privada o mixta.';
COMMENT ON COLUMN cat_tipo_institucion.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_DEPARTAMENTO ===
-- Departamentos.
CREATE TABLE cat_departamento (
    id_departamento NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_departamento PRIMARY KEY (id_departamento),
    CONSTRAINT uk_departamento_codigo UNIQUE (codigo),
    CONSTRAINT ck_departamento_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_departamento IS 'Departamentos';
COMMENT ON COLUMN cat_departamento.id_departamento IS 'Identificador interno y único del departamento; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_departamento.codigo IS 'Código estable del departamento utilizado por la fuente territorial; facilita conciliar archivos. Se conserva el identificador interno como PK.';
COMMENT ON COLUMN cat_departamento.nombre IS 'Nombre legible del departamento; por ejemplo, San Salvador.';
COMMENT ON COLUMN cat_departamento.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_ZONA ===
-- Zona urbana o rural del centro.
CREATE TABLE cat_zona (
    id_zona NUMBER(10,0) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_zona PRIMARY KEY (id_zona),
    CONSTRAINT uk_zona_nombre UNIQUE (nombre),
    CONSTRAINT ck_zona_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_zona IS 'Zona urbana o rural del centro';
COMMENT ON COLUMN cat_zona.id_zona IS 'Identificador interno y único de la zona del centro educativo; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_zona.nombre IS 'Nombre único de la zona del centro educativo, como Urbana o Rural; se usa para mostrar y filtrar indicadores.';
COMMENT ON COLUMN cat_zona.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_MODALIDAD ===
-- Presencial, en linea o semipresencial.
CREATE TABLE cat_modalidad (
    id_modalidad NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_modalidad PRIMARY KEY (id_modalidad),
    CONSTRAINT uk_modalidad_codigo UNIQUE (codigo),
    CONSTRAINT ck_modalidad_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_modalidad IS 'Presencial, en linea o semipresencial';
COMMENT ON COLUMN cat_modalidad.id_modalidad IS 'Identificador interno y único de la modalidad de enseñanza; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_modalidad.codigo IS 'Código único y estable para reconocer la modalidad de enseñanza en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_modalidad.descripcion IS 'Nombre o descripción legible de la modalidad de enseñanza; por ejemplo, presencial, en línea o semipresencial.';
COMMENT ON COLUMN cat_modalidad.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_JORNADA ===
-- Matutina, vespertina, nocturna u otra acordada.
CREATE TABLE cat_jornada (
    id_jornada NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_jornada PRIMARY KEY (id_jornada),
    CONSTRAINT uk_jornada_codigo UNIQUE (codigo),
    CONSTRAINT ck_jornada_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_jornada IS 'Matutina, vespertina, nocturna u otra acordada';
COMMENT ON COLUMN cat_jornada.id_jornada IS 'Identificador interno y único de la jornada del grupo; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_jornada.codigo IS 'Código único y estable para reconocer la jornada del grupo en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_jornada.descripcion IS 'Nombre o descripción legible de la jornada del grupo; por ejemplo, matutina, vespertina o nocturna.';
COMMENT ON COLUMN cat_jornada.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_AREA_CONOCIMIENTO ===
-- Areas de conocimiento.
CREATE TABLE cat_area_conocimiento (
    id_area NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_area_conocimiento PRIMARY KEY (id_area),
    CONSTRAINT uk_area_conocimiento_codigo UNIQUE (codigo),
    CONSTRAINT ck_area_conocimiento_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_area_conocimiento IS 'Areas de conocimiento';
COMMENT ON COLUMN cat_area_conocimiento.id_area IS 'Identificador interno y único del área de conocimiento; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_area_conocimiento.codigo IS 'Código único y estable para reconocer el área de conocimiento en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_area_conocimiento.descripcion IS 'Nombre o descripción legible del área de conocimiento; por ejemplo, Ciencias o Lenguaje.';
COMMENT ON COLUMN cat_area_conocimiento.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_TIPO_BECA ===
-- Tipo y motivo de beca.
CREATE TABLE cat_tipo_beca (
    id_tipo_beca NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    descripcion VARCHAR2(500 CHAR) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_tipo_beca PRIMARY KEY (id_tipo_beca),
    CONSTRAINT uk_tipo_beca_codigo UNIQUE (codigo),
    CONSTRAINT ck_tipo_beca_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE cat_tipo_beca IS 'Tipo y motivo de beca';
COMMENT ON COLUMN cat_tipo_beca.id_tipo_beca IS 'Identificador interno y único del tipo o motivo de beca; permite referenciarlo desde otras tablas.';
COMMENT ON COLUMN cat_tipo_beca.codigo IS 'Código único y estable para reconocer el tipo o motivo de beca en archivos, integraciones y consultas.';
COMMENT ON COLUMN cat_tipo_beca.descripcion IS 'Nombre o descripción legible del tipo o motivo de beca; por ejemplo, apoyo económico o mérito académico.';
COMMENT ON COLUMN cat_tipo_beca.activo IS 'Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas.';

-- === CAT_NIVEL ===
-- Nivel educativo.
CREATE TABLE cat_nivel (
    id_nivel NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    orden NUMBER(10,0) NOT NULL,
    CONSTRAINT pk_nivel PRIMARY KEY (id_nivel),
    CONSTRAINT uk_nivel_codigo UNIQUE (codigo)
);
COMMENT ON TABLE cat_nivel IS 'Nivel educativo';
COMMENT ON COLUMN cat_nivel.id_nivel IS 'Identificador interno del nivel educativo.';
COMMENT ON COLUMN cat_nivel.codigo IS 'Código único y estable del nivel; por ejemplo, BAS para básica.';
COMMENT ON COLUMN cat_nivel.nombre IS 'Nombre del nivel escolar; por ejemplo, parvularia, básica o bachillerato.';
COMMENT ON COLUMN cat_nivel.orden IS 'Posición del nivel en la secuencia educativa; permite ordenar reportes sin depender del nombre.';

-- === CAT_GRADO ===
-- Grado perteneciente a un nivel.
CREATE TABLE cat_grado (
    id_grado NUMBER(10,0) NOT NULL,
    id_nivel NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    orden NUMBER(10,0) NOT NULL,
    es_ultimo_grado NUMBER(1) NOT NULL,
    CONSTRAINT pk_grado PRIMARY KEY (id_grado),
    CONSTRAINT uk_grado_nivel_codigo UNIQUE (id_nivel,codigo),
    CONSTRAINT ck_grado_es_ultimo_grado CHECK (es_ultimo_grado IN (0,1))
);
COMMENT ON TABLE cat_grado IS 'Grado perteneciente a un nivel';
COMMENT ON COLUMN cat_grado.id_grado IS 'Identificador interno del grado; se utiliza para clasificar los cursos.';
COMMENT ON COLUMN cat_grado.id_nivel IS 'Nivel educativo al que pertenece el grado.';
COMMENT ON COLUMN cat_grado.codigo IS 'Código del grado dentro del nivel; debe ser único junto con id_nivel.';
COMMENT ON COLUMN cat_grado.nombre IS 'Nombre del grado; por ejemplo, Octavo o Primero de bachillerato. La sección se define en est_curso.';
COMMENT ON COLUMN cat_grado.orden IS 'Posición del grado dentro de su nivel; ayuda a presentar la secuencia de grados.';
COMMENT ON COLUMN cat_grado.es_ultimo_grado IS 'Indica que es el último grado cubierto por el proyecto. Para excluir a una persona de la cohorte de retención también se exige resultado GRADUADO; cursar este grado no demuestra graduación.';

-- ==============================================================
-- SECCIÓN 2: MAESTROS
-- Descripción: Personas, estudiantes, docentes, instituciones y asignaturas.
-- ==============================================================

-- === MAE_INSTITUCION ===
-- Identidad estable y configuracion actual del centro.
CREATE TABLE mae_institucion (
    id_institucion NUMBER(10,0) NOT NULL,
    codigo_institucion VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    id_tipo_institucion NUMBER(10,0) NOT NULL,
    id_departamento NUMBER(10,0) NOT NULL,
    id_zona NUMBER(10,0) NOT NULL,
    permite_becas NUMBER(1) NOT NULL,
    direccion VARCHAR2(500 CHAR) NOT NULL,
    telefono VARCHAR2(30 CHAR),
    email VARCHAR2(254 CHAR),
    fecha_creacion DATE NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_institucion PRIMARY KEY (id_institucion),
    CONSTRAINT uk_institucion_codigo_institucion UNIQUE (codigo_institucion),
    CONSTRAINT ck_institucion_permite_becas CHECK (permite_becas IN (0,1)),
    CONSTRAINT ck_institucion_fecha_creacion CHECK (fecha_creacion = TRUNC(fecha_creacion)),
    CONSTRAINT ck_institucion_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE mae_institucion IS 'Identidad estable y configuracion actual del centro';
COMMENT ON COLUMN mae_institucion.id_institucion IS 'Identificador interno y estable del centro educativo; se conserva aunque cambien sus datos.';
COMMENT ON COLUMN mae_institucion.codigo_institucion IS 'Código único del centro utilizado para reconocerlo en las fuentes e integraciones.';
COMMENT ON COLUMN mae_institucion.nombre IS 'Nombre del centro educativo que se muestra en consultas y reportes.';
COMMENT ON COLUMN mae_institucion.id_tipo_institucion IS 'Clasificación actual del centro, como público, privado o mixto. La clasificación histórica por ciclo se conserva en est_institucion_ciclo.';
COMMENT ON COLUMN mae_institucion.id_departamento IS 'Departamento actual del centro; permite agrupar indicadores por territorio. Su valor histórico se conserva por ciclo.';
COMMENT ON COLUMN mae_institucion.id_zona IS 'Zona actual del centro, como urbana o rural. Su valor histórico se conserva por ciclo.';
COMMENT ON COLUMN mae_institucion.permite_becas IS 'Indica si el centro está habilitado para otorgar becas según su configuración actual. Los beneficios efectivamente concedidos se registran en trx_beca.';
COMMENT ON COLUMN mae_institucion.direccion IS 'Dirección física registrada del centro educativo.';
COMMENT ON COLUMN mae_institucion.telefono IS 'Número de contacto del centro; se almacena como texto para conservar prefijos y formato.';
COMMENT ON COLUMN mae_institucion.email IS 'Correo electrónico de contacto del centro.';
COMMENT ON COLUMN mae_institucion.fecha_creacion IS 'Fecha de creación registrada para la institución.';
COMMENT ON COLUMN mae_institucion.activo IS 'Indica si el centro está habilitado para nuevas operaciones; conserva su identidad y sus registros históricos.';

-- === MAE_PERSONA ===
-- Identidad y datos personales compartidos por estudiantes y docentes.
CREATE TABLE mae_persona (
    id_persona NUMBER(10,0) NOT NULL,
    id_tipo_documento NUMBER(10,0),
    numero_documento VARCHAR2(50 CHAR),
    primer_nombre VARCHAR2(100 CHAR) NOT NULL,
    segundo_nombre VARCHAR2(100 CHAR),
    primer_apellido VARCHAR2(100 CHAR) NOT NULL,
    segundo_apellido VARCHAR2(100 CHAR),
    fecha_nacimiento DATE NOT NULL,
    sexo VARCHAR2(30 CHAR),
    email VARCHAR2(254 CHAR),
    telefono VARCHAR2(30 CHAR),
    direccion VARCHAR2(500 CHAR),
    fecha_registro TIMESTAMP(6) NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    CONSTRAINT uk_persona_tipo_documento_numero_documento UNIQUE (id_tipo_documento,numero_documento),
    CONSTRAINT ck_persona_fecha_nacimiento CHECK (fecha_nacimiento = TRUNC(fecha_nacimiento)),
    CONSTRAINT ck_persona_sexo CHECK (sexo IN ('M','F','OTRO')),
    CONSTRAINT ck_persona_documento_completo_o_ausente CHECK ((id_tipo_documento IS NULL AND numero_documento IS NULL) OR (id_tipo_documento IS NOT NULL AND numero_documento IS NOT NULL))
);
COMMENT ON TABLE mae_persona IS 'Identidad y datos personales compartidos por estudiantes y docentes';
COMMENT ON COLUMN mae_persona.id_persona IS 'Identificador interno y estable de la persona; permite compartir su identidad entre los roles de estudiante y docente.';
COMMENT ON COLUMN mae_persona.id_tipo_documento IS 'Tipo del documento personal. Puede omitirse únicamente si también se omite numero_documento.';
COMMENT ON COLUMN mae_persona.numero_documento IS 'Número del documento como texto. Es único junto con id_tipo_documento; conserva ceros iniciales y solo puede omitirse junto con el tipo.';
COMMENT ON COLUMN mae_persona.primer_nombre IS 'Primer nombre de la persona, utilizado para identificarla y mostrarla en listados.';
COMMENT ON COLUMN mae_persona.segundo_nombre IS 'Segundo nombre de la persona, cuando exista o esté informado.';
COMMENT ON COLUMN mae_persona.primer_apellido IS 'Primer apellido de la persona.';
COMMENT ON COLUMN mae_persona.segundo_apellido IS 'Segundo apellido de la persona, cuando exista o esté informado.';
COMMENT ON COLUMN mae_persona.fecha_nacimiento IS 'Fecha de nacimiento; permite calcular la edad a una fecha de corte sin almacenar una edad que cambia con el tiempo.';
COMMENT ON COLUMN mae_persona.sexo IS 'Sexo informado mediante M, F u OTRO; NULL cuando no se informó. El ETL utiliza una equivalencia explícita con las categorías de la fuente.';
COMMENT ON COLUMN mae_persona.email IS 'Correo electrónico de contacto, si está disponible.';
COMMENT ON COLUMN mae_persona.telefono IS 'Teléfono de contacto como texto, si está disponible.';
COMMENT ON COLUMN mae_persona.direccion IS 'Dirección de residencia informada de la persona. Los KPI territoriales del proyecto utilizan el departamento histórico del centro educativo.';
COMMENT ON COLUMN mae_persona.fecha_registro IS 'Fecha y hora en que se creó la identidad compartida en el sistema; las altas de los roles se registran por separado.';

-- === MAE_ESTUDIANTE ===
-- Rol de estudiante vinculado a una identidad personal compartida.
CREATE TABLE mae_estudiante (
    id_estudiante NUMBER(10,0) NOT NULL,
    id_persona NUMBER(10,0) NOT NULL,
    nie VARCHAR2(30 CHAR) NOT NULL,
    fecha_registro TIMESTAMP(6) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT uk_estudiante_persona UNIQUE (id_persona),
    CONSTRAINT uk_estudiante_nie UNIQUE (nie),
    CONSTRAINT ck_estudiante_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE mae_estudiante IS 'Rol de estudiante vinculado a una identidad personal compartida';
COMMENT ON COLUMN mae_estudiante.id_estudiante IS 'Identificador interno y estable del estudiante; enlaza su historial aunque cambie de curso o institución.';
COMMENT ON COLUMN mae_estudiante.id_persona IS 'Persona que posee este rol de estudiante. Es obligatoria y única dentro del rol; los datos personales se consultan en mae_persona.';
COMMENT ON COLUMN mae_estudiante.nie IS 'Número de Identificación del Estudiante, único. Se guarda como texto para conservar los ceros iniciales.';
COMMENT ON COLUMN mae_estudiante.fecha_registro IS 'Fecha y hora de creación del rol de estudiante; puede ser distinta de la fecha de creación de la persona.';
COMMENT ON COLUMN mae_estudiante.activo IS 'Indica si la identidad está habilitada para nuevas operaciones. La matrícula vigente se determina con trx_inscripcion y sus fechas.';

-- === MAE_DOCENTE ===
-- Rol de docente vinculado a una identidad personal compartida.
CREATE TABLE mae_docente (
    id_docente NUMBER(10,0) NOT NULL,
    id_persona NUMBER(10,0) NOT NULL,
    especialidad VARCHAR2(250 CHAR),
    fecha_registro TIMESTAMP(6) NOT NULL,
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_docente PRIMARY KEY (id_docente),
    CONSTRAINT uk_docente_persona UNIQUE (id_persona),
    CONSTRAINT ck_docente_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE mae_docente IS 'Rol de docente vinculado a una identidad personal compartida';
COMMENT ON COLUMN mae_docente.id_docente IS 'Identificador interno y estable del docente; permite seguir sus asignaciones en diferentes centros y ciclos.';
COMMENT ON COLUMN mae_docente.id_persona IS 'Persona que posee este rol de docente. Es obligatoria y única dentro del rol; los datos personales se consultan en mae_persona.';
COMMENT ON COLUMN mae_docente.especialidad IS 'Especialidad académica o profesional informada del docente.';
COMMENT ON COLUMN mae_docente.fecha_registro IS 'Fecha y hora de creación del rol de docente; puede ser distinta de la fecha de creación de la persona.';
COMMENT ON COLUMN mae_docente.activo IS 'Indica si la identidad está habilitada para nuevas operaciones. Los grupos y centros donde enseña se obtienen de sus asignaciones y vigencias.';

-- === MAE_ASIGNATURA ===
-- Identidad de la materia; sin horas ni creditos dependientes del grupo.
CREATE TABLE mae_asignatura (
    id_asignatura NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    id_area NUMBER(10,0) NOT NULL,
    descripcion VARCHAR2(500 CHAR),
    activo NUMBER(1) NOT NULL,
    CONSTRAINT pk_asignatura PRIMARY KEY (id_asignatura),
    CONSTRAINT uk_asignatura_codigo UNIQUE (codigo),
    CONSTRAINT ck_asignatura_activo CHECK (activo IN (0,1))
);
COMMENT ON TABLE mae_asignatura IS 'Identidad de la materia; sin horas ni creditos dependientes del grupo';
COMMENT ON COLUMN mae_asignatura.id_asignatura IS 'Identificador interno y único de la materia; permite relacionarla con los grupos donde se ofrece.';
COMMENT ON COLUMN mae_asignatura.codigo IS 'Código único y estable de la materia; por ejemplo, MAT para Matemática.';
COMMENT ON COLUMN mae_asignatura.nombre IS 'Nombre de la materia que se muestra en horarios, consultas y reportes.';
COMMENT ON COLUMN mae_asignatura.id_area IS 'Área de conocimiento a la que pertenece la materia; permite agrupar resultados de materias relacionadas.';
COMMENT ON COLUMN mae_asignatura.descripcion IS 'Detalle opcional sobre el contenido o propósito de la materia.';
COMMENT ON COLUMN mae_asignatura.activo IS 'Indica si la materia puede incorporarse a nuevas ofertas; desactivarla conserva sus resultados históricos.';

-- ==============================================================
-- SECCIÓN 3: ESTRUCTURA ACADÉMICA
-- Descripción: Ciclos, períodos, cursos, oferta de materias, planes de pesos y plazos de notas.
-- ==============================================================

-- === EST_CICLO ===
-- Calendario académico: año escolar con su propia cantidad de períodos.
CREATE TABLE est_ciclo (
    id_ciclo NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    anio NUMBER(4,0) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_ciclo PRIMARY KEY (id_ciclo),
    CONSTRAINT uk_ciclo_codigo UNIQUE (codigo),
    CONSTRAINT ck_ciclo_fecha_inicio CHECK (fecha_inicio = TRUNC(fecha_inicio)),
    CONSTRAINT ck_ciclo_fecha_fin CHECK (fecha_fin = TRUNC(fecha_fin)),
    CONSTRAINT ck_ciclo_estado CHECK (estado IN ('PLANIFICADO','ABIERTO','CERRADO')),
    CONSTRAINT ck_ciclo_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE est_ciclo IS 'Calendario académico: año escolar con su propia cantidad de períodos';
COMMENT ON COLUMN est_ciclo.id_ciclo IS 'Identificador interno del calendario académico.';
COMMENT ON COLUMN est_ciclo.codigo IS 'Código único del ciclo, utilizado para reconocerlo en las fuentes y consultas.';
COMMENT ON COLUMN est_ciclo.nombre IS 'Nombre legible del ciclo; por ejemplo, Año académico 2026 o Año escolar 2026-2027.';
COMMENT ON COLUMN est_ciclo.anio IS 'Año de referencia del ciclo; si cruza años calendario, es el año de inicio (2026 para agosto 2026–junio 2027). Varios ciclos pueden compartir el mismo año. Facilita filtros y comparaciones interanuales.';
COMMENT ON COLUMN est_ciclo.fecha_inicio IS 'Primer día del ciclo académico; delimita sus períodos y la vigencia ordinaria de las inscripciones.';
COMMENT ON COLUMN est_ciclo.fecha_fin IS 'Último día del ciclo académico. Limita la matrícula efectiva; una recuperación posterior puede autorizarse mediante su ventana específica.';
COMMENT ON COLUMN est_ciclo.estado IS 'Situación administrativa del ciclo: planificado, abierto o cerrado. El cierre interviene en la publicación de resultados finales.';

-- === EST_PERIODO_ACADEMICO ===
-- Periodos de evaluacion dentro de un ciclo.
CREATE TABLE est_periodo_academico (
    id_periodo NUMBER(10,0) NOT NULL,
    id_ciclo NUMBER(10,0) NOT NULL,
    numero NUMBER(10,0) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT pk_periodo_academico PRIMARY KEY (id_periodo),
    CONSTRAINT uk_periodo_academico_ciclo_numero UNIQUE (id_ciclo,numero),
    CONSTRAINT ck_periodo_academico_fecha_inicio CHECK (fecha_inicio = TRUNC(fecha_inicio)),
    CONSTRAINT ck_periodo_academico_fecha_fin CHECK (fecha_fin = TRUNC(fecha_fin)),
    CONSTRAINT ck_periodo_academico_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE est_periodo_academico IS 'Periodos de evaluacion dentro de un ciclo';
COMMENT ON COLUMN est_periodo_academico.id_periodo IS 'Identificador interno del período de evaluación.';
COMMENT ON COLUMN est_periodo_academico.id_ciclo IS 'Ciclo académico al que pertenece el período.';
COMMENT ON COLUMN est_periodo_academico.numero IS 'Posición del período dentro del ciclo: entero positivo, numerado desde 1 en orden temporal. La cantidad de períodos depende del ciclo. Es única junto con id_ciclo.';
COMMENT ON COLUMN est_periodo_academico.nombre IS 'Nombre legible del período; por ejemplo, Primer trimestre o Período 4.';
COMMENT ON COLUMN est_periodo_academico.fecha_inicio IS 'Primer día académico del período; debe estar dentro del ciclo y respetar el orden de los períodos.';
COMMENT ON COLUMN est_periodo_academico.fecha_fin IS 'Último día académico del período; permite saber si ya concluyó. Puede diferir de la fecha límite para cargar sus notas.';

-- === EST_INSTITUCION_CICLO ===
-- Contexto institucional congelado para el ciclo.
CREATE TABLE est_institucion_ciclo (
    id_institucion NUMBER(10,0) NOT NULL,
    id_ciclo NUMBER(10,0) NOT NULL,
    id_tipo_institucion NUMBER(10,0) NOT NULL,
    id_departamento NUMBER(10,0) NOT NULL,
    id_zona NUMBER(10,0) NOT NULL,
    permite_becas NUMBER(1) NOT NULL,
    fecha_corte_matricula DATE NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_institucion_ciclo PRIMARY KEY (id_institucion,id_ciclo),
    CONSTRAINT ck_institucion_ciclo_permite_becas CHECK (permite_becas IN (0,1)),
    CONSTRAINT ck_institucion_ciclo_fecha_corte_matricula CHECK (fecha_corte_matricula = TRUNC(fecha_corte_matricula)),
    CONSTRAINT ck_institucion_ciclo_estado CHECK (estado IN ('PLANIFICADO','ABIERTO','CERRADO'))
);
COMMENT ON TABLE est_institucion_ciclo IS 'Contexto institucional congelado para el ciclo';
COMMENT ON COLUMN est_institucion_ciclo.id_institucion IS 'Centro cuyo contexto se conserva para el año académico; forma parte de la clave primaria compuesta.';
COMMENT ON COLUMN est_institucion_ciclo.id_ciclo IS 'Ciclo para el que se conserva ese contexto; completa la clave primaria con id_institucion.';
COMMENT ON COLUMN est_institucion_ciclo.id_tipo_institucion IS 'Tipo institucional que se utiliza para analizar ese ciclo, aunque la clasificación actual del centro cambie posteriormente.';
COMMENT ON COLUMN est_institucion_ciclo.id_departamento IS 'Departamento institucional conservado para el ciclo; es la referencia territorial histórica de los KPI.';
COMMENT ON COLUMN est_institucion_ciclo.id_zona IS 'Zona urbana o rural conservada para el ciclo, utilizada en comparaciones históricas.';
COMMENT ON COLUMN est_institucion_ciclo.permite_becas IS 'Habilitación para otorgar becas conservada para ese ciclo; permite validar beneficios con la configuración histórica.';
COMMENT ON COLUMN est_institucion_ciclo.fecha_corte_matricula IS 'Día de referencia para observar la población matriculada del centro en el ciclo y comparar cohortes. No es la fecha de inscripción de una persona ni una fecha límite para inscribirse.';
COMMENT ON COLUMN est_institucion_ciclo.estado IS 'Situación administrativa del contexto institucional del ciclo: planificado, abierto o cerrado.';

-- === EST_CURSO ===
-- Grupo concreto de una institucion durante un ciclo.
CREATE TABLE est_curso (
    id_curso NUMBER(10,0) NOT NULL,
    id_institucion NUMBER(10,0) NOT NULL,
    id_ciclo NUMBER(10,0) NOT NULL,
    id_grado NUMBER(10,0) NOT NULL,
    id_jornada NUMBER(10,0) NOT NULL,
    id_modalidad NUMBER(10,0) NOT NULL,
    codigo VARCHAR2(50 CHAR) NOT NULL,
    nombre VARCHAR2(150 CHAR) NOT NULL,
    seccion VARCHAR2(20 CHAR) NOT NULL,
    capacidad_maxima NUMBER(10,0) NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_curso PRIMARY KEY (id_curso),
    CONSTRAINT uk_curso_institucion_ciclo_grado_jornada_seccion UNIQUE (id_institucion,id_ciclo,id_grado,id_jornada,seccion),
    CONSTRAINT ck_curso_capacidad_maxima CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_curso_estado CHECK (estado IN ('PLANIFICADO','ACTIVO','CERRADO','ANULADO'))
);
COMMENT ON TABLE est_curso IS 'Grupo concreto de una institucion durante un ciclo';
COMMENT ON COLUMN est_curso.id_curso IS 'Identificador interno del grupo concreto de un año académico; por ejemplo, Octavo A nocturno de un centro en 2026.';
COMMENT ON COLUMN est_curso.id_institucion IS 'Centro que ofrece el grupo. Junto con id_ciclo debe existir en est_institucion_ciclo.';
COMMENT ON COLUMN est_curso.id_ciclo IS 'Año académico del grupo; permite diferenciar grupos similares de años distintos.';
COMMENT ON COLUMN est_curso.id_grado IS 'Grado que cursa el grupo; su nivel se obtiene desde cat_grado.';
COMMENT ON COLUMN est_curso.id_jornada IS 'Jornada del grupo, como matutina, vespertina o nocturna.';
COMMENT ON COLUMN est_curso.id_modalidad IS 'Forma de enseñanza del grupo, como presencial, en línea o semipresencial.';
COMMENT ON COLUMN est_curso.codigo IS 'Código operativo del grupo utilizado por la fuente. En el modelo actual no tiene una restricción de unicidad individual.';
COMMENT ON COLUMN est_curso.nombre IS 'Nombre legible del grupo para listados y reportes.';
COMMENT ON COLUMN est_curso.seccion IS 'Identificador de la sección, como A o B; diferencia grupos del mismo centro, ciclo, grado y jornada.';
COMMENT ON COLUMN est_curso.capacidad_maxima IS 'Cantidad máxima de estudiantes prevista simultáneamente en el grupo; debe ser mayor que 0. Por defecto es referencial: solo se exige si se activa la política de capacidad estricta.';
COMMENT ON COLUMN est_curso.estado IS 'Situación del grupo: planificado, activo, cerrado o anulado; ayuda a distinguir la oferta efectiva de registros sin efecto.';

-- === EST_CURSO_ASIGNATURA ===
-- Oferta de asignaturas del grupo.
CREATE TABLE est_curso_asignatura (
    id_curso_asignatura NUMBER(10,0) NOT NULL,
    id_curso NUMBER(10,0) NOT NULL,
    id_asignatura NUMBER(10,0) NOT NULL,
    horas_semanales NUMBER(8,4) NOT NULL,
    creditos NUMBER(8,4),
    tipo_resultado VARCHAR2(30 CHAR) NOT NULL,
    regla_recuperacion VARCHAR2(30 CHAR) NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_curso_asignatura PRIMARY KEY (id_curso_asignatura),
    CONSTRAINT uk_curso_asignatura_curso_asignatura UNIQUE (id_curso,id_asignatura),
    CONSTRAINT ck_curso_asignatura_horas_semanales CHECK (horas_semanales > 0),
    CONSTRAINT ck_curso_asignatura_creditos CHECK (creditos >= 0),
    CONSTRAINT ck_curso_asignatura_tipo_resultado CHECK (tipo_resultado IN ('NUMERICA','CUALITATIVA')),
    CONSTRAINT ck_curso_asignatura_regla_recuperacion CHECK (regla_recuperacion IN ('MEJOR_NOTA','ULTIMA_RECUPERACION')),
    CONSTRAINT ck_curso_asignatura_estado CHECK (estado IN ('PLANIFICADA','ACTIVA','ANULADA'))
);
COMMENT ON TABLE est_curso_asignatura IS 'Oferta de asignaturas del grupo';
COMMENT ON COLUMN est_curso_asignatura.id_curso_asignatura IS 'Identificador de una materia ofrecida en un grupo concreto; enlaza su plan, docentes y actividad académica.';
COMMENT ON COLUMN est_curso_asignatura.id_curso IS 'Grupo en el que se ofrece la materia.';
COMMENT ON COLUMN est_curso_asignatura.id_asignatura IS 'Materia del catálogo que se ofrece en el grupo.';
COMMENT ON COLUMN est_curso_asignatura.horas_semanales IS 'Carga semanal de enseñanza de la materia en este grupo; puede variar entre ofertas de la misma materia.';
COMMENT ON COLUMN est_curso_asignatura.creditos IS 'Créditos asignados a esta oferta si el centro los utiliza; puede quedar NULL cuando no aplica. No modifican automáticamente las reglas de promedio acordadas.';
COMMENT ON COLUMN est_curso_asignatura.tipo_resultado IS 'Indica si la materia registra calificaciones numéricas o resultados cualitativos; evita convertir categorías en números arbitrarios.';
COMMENT ON COLUMN est_curso_asignatura.regla_recuperacion IS 'Regla para seleccionar el resultado aplicable después de una recuperación: mejor nota o última recuperación.';
COMMENT ON COLUMN est_curso_asignatura.estado IS 'Situación de la oferta de la materia: planificada, activa o anulada.';

-- === EST_PONDERACION_PERIODO ===
-- Materia ofrecida, período y peso relativo de su calificación del período.
CREATE TABLE est_ponderacion_periodo (
    id_ponderacion_periodo NUMBER(10,0) NOT NULL,
    id_curso_asignatura NUMBER(10,0) NOT NULL,
    id_periodo NUMBER(10,0) NOT NULL,
    peso NUMBER NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_ponderacion_periodo PRIMARY KEY (id_ponderacion_periodo),
    CONSTRAINT uk_ponderacion_periodo_curso_asignatura_periodo UNIQUE (id_curso_asignatura,id_periodo),
    CONSTRAINT ck_ponderacion_periodo_peso CHECK (peso > 0),
    CONSTRAINT ck_ponderacion_periodo_estado CHECK (estado IN ('BORRADOR','PUBLICADO','ANULADO'))
);
COMMENT ON TABLE est_ponderacion_periodo IS 'Materia ofrecida, período y peso relativo de su calificación del período';
COMMENT ON COLUMN est_ponderacion_periodo.id_ponderacion_periodo IS 'Identificador de la configuración de una materia del grupo en un período; relaciona su peso, sus calificaciones y sus sesiones.';
COMMENT ON COLUMN est_ponderacion_periodo.id_curso_asignatura IS 'Oferta de la materia a la que se aplica este componente del plan.';
COMMENT ON COLUMN est_ponderacion_periodo.id_periodo IS 'Período académico cuyo resultado se pondera; debe pertenecer al ciclo del curso.';
COMMENT ON COLUMN est_ponderacion_periodo.peso IS 'Peso relativo positivo de la nota consolidada del período en el promedio anual de la materia. Se normaliza contra el plan completo; los pesos no tienen que sumar 100.';
COMMENT ON COLUMN est_ponderacion_periodo.estado IS 'Indica si el componente está en borrador, publicado o anulado. La publicación requiere el plan completo y sus pesos se congelan cuando existen resultados.';

-- === EST_PLAZO_REGISTRO_NOTAS ===
-- Plazo institucional de registro por grado, período y tipo de intento.
CREATE TABLE est_plazo_registro_notas (
    id_plazo_registro_notas NUMBER(10,0) NOT NULL,
    id_institucion NUMBER(10,0) NOT NULL,
    id_ciclo NUMBER(10,0) NOT NULL,
    id_grado NUMBER(10,0) NOT NULL,
    id_periodo NUMBER(10,0) NOT NULL,
    tipo_intento VARCHAR2(30 CHAR) NOT NULL,
    fecha_inicio_recuperacion DATE,
    fecha_fin_recuperacion DATE,
    fecha_apertura_registro TIMESTAMP(6) NOT NULL,
    fecha_limite_registro TIMESTAMP(6) NOT NULL,
    fecha_cierre_registro TIMESTAMP(6),
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_plazo_registro_notas PRIMARY KEY (id_plazo_registro_notas),
    CONSTRAINT uk_plazo_registro_notas_institucion_ciclo_grado_periodo_tipo_intento UNIQUE (id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento),
    CONSTRAINT ck_plazo_registro_notas_tipo_intento CHECK (tipo_intento IN ('ORDINARIA','RECUPERACION')),
    CONSTRAINT ck_plazo_registro_notas_fecha_inicio_recuperacion CHECK (fecha_inicio_recuperacion = TRUNC(fecha_inicio_recuperacion)),
    CONSTRAINT ck_plazo_registro_notas_fecha_fin_recuperacion CHECK (fecha_fin_recuperacion = TRUNC(fecha_fin_recuperacion)),
    CONSTRAINT ck_plazo_registro_notas_estado CHECK (estado IN ('PROGRAMADA','ABIERTA','CERRADA')),
    CONSTRAINT ck_plazo_registro_notas_plazo_cierre_coherente CHECK (fecha_apertura_registro <= fecha_limite_registro AND ((estado = 'CERRADA' AND fecha_cierre_registro IS NOT NULL AND fecha_cierre_registro >= fecha_apertura_registro) OR (estado IN ('PROGRAMADA','ABIERTA') AND fecha_cierre_registro IS NULL))),
    CONSTRAINT ck_plazo_registro_notas_recuperacion CHECK ((tipo_intento='ORDINARIA' AND fecha_inicio_recuperacion IS NULL AND fecha_fin_recuperacion IS NULL) OR (tipo_intento='RECUPERACION' AND fecha_inicio_recuperacion IS NOT NULL AND fecha_fin_recuperacion IS NOT NULL AND fecha_fin_recuperacion>=fecha_inicio_recuperacion))
);
COMMENT ON TABLE est_plazo_registro_notas IS 'Plazo institucional de registro por grado, período y tipo de intento';
COMMENT ON COLUMN est_plazo_registro_notas.id_plazo_registro_notas IS 'Identificador del plazo de registro de notas para un centro, ciclo, grado, período y tipo de intento.';
COMMENT ON COLUMN est_plazo_registro_notas.id_institucion IS 'Centro al que corresponde la ventana; junto con id_ciclo referencia su contexto anual.';
COMMENT ON COLUMN est_plazo_registro_notas.id_ciclo IS 'Ciclo académico al que corresponden las notas, aunque se registren posteriormente.';
COMMENT ON COLUMN est_plazo_registro_notas.id_grado IS 'Grado para el que se configura la ventana; permite calendarios de entrega distintos entre grados.';
COMMENT ON COLUMN est_plazo_registro_notas.id_periodo IS 'Período cuyas notas se reciben; debe pertenecer al mismo ciclo.';
COMMENT ON COLUMN est_plazo_registro_notas.tipo_intento IS 'Distingue una ventana para notas ordinarias de una para recuperaciones.';
COMMENT ON COLUMN est_plazo_registro_notas.fecha_inicio_recuperacion IS 'Primer día autorizado para realizar la recuperación. Es obligatorio en RECUPERACION y NULL en ORDINARIA; puede ser posterior al fin del ciclo.';
COMMENT ON COLUMN est_plazo_registro_notas.fecha_fin_recuperacion IS 'Último día autorizado para realizar la recuperación. Es obligatorio en RECUPERACION y NULL en ORDINARIA; debe respetar el inicio autorizado.';
COMMENT ON COLUMN est_plazo_registro_notas.fecha_apertura_registro IS 'Fecha y hora desde la que se autoriza el registro de las notas correspondientes a este plazo.';
COMMENT ON COLUMN est_plazo_registro_notas.fecha_limite_registro IS 'Fecha y hora límite prevista para entregar las notas; permite identificar obligaciones vencidas.';
COMMENT ON COLUMN est_plazo_registro_notas.fecha_cierre_registro IS 'Fecha y hora en que se cerró efectivamente el registro de notas. NULL significa que todavía no se ha registrado ese cierre; es independiente del fin del período académico.';
COMMENT ON COLUMN est_plazo_registro_notas.estado IS 'Situación de la ventana: programada, abierta o cerrada.';

-- ==============================================================
-- SECCIÓN 4: TRANSACCIONES ACADÉMICAS
-- Descripción: Inscripciones, docentes asignados, calificaciones, resultados, clases, asistencia y becas.
-- ==============================================================

-- === TRX_ASIGNACION_DOCENTE ===
-- Docente que ensena una asignatura del grupo durante una vigencia.
CREATE TABLE trx_asignacion_docente (
    id_asignacion NUMBER(10,0) NOT NULL,
    id_docente NUMBER(10,0) NOT NULL,
    id_curso_asignatura NUMBER(10,0) NOT NULL,
    fecha_asignacion TIMESTAMP(6) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado VARCHAR2(30 CHAR) NOT NULL,
    CONSTRAINT pk_asignacion_docente PRIMARY KEY (id_asignacion),
    CONSTRAINT ck_asignacion_docente_fecha_inicio CHECK (fecha_inicio = TRUNC(fecha_inicio)),
    CONSTRAINT ck_asignacion_docente_fecha_fin CHECK (fecha_fin = TRUNC(fecha_fin)),
    CONSTRAINT ck_asignacion_docente_estado CHECK (estado IN ('PROGRAMADA','VIGENTE','FINALIZADA','ANULADA')),
    CONSTRAINT ck_asignacion_docente_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE trx_asignacion_docente IS 'Docente que ensena una asignatura del grupo durante una vigencia';
COMMENT ON COLUMN trx_asignacion_docente.id_asignacion IS 'Identificador de la responsabilidad docente sobre una materia ofrecida durante una vigencia.';
COMMENT ON COLUMN trx_asignacion_docente.id_docente IS 'Docente responsable de impartir la materia durante el intervalo indicado.';
COMMENT ON COLUMN trx_asignacion_docente.id_curso_asignatura IS 'Materia y grupo sobre los que se asigna al docente; desde el grupo se obtiene la institución.';
COMMENT ON COLUMN trx_asignacion_docente.fecha_asignacion IS 'Fecha y hora en que se registró administrativamente la asignación; puede diferir del inicio efectivo.';
COMMENT ON COLUMN trx_asignacion_docente.fecha_inicio IS 'Primer día efectivo de responsabilidad docente sobre la oferta.';
COMMENT ON COLUMN trx_asignacion_docente.fecha_fin IS 'Último día efectivo de esa responsabilidad. Puede quedar NULL mientras no se haya informado su finalización, dentro del ciclo correspondiente.';
COMMENT ON COLUMN trx_asignacion_docente.estado IS 'Situación de la asignación: programada, vigente, finalizada o anulada; se interpreta junto con sus fechas.';

-- === TRX_INSCRIPCION ===
-- Pertenencia historica del estudiante al grupo.
CREATE TABLE trx_inscripcion (
    id_inscripcion NUMBER(10,0) NOT NULL,
    id_estudiante NUMBER(10,0) NOT NULL,
    id_curso NUMBER(10,0) NOT NULL,
    fecha_inscripcion TIMESTAMP(6) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado VARCHAR2(30 CHAR) NOT NULL,
    motivo_fin_inscripcion VARCHAR2(500 CHAR),
    resultado_cierre VARCHAR2(30 CHAR),
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_inscripcion),
    CONSTRAINT uk_inscripcion_estudiante_curso_fecha_inicio UNIQUE (id_estudiante,id_curso,fecha_inicio),
    CONSTRAINT ck_inscripcion_fecha_inicio CHECK (fecha_inicio = TRUNC(fecha_inicio)),
    CONSTRAINT ck_inscripcion_fecha_fin CHECK (fecha_fin = TRUNC(fecha_fin)),
    CONSTRAINT ck_inscripcion_estado CHECK (estado IN ('VIGENTE','FINALIZADA','RETIRADA','TRASLADADA','ANULADA')),
    CONSTRAINT ck_inscripcion_resultado_cierre CHECK (resultado_cierre IN ('PROMOVIDO','REPITE','GRADUADO')),
    CONSTRAINT ck_inscripcion_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE trx_inscripcion IS 'Pertenencia historica del estudiante al grupo';
COMMENT ON COLUMN trx_inscripcion.id_inscripcion IS 'Identificador de un intervalo de pertenencia del estudiante a un grupo; permite conservar retiros, traslados y reingresos.';
COMMENT ON COLUMN trx_inscripcion.id_estudiante IS 'Estudiante al que corresponde la inscripción.';
COMMENT ON COLUMN trx_inscripcion.id_curso IS 'Grupo al que pertenece el estudiante; desde aquí se obtiene su institución, ciclo, grado, jornada y modalidad históricos.';
COMMENT ON COLUMN trx_inscripcion.fecha_inscripcion IS 'Fecha y hora de registro administrativo de la inscripción; puede diferir del primer día de pertenencia efectiva.';
COMMENT ON COLUMN trx_inscripcion.fecha_inicio IS 'Primer día de pertenencia efectiva al grupo; permite decidir qué sesiones y obligaciones corresponden al estudiante.';
COMMENT ON COLUMN trx_inscripcion.fecha_fin IS 'Último día de pertenencia efectiva al grupo. Si está NULL, las consultas limitan la vigencia al fin del ciclo; no implica matrícula en el año siguiente.';
COMMENT ON COLUMN trx_inscripcion.estado IS 'Situación de la inscripción: vigente, finalizada, retirada, trasladada o anulada. Se interpreta junto con las fechas.';
COMMENT ON COLUMN trx_inscripcion.motivo_fin_inscripcion IS 'Explica por qué terminó la pertenencia al grupo, como traslado, retiro o finalización. El cierre de una inscripción no demuestra abandono escolar.';
COMMENT ON COLUMN trx_inscripcion.resultado_cierre IS 'Resultado académico del cierre: promovido, repite o graduado. Puede quedar NULL mientras esté pendiente; permite tratar correctamente la retención y los egresados.';

-- === TRX_CALIFICACION ===
-- Calificación real consolidada de un período e intento, con sus versiones.
CREATE TABLE trx_calificacion (
    id_calificacion NUMBER(10,0) NOT NULL,
    id_inscripcion NUMBER(10,0) NOT NULL,
    id_ponderacion_periodo NUMBER(10,0) NOT NULL,
    tipo_intento VARCHAR2(30 CHAR) NOT NULL,
    numero_intento NUMBER(10,0) NOT NULL,
    version NUMBER(10,0) NOT NULL,
    id_calificacion_ordinaria NUMBER(10,0),
    id_calificacion_sustituida NUMBER(10,0),
    id_asignacion_docente NUMBER(10,0) NOT NULL,
    id_docente_registra NUMBER(10,0) NOT NULL,
    nota NUMBER(7,4),
    resultado_cualitativo VARCHAR2(100 CHAR),
    fecha_evaluacion DATE NOT NULL,
    fecha_registro TIMESTAMP(6) NOT NULL,
    fecha_validacion TIMESTAMP(6),
    fecha_anulacion TIMESTAMP(6),
    motivo_anulacion VARCHAR2(500 CHAR),
    CONSTRAINT pk_calificacion PRIMARY KEY (id_calificacion),
    CONSTRAINT uk_calificacion_inscripcion_ponderacion_periodo_tipo_intento_numero_intento_version UNIQUE (id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento,version),
    CONSTRAINT ck_calificacion_tipo_intento CHECK (tipo_intento IN ('ORDINARIA','RECUPERACION')),
    CONSTRAINT ck_calificacion_numero_intento CHECK (numero_intento >= 1),
    CONSTRAINT ck_calificacion_version CHECK (version >= 1),
    CONSTRAINT ck_calificacion_nota CHECK (nota BETWEEN 0 AND 100),
    CONSTRAINT ck_calificacion_fecha_evaluacion CHECK (fecha_evaluacion = TRUNC(fecha_evaluacion)),
    CONSTRAINT ck_calificacion_intento_ordinario_y_recuperacion CHECK ((tipo_intento = 'ORDINARIA' AND numero_intento = 1 AND id_calificacion_ordinaria IS NULL) OR (tipo_intento = 'RECUPERACION' AND numero_intento >= 2 AND id_calificacion_ordinaria IS NOT NULL)),
    CONSTRAINT ck_calificacion_resultado_real_excluyente CHECK ((nota IS NOT NULL AND resultado_cualitativo IS NULL) OR (nota IS NULL AND resultado_cualitativo IS NOT NULL)),
    CONSTRAINT ck_calificacion_version_con_antecedente CHECK ((version = 1 AND id_calificacion_sustituida IS NULL) OR (version > 1 AND id_calificacion_sustituida IS NOT NULL)),
    CONSTRAINT ck_calificacion_fechas_calificacion_ordenadas CHECK ((fecha_validacion IS NULL OR fecha_validacion >= fecha_registro) AND (fecha_anulacion IS NULL OR (fecha_anulacion >= fecha_registro AND motivo_anulacion IS NOT NULL)))
);
COMMENT ON TABLE trx_calificacion IS 'Calificación real consolidada de un período e intento, con sus versiones';
COMMENT ON COLUMN trx_calificacion.id_calificacion IS 'Identificador de una versión concreta de una calificación real del período y de un intento.';
COMMENT ON COLUMN trx_calificacion.id_inscripcion IS 'Inscripción de origen de la nota; conserva el estudiante y el grupo donde se produjo el resultado.';
COMMENT ON COLUMN trx_calificacion.id_ponderacion_periodo IS 'Materia ofrecida y período a los que corresponde la nota; aporta su peso y contexto académico.';
COMMENT ON COLUMN trx_calificacion.tipo_intento IS 'Distingue la calificación ordinaria de una recuperación del mismo período.';
COMMENT ON COLUMN trx_calificacion.numero_intento IS 'Número del intento: 1 para la ordinaria y 2 o más para recuperaciones. Se mantiene al corregir una versión del mismo intento.';
COMMENT ON COLUMN trx_calificacion.version IS 'Número de versión de la calificación dentro del mismo intento. Una corrección agrega una versión y conserva la anterior.';
COMMENT ON COLUMN trx_calificacion.id_calificacion_ordinaria IS 'Calificación ordinaria a la que corresponde esta recuperación. Es obligatoria en RECUPERACION y NULL en ORDINARIA; una recuperación es otro intento, no una corrección de versión.';
COMMENT ON COLUMN trx_calificacion.id_calificacion_sustituida IS 'Versión anterior que se corrige, del mismo intento. NULL en la primera versión. Referencia la calificación anterior, no necesariamente el resultado seleccionado del período.';
COMMENT ON COLUMN trx_calificacion.id_asignacion_docente IS 'Asignación docente responsable de la calificación; identifica la oferta y la responsabilidad académica histórica. Puede diferir del docente que registra la nota. En la ordinaria debe estar vigente en fecha_evaluacion; en la recuperación, en algún momento del período que se recupera.';
COMMENT ON COLUMN trx_calificacion.id_docente_registra IS 'Docente que registró la nota; puede diferir del responsable académico.';
COMMENT ON COLUMN trx_calificacion.nota IS 'Calificación numérica real de 0 a 100. Es obligatoria para una oferta numérica y NULL para una cualitativa; nunca representa una nota pendiente ni un promedio temporal.';
COMMENT ON COLUMN trx_calificacion.resultado_cualitativo IS 'Resultado textual real de una oferta cualitativa; queda NULL en una oferta numérica. Exactamente uno de este campo y nota debe tener valor.';
COMMENT ON COLUMN trx_calificacion.fecha_evaluacion IS 'Fecha académica del resultado, aunque se capture después; en recuperación debe respetar el intervalo de examen autorizado.';
COMMENT ON COLUMN trx_calificacion.fecha_registro IS 'Fecha y hora de incorporación de esta versión de la nota; permite distinguir el hecho académico de su captura.';
COMMENT ON COLUMN trx_calificacion.fecha_validacion IS 'Fecha y hora en que se aceptó la versión para su uso académico. NULL indica que todavía no está validada.';
COMMENT ON COLUMN trx_calificacion.fecha_anulacion IS 'Fecha y hora desde la que esta versión queda anulada. NULL indica que no tiene una anulación registrada; anularla no reactiva automáticamente versiones anteriores.';
COMMENT ON COLUMN trx_calificacion.motivo_anulacion IS 'Explicación de la anulación cuando se registra; permite interpretar por qué dejó de utilizarse el resultado.';

-- === TRX_RESULTADO_PERIODO ===
-- Selección versionada de la calificación usada para el período, sin duplicar nota ni promedio.
CREATE TABLE trx_resultado_periodo (
    id_resultado NUMBER(10,0) NOT NULL,
    id_estudiante NUMBER(10,0) NOT NULL,
    id_asignatura NUMBER(10,0) NOT NULL,
    id_periodo NUMBER(10,0) NOT NULL,
    id_calificacion_seleccionada NUMBER(10,0) NOT NULL,
    version NUMBER(10,0) NOT NULL,
    criterio VARCHAR2(30 CHAR) NOT NULL,
    fecha_seleccion TIMESTAMP(6) NOT NULL,
    fecha_cierre TIMESTAMP(6),
    CONSTRAINT pk_resultado_periodo PRIMARY KEY (id_resultado),
    CONSTRAINT uk_resultado_periodo_estudiante_asignatura_periodo_version UNIQUE (id_estudiante,id_asignatura,id_periodo,version),
    CONSTRAINT ck_resultado_periodo_version CHECK (version >= 1),
    CONSTRAINT ck_resultado_periodo_criterio CHECK (criterio IN ('ORDINARIA','MEJOR_NOTA','ULTIMA_RECUPERACION','CORRECCION','TRASLADO'))
);
COMMENT ON TABLE trx_resultado_periodo IS 'Selección versionada de la calificación usada para el período, sin duplicar nota ni promedio';
COMMENT ON COLUMN trx_resultado_periodo.id_resultado IS 'Identificador de una versión de la selección del resultado aplicable para un estudiante, materia y período.';
COMMENT ON COLUMN trx_resultado_periodo.id_estudiante IS 'Estudiante cuyo resultado se selecciona, independientemente de los traslados que haya tenido.';
COMMENT ON COLUMN trx_resultado_periodo.id_asignatura IS 'Materia a la que corresponde el resultado seleccionado.';
COMMENT ON COLUMN trx_resultado_periodo.id_periodo IS 'Período académico al que corresponde la selección.';
COMMENT ON COLUMN trx_resultado_periodo.id_calificacion_seleccionada IS 'Referencia a la calificación real elegida como resultado de ese período: ordinaria, recuperación o versión corregida. No es el promedio anual y no duplica el valor de la nota; debe corresponder al mismo estudiante, materia y período.';
COMMENT ON COLUMN trx_resultado_periodo.version IS 'Número de versión de la selección. Permite cambiar el resultado aplicado conservando la historia de decisiones.';
COMMENT ON COLUMN trx_resultado_periodo.criterio IS 'Motivo o regla de selección: ordinaria, mejor nota, última recuperación, corrección o traslado.';
COMMENT ON COLUMN trx_resultado_periodo.fecha_seleccion IS 'Fecha y hora en que se estableció esta selección; permite reconstruir cuál se utilizaba a una fecha de corte.';
COMMENT ON COLUMN trx_resultado_periodo.fecha_cierre IS 'Fecha y hora en que se cerró el resultado del período. Puede quedar NULL mientras esté abierto; el cierre anual exige además las demás condiciones del modelo.';

-- === TRX_SESION_CLASE ===
-- Una sesion de una asignatura ofrecida.
CREATE TABLE trx_sesion_clase (
    id_sesion NUMBER(10,0) NOT NULL,
    id_ponderacion_periodo NUMBER(10,0) NOT NULL,
    id_asignacion NUMBER(10,0) NOT NULL,
    fecha_academica DATE NOT NULL,
    inicio TIMESTAMP(6) NOT NULL,
    fin TIMESTAMP(6) NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    observaciones VARCHAR2(1000 CHAR),
    CONSTRAINT pk_sesion_clase PRIMARY KEY (id_sesion),
    CONSTRAINT uk_sesion_clase_ponderacion_periodo_inicio UNIQUE (id_ponderacion_periodo,inicio),
    CONSTRAINT ck_sesion_clase_fecha_academica CHECK (fecha_academica = TRUNC(fecha_academica)),
    CONSTRAINT ck_sesion_clase_estado CHECK (estado IN ('PROGRAMADA','IMPARTIDA','CANCELADA')),
    CONSTRAINT ck_sesion_clase_horario CHECK (fin > inicio)
);
COMMENT ON TABLE trx_sesion_clase IS 'Una sesion de una asignatura ofrecida';
COMMENT ON COLUMN trx_sesion_clase.id_sesion IS 'Identificador de una sesión concreta de clase; es la unidad a la que se registra la asistencia.';
COMMENT ON COLUMN trx_sesion_clase.id_ponderacion_periodo IS 'Materia ofrecida y período a los que pertenece la sesión.';
COMMENT ON COLUMN trx_sesion_clase.id_asignacion IS 'Asignación del docente responsable de la sesión, compatible con la oferta y su vigencia.';
COMMENT ON COLUMN trx_sesion_clase.fecha_academica IS 'Día académico al que se atribuye la sesión. Permanece como referencia aunque una clase nocturna termine después de medianoche.';
COMMENT ON COLUMN trx_sesion_clase.inicio IS 'Fecha y hora de inicio de la sesión.';
COMMENT ON COLUMN trx_sesion_clase.fin IS 'Fecha y hora de finalización de la sesión; debe ser posterior al inicio y puede corresponder al día siguiente.';
COMMENT ON COLUMN trx_sesion_clase.estado IS 'Indica si la sesión está programada, fue impartida o se canceló. El denominador de asistencia utiliza sesiones impartidas que correspondían al estudiante.';
COMMENT ON COLUMN trx_sesion_clase.observaciones IS 'Detalle opcional sobre la sesión, como la causa de una cancelación.';

-- === TRX_ASISTENCIA ===
-- Estado de asistencia del inscrito a una sesion.
CREATE TABLE trx_asistencia (
    id_asistencia NUMBER(10,0) NOT NULL,
    id_inscripcion NUMBER(10,0) NOT NULL,
    id_sesion NUMBER(10,0) NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    hora_llegada TIMESTAMP(6),
    fecha_registro TIMESTAMP(6) NOT NULL,
    observaciones VARCHAR2(1000 CHAR),
    CONSTRAINT pk_asistencia PRIMARY KEY (id_asistencia),
    CONSTRAINT uk_asistencia_inscripcion_sesion UNIQUE (id_inscripcion,id_sesion),
    CONSTRAINT ck_asistencia_estado CHECK (estado IN ('PRESENTE','TARDE','AUSENTE','JUSTIFICADA'))
);
COMMENT ON TABLE trx_asistencia IS 'Estado de asistencia del inscrito a una sesion';
COMMENT ON COLUMN trx_asistencia.id_asistencia IS 'Identificador del registro de asistencia de una inscripción a una sesión.';
COMMENT ON COLUMN trx_asistencia.id_inscripcion IS 'Inscripción del estudiante cuya asistencia se registra; debe estar vigente para la sesión correspondiente.';
COMMENT ON COLUMN trx_asistencia.id_sesion IS 'Sesión concreta a la que corresponde la asistencia. Junto con id_inscripcion evita duplicar el registro.';
COMMENT ON COLUMN trx_asistencia.estado IS 'Resultado observado de asistencia: presente, tarde, ausente o justificada. Una fila que no existe significa captura pendiente, no ausencia automática.';
COMMENT ON COLUMN trx_asistencia.hora_llegada IS 'Fecha y hora de llegada si fue capturada; puede quedar NULL cuando no se dispone de ese dato o no corresponde.';
COMMENT ON COLUMN trx_asistencia.fecha_registro IS 'Fecha y hora de captura del registro de asistencia.';
COMMENT ON COLUMN trx_asistencia.observaciones IS 'Detalle opcional, como el motivo de una ausencia justificada o de una llegada tardía.';

-- === TRX_BECA ===
-- Beneficio concedido a una inscripcion, separado de la politica institucional.
CREATE TABLE trx_beca (
    id_beca NUMBER(10,0) NOT NULL,
    id_inscripcion NUMBER(10,0) NOT NULL,
    id_tipo_beca NUMBER(10,0) NOT NULL,
    porcentaje NUMBER(7,4) NOT NULL,
    fecha_otorgamiento DATE NOT NULL,
    fecha_registro TIMESTAMP(6) NOT NULL,
    observaciones VARCHAR2(1000 CHAR),
    CONSTRAINT pk_beca PRIMARY KEY (id_beca),
    CONSTRAINT ck_beca_porcentaje CHECK (porcentaje > 0 AND porcentaje <= 100),
    CONSTRAINT ck_beca_fecha_otorgamiento CHECK (fecha_otorgamiento = TRUNC(fecha_otorgamiento))
);
COMMENT ON TABLE trx_beca IS 'Beneficio concedido a una inscripcion, separado de la politica institucional';
COMMENT ON COLUMN trx_beca.id_beca IS 'Identificador del beneficio efectivamente otorgado; sus intervalos de aplicación se registran en trx_beca_vigencia.';
COMMENT ON COLUMN trx_beca.id_inscripcion IS 'Inscripción beneficiaria; permite atribuir la beca al estudiante, centro y ciclo correspondientes.';
COMMENT ON COLUMN trx_beca.id_tipo_beca IS 'Categoría o motivo de la beca concedida, como apoyo económico o mérito académico.';
COMMENT ON COLUMN trx_beca.porcentaje IS 'Porcentaje del beneficio concedido, mayor que 0 y hasta 100. Si concurren beneficios sobre la misma base, su suma no puede exceder 100.';
COMMENT ON COLUMN trx_beca.fecha_otorgamiento IS 'Fecha en que se concedió el beneficio; puede diferir del inicio de su aplicación efectiva.';
COMMENT ON COLUMN trx_beca.fecha_registro IS 'Fecha y hora en que se incorporó el otorgamiento al sistema.';
COMMENT ON COLUMN trx_beca.observaciones IS 'Detalle opcional sobre el otorgamiento del beneficio.';

-- === TRX_BECA_VIGENCIA ===
-- Intervalos efectivos del beneficio, incluyendo suspensiones.
CREATE TABLE trx_beca_vigencia (
    id_vigencia NUMBER(10,0) NOT NULL,
    id_beca NUMBER(10,0) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    motivo_fin VARCHAR2(30 CHAR),
    fecha_registro TIMESTAMP(6) NOT NULL,
    CONSTRAINT pk_beca_vigencia PRIMARY KEY (id_vigencia),
    CONSTRAINT uk_beca_vigencia_beca_fecha_inicio UNIQUE (id_beca,fecha_inicio),
    CONSTRAINT ck_beca_vigencia_fecha_inicio CHECK (fecha_inicio = TRUNC(fecha_inicio)),
    CONSTRAINT ck_beca_vigencia_fecha_fin CHECK (fecha_fin = TRUNC(fecha_fin)),
    CONSTRAINT ck_beca_vigencia_motivo_fin CHECK (motivo_fin IN ('FIN_VIGENCIA','SUSPENSION','CANCELACION','TRASLADO')),
    CONSTRAINT ck_beca_vigencia_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
COMMENT ON TABLE trx_beca_vigencia IS 'Intervalos efectivos del beneficio, incluyendo suspensiones';
COMMENT ON COLUMN trx_beca_vigencia.id_vigencia IS 'Identificador de un intervalo continuo en que una beca se aplica efectivamente.';
COMMENT ON COLUMN trx_beca_vigencia.id_beca IS 'Beneficio al que corresponde el intervalo.';
COMMENT ON COLUMN trx_beca_vigencia.fecha_inicio IS 'Primer día efectivo del beneficio en este intervalo. Una reanudación después de una suspensión genera un intervalo nuevo.';
COMMENT ON COLUMN trx_beca_vigencia.fecha_fin IS 'Último día efectivo del intervalo. Puede quedar NULL mientras no se haya informado su finalización, siempre limitado por la inscripción y el ciclo.';
COMMENT ON COLUMN trx_beca_vigencia.motivo_fin IS 'Causa del cierre del intervalo: fin de vigencia, suspensión, cancelación o traslado. Puede quedar NULL mientras el intervalo siga abierto.';
COMMENT ON COLUMN trx_beca_vigencia.fecha_registro IS 'Fecha y hora en que se registró el intervalo de vigencia.';

-- ==============================================================
-- SECCIÓN 5: CONTROL DE CARGA Y AUDITORÍA
-- Descripción: Cobertura de los datos recibidos y registro de cada ejecución de carga y sus errores.
-- ==============================================================

-- === AUDITORIA_ETL_EVALUACIONES ===
-- Ejecuciones de carga.
CREATE TABLE auditoria_etl_evaluaciones (
    id_ejecucion NUMBER(10,0) NOT NULL,
    fuente VARCHAR2(500 CHAR) NOT NULL,
    inicio TIMESTAMP(6) NOT NULL,
    fin TIMESTAMP(6),
    estado VARCHAR2(30 CHAR) NOT NULL,
    total_leidos NUMBER(10,0) NOT NULL,
    insertados NUMBER(10,0) NOT NULL,
    actualizados NUMBER(10,0) NOT NULL,
    rechazados NUMBER(10,0) NOT NULL,
    CONSTRAINT pk_auditoria_etl PRIMARY KEY (id_ejecucion),
    CONSTRAINT ck_auditoria_etl_estado CHECK (estado IN ('EN_PROCESO','COMPLETADA','ERROR')),
    CONSTRAINT ck_auditoria_etl_conteos CHECK (total_leidos>=0 AND insertados>=0 AND actualizados>=0 AND rechazados>=0),
    CONSTRAINT ck_auditoria_etl_cierre CHECK (estado<>'COMPLETADA' OR (fin IS NOT NULL AND fin>=inicio AND total_leidos=insertados+actualizados+rechazados))
);
COMMENT ON TABLE auditoria_etl_evaluaciones IS 'Ejecuciones de carga';
COMMENT ON COLUMN auditoria_etl_evaluaciones.id_ejecucion IS 'Identificador de una ejecución del ETL; relaciona sus errores y controles de cobertura.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.fuente IS 'Identifica el archivo, sistema o entrega de origen procesado por la ejecución.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.inicio IS 'Fecha y hora en que comenzó la ejecución.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.fin IS 'Fecha y hora en que terminó la ejecución; puede quedar NULL mientras esté en proceso.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.estado IS 'Situación técnica de la ejecución: en proceso, completada o error. Completar una ejecución no demuestra que el centro haya entregado toda la información esperada.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.total_leidos IS 'Cantidad total de registros leídos de la fuente durante la ejecución.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.insertados IS 'Cantidad de registros nuevos incorporados correctamente durante la ejecución.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.actualizados IS 'Cantidad de registros existentes actualizados correctamente durante la ejecución; las correcciones de calificaciones deben respetar el versionado académico.';
COMMENT ON COLUMN auditoria_etl_evaluaciones.rechazados IS 'Cantidad de registros rechazados por validaciones; sus detalles se conservan en errores_etl_evaluaciones.';

-- === ERRORES_ETL_EVALUACIONES ===
-- Errores y registros rechazados.
CREATE TABLE errores_etl_evaluaciones (
    id_error NUMBER(10,0) NOT NULL,
    id_ejecucion NUMBER(10,0) NOT NULL,
    entidad VARCHAR2(100 CHAR) NOT NULL,
    clave_origen VARCHAR2(250 CHAR),
    tipo_error VARCHAR2(100 CHAR) NOT NULL,
    detalle VARCHAR2(1000 CHAR) NOT NULL,
    json_original CLOB NOT NULL,
    fecha_registro TIMESTAMP(6) NOT NULL,
    CONSTRAINT pk_errores_etl PRIMARY KEY (id_error),
    CONSTRAINT ck_errores_etl_json_original CHECK (json_original IS JSON STRICT)
);
COMMENT ON TABLE errores_etl_evaluaciones IS 'Errores y registros rechazados';
COMMENT ON COLUMN errores_etl_evaluaciones.id_error IS 'Identificador de un error o rechazo detectado por el ETL.';
COMMENT ON COLUMN errores_etl_evaluaciones.id_ejecucion IS 'Ejecución durante la que se detectó el problema.';
COMMENT ON COLUMN errores_etl_evaluaciones.entidad IS 'Tipo de información afectada, como estudiante, evaluación, asistencia o beca.';
COMMENT ON COLUMN errores_etl_evaluaciones.clave_origen IS 'Identificador del registro en la fuente, si está disponible; ayuda a localizarlo para corregirlo.';
COMMENT ON COLUMN errores_etl_evaluaciones.tipo_error IS 'Categoría del problema, como formato inválido, referencia inexistente o dato duplicado.';
COMMENT ON COLUMN errores_etl_evaluaciones.detalle IS 'Explicación concreta del error y del dato o regla que impidió aceptar el registro.';
COMMENT ON COLUMN errores_etl_evaluaciones.json_original IS 'Contenido original del registro rechazado en formato JSON; permite revisar el dato recibido y preparar su corrección.';
COMMENT ON COLUMN errores_etl_evaluaciones.fecha_registro IS 'Fecha y hora en que se registró el error.';

-- === TRX_CONTROL_CARGA ===
-- Cobertura declarada por curso, periodo, dominio y corte.
CREATE TABLE trx_control_carga (
    id_control NUMBER(10,0) NOT NULL,
    id_curso NUMBER(10,0) NOT NULL,
    id_periodo NUMBER(10,0) NOT NULL,
    dominio VARCHAR2(30 CHAR) NOT NULL,
    fecha_corte DATE NOT NULL,
    estado VARCHAR2(30 CHAR) NOT NULL,
    registros_declarados NUMBER(10,0) NOT NULL,
    fecha_recepcion TIMESTAMP(6) NOT NULL,
    id_ejecucion NUMBER(10,0) NOT NULL,
    CONSTRAINT pk_control_carga PRIMARY KEY (id_control),
    CONSTRAINT uk_control_carga_curso_periodo_dominio_fecha_corte UNIQUE (id_curso,id_periodo,dominio,fecha_corte),
    CONSTRAINT ck_control_carga_dominio CHECK (dominio IN ('MATRICULA','NOTAS','ASISTENCIA','BECAS')),
    CONSTRAINT ck_control_carga_fecha_corte CHECK (fecha_corte = TRUNC(fecha_corte)),
    CONSTRAINT ck_control_carga_estado CHECK (estado IN ('COMPLETA','PARCIAL','NO_APLICA')),
    CONSTRAINT ck_control_carga_registros_declarados CHECK (registros_declarados >= 0)
);
COMMENT ON TABLE trx_control_carga IS 'Cobertura declarada por curso, periodo, dominio y corte';
COMMENT ON COLUMN trx_control_carga.id_control IS 'Identificador de la declaración de cobertura de una entrega para un curso, período, dominio y fecha de corte.';
COMMENT ON COLUMN trx_control_carga.id_curso IS 'Grupo cuya información se está declarando completa, parcial o no aplicable.';
COMMENT ON COLUMN trx_control_carga.id_periodo IS 'Período al que corresponde la información controlada; debe ser compatible con el ciclo del curso.';
COMMENT ON COLUMN trx_control_carga.dominio IS 'Conjunto de datos controlado: matrícula, notas, asistencia o becas. Cada dominio tiene su propia declaración.';
COMMENT ON COLUMN trx_control_carga.fecha_corte IS 'Fecha hasta la que se evalúa la cobertura de la información. Una entrega completa al corte no requiere datos futuros.';
COMMENT ON COLUMN trx_control_carga.estado IS 'COMPLETA confirma la entrega total correspondiente al corte; PARCIAL indica faltantes; NO_APLICA requiere una regla explícita. Cero casos confirmados puede ser COMPLETA; sin control, la cobertura es desconocida.';
COMMENT ON COLUMN trx_control_carga.registros_declarados IS 'Cantidad de registros declarada por la fuente para esa entrega y alcance; admite cero confirmado. El conteo por sí solo no demuestra que la entrega esté completa.';
COMMENT ON COLUMN trx_control_carga.fecha_recepcion IS 'Fecha y hora en que se recibió la entrega o declaración de cobertura; puede ser posterior a su fecha de corte.';
COMMENT ON COLUMN trx_control_carga.id_ejecucion IS 'Ejecución del ETL que procesó y dejó trazabilidad de esta declaración de cobertura.';

-- ==============================================================
-- SECCIÓN 6: CLAVES FORÁNEAS E ÍNDICES
-- Descripción: Se agregan al final, cuando ya existen todas las tablas.
--   Cada FK sin un índice que empiece por sus columnas recibe uno, para no bloquear la tabla padre.
-- ==============================================================

-- === CAT_GRADO ===
ALTER TABLE cat_grado ADD CONSTRAINT fk_grado_nivel FOREIGN KEY (id_nivel) REFERENCES cat_nivel (id_nivel);

-- === MAE_INSTITUCION ===
ALTER TABLE mae_institucion ADD CONSTRAINT fk_institucion_tipo_institucion FOREIGN KEY (id_tipo_institucion) REFERENCES cat_tipo_institucion (id_tipo_institucion);
CREATE INDEX ix_institucion_tipo_institucion ON mae_institucion (id_tipo_institucion);
ALTER TABLE mae_institucion ADD CONSTRAINT fk_institucion_departamento FOREIGN KEY (id_departamento) REFERENCES cat_departamento (id_departamento);
CREATE INDEX ix_institucion_departamento ON mae_institucion (id_departamento);
ALTER TABLE mae_institucion ADD CONSTRAINT fk_institucion_zona FOREIGN KEY (id_zona) REFERENCES cat_zona (id_zona);
CREATE INDEX ix_institucion_zona ON mae_institucion (id_zona);

-- === MAE_PERSONA ===
ALTER TABLE mae_persona ADD CONSTRAINT fk_persona_tipo_documento FOREIGN KEY (id_tipo_documento) REFERENCES cat_tipo_documento (id_tipo_documento);

-- === MAE_ESTUDIANTE ===
ALTER TABLE mae_estudiante ADD CONSTRAINT fk_estudiante_persona FOREIGN KEY (id_persona) REFERENCES mae_persona (id_persona);

-- === MAE_DOCENTE ===
ALTER TABLE mae_docente ADD CONSTRAINT fk_docente_persona FOREIGN KEY (id_persona) REFERENCES mae_persona (id_persona);

-- === MAE_ASIGNATURA ===
ALTER TABLE mae_asignatura ADD CONSTRAINT fk_asignatura_area FOREIGN KEY (id_area) REFERENCES cat_area_conocimiento (id_area);
CREATE INDEX ix_asignatura_area ON mae_asignatura (id_area);

-- === EST_PERIODO_ACADEMICO ===
ALTER TABLE est_periodo_academico ADD CONSTRAINT fk_periodo_academico_ciclo FOREIGN KEY (id_ciclo) REFERENCES est_ciclo (id_ciclo);

-- === EST_INSTITUCION_CICLO ===
ALTER TABLE est_institucion_ciclo ADD CONSTRAINT fk_institucion_ciclo_institucion FOREIGN KEY (id_institucion) REFERENCES mae_institucion (id_institucion);
ALTER TABLE est_institucion_ciclo ADD CONSTRAINT fk_institucion_ciclo_ciclo FOREIGN KEY (id_ciclo) REFERENCES est_ciclo (id_ciclo);
CREATE INDEX ix_institucion_ciclo_ciclo ON est_institucion_ciclo (id_ciclo);
ALTER TABLE est_institucion_ciclo ADD CONSTRAINT fk_institucion_ciclo_tipo_institucion FOREIGN KEY (id_tipo_institucion) REFERENCES cat_tipo_institucion (id_tipo_institucion);
CREATE INDEX ix_institucion_ciclo_tipo_institucion ON est_institucion_ciclo (id_tipo_institucion);
ALTER TABLE est_institucion_ciclo ADD CONSTRAINT fk_institucion_ciclo_departamento FOREIGN KEY (id_departamento) REFERENCES cat_departamento (id_departamento);
CREATE INDEX ix_institucion_ciclo_departamento ON est_institucion_ciclo (id_departamento);
ALTER TABLE est_institucion_ciclo ADD CONSTRAINT fk_institucion_ciclo_zona FOREIGN KEY (id_zona) REFERENCES cat_zona (id_zona);
CREATE INDEX ix_institucion_ciclo_zona ON est_institucion_ciclo (id_zona);

-- === EST_CURSO ===
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_institucion FOREIGN KEY (id_institucion) REFERENCES mae_institucion (id_institucion);
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_ciclo FOREIGN KEY (id_ciclo) REFERENCES est_ciclo (id_ciclo);
CREATE INDEX ix_curso_ciclo ON est_curso (id_ciclo);
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_grado FOREIGN KEY (id_grado) REFERENCES cat_grado (id_grado);
CREATE INDEX ix_curso_grado ON est_curso (id_grado);
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_jornada FOREIGN KEY (id_jornada) REFERENCES cat_jornada (id_jornada);
CREATE INDEX ix_curso_jornada ON est_curso (id_jornada);
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_modalidad FOREIGN KEY (id_modalidad) REFERENCES cat_modalidad (id_modalidad);
CREATE INDEX ix_curso_modalidad ON est_curso (id_modalidad);
ALTER TABLE est_curso ADD CONSTRAINT fk_curso_institucion_ciclo FOREIGN KEY (id_institucion,id_ciclo) REFERENCES est_institucion_ciclo (id_institucion,id_ciclo);

-- === EST_CURSO_ASIGNATURA ===
ALTER TABLE est_curso_asignatura ADD CONSTRAINT fk_curso_asignatura_curso FOREIGN KEY (id_curso) REFERENCES est_curso (id_curso);
ALTER TABLE est_curso_asignatura ADD CONSTRAINT fk_curso_asignatura_asignatura FOREIGN KEY (id_asignatura) REFERENCES mae_asignatura (id_asignatura);
CREATE INDEX ix_curso_asignatura_asignatura ON est_curso_asignatura (id_asignatura);

-- === EST_PONDERACION_PERIODO ===
ALTER TABLE est_ponderacion_periodo ADD CONSTRAINT fk_ponderacion_periodo_curso_asignatura FOREIGN KEY (id_curso_asignatura) REFERENCES est_curso_asignatura (id_curso_asignatura);
ALTER TABLE est_ponderacion_periodo ADD CONSTRAINT fk_ponderacion_periodo_periodo FOREIGN KEY (id_periodo) REFERENCES est_periodo_academico (id_periodo);
CREATE INDEX ix_ponderacion_periodo_periodo ON est_ponderacion_periodo (id_periodo);

-- === EST_PLAZO_REGISTRO_NOTAS ===
ALTER TABLE est_plazo_registro_notas ADD CONSTRAINT fk_plazo_registro_notas_institucion FOREIGN KEY (id_institucion) REFERENCES mae_institucion (id_institucion);
ALTER TABLE est_plazo_registro_notas ADD CONSTRAINT fk_plazo_registro_notas_ciclo FOREIGN KEY (id_ciclo) REFERENCES est_ciclo (id_ciclo);
CREATE INDEX ix_plazo_registro_notas_ciclo ON est_plazo_registro_notas (id_ciclo);
ALTER TABLE est_plazo_registro_notas ADD CONSTRAINT fk_plazo_registro_notas_grado FOREIGN KEY (id_grado) REFERENCES cat_grado (id_grado);
CREATE INDEX ix_plazo_registro_notas_grado ON est_plazo_registro_notas (id_grado);
ALTER TABLE est_plazo_registro_notas ADD CONSTRAINT fk_plazo_registro_notas_periodo FOREIGN KEY (id_periodo) REFERENCES est_periodo_academico (id_periodo);
CREATE INDEX ix_plazo_registro_notas_periodo ON est_plazo_registro_notas (id_periodo);
ALTER TABLE est_plazo_registro_notas ADD CONSTRAINT fk_plazo_registro_notas_institucion_ciclo FOREIGN KEY (id_institucion,id_ciclo) REFERENCES est_institucion_ciclo (id_institucion,id_ciclo);

-- === TRX_ASIGNACION_DOCENTE ===
ALTER TABLE trx_asignacion_docente ADD CONSTRAINT fk_asignacion_docente_docente FOREIGN KEY (id_docente) REFERENCES mae_docente (id_docente);
CREATE INDEX ix_asignacion_docente_docente ON trx_asignacion_docente (id_docente);
ALTER TABLE trx_asignacion_docente ADD CONSTRAINT fk_asignacion_docente_curso_asignatura FOREIGN KEY (id_curso_asignatura) REFERENCES est_curso_asignatura (id_curso_asignatura);
CREATE INDEX ix_asignacion_docente_curso_asignatura ON trx_asignacion_docente (id_curso_asignatura);

-- === TRX_INSCRIPCION ===
ALTER TABLE trx_inscripcion ADD CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante) REFERENCES mae_estudiante (id_estudiante);
ALTER TABLE trx_inscripcion ADD CONSTRAINT fk_inscripcion_curso FOREIGN KEY (id_curso) REFERENCES est_curso (id_curso);
CREATE INDEX ix_inscripcion_curso ON trx_inscripcion (id_curso);

-- === TRX_CALIFICACION ===
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_inscripcion FOREIGN KEY (id_inscripcion) REFERENCES trx_inscripcion (id_inscripcion);
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_ponderacion_periodo FOREIGN KEY (id_ponderacion_periodo) REFERENCES est_ponderacion_periodo (id_ponderacion_periodo);
CREATE INDEX ix_calificacion_ponderacion_periodo ON trx_calificacion (id_ponderacion_periodo);
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_calificacion_ordinaria FOREIGN KEY (id_calificacion_ordinaria) REFERENCES trx_calificacion (id_calificacion);
CREATE INDEX ix_calificacion_calificacion_ordinaria ON trx_calificacion (id_calificacion_ordinaria);
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_calificacion_sustituida FOREIGN KEY (id_calificacion_sustituida) REFERENCES trx_calificacion (id_calificacion);
CREATE INDEX ix_calificacion_calificacion_sustituida ON trx_calificacion (id_calificacion_sustituida);
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_asignacion_docente FOREIGN KEY (id_asignacion_docente) REFERENCES trx_asignacion_docente (id_asignacion);
CREATE INDEX ix_calificacion_asignacion_docente ON trx_calificacion (id_asignacion_docente);
ALTER TABLE trx_calificacion ADD CONSTRAINT fk_calificacion_docente_registra FOREIGN KEY (id_docente_registra) REFERENCES mae_docente (id_docente);
CREATE INDEX ix_calificacion_docente_registra ON trx_calificacion (id_docente_registra);

-- === TRX_RESULTADO_PERIODO ===
ALTER TABLE trx_resultado_periodo ADD CONSTRAINT fk_resultado_periodo_estudiante FOREIGN KEY (id_estudiante) REFERENCES mae_estudiante (id_estudiante);
ALTER TABLE trx_resultado_periodo ADD CONSTRAINT fk_resultado_periodo_asignatura FOREIGN KEY (id_asignatura) REFERENCES mae_asignatura (id_asignatura);
CREATE INDEX ix_resultado_periodo_asignatura ON trx_resultado_periodo (id_asignatura);
ALTER TABLE trx_resultado_periodo ADD CONSTRAINT fk_resultado_periodo_periodo FOREIGN KEY (id_periodo) REFERENCES est_periodo_academico (id_periodo);
CREATE INDEX ix_resultado_periodo_periodo ON trx_resultado_periodo (id_periodo);
ALTER TABLE trx_resultado_periodo ADD CONSTRAINT fk_resultado_periodo_calificacion_seleccionada FOREIGN KEY (id_calificacion_seleccionada) REFERENCES trx_calificacion (id_calificacion);
CREATE INDEX ix_resultado_periodo_calificacion_seleccionada ON trx_resultado_periodo (id_calificacion_seleccionada);

-- === TRX_SESION_CLASE ===
ALTER TABLE trx_sesion_clase ADD CONSTRAINT fk_sesion_clase_ponderacion_periodo FOREIGN KEY (id_ponderacion_periodo) REFERENCES est_ponderacion_periodo (id_ponderacion_periodo);
ALTER TABLE trx_sesion_clase ADD CONSTRAINT fk_sesion_clase_asignacion FOREIGN KEY (id_asignacion) REFERENCES trx_asignacion_docente (id_asignacion);
CREATE INDEX ix_sesion_clase_asignacion ON trx_sesion_clase (id_asignacion);

-- === TRX_ASISTENCIA ===
ALTER TABLE trx_asistencia ADD CONSTRAINT fk_asistencia_inscripcion FOREIGN KEY (id_inscripcion) REFERENCES trx_inscripcion (id_inscripcion);
ALTER TABLE trx_asistencia ADD CONSTRAINT fk_asistencia_sesion FOREIGN KEY (id_sesion) REFERENCES trx_sesion_clase (id_sesion);
CREATE INDEX ix_asistencia_sesion ON trx_asistencia (id_sesion);

-- === TRX_BECA ===
ALTER TABLE trx_beca ADD CONSTRAINT fk_beca_inscripcion FOREIGN KEY (id_inscripcion) REFERENCES trx_inscripcion (id_inscripcion);
CREATE INDEX ix_beca_inscripcion ON trx_beca (id_inscripcion);
ALTER TABLE trx_beca ADD CONSTRAINT fk_beca_tipo_beca FOREIGN KEY (id_tipo_beca) REFERENCES cat_tipo_beca (id_tipo_beca);
CREATE INDEX ix_beca_tipo_beca ON trx_beca (id_tipo_beca);

-- === TRX_BECA_VIGENCIA ===
ALTER TABLE trx_beca_vigencia ADD CONSTRAINT fk_beca_vigencia_beca FOREIGN KEY (id_beca) REFERENCES trx_beca (id_beca);

-- === ERRORES_ETL_EVALUACIONES ===
ALTER TABLE errores_etl_evaluaciones ADD CONSTRAINT fk_errores_etl_ejecucion FOREIGN KEY (id_ejecucion) REFERENCES auditoria_etl_evaluaciones (id_ejecucion);
CREATE INDEX ix_errores_etl_ejecucion ON errores_etl_evaluaciones (id_ejecucion);

-- === TRX_CONTROL_CARGA ===
ALTER TABLE trx_control_carga ADD CONSTRAINT fk_control_carga_curso FOREIGN KEY (id_curso) REFERENCES est_curso (id_curso);
ALTER TABLE trx_control_carga ADD CONSTRAINT fk_control_carga_periodo FOREIGN KEY (id_periodo) REFERENCES est_periodo_academico (id_periodo);
CREATE INDEX ix_control_carga_periodo ON trx_control_carga (id_periodo);
ALTER TABLE trx_control_carga ADD CONSTRAINT fk_control_carga_ejecucion FOREIGN KEY (id_ejecucion) REFERENCES auditoria_etl_evaluaciones (id_ejecucion);
CREATE INDEX ix_control_carga_ejecucion ON trx_control_carga (id_ejecucion);
PROMPT DDL de referencia creado; las reglas entre filas se comprueban con VALIDAR_MODELOS.sql.
