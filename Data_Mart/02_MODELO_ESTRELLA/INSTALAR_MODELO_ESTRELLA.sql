-- ==============================================================
-- Data_Mart/02_MODELO_ESTRELLA/INSTALAR_MODELO_ESTRELLA.sql
-- Descripción: Estructura del data mart sobre el staging. Ejecuta los archivos 01 a 07 de esta carpeta:
--   vistas de lectura y de validación, tablas de trabajo, transformación, 5 dimensiones,
--   HECHOS_RESULTADOS y triggers de auditoría. DIM_TIEMPO viene de 01_CALENDARIO.sql.
-- Grano de HECHOS_RESULTADOS: un resultado oficial por estudiante, materia y período.
-- Requiere: staging creado (script maestro) y Data_Mart/01_CALENDARIO.sql.
-- Re-ejecutable: dimensiones y hechos se crean solo si no existen y no se borran; las vistas
--   se reemplazan y las tablas de trabajo se vuelven a crear vacías. Después, ejecutar el 03.
-- Desde la carpeta Data_Mart: @02_MODELO_ESTRELLA/INSTALAR_MODELO_ESTRELLA.sql
-- ==============================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- === Requisitos: staging, secuencias del ETL y DIM_TIEMPO ===
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name IN ('STG_CALIFICACIONES', 'STG_DOCENTES', 'STG_ZONAS', 'STG_AREAS_CONOCIMIENTO');
  IF n <> 4 THEN
    RAISE_APPLICATION_ERROR(-20110, 'Falta el staging del equipo: ejecute primero el script maestro (INSTALACION_COMPLETA.sql).');
  END IF;
  SELECT COUNT(*) INTO n FROM user_sequences WHERE sequence_name IN ('SEQ_ETL_CARGA', 'SEQ_ETL_ERROR');
  IF n <> 2 THEN
    RAISE_APPLICATION_ERROR(-20111, 'Faltan SEQ_ETL_CARGA / SEQ_ETL_ERROR (se crean con Staging/CREACION_STAGING.sql).');
  END IF;
END;
/

DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'DIM_TIEMPO';
  IF n <> 1 THEN
    RAISE_APPLICATION_ERROR(-20112, 'Falta DIM_TIEMPO: ejecute primero 01_CALENDARIO.sql');
  END IF;
END;
/

PROMPT 1/7 Vistas de lectura del staging...
@@01_VISTAS_LECTURA.sql
PROMPT 2/7 Vistas de validación...
@@02_VISTAS_VALIDACION.sql
PROMPT 3/7 Tablas de trabajo del ETL...
@@03_TABLAS_TRABAJO.sql
PROMPT 4/7 Transformación...
@@04_TRANSFORMACION.sql
PROMPT 5/7 Dimensiones...
@@05_DIMENSIONES.sql
PROMPT 6/7 Tabla de hechos...
@@06_HECHOS.sql
PROMPT 7/7 Triggers de auditoría...
@@07_TRIGGERS_AUDITORIA.sql

-- === Verificación: objetos creados y su estado ===
SELECT object_type, object_name, status
  FROM user_objects
 WHERE object_name IN ('DIM_ESTUDIANTE', 'DIM_DOCENTE', 'DIM_ASIGNATURA', 'DIM_MODALIDAD', 'DIM_CURSO',
                       'DIM_TIEMPO', 'HECHOS_RESULTADOS', 'VW_ETL_ULTIMA_CARGA',
                       'VW_ETL_VAL_ESTUDIANTES', 'VW_ETL_VAL_CURSOS', 'VW_ETL_VAL_INSCRIPCIONES',
                       'VW_ETL_VAL_CALIFICACIONES', 'VW_ETL_VAL_ASISTENCIAS', 'VW_ETL_HECHOS_RESULTADOS',
                       'TRG_HECHOS_AUDITORIA', 'TRG_ERRORES_ETL_AUDITORIA')
    OR object_name LIKE 'VW\_ETL\_STG\_%' ESCAPE '\'
 ORDER BY object_type, object_name;
