# Diccionario de datos — Modelo educativo escolar

## Diagrama entidad-relación (DER)

[Consultar el DER en ToDiagram](https://todiagram.com/editor?doc=8c24f0523d8da690df328b98)

Archivo de esta entrega: `DER.mmd`.

## Alcance y capas de datos

El modelo cubre parvularia, básica y bachillerato. Este diccionario contiene **33 tablas y 235 campos**, organizados para la operación académica y el soporte a las cargas de información.

- **Operación:** registra personas, instituciones, cursos, inscripciones, docentes, calificaciones, sesiones, asistencia y becas. Es la base de origen para calcular los KPI acordados.
- **Soporte ETL:** incluye controles de carga, auditoría de ejecuciones y registro de errores para validar entregas y dar seguimiento al procesamiento. La extracción, transformación y carga se implementarán mediante procesos que utilicen estas estructuras.
- **BI y análisis:** al construir el dashboard probablemente se necesitarán tablas adicionales de staging para recibir y preparar datos, y un esquema dimensional con tablas de hechos y dimensiones para facilitar las consultas, los filtros y las agregaciones. Estas estructuras se definirán al desarrollar la solución de BI, a partir del modelo operacional y de las reglas de los KPI.

Una tabla técnica separada, `ctl_carga_staging`, serializa las ejecuciones mediante una fila de control; no es matrícula ni una ejecución académica. Las **29 tablas de staging** se documentan en `Staging/Diccionario_Staging.md`. Conservan tipos y claves de origen como datos, añaden las fechas de recuperación y registran `id_ejecucion_carga` y `fecha_carga`. Las reglas académicas se verifican antes de confirmar la carga; no se deduce su cumplimiento por haber copiado filas.

La ubicación se relaciona directamente con `cat_departamento`: `mae_institucion.id_departamento` representa la actual y `est_institucion_ciclo.id_departamento`, la conservada para cada año. Los KPI territoriales utilizan esta última; zona urbana/rural y dirección permanecen independientes.

## Convenciones para Oracle

- El modelo se instala en Oracle Database 23ai y también funciona en 19c y 21c. La columna Tipo Oracle propuesto concreta el tipo lógico del DER; las longitudes y escalas deben comprobarse contra las fuentes antes de ejecutar el DDL, sin truncar ni redondear datos silenciosamente.
- PK es clave primaria; FK, referencia a otra tabla; UK, unicidad. Los componentes de una clave compuesta se interpretan juntos. Cada rol tiene id_persona obligatorio y único; una misma persona puede tener ambos roles.
- Los booleanos usan NUMBER(1), NOT NULL y CHECK de 0/1. Los dominios cerrados usan VARCHAR2(30 CHAR) y CHECK IN; sus valores figuran debajo de cada tabla. Un CHECK de dominio no sustituye NOT NULL.
- Los textos usan VARCHAR2(n CHAR). NIE y documento conservan sus ceros iniciales. Oracle considera la cadena vacía como NULL; el ETL debe normalizar espacios y validar campos obligatorios.
- DATE también almacena hora en Oracle: los campos de día académico se normalizan con TRUNC. TIMESTAMP(6) conserva fecha y hora bajo una convención horaria documentada.
- Las notas y porcentajes se proponen con cuatro decimales; horas y créditos también. El peso relativo usa NUMBER sin escala fija. Validar precisión de origen y redondear únicamente la presentación de los promedios.
- El JSON de errores usa CLOB NOT NULL y CHECK IS JSON STRICT. Una entrada malformada se conserva como texto dentro de un objeto JSON válido.
- Las comprobaciones entre tablas y los solapamientos requieren FKs y procedimientos PL/SQL transaccionales. Los CHECK por fila no contienen subconsultas.
- La identidad personal y el documento se registran una sola vez en mae_persona. Las fechas y los estados de cada rol conservan su propio significado.

Los tipos y CHECK aquí descritos son los que crea `SCRIPT_BASE.sql`. El resumen funcional del modelo está en `Acerca_del_modelo.md`.


### cat_tipo_documento

Tipos de documento personal

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_tipo_documento | NUMBER(10,0) | PK | No | Identificador interno y único del tipo de documento; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer el tipo de documento en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible del tipo de documento; por ejemplo, DUI o pasaporte. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_tipo_institucion

Clasificacion institucional

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_tipo_institucion | NUMBER(10,0) | PK | No | Identificador interno y único del tipo de institución; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer el tipo de institución en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible del tipo de institución; por ejemplo, pública, privada o mixta. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_departamento

Departamentos

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_departamento | NUMBER(10,0) | PK | No | Identificador interno y único del departamento; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código estable del departamento utilizado por la fuente territorial; facilita conciliar archivos. Se conserva el identificador interno como PK. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre legible del departamento; por ejemplo, San Salvador. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_zona

Zona urbana o rural del centro

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_zona | NUMBER(10,0) | PK | No | Identificador interno y único de la zona del centro educativo; permite referenciarlo desde otras tablas. |
| nombre | VARCHAR2(150 CHAR) | UK | No | Nombre único de la zona del centro educativo, como Urbana o Rural; se usa para mostrar y filtrar indicadores. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_modalidad

Presencial, en linea o semipresencial

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_modalidad | NUMBER(10,0) | PK | No | Identificador interno y único de la modalidad de enseñanza; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer la modalidad de enseñanza en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible de la modalidad de enseñanza; por ejemplo, presencial, en línea o semipresencial. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_jornada

Matutina, vespertina, nocturna u otra acordada

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_jornada | NUMBER(10,0) | PK | No | Identificador interno y único de la jornada del grupo; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer la jornada del grupo en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible de la jornada del grupo; por ejemplo, matutina, vespertina o nocturna. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_area_conocimiento

Areas de conocimiento

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_area | NUMBER(10,0) | PK | No | Identificador interno y único del área de conocimiento; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer el área de conocimiento en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible del área de conocimiento; por ejemplo, Ciencias o Lenguaje. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_tipo_beca

Tipo y motivo de beca

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_tipo_beca | NUMBER(10,0) | PK | No | Identificador interno y único del tipo o motivo de beca; permite referenciarlo desde otras tablas. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable para reconocer el tipo o motivo de beca en archivos, integraciones y consultas. |
| descripcion | VARCHAR2(500 CHAR) | — | No | Nombre o descripción legible del tipo o motivo de beca; por ejemplo, apoyo económico o mérito académico. |
| activo | NUMBER(1) | — | No | Indica si el valor puede utilizarse en nuevos registros; desactivarlo conserva las referencias históricas. |


### cat_nivel

Nivel educativo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_nivel | NUMBER(10,0) | PK | No | Identificador interno del nivel educativo. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable del nivel; por ejemplo, BAS para básica. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre del nivel escolar; por ejemplo, parvularia, básica o bachillerato. |
| orden | NUMBER(10,0) | — | No | Posición del nivel en la secuencia educativa; permite ordenar reportes sin depender del nombre. |


### cat_grado

Grado perteneciente a un nivel

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_grado | NUMBER(10,0) | PK | No | Identificador interno del grado; se utiliza para clasificar los cursos. |
| id_nivel | NUMBER(10,0) | FK | No | Nivel educativo al que pertenece el grado. Referencia: `cat_nivel`. |
| codigo | VARCHAR2(50 CHAR) | — | No | Código del grado dentro del nivel; debe ser único junto con id_nivel. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre del grado; por ejemplo, Octavo o Primero de bachillerato. La sección se define en est_curso. |
| orden | NUMBER(10,0) | — | No | Posición del grado dentro de su nivel; ayuda a presentar la secuencia de grados. |
| es_ultimo_grado | NUMBER(1) | — | No | Indica que es el último grado cubierto por el proyecto. Para excluir a una persona de la cohorte de retención también se exige resultado GRADUADO; cursar este grado no demuestra graduación. |

Unicidad compuesta: (id_nivel, codigo).


### mae_institucion

Identidad estable y configuracion actual del centro

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_institucion | NUMBER(10,0) | PK | No | Identificador interno y estable del centro educativo; se conserva aunque cambien sus datos. |
| codigo_institucion | VARCHAR2(50 CHAR) | UK | No | Código único del centro utilizado para reconocerlo en las fuentes e integraciones. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre del centro educativo que se muestra en consultas y reportes. |
| id_tipo_institucion | NUMBER(10,0) | FK | No | Clasificación actual del centro, como público, privado o mixto. La clasificación histórica por ciclo se conserva en est_institucion_ciclo. Referencia: `cat_tipo_institucion`. |
| id_departamento | NUMBER(10,0) | FK | No | Departamento actual del centro; permite agrupar indicadores por territorio. Su valor histórico se conserva por ciclo. Referencia: `cat_departamento`. |
| id_zona | NUMBER(10,0) | FK | No | Zona actual del centro, como urbana o rural. Su valor histórico se conserva por ciclo. Referencia: `cat_zona`. |
| permite_becas | NUMBER(1) | — | No | Indica si el centro está habilitado para otorgar becas según su configuración actual. Los beneficios efectivamente concedidos se registran en trx_beca. |
| direccion | VARCHAR2(500 CHAR) | — | No | Dirección física registrada del centro educativo. |
| telefono | VARCHAR2(30 CHAR) | — | Sí | Número de contacto del centro; se almacena como texto para conservar prefijos y formato. |
| email | VARCHAR2(254 CHAR) | — | Sí | Correo electrónico de contacto del centro. |
| fecha_creacion | DATE | — | No | Fecha de creación registrada para la institución. |
| activo | NUMBER(1) | — | No | Indica si el centro está habilitado para nuevas operaciones; conserva su identidad y sus registros históricos. |


### mae_persona

Identidad y datos personales compartidos por estudiantes y docentes

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_persona | NUMBER(10,0) | PK | No | Identificador interno y estable de la persona; permite compartir su identidad entre los roles de estudiante y docente. |
| id_tipo_documento | NUMBER(10,0) | FK | Sí | Tipo del documento personal. Puede omitirse únicamente si también se omite numero_documento. Referencia: `cat_tipo_documento`. |
| numero_documento | VARCHAR2(50 CHAR) | — | Sí | Número del documento como texto. Es único junto con id_tipo_documento; conserva ceros iniciales y solo puede omitirse junto con el tipo. |
| primer_nombre | VARCHAR2(100 CHAR) | — | No | Primer nombre de la persona, utilizado para identificarla y mostrarla en listados. |
| segundo_nombre | VARCHAR2(100 CHAR) | — | Sí | Segundo nombre de la persona, cuando exista o esté informado. |
| primer_apellido | VARCHAR2(100 CHAR) | — | No | Primer apellido de la persona. |
| segundo_apellido | VARCHAR2(100 CHAR) | — | Sí | Segundo apellido de la persona, cuando exista o esté informado. |
| fecha_nacimiento | DATE | — | No | Fecha de nacimiento; permite calcular la edad a una fecha de corte sin almacenar una edad que cambia con el tiempo. |
| sexo | VARCHAR2(30 CHAR) | — | Sí | Sexo informado mediante M, F u OTRO; NULL cuando no se informó. El ETL utiliza una equivalencia explícita con las categorías de la fuente. |
| email | VARCHAR2(254 CHAR) | — | Sí | Correo electrónico de contacto, si está disponible. |
| telefono | VARCHAR2(30 CHAR) | — | Sí | Teléfono de contacto como texto, si está disponible. |
| direccion | VARCHAR2(500 CHAR) | — | Sí | Dirección de residencia informada de la persona. Los KPI territoriales del proyecto utilizan el departamento histórico del centro educativo. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora en que se creó la identidad compartida en el sistema; las altas de los roles se registran por separado. |

Unicidad compuesta: (id_tipo_documento, numero_documento).

- Valores de sexo: M, F, OTRO.
- Tipo y número de documento: ambos presentes o ambos NULL; la combinación es única entre todas las personas.
- Nombres coincidentes no autorizan fusionar identidades. Utilizar documento, NIE a través del rol de estudiante o una correspondencia de origen verificada.
- Sexo usa el dominio inicial M, F, OTRO; NULL significa no informado. Conservar equivalencias documentadas con la fuente y rechazar categorías sin correspondencia, sin adivinarlas.
- DOCUMENTO_COMPLETO_O_AUSENTE: Tipo y número de documento se informan juntos; ambos NULL están permitidos en distintas personas y la pareja informada es única.

### mae_estudiante

Rol de estudiante vinculado a una identidad personal compartida

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_estudiante | NUMBER(10,0) | PK | No | Identificador interno y estable del estudiante; enlaza su historial aunque cambie de curso o institución. |
| id_persona | NUMBER(10,0) | FK,UK | No | Persona que posee este rol de estudiante. Es obligatoria y única dentro del rol; los datos personales se consultan en mae_persona. Referencia: `mae_persona`. |
| nie | VARCHAR2(30 CHAR) | UK | No | Número de Identificación del Estudiante, único. Se guarda como texto para conservar los ceros iniciales. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora de creación del rol de estudiante; puede ser distinta de la fecha de creación de la persona. |
| activo | NUMBER(1) | — | No | Indica si la identidad está habilitada para nuevas operaciones. La matrícula vigente se determina con trx_inscripcion y sus fechas. |

Unicidad: (id_persona).

- Cada persona tiene como máximo un rol de estudiante; puede tener también el otro rol sin duplicar su identidad.

### mae_docente

Rol de docente vinculado a una identidad personal compartida

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_docente | NUMBER(10,0) | PK | No | Identificador interno y estable del docente; permite seguir sus asignaciones en diferentes centros y ciclos. |
| id_persona | NUMBER(10,0) | FK,UK | No | Persona que posee este rol de docente. Es obligatoria y única dentro del rol; los datos personales se consultan en mae_persona. Referencia: `mae_persona`. |
| especialidad | VARCHAR2(250 CHAR) | — | Sí | Especialidad académica o profesional informada del docente. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora de creación del rol de docente; puede ser distinta de la fecha de creación de la persona. |
| activo | NUMBER(1) | — | No | Indica si la identidad está habilitada para nuevas operaciones. Los grupos y centros donde enseña se obtienen de sus asignaciones y vigencias. |

Unicidad: (id_persona).

- Cada persona tiene como máximo un rol de docente; puede tener también el otro rol sin duplicar su identidad.

### mae_asignatura

Identidad de la materia; sin horas ni creditos dependientes del grupo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_asignatura | NUMBER(10,0) | PK | No | Identificador interno y único de la materia; permite relacionarla con los grupos donde se ofrece. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único y estable de la materia; por ejemplo, MAT para Matemática. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre de la materia que se muestra en horarios, consultas y reportes. |
| id_area | NUMBER(10,0) | FK | No | Área de conocimiento a la que pertenece la materia; permite agrupar resultados de materias relacionadas. Referencia: `cat_area_conocimiento`. |
| descripcion | VARCHAR2(500 CHAR) | — | Sí | Detalle opcional sobre el contenido o propósito de la materia. |
| activo | NUMBER(1) | — | No | Indica si la materia puede incorporarse a nuevas ofertas; desactivarla conserva sus resultados históricos. |


### est_ciclo

Calendario académico: año escolar con su propia cantidad de períodos

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_ciclo | NUMBER(10,0) | PK | No | Identificador interno del calendario académico. |
| codigo | VARCHAR2(50 CHAR) | UK | No | Código único del ciclo, utilizado para reconocerlo en las fuentes y consultas. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre legible del ciclo; por ejemplo, Año académico 2026 o Año escolar 2026-2027. |
| anio | NUMBER(4,0) | — | No | Año de referencia del ciclo; si cruza años calendario, es el año de inicio (2026 para agosto 2026–junio 2027). Varios ciclos pueden compartir el mismo año. Facilita filtros y comparaciones interanuales. |
| fecha_inicio | DATE | — | No | Primer día del ciclo académico; delimita sus períodos y la vigencia ordinaria de las inscripciones. |
| fecha_fin | DATE | — | No | Último día del ciclo académico. Limita la matrícula efectiva; una recuperación posterior puede autorizarse mediante su ventana específica. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación administrativa del ciclo: planificado, abierto o cerrado. El cierre interviene en la publicación de resultados finales. |

- Valores de estado: PLANIFICADO, ABIERTO, CERRADO.
- CICLO_CON_PERIODOS_PROPIOS: Cada ciclo define cuántos períodos de evaluación tiene; por ejemplo, tres trimestres en el calendario nacional o cuatro períodos en algunos bachilleratos. El ciclo no tiene duración fija y puede cruzar años calendario. Si en una misma institución y año conviven niveles con distinta cantidad de períodos, se registran ciclos separados, cada uno con su contexto en est_institucion_ciclo; los cursos y plazos referencian el que corresponde.
- CICLO_ANIO_INICIO (aviso): anio coincide con el año de fecha_inicio, también cuando el ciclo cruza años calendario. Se informa como aviso de calidad y no bloquea.

### est_periodo_academico

Periodos de evaluacion dentro de un ciclo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_periodo | NUMBER(10,0) | PK | No | Identificador interno del período de evaluación. |
| id_ciclo | NUMBER(10,0) | FK | No | Ciclo académico al que pertenece el período. Referencia: `est_ciclo`. |
| numero | NUMBER(10,0) | — | No | Posición del período dentro del ciclo: entero positivo, numerado desde 1 en orden temporal. La cantidad de períodos depende del ciclo. Es única junto con id_ciclo. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre legible del período; por ejemplo, Primer trimestre o Período 4. |
| fecha_inicio | DATE | — | No | Primer día académico del período; debe estar dentro del ciclo y respetar el orden de los períodos. |
| fecha_fin | DATE | — | No | Último día académico del período; permite saber si ya concluyó. Puede diferir de la fecha límite para cargar sus notas. |

Unicidad compuesta: (id_ciclo, numero).

- PERIODOS_EN_CICLO_SIN_SOLAPAR: Los periodos estan contenidos en el ciclo, tienen orden temporal y no se solapan; los extremos de fecha son inclusivos.
- PERIODOS_CONSECUTIVOS (aviso): La numeración de cada ciclo va de 1 a N sin huecos y sigue el orden de fecha_inicio. Un hueco puede indicar un período no cargado, que el plan completo no detecta porque se compara con los períodos configurados. Se informa como aviso de calidad y no bloquea la operación ni la carga.

### est_institucion_ciclo

Contexto institucional congelado para el ciclo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_institucion | NUMBER(10,0) | PK,FK | No | Centro cuyo contexto se conserva para el año académico; forma parte de la clave primaria compuesta. Referencia: `mae_institucion`. |
| id_ciclo | NUMBER(10,0) | PK,FK | No | Ciclo para el que se conserva ese contexto; completa la clave primaria con id_institucion. Referencia: `est_ciclo`. |
| id_tipo_institucion | NUMBER(10,0) | FK | No | Tipo institucional que se utiliza para analizar ese ciclo, aunque la clasificación actual del centro cambie posteriormente. Referencia: `cat_tipo_institucion`. |
| id_departamento | NUMBER(10,0) | FK | No | Departamento institucional conservado para el ciclo; es la referencia territorial histórica de los KPI. Referencia: `cat_departamento`. |
| id_zona | NUMBER(10,0) | FK | No | Zona urbana o rural conservada para el ciclo, utilizada en comparaciones históricas. Referencia: `cat_zona`. |
| permite_becas | NUMBER(1) | — | No | Habilitación para otorgar becas conservada para ese ciclo; permite validar beneficios con la configuración histórica. |
| fecha_corte_matricula | DATE | — | No | Día de referencia para observar la población matriculada del centro en el ciclo y comparar cohortes. No es la fecha de inscripción de una persona ni una fecha límite para inscribirse. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación administrativa del contexto institucional del ciclo: planificado, abierto o cerrado. |

Clave primaria compuesta: (id_institucion, id_ciclo).

- Valores de estado: PLANIFICADO, ABIERTO, CERRADO.
- La PK es compuesta: institucion y ciclo. Es una instantanea anual, no una duplicacion del dato actual.

### est_curso

Grupo concreto de una institucion durante un ciclo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_curso | NUMBER(10,0) | PK | No | Identificador interno del grupo concreto de un año académico; por ejemplo, Octavo A nocturno de un centro en 2026. |
| id_institucion | NUMBER(10,0) | FK | No | Centro que ofrece el grupo. Junto con id_ciclo debe existir en est_institucion_ciclo. Referencia: `mae_institucion`. |
| id_ciclo | NUMBER(10,0) | FK | No | Año académico del grupo; permite diferenciar grupos similares de años distintos. Referencia: `est_ciclo`. |
| id_grado | NUMBER(10,0) | FK | No | Grado que cursa el grupo; su nivel se obtiene desde cat_grado. Referencia: `cat_grado`. |
| id_jornada | NUMBER(10,0) | FK | No | Jornada del grupo, como matutina, vespertina o nocturna. Referencia: `cat_jornada`. |
| id_modalidad | NUMBER(10,0) | FK | No | Forma de enseñanza del grupo, como presencial, en línea o semipresencial. Referencia: `cat_modalidad`. |
| codigo | VARCHAR2(50 CHAR) | — | No | Código operativo del grupo utilizado por la fuente. En el modelo actual no tiene una restricción de unicidad individual. |
| nombre | VARCHAR2(150 CHAR) | — | No | Nombre legible del grupo para listados y reportes. |
| seccion | VARCHAR2(20 CHAR) | — | No | Identificador de la sección, como A o B; diferencia grupos del mismo centro, ciclo, grado y jornada. |
| capacidad_maxima | NUMBER(10,0) | — | No | Cantidad máxima de estudiantes prevista simultáneamente en el grupo; debe ser mayor que 0. Por defecto es referencial: solo se exige si se activa la política de capacidad estricta. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación del grupo: planificado, activo, cerrado o anulado; ayuda a distinguir la oferta efectiva de registros sin efecto. |

Unicidad compuesta: (id_institucion, id_ciclo, id_grado, id_jornada, seccion).

- Valores de estado: PLANIFICADO, ACTIVO, CERRADO, ANULADO.
- FK compuesta (id_institucion, id_ciclo) → est_institucion_ciclo (id_institucion, id_ciclo).
- CAPACIDAD_ESTRICTA (opcional): Desactivada por defecto. Al activarla (val_politica.capacidad_estricta = 1), las inscripciones no anuladas vigentes a la vez no pueden superar capacidad_maxima. Desactivada, la ocupación solo se consulta en VW_CAPACIDAD_CURSOS.

### est_curso_asignatura

Oferta de asignaturas del grupo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_curso_asignatura | NUMBER(10,0) | PK | No | Identificador de una materia ofrecida en un grupo concreto; enlaza su plan, docentes y actividad académica. |
| id_curso | NUMBER(10,0) | FK | No | Grupo en el que se ofrece la materia. Referencia: `est_curso`. |
| id_asignatura | NUMBER(10,0) | FK | No | Materia del catálogo que se ofrece en el grupo. Referencia: `mae_asignatura`. |
| horas_semanales | NUMBER(8,4) | — | No | Carga semanal de enseñanza de la materia en este grupo; puede variar entre ofertas de la misma materia. |
| creditos | NUMBER(8,4) | — | Sí | Créditos asignados a esta oferta si el centro los utiliza; puede quedar NULL cuando no aplica. No modifican automáticamente las reglas de promedio acordadas. |
| tipo_resultado | VARCHAR2(30 CHAR) | — | No | Indica si la materia registra calificaciones numéricas o resultados cualitativos; evita convertir categorías en números arbitrarios. |
| regla_recuperacion | VARCHAR2(30 CHAR) | — | No | Regla para seleccionar el resultado aplicable después de una recuperación: mejor nota o última recuperación. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación de la oferta de la materia: planificada, activa o anulada. |

Unicidad compuesta: (id_curso, id_asignatura).

- Valores de tipo_resultado: NUMERICA, CUALITATIVA.
- Valores de regla_recuperacion: MEJOR_NOTA, ULTIMA_RECUPERACION.
- Valores de estado: PLANIFICADA, ACTIVA, ANULADA.

### est_ponderacion_periodo

Materia ofrecida, período y peso relativo de su calificación del período

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_ponderacion_periodo | NUMBER(10,0) | PK | No | Identificador de la configuración de una materia del grupo en un período; relaciona su peso, sus calificaciones y sus sesiones. |
| id_curso_asignatura | NUMBER(10,0) | FK | No | Oferta de la materia a la que se aplica este componente del plan. Referencia: `est_curso_asignatura`. |
| id_periodo | NUMBER(10,0) | FK | No | Período académico cuyo resultado se pondera; debe pertenecer al ciclo del curso. Referencia: `est_periodo_academico`. |
| peso | NUMBER | — | No | Peso relativo positivo de la nota consolidada del período en el promedio anual de la materia. Se normaliza contra el plan completo; los pesos no tienen que sumar 100. |
| estado | VARCHAR2(30 CHAR) | — | No | Indica si el componente está en borrador, publicado o anulado. La publicación requiere el plan completo y sus pesos se congelan cuando existen resultados. |

Unicidad compuesta: (id_curso_asignatura, id_periodo).

- Valores de estado: BORRADOR, PUBLICADO, ANULADO.
- El periodo y el curso deben pertenecer al mismo ciclo. Peso relativo estrictamente positivo.
- PESOS_COHERENTES_TRASLADO: Para el proyecto, las ofertas del mismo ciclo, grado y asignatura comparten el mismo vector de pesos normalizados. Antes de combinar notas de centros distintos, normalizar cada peso contra el total del plan completo de su oferta. Nunca mezclar pesos crudos de planes diferentes.
- PLAN_COMPLETO_PUBLICADO: Publicar solo cuando exista un peso positivo por cada período configurado en el ciclo del curso; congelar el plan cuando tenga resultados.

### est_plazo_registro_notas

Plazo institucional de registro por grado, período y tipo de intento

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_plazo_registro_notas | NUMBER(10,0) | PK | No | Identificador del plazo de registro de notas para un centro, ciclo, grado, período y tipo de intento. |
| id_institucion | NUMBER(10,0) | FK | No | Centro al que corresponde la ventana; junto con id_ciclo referencia su contexto anual. Referencia: `mae_institucion`. |
| id_ciclo | NUMBER(10,0) | FK | No | Ciclo académico al que corresponden las notas, aunque se registren posteriormente. Referencia: `est_ciclo`. |
| id_grado | NUMBER(10,0) | FK | No | Grado para el que se configura la ventana; permite calendarios de entrega distintos entre grados. Referencia: `cat_grado`. |
| id_periodo | NUMBER(10,0) | FK | No | Período cuyas notas se reciben; debe pertenecer al mismo ciclo. Referencia: `est_periodo_academico`. |
| tipo_intento | VARCHAR2(30 CHAR) | — | No | Distingue una ventana para notas ordinarias de una para recuperaciones. |
| fecha_inicio_recuperacion | DATE | — | Sí | Primer día autorizado para realizar la recuperación. Es obligatorio en RECUPERACION y NULL en ORDINARIA; puede ser posterior al fin del ciclo. |
| fecha_fin_recuperacion | DATE | — | Sí | Último día autorizado para realizar la recuperación. Es obligatorio en RECUPERACION y NULL en ORDINARIA; debe respetar el inicio autorizado. |
| fecha_apertura_registro | TIMESTAMP(6) | — | No | Fecha y hora desde la que se autoriza el registro de las notas correspondientes a este plazo. |
| fecha_limite_registro | TIMESTAMP(6) | — | No | Fecha y hora límite prevista para entregar las notas; permite identificar obligaciones vencidas. |
| fecha_cierre_registro | TIMESTAMP(6) | — | Sí | Fecha y hora en que se cerró efectivamente el registro de notas. NULL significa que todavía no se ha registrado ese cierre; es independiente del fin del período académico. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación de la ventana: programada, abierta o cerrada. |

Unicidad compuesta: (id_institucion, id_ciclo, id_grado, id_periodo, tipo_intento).

- Valores de tipo_intento: ORDINARIA, RECUPERACION.
- Valores de estado: PROGRAMADA, ABIERTA, CERRADA.
- FK compuesta (id_institucion, id_ciclo) → est_institucion_ciclo (id_institucion, id_ciclo). El periodo pertenece al mismo ciclo.
- INTERVALO_RECUPERACION_SEPARADO: En RECUPERACION ambas fechas de evaluacion son obligatorias y ordenadas; en ORDINARIA ambas son NULL. Las fechas de captura no sustituyen las del examen.
- PLAZO_CIERRE_COHERENTE: Un plazo cerrado tiene fecha efectiva de cierre; los plazos abiertos o programados no la tienen. La apertura no supera el límite y el cierre no precede a la apertura.


### trx_asignacion_docente

Docente que ensena una asignatura del grupo durante una vigencia

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_asignacion | NUMBER(10,0) | PK | No | Identificador de la responsabilidad docente sobre una materia ofrecida durante una vigencia. |
| id_docente | NUMBER(10,0) | FK | No | Docente responsable de impartir la materia durante el intervalo indicado. Referencia: `mae_docente`. |
| id_curso_asignatura | NUMBER(10,0) | FK | No | Materia y grupo sobre los que se asigna al docente; desde el grupo se obtiene la institución. Referencia: `est_curso_asignatura`. |
| fecha_asignacion | TIMESTAMP(6) | — | No | Fecha y hora en que se registró administrativamente la asignación; puede diferir del inicio efectivo. |
| fecha_inicio | DATE | — | No | Primer día efectivo de responsabilidad docente sobre la oferta. |
| fecha_fin | DATE | — | Sí | Último día efectivo de esa responsabilidad. Puede quedar NULL mientras no se haya informado su finalización, dentro del ciclo correspondiente. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación de la asignación: programada, vigente, finalizada o anulada; se interpreta junto con sus fechas. |

- Valores de estado: PROGRAMADA, VIGENTE, FINALIZADA, ANULADA.

### trx_inscripcion

Pertenencia historica del estudiante al grupo

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_inscripcion | NUMBER(10,0) | PK | No | Identificador de un intervalo de pertenencia del estudiante a un grupo; permite conservar retiros, traslados y reingresos. |
| id_estudiante | NUMBER(10,0) | FK | No | Estudiante al que corresponde la inscripción. Referencia: `mae_estudiante`. |
| id_curso | NUMBER(10,0) | FK | No | Grupo al que pertenece el estudiante; desde aquí se obtiene su institución, ciclo, grado, jornada y modalidad históricos. Referencia: `est_curso`. |
| fecha_inscripcion | TIMESTAMP(6) | — | No | Fecha y hora de registro administrativo de la inscripción; puede diferir del primer día de pertenencia efectiva. |
| fecha_inicio | DATE | — | No | Primer día de pertenencia efectiva al grupo; permite decidir qué sesiones y obligaciones corresponden al estudiante. |
| fecha_fin | DATE | — | Sí | Último día de pertenencia efectiva al grupo. Si está NULL, las consultas limitan la vigencia al fin del ciclo; no implica matrícula en el año siguiente. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación de la inscripción: vigente, finalizada, retirada, trasladada o anulada. Se interpreta junto con las fechas. |
| motivo_fin_inscripcion | VARCHAR2(500 CHAR) | — | Sí | Explica por qué terminó la pertenencia al grupo, como traslado, retiro o finalización. El cierre de una inscripción no demuestra abandono escolar. |
| resultado_cierre | VARCHAR2(30 CHAR) | — | Sí | Resultado académico del cierre: promovido, repite o graduado. Puede quedar NULL mientras esté pendiente; permite tratar correctamente la retención y los egresados. |

Unicidad compuesta: (id_estudiante, id_curso, fecha_inicio).

- Valores de estado: VIGENTE, FINALIZADA, RETIRADA, TRASLADADA, ANULADA.
- Valores de resultado_cierre: PROMOVIDO, REPITE, GRADUADO.
- VIGENCIA_LIMITADA_CICLO: Inicio dentro del ciclo; fin explicito dentro del ciclo si existe. Para consultas de matricula, el fin efectivo es el menor entre el fin informado y el fin del ciclo; si no hay fin, usar el del ciclo. Un estado VIGENTE no extiende la matricula a otro ano.
- CIERRE_INSCRIPCION: Una inscripción FINALIZADA, RETIRADA o TRASLADADA requiere fecha_fin y motivo_fin_inscripcion con texto. Ambos campos solo pueden quedar NULL en VIGENTE o ANULADA.

### trx_calificacion

Calificación real consolidada de un período e intento, con sus versiones

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_calificacion | NUMBER(10,0) | PK | No | Identificador de una versión concreta de una calificación real del período y de un intento. |
| id_inscripcion | NUMBER(10,0) | FK | No | Inscripción de origen de la nota; conserva el estudiante y el grupo donde se produjo el resultado. Referencia: `trx_inscripcion`. |
| id_ponderacion_periodo | NUMBER(10,0) | FK | No | Materia ofrecida y período a los que corresponde la nota; aporta su peso y contexto académico. Referencia: `est_ponderacion_periodo`. |
| tipo_intento | VARCHAR2(30 CHAR) | — | No | Distingue la calificación ordinaria de una recuperación del mismo período. |
| numero_intento | NUMBER(10,0) | — | No | Número del intento: 1 para la ordinaria y 2 o más para recuperaciones. Se mantiene al corregir una versión del mismo intento. |
| version | NUMBER(10,0) | — | No | Número de versión de la calificación dentro del mismo intento. Una corrección agrega una versión y conserva la anterior. |
| id_calificacion_ordinaria | NUMBER(10,0) | FK | Sí | Calificación ordinaria a la que corresponde esta recuperación. Es obligatoria en RECUPERACION y NULL en ORDINARIA; una recuperación es otro intento, no una corrección de versión. Referencia: `trx_calificacion`. |
| id_calificacion_sustituida | NUMBER(10,0) | FK | Sí | Versión anterior que se corrige, del mismo intento. NULL en la primera versión. Referencia la calificación anterior, no necesariamente el resultado seleccionado del período. Referencia: `trx_calificacion`. |
| id_asignacion_docente | NUMBER(10,0) | FK | No | Asignación docente responsable de la calificación; identifica la oferta y la responsabilidad académica histórica. Puede diferir del docente que registra la nota. En la ordinaria debe estar vigente en fecha_evaluacion; en la recuperación, en algún momento del período que se recupera. Referencia: `trx_asignacion_docente`. |
| id_docente_registra | NUMBER(10,0) | FK | No | Docente que registró la nota; puede diferir del responsable académico. Referencia: `mae_docente`. |
| nota | NUMBER(7,4) | — | Sí | Calificación numérica real de 0 a 100. Es obligatoria para una oferta numérica y NULL para una cualitativa; nunca representa una nota pendiente ni un promedio temporal. |
| resultado_cualitativo | VARCHAR2(100 CHAR) | — | Sí | Resultado textual real de una oferta cualitativa; queda NULL en una oferta numérica. Exactamente uno de este campo y nota debe tener valor. |
| fecha_evaluacion | DATE | — | No | Fecha académica del resultado, aunque se capture después; en recuperación debe respetar el intervalo de examen autorizado. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora de incorporación de esta versión de la nota; permite distinguir el hecho académico de su captura. |
| fecha_validacion | TIMESTAMP(6) | — | Sí | Fecha y hora en que se aceptó la versión para su uso académico. NULL indica que todavía no está validada. |
| fecha_anulacion | TIMESTAMP(6) | — | Sí | Fecha y hora desde la que esta versión queda anulada. NULL indica que no tiene una anulación registrada; anularla no reactiva automáticamente versiones anteriores. |
| motivo_anulacion | VARCHAR2(500 CHAR) | — | Sí | Explicación de la anulación cuando se registra; permite interpretar por qué dejó de utilizarse el resultado. |

Unicidad compuesta: (id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version).

- Valores de tipo_intento: ORDINARIA, RECUPERACION.
- Nota numerica o resultado cualitativo, exactamente uno. Una nota pendiente no genera fila.
- Las correcciones agregan version; no sobrescriben el valor anterior.
- id_calificacion_ordinaria enlaza la recuperación con su ordinaria; id_calificacion_sustituida enlaza una corrección con una versión anterior del mismo intento. No son intercambiables.
- La validación, corrección o anulación debe actualizar la selección del resultado dentro de la misma transacción.
- ANULACION_SIN_REVIVIR_VERSION: Por intento, elegir primero la ultima version validada al corte; luego evaluar si fue anulada al corte. Si fue anulada, el intento no aporta nota; no revivir una version antigua. Borradores no sustituyen versiones validadas.
- RECUPERACION_POST_CICLO: Una recuperacion puede ocurrir tras el fin del ciclo o de la inscripcion, si referencia su ordinaria, el mismo plan y el intervalo de evaluacion de recuperacion autorizado. No reabrir la matricula ni cambiar su fecha academica. La ventana de captura es distinta.
- CALIFICACION_CONTEXTO_COHERENTE: La inscripción y la ponderación deben corresponder al mismo curso; la asignación docente debe pertenecer a la misma oferta. La ordinaria respeta el período y la pertenencia del estudiante; la recuperación usa la excepción autorizada ya definida. Ordinaria de origen y versión sustituida corresponden al mismo estudiante, materia y período; la sustituida pertenece al mismo intento y tiene una versión menor.
- RECUPERACION_RESPONSABLE: La asignación de una recuperación pertenece a la misma oferta y estuvo vigente en algún momento del período que se recupera: su intervalo se cruza con fecha_inicio–fecha_fin del período, y fecha_fin NULL se interpreta hasta el fin del período. No se exige vigencia en la fecha del examen, porque las asignaciones terminan con el ciclo y la recuperación puede ser posterior. Si hubo cambio de docente durante el período, sirve cualquiera de los responsables; una suplencia de otro período no sirve. Quien registra la nota queda en id_docente_registra.
- INTENTO_ORDINARIO_Y_RECUPERACION: La ordinaria es el intento 1 y no referencia una ordinaria de origen; las recuperaciones son intentos 2 o superiores y sí la referencian. Las correcciones mantienen el intento y aumentan la versión.
- RESULTADO_REAL_EXCLUYENTE: Cada fila guarda exactamente un resultado real numérico o cualitativo; las notas pendientes no generan filas.
- VERSION_CON_ANTECEDENTE: La versión 1 no tiene sustituida; una corrección posterior referencia una versión anterior del mismo intento.
- FECHAS_CALIFICACION_ORDENADAS: La validación y la anulación no preceden al registro; una anulación requiere motivo.


### trx_resultado_periodo

Selección versionada de la calificación usada para el período, sin duplicar nota ni promedio

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_resultado | NUMBER(10,0) | PK | No | Identificador de una versión de la selección del resultado aplicable para un estudiante, materia y período. |
| id_estudiante | NUMBER(10,0) | FK | No | Estudiante cuyo resultado se selecciona, independientemente de los traslados que haya tenido. Referencia: `mae_estudiante`. |
| id_asignatura | NUMBER(10,0) | FK | No | Materia a la que corresponde el resultado seleccionado. Referencia: `mae_asignatura`. |
| id_periodo | NUMBER(10,0) | FK | No | Período académico al que corresponde la selección. Referencia: `est_periodo_academico`. |
| id_calificacion_seleccionada | NUMBER(10,0) | FK | No | Referencia a la calificación real elegida como resultado de ese período: ordinaria, recuperación o versión corregida. No es el promedio anual y no duplica el valor de la nota; debe corresponder al mismo estudiante, materia y período. Referencia: `trx_calificacion`. |
| version | NUMBER(10,0) | — | No | Número de versión de la selección. Permite cambiar el resultado aplicado conservando la historia de decisiones. |
| criterio | VARCHAR2(30 CHAR) | — | No | Motivo o regla de selección: ordinaria, mejor nota, última recuperación, corrección o traslado. |
| fecha_seleccion | TIMESTAMP(6) | — | No | Fecha y hora en que se estableció esta selección; permite reconstruir cuál se utilizaba a una fecha de corte. |
| fecha_cierre | TIMESTAMP(6) | — | Sí | Fecha y hora en que se cerró el resultado del período. Puede quedar NULL mientras esté abierto; el cierre anual exige además las demás condiciones del modelo. |

Unicidad compuesta: (id_estudiante, id_asignatura, id_periodo, version).

- Valores de criterio: ORDINARIA, MEJOR_NOTA, ULTIMA_RECUPERACION, CORRECCION, TRASLADO.
- La evaluacion referenciada debe corresponder al mismo estudiante, asignatura y periodo.
- La version vigente es la ultima seleccion a la fecha de corte; no contiene nota ni promedio duplicado.
- Conservar la referencia seleccionada y su historial para reproducir cierres y emisiones. Los promedios actual y anual se calculan a partir de las calificaciones seleccionadas.
- RIESGO_SOLO_CON_DATOS_COMPLETOS: Para el riesgo académico usar un periodo academico concluido, todas las notas numericas esperadas del estudiante en ese periodo y toda su asistencia correspondiente capturada; al menos una nota numerica y una sesion. En otro caso mostrar informacion insuficiente. La falta de períodos futuros no bloquea el riesgo de un período ya completo.
- COMPLETITUD_MISMAS_OBLIGACIONES: Para medir la completitud de notas, derivar obligaciones ordinarias únicas por estudiante, asignatura y período, según trayectoria, plan publicado y fecha_limite_registro vencida al corte. El numerador cuenta como máximo un resultado seleccionado válido de esas mismas obligaciones, aunque provenga de recuperación o corrección. No contar filas de intentos/versiones ni notas de plazos aún no vencidos. Una recuperación no crea otra obligación ordinaria. Si falta el plan o el plazo necesario, mostrar configuración incompleta, no completitud del 100 %.
- SELECCION_VERSION_VIGENTE: La selección debe referenciar la última versión validada de su intento a la fecha de selección; una corrección posterior no invalida decisiones históricas anteriores.
- SELECCION_POLITICA: La selección respeta MEJOR_NOTA o ULTIMA_RECUPERACION entre los intentos válidos del mismo contexto a fecha_seleccion; se elige la última versión validada antes de revisar anulaciones y no se anticipan eventos futuros.


### trx_sesion_clase

Una sesion de una asignatura ofrecida

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_sesion | NUMBER(10,0) | PK | No | Identificador de una sesión concreta de clase; es la unidad a la que se registra la asistencia. |
| id_ponderacion_periodo | NUMBER(10,0) | FK | No | Materia ofrecida y período a los que pertenece la sesión. Referencia: `est_ponderacion_periodo`. |
| id_asignacion | NUMBER(10,0) | FK | No | Asignación del docente responsable de la sesión, compatible con la oferta y su vigencia. Referencia: `trx_asignacion_docente`. |
| fecha_academica | DATE | — | No | Día académico al que se atribuye la sesión. Permanece como referencia aunque una clase nocturna termine después de medianoche. |
| inicio | TIMESTAMP(6) | — | No | Fecha y hora de inicio de la sesión. |
| fin | TIMESTAMP(6) | — | No | Fecha y hora de finalización de la sesión; debe ser posterior al inicio y puede corresponder al día siguiente. |
| estado | VARCHAR2(30 CHAR) | — | No | Indica si la sesión está programada, fue impartida o se canceló. El denominador de asistencia utiliza sesiones impartidas que correspondían al estudiante. |
| observaciones | VARCHAR2(1000 CHAR) | — | Sí | Detalle opcional sobre la sesión, como la causa de una cancelación. |

Unicidad compuesta: (id_ponderacion_periodo, inicio).

- Valores de estado: PROGRAMADA, IMPARTIDA, CANCELADA.
- SESION_CONTEXTO_COHERENTE: La asignación y la ponderación pertenecen a la misma oferta. La fecha académica pertenece al período y a la vigencia de la asignación. fin es posterior a inicio; una sesión nocturna puede terminar el día siguiente. La sesión empieza el mismo día de fecha_academica (TRUNC(inicio) = fecha_academica): no se programan clases que comiencen después de medianoche.


### trx_asistencia

Estado de asistencia del inscrito a una sesion

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_asistencia | NUMBER(10,0) | PK | No | Identificador del registro de asistencia de una inscripción a una sesión. |
| id_inscripcion | NUMBER(10,0) | FK | No | Inscripción del estudiante cuya asistencia se registra; debe estar vigente para la sesión correspondiente. Referencia: `trx_inscripcion`. |
| id_sesion | NUMBER(10,0) | FK | No | Sesión concreta a la que corresponde la asistencia. Junto con id_inscripcion evita duplicar el registro. Referencia: `trx_sesion_clase`. |
| estado | VARCHAR2(30 CHAR) | — | No | Resultado observado de asistencia: presente, tarde, ausente o justificada. Una fila que no existe significa captura pendiente, no ausencia automática. |
| hora_llegada | TIMESTAMP(6) | — | Sí | Fecha y hora de llegada si fue capturada; puede quedar NULL cuando no se dispone de ese dato o no corresponde. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora de captura del registro de asistencia. |
| observaciones | VARCHAR2(1000 CHAR) | — | Sí | Detalle opcional, como el motivo de una ausencia justificada o de una llegada tardía. |

Unicidad compuesta: (id_inscripcion, id_sesion).

- Valores de estado: PRESENTE, TARDE, AUSENTE, JUSTIFICADA.
- ASISTENCIA_COBERTURA_SEPARADA: La asistencia distingue sesiones aplicables de registros recibidos. Con captura parcial, la asistencia observada es presencias / sesiones aplicables con asistencia registrada; la cobertura es sesiones con registro / sesiones aplicables. Mostrar ambas y etiquetar el resultado como provisional. La tasa definitiva usa todas las sesiones aplicables cuando la captura está completa. Con sesiones pero sin registros, mostrar Sin datos, no 0 %; sin sesiones aplicables, No aplica. El riesgo académico sigue exigiendo captura completa.
- ASISTENCIA_CONTEXTO_COHERENTE: La inscripción pertenece al mismo curso que la sesión y está vigente en su fecha académica. El estado actual FINALIZADA, RETIRADA o TRASLADADA no elimina asistencias históricas válidas; ANULADA queda excluida.
- ASISTENCIA_SESION_IMPARTIDA: Solo se registra asistencia de sesiones IMPARTIDA y después de su fin (fecha_registro ≥ fin). Una sesión que no esté IMPARTIDA no puede conservar asistencias registradas. AUSENTE y JUSTIFICADA no tienen hora_llegada.


### trx_beca

Beneficio concedido a una inscripcion, separado de la politica institucional

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_beca | NUMBER(10,0) | PK | No | Identificador del beneficio efectivamente otorgado; sus intervalos de aplicación se registran en trx_beca_vigencia. |
| id_inscripcion | NUMBER(10,0) | FK | No | Inscripción beneficiaria; permite atribuir la beca al estudiante, centro y ciclo correspondientes. Referencia: `trx_inscripcion`. |
| id_tipo_beca | NUMBER(10,0) | FK | No | Categoría o motivo de la beca concedida, como apoyo económico o mérito académico. Referencia: `cat_tipo_beca`. |
| porcentaje | NUMBER(7,4) | — | No | Porcentaje del beneficio concedido, mayor que 0 y hasta 100. Si concurren beneficios sobre la misma base, su suma no puede exceder 100. |
| fecha_otorgamiento | DATE | — | No | Fecha en que se concedió el beneficio; puede diferir del inicio de su aplicación efectiva. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora en que se incorporó el otorgamiento al sistema. |
| observaciones | VARCHAR2(1000 CHAR) | — | Sí | Detalle opcional sobre el otorgamiento del beneficio. |


### trx_beca_vigencia

Intervalos efectivos del beneficio, incluyendo suspensiones

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_vigencia | NUMBER(10,0) | PK | No | Identificador de un intervalo continuo en que una beca se aplica efectivamente. |
| id_beca | NUMBER(10,0) | FK | No | Beneficio al que corresponde el intervalo. Referencia: `trx_beca`. |
| fecha_inicio | DATE | — | No | Primer día efectivo del beneficio en este intervalo. Una reanudación después de una suspensión genera un intervalo nuevo. |
| fecha_fin | DATE | — | Sí | Último día efectivo del intervalo. Puede quedar NULL mientras no se haya informado su finalización, siempre limitado por la inscripción y el ciclo. |
| motivo_fin | VARCHAR2(30 CHAR) | — | Sí | Causa del cierre del intervalo: fin de vigencia, suspensión, cancelación o traslado. Puede quedar NULL mientras el intervalo siga abierto. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora en que se registró el intervalo de vigencia. |

Unicidad compuesta: (id_beca, fecha_inicio).

- Valores de motivo_fin: FIN_VIGENCIA, SUSPENSION, CANCELACION, TRASLADO.
- ESTADO_BECA_DERIVADO: La vigencia de la beca se deriva de intervalos efectivos no solapados, acotados por inscripción y ciclo. fecha_fin es inclusiva; una suspensión cierra el intervalo y una reanudación agrega otro. No se añade un estado duplicado a trx_beca.
- MOTIVO_FIN_CON_CIERRE: motivo_fin es obligatorio cuando el intervalo tiene fecha_fin y queda NULL mientras sigue abierto.


### auditoria_etl_evaluaciones

Ejecuciones de carga

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_ejecucion | NUMBER(10,0) | PK | No | Identificador de una ejecución del ETL; relaciona sus errores y controles de cobertura. |
| fuente | VARCHAR2(500 CHAR) | — | No | Identifica el archivo, sistema o entrega de origen procesado por la ejecución. |
| inicio | TIMESTAMP(6) | — | No | Fecha y hora en que comenzó la ejecución. |
| fin | TIMESTAMP(6) | — | Sí | Fecha y hora en que terminó la ejecución; puede quedar NULL mientras esté en proceso. |
| estado | VARCHAR2(30 CHAR) | — | No | Situación técnica de la ejecución: en proceso, completada o error. Completar una ejecución no demuestra que el centro haya entregado toda la información esperada. |
| total_leidos | NUMBER(10,0) | — | No | Cantidad total de registros leídos de la fuente durante la ejecución. |
| insertados | NUMBER(10,0) | — | No | Cantidad de registros nuevos incorporados correctamente durante la ejecución. |
| actualizados | NUMBER(10,0) | — | No | Cantidad de registros existentes actualizados correctamente durante la ejecución; las correcciones de calificaciones deben respetar el versionado académico. |
| rechazados | NUMBER(10,0) | — | No | Cantidad de registros rechazados por validaciones; sus detalles se conservan en errores_etl_evaluaciones. |

- Valores de estado: EN_PROCESO, COMPLETADA, ERROR.

### errores_etl_evaluaciones

Errores y registros rechazados

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_error | NUMBER(10,0) | PK | No | Identificador de un error o rechazo detectado por el ETL. |
| id_ejecucion | NUMBER(10,0) | FK | No | Ejecución durante la que se detectó el problema. Referencia: `auditoria_etl_evaluaciones`. |
| entidad | VARCHAR2(100 CHAR) | — | No | Tipo de información afectada, como estudiante, evaluación, asistencia o beca. |
| clave_origen | VARCHAR2(250 CHAR) | — | Sí | Identificador del registro en la fuente, si está disponible; ayuda a localizarlo para corregirlo. |
| tipo_error | VARCHAR2(100 CHAR) | — | No | Categoría del problema, como formato inválido, referencia inexistente o dato duplicado. |
| detalle | VARCHAR2(1000 CHAR) | — | No | Explicación concreta del error y del dato o regla que impidió aceptar el registro. |
| json_original | CLOB | — | No | Contenido original del registro rechazado en formato JSON; permite revisar el dato recibido y preparar su corrección. |
| fecha_registro | TIMESTAMP(6) | — | No | Fecha y hora en que se registró el error. |


### trx_control_carga

Cobertura declarada por curso, periodo, dominio y corte

| Campo | Tipo Oracle propuesto | Clave | Admite NULL | ¿Para qué sirve? |
|---|---|---|---|---|
| id_control | NUMBER(10,0) | PK | No | Identificador de la declaración de cobertura de una entrega para un curso, período, dominio y fecha de corte. |
| id_curso | NUMBER(10,0) | FK | No | Grupo cuya información se está declarando completa, parcial o no aplicable. Referencia: `est_curso`. |
| id_periodo | NUMBER(10,0) | FK | No | Período al que corresponde la información controlada; debe ser compatible con el ciclo del curso. Referencia: `est_periodo_academico`. |
| dominio | VARCHAR2(30 CHAR) | — | No | Conjunto de datos controlado: matrícula, notas, asistencia o becas. Cada dominio tiene su propia declaración. |
| fecha_corte | DATE | — | No | Fecha hasta la que se evalúa la cobertura de la información. Una entrega completa al corte no requiere datos futuros. |
| estado | VARCHAR2(30 CHAR) | — | No | COMPLETA confirma la entrega total correspondiente al corte; PARCIAL indica faltantes; NO_APLICA requiere una regla explícita. Cero casos confirmados puede ser COMPLETA; sin control, la cobertura es desconocida. |
| registros_declarados | NUMBER(10,0) | — | No | Cantidad de registros declarada por la fuente para esa entrega y alcance; admite cero confirmado. El conteo por sí solo no demuestra que la entrega esté completa. |
| fecha_recepcion | TIMESTAMP(6) | — | No | Fecha y hora en que se recibió la entrega o declaración de cobertura; puede ser posterior a su fecha de corte. |
| id_ejecucion | NUMBER(10,0) | FK | No | Ejecución del ETL que procesó y dejó trazabilidad de esta declaración de cobertura. Referencia: `auditoria_etl_evaluaciones`. |

Unicidad compuesta: (id_curso, id_periodo, dominio, fecha_corte).

- Valores de dominio: MATRICULA, NOTAS, ASISTENCIA, BECAS.
- Valores de estado: COMPLETA, PARCIAL, NO_APLICA.
- RETENCION_CON_COBERTURA_DESTINO: Retencion definitiva solo con cobertura de matricula completa del alcance del ciclo destino al corte acordado. Una carga pendiente no prueba no continuidad.


## Trazabilidad con las validaciones

Cada regla del script se registra en `val_regla` con prefijo `OPERACION_` (tablas OLTP) o `STAGING_` (tablas `STG_*`). La tabla siguiente omite ese prefijo y relaciona cada regla con la del diccionario que implementa. El detalle por tabla, con el mecanismo que aplica cada regla, está en `Validacion/Reglas_por_tabla.md`; el resumen, en `Validacion/Reglas_principales.md`. Severidad: BLOQUEO impide confirmar la operación o la carga; PENDIENTE y AVISO solo se informan con `pr_diagnosticar_validaciones` y `VW_AVISOS_CALIDAD`.

Familias generadas por campo, en ambas capas:

- `<TABLA>_NN_<campo>`: campo obligatorio (columna Admite NULL = No).
- `<TABLA>_CK_<campo>_n`: dominio, rango o día normalizado con TRUNC.
- `<TABLA>_PK`, `<TABLA>_UK_<columnas>` y `<TABLA>_FK_<columnas>`: clave primaria, claves únicas y foráneas; las columnas van sin el prefijo `id_` (por ejemplo, `OPERACION_TRX_INSCRIPCION_FK_curso`).
- `TEXTO_<TABLA>_<campo>`: texto obligatorio que no queda vacío tras TRIM.
- `<TABLA>_BC_<REGLA>`: regla por fila con el mismo nombre que en el diccionario.
- Solo staging: `<TABLA>_METADATOS` (la copia conserva una ejecución de carga existente) y `MAE_ESTUDIANTE_*_JOIN_*` (dominios de la persona recibidos con el estudiante).

| Regla del script | Severidad | Capas | Tabla | Regla o campo del diccionario |
|---|---|---|---|---|
| PERIODO_CICLO | BLOQUEO | Operación y staging | est_periodo_academico | PERIODOS_EN_CICLO_SIN_SOLAPAR, CICLO_CON_PERIODOS_PROPIOS |
| PERIODOS_SOLAPADOS | BLOQUEO | Operación y staging | est_periodo_academico | PERIODOS_EN_CICLO_SIN_SOLAPAR |
| PERIODOS_CONSECUTIVOS | AVISO | Operación y staging | est_periodo_academico | PERIODOS_CONSECUTIVOS |
| CICLO_ANIO_INICIO | AVISO | Operación y staging | est_ciclo | CICLO_ANIO_INICIO |
| CORTE_EN_CICLO | BLOQUEO | Operación y staging | est_institucion_ciclo | fecha_corte_matricula dentro del ciclo |
| PLAN_CICLO | BLOQUEO | Operación y staging | est_ponderacion_periodo | Período y curso del mismo ciclo |
| PLAN_COMPLETO | BLOQUEO | Operación y staging | est_ponderacion_periodo | PLAN_COMPLETO_PUBLICADO |
| OFERTA_CON_PLAN | PENDIENTE | Operación y staging | est_curso_asignatura | PLAN_COMPLETO_PUBLICADO |
| PLAN_CON_PLAZO | PENDIENTE | Operación y staging | est_ponderacion_periodo | COMPLETITUD_MISMAS_OBLIGACIONES (configuración incompleta) |
| PESOS_COMPARABLES | BLOQUEO | Operación y staging | est_ponderacion_periodo | PESOS_COHERENTES_TRASLADO |
| PLAZO_CICLO | BLOQUEO | Operación y staging | est_plazo_registro_notas | Período del mismo ciclo que el plazo |
| EST_PLAZO_REGISTRO_NOTAS_BC_PLAZO_CIERRE_COHERENTE | BLOQUEO | Operación y staging | est_plazo_registro_notas | PLAZO_CIERRE_COHERENTE |
| RECUPERACION_FECHAS | BLOQUEO | Operación y staging | est_plazo_registro_notas | INTERVALO_RECUPERACION_SEPARADO |
| INSCRIPCION_CICLO | BLOQUEO | Operación y staging | trx_inscripcion | VIGENCIA_LIMITADA_CICLO |
| INSCRIPCIONES_SOLAPADAS | BLOQUEO | Operación y staging | trx_inscripcion | VIGENCIA_LIMITADA_CICLO; sin inscripciones ordinarias solapadas |
| CIERRE_INSCRIPCION | BLOQUEO | Operación y staging | trx_inscripcion | CIERRE_INSCRIPCION |
| CAPACIDAD_ESTRICTA | BLOQUEO si se activa | Operación | trx_inscripcion | CAPACIDAD_ESTRICTA |
| ASIGNACION_CICLO | BLOQUEO | Operación y staging | trx_asignacion_docente | fecha_inicio y fecha_fin dentro del ciclo |
| ASIGNACIONES_SOLAPADAS | BLOQUEO | Operación y staging | trx_asignacion_docente | Un responsable por oferta y fecha |
| MAE_PERSONA_BC_DOCUMENTO_COMPLETO_O_AUSENTE | BLOQUEO | Operación | mae_persona | DOCUMENTO_COMPLETO_O_AUSENTE |
| NACIMIENTO_FUTURO | BLOQUEO | Operación | mae_persona | fecha_nacimiento no futura |
| TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION | BLOQUEO | Operación y staging | trx_calificacion | INTENTO_ORDINARIO_Y_RECUPERACION |
| TRX_CALIFICACION_BC_RESULTADO_REAL_EXCLUYENTE | BLOQUEO | Operación y staging | trx_calificacion | RESULTADO_REAL_EXCLUYENTE |
| TIPO_RESULTADO | BLOQUEO | Operación y staging | trx_calificacion | RESULTADO_REAL_EXCLUYENTE (coherente con la oferta) |
| TRX_CALIFICACION_BC_VERSION_CON_ANTECEDENTE | BLOQUEO | Operación y staging | trx_calificacion | VERSION_CON_ANTECEDENTE |
| VERSION_ANTERIOR | BLOQUEO | Operación y staging | trx_calificacion | VERSION_CON_ANTECEDENTE, CALIFICACION_CONTEXTO_COHERENTE |
| TRX_CALIFICACION_BC_FECHAS_CALIFICACION_ORDENADAS | BLOQUEO | Operación y staging | trx_calificacion | FECHAS_CALIFICACION_ORDENADAS |
| REGISTRO_NO_ANTICIPADO | BLOQUEO | Operación y staging | trx_calificacion | FECHAS_CALIFICACION_ORDENADAS |
| CALIFICACION_CONTEXTO | BLOQUEO | Operación y staging | trx_calificacion | CALIFICACION_CONTEXTO_COHERENTE |
| ORDINARIA_VIGENCIA | BLOQUEO | Operación y staging | trx_calificacion | CALIFICACION_CONTEXTO_COHERENTE |
| RECUPERACION_RESPONSABLE | BLOQUEO | Operación y staging | trx_calificacion | RECUPERACION_RESPONSABLE |
| ORIGEN_RECUPERACION | BLOQUEO | Operación y staging | trx_calificacion | RECUPERACION_POST_CICLO, CALIFICACION_CONTEXTO_COHERENTE |
| CAPTURA_AUTORIZADA | BLOQUEO | Operación y staging | trx_calificacion | RECUPERACION_POST_CICLO, INTERVALO_RECUPERACION_SEPARADO |
| RESULTADO_CORRESPONDE | BLOQUEO | Operación y staging | trx_resultado_periodo | La calificación seleccionada corresponde a estudiante, asignatura y período |
| SELECCION_VERSION_VIGENTE | BLOQUEO | Operación y staging | trx_resultado_periodo | SELECCION_VERSION_VIGENTE, ANULACION_SIN_REVIVIR_VERSION |
| SELECCION_POLITICA | BLOQUEO | Operación y staging | trx_resultado_periodo | SELECCION_POLITICA |
| SESION_CONTEXTO | BLOQUEO | Operación y staging | trx_sesion_clase | SESION_CONTEXTO_COHERENTE |
| SESIONES_SIMULTANEAS | BLOQUEO | Operación y staging | trx_sesion_clase | Un docente o grupo sin sesiones simultáneas |
| ASISTENCIA_CONTEXTO | BLOQUEO | Operación y staging | trx_asistencia | ASISTENCIA_CONTEXTO_COHERENTE, ASISTENCIA_SESION_IMPARTIDA |
| ASISTENCIA_LLEGADA | BLOQUEO | Operación y staging | trx_asistencia | ASISTENCIA_SESION_IMPARTIDA |
| BECA_HABILITADA | BLOQUEO | Operación y staging | trx_beca | est_institucion_ciclo.permite_becas |
| BECA_VIGENCIA | BLOQUEO | Operación y staging | trx_beca_vigencia | ESTADO_BECA_DERIVADO, MOTIVO_FIN_CON_CIERRE |
| BECA_SOLAPADA | BLOQUEO | Operación y staging | trx_beca_vigencia | ESTADO_BECA_DERIVADO |
| PORCENTAJE_SIMULTANEO | BLOQUEO | Operación y staging | trx_beca_vigencia | trx_beca.porcentaje (suma simultánea ≤ 100) |
| CONTROL_CICLO | BLOQUEO | Operación y staging | trx_control_carga | Curso y período del mismo ciclo |
| AUDITORIA_TIEMPOS | BLOQUEO | Operación | auditoria_etl_evaluaciones | inicio y fin coherentes |

ANULACION_SIN_REVIVIR_VERSION y SELECCION_POLITICA también se aplican en `FN_ELEGIR_CALIFICACION`, que propone la selección. RIESGO_SOLO_CON_DATOS_COMPLETOS, COMPLETITUD_MISMAS_OBLIGACIONES, ASISTENCIA_COBERTURA_SEPARADA y RETENCION_CON_COBERTURA_DESTINO son reglas de cálculo de los KPI, no validaciones de datos, y no tienen una regla en `val_regla`.
