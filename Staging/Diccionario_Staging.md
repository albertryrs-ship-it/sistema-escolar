# Diccionario de staging

**29 tablas, 260 campos:** 202 copiados del origen y 58 metadatos de carga. El resumen para lectura rápida está en `Staging_en_resumen.md`.

Cada columna copiada conserva el tipo Oracle, la nulabilidad y el significado de su campo de origen; su descripción está en `General/Diccionario_Datos_Educacion.md`. Las claves del origen se guardan como datos y se validan con reglas, sin PK/UK/FK físicas entre las STG, para poder diagnosticar duplicados y referencias rotas. La única FK física es la técnica: `id_ejecucion_carga` → `auditoria_etl_evaluaciones`. La tabla técnica `ctl_carga_staging` tiene una sola fila: el cargador la bloquea para que no haya dos cargas a la vez.

Todas las tablas terminan con dos metadatos: `id_ejecucion_carga`, la ejecución técnica que hizo la copia (distinta del `id_ejecucion` de origen en STG_CONTROL_CARGA), y `fecha_carga`, el momento de la extracción, igual para todas las filas de una ejecución; nunca reemplaza las fechas académicas.

### STG_CALIFICACIONES

Origen: `trx_calificacion s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_calificacion | NUMBER(10,0) | Dato PK del origen | No | = `trx_calificacion.id_calificacion` |
| id_inscripcion | NUMBER(10,0) | Dato FK del origen | No | = `trx_calificacion.id_inscripcion` |
| id_ponderacion_periodo | NUMBER(10,0) | Dato FK del origen | No | = `trx_calificacion.id_ponderacion_periodo` |
| tipo_intento | VARCHAR2(30 CHAR) | — | No | = `trx_calificacion.tipo_intento` |
| numero_intento | NUMBER(10,0) | — | No | = `trx_calificacion.numero_intento` |
| version | NUMBER(10,0) | — | No | = `trx_calificacion.version` |
| id_calificacion_ordinaria | NUMBER(10,0) | Dato FK del origen | Sí | = `trx_calificacion.id_calificacion_ordinaria` |
| id_calificacion_sustituida | NUMBER(10,0) | Dato FK del origen | Sí | = `trx_calificacion.id_calificacion_sustituida` |
| id_asignacion_docente | NUMBER(10,0) | Dato FK del origen | No | = `trx_calificacion.id_asignacion_docente` |
| id_docente_registra | NUMBER(10,0) | Dato FK del origen | No | = `trx_calificacion.id_docente_registra` |
| nota | NUMBER(7,4) | — | Sí | = `trx_calificacion.nota` |
| resultado_cualitativo | VARCHAR2(100 CHAR) | — | Sí | = `trx_calificacion.resultado_cualitativo` |
| fecha_evaluacion | DATE | — | No | = `trx_calificacion.fecha_evaluacion` |
| fecha_registro | TIMESTAMP(6) | — | No | = `trx_calificacion.fecha_registro` |
| fecha_validacion | TIMESTAMP(6) | — | Sí | = `trx_calificacion.fecha_validacion` |
| fecha_anulacion | TIMESTAMP(6) | — | Sí | = `trx_calificacion.fecha_anulacion` |
| motivo_anulacion | VARCHAR2(500 CHAR) | — | Sí | = `trx_calificacion.motivo_anulacion` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_ASISTENCIAS

Origen: `trx_asistencia s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_asistencia | NUMBER(10,0) | Dato PK del origen | No | = `trx_asistencia.id_asistencia` |
| id_inscripcion | NUMBER(10,0) | Dato FK del origen | No | = `trx_asistencia.id_inscripcion` |
| id_sesion | NUMBER(10,0) | Dato FK del origen | No | = `trx_asistencia.id_sesion` |
| estado | VARCHAR2(30 CHAR) | — | No | = `trx_asistencia.estado` |
| hora_llegada | TIMESTAMP(6) | — | Sí | = `trx_asistencia.hora_llegada` |
| fecha_registro | TIMESTAMP(6) | — | No | = `trx_asistencia.fecha_registro` |
| observaciones | VARCHAR2(1000 CHAR) | — | Sí | = `trx_asistencia.observaciones` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_INSCRIPCIONES

