# Data Mart (modelo estrella)

Capa analítica que lee staging y alimenta Power BI. El script maestro corre `01`, `02_MODELO_ESTRELLA/` y `03` (pasos 8 a 10) y `05` (paso 12). Entre ambos, en el paso 11, instala las vistas materializadas, que están en su propia carpeta: `../Vistas_Materializadas/`. También se pueden correr solos, en ese orden. `06`, `07` y `08` son demostraciones aparte.

| Archivo | Qué hace |
|---|---|
| `01_CALENDARIO.sql` | Crea `DIM_TIEMPO` (calendario 2024-2027). |
| `02_MODELO_ESTRELLA/` | La estructura del modelo estrella, en una carpeta. `INSTALAR_MODELO_ESTRELLA.sql` ejecuta en orden: `01_VISTAS_LECTURA` (última carga de staging), `02_VISTAS_VALIDACION`, `03_TABLAS_TRABAJO` (`WK_ETL_*`), `04_TRANSFORMACION`, `05_DIMENSIONES`, `06_HECHOS` y `07_TRIGGERS_AUDITORIA`. |
| `03_ETL_CARGA_ESTRELLA.sql` | ETL de staging al modelo estrella: valida, registra rechazos en `errores_etl_evaluaciones`, carga dimensiones y hechos con `MERGE` y cierra la ejecución en `auditoria_etl_evaluaciones`. |
| `04_REHACER_ESTRELLA.sql` | Ejecuta 02, 03 y `../Vistas_Materializadas/INSTALAR_VISTAS.sql` seguidos. Sirve para actualizar el modelo estrella y las vistas sin tocar OLTP ni staging. |
| `05_EXPEDIENTE_JSON.sql` | Emite el expediente académico JSON firmado (SHA256) de cada estudiante por cada ciclo cerrado. |
| `06_ERRORES_SEMBRADOS.sql` | Simula una carga nueva con 17 errores sembrados y ejecuta el ETL para demostrar que se detectan y se registran. |
| `07_PERMISOS_OPTIMIZACION_SYSTEM.sql` | Una vez, como SYSTEM: permiso para leer los planes reales (`SELECT ANY DICTIONARY`). |
| `08_OPTIMIZACION.sql` | Mide 3 consultas clave antes y después (vistas materializadas e índices) con `ALLSTATS LAST` y agrega el caso del ETL. |

## Optimización del ETL (tablas de trabajo)

Con la carga masiva (~4.1 millones de filas) el ETL no terminaba en Oracle 23ai Free:

1. **Primer intento:** el `MERGE` de hechos leía `vw_etl_hechos_resultados` directamente. Pasó más de 90 minutos sin terminar, porque Oracle recalculaba las vistas de validación anidadas dentro del `MERGE`.
2. **Segundo intento:** se guardaron las filas válidas en tablas de trabajo, pero el `INSERT` de la transformación siguió más de 40 minutos con la espera `latch: cache buffers chains`. El plan (`optimizacion/plan_ANTES_insert_wk_etl_hechos.txt`, operaciones 151-185) muestra `NESTED LOOPS` que, por cada inscripción, leían por el índice `IX_STG_*_CARGA` (solo `id_ejecucion_carga`) todas las asignaturas, ponderaciones y las 252 mil sesiones de la carga: 79G filas estimadas.
3. **Tercer intento:** al unir solo sesiones, ponderaciones y asignaturas del staging, Oracle volvió a elegir `NESTED LOOPS` (6190M filas estimadas) e ignoró los hints, porque las tablas venían dentro de vistas. El índice `IX_STG_*_CARGA` tiene un costo estimado casi cero, y por eso Oracle lo prefiere aunque relea toda la carga.
4. **Cuarto intento:** la transformación final volvió a leer `STG_PONDERACIONES` por cada una de las 335 mil calificaciones (8211M filas estimadas, `optimizacion/plan_ANTES_insert_wk_etl_hechos_v4.txt`).
5. **Solución:** cada tabla de staging se copia primero sola, sin uniones (`WK_ETL_SES_RAW`, `WK_ETL_PP`, `WK_ETL_AD`, `WK_ETL_CA`). Las uniones se hacen solo entre tablas de trabajo. La sección Preparación del `03` llena `WK_ETL_INS`, `WK_ETL_CAL`, `WK_ETL_ASI`, esas tres, `WK_ETL_SES` (sesiones impartidas con su curso), `WK_ETL_ASIST` (asistencia ya agregada) y `WK_ETL_HECHOS`, cada una con estadísticas (`DBMS_STATS`). Las uniones pesadas usan `HASH JOIN` (`USE_HASH`). El `MERGE` lee de `WK_ETL_HECHOS`. Las reglas y los resultados son los mismos.

