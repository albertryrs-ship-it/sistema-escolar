# Vistas materializadas

Cinco resúmenes ya calculados sobre el modelo estrella (`../Data_Mart/`), para que el tablero y las consultas frecuentes no recalculen todo cada vez. El script maestro las instala en su paso 11, después de cargar los hechos.

Para instalarlas solas (con el modelo estrella ya cargado), desde esta carpeta:

```
@INSTALAR_VISTAS.sql
```

| Archivo | Qué hace |
|---|---|
| `INSTALAR_VISTAS.sql` | Revisa que `HECHOS_RESULTADOS` tenga datos, ejecuta los demás archivos en orden y muestra un resumen de cada vista. |
| `MV_RENDIMIENTO_POR_DOCENTE.sql` | Vista por docente, con su índice. |
| `MV_PROMEDIO_ASIGNATURAS.sql` | Vista por asignatura y grado, con su índice. |
| `MV_ASISTENCIA_ESTUDIANTES.sql` | Vista de asistencia por estudiante, con su índice. |
| `MV_ALERTA_RIESGO.sql` | Vista de estudiantes que necesitan apoyo, con su índice. |
| `MV_PROGRESO_ACADEMICO.sql` | Vista de progreso de un año al siguiente, con su índice. |
| `REFRESCO.sql` | Procedimiento `PR_REFRESCAR_VISTAS_DM` y job diario `JOB_REFRESCAR_VISTAS_DM`. |

Cada archivo de vista se puede correr solo: si la vista ya existe, la borra y la vuelve a crear. No se pierde nada, porque las vistas no guardan datos propios; se calculan desde los hechos.

## Qué muestra cada vista

| Vista | Grano | Para qué sirve |
|---|---|---|
| `MV_RENDIMIENTO_POR_DOCENTE` | docente + asignatura + año + período | Promedio, % aprobados y reprobados, asistencia, estudiantes en riesgo y ranking del docente entre los de su misma asignatura |
| `MV_PROMEDIO_ASIGNATURAS` | asignatura + grado + año + período | Promedio, mediana, mínimo, máximo, desviación estándar y aprobación |
| `MV_ASISTENCIA_ESTUDIANTES` | estudiante (NIE) + curso + año + período | Sesiones, presencias, inasistencias, sesiones sin captura y alerta si la asistencia es menor a 75 % |
| `MV_ALERTA_RIESGO` | estudiante + curso + año + período | Solo quienes necesitan apoyo. **ALTO:** promedio < 60 y asistencia < 75 %. **MEDIO:** una de las dos. **BAJO:** 2 o más asignaturas reprobadas |
| `MV_PROGRESO_ACADEMICO` | estudiante + asignatura + año | Promedio anual contra el del año anterior (`LAG`); tendencia MEJORA, BAJA, ESTABLE o SIN COMPARACION |

**Estrategia de refresco:** `BUILD IMMEDIATE` y `REFRESH COMPLETE ON DEMAND`. El modelo se carga por lotes y las vistas usan `RANK`, `LAG` y `MEDIAN`, que no admiten refresco rápido. Al terminar, el `03` llama a `PR_REFRESCAR_VISTAS_DM` (`DBMS_MVIEW.REFRESH`, método `C`, `atomic_refresh => FALSE`). Además, `JOB_REFRESCAR_VISTAS_DM` (`DBMS_SCHEDULER`) las refresca todos los días a las 02:00 como respaldo.

Para refrescarlas a mano: `EXEC pr_refrescar_vistas_dm;`