Origen: `trx_inscripcion s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_inscripcion | NUMBER(10,0) | Dato PK del origen | No | = `trx_inscripcion.id_inscripcion` |
| id_estudiante | NUMBER(10,0) | Dato FK del origen | No | = `trx_inscripcion.id_estudiante` |
| id_curso | NUMBER(10,0) | Dato FK del origen | No | = `trx_inscripcion.id_curso` |
| fecha_inscripcion | TIMESTAMP(6) | — | No | = `trx_inscripcion.fecha_inscripcion` |
| fecha_inicio | DATE | — | No | = `trx_inscripcion.fecha_inicio` |
| fecha_fin | DATE | — | Sí | = `trx_inscripcion.fecha_fin` |
| estado | VARCHAR2(30 CHAR) | — | No | = `trx_inscripcion.estado` |
| motivo_fin_inscripcion | VARCHAR2(500 CHAR) | — | Sí | = `trx_inscripcion.motivo_fin_inscripcion` |
| resultado_cierre | VARCHAR2(30 CHAR) | — | Sí | = `trx_inscripcion.resultado_cierre` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_ESTUDIANTES

Origen: `mae_estudiante s JOIN mae_persona p ON p.id_persona = s.id_persona`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_estudiante | NUMBER(10,0) | Dato PK del origen | No | = `mae_estudiante.id_estudiante` |
| id_persona | NUMBER(10,0) | Dato FK,UK del origen | No | = `mae_estudiante.id_persona` |
| nie | VARCHAR2(30 CHAR) | Dato UK del origen | No | = `mae_estudiante.nie` |
| fecha_registro_estudiante | TIMESTAMP(6) | — | No | Renombrado de `mae_estudiante.fecha_registro`. |
| estudiante_activo | NUMBER(1) | — | No | Renombrado de `mae_estudiante.activo`. |
| fecha_nacimiento | DATE | — | No | = `mae_persona.fecha_nacimiento` |
| sexo | VARCHAR2(30 CHAR) | — | Sí | = `mae_persona.sexo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_CICLOS

Origen: `est_ciclo s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_ciclo | NUMBER(10,0) | Dato PK del origen | No | = `est_ciclo.id_ciclo` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `est_ciclo.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `est_ciclo.nombre` |
| anio | NUMBER(4,0) | — | No | = `est_ciclo.anio` |
| fecha_inicio | DATE | — | No | = `est_ciclo.fecha_inicio` |
| fecha_fin | DATE | — | No | = `est_ciclo.fecha_fin` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_ciclo.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_PERIODOS

Origen: `est_periodo_academico s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_periodo | NUMBER(10,0) | Dato PK del origen | No | = `est_periodo_academico.id_periodo` |
| id_ciclo | NUMBER(10,0) | Dato FK del origen | No | = `est_periodo_academico.id_ciclo` |
| numero | NUMBER(10,0) | — | No | = `est_periodo_academico.numero` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `est_periodo_academico.nombre` |
| fecha_inicio | DATE | — | No | = `est_periodo_academico.fecha_inicio` |
| fecha_fin | DATE | — | No | = `est_periodo_academico.fecha_fin` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_CURSOS

Origen: `est_curso s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_curso | NUMBER(10,0) | Dato PK del origen | No | = `est_curso.id_curso` |
| id_institucion | NUMBER(10,0) | Dato FK del origen | No | = `est_curso.id_institucion` |
| id_ciclo | NUMBER(10,0) | Dato FK del origen | No | = `est_curso.id_ciclo` |
| id_grado | NUMBER(10,0) | Dato FK del origen | No | = `est_curso.id_grado` |
| id_jornada | NUMBER(10,0) | Dato FK del origen | No | = `est_curso.id_jornada` |
| id_modalidad | NUMBER(10,0) | Dato FK del origen | No | = `est_curso.id_modalidad` |
| codigo | VARCHAR2(50 CHAR) | — | No | = `est_curso.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `est_curso.nombre` |
| seccion | VARCHAR2(20 CHAR) | — | No | = `est_curso.seccion` |
| capacidad_maxima | NUMBER(10,0) | — | No | = `est_curso.capacidad_maxima` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_curso.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_CURSOS_ASIGNATURAS

Origen: `est_curso_asignatura s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_curso_asignatura | NUMBER(10,0) | Dato PK del origen | No | = `est_curso_asignatura.id_curso_asignatura` |
| id_curso | NUMBER(10,0) | Dato FK del origen | No | = `est_curso_asignatura.id_curso` |
| id_asignatura | NUMBER(10,0) | Dato FK del origen | No | = `est_curso_asignatura.id_asignatura` |
| horas_semanales | NUMBER(8,4) | — | No | = `est_curso_asignatura.horas_semanales` |
| creditos | NUMBER(8,4) | — | Sí | = `est_curso_asignatura.creditos` |
| tipo_resultado | VARCHAR2(30 CHAR) | — | No | = `est_curso_asignatura.tipo_resultado` |
| regla_recuperacion | VARCHAR2(30 CHAR) | — | No | = `est_curso_asignatura.regla_recuperacion` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_curso_asignatura.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_PONDERACIONES

