-- =====================================================================
-- Data_Mart/06_ERRORES_SEMBRADOS.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- Demuestra que el ETL detecta y registra errores reales.
--
-- El staging del equipo no se puede editar: cada fila pertenece a una carga, y los triggers
-- trg_stg_*_inmutable solo aceptan filas de una carga EN_PROCESO y bloquean UPDATE y DELETE.
-- Por eso este script simula la llegada de una carga nueva con errores, como pasaria en la
-- realidad:
--   1. Abre una carga nueva en auditoria_etl_evaluaciones (EN_PROCESO).
--   2. Copia en ella la ultima carga COMPLETADA (todas las tablas STG_*).
--   3. Siembra 17 filas con errores en calificaciones, asistencias, inscripciones,
--      estudiantes y cursos (ids 99000000xx, faciles de reconocer).
--   4. Cierra la carga como COMPLETADA y ejecuta el ETL (03).
-- Resultado esperado: el ETL rechaza las 17 filas, las guarda en errores_etl_evaluaciones con
-- su fila original en JSON, y el modelo estrella queda igual (306,464 hechos).
--
-- Re-ejecutable: si la ultima carga ya tiene los errores sembrados, no copia ni siembra de
-- nuevo; solo vuelve a ejecutar el ETL.
-- Tarda varios minutos: copia ~4.1 millones de filas de staging.
-- Ejecutar como el usuario del proyecto:
--   @06_ERRORES_SEMBRADOS.sql  (desde la carpeta Data_Mart)
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- ==============================================================
-- SECCIÓN 1: CARGA NUEVA CON ERRORES SEMBRADOS
-- Descripción: Abre una carga, copia la última carga completa y le agrega 17 filas con errores conocidos.
-- ==============================================================
DECLARE
  v_src     NUMBER;
  v_new     NUMBER;
  v_ts      TIMESTAMP(6);
  v_cols    VARCHAR2(4000);
  v_copiadas NUMBER := 0;
  v_sembradas NUMBER := 0;
  n         NUMBER;

  PROCEDURE sembrar(p_desc VARCHAR2) IS
  BEGIN
    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20151, 'No se pudo sembrar: ' || p_desc);
    END IF;
    v_sembradas := v_sembradas + 1;
    DBMS_OUTPUT.PUT_LINE('  sembrado: ' || p_desc);
  END;
