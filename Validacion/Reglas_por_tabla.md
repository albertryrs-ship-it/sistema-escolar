# Reglas por tabla

Generado por `Pruebas/scripts/generar_reglas_por_tabla.py` desde `General/modelo_logico.json`, `General/SCRIPT_BASE.sql` y los archivos de `Validacion/` (reglas en `09_CATALOGO_REGLAS.sql`, CHECK en `02_RESTRICCIONES.sql`, triggers en `04_TRIGGERS_OLTP.sql` y `07_CARGADOR_STAGING.sql`).

Este documento enumera, tabla por tabla, cada regla que protege los datos y el mecanismo que la hace cumplir. Las reglas con nombre del diccionario se indican en la columna **Diccionario**. El resumen de las reglas de negocio más importantes está en `Reglas_principales.md`.

Las **reglas espejo** repiten en `val_regla` una restricción del DDL para poder diagnosticar datos existentes; aquí solo se cuentan. Se nombran `CAPA_TABLA_TIPO[_columnas]`, con TIPO `NN` (obligatorio), `CK` (dominio o rango), `PK` (clave primaria, sin columnas), `UK` (clave única), `FK` (referencia), `TEXTO` (texto no vacío) o `METADATOS` (ejecución de carga); en `UK` y `FK` las columnas van sin el prefijo `id_`. Por ejemplo, `OPERACION_TRX_BECA_NN_porcentaje` u `OPERACION_TRX_INSCRIPCION_FK_curso`. Toda tabla admite además `PR_GUARDAR_REGISTRO` (entrada por JSON que valida tipos, precisión y claves antes del DML).

## Mecanismos

| Mecanismo | Dónde se define | Cuándo actúa | Qué pasa si falla |
|---|---|---|---|
| Estructura: NOT NULL, PK, UK, FK, CHECK | DDL del OLTP (`General/SCRIPT_BASE.sql` como referencia) | En cada fila, por Oracle | Error ORA- y la sentencia se revierte. |
| CHECK adicional `ck_*_no_vacio` y otros | `02_RESTRICCIONES.sql`, `ENABLE VALIDATE` | En cada fila; al instalar también revisa los datos existentes | Error ORA-02290. Si los datos existentes no cumplen, la instalación se detiene. |
| Trigger por fila `trg_val_<tabla>` (BEFORE EACH ROW) | `04_TRIGGERS_OLTP.sql` | Antes de cada INSERT/UPDATE/DELETE | Error -20805. |
| Validación por sentencia `pr_validar_operacion` (AFTER STATEMENT del mismo trigger) | `val_regla`, severidad BLOQUEO, capa OPERACION; alcance en `val_regla_tabla` y `val_regla_ddl` | Al terminar cada sentencia DML; revisa las reglas BLOQUEO que leen la tabla modificada y omite las reglas espejo que una restricción habilitada del DDL ya garantiza. `PR_RECALCULAR_ALCANCE` calcula ese alcance al instalar y debe repetirse si cambia el DDL | Error -20802 con el ID de la regla; la sentencia se revierte. La instalación, el cargador y `pr_probar_validaciones` revisan todas las reglas. |
| Auditoría de cambios (AFTER EACH ROW) | `val_cambio` | Si `val_politica.auditar_cambios = 1` (por defecto) | Guarda antes/después en JSON; no bloquea. |
| Diagnóstico | `val_regla` (todas las severidades) | Al ejecutar `EXEC pr_diagnosticar_validaciones[('STAGING')]` | Registra la cantidad en `val_incidencia`; las abiertas se ven en `VW_AVISOS_CALIDAD`. PENDIENTE y AVISO solo se informan aquí. |
| Procedimientos `PR_*` | `06_OPERACIONES.sql` | Al usar la operación correspondiente (traslado, cierre, anulación…) | Error -208xx con el motivo; la operación se revierte. |
| Cargador `pr_cargar_staging` | `07_CARGADOR_STAGING.sql` | Al cargar staging | Revisa una por una las reglas marcadas “(revisión individual)” y guarda una fila de ejemplo en `errores_etl_evaluaciones`; al final ejecuta `pr_validar_operacion('STAGING')`, que cubre todas las BLOQUEO de staging. Cualquier fallo revierte la copia y deja la ejecución en ERROR. |
| Trigger de staging `trg_stg_<tabla>_inmutable` | `07_CARGADOR_STAGING.sql` | Antes de cada fila STG | Las STG son inmutables: no se actualizan ni borran, y solo se insertan con una ejecución EN_PROCESO compatible. |

La columna **Cómo se aplica** usa: *Trigger (fin de sentencia)* = validación global en OLTP; *+ cargador* = además se revisa al cargar staging; *Cargador (revisión individual)* = el cargador la revisa una por una y guarda una fila de ejemplo si falla; *Cargador (validación final)* = la cubre `pr_validar_operacion('STAGING')` al terminar la copia; *Diagnóstico* = solo se informa.

## Resumen

| Capa | BLOQUEO | PENDIENTE | AVISO | Total |
|---|---:|---:|---:|---:|
| Operacion | 460 | 2 | 2 | 464 |
| Staging | 445 | 2 | 2 | 449 |
| Total | 905 | 4 | 4 | 913 |

Además: 44 CHECK adicionales, 31 triggers OLTP, 29 triggers de staging. `auditoria_etl_evaluaciones` y `errores_etl_evaluaciones` no tienen trigger propio en las validaciones; sus reglas se aplican con la validación global y el diagnóstico.

---

## cat_tipo_documento

Tipos de documento personal. Sin copia en staging.

**Estructura (DDL)**

- PK: (id_tipo_documento).
- UK: (codigo).
- NOT NULL: `id_tipo_documento`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_tipo_documento_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_tipo_documento_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_TIPO_DOCUMENTO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

---

## cat_tipo_institucion

Clasificacion institucional. Copia en staging: `STG_TIPOS_INSTITUCION`.

**Estructura (DDL)**