## Expediente académico JSON

- **Uno por estudiante y ciclo cerrado.** ID `EX-{CICLO}-{ID_ESTUDIANTE}-{SEQ}`, por ejemplo `EX-NAC-2025-1010014-001`. `CICLO` es el código del ciclo (`NAC-2025`, `BAC4-2025`) y `SEQ` es la versión.
- **Contenido:** `estudiante` (id, NIE, nombre, edad al cierre, sexo, institución, tipo, zona, departamento y modalidad), `ciclo_academico`, `asignaturas` (id, nombre, docente, promedio_final, asistencia y estatus), `promedio_general` y `riesgo_academico` (booleano).
- **Firma:** `firma_digital = STANDARD_HASH(documento sin la firma, 'SHA256')`. El script recalcula todas las firmas y demuestra que, si se altera un dato, el hash ya no coincide.
- **Nombre:** se toma del OLTP (`mae_estudiante` → `mae_persona`), porque el staging no replica los nombres de los estudiantes.
- **Historial:** la tabla `EXPEDIENTE_ACADEMICO` se conserva entre ejecuciones. Si el contenido no cambió, el expediente no se vuelve a emitir; si cambió, se emite una versión nueva (`SEQ + 1`). El trigger `TRG_EXPEDIENTE_INMUTABLE` impide modificar o borrar un expediente firmado. Cada ejecución queda en `auditoria_etl_evaluaciones`.

## Errores sembrados

El staging del equipo no se puede editar: los triggers `trg_stg_*_inmutable` solo aceptan filas de una carga `EN_PROCESO` y bloquean `UPDATE` y `DELETE`. Por eso `06_ERRORES_SEMBRADOS.sql` simula la llegada de una carga nueva. Copia la última carga completa, agrega 17 filas con errores (ids `99000000xx`) y ejecuta el ETL.

| Entidad | Errores sembrados | Tipo esperado |
|---|---|---|
| Calificaciones | nota 150; sin nota ni resultado; intento EXTRAORDINARIA; inscripción inexistente; evaluada en 2031; calificación duplicada | NOTA_FUERA_DE_RANGO, RESULTADO_INCOMPLETO, DOMINIO_INVALIDO, CLAVE_HUERFANA, FECHA_INVALIDA, DUPLICADO |
| Asistencias | estado PRESENT; sesión inexistente; asistencia duplicada | DOMINIO_INVALIDO, CLAVE_HUERFANA, DUPLICADO |
| Inscripciones | estudiante inexistente; termina antes de empezar; estado ACTIVA | CLAVE_HUERFANA, FECHA_INVALIDA, DOMINIO_INVALIDO |
| Estudiantes | NIE de otro estudiante; sexo X; nacimiento en el futuro | NIE_DUPLICADO, DOMINIO_INVALIDO, FECHA_INVALIDA |
| Cursos | modalidad inexistente; grado inexistente | MODALIDAD_INVALIDA, CLAVE_HUERFANA |

Cada rechazo queda en `errores_etl_evaluaciones` con la fila original en JSON. El modelo estrella no cambia, porque las filas válidas son las mismas.

## Modelo

