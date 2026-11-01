# Expediente académico en JSON

El proyecto genera un expediente JSON por cada estudiante y cada año escolar cerrado. Lo produce `Data_Mart/05_EXPEDIENTE_JSON.sql`, que el script maestro ejecuta en su paso 12. Los expedientes quedan guardados en la tabla `EXPEDIENTE_ACADEMICO`.

Esta carpeta tiene ejemplos reales de esa salida:

| Archivo | De dónde sale |
|---|---|
| `expediente_ejemplo_ficticios.json` | Ana López, 8.º grado, 2024, con los datos de ejemplo (modo ficticios). |
| `expediente_ejemplo_masiva.json` | Óscar Guzmán, 2.º de bachillerato (ciclo de 4 períodos), 2025, de la carga masiva: 8 materias, una reprobada. Los nombres son sintéticos. |

## Qué contiene

| Campo | Contenido |
|---|---|
| `id_expediente` | `EX-{ciclo}-{estudiante}-{versión}`; por ejemplo, `EX-NAC-2025-1010014-001`. |
| `estudiante` | Id, NIE, nombre, edad al cierre, sexo, colegio, tipo de colegio, zona, departamento y modalidad. |
| `ciclo_academico` | Ciclo, año, grado, sección y fechas de inicio y fin. |
| `asignaturas` | Cada materia con su docente, promedio final, % de asistencia y estatus (APROBADA, REPROBADA, el resultado cualitativo o SIN NOTA). |
| `promedio_general` | Promedio de las materias numéricas. |
| `riesgo_academico` | `true` si el estudiante quedó en riesgo (promedio < 60 y asistencia < 75 %). |
| `firma_digital` | Huella SHA256 del documento sin la firma. |

## La firma

La firma es el SHA256 del mismo documento sin el campo `firma_digital`. Si alguien cambia cualquier dato, como una nota o un nombre, la firma deja de coincidir. Para comprobar todas las firmas, conectado al mismo usuario:

```sql
SELECT COUNT(*) AS expedientes,
       SUM(CASE WHEN LOWER(RAWTOHEX(STANDARD_HASH(
                       SUBSTR(documento, 1, INSTR(documento, ',"firma_digital":') - 1) || '}',
                       'SHA256'))) = firma_digital THEN 1 ELSE 0 END) AS firmas_validas
  FROM expediente_academico;
```

Las dos columnas deben dar el mismo número. La huella demuestra que el documento no cambió, pero no identifica a quien lo firmó: no es una firma electrónica certificada.

## Versiones

- Un expediente emitido no se puede modificar ni borrar: lo impide el trigger `TRG_EXPEDIENTE_INMUTABLE`.
- Si después cambia la información (por ejemplo, se corrige una nota), al volver a correr `05_EXPEDIENTE_JSON.sql` se emite una versión nueva (`-002`) y la anterior se conserva.
- Si nada cambió, no se emite nada nuevo.

Para sacar un expediente en formato legible:

```sql
SELECT JSON_SERIALIZE(documento RETURNING CLOB PRETTY)
  FROM expediente_academico
 WHERE id_expediente = 'EX-C-2024-1001-001';
```