BEGIN
  SELECT id_carga INTO v_src FROM vw_etl_ultima_carga;
  IF v_src IS NULL THEN
    RAISE_APPLICATION_ERROR(-20150, 'No hay ninguna carga de staging COMPLETADA.');
  END IF;

  SELECT COUNT(*) INTO n FROM stg_estudiantes
   WHERE id_ejecucion_carga = v_src AND id_estudiante BETWEEN 9900000001 AND 9900000099;
  IF n > 0 THEN
    DBMS_OUTPUT.PUT_LINE('La carga #' || v_src || ' ya tiene los errores sembrados. Solo se vuelve a ejecutar el ETL.');
    RETURN;
  END IF;

  -- === 1. Abrir la carga nueva ===
  SELECT seq_etl_carga.NEXTVAL INTO v_new FROM dual;
  INSERT INTO auditoria_etl_evaluaciones
    (id_ejecucion, fuente, inicio, fin, estado, total_leidos, insertados, actualizados, rechazados)
  VALUES
    (v_new, 'Data_Mart/06_ERRORES_SEMBRADOS.sql (copia de la carga #' || v_src || ' + 17 errores sembrados)',
     LOCALTIMESTAMP, NULL, 'EN_PROCESO', 0, 0, 0, 0);
  COMMIT;
  v_ts := LOCALTIMESTAMP;

  BEGIN
    -- === 2. Copiar la ultima carga completa ===
    FOR t IN (SELECT c.table_name
                FROM user_tab_columns c
                JOIN user_tables u ON u.table_name = c.table_name
               WHERE c.column_name = 'ID_EJECUCION_CARGA'
                 AND c.table_name LIKE 'STG\_%' ESCAPE '\'
               ORDER BY c.table_name) LOOP
      SELECT LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_id)
        INTO v_cols
        FROM user_tab_columns
       WHERE table_name = t.table_name
         AND column_name NOT IN ('ID_EJECUCION_CARGA', 'FECHA_CARGA');
      EXECUTE IMMEDIATE
        'INSERT INTO ' || t.table_name || ' (' || v_cols || ', id_ejecucion_carga, fecha_carga) '
        || 'SELECT ' || v_cols || ', :1, :2 FROM ' || t.table_name || ' WHERE id_ejecucion_carga = :3'
        USING v_new, v_ts, v_src;
      v_copiadas := v_copiadas + SQL%ROWCOUNT;
      DBMS_OUTPUT.PUT_LINE(RPAD(t.table_name, 28) || LPAD(SQL%ROWCOUNT, 10) || ' filas copiadas');
    END LOOP;

    -- === 3. Sembrar errores ===
    DBMS_OUTPUT.PUT_LINE('Errores sembrados en la carga #' || v_new || ':');

    -- CALIFICACIONES (6)
    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT 9900000001, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           150, NULL, fecha_evaluacion, fecha_registro, fecha_validacion, NULL, NULL, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND nota IS NOT NULL AND tipo_intento = 'ORDINARIA' AND fecha_anulacion IS NULL
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES 9900000001: nota 150 (fuera de rango 0-100)');

    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT 9900000002, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           NULL, NULL, fecha_evaluacion, fecha_registro, fecha_validacion, NULL, NULL, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND nota IS NOT NULL AND tipo_intento = 'ORDINARIA' AND fecha_anulacion IS NULL
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES 9900000002: sin nota ni resultado cualitativo (nulo)');

    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT 9900000003, id_inscripcion, id_ponderacion_periodo, 'EXTRAORDINARIA', numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           nota, NULL, fecha_evaluacion, fecha_registro, fecha_validacion, NULL, NULL, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND nota IS NOT NULL AND tipo_intento = 'ORDINARIA' AND fecha_anulacion IS NULL
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES 9900000003: tipo de intento EXTRAORDINARIA (fuera del dominio)');

    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT 9900000004, 9900000099, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           nota, NULL, fecha_evaluacion, fecha_registro, fecha_validacion, NULL, NULL, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND nota IS NOT NULL AND tipo_intento = 'ORDINARIA' AND fecha_anulacion IS NULL
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES 9900000004: inscripcion 9900000099 inexistente (clave huerfana)');

    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT 9900000005, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           nota, NULL, DATE '2031-03-01', fecha_registro, fecha_validacion, NULL, NULL, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND nota IS NOT NULL AND tipo_intento = 'ORDINARIA' AND fecha_anulacion IS NULL
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES 9900000005: evaluada el 2031-03-01 (fuera de los ciclos)');

    INSERT INTO stg_calificaciones (id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, id_ejecucion_carga, fecha_carga)
    SELECT id_calificacion, id_inscripcion, id_ponderacion_periodo, tipo_intento, numero_intento, version, id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente, id_docente_registra,
           nota, resultado_cualitativo, fecha_evaluacion, fecha_registro, fecha_validacion, fecha_anulacion, motivo_anulacion, v_new, LOCALTIMESTAMP
      FROM stg_calificaciones
     WHERE id_ejecucion_carga = v_new AND id_calificacion < 9900000000
     ORDER BY id_calificacion
     FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CALIFICACIONES: la primera calificacion llega dos veces (duplicado)');

    -- ASISTENCIAS (3)
    INSERT INTO stg_asistencias (id_asistencia, id_inscripcion, id_sesion, estado, hora_llegada, fecha_registro, observaciones, id_ejecucion_carga, fecha_carga)
    SELECT 9900000011, id_inscripcion, id_sesion, 'PRESENT', hora_llegada, fecha_registro, 'Error sembrado', v_new, LOCALTIMESTAMP
      FROM stg_asistencias WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ASISTENCIAS 9900000011: estado PRESENT (fuera del dominio)');

    INSERT INTO stg_asistencias (id_asistencia, id_inscripcion, id_sesion, estado, hora_llegada, fecha_registro, observaciones, id_ejecucion_carga, fecha_carga)
    SELECT 9900000012, id_inscripcion, 9900000099, estado, hora_llegada, fecha_registro, 'Error sembrado', v_new, LOCALTIMESTAMP
      FROM stg_asistencias WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ASISTENCIAS 9900000012: sesion 9900000099 inexistente (clave huerfana)');

    INSERT INTO stg_asistencias (id_asistencia, id_inscripcion, id_sesion, estado, hora_llegada, fecha_registro, observaciones, id_ejecucion_carga, fecha_carga)
    SELECT id_asistencia, id_inscripcion, id_sesion, estado, hora_llegada, fecha_registro, observaciones, v_new, LOCALTIMESTAMP
      FROM stg_asistencias WHERE id_ejecucion_carga = v_new AND id_asistencia < 9900000000
     ORDER BY id_asistencia FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ASISTENCIAS: la primera asistencia llega dos veces (duplicado)');

    -- INSCRIPCIONES (3)
    INSERT INTO stg_inscripciones (id_inscripcion, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, estado, motivo_fin_inscripcion, resultado_cierre, id_ejecucion_carga, fecha_carga)
    SELECT 9900000021, 9900000099, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, estado, motivo_fin_inscripcion, resultado_cierre, v_new, LOCALTIMESTAMP
      FROM stg_inscripciones WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_INSCRIPCIONES 9900000021: estudiante 9900000099 inexistente (clave huerfana)');

    INSERT INTO stg_inscripciones (id_inscripcion, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, estado, motivo_fin_inscripcion, resultado_cierre, id_ejecucion_carga, fecha_carga)
    SELECT 9900000022, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_inicio - 30, estado, motivo_fin_inscripcion, resultado_cierre, v_new, LOCALTIMESTAMP
      FROM stg_inscripciones WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_INSCRIPCIONES 9900000022: termina 30 dias antes de empezar (fecha invalida)');

    INSERT INTO stg_inscripciones (id_inscripcion, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, estado, motivo_fin_inscripcion, resultado_cierre, id_ejecucion_carga, fecha_carga)
    SELECT 9900000023, id_estudiante, id_curso, fecha_inscripcion, fecha_inicio, fecha_fin, 'ACTIVA', motivo_fin_inscripcion, resultado_cierre, v_new, LOCALTIMESTAMP
      FROM stg_inscripciones WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_INSCRIPCIONES 9900000023: estado ACTIVA (fuera del dominio)');

    -- ESTUDIANTES (3)
    INSERT INTO stg_estudiantes (id_estudiante, id_persona, nie, fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, sexo, id_ejecucion_carga, fecha_carga)
    SELECT 9900000031, id_persona, nie, fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, sexo, v_new, LOCALTIMESTAMP
      FROM stg_estudiantes WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ESTUDIANTES 9900000031: NIE que ya pertenece a otro estudiante');

    INSERT INTO stg_estudiantes (id_estudiante, id_persona, nie, fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, sexo, id_ejecucion_carga, fecha_carga)
    SELECT 9900000032, id_persona, 'SEMB-0000032', fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, 'X', v_new, LOCALTIMESTAMP
      FROM stg_estudiantes WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ESTUDIANTES 9900000032: sexo X (fuera del dominio M/F/OTRO)');

    INSERT INTO stg_estudiantes (id_estudiante, id_persona, nie, fecha_registro_estudiante, estudiante_activo, fecha_nacimiento, sexo, id_ejecucion_carga, fecha_carga)
    SELECT 9900000033, id_persona, 'SEMB-0000033', fecha_registro_estudiante, estudiante_activo, TRUNC(SYSDATE) + 365, sexo, v_new, LOCALTIMESTAMP
      FROM stg_estudiantes WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_ESTUDIANTES 9900000033: fecha de nacimiento en el futuro');

    -- CURSOS (2)
    INSERT INTO stg_cursos (id_curso, id_institucion, id_ciclo, id_grado, id_jornada, id_modalidad, codigo, nombre, seccion, capacidad_maxima, estado, id_ejecucion_carga, fecha_carga)
    SELECT 9900000041, id_institucion, id_ciclo, id_grado, id_jornada, 99, 'SEMB-41', 'Curso con modalidad inexistente', seccion, capacidad_maxima, estado, v_new, LOCALTIMESTAMP
      FROM stg_cursos WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CURSOS 9900000041: modalidad de entrega 99 inexistente');

    INSERT INTO stg_cursos (id_curso, id_institucion, id_ciclo, id_grado, id_jornada, id_modalidad, codigo, nombre, seccion, capacidad_maxima, estado, id_ejecucion_carga, fecha_carga)
    SELECT 9900000042, id_institucion, id_ciclo, 99, id_jornada, id_modalidad, 'SEMB-42', 'Curso con grado inexistente', seccion, capacidad_maxima, estado, v_new, LOCALTIMESTAMP
      FROM stg_cursos WHERE id_ejecucion_carga = v_new FETCH FIRST 1 ROW ONLY;
    sembrar('STG_CURSOS 9900000042: grado 99 inexistente (clave huerfana)');

    -- === 4. Cerrar la carga ===
    UPDATE auditoria_etl_evaluaciones
       SET estado = 'COMPLETADA', fin = LOCALTIMESTAMP,
           insertados = v_copiadas + v_sembradas, actualizados = 0, rechazados = 0,
           total_leidos = v_copiadas + v_sembradas
     WHERE id_ejecucion = v_new;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga #' || v_new || ' COMPLETADA: ' || v_copiadas || ' filas copiadas de la carga #'
                         || v_src || ' + ' || v_sembradas || ' errores sembrados.');
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      UPDATE auditoria_etl_evaluaciones SET estado = 'ERROR', fin = LOCALTIMESTAMP WHERE id_ejecucion = v_new;
      COMMIT;
      RAISE;
  END;
