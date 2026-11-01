# Plataforma Nacional Educativa — modelo en Oracle

Base de datos para colegios de El Salvador, de parvularia a bachillerato. Registra estudiantes, cursos, notas, asistencia y becas, y valida que todo sea coherente. Además prepara los datos para un tablero de Power BI y genera el expediente académico de cada estudiante en JSON. Funciona en Oracle 23ai (también en 19c y 21c).

## Por dónde empezar

| Si quieres… | Lee |
|---|---|
| Entender el modelo | `General/Acerca_del_modelo.md` |
| Instalarlo | `Script_Maestro/README.md` (empezar por "Configuración de cada equipo") |
| Saber qué reglas se validan | `Validacion/Reglas_principales.md` |
| Saber qué se copia para BI | `Staging/Staging_en_resumen.md` |
| Ver el modelo para Power BI | `Data_Mart/README.md` |
| Ver el tablero y sus conclusiones | `Dashboard/README.md` |
| Ver un expediente académico | `JSON_Ejemplo/README.md` |

## Carpetas

Cada carpeta, salvo `General/`, tiene un `README.md` con lo que hace cada archivo.

| Carpeta | Qué hay |
|---|---|
| `Script_Maestro/` | El script que instala todo en un paso, sus datos (ficticios y carga masiva) y la versión para Windows. |
| `General/` | El modelo: guía, diccionario de datos, diccionario de KPI, diagrama entidad-relación y DDL. |
| `Validacion/` | Las reglas, triggers y procedimientos que protegen los datos. |
| `Staging/` | La copia para BI: creación y diccionario. La carga la hace `pr_cargar_staging`, en `Validacion/`. |
| `Data_Mart/` | El modelo estrella, el expediente JSON y demostraciones de errores y optimización. |
| `Vistas_Materializadas/` | Los cinco resúmenes del modelo estrella que usa el tablero, uno por archivo, y su refresco diario. |
| `Dashboard/` | El tablero de Power BI (`.pbix` y PDF) y la explicación de cada página. |
| `JSON_Ejemplo/` | Ejemplos del expediente académico que genera el proyecto. |
| `Pruebas/` | Pruebas en Oracle y generadores en Python. |

## En números

- 33 tablas de operación, 29 de staging y un modelo estrella de 6 dimensiones y 1 tabla de hechos.
- 913 reglas de validación y 8 KPI en el tablero.
- Carga masiva de prueba: 42 colegios (3 por departamento), 2 años y unos 4 millones de filas.

Los CSV de la carga masiva no están en el repositorio (pesan unos 320 MB); se generan con `python Pruebas/scripts/generar_carga_masiva.py`.