- **Hechos:** `HECHOS_RESULTADOS`. Grano: un resultado oficial por estudiante, asignatura y período.
- **Dimensiones:** `DIM_ESTUDIANTE`, `DIM_DOCENTE`, `DIM_ASIGNATURA`, `DIM_MODALIDAD`, `DIM_CURSO` y `DIM_TIEMPO`.
- **Clave agregada respecto del caso:** `sk_curso`. Sin ella no se puede saber el colegio, la zona y el departamento del estudiante en cada año. `DIM_CURSO` guarda esa ubicación histórica desde `STG_INSTITUCIONES_CICLO`.
- **Código ISO del mapa:** `cat_departamento.codigo` lleva el código ISO 3166-2 (`SV-AH`, `SV-SS`, ...). Llega por `STG_DEPARTAMENTOS` y el ETL lo copia a `DIM_CURSO.CODIGO_ISO`; si un código no tiene formato `SV-__`, queda vacío.

## Transformaciones (vista `vw_etl_hechos_resultados`)

| Cálculo | Cómo |
|---|---|
| Promedio ponderado del año | `SUM(nota * peso) / SUM(peso con nota)` por inscripción y asignatura |
| Asistencia | Presencias (PRESENTE + TARDE) / sesiones registradas, solo sesiones IMPARTIDAS dentro de la inscripción |
| Riesgo | Promedio del período < 60 **y** asistencia del período < 75 %. Queda `NULL` (información insuficiente) si falta asistencia por capturar |
| Ranking en el curso | `PERCENT_RANK` y `NTILE(4)` por curso, asignatura y período |
| Promedio del curso | `AVG(...) OVER` |
| Progresión interanual | `LAG` sobre el mismo estudiante, asignatura y número de período en años consecutivos |

## Reglas que respeta del staging del equipo

- El staging guarda una copia por carga y no se puede editar. Las vistas `vw_etl_stg_*` leen solo la última carga `COMPLETADA`.
- Las ejecuciones y los errores usan `SEQ_ETL_CARGA` y `SEQ_ETL_ERROR`. Los errores del data mart se marcan con entidad `DM:...`.
- Mientras una ejecución está `EN_PROCESO` no se escribe `fin` (regla `ck_auditoria_etl_estado_y_fin`).
- El staging no copia los nombres de los estudiantes. El ETL toma el nombre del OLTP (`mae_estudiante` → `mae_persona`) y lo guarda en `DIM_ESTUDIANTE.NOMBRE_COMPLETO`; el estudiante se identifica por NIE.
- El bachillerato puede tener 4 períodos (`periodo_numero` de 1 a 4).

## Re-ejecución

Todos los scripts se pueden volver a correr sin perder datos:

- `01` y `02` crean el calendario, las dimensiones y los hechos solo si no existen, y comprueban que tengan la estructura esperada. Si no la tienen, se detienen (error -20114) y el cambio se hace con `ALTER TABLE`. El calendario se actualiza con `MERGE` por fecha.
- Las tablas de trabajo `WK_ETL_*` sí se recrean, porque no guardan datos propios: `03` las vacía y las llena en cada corrida.
- Después de cada `EXEC pr_cargar_staging;`, correr `03`. Inserta los hechos nuevos, actualiza solo los que cambiaron y quita los que ya no están en staging. Correrlo dos veces seguidas no cambia nada.
- `INSTALAR_VISTAS.sql` recrea las vistas materializadas; `05` emite solo los expedientes que cambiaron.
- Para empezar de cero, se borra el usuario completo.

## Power BI

Cargar solo las 7 tablas del modelo y relacionar cada dimensión con `HECHOS_RESULTADOS` (uno a varios): `SK_ESTUDIANTE`, `SK_DOCENTE`, `SK_ASIGNATURA`, `SK_MODALIDAD`, `SK_CURSO` e `ID_TIEMPO`. Para el mapa, usar `DIM_CURSO[CODIGO_ISO]` con la categoría de datos *Estado o provincia*.