Origen: `est_ponderacion_periodo s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_ponderacion_periodo | NUMBER(10,0) | Dato PK del origen | No | = `est_ponderacion_periodo.id_ponderacion_periodo` |
| id_curso_asignatura | NUMBER(10,0) | Dato FK del origen | No | = `est_ponderacion_periodo.id_curso_asignatura` |
| id_periodo | NUMBER(10,0) | Dato FK del origen | No | = `est_ponderacion_periodo.id_periodo` |
| peso | NUMBER | — | No | = `est_ponderacion_periodo.peso` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_ponderacion_periodo.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_RESULTADOS_PERIODO

Origen: `trx_resultado_periodo s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_resultado | NUMBER(10,0) | Dato PK del origen | No | = `trx_resultado_periodo.id_resultado` |
| id_estudiante | NUMBER(10,0) | Dato FK del origen | No | = `trx_resultado_periodo.id_estudiante` |
| id_asignatura | NUMBER(10,0) | Dato FK del origen | No | = `trx_resultado_periodo.id_asignatura` |
| id_periodo | NUMBER(10,0) | Dato FK del origen | No | = `trx_resultado_periodo.id_periodo` |
| id_calificacion_seleccionada | NUMBER(10,0) | Dato FK del origen | No | = `trx_resultado_periodo.id_calificacion_seleccionada` |
| version | NUMBER(10,0) | — | No | = `trx_resultado_periodo.version` |
| criterio | VARCHAR2(30 CHAR) | — | No | = `trx_resultado_periodo.criterio` |
| fecha_seleccion | TIMESTAMP(6) | — | No | = `trx_resultado_periodo.fecha_seleccion` |
| fecha_cierre | TIMESTAMP(6) | — | Sí | = `trx_resultado_periodo.fecha_cierre` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_SESIONES

Origen: `trx_sesion_clase s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_sesion | NUMBER(10,0) | Dato PK del origen | No | = `trx_sesion_clase.id_sesion` |
| id_ponderacion_periodo | NUMBER(10,0) | Dato FK del origen | No | = `trx_sesion_clase.id_ponderacion_periodo` |
| id_asignacion | NUMBER(10,0) | Dato FK del origen | No | = `trx_sesion_clase.id_asignacion` |
| fecha_academica | DATE | — | No | = `trx_sesion_clase.fecha_academica` |
| inicio | TIMESTAMP(6) | — | No | = `trx_sesion_clase.inicio` |
| fin | TIMESTAMP(6) | — | No | = `trx_sesion_clase.fin` |
| estado | VARCHAR2(30 CHAR) | — | No | = `trx_sesion_clase.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_ASIGNACIONES_DOCENTES

Origen: `trx_asignacion_docente s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_asignacion | NUMBER(10,0) | Dato PK del origen | No | = `trx_asignacion_docente.id_asignacion` |
| id_docente | NUMBER(10,0) | Dato FK del origen | No | = `trx_asignacion_docente.id_docente` |
| id_curso_asignatura | NUMBER(10,0) | Dato FK del origen | No | = `trx_asignacion_docente.id_curso_asignatura` |
| fecha_asignacion | TIMESTAMP(6) | — | No | = `trx_asignacion_docente.fecha_asignacion` |
| fecha_inicio | DATE | — | No | = `trx_asignacion_docente.fecha_inicio` |
| fecha_fin | DATE | — | Sí | = `trx_asignacion_docente.fecha_fin` |
| estado | VARCHAR2(30 CHAR) | — | No | = `trx_asignacion_docente.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_INSTITUCIONES

