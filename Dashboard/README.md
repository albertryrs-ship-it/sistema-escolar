# Dashboard: Monitor de Rendimiento y Riesgo Académico

Tablero de Power BI sobre el modelo estrella (`Data_Mart/`), con los datos de la carga masiva: años 2024 y 2025, 42 centros y 14 departamentos.

| Archivo | Qué es |
|---|---|
| `Dashboard kodigo Plataforma Nacional Educativa.pbix` | El tablero; se abre con Power BI Desktop. Se conecta a las 7 tablas del modelo estrella. |
| `Dashboard kodigo Plataforma Nacional Educativa.pdf` | Las páginas del tablero exportadas, para verlas sin Power BI. |

**Conexión.** El `.pbix` guarda la conexión del equipo donde se armó. Para usarlo con otra base: en Power BI Desktop, *Transformar datos* → *Configuración de origen de datos* → *Cambiar origen*, y escribir `<host>:<puerto>/<servicio>` y el esquema del usuario del proyecto (ver "Configuración de cada equipo" en `Script_Maestro/README.md`). Luego *Actualizar*.

Abajo, página por página, qué muestra cada visual del dashboard y qué dicen los datos. Las cifras toman 2024 y 2025 juntos, salvo cuando se indica un año. "p.p." significa puntos porcentuales.

## Página 1 · Inicio

**Pregunta de la página:** *¿Cómo estamos frente al año anterior?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Velocímetro: Promedio General | Promedio de todas las notas, en escala de 0 a 100. | **76.48** con 2024 y 2025 juntos. El rendimiento general es aceptable, lejos del mínimo de 60. |
| Tarjetas: Promedio Año Actual y Variación | Promedio de 2025 y su diferencia, en puntos, contra 2024. | **76.41** en 2025, **−0.13 puntos** frente a 2024 (76.54). Una baja leve, pero en la dirección equivocada. |
| Tarjetas: % Aprobados, % Reprobados, % Asistencia, Retención | Los indicadores clave del sistema. | Aprobación **93.08 %**, reprobación **6.92 %**, asistencia **93.51 %** y retención interanual **88.41 %**: de cada 100 estudiantes de 2024, 88 siguen inscritos en 2025. La retención cuenta como "no retenidos" a los graduados de 3.º de bachillerato. La asistencia solo incluye 7 de los 14 departamentos, porque los otros no tienen registro. |
| Mapa por código ISO | Los 14 departamentos de El Salvador. Al hacer clic en uno, se filtra la página. | Sirve de navegación: el análisis por color está en la página Mapa. |
| Barras: % Reprobados por departamento y año | La reprobación de cada departamento en 2024 (verde) y 2025 (azul). | Encabeza **Sonsonate** (8.14 % → 8.16 %), seguido de Usulután (7.62 % → 7.78 %) y La Unión (7.35 % → 7.44 %). Las mayores alzas son **Morazán** (+0.72 p.p.) y **Cabañas** (+0.71 p.p.). Solo **San Vicente** (7.04 % → 6.47 %) y La Paz (6.21 % → 6.14 %) mejoraron. |
| Columnas: Promedio por grado y año | El promedio de cada grado, de 1.º de básica a 3.º de bachillerato, en 2024 y 2025. | Todos los grados están entre **75 y 77** en ambos años. Ningún grado se separa del resto: el rendimiento es parejo en toda la trayectoria escolar. |
| Líneas: % Aprobados por materia y año | La aprobación de cada materia, ordenada de mayor a menor, en ambos años. | Va de **Educación Física (\~97 %)** a **Matemática (\~88 %)**. Las líneas de 2024 y 2025 casi se superponen: el patrón por materia se repite cada año. |

## Página 2 · Estudiantes