END;
/

-- ==============================================================
-- SECCIÓN 2: ETL Y RESULTADOS
-- Descripción: Ejecuta el 03 sobre la carga con errores y muestra lo que detectó y registró.
-- ==============================================================

PROMPT ==== Ejecutando el ETL sobre la carga con errores sembrados
@@03_ETL_CARGA_ESTRELLA.sql

PROMPT ==== Errores detectados en la ultima ejecucion del ETL (con la fila original en JSON)
COLUMN entidad FORMAT A22
COLUMN clave_origen FORMAT A12
COLUMN tipo_error FORMAT A26
COLUMN detalle FORMAT A52
COLUMN fila_original FORMAT A120
SELECT e.entidad, e.clave_origen, e.tipo_error, e.detalle,
       DBMS_LOB.SUBSTR(e.json_original, 120, 1) AS fila_original
  FROM errores_etl_evaluaciones e
 WHERE e.id_ejecucion = (SELECT MAX(id_ejecucion) FROM auditoria_etl_evaluaciones
                          WHERE fuente LIKE 'Data_Mart/03%' AND estado = 'COMPLETADA')
 ORDER BY e.entidad, e.clave_origen;

PROMPT ==== Ultimas ejecuciones registradas en la auditoria
COLUMN fuente FORMAT A70
SELECT id_ejecucion, fuente, estado, total_leidos, insertados, actualizados, rechazados
  FROM auditoria_etl_evaluaciones
 ORDER BY id_ejecucion DESC
 FETCH FIRST 4 ROWS ONLY;