Origen: `mae_institucion s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_institucion | NUMBER(10,0) | Dato PK del origen | No | = `mae_institucion.id_institucion` |
| codigo_institucion | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `mae_institucion.codigo_institucion` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `mae_institucion.nombre` |
| id_tipo_institucion | NUMBER(10,0) | Dato FK del origen | No | = `mae_institucion.id_tipo_institucion` |
| id_departamento | NUMBER(10,0) | Dato FK del origen | No | = `mae_institucion.id_departamento` |
| id_zona | NUMBER(10,0) | Dato FK del origen | No | = `mae_institucion.id_zona` |
| permite_becas | NUMBER(1) | — | No | = `mae_institucion.permite_becas` |
| fecha_creacion | DATE | — | No | = `mae_institucion.fecha_creacion` |
| activo | NUMBER(1) | — | No | = `mae_institucion.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_INSTITUCIONES_CICLO

Origen: `est_institucion_ciclo s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_institucion | NUMBER(10,0) | Dato PK,FK del origen | No | = `est_institucion_ciclo.id_institucion` |
| id_ciclo | NUMBER(10,0) | Dato PK,FK del origen | No | = `est_institucion_ciclo.id_ciclo` |
| id_tipo_institucion | NUMBER(10,0) | Dato FK del origen | No | = `est_institucion_ciclo.id_tipo_institucion` |
| id_departamento | NUMBER(10,0) | Dato FK del origen | No | = `est_institucion_ciclo.id_departamento` |
| id_zona | NUMBER(10,0) | Dato FK del origen | No | = `est_institucion_ciclo.id_zona` |
| permite_becas | NUMBER(1) | — | No | = `est_institucion_ciclo.permite_becas` |
| fecha_corte_matricula | DATE | — | No | = `est_institucion_ciclo.fecha_corte_matricula` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_institucion_ciclo.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_GRADOS

Origen: `cat_grado s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_grado | NUMBER(10,0) | Dato PK del origen | No | = `cat_grado.id_grado` |
| id_nivel | NUMBER(10,0) | Dato FK del origen | No | = `cat_grado.id_nivel` |
| codigo | VARCHAR2(50 CHAR) | — | No | = `cat_grado.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `cat_grado.nombre` |
| orden | NUMBER(10,0) | — | No | = `cat_grado.orden` |
| es_ultimo_grado | NUMBER(1) | — | No | = `cat_grado.es_ultimo_grado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_NIVELES

Origen: `cat_nivel s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_nivel | NUMBER(10,0) | Dato PK del origen | No | = `cat_nivel.id_nivel` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_nivel.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `cat_nivel.nombre` |
| orden | NUMBER(10,0) | — | No | = `cat_nivel.orden` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_BECAS

Origen: `trx_beca s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_beca | NUMBER(10,0) | Dato PK del origen | No | = `trx_beca.id_beca` |
| id_inscripcion | NUMBER(10,0) | Dato FK del origen | No | = `trx_beca.id_inscripcion` |
| id_tipo_beca | NUMBER(10,0) | Dato FK del origen | No | = `trx_beca.id_tipo_beca` |
| porcentaje | NUMBER(7,4) | — | No | = `trx_beca.porcentaje` |
| fecha_otorgamiento | DATE | — | No | = `trx_beca.fecha_otorgamiento` |
| fecha_registro | TIMESTAMP(6) | — | No | = `trx_beca.fecha_registro` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_BECAS_VIGENCIA

