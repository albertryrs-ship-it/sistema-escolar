# Diccionario de KPI

Los indicadores que muestra el tablero de Power BI (`Dashboard/`), con la fórmula exacta con que los calcula.

Todos salen de `HECHOS_RESULTADOS`, que tiene **una fila por estudiante, materia y período**: el resultado oficial de ese período. Las dimensiones solo agrupan y filtran: estudiante, docente, materia, curso (con colegio, departamento y zona de ese año), modalidad y tiempo.

Escala de 0 a 100. Se aprueba con **60** y la referencia de asistencia es **75 %**.

## Resumen

| | KPI | Medida en Power BI | Páginas |
|---|---|---|---|
| K01 | Estudiantes | `Estudiantes` | Curso, Mapa |
| K02 | Promedio general | `Promedio General`, `Promedio Año Actual` | Inicio, Asignatura, Curso, Docente, Mapa |
| K03 | Aprobación y reprobación | `% Aprobados`, `% Reprobados`, `Notas Reprobadas` | Todas |
| K04 | Asistencia | `% Asistencia` | Inicio |
| K05 | Riesgo académico por niveles | `Estudiantes por Nivel` (`Alerta Alta`, `Alerta Media`, `Alerta Baja`) | Estudiantes |
| K06 | Retención interanual | `Retención Interanual` | Inicio |
| K07 | Variación interanual | `Variación vs Año Anterior` | Inicio |
| K08 | Reprobación por departamento | `% Reprobados` por `DEPARTAMENTO` y `CODIGO_ISO` | Inicio, Mapa |

## Los KPI

### K01. Estudiantes

```
Estudiantes = DISTINCTCOUNT ( HECHOS_RESULTADOS[SK_ESTUDIANTE] )
```

Estudiantes distintos con al menos un resultado en el filtro elegido (año, departamento, grado…). Un estudiante que se trasladó cuenta una vez.

**Nota:** cuenta a quienes tienen resultados, no a todos los inscritos a una fecha. Un estudiante recién inscrito, todavía sin notas, no aparece.

### K02. Promedio general

```
Promedio General   = AVERAGE ( HECHOS_RESULTADOS[NOTA] )
Promedio Año Actual = CALCULATE ( [Promedio General], HECHOS_RESULTADOS[ANIO] = MAX ( HECHOS_RESULTADOS[ANIO] ) )
```

Promedio de las notas de período en el filtro elegido. Sin filtro de año junta 2024 y 2025; `Promedio Año Actual` toma solo el último año del filtro.

**Nota:** es un promedio simple de notas: no aplica los pesos del plan de cada materia ni promedia primero por estudiante. El promedio ponderado del año por estudiante y materia sí está en los hechos (`PROMEDIO_ANUAL_MATERIA`, con su cobertura en `COBERTURA_ANUAL_PCT`) y se usa en el expediente JSON, pero no en el tablero.

### K03. Aprobación y reprobación

```
% Aprobados     = DIVIDE ( SUM ( HECHOS_RESULTADOS[APROBADO] ), COUNT ( HECHOS_RESULTADOS[APROBADO] ) )
% Reprobados    = DIVIDE ( CALCULATE ( COUNT ( HECHOS_RESULTADOS[APROBADO] ), HECHOS_RESULTADOS[APROBADO] = 0 ),
                           COUNT ( HECHOS_RESULTADOS[APROBADO] ) )
Notas Reprobadas = CALCULATE ( COUNTROWS ( HECHOS_RESULTADOS ), HECHOS_RESULTADOS[APROBADO] = 0 )
```

Unidad: estudiante, materia y período. `APROBADO` es 1 si la nota es 60 o más, 0 si es menor y vacío si no hay nota. `COUNT` ignora los vacíos, así que las notas pendientes y los resultados cualitativos (parvularia) no cuentan en ninguno de los dos lados. `% Aprobados + % Reprobados = 100 %`.

### K04. Asistencia

```
% Asistencia = DIVIDE ( SUM ( HECHOS_RESULTADOS[PRESENCIAS] ), SUM ( HECHOS_RESULTADOS[SESIONES_REGISTRADAS] ) )
```

Presencias (presente y tarde) sobre las sesiones impartidas que tienen asistencia registrada. Una sesión sin registro no cuenta como falta: queda fuera del denominador.

**Nota:** es la asistencia observada. El tablero no muestra la cobertura (sesiones con registro sobre sesiones impartidas), aunque los hechos la permiten con `SESIONES_APLICABLES`. En la carga de prueba, 7 departamentos y 2 materias no tienen asistencia, así que la tasa refleja solo el resto.

### K05. Riesgo académico por niveles

Se evalúa por estudiante y período. Cada estudiante cae en el primer nivel que cumpla:

| Nivel | Condición | Medida |
|---|---|---|
| ALTO | `EN_RIESGO = 1`: promedio del período < 60 **y** asistencia del período < 75 % | `Alerta Alta` |
| MEDIO | Una sola de las dos condiciones (las que tengan dato) | `Alerta Media` |
| BAJO | Ninguna de las dos, pero 2 o más materias reprobadas en el período | `Alerta Baja` |

```
Alerta Alta = CALCULATE ( DISTINCTCOUNT ( HECHOS_RESULTADOS[SK_ESTUDIANTE] ), HECHOS_RESULTADOS[EN_RIESGO] = 1 )
```

`Alerta Media` y `Alerta Baja` arman una tabla por estudiante y período con `EN_RIESGO`, `PROMEDIO_PERIODO_ESTUDIANTE`, `ASISTENCIA_PERIODO_ESTUDIANTE` y la cantidad de notas reprobadas, filtran según la condición y cuentan estudiantes distintos. `Estudiantes por Nivel` elige la medida según la barra (tabla `Niveles`). Es la misma regla de `MV_ALERTA_RIESGO`.

