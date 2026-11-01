# Acerca del modelo

Base de datos para colegios de El Salvador, de parvularia a bachillerato. Guarda la vida académica de cada estudiante: dónde estudió, qué notas sacó, si asistió y si tuvo beca. Con eso calcula los indicadores (KPI) de un tablero de Power BI.

Campo por campo, el detalle está en `Diccionario_Datos_Educacion.md`; las relaciones, en `DER.mmd`; y cómo se calcula cada KPI, en `Diccionario_KPI_Educacion.md`.

## Cómo está organizado

| Capa | Qué es | Dónde |
|---|---|---|
| Operación (OLTP) | 33 tablas donde se registra el día a día. | `General/SCRIPT_BASE.sql` |
| Validaciones | 913 reglas, triggers y procedimientos que impiden guardar datos incoherentes y registran quién cambió qué. | `Validacion/` |
| Staging | Copia fechada de la operación, sin datos sensibles, de donde lee el BI. | `Staging/` |
| Data mart | Modelo estrella (6 dimensiones y 1 tabla de hechos) y expediente JSON. | `Data_Mart/` |
| Vistas materializadas | Cinco resúmenes del modelo estrella para el tablero. | `Vistas_Materializadas/` |
| Dashboard | Tablero de Power BI sobre el data mart. | `Dashboard/` |

Las 33 tablas de operación son 10 catálogos, 5 maestros, 7 de estructura académica, 8 de transacciones académicas, 1 de control de carga y 2 de auditoría de cargas.

## Personas e identidad

- **Una persona, varios roles.** Nombres, documento, nacimiento, sexo y contacto se guardan una sola vez. Una persona puede ser estudiante, docente o las dos cosas, y cada rol conserva sus propias fechas y estado.
- **Identificación.** El estudiante se identifica por su NIE, que es único. El documento de la persona es único por tipo y número, y puede faltar (tipo y número juntos).
- **No se fusionan personas por el nombre.** Dos registros son la misma persona solo si coinciden el documento, el NIE o una correspondencia verificada.

## Colegios y su historia

- **Colegio y departamento.** Cada colegio pertenece a un departamento (con su código ISO para el mapa) y a una zona, urbana o rural.
- **Foto anual del colegio.** Cada año se guarda cómo era el colegio: tipo (público o privado), departamento, zona y si daba becas. Así, si un colegio cambia después, los datos de años anteriores no cambian.
- **El camino histórico** es estudiante → inscripción → curso del año → colegio. El curso define grado, sección, jornada y modalidad; el nivel sale del grado.

## Año escolar: ciclos, períodos y planes

- **Ciclo.** Es un año escolar. No tiene duración fija y puede cruzar años, como el calendario agosto–junio de los colegios bilingües; en ese caso su año es el de inicio.
- **Períodos.** Cada ciclo define cuántos tiene: 3 trimestres en el calendario nacional, 4 en algunos bachilleratos. Van numerados, en orden y sin solaparse. Si en un mismo colegio conviven niveles con distinta cantidad de períodos, se usan ciclos separados.
- **Plan de la materia.** Cada materia de un curso tiene un peso por período. El plan se publica completo antes de registrar notas y queda congelado cuando ya tiene calificaciones. Los pesos no necesitan sumar 100: pueden ser iguales.
- **Plazos de entrega.** Para cada colegio, ciclo, grado y período se define cuándo se abre y se cierra la captura de notas, y para las recuperaciones, cuándo se rinden. Una nota entregada tarde conserva su fecha académica real.

## Notas

- **Una nota real por materia y período.** Las tareas y exámenes internos no entran.
- **Intentos.** La nota ordinaria es el intento 1; las recuperaciones, los intentos 2, 3, etc. Cada recuperación apunta a la ordinaria que recupera. Puede rendirse después del cierre del año, sin reabrir la inscripción, y la registra un docente que dio esa materia en ese período.
- **Correcciones.** Corregir una nota no la borra: crea una versión nueva y la anterior queda en el historial. Anular una versión no revive la anterior.
- **Numérica o cualitativa.** Cada nota es numérica, de 0 a 100, o cualitativa (por ejemplo, en parvularia), según la materia; nunca las dos. Las cualitativas no se convierten a números.
- **Nota elegida del período.** Según la materia, cuenta la mejor nota (`MEJOR_NOTA`, la opción por defecto) o la última recuperación (`ULTIMA_RECUPERACION`). La recuperación conserva el peso del período.

### Promedios