Origen: `trx_beca_vigencia s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_vigencia | NUMBER(10,0) | Dato PK del origen | No | = `trx_beca_vigencia.id_vigencia` |
| id_beca | NUMBER(10,0) | Dato FK del origen | No | = `trx_beca_vigencia.id_beca` |
| fecha_inicio | DATE | — | No | = `trx_beca_vigencia.fecha_inicio` |
| fecha_fin | DATE | — | Sí | = `trx_beca_vigencia.fecha_fin` |
| motivo_fin | VARCHAR2(30 CHAR) | — | Sí | = `trx_beca_vigencia.motivo_fin` |
| fecha_registro | TIMESTAMP(6) | — | No | = `trx_beca_vigencia.fecha_registro` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_PLAZOS_NOTAS

Origen: `est_plazo_registro_notas s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_plazo_registro_notas | NUMBER(10,0) | Dato PK del origen | No | = `est_plazo_registro_notas.id_plazo_registro_notas` |
| id_institucion | NUMBER(10,0) | Dato FK del origen | No | = `est_plazo_registro_notas.id_institucion` |
| id_ciclo | NUMBER(10,0) | Dato FK del origen | No | = `est_plazo_registro_notas.id_ciclo` |
| id_grado | NUMBER(10,0) | Dato FK del origen | No | = `est_plazo_registro_notas.id_grado` |
| id_periodo | NUMBER(10,0) | Dato FK del origen | No | = `est_plazo_registro_notas.id_periodo` |
| tipo_intento | VARCHAR2(30 CHAR) | — | No | = `est_plazo_registro_notas.tipo_intento` |
| fecha_inicio_recuperacion | DATE | — | Sí | = `est_plazo_registro_notas.fecha_inicio_recuperacion` |
| fecha_fin_recuperacion | DATE | — | Sí | = `est_plazo_registro_notas.fecha_fin_recuperacion` |
| fecha_apertura_registro | TIMESTAMP(6) | — | No | = `est_plazo_registro_notas.fecha_apertura_registro` |
| fecha_limite_registro | TIMESTAMP(6) | — | No | = `est_plazo_registro_notas.fecha_limite_registro` |
| fecha_cierre_registro | TIMESTAMP(6) | — | Sí | = `est_plazo_registro_notas.fecha_cierre_registro` |
| estado | VARCHAR2(30 CHAR) | — | No | = `est_plazo_registro_notas.estado` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_CONTROL_CARGA

Origen: `trx_control_carga s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_control | NUMBER(10,0) | Dato PK del origen | No | = `trx_control_carga.id_control` |
| id_curso | NUMBER(10,0) | Dato FK del origen | No | = `trx_control_carga.id_curso` |
| id_periodo | NUMBER(10,0) | Dato FK del origen | No | = `trx_control_carga.id_periodo` |
| dominio | VARCHAR2(30 CHAR) | — | No | = `trx_control_carga.dominio` |
| fecha_corte | DATE | — | No | = `trx_control_carga.fecha_corte` |
| estado | VARCHAR2(30 CHAR) | — | No | = `trx_control_carga.estado` |
| registros_declarados | NUMBER(10,0) | — | No | = `trx_control_carga.registros_declarados` |
| fecha_recepcion | TIMESTAMP(6) | — | No | = `trx_control_carga.fecha_recepcion` |
| id_ejecucion | NUMBER(10,0) | Dato FK del origen | No | = `trx_control_carga.id_ejecucion` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_ASIGNATURAS

Origen: `mae_asignatura s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_asignatura | NUMBER(10,0) | Dato PK del origen | No | = `mae_asignatura.id_asignatura` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `mae_asignatura.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `mae_asignatura.nombre` |
| id_area | NUMBER(10,0) | Dato FK del origen | No | = `mae_asignatura.id_area` |
| descripcion | VARCHAR2(500 CHAR) | — | Sí | = `mae_asignatura.descripcion` |
| activo | NUMBER(1) | — | No | = `mae_asignatura.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_DEPARTAMENTOS

Origen: `cat_departamento s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_departamento | NUMBER(10,0) | Dato PK del origen | No | = `cat_departamento.id_departamento` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_departamento.codigo` |
| nombre | VARCHAR2(150 CHAR) | — | No | = `cat_departamento.nombre` |
| activo | NUMBER(1) | — | No | = `cat_departamento.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_TIPOS_BECA

Origen: `cat_tipo_beca s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_tipo_beca | NUMBER(10,0) | Dato PK del origen | No | = `cat_tipo_beca.id_tipo_beca` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_tipo_beca.codigo` |
| descripcion | VARCHAR2(500 CHAR) | — | No | = `cat_tipo_beca.descripcion` |
| activo | NUMBER(1) | — | No | = `cat_tipo_beca.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_TIPOS_INSTITUCION