**Pregunta de la página:** *¿Quién necesita apoyo y cuáles son sus notas?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Buscador por NIE y segmentación por departamento | Filtros para encontrar a un estudiante o a los de un departamento. | Al escribir un NIE, toda la página muestra solo a ese estudiante. |
| Tarjetas: Materias reprobadas y Cuartil promedio | La ficha del estudiante seleccionado. | Sin selección muestran el total del sistema: **21 mil** notas reprobadas y cuartil **2.00** (el promedio de todos). Con un estudiante seleccionado, muestran sus materias reprobadas y su posición en la sección (1 = el 25 % mejor, 4 = el 25 % más bajo). |
| Barras: Nivel de riesgo académico por estudiante | Estudiantes por nivel de alerta: **ALTO** = promedio < 60 y asistencia < 75 %; **MEDIO** = una de las dos; **BAJO** = 2 o más materias reprobadas en un período. | **1,894** en nivel BAJO, **600** en MEDIO y **6** en ALTO (2024 y 2025). Al hacer clic en una barra, la tabla muestra quiénes son. El nivel ALTO está subestimado, porque 7 departamentos no tienen asistencia registrada. |
| Tabla: Récord de notas | Cada nota con NIE, nombre, materia, período, sexo y centro. | Es la consulta por NIE que pidió el equipo: muestra la historia académica completa de un estudiante. |

## Página 3 · Asignaturas

**Pregunta de la página:** *¿Qué materias concentran la reprobación?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Tarjetas: Promedio, % Reprobados, Mediana y Desviación | Cómo le va a la materia seleccionada y qué tan parejas son sus notas. | Promedio general **76.48**, mediana **76.00** y desviación estándar **12.62**: la mayoría de notas están entre 64 y 89. |
| Barras: ¿Qué materias reprueban más? | El % de reprobados por materia, de mayor a menor. | **Matemática reprueba 11.98 %**, casi el doble del promedio (6.92 %). Le sigue **Inglés con 8.79 %**. Las demás materias académicas rondan el 7 %, y las que menos reprueban son Educación Artística (3.39 %) y Educación Física. |
| Barras: ¿Qué materias mejoraron o empeoraron frente a 2024? | El promedio de cada materia en 2024 y 2025. | Educación Física (**81**) y Artística (**80**) tienen los promedios más altos; **Matemática (72)** e **Inglés (74)**, los más bajos. Las barras de los dos años son casi iguales: ninguna materia cambió de forma marcada. |
| Matriz de calor: ¿En qué grado se complica cada materia? | El % de reprobados de cada materia en cada grado. | La celda más crítica es **Matemática en 1.º de básica (13.69 %)**, seguida de Matemática en 2.º de bachillerato (12.48 %), 1.º de bachillerato (12.09 %) y 2.º de básica (12.07 %). Educación Física no pasa del 4 % en ningún grado. |
| Líneas: ¿En qué período baja cada materia? | El promedio de cada materia por período. | Las materias son estables a lo largo del año. **Matemática** se mantiene en 72 y **sube a 73.2 en el período 4**; Educación Física y Artística se mantienen en 80–81. |

## Página 4 · Curso

**Pregunta de la página:** *¿Qué grados, secciones y centros rinden mejor o peor?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Tarjetas: Cursos, Estudiantes, % Aprobados, % Reprobados | El tamaño del sistema y su resultado general. | **1,008** secciones, **7,168** estudiantes, **93.08 %** de aprobación y **6.92 %** de reprobación. |
| Columnas: ¿Mejoró la aprobación de cada grado frente a 2024? | La aprobación por grado en 2024 y 2025. | Todos los grados están entre **92 % y 94 %** en ambos años, sin un grado que destaque o preocupe. |
| Barras: ¿Rinden distinto los centros públicos y privados? | La aprobación por tipo de institución y año. | Prácticamente iguales: privada **93.31 % → 93.02 %**, pública **93.10 % → 92.96 %**. Ambas bajan levemente en 2025. |
| Columnas: ¿Influye la jornada en el rendimiento? | La aprobación por jornada. | Sin diferencia: vespertina **93.14 %**, matutina **93.19 %**. |
| Matriz: ¿Qué centros y secciones necesitan apoyo? | Promedio, % reprobados y estudiantes por centro, desplegable a grado y sección. | El centro con más reprobación es el **Colegio Sintético Sonsonate 3 (9.61 %)**, seguido del Centro Escolar Sintético Cabañas 2 (8.50 %), el Colegio Sintético Usulután 3 (8.23 %), el Centro Escolar Sintético Ahuachapán 1 (8.22 %) y el Centro Escolar Sintético La Unión 2 (8.14 %). |

## Página 5 · Docentes