- **Promedio actual:** usa solo las notas que hay, con el peso de cada período. Una nota pendiente **no cuenta como cero**; un cero real, sí.
- **Cobertura:** qué porcentaje del peso del año ya tiene nota.
- **Promedio final:** aparece solo cuando están todas las notas y el año está cerrado; antes queda vacío.

Ejemplo: notas 80, 60 y pendiente, con pesos 30/30/40 → promedio actual **70**, cobertura **60 %** y final vacío. Al llegar un 90, el promedio pasa a **78** y se publica como final cuando cierra el año.

El promedio general de un estudiante da el mismo peso a cada materia numérica. El de un grupo promedia los promedios de sus estudiantes, no las notas sueltas.

## Traslados, docentes, clases y asistencia

- **Traslados.** Un traslado cierra la inscripción anterior y abre otra. Las notas conservan el colegio donde se obtuvieron. Para combinar notas de dos colegios, cada plan se normaliza a proporciones antes de unirlas.
- **Inscripciones.** Una inscripción termina, a más tardar, al cierre de su ciclo; seguir al año siguiente requiere una inscripción nueva. Un estudiante no puede tener dos inscripciones a la vez en el mismo ciclo. Terminar una inscripción no significa abandonar la escuela.
- **Docentes.** Cada materia de un curso tiene un solo docente responsable en cada fecha. Puede haber suplentes durante el año, y un docente puede trabajar en varios colegios.
- **Clases.** Cada clase pertenece a una materia, un período y un docente. Una clase nocturna puede terminar al día siguiente; conserva su día académico.
- **Asistencia.** Se marca por clase dada. Presente y tarde cuentan como asistencia; ausente y justificada, como falta. Si no hay registro, la captura está pendiente: no se asume una falta.

## Becas y cobertura de datos

- **Becas.** Se registra el beneficio y los períodos en que estuvo activo. Suspender cierra un período y reanudar abre otro, sin borrar la interrupción. Solo hay becas en colegios que las daban ese año, y los beneficios simultáneos no suman más del 100 %.
- **Datos completos o parciales.** Para cada curso, período y tipo de dato (matrícula, notas, asistencia, becas) se declara si la información llegó completa, parcial o no aplica. "No sabemos" no se trata como cero: un KPI con datos parciales se muestra como provisional.

## Los KPI del tablero

| | KPI | Qué mide |
|---|---|---|
| K01 | Estudiantes | Estudiantes distintos con resultados. |
| K02 | Promedio general | Promedio de las notas de período. |
| K03 | Aprobación y reprobación | Notas de 60 o más sobre las notas con valor; las pendientes no cuentan. |
| K04 | Asistencia | Presencias sobre sesiones con asistencia registrada. |
| K05 | Riesgo académico | ALTO: promedio menor que 60 **y** asistencia menor que 75 % en el mismo período. MEDIO: una de las dos. BAJO: 2 o más materias reprobadas. |
| K06 | Retención | Estudiantes del año anterior que siguen con resultados este año. |
| K07 | Variación interanual | Promedio general del año menos el del año anterior. |
| K08 | Reprobación por departamento | K03 por el departamento del colegio en ese año, en ranking y mapa. |

La fórmula de cada uno, en DAX, y sus limitaciones están en `Diccionario_KPI_Educacion.md`. Por ejemplo, la retención cuenta como perdidos a los graduados, y el riesgo exige toda la asistencia del período: si falta, el estudiante figura como "información insuficiente".

## Datos para BI y expediente

- **Staging:** cada carga queda registrada en la auditoría, con su fuente, fecha y errores, para poder repetirla sin duplicar.
- **Data mart:** organiza los datos en una fila por estudiante, materia y período, con nota, asistencia, riesgo, ranking y progresión.
- **Expediente académico:** de cada estudiante y cada año cerrado se genera un expediente JSON con sus materias, promedios, asistencia y riesgo. Lleva una huella SHA256: si alguien cambia un dato, la huella ya no coincide. Los promedios del expediente se calculan; nunca se vuelven a cargar como notas.

## En Oracle

Funciona en Oracle 23ai, y también en 19c y 21c. Solo usa tipos clásicos: `NUMBER`, `VARCHAR2`, `DATE`, `TIMESTAMP` y JSON guardado como texto validado. Los sí/no se guardan como 0/1. Las reglas de una sola fila son `CHECK` en las tablas. Las que cruzan tablas (curso, período, docente, nota, beca, solapamientos) las aplican los triggers y procedimientos de `Validacion/`. No hay borrado en cascada sobre la historia académica.
