# Reglas principales

Las validaciones impiden guardar datos incoherentes. En total son 913 reglas, pero la mayoría repite lo que ya garantizan las tablas: campos obligatorios, valores permitidos, claves únicas y referencias. Aquí están solo las **reglas de negocio**, las que vale la pena conocer. El listado completo, tabla por tabla, está en `Reglas_por_tabla.md`.

## Cómo actúan

- **Bloquean** (BLOQUEO): si un cambio las rompe, Oracle lo rechaza y no se guarda nada.
- **Quedan pendientes** (PENDIENTE): se permite el cambio, pero aparece en el diagnóstico como algo por completar.
- **Avisan** (AVISO): algo raro que conviene revisar, sin impedir nada.

Se aplican al guardar cada cambio, al cargar staging y al correr el diagnóstico (`EXEC pr_diagnosticar_validaciones;`).

## Año escolar y planes

- Los períodos están dentro de su ciclo y no se solapan.
- *Aviso:* los períodos van numerados 1, 2, 3… sin saltos y en orden de fechas.
- *Aviso:* el año de un ciclo es el de inicio, aunque termine al año siguiente.
- Un plan publicado tiene un peso para **cada** período del ciclo.
- Una misma materia, en el mismo grado y ciclo, tiene las mismas proporciones de peso en todos los cursos.
- *Pendiente:* una materia con alumnos inscritos debe tener plan, y cada período del plan, su plazo de entrega.

## Inscripciones y docentes

- Una inscripción está dentro de las fechas de su ciclo.
- Un estudiante no puede tener dos inscripciones al mismo tiempo en el mismo ciclo.
- Una inscripción cerrada tiene fecha y motivo (traslado, retiro…).
- Cada materia tiene un solo docente responsable en cada fecha.
- Un docente o un curso no pueden tener dos clases a la misma hora.

## Notas

- La nota corresponde al curso, la materia y el docente correctos, y el plan debe estar publicado.
- Cada nota es numérica (de 0 a 100) o cualitativa, según la materia; nunca las dos.
- La nota normal es el intento 1 y las recuperaciones, 2 o más. Una recuperación apunta a la nota normal que recupera.
- Una nota solo se registra dentro del plazo de captura y no antes de la evaluación.
- Una recuperación queda a cargo de un docente que dio esa materia en ese período.
- Una corrección crea una versión nueva; la anterior se conserva.
- La nota elegida para un período respeta la regla de la materia (mejor nota o última recuperación) y usa la última versión válida.

## Asistencia

- Solo se marca asistencia en clases dadas, para alumnos inscritos en ese curso en esa fecha.
- Ausente o justificada no tiene hora de llegada.

## Becas

- Solo en colegios que dan becas ese año.
- La beca está dentro de las fechas de la inscripción y sus períodos activos no se solapan.
- Las becas activas al mismo tiempo no suman más del 100 %.

## Otras

- Nadie nace en el futuro.
- Tipo y número de documento van juntos, o ninguno de los dos.

## Operaciones protegidas

Algunas acciones pasan por un procedimiento que hace todas las comprobaciones juntas:

- **Registrar y corregir notas:** `pr_registrar_calificacion`, `pr_corregir_calificacion`.
- **Validar y anular notas:** `pr_validar_calificacion`, `pr_anular_calificacion`.
- **Elegir la nota del período:** `pr_seleccionar_resultado`.
- **Planes:** `pr_publicar_plan`.
- **Estudiantes:** `pr_trasladar_estudiante`.
- **Becas:** `pr_otorgar_beca`, `pr_suspender_beca`, `pr_reanudar_beca`.
- **Cierres y plazos:** `pr_cerrar_ciclo`, `pr_reabrir_ciclo`, `pr_reabrir_plazo`.
