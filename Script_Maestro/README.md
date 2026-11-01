# Cómo instalar todo con el script maestro

`INSTALACION_COMPLETA.sql` crea la base completa en un solo paso: tablas, datos, staging, validaciones, pruebas, el data mart para Power BI, las vistas materializadas y los expedientes JSON. Si algo falla, se detiene en ese punto y te dice por qué.

Hay dos modos:

- **ficticios**: pocos datos de ejemplo y pruebas con resultados conocidos.
- **masiva**: 42 colegios, 2 años, unos 4 millones de filas. Es la que usa el dashboard.

## Configuración de cada equipo

Ningún script trae datos de conexión: cada quien usa los de su equipo. En las instrucciones de abajo aparecen entre `< >`:

| Dato | Qué es | Ejemplo |
|---|---|---|
| `<host>` y `<puerto>` | Dónde escucha Oracle. | `localhost` y `1521` |
| `<servicio>` | La base (PDB) donde se instala. | `FREEPDB1` en Oracle 23ai Free; `XEPDB1` en 21c XE |
| `<usuario>` y `<clave>` | El usuario del proyecto, que se crea abajo. | `educacion` |
| `ORACLE_CONN` | Variable de entorno con la conexión completa, para la carga masiva: `<usuario>/<clave>@//<host>:<puerto>/<servicio>`. | |
| `IC` | Solo en Windows: carpeta del Instant Client que contiene `sqlldr.exe`. Si no está definida, `cargar.bat` la pregunta. | |

La conexión de Power BI se configura aparte, al abrir el `.pbix` (ver `Dashboard/README.md`).

## Antes de empezar

1. **Oracle 23ai** en marcha. También funciona en 19c y 21c.
2. **SQLcl** (comando `sql`) o **SQL*Plus**. SQL Developer sirve para el modo ficticios. Para el modo masiva en Windows, ver "Modo masiva desde Windows".
3. **Un usuario vacío.** El script se niega a instalar sobre tablas que ya existen. Como administrador (por ejemplo `system`), conectado a `<servicio>`:

   ```sql
   CREATE USER <usuario> IDENTIFIED BY "<clave>" QUOTA UNLIMITED ON users;
   GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE,
         CREATE PROCEDURE, CREATE TRIGGER, CREATE TYPE, CREATE JOB,
         CREATE MATERIALIZED VIEW TO <usuario>;
   ```

Solo para el modo masiva:

4. **SQL*Loader** (comando `sqlldr`). Viene en el paquete *Instant Client Tools* de Oracle.
5. **Los CSV.** No están en el repositorio por su tamaño (unos 320 MB). Se generan una vez con Python 3:

   ```
   python ../Pruebas/scripts/generar_carga_masiva.py
   ```

6. **Redo logs grandes (recomendado).** Oracle anota cada cambio en sus *redo logs* antes de guardarlo. Si son chicos, como los de fábrica (20 MB), la carga masiva se vuelve varias veces más lenta. No cambia el resultado, solo el tiempo. Un administrador los agranda en la base principal (el contenedor raíz, no en `<servicio>`):

   ```sql
   -- <carpeta>: la de los redo logs actuales (SELECT member FROM v$logfile;)
   ALTER DATABASE ADD LOGFILE GROUP 3 ('<carpeta>/redo03.log') SIZE 512M;
   ALTER DATABASE ADD LOGFILE GROUP 4 ('<carpeta>/redo04.log') SIZE 512M;
   ALTER DATABASE ADD LOGFILE GROUP 5 ('<carpeta>/redo05.log') SIZE 512M;
   ```

## Modo ficticios

Abre una terminal **en esta carpeta** (`Script_Maestro`) y ejecuta:

```
sql <usuario>/<clave>@//<host>:<puerto>/<servicio> @INSTALACION_COMPLETA.sql ficticios
```

## Modo masiva

Abre una terminal **en esta carpeta** (`Script_Maestro`):

```
export ORACLE_CONN=<usuario>/<clave>@//<host>:<puerto>/<servicio>
sql $ORACLE_CONN @INSTALACION_COMPLETA.sql masiva
```

### Modo masiva desde Windows

`INSTALACION_COMPLETA.sql` usa un script de Linux/macOS (`cargar.sh`) para la carga. En Windows, la instalación se hace en tres partes:

1. En SQL Developer o SQLcl, conectado como `<usuario>`: `@MASIVA_1_ESTRUCTURA.sql` (crea las tablas y revisa que la base esté lista).
2. Doble clic en `carga_masiva\cargar.bat`. Pide la conexión y la carpeta del Instant Client, o las toma de las variables `ORACLE_CONN` e `IC`, y carga los CSV con SQL*Loader.
3. De nuevo en SQL Developer o SQLcl: `@MASIVA_2_STAGING_Y_ESTRELLA.sql` (staging, validaciones, data mart, vistas materializadas y expedientes).