`EN_RIESGO` lo calcula el ETL y queda vacío ("información insuficiente") si el estudiante no tiene notas en el período o si falta asistencia por capturar. Por eso un estudiante sin asistencia nunca llega a ALTO.

**Nota:** el tablero muestra cantidades, no la tasa de riesgo sobre los estudiantes evaluables. Un estudiante con niveles distintos en distintos períodos cuenta en cada nivel. ALTO está subestimado en la carga de prueba, por los departamentos sin asistencia.

### K06. Retención interanual

```
Retención Interanual =
VAR anio     = MAX ( HECHOS_RESULTADOS[ANIO] )
VAR anterior = CALCULATETABLE ( VALUES ( HECHOS_RESULTADOS[SK_ESTUDIANTE] ), HECHOS_RESULTADOS[ANIO] = anio - 1 )
VAR actual   = CALCULATETABLE ( VALUES ( HECHOS_RESULTADOS[SK_ESTUDIANTE] ), HECHOS_RESULTADOS[ANIO] = anio )
RETURN DIVIDE ( COUNTROWS ( INTERSECT ( anterior, actual ) ), COUNTROWS ( anterior ) )
```

De los estudiantes con resultados el año anterior, cuántos tienen resultados este año. Un traslado o una repetición de grado cuentan como continuar, porque se sigue al mismo estudiante en cualquier colegio y grado.

**Nota:** cuenta como no retenidos a los graduados de 3.º de bachillerato del año anterior, que no deberían estar en el denominador. Por eso la retención real es más alta que la que muestra el tablero (88.41 %).

### K07. Variación interanual

```
Variación vs Año Anterior =
VAR anio     = MAX ( HECHOS_RESULTADOS[ANIO] )
VAR actual   = CALCULATE ( [Promedio General], HECHOS_RESULTADOS[ANIO] = anio )
VAR anterior = CALCULATE ( [Promedio General], HECHOS_RESULTADOS[ANIO] = anio - 1 )
RETURN IF ( NOT ISBLANK ( anterior ), actual - anterior )
```

Diferencia, en puntos de nota, entre el promedio general del último año y el del año anterior, con el mismo filtro (materia, grado, departamento…).

**Nota:** compara a todos los estudiantes de cada año, no a los mismos: los que entran y los que salen cambian el resultado. La variación del mismo estudiante en la misma materia está en los hechos (`VARIACION_INTERANUAL`) y en `MV_PROGRESO_ACADEMICO`, pero no en el tablero.

### K08. Reprobación por departamento

Es el K03 (`% Reprobados`) agrupado por el departamento del colegio **en ese año** (`DIM_CURSO[DEPARTAMENTO]`), que se copia desde `est_institucion_ciclo`: si un colegio cambia de departamento, los años anteriores no se mueven. El mapa usa `DIM_CURSO[CODIGO_ISO]` (ISO 3166-2, `SV-SO`, `SV-US`…). Se muestra como ranking, como barras por año y coloreado en el mapa.

**Nota:** el ranking territorial usa la reprobación, no el riesgo académico, porque 7 departamentos no tienen asistencia y su riesgo no se puede calcular.

## Medidas de apoyo

| Medida | Fórmula | Dónde |
|---|---|---|
| `Mediana Nota` | `MEDIAN ( NOTA )` | Asignatura |
| `Desviacion Nota` | `STDEV.P ( NOTA )` | Asignatura |
| `Cuartil Promedio` | `ROUND ( AVERAGE ( CUARTIL_CURSO ), 0 )`: 1 = 25 % mejor de su sección en esa materia y período; 4 = 25 % más bajo | Estudiantes (ficha) |
| `Materias Reprobadas` | Columna: notas con `APROBADO = 0` | Estudiantes (ficha) |
| `Cursos` | `DISTINCTCOUNT ( SK_CURSO )`: secciones con resultados | Curso |
| `Docentes` | `DISTINCTCOUNT ( SK_DOCENTE )`: docentes responsables con resultados | Docente |
| `Estudiantes por Docente` | `DIVIDE ( [Estudiantes], [Docentes] )` | Docente |

El modelo tiene además `Promedio Año Anterior`, `Total Hechos`, `Ocupacion Cursos` y `Experiencia Promedio`, que no se usan en ninguna página.

## Reglas que ya vienen aplicadas en los hechos

El ETL (`Data_Mart/03_ETL_CARGA_ESTRELLA.sql`) deja los datos listos para que las medidas sean simples:

- **Un resultado por período.** Si hubo recuperación, cuenta la nota elegida según la materia (`MEJOR_NOTA` por defecto, o `ULTIMA_RECUPERACION`), no las dos. Una corrección reemplaza a la versión anterior, sin duplicarla.
- **Pendiente no es cero.** Una nota pendiente queda vacía y no entra en promedios ni en aprobación; un 0 real sí cuenta.
- **Sin registro no es falta.** Solo cuentan las sesiones impartidas con asistencia registrada y dentro de la vigencia de la inscripción.
- **Riesgo solo con datos completos.** `EN_RIESGO` exige notas en el período y toda la asistencia capturada; si no, queda vacío.
- **Historia del colegio.** Departamento, zona y tipo de institución son los del año del resultado, no los actuales.
- **Un docente por resultado.** Cada resultado se atribuye al docente de la asignación con que se registró la nota, que puede ser un suplente; no se duplica. Una comparación entre docentes no demuestra causa.
- **Cuartil estable.** Con notas iguales, el cuartil desempata por estudiante, así que no cambia entre cargas.