- PK: (id_tipo_institucion).
- UK: (codigo).
- NOT NULL: `id_tipo_institucion`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_tipo_institucion_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_tipo_institucion_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_TIPO_INSTITUCION`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_TIPOS_INSTITUCION`** (trigger `TRG_STG_TIPOS_INSTITUCION_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_departamento

Departamentos. Copia en staging: `STG_DEPARTAMENTOS`.

**Estructura (DDL)**

- PK: (id_departamento).
- UK: (codigo).
- NOT NULL: `id_departamento`, `codigo`, `nombre`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_departamento_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_departamento_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`

**Trigger `TRG_VAL_CAT_DEPARTAMENTO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_DEPARTAMENTOS`** (trigger `TRG_STG_DEPARTAMENTOS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_zona

Zona urbana o rural del centro. Copia en staging: `STG_ZONAS`.

**Estructura (DDL)**

- PK: (id_zona).
- UK: (nombre).
- NOT NULL: `id_zona`, `nombre`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_zona_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`

**Trigger `TRG_VAL_CAT_ZONA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `nombre`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 3, dominio/rango 1, claves únicas 2, texto no vacío 1.

**Staging `STG_ZONAS`** (trigger `TRG_STG_ZONAS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 3, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 1.

---

## cat_modalidad

Presencial, en linea o semipresencial. Copia en staging: `STG_MODALIDADES`.

**Estructura (DDL)**

- PK: (id_modalidad).
- UK: (codigo).
- NOT NULL: `id_modalidad`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_modalidad_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_modalidad_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_MODALIDAD`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_MODALIDADES`** (trigger `TRG_STG_MODALIDADES_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_jornada

Matutina, vespertina, nocturna u otra acordada. Copia en staging: `STG_JORNADAS`.

**Estructura (DDL)**

- PK: (id_jornada).
- UK: (codigo).
- NOT NULL: `id_jornada`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_jornada_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_jornada_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_JORNADA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_JORNADAS`** (trigger `TRG_STG_JORNADAS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_area_conocimiento

Areas de conocimiento. Copia en staging: `STG_AREAS_CONOCIMIENTO`.

**Estructura (DDL)**

- PK: (id_area).
- UK: (codigo).
- NOT NULL: `id_area`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_area_conocimiento_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_area_conocimiento_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_AREA_CONOCIMIENTO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_AREAS_CONOCIMIENTO`** (trigger `TRG_STG_AREAS_CONOCIMIENTO_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_tipo_beca

Tipo y motivo de beca. Copia en staging: `STG_TIPOS_BECA`.

**Estructura (DDL)**

- PK: (id_tipo_beca).
- UK: (codigo).
- NOT NULL: `id_tipo_beca`, `codigo`, `descripcion`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_tipo_beca_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_tipo_beca_descripcion_no_vacio`: `TRIM(descripcion) IS NOT NULL`

**Trigger `TRG_VAL_CAT_TIPO_BECA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, texto no vacío 2.

**Staging `STG_TIPOS_BECA`** (trigger `TRG_STG_TIPOS_BECA_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_nivel

Nivel educativo. Copia en staging: `STG_NIVELES`.

**Estructura (DDL)**

- PK: (id_nivel).
- UK: (codigo).
- NOT NULL: `id_nivel`, `codigo`, `nombre`, `orden`.

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_nivel_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_nivel_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`
- `ck_nivel_orden_positivo`: `orden>0`

**Trigger `TRG_VAL_CAT_NIVEL`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, claves únicas 2, texto no vacío 2.

**Staging `STG_NIVELES`** (trigger `TRG_STG_NIVELES_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## cat_grado

Grado perteneciente a un nivel. Copia en staging: `STG_GRADOS`.

**Estructura (DDL)**

- PK: (id_grado).
- UK: (id_nivel, codigo).
- FK: (id_nivel) → `cat_nivel`.
- NOT NULL: `id_grado`, `id_nivel`, `codigo`, `nombre`, `orden`, `es_ultimo_grado`.
- CHECK: `es_ultimo_grado IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_grado_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_grado_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`
- `ck_grado_orden_positivo`: `orden>0`

**Trigger `TRG_VAL_CAT_GRADO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`. `es_ultimo_grado` no cambia si el grado ya tiene inscripciones con `resultado_cierre`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 6, dominio/rango 1, claves únicas 2, referencias 1, texto no vacío 2.

**Staging `STG_GRADOS`** (trigger `TRG_STG_GRADOS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 6, dominio/rango 1, claves únicas 2, referencias 1, ejecución de carga 1, texto no vacío 2.

---

## mae_institucion

Identidad estable y configuracion actual del centro. Copia en staging: `STG_INSTITUCIONES`.

**Estructura (DDL)**

- PK: (id_institucion).
- UK: (codigo_institucion).
- FK: (id_tipo_institucion) → `cat_tipo_institucion`.
- FK: (id_departamento) → `cat_departamento`.
- FK: (id_zona) → `cat_zona`.
- NOT NULL: `id_institucion`, `codigo_institucion`, `nombre`, `id_tipo_institucion`, `id_departamento`, `id_zona`, `permite_becas`, `direccion`, `fecha_creacion`, `activo`.
- CHECK: `permite_becas IN (0,1)`
- CHECK: `fecha_creacion = TRUNC(fecha_creacion)`
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_institucion_codigo_institucion_no_vacio`: `TRIM(codigo_institucion) IS NOT NULL`
- `ck_institucion_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`
- `ck_institucion_direccion_no_vacio`: `TRIM(direccion) IS NOT NULL`

**Trigger `TRG_VAL_MAE_INSTITUCION`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo_institucion`, `nombre`, `direccion`, `telefono`, `email`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 10, dominio/rango 3, claves únicas 2, referencias 3, texto no vacío 3.

**Staging `STG_INSTITUCIONES`** (trigger `TRG_STG_INSTITUCIONES_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 9, dominio/rango 3, claves únicas 2, referencias 3, ejecución de carga 1, texto no vacío 2.

---

## mae_persona

Identidad y datos personales compartidos por estudiantes y docentes. Sin copia en staging.

**Estructura (DDL)**

- PK: (id_persona).
- UK: (id_tipo_documento, numero_documento).
- FK: (id_tipo_documento) → `cat_tipo_documento`.
- NOT NULL: `id_persona`, `primer_nombre`, `primer_apellido`, `fecha_nacimiento`, `fecha_registro`.
- CHECK: `fecha_nacimiento = TRUNC(fecha_nacimiento)`
- CHECK: `sexo IN ('M','F','OTRO')`
- CHECK: `(id_tipo_documento IS NULL AND numero_documento IS NULL) OR (id_tipo_documento IS NOT NULL AND numero_documento IS NOT NULL)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_persona_primer_nombre_no_vacio`: `TRIM(primer_nombre) IS NOT NULL`
- `ck_persona_primer_apellido_no_vacio`: `TRIM(primer_apellido) IS NOT NULL`

**Trigger `TRG_VAL_MAE_PERSONA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `numero_documento`, `primer_nombre`, `segundo_nombre`, `primer_apellido`, `segundo_apellido`, `email`, `telefono`, `direccion`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `MAE_PERSONA_BC_DOCUMENTO_COMPLETO_O_AUSENTE` | BLOQUEO | Tipo y número de documento se informan juntos; ambos NULL están permitidos en distintas personas y la pareja informada es única. | DOCUMENTO_COMPLETO_O_AUSENTE | Trigger (fin de sentencia) + cargador |
| `NACIMIENTO_FUTURO` | BLOQUEO | Nacimiento no futuro. | fecha_nacimiento no futura | Trigger (fin de sentencia) |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 5, dominio/rango 2, claves únicas 2, referencias 1, texto no vacío 2.

---

## mae_estudiante

Rol de estudiante vinculado a una identidad personal compartida. Copia en staging: `STG_ESTUDIANTES`.

**Estructura (DDL)**

- PK: (id_estudiante).
- UK: (id_persona); (nie).
- FK: (id_persona) → `mae_persona`.
- NOT NULL: `id_estudiante`, `id_persona`, `nie`, `fecha_registro`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_estudiante_nie_no_vacio`: `TRIM(nie) IS NOT NULL`

**Trigger `TRG_VAL_MAE_ESTUDIANTE`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `nie`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 5, dominio/rango 1, claves únicas 3, referencias 1, texto no vacío 1.

**Staging `STG_ESTUDIANTES`** (trigger `TRG_STG_ESTUDIANTES_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 5, dominio/rango 1, claves únicas 3, referencias 1, persona obligatoria 1, dominio de persona 2, ejecución de carga 1, texto no vacío 1.

---

## mae_docente

Rol de docente vinculado a una identidad personal compartida. Copia en staging: `STG_DOCENTES`.

**Estructura (DDL)**

- PK: (id_docente).
- UK: (id_persona).
- FK: (id_persona) → `mae_persona`.
- NOT NULL: `id_docente`, `id_persona`, `fecha_registro`, `activo`.
- CHECK: `activo IN (0,1)`

**Trigger `TRG_VAL_MAE_DOCENTE`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `especialidad`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 1, claves únicas 2, referencias 1.

**Staging `STG_DOCENTES`** (trigger `TRG_STG_DOCENTES_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 1, claves únicas 2, referencias 1, persona obligatoria 2, ejecución de carga 1, texto no vacío 2.

---

## mae_asignatura

Identidad de la materia; sin horas ni creditos dependientes del grupo. Copia en staging: `STG_ASIGNATURAS`.

**Estructura (DDL)**

- PK: (id_asignatura).
- UK: (codigo).
- FK: (id_area) → `cat_area_conocimiento`.
- NOT NULL: `id_asignatura`, `codigo`, `nombre`, `id_area`, `activo`.
- CHECK: `activo IN (0,1)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_asignatura_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_asignatura_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`

**Trigger `TRG_VAL_MAE_ASIGNATURA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`, `descripcion`.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 5, dominio/rango 1, claves únicas 2, referencias 1, texto no vacío 2.

**Staging `STG_ASIGNATURAS`** (trigger `TRG_STG_ASIGNATURAS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 5, dominio/rango 1, claves únicas 2, referencias 1, ejecución de carga 1, texto no vacío 2.

---

## est_ciclo

Calendario académico: año escolar con su propia cantidad de períodos. Copia en staging: `STG_CICLOS`.

**Estructura (DDL)**

- PK: (id_ciclo).
- UK: (codigo).
- NOT NULL: `id_ciclo`, `codigo`, `nombre`, `anio`, `fecha_inicio`, `fecha_fin`, `estado`.
- CHECK: `fecha_inicio = TRUNC(fecha_inicio)`
- CHECK: `fecha_fin = TRUNC(fecha_fin)`
- CHECK: `estado IN ('PLANIFICADO','ABIERTO','CERRADO')`
- CHECK: `fecha_fin IS NULL OR fecha_fin >= fecha_inicio`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_ciclo_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_ciclo_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`

**Trigger `TRG_VAL_EST_CICLO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`. Pasar a CERRADO o salir de CERRADO solo con `PR_CERRAR_CICLO` / `PR_REABRIR_CICLO`, que registran el motivo en `val_cambio` en la misma transacción.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `CICLO_ANIO_INICIO` | AVISO | El año de referencia es el año de inicio del ciclo, aunque cruce años calendario. | CICLO_ANIO_INICIO | Diagnóstico (aviso): no bloquea |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 7, dominio/rango 3, claves únicas 2, texto no vacío 2.

**Procedimientos**

- `PR_CERRAR_CICLO`: cierra solo si el ciclo terminó y no hay notas ni asistencias pendientes.
- `PR_REABRIR_CICLO`: reabre un ciclo cerrado con motivo auditado.

**Staging `STG_CICLOS`** (trigger `TRG_STG_CICLOS_INMUTABLE`)

- Reglas de negocio: `CICLO_ANIO_INICIO` (AVISO, diagnóstico (aviso): no bloquea).
- Reglas espejo (BLOQUEO, cargador): obligatorios 7, dominio/rango 3, claves únicas 2, ejecución de carga 1, texto no vacío 2.

---

## est_periodo_academico

Periodos de evaluacion dentro de un ciclo. Copia en staging: `STG_PERIODOS`.

**Estructura (DDL)**

- PK: (id_periodo).
- UK: (id_ciclo, numero).
- FK: (id_ciclo) → `est_ciclo`.
- NOT NULL: `id_periodo`, `id_ciclo`, `numero`, `nombre`, `fecha_inicio`, `fecha_fin`.
- CHECK: `fecha_inicio = TRUNC(fecha_inicio)`
- CHECK: `fecha_fin = TRUNC(fecha_fin)`
- CHECK: `fecha_fin IS NULL OR fecha_fin >= fecha_inicio`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_periodo_academico_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`
- `ck_periodo_academico_numero_positivo`: `numero>=1`

**Trigger `TRG_VAL_EST_PERIODO_ACADEMICO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `nombre`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `PERIODO_CICLO` | BLOQUEO | Períodos configurables positivos, contenidos en su ciclo, sin duración fija. | PERIODOS_EN_CICLO_SIN_SOLAPAR, CICLO_CON_PERIODOS_PROPIOS | Trigger (fin de sentencia) + cargador |
| `PERIODOS_SOLAPADOS` | BLOQUEO | No solapar períodos del mismo ciclo. | PERIODOS_EN_CICLO_SIN_SOLAPAR | Trigger (fin de sentencia) + cargador |
| `PERIODOS_CONSECUTIVOS` | AVISO | Períodos numerados 1..N sin huecos y en el orden de sus fechas; un hueco puede indicar un período no cargado. | PERIODOS_CONSECUTIVOS | Diagnóstico (aviso): no bloquea |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 6, dominio/rango 2, claves únicas 2, referencias 1, texto no vacío 1.

**Staging `STG_PERIODOS`** (trigger `TRG_STG_PERIODOS_INMUTABLE`)

- Reglas de negocio: `PERIODO_CICLO` (BLOQUEO, cargador (revisión individual)); `PERIODOS_SOLAPADOS` (BLOQUEO, cargador (revisión individual)); `PERIODOS_CONSECUTIVOS` (AVISO, diagnóstico (aviso): no bloquea).
- Reglas espejo (BLOQUEO, cargador): obligatorios 6, dominio/rango 2, claves únicas 2, referencias 1, ejecución de carga 1, texto no vacío 1.

---

## est_institucion_ciclo

Contexto institucional congelado para el ciclo. Copia en staging: `STG_INSTITUCIONES_CICLO`.

**Estructura (DDL)**

- PK: (id_institucion, id_ciclo).
- FK: (id_institucion) → `mae_institucion`.
- FK: (id_ciclo) → `est_ciclo`.
- FK: (id_tipo_institucion) → `cat_tipo_institucion`.
- FK: (id_departamento) → `cat_departamento`.
- FK: (id_zona) → `cat_zona`.
- NOT NULL: `id_institucion`, `id_ciclo`, `id_tipo_institucion`, `id_departamento`, `id_zona`, `permite_becas`, `fecha_corte_matricula`, `estado`.
- CHECK: `permite_becas IN (0,1)`
- CHECK: `fecha_corte_matricula = TRUNC(fecha_corte_matricula)`
- CHECK: `estado IN ('PLANIFICADO','ABIERTO','CERRADO')`

**Trigger `TRG_VAL_EST_INSTITUCION_CICLO`**: La clave primaria no se renumera en un UPDATE. Pasar a CERRADO o salir de CERRADO solo con `PR_CERRAR_CICLO` / `PR_REABRIR_CICLO`, que registran el motivo en `val_cambio` en la misma transacción. Tipo, departamento, zona y `permite_becas` no cambian si el contexto ya tiene cursos.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `CORTE_EN_CICLO` | BLOQUEO | Corte de matrícula contenido en su ciclo. | fecha_corte_matricula dentro del ciclo | Trigger (fin de sentencia) |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 8, dominio/rango 3, claves únicas 1, referencias 5.

**Procedimientos**

- `PR_CERRAR_CICLO`: cierra solo si el ciclo terminó y no hay notas ni asistencias pendientes.
- `PR_REABRIR_CICLO`: reabre un ciclo cerrado con motivo auditado.

**Staging `STG_INSTITUCIONES_CICLO`** (trigger `TRG_STG_INSTITUCIONES_CICLO_INMUTABLE`)

- Reglas de negocio: `CORTE_EN_CICLO` (BLOQUEO, cargador (validación final)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 8, dominio/rango 3, claves únicas 1, referencias 5, ejecución de carga 1.

---

## est_curso

Grupo concreto de una institucion durante un ciclo. Copia en staging: `STG_CURSOS`.

**Estructura (DDL)**

- PK: (id_curso).
- UK: (id_institucion, id_ciclo, id_grado, id_jornada, seccion).
- FK: (id_institucion) → `mae_institucion`.
- FK: (id_ciclo) → `est_ciclo`.
- FK: (id_grado) → `cat_grado`.
- FK: (id_jornada) → `cat_jornada`.
- FK: (id_modalidad) → `cat_modalidad`.
- FK: (id_institucion, id_ciclo) → `est_institucion_ciclo`.
- NOT NULL: `id_curso`, `id_institucion`, `id_ciclo`, `id_grado`, `id_jornada`, `id_modalidad`, `codigo`, `nombre`, `seccion`, `capacidad_maxima`, `estado`.
- CHECK: `capacidad_maxima > 0`
- CHECK: `estado IN ('PLANIFICADO','ACTIVO','CERRADO','ANULADO')`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_curso_codigo_no_vacio`: `TRIM(codigo) IS NOT NULL`
- `ck_curso_nombre_no_vacio`: `TRIM(nombre) IS NOT NULL`
- `ck_curso_seccion_no_vacio`: `TRIM(seccion) IS NOT NULL`

**Trigger `TRG_VAL_EST_CURSO`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `codigo`, `nombre`, `seccion`. Institución, ciclo, grado, jornada y sección no cambian si el grupo tiene inscripciones; se crea otro grupo.

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 11, dominio/rango 2, claves únicas 2, referencias 6, texto no vacío 3.

**Staging `STG_CURSOS`** (trigger `TRG_STG_CURSOS_INMUTABLE`)

- Reglas espejo (BLOQUEO, cargador): obligatorios 11, dominio/rango 2, claves únicas 2, referencias 6, ejecución de carga 1, texto no vacío 3.

---

## est_curso_asignatura

Oferta de asignaturas del grupo. Copia en staging: `STG_CURSOS_ASIGNATURAS`.

**Estructura (DDL)**

- PK: (id_curso_asignatura).
- UK: (id_curso, id_asignatura).
- FK: (id_curso) → `est_curso`.
- FK: (id_asignatura) → `mae_asignatura`.
- NOT NULL: `id_curso_asignatura`, `id_curso`, `id_asignatura`, `horas_semanales`, `tipo_resultado`, `regla_recuperacion`, `estado`.
- CHECK: `horas_semanales > 0`
- CHECK: `creditos >= 0`
- CHECK: `tipo_resultado IN ('NUMERICA','CUALITATIVA')`
- CHECK: `regla_recuperacion IN ('MEJOR_NOTA','ULTIMA_RECUPERACION')`
- CHECK: `estado IN ('PLANIFICADA','ACTIVA','ANULADA')`

**Trigger `TRG_VAL_EST_CURSO_ASIGNATURA`**: La clave primaria no se renumera en un UPDATE. `tipo_resultado` y `regla_recuperacion` no cambian si la oferta tiene notas validadas.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `OFERTA_CON_PLAN` | PENDIENTE | Una oferta activa con matrícula no puede ocultar un plan anual ausente. | PLAN_COMPLETO_PUBLICADO | Diagnóstico (pendiente): no bloquea |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 7, dominio/rango 5, claves únicas 2, referencias 2.

**Staging `STG_CURSOS_ASIGNATURAS`** (trigger `TRG_STG_CURSOS_ASIGNATURAS_INMUTABLE`)

- Reglas de negocio: `OFERTA_CON_PLAN` (PENDIENTE, diagnóstico (pendiente): no bloquea).
- Reglas espejo (BLOQUEO, cargador): obligatorios 7, dominio/rango 5, claves únicas 2, referencias 2, ejecución de carga 1.

---

## est_ponderacion_periodo

Materia ofrecida, período y peso relativo de su calificación del período. Copia en staging: `STG_PONDERACIONES`.

**Estructura (DDL)**

- PK: (id_ponderacion_periodo).
- UK: (id_curso_asignatura, id_periodo).
- FK: (id_curso_asignatura) → `est_curso_asignatura`.
- FK: (id_periodo) → `est_periodo_academico`.
- NOT NULL: `id_ponderacion_periodo`, `id_curso_asignatura`, `id_periodo`, `peso`, `estado`.
- CHECK: `peso > 0`
- CHECK: `estado IN ('BORRADOR','PUBLICADO','ANULADO')`

**Trigger `TRG_VAL_EST_PONDERACION_PERIODO`**: La clave primaria no se renumera en un UPDATE. Un componente del plan con notas validadas no se modifica ni se borra.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `PLAN_CICLO` | BLOQUEO | Curso y período deben pertenecer al mismo ciclo. | Período y curso del mismo ciclo | Trigger (fin de sentencia) + cargador |
| `PLAN_COMPLETO` | BLOQUEO | Un plan publicado cubre todos los períodos configurados de su ciclo. | PLAN_COMPLETO_PUBLICADO | Trigger (fin de sentencia) + cargador |
| `PLAN_CON_PLAZO` | PENDIENTE | Todo componente publicado tiene plazo ordinario del contexto correspondiente. | COMPLETITUD_MISMAS_OBLIGACIONES (configuración incompleta) | Diagnóstico (pendiente): no bloquea |
| `PESOS_COMPARABLES` | BLOQUEO | Mismo ciclo, grado y asignatura: igual vector normalizado. | PESOS_COHERENTES_TRASLADO | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 5, dominio/rango 2, claves únicas 2, referencias 2.

**Procedimientos**

- `PR_PUBLICAR_PLAN`: publica el plan solo si tiene un peso por cada período del ciclo.

**Staging `STG_PONDERACIONES`** (trigger `TRG_STG_PONDERACIONES_INMUTABLE`)

- Reglas de negocio: `PLAN_CICLO` (BLOQUEO, cargador (revisión individual)); `PLAN_COMPLETO` (BLOQUEO, cargador (revisión individual)); `PLAN_CON_PLAZO` (PENDIENTE, diagnóstico (pendiente): no bloquea); `PESOS_COMPARABLES` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 5, dominio/rango 2, claves únicas 2, referencias 2, ejecución de carga 1.

---

## est_plazo_registro_notas

Plazo institucional de registro por grado, período y tipo de intento. Copia en staging: `STG_PLAZOS_NOTAS`.

**Estructura (DDL)**

- PK: (id_plazo_registro_notas).
- UK: (id_institucion, id_ciclo, id_grado, id_periodo, tipo_intento).
- FK: (id_institucion) → `mae_institucion`.
- FK: (id_ciclo) → `est_ciclo`.
- FK: (id_grado) → `cat_grado`.
- FK: (id_periodo) → `est_periodo_academico`.
- FK: (id_institucion, id_ciclo) → `est_institucion_ciclo`.
- NOT NULL: `id_plazo_registro_notas`, `id_institucion`, `id_ciclo`, `id_grado`, `id_periodo`, `tipo_intento`, `fecha_apertura_registro`, `fecha_limite_registro`, `estado`.
- CHECK: `tipo_intento IN ('ORDINARIA','RECUPERACION')`
- CHECK: `fecha_inicio_recuperacion = TRUNC(fecha_inicio_recuperacion)`
- CHECK: `fecha_fin_recuperacion = TRUNC(fecha_fin_recuperacion)`
- CHECK: `estado IN ('PROGRAMADA','ABIERTA','CERRADA')`
- CHECK: `fecha_apertura_registro <= fecha_limite_registro AND ((estado = 'CERRADA' AND fecha_cierre_registro IS NOT NULL AND fecha_cierre_registro >= fecha_apertura_registro) OR (estado IN ('PROGRAMADA','ABIERTA') AND fecha_cierre_registro IS NULL))`
- CHECK: `(tipo_intento='ORDINARIA' AND fecha_inicio_recuperacion IS NULL AND fecha_fin_recuperacion IS NULL) OR (tipo_intento='RECUPERACION' AND fecha_inicio_recuperacion IS NOT NULL AND fecha_fin_recuperacion IS NOT NULL AND fecha_fin_recuperacion>=fecha_inicio_recuperacion)`

**Trigger `TRG_VAL_EST_PLAZO_REGISTRO_NOTAS`**: La clave primaria no se renumera en un UPDATE. Un plazo CERRADO solo se reabre con `PR_REABRIR_PLAZO` y motivo.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `EST_PLAZO_REGISTRO_NOTAS_BC_PLAZO_CIERRE_COHERENTE` | BLOQUEO | Un plazo cerrado tiene fecha efectiva de cierre; los plazos abiertos o programados no la tienen. La apertura no supera el límite y el cierre no precede a la apertura. | PLAZO_CIERRE_COHERENTE | Trigger (fin de sentencia) + cargador |
| `PLAZO_CICLO` | BLOQUEO | El período del plazo pertenece a su ciclo. | Período del mismo ciclo que el plazo | Trigger (fin de sentencia) + cargador |
| `RECUPERACION_FECHAS` | BLOQUEO | Recuperación exige intervalo ordenado; ordinaria lo deja vacío. | INTERVALO_RECUPERACION_SEPARADO | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 9, dominio/rango 4, claves únicas 2, referencias 5.

**Procedimientos**

- `PR_REABRIR_PLAZO`: reabre un plazo cerrado con motivo auditado.

**Staging `STG_PLAZOS_NOTAS`** (trigger `TRG_STG_PLAZOS_NOTAS_INMUTABLE`)

- Reglas de negocio: `EST_PLAZO_REGISTRO_NOTAS_BC_PLAZO_CIERRE_COHERENTE` (BLOQUEO, cargador (revisión individual)); `PLAZO_CICLO` (BLOQUEO, cargador (revisión individual)); `RECUPERACION_FECHAS` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 9, dominio/rango 4, claves únicas 2, referencias 5, ejecución de carga 1.

---

## trx_asignacion_docente

Docente que ensena una asignatura del grupo durante una vigencia. Copia en staging: `STG_ASIGNACIONES_DOCENTES`.

**Estructura (DDL)**

- PK: (id_asignacion).
- FK: (id_docente) → `mae_docente`.
- FK: (id_curso_asignatura) → `est_curso_asignatura`.
- NOT NULL: `id_asignacion`, `id_docente`, `id_curso_asignatura`, `fecha_asignacion`, `fecha_inicio`, `estado`.
- CHECK: `fecha_inicio = TRUNC(fecha_inicio)`
- CHECK: `fecha_fin = TRUNC(fecha_fin)`
- CHECK: `estado IN ('PROGRAMADA','VIGENTE','FINALIZADA','ANULADA')`
- CHECK: `fecha_fin IS NULL OR fecha_fin >= fecha_inicio`

**Trigger `TRG_VAL_TRX_ASIGNACION_DOCENTE`**: La clave primaria no se renumera en un UPDATE.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `ASIGNACION_CICLO` | BLOQUEO | La responsabilidad ordinaria pertenece al ciclo de la oferta. | fecha_inicio y fecha_fin dentro del ciclo | Trigger (fin de sentencia) + cargador |
| `ASIGNACIONES_SOLAPADAS` | BLOQUEO | Un responsable por oferta y fecha. | Un responsable por oferta y fecha | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 6, dominio/rango 3, claves únicas 1, referencias 2.

**Staging `STG_ASIGNACIONES_DOCENTES`** (trigger `TRG_STG_ASIGNACIONES_DOCENTES_INMUTABLE`)

- Reglas de negocio: `ASIGNACION_CICLO` (BLOQUEO, cargador (revisión individual)); `ASIGNACIONES_SOLAPADAS` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 6, dominio/rango 3, claves únicas 1, referencias 2, ejecución de carga 1.

---

## trx_inscripcion

Pertenencia historica del estudiante al grupo. Copia en staging: `STG_INSCRIPCIONES`.

**Estructura (DDL)**

- PK: (id_inscripcion).
- UK: (id_estudiante, id_curso, fecha_inicio).
- FK: (id_estudiante) → `mae_estudiante`.
- FK: (id_curso) → `est_curso`.
- NOT NULL: `id_inscripcion`, `id_estudiante`, `id_curso`, `fecha_inscripcion`, `fecha_inicio`, `estado`.
- CHECK: `fecha_inicio = TRUNC(fecha_inicio)`
- CHECK: `fecha_fin = TRUNC(fecha_fin)`
- CHECK: `estado IN ('VIGENTE','FINALIZADA','RETIRADA','TRASLADADA','ANULADA')`
- CHECK: `resultado_cierre IN ('PROMOVIDO','REPITE','GRADUADO')`
- CHECK: `fecha_fin IS NULL OR fecha_fin >= fecha_inicio`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_inscripcion_fin_con_fecha_y_motivo`: `estado NOT IN ('FINALIZADA','RETIRADA','TRASLADADA') OR (fecha_fin IS NOT NULL AND TRIM(motivo_fin_inscripcion) IS NOT NULL)`

**Trigger `TRG_VAL_TRX_INSCRIPCION`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `motivo_fin_inscripcion`. `id_estudiante` e `id_curso` no se reasignan; el cambio de grupo se hace con `PR_TRASLADAR_ESTUDIANTE`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `INSCRIPCION_CICLO` | BLOQUEO | Pertenencia dentro del ciclo, con intervalos inclusivos. | VIGENCIA_LIMITADA_CICLO | Trigger (fin de sentencia) + cargador |
| `INSCRIPCIONES_SOLAPADAS` | BLOQUEO | No solapar matrículas ordinarias del mismo estudiante y ciclo. | VIGENCIA_LIMITADA_CICLO; sin inscripciones ordinarias solapadas | Trigger (fin de sentencia) + cargador |
| `CIERRE_INSCRIPCION` | BLOQUEO | Inscripción terminada con fecha y motivo. | CIERRE_INSCRIPCION | Trigger (fin de sentencia) |
| `CAPACIDAD_ESTRICTA` | BLOQUEO | Capacidad simultanea solo cuando se active expresamente la politica. | CAPACIDAD_ESTRICTA | Trigger (fin de sentencia), solo si `val_politica.capacidad_estricta = 1`; desactivada por defecto |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 6, dominio/rango 4, claves únicas 2, referencias 2.

**Procedimientos**

- `PR_TRASLADAR_ESTUDIANTE`: cierra la inscripción de origen y abre la de destino en el mismo ciclo; no deja notas ordinarias posteriores a la salida.

**Staging `STG_INSCRIPCIONES`** (trigger `TRG_STG_INSCRIPCIONES_INMUTABLE`)

- Reglas de negocio: `INSCRIPCION_CICLO` (BLOQUEO, cargador (revisión individual)); `INSCRIPCIONES_SOLAPADAS` (BLOQUEO, cargador (revisión individual)); `CIERRE_INSCRIPCION` (BLOQUEO, cargador (validación final)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 6, dominio/rango 4, claves únicas 2, referencias 2, ejecución de carga 1.

---

## trx_calificacion

Calificación real consolidada de un período e intento, con sus versiones. Copia en staging: `STG_CALIFICACIONES`.

**Estructura (DDL)**

- PK: (id_calificacion).
- UK: (id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version).
- FK: (id_inscripcion) → `trx_inscripcion`.
- FK: (id_ponderacion_periodo) → `est_ponderacion_periodo`.
- FK: (id_calificacion_ordinaria) → `trx_calificacion`.
- FK: (id_calificacion_sustituida) → `trx_calificacion`.
- FK: (id_asignacion_docente) → `trx_asignacion_docente`.
- FK: (id_docente_registra) → `mae_docente`.
- NOT NULL: `id_calificacion`, `id_inscripcion`, `id_ponderacion_periodo`, `tipo_intento`, `numero_intento`, `version`, `id_asignacion_docente`, `id_docente_registra`, `fecha_evaluacion`, `fecha_registro`.
- CHECK: `tipo_intento IN ('ORDINARIA','RECUPERACION')`
- CHECK: `numero_intento >= 1`
- CHECK: `version >= 1`
- CHECK: `nota BETWEEN 0 AND 100`
- CHECK: `fecha_evaluacion = TRUNC(fecha_evaluacion)`
- CHECK: `(tipo_intento = 'ORDINARIA' AND numero_intento = 1 AND id_calificacion_ordinaria IS NULL) OR (tipo_intento = 'RECUPERACION' AND numero_intento >= 2 AND id_calificacion_ordinaria IS NOT NULL)`
- CHECK: `(nota IS NOT NULL AND resultado_cualitativo IS NULL) OR (nota IS NULL AND resultado_cualitativo IS NOT NULL)`
- CHECK: `(version = 1 AND id_calificacion_sustituida IS NULL) OR (version > 1 AND id_calificacion_sustituida IS NOT NULL)`
- CHECK: `(fecha_validacion IS NULL OR fecha_validacion >= fecha_registro) AND (fecha_anulacion IS NULL OR (fecha_anulacion >= fecha_registro AND motivo_anulacion IS NOT NULL))`

**Trigger `TRG_VAL_TRX_CALIFICACION`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `resultado_cualitativo`, `motivo_anulacion`. Columnas inmutables (una corrección crea otra versión): `id_calificacion`, `id_inscripcion`, `id_ponderacion_periodo`, `tipo_intento`, `numero_intento`, `version`, `id_calificacion_ordinaria`, `id_calificacion_sustituida`, `id_asignacion_docente`, `id_docente_registra`, `nota`, `resultado_cualitativo`, `fecha_evaluacion`, `fecha_registro`. Se escriben una sola vez; después solo con nueva versión o reapertura: `fecha_validacion`, `fecha_anulacion`, `motivo_anulacion`. No se permite DELETE: se anula o se corrige con una versión nueva.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION` | BLOQUEO | La ordinaria es el intento 1 y no referencia una ordinaria de origen; las recuperaciones son intentos 2 o superiores y sí la referencian. Las correcciones mantienen el intento y aumentan la versión. | INTENTO_ORDINARIO_Y_RECUPERACION | Trigger (fin de sentencia) + cargador |
| `TRX_CALIFICACION_BC_RESULTADO_REAL_EXCLUYENTE` | BLOQUEO | Cada fila guarda exactamente un resultado real numérico o cualitativo; las notas pendientes no generan filas. | RESULTADO_REAL_EXCLUYENTE | Trigger (fin de sentencia) + cargador |
| `TRX_CALIFICACION_BC_VERSION_CON_ANTECEDENTE` | BLOQUEO | La versión 1 no tiene sustituida; una corrección posterior referencia una versión anterior del mismo intento. | VERSION_CON_ANTECEDENTE | Trigger (fin de sentencia) + cargador |
| `TRX_CALIFICACION_BC_FECHAS_CALIFICACION_ORDENADAS` | BLOQUEO | La validación y la anulación no preceden al registro; una anulación requiere motivo. | FECHAS_CALIFICACION_ORDENADAS | Trigger (fin de sentencia) + cargador |
| `CALIFICACION_CONTEXTO` | BLOQUEO | Calificación, inscripción y asignación corresponden a la misma oferta publicada. | CALIFICACION_CONTEXTO_COHERENTE | Trigger (fin de sentencia) + cargador |
| `TIPO_RESULTADO` | BLOQUEO | Resultado numérico o cualitativo coherente con la oferta. | RESULTADO_REAL_EXCLUYENTE (coherente con la oferta) | Trigger (fin de sentencia) + cargador |
| `ORDINARIA_VIGENCIA` | BLOQUEO | La fecha académica ordinaria está en período, matrícula y responsabilidad. | CALIFICACION_CONTEXTO_COHERENTE | Trigger (fin de sentencia) + cargador |
| `RECUPERACION_RESPONSABLE` | BLOQUEO | La recuperación queda a cargo de una asignación vigente en algún momento del período que recupera. | RECUPERACION_RESPONSABLE | Trigger (fin de sentencia) + cargador |
| `ORIGEN_RECUPERACION` | BLOQUEO | La recuperación referencia su ordinaria y conserva inscripción y plan. | RECUPERACION_POST_CICLO, CALIFICACION_CONTEXTO_COHERENTE | Trigger (fin de sentencia) + cargador |
| `VERSION_ANTERIOR` | BLOQUEO | La sustituida es la versión previa del mismo intento y contexto. | VERSION_CON_ANTECEDENTE, CALIFICACION_CONTEXTO_COHERENTE | Trigger (fin de sentencia) + cargador |
| `CAPTURA_AUTORIZADA` | BLOQUEO | Existe plazo compatible y la captura no precede apertura ni supera cierre real. | RECUPERACION_POST_CICLO, INTERVALO_RECUPERACION_SEPARADO | Trigger (fin de sentencia) + cargador |
| `REGISTRO_NO_ANTICIPADO` | BLOQUEO | El registro no precede al hecho académico. | FECHAS_CALIFICACION_ORDENADAS | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 10, dominio/rango 5, claves únicas 2, referencias 6.

**Procedimientos**

- `PR_ANULAR_CALIFICACION`: exige fecha y motivo y actualiza la selección; no revive versiones anteriores.
- `PR_CORREGIR_CALIFICACION`: exige motivo; agrega una versión nueva sobre la última del intento, la valida y actualiza la selección.
- `PR_REGISTRAR_CALIFICACION`: inserta la calificación; si se indica fecha de validación, la valida y actualiza la selección en la misma transacción.
- `PR_VALIDAR_CALIFICACION`: registra fecha_validacion y actualiza la selección en la misma transacción.

**Staging `STG_CALIFICACIONES`** (trigger `TRG_STG_CALIFICACIONES_INMUTABLE`)

- Reglas de negocio: `TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION` (BLOQUEO, cargador (revisión individual)); `TRX_CALIFICACION_BC_RESULTADO_REAL_EXCLUYENTE` (BLOQUEO, cargador (revisión individual)); `TRX_CALIFICACION_BC_VERSION_CON_ANTECEDENTE` (BLOQUEO, cargador (revisión individual)); `TRX_CALIFICACION_BC_FECHAS_CALIFICACION_ORDENADAS` (BLOQUEO, cargador (revisión individual)); `CALIFICACION_CONTEXTO` (BLOQUEO, cargador (revisión individual)); `TIPO_RESULTADO` (BLOQUEO, cargador (revisión individual)); `ORDINARIA_VIGENCIA` (BLOQUEO, cargador (revisión individual)); `RECUPERACION_RESPONSABLE` (BLOQUEO, cargador (revisión individual)); `ORIGEN_RECUPERACION` (BLOQUEO, cargador (revisión individual)); `VERSION_ANTERIOR` (BLOQUEO, cargador (revisión individual)); `CAPTURA_AUTORIZADA` (BLOQUEO, cargador (revisión individual)); `REGISTRO_NO_ANTICIPADO` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 10, dominio/rango 5, claves únicas 2, referencias 6, ejecución de carga 1.

---

## trx_resultado_periodo

Selección versionada de la calificación usada para el período, sin duplicar nota ni promedio. Copia en staging: `STG_RESULTADOS_PERIODO`.

**Estructura (DDL)**

- PK: (id_resultado).
- UK: (id_estudiante, id_asignatura, id_periodo, version).
- FK: (id_estudiante) → `mae_estudiante`.
- FK: (id_asignatura) → `mae_asignatura`.
- FK: (id_periodo) → `est_periodo_academico`.
- FK: (id_calificacion_seleccionada) → `trx_calificacion`.
- NOT NULL: `id_resultado`, `id_estudiante`, `id_asignatura`, `id_periodo`, `id_calificacion_seleccionada`, `version`, `criterio`, `fecha_seleccion`.
- CHECK: `version >= 1`
- CHECK: `criterio IN ('ORDINARIA','MEJOR_NOTA','ULTIMA_RECUPERACION','CORRECCION','TRASLADO')`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_resultado_periodo_cierre_tras_seleccion`: `fecha_cierre IS NULL OR fecha_cierre>=fecha_seleccion`

**Trigger `TRG_VAL_TRX_RESULTADO_PERIODO`**: La clave primaria no se renumera en un UPDATE. Columnas inmutables (una corrección crea otra versión): `id_resultado`, `id_estudiante`, `id_asignatura`, `id_periodo`, `id_calificacion_seleccionada`, `version`, `criterio`, `fecha_seleccion`. Se escriben una sola vez; después solo con nueva versión o reapertura: `fecha_cierre`. No se permite DELETE: se anula o se corrige con una versión nueva.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `RESULTADO_CORRESPONDE` | BLOQUEO | La referencia seleccionada corresponde a estudiante, materia y período. | La calificación seleccionada corresponde a estudiante, asignatura y período | Trigger (fin de sentencia) + cargador |
| `SELECCION_VERSION_VIGENTE` | BLOQUEO | Una selección usa la última versión validada de su intento en ese momento. | SELECCION_VERSION_VIGENTE, ANULACION_SIN_REVIVIR_VERSION | Trigger (fin de sentencia) + cargador |
| `SELECCION_POLITICA` | BLOQUEO | La elección respeta mejor nota o última recuperación a fecha de selección, sin anticipar eventos futuros. | SELECCION_POLITICA | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 8, dominio/rango 2, claves únicas 2, referencias 4.

**Procedimientos**

- `PR_CERRAR_CICLO`: cierra solo si el ciclo terminó y no hay notas ni asistencias pendientes.
- `PR_SELECCIONAR_RESULTADO`: crea una nueva versión de la selección con FN_ELEGIR_CALIFICACION; un resultado cerrado exige motivo.

**Staging `STG_RESULTADOS_PERIODO`** (trigger `TRG_STG_RESULTADOS_PERIODO_INMUTABLE`)

- Reglas de negocio: `RESULTADO_CORRESPONDE` (BLOQUEO, cargador (revisión individual)); `SELECCION_VERSION_VIGENTE` (BLOQUEO, cargador (revisión individual)); `SELECCION_POLITICA` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 8, dominio/rango 2, claves únicas 2, referencias 4, ejecución de carga 1.

---

## trx_sesion_clase

Una sesion de una asignatura ofrecida. Copia en staging: `STG_SESIONES`.

**Estructura (DDL)**

- PK: (id_sesion).
- UK: (id_ponderacion_periodo, inicio).
- FK: (id_ponderacion_periodo) → `est_ponderacion_periodo`.
- FK: (id_asignacion) → `trx_asignacion_docente`.
- NOT NULL: `id_sesion`, `id_ponderacion_periodo`, `id_asignacion`, `fecha_academica`, `inicio`, `fin`, `estado`.
- CHECK: `fecha_academica = TRUNC(fecha_academica)`
- CHECK: `estado IN ('PROGRAMADA','IMPARTIDA','CANCELADA')`
- CHECK: `fin > inicio`

**Trigger `TRG_VAL_TRX_SESION_CLASE`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `observaciones`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `SESION_CONTEXTO` | BLOQUEO | Sesión y responsabilidad compatibles; noche puede terminar al día siguiente. | SESION_CONTEXTO_COHERENTE | Trigger (fin de sentencia) + cargador |
| `SESIONES_SIMULTANEAS` | BLOQUEO | Un docente o grupo no recibe dos sesiones simultáneas. | Un docente o grupo sin sesiones simultáneas | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 7, dominio/rango 2, claves únicas 2, referencias 2.

**Staging `STG_SESIONES`** (trigger `TRG_STG_SESIONES_INMUTABLE`)

- Reglas de negocio: `SESION_CONTEXTO` (BLOQUEO, cargador (revisión individual)); `SESIONES_SIMULTANEAS` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 7, dominio/rango 2, claves únicas 2, referencias 2, ejecución de carga 1.

---

## trx_asistencia

Estado de asistencia del inscrito a una sesion. Copia en staging: `STG_ASISTENCIAS`.

**Estructura (DDL)**

- PK: (id_asistencia).
- UK: (id_inscripcion, id_sesion).
- FK: (id_inscripcion) → `trx_inscripcion`.
- FK: (id_sesion) → `trx_sesion_clase`.
- NOT NULL: `id_asistencia`, `id_inscripcion`, `id_sesion`, `estado`, `fecha_registro`.
- CHECK: `estado IN ('PRESENTE','TARDE','AUSENTE','JUSTIFICADA')`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_asistencia_ausente_sin_llegada`: `estado NOT IN ('AUSENTE','JUSTIFICADA') OR hora_llegada IS NULL`

**Trigger `TRG_VAL_TRX_ASISTENCIA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `observaciones`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `ASISTENCIA_CONTEXTO` | BLOQUEO | La asistencia pertenece al curso e intervalo de la sesión. | ASISTENCIA_CONTEXTO_COHERENTE, ASISTENCIA_SESION_IMPARTIDA | Trigger (fin de sentencia) + cargador |
| `ASISTENCIA_LLEGADA` | BLOQUEO | Ausencia/justificación sin hora de llegada. | ASISTENCIA_SESION_IMPARTIDA | Trigger (fin de sentencia) |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 5, dominio/rango 1, claves únicas 2, referencias 2.

**Staging `STG_ASISTENCIAS`** (trigger `TRG_STG_ASISTENCIAS_INMUTABLE`)

- Reglas de negocio: `ASISTENCIA_CONTEXTO` (BLOQUEO, cargador (revisión individual)); `ASISTENCIA_LLEGADA` (BLOQUEO, cargador (validación final)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 5, dominio/rango 1, claves únicas 2, referencias 2, ejecución de carga 1.

---

## trx_beca

Beneficio concedido a una inscripcion, separado de la politica institucional. Copia en staging: `STG_BECAS`.

**Estructura (DDL)**

- PK: (id_beca).
- FK: (id_inscripcion) → `trx_inscripcion`.
- FK: (id_tipo_beca) → `cat_tipo_beca`.
- NOT NULL: `id_beca`, `id_inscripcion`, `id_tipo_beca`, `porcentaje`, `fecha_otorgamiento`, `fecha_registro`.
- CHECK: `porcentaje > 0 AND porcentaje <= 100`
- CHECK: `fecha_otorgamiento = TRUNC(fecha_otorgamiento)`

**Trigger `TRG_VAL_TRX_BECA`**: La clave primaria no se renumera en un UPDATE. Normaliza espacios de texto antes de guardar: `observaciones`.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `BECA_HABILITADA` | BLOQUEO | El beneficio respeta la habilitación histórica del centro. | est_institucion_ciclo.permite_becas | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 6, dominio/rango 2, claves únicas 1, referencias 2.

**Procedimientos**

- `PR_OTORGAR_BECA`: registra la beca y abre su primer intervalo de vigencia.

**Staging `STG_BECAS`** (trigger `TRG_STG_BECAS_INMUTABLE`)

- Reglas de negocio: `BECA_HABILITADA` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 6, dominio/rango 2, claves únicas 1, referencias 2, ejecución de carga 1.

---

## trx_beca_vigencia

Intervalos efectivos del beneficio, incluyendo suspensiones. Copia en staging: `STG_BECAS_VIGENCIA`.

**Estructura (DDL)**

- PK: (id_vigencia).
- UK: (id_beca, fecha_inicio).
- FK: (id_beca) → `trx_beca`.
- NOT NULL: `id_vigencia`, `id_beca`, `fecha_inicio`, `fecha_registro`.
- CHECK: `fecha_inicio = TRUNC(fecha_inicio)`
- CHECK: `fecha_fin = TRUNC(fecha_fin)`
- CHECK: `motivo_fin IN ('FIN_VIGENCIA','SUSPENSION','CANCELACION','TRASLADO')`
- CHECK: `fecha_fin IS NULL OR fecha_fin >= fecha_inicio`

**Trigger `TRG_VAL_TRX_BECA_VIGENCIA`**: La clave primaria no se renumera en un UPDATE.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `BECA_VIGENCIA` | BLOQUEO | El intervalo efectivo queda dentro de matrícula y ciclo. | ESTADO_BECA_DERIVADO, MOTIVO_FIN_CON_CIERRE | Trigger (fin de sentencia) + cargador |
| `BECA_SOLAPADA` | BLOQUEO | Una beca no tiene intervalos efectivos solapados. | ESTADO_BECA_DERIVADO | Trigger (fin de sentencia) + cargador |
| `PORCENTAJE_SIMULTANEO` | BLOQUEO | Beneficios simultáneos de la misma inscripción y base no superan 100. | trx_beca.porcentaje (suma simultánea ≤ 100) | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 4, dominio/rango 3, claves únicas 2, referencias 1.

**Procedimientos**

- `PR_REANUDAR_BECA`: abre un intervalo nuevo.
- `PR_SUSPENDER_BECA`: cierra el intervalo abierto con fecha y motivo.
- `PR_TRASLADAR_ESTUDIANTE`: cierra la inscripción de origen y abre la de destino en el mismo ciclo; no deja notas ordinarias posteriores a la salida.

**Staging `STG_BECAS_VIGENCIA`** (trigger `TRG_STG_BECAS_VIGENCIA_INMUTABLE`)

- Reglas de negocio: `BECA_VIGENCIA` (BLOQUEO, cargador (revisión individual)); `BECA_SOLAPADA` (BLOQUEO, cargador (revisión individual)); `PORCENTAJE_SIMULTANEO` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 4, dominio/rango 3, claves únicas 2, referencias 1, ejecución de carga 1.

---

## auditoria_etl_evaluaciones

Ejecuciones de carga. Sin copia en staging.

**Estructura (DDL)**

- PK: (id_ejecucion).
- NOT NULL: `id_ejecucion`, `fuente`, `inicio`, `estado`, `total_leidos`, `insertados`, `actualizados`, `rechazados`.
- CHECK: `estado IN ('EN_PROCESO','COMPLETADA','ERROR')`
- CHECK: `total_leidos>=0 AND insertados>=0 AND actualizados>=0 AND rechazados>=0`
- CHECK: `estado<>'COMPLETADA' OR (fin IS NOT NULL AND fin>=inicio AND total_leidos=insertados+actualizados+rechazados)`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_auditoria_etl_fuente_no_vacio`: `TRIM(fuente) IS NOT NULL`
- `ck_auditoria_etl_estado_y_fin`: `(estado='EN_PROCESO' AND fin IS NULL) OR (estado IN ('ERROR','COMPLETADA') AND fin IS NOT NULL AND fin>=inicio)`

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `AUDITORIA_TIEMPOS` | BLOQUEO | Auditoría con fechas coherentes. | inicio y fin coherentes | Trigger (fin de sentencia) |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 8, dominio/rango 1, claves únicas 1, texto no vacío 1.

---

## errores_etl_evaluaciones

Errores y registros rechazados. Sin copia en staging.

**Estructura (DDL)**

- PK: (id_error).
- FK: (id_ejecucion) → `auditoria_etl_evaluaciones`.
- NOT NULL: `id_error`, `id_ejecucion`, `entidad`, `tipo_error`, `detalle`, `json_original`, `fecha_registro`.
- CHECK: `json_original IS JSON STRICT`

**CHECK adicionales (02_RESTRICCIONES.sql)**

- `ck_errores_etl_entidad_no_vacio`: `TRIM(entidad) IS NOT NULL`
- `ck_errores_etl_tipo_error_no_vacio`: `TRIM(tipo_error) IS NOT NULL`
- `ck_errores_etl_detalle_no_vacio`: `TRIM(detalle) IS NOT NULL`

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 7, dominio/rango 1, claves únicas 1, referencias 1, texto no vacío 3.

---

## trx_control_carga

Cobertura declarada por curso, periodo, dominio y corte. Copia en staging: `STG_CONTROL_CARGA`.

**Estructura (DDL)**

- PK: (id_control).
- UK: (id_curso, id_periodo, dominio, fecha_corte).
- FK: (id_curso) → `est_curso`.
- FK: (id_periodo) → `est_periodo_academico`.
- FK: (id_ejecucion) → `auditoria_etl_evaluaciones`.
- NOT NULL: `id_control`, `id_curso`, `id_periodo`, `dominio`, `fecha_corte`, `estado`, `registros_declarados`, `fecha_recepcion`, `id_ejecucion`.
- CHECK: `dominio IN ('MATRICULA','NOTAS','ASISTENCIA','BECAS')`
- CHECK: `fecha_corte = TRUNC(fecha_corte)`
- CHECK: `estado IN ('COMPLETA','PARCIAL','NO_APLICA')`
- CHECK: `registros_declarados >= 0`

**Trigger `TRG_VAL_TRX_CONTROL_CARGA`**: La clave primaria no se renumera en un UPDATE.

**Reglas de negocio (OLTP)**

| Regla | Severidad | Qué valida | Diccionario | Cómo se aplica |
|---|---|---|---|---|
| `CONTROL_CICLO` | BLOQUEO | El curso y período del control pertenecen al mismo ciclo. | Curso y período del mismo ciclo | Trigger (fin de sentencia) + cargador |

**Reglas espejo (OLTP, BLOQUEO)**: obligatorios 9, dominio/rango 4, claves únicas 2, referencias 3.

**Procedimientos**

- `PR_DECLARAR_COBERTURA`: no permite declarar COMPLETA si faltan registros o configuración al corte.

**Staging `STG_CONTROL_CARGA`** (trigger `TRG_STG_CONTROL_CARGA_INMUTABLE`)

- Reglas de negocio: `CONTROL_CICLO` (BLOQUEO, cargador (revisión individual)).
- Reglas espejo (BLOQUEO, cargador): obligatorios 9, dominio/rango 4, claves únicas 2, referencias 3, ejecución de carga 1.