**Pregunta de la página:** *¿Qué docentes tienen mayor impacto?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Tarjetas: Docentes, Estudiantes por docente, Promedio, % Aprobados | La planta docente y su resultado. | **546** docentes, con **13.13** estudiantes por docente en promedio. |
| Tabla: ¿Qué docentes tienen mayor impacto? | Promedio, % de aprobados y estudiantes de cada docente en cada materia. | Un mismo docente aparece en varias materias porque **en educación básica un solo docente imparte todas las materias de su grado**, como pide el caso. Para comparar en igualdad de condiciones, se filtra una materia con la segmentación. |
| Barras: ¿Cómo rinden los estudiantes según la materia que se imparte? | El promedio por materia. | Educación Física y Artística, cerca de **80**; Matemática, la más baja, cerca de **72**. Un docente de Matemática no se debe comparar con uno de Educación Física. |
| Gráfico circular: ¿Qué especialidades logran más aprobados? | La aprobación por especialidad del docente. | **Educación básica 93.34 %**, **Bachillerato 92.45 %** y **Suplencias 87.90 %**. Los grupos con docentes suplentes aprueban cerca de **5 puntos menos**. Los porcentajes entre paréntesis son la parte del círculo, no un dato del negocio. |

## Página 6 · Mapa

**Pregunta de la página:** *¿Qué departamentos y zonas necesitan más apoyo?*

| **Visual** | **Qué muestra** | **Lectura con los datos** |
| --- | --- | --- |
| Tarjetas: Estudiantes, Promedio, % Reprobados, Notas reprobadas | El resumen del departamento seleccionado, o del país sin selección. | **7,168** estudiantes, promedio **76.48**, reprobación **6.92 %** y **21 mil** notas reprobadas. |
| Mapa: ¿Qué departamentos reprueban más? | Los departamentos coloreados según su % de reprobados: rojo el más alto, amarillo intermedio y verde el más bajo. | En **rojo**: Sonsonate y Usulután. En **amarillo**: Ahuachapán, Chalatenango, Cabañas y La Unión. El resto, en verde. |
| Barras: Ranking de reprobación por departamento | Los departamentos ordenados por % de reprobados (2024 y 2025 juntos). | **Sonsonate 8.15 %**, **Usulután 7.70 %**, **La Unión 7.40 %**, Chalatenango 7.32 % y Cabañas 7.00 %. El más bajo es La Paz (6.18 %). |
| Tabla: Detalle por departamento | Estudiantes, promedio, aprobación y reprobación de cada departamento. | Cada departamento tiene entre 502 y 519 estudiantes. **Morazán** tiene el promedio más alto (77.15) y **La Paz** la mayor aprobación (93.82 %). |
| Barras: ¿Hay diferencia entre la zona urbana y la rural? | El % de reprobados por zona y año. | No hay brecha: ambas zonas partieron de **6.81 %** en 2024 y subieron en 2025 (rural **7.06 %**, urbana **7.00 %**). |

## Mensajes clave para la presentación

1. **Matemática es la materia crítica:** reprueba 11.98 %, casi el doble del promedio, y llega a 13.69 % en 1.º de básica.
2. **Sonsonate y Usulután son los departamentos con más reprobación** (8.15 % y 7.70 %). El centro más afectado es el Colegio Sintético Sonsonate 3 (9.61 %).
3. **La reprobación subió en la mayoría de departamentos en 2025.** Morazán y Cabañas tuvieron las mayores alzas (+0.7 p.p.); solo San Vicente y La Paz mejoraron.
4. **Los grupos con docentes suplentes aprueban 5 puntos menos** (87.90 % frente a 93.34 % en educación básica).
5. **No hay brechas por tipo de centro, jornada ni zona:** público y privado, matutina y vespertina, urbano y rural rinden casi igual.
6. **Retención interanual de 88.41 %:** de cada 100 estudiantes de 2024, 88 siguen en 2025.

## Limitaciones que conviene mencionar

- Los datos de prueba no tienen asistencia en 7 departamentos (Ahuachapán, Cabañas, Chalatenango, Cuscatlán, Morazán, San Vicente y Santa Ana) ni en Educación Física y Artística. Por eso el % de asistencia usa solo 7 departamentos, y el nivel de riesgo ALTO está subestimado.
- La retención interanual cuenta como no retenidos a los estudiantes que se graduaron en 2024.
- Las tarjetas de la ficha del estudiante (materias reprobadas y cuartil) solo tienen sentido con un estudiante seleccionado.