Origen: `cat_tipo_institucion s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_tipo_institucion | NUMBER(10,0) | Dato PK del origen | No | = `cat_tipo_institucion.id_tipo_institucion` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_tipo_institucion.codigo` |
| descripcion | VARCHAR2(500 CHAR) | — | No | = `cat_tipo_institucion.descripcion` |
| activo | NUMBER(1) | — | No | = `cat_tipo_institucion.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_JORNADAS

Origen: `cat_jornada s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_jornada | NUMBER(10,0) | Dato PK del origen | No | = `cat_jornada.id_jornada` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_jornada.codigo` |
| descripcion | VARCHAR2(500 CHAR) | — | No | = `cat_jornada.descripcion` |
| activo | NUMBER(1) | — | No | = `cat_jornada.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_MODALIDADES

Origen: `cat_modalidad s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_modalidad | NUMBER(10,0) | Dato PK del origen | No | = `cat_modalidad.id_modalidad` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_modalidad.codigo` |
| descripcion | VARCHAR2(500 CHAR) | — | No | = `cat_modalidad.descripcion` |
| activo | NUMBER(1) | — | No | = `cat_modalidad.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_DOCENTES

Origen: `mae_docente s JOIN mae_persona p ON p.id_persona = s.id_persona`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_docente | NUMBER(10,0) | Dato PK del origen | No | = `mae_docente.id_docente` |
| id_persona | NUMBER(10,0) | Dato FK,UK del origen | No | = `mae_docente.id_persona` |
| especialidad | VARCHAR2(250 CHAR) | — | Sí | = `mae_docente.especialidad` |
| fecha_registro_docente | TIMESTAMP(6) | — | No | Renombrado de `mae_docente.fecha_registro`. |
| docente_activo | NUMBER(1) | — | No | Renombrado de `mae_docente.activo`. |
| primer_nombre | VARCHAR2(100 CHAR) | — | No | = `mae_persona.primer_nombre` |
| segundo_nombre | VARCHAR2(100 CHAR) | — | Sí | = `mae_persona.segundo_nombre` |
| primer_apellido | VARCHAR2(100 CHAR) | — | No | = `mae_persona.primer_apellido` |
| segundo_apellido | VARCHAR2(100 CHAR) | — | Sí | = `mae_persona.segundo_apellido` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_ZONAS

Origen: `cat_zona s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_zona | NUMBER(10,0) | Dato PK del origen | No | = `cat_zona.id_zona` |
| nombre | VARCHAR2(150 CHAR) | Dato UK del origen | No | = `cat_zona.nombre` |
| activo | NUMBER(1) | — | No | = `cat_zona.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

### STG_AREAS_CONOCIMIENTO

Origen: `cat_area_conocimiento s`.

| Campo | Tipo Oracle | Clave | Admite NULL | Descripción |
|---|---|---|---|---|
| id_area | NUMBER(10,0) | Dato PK del origen | No | = `cat_area_conocimiento.id_area` |
| codigo | VARCHAR2(50 CHAR) | Dato UK del origen | No | = `cat_area_conocimiento.codigo` |
| descripcion | VARCHAR2(500 CHAR) | — | No | = `cat_area_conocimiento.descripcion` |
| activo | NUMBER(1) | — | No | = `cat_area_conocimiento.activo` |
| id_ejecucion_carga | NUMBER(10,0) | FK técnica | No | Ejecución que hizo la copia. |
| fecha_carga | TIMESTAMP(6) | — | No | Momento de la copia. |

## Validación

Las reglas están en `Pruebas/datos/reglas_validacion.json`; el resumen de las reglas de negocio, en `Validacion/Reglas_principales.md`. Las ejecutan `pr_cargar_staging` (`Validacion/07_CARGADOR_STAGING.sql`) y `VALIDAR_MODELOS.sql`. Solo bloquean las BLOQUEO; una infracción revierte toda la copia y queda registrada en la auditoría.

De `mae_persona` solo se copia lo necesario para cada rol: fecha de nacimiento y sexo del estudiante, nombres y apellidos del docente. Documento y contacto no se copian.