## Qué hace, paso a paso

| Paso | Qué hace |
|---|---|
| 1 | Crea las 33 tablas de operación (`General/SCRIPT_BASE.sql`). |
| 2 | Carga los datos: ficticios o masiva. |
| 3 | Crea las 29 tablas de staging. |
| 4 | Instala las validaciones y revisa con ellas todos los datos. |
| 5 | Copia la operación a staging. |
| 6 | Diagnóstico: revisa todas las reglas otra vez. |
| 7 | Pruebas con resultados conocidos (solo modo ficticios). |
| 8 a 10 | Data mart: calendario, modelo estrella y carga de los hechos. |
| 11 | Vistas materializadas (`Vistas_Materializadas/INSTALAR_VISTAS.sql`). |
| 12 | Expedientes académicos JSON firmados. |

## ¿Salió bien?

La última línea debe decir **`Instalación completa terminada.`** Todo lo que pasó queda en `instalacion_ficticios.log` o `instalacion_masiva.log`, en esta carpeta.

Para mirar los datos, conéctate con el mismo usuario y prueba:

```sql
SELECT table_name, num_rows FROM user_tables ORDER BY num_rows DESC NULLS LAST;
SELECT id_ejecucion, fuente, estado, rechazados FROM auditoria_etl_evaluaciones ORDER BY id_ejecucion;
SELECT COUNT(*) FROM hechos_resultados;
SELECT COUNT(*) FROM expediente_academico;
```

Las ejecuciones deben aparecer `COMPLETADA`, con 0 rechazados.

## Si algo falla

El script se detiene en el primer error. Para reintentar, borra el usuario, créalo de nuevo y vuelve a ejecutar el script.

| Mensaje | Qué hacer |
|---|---|
| `ORA-20091` (faltan permisos) | Dale al usuario los permisos que lista el mensaje (ver "Antes de empezar"). |
| `ORA-20070` (ya existen tablas) | El usuario no está vacío. Usa uno nuevo. |
| `ORA-01940` al borrar el usuario | Hay una sesión abierta con ese usuario (por ejemplo, en SQL Developer). Ciérrala. |
| `ORA-12541` (no hay listener) | Oracle está apagado. Arráncalo; si está en Docker: `sudo docker start <contenedor>`. |
| La carga masiva va muy lenta | Agranda los redo logs (ver "Antes de empezar"). |
| Falla en el paso 2 del modo masiva | Revisa que existan los CSV en `carga_masiva/datos/`, que `sqlldr` funcione y que `ORACLE_CONN` esté definida. |

## Qué hay en esta carpeta

| Archivo | Qué hace |
|---|---|
| `comprobar_permisos.sql` | Lo primero que corre el maestro: revisa que el usuario tenga todos los permisos y, si falta alguno, dice cuál. |
| `INSTALACION_COMPLETA.sql` | El script maestro (12 pasos). Usa también los archivos de `General`, `Staging`, `Validacion`, `Pruebas`, `Data_Mart` y `Vistas_Materializadas`. |
| `MASIVA_1_ESTRUCTURA.sql`, `MASIVA_2_STAGING_Y_ESTRELLA.sql` | El modo masiva desde Windows, en dos partes, antes y después de `cargar.bat`. |
| `datos_ficticios/DATOS_FICTICIOS.sql` | Carga los datos de ejemplo (modo ficticios). |
| `carga_masiva/carga_masiva.sql` | Carga del modo masiva: une `pre_carga.sql`, `cargar.sh` y `post_carga.sql`. |
| `carga_masiva/pre_carga.sql` | Revisa que la base esté vacía antes de cargar. |
| `carga_masiva/cargar.sh`, `carga_masiva/cargar.bat` | Cargan los CSV con SQL*Loader (Linux/macOS y Windows). |
| `carga_masiva/post_carga.sql` | Revisa los conteos y calcula estadísticas después de cargar. |
| `carga_masiva/conteos.json` | Filas esperadas por tabla. |
| `carga_masiva/ctl/` | Instrucciones de SQL*Loader, una por tabla. |
| `carga_masiva/datos/` | Los CSV. No están en git; se generan con `python ../Pruebas/scripts/generar_carga_masiva.py`. |
| `pruebas_ficticios.sql`, `pruebas_masiva.sql` | Pruebas del paso 7 de cada modo. |
