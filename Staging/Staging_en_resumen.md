# Staging en resumen

Staging es una **copia de los datos de operación, preparada para el BI**. El tablero lee desde aquí, no desde las tablas donde se trabaja a diario. Así los reportes no afectan la operación, y cada copia queda fechada.

Campo por campo, el detalle está en `Diccionario_Staging.md`.

## Qué se copia

29 tablas STG, cada una con su origen:

| Tema | Tablas de staging |
|---|---|
| Estudiantes y docentes | `STG_ESTUDIANTES`, `STG_DOCENTES` |
| Colegios | `STG_INSTITUCIONES`, `STG_INSTITUCIONES_CICLO` (la foto anual), `STG_DEPARTAMENTOS`, `STG_ZONAS`, `STG_TIPOS_INSTITUCION` |
| Año escolar | `STG_CICLOS`, `STG_PERIODOS`, `STG_PLAZOS_NOTAS` |
| Cursos y materias | `STG_CURSOS`, `STG_CURSOS_ASIGNATURAS`, `STG_ASIGNATURAS`, `STG_AREAS_CONOCIMIENTO`, `STG_GRADOS`, `STG_NIVELES`, `STG_JORNADAS`, `STG_MODALIDADES`, `STG_PONDERACIONES` |
| Vida académica | `STG_INSCRIPCIONES`, `STG_CALIFICACIONES`, `STG_RESULTADOS_PERIODO`, `STG_ASIGNACIONES_DOCENTES`, `STG_SESIONES`, `STG_ASISTENCIAS` |
| Becas | `STG_BECAS`, `STG_BECAS_VIGENCIA`, `STG_TIPOS_BECA` |
| Control | `STG_CONTROL_CARGA` (qué datos llegaron completos) |

## Qué **no** se copia

- **Datos personales sensibles:** documento, correo, teléfono y dirección. De los estudiantes solo van la fecha de nacimiento y el sexo, que necesitan los KPI. De los docentes, el nombre, para los reportes por docente.
- **Contactos de los colegios** y **observaciones** escritas a mano.
- **Tablas técnicas:** tipos de documento, auditoría de cargas y errores de carga (cada copia apunta a su ejecución en la auditoría).

## Cómo se carga

- Se copia **todo de una vez**: o entra completo o no entra nada. Si una regla falla, la copia se descarta y queda registrado el motivo.
- Cada fila guarda **de qué carga viene** (`id_ejecucion_carga`) y **cuándo** (`fecha_carga`).
- Las copias son **de solo lectura**: no se editan ni se borran.
- Antes de aceptar la copia, se comprueba que sea **idéntica al origen** y que cumpla las mismas reglas que la operación.

Con las validaciones instaladas, la carga se hace con `EXEC pr_cargar_staging;`. Lo más simple es usar el script maestro (`Script_Maestro/README.md`).
