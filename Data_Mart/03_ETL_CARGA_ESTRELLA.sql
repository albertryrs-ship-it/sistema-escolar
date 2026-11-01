-- =====================================================================
-- Data_Mart/03_ETL_CARGA_ESTRELLA.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- ETL de staging (ultima carga COMPLETADA) al modelo estrella:
--   0. Prepara tablas de trabajo (filas validas y transformacion) con estadisticas
--   1. Abre una ejecucion en auditoria_etl_evaluaciones (SEQ_ETL_CARGA)
--   2. Validacion: filas invalidas -> errores_etl_evaluaciones (entidad 'DM:...', SEQ_ETL_ERROR)
--   3. Dimensiones (MERGE)  4. Hechos (MERGE por id_resultado_origen, no duplica)
--   5. Cierra la ejecucion; los triggers cuentan insertados, actualizados y rechazados.
-- Requiere: script maestro, 01 y 02. Re-ejecutable; cada corrida es una ejecucion nueva.
-- Despues de cada EXEC pr_cargar_staging; vuelva a ejecutar este script.
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- ==============================================================
-- SECCIÓN 0: REQUISITOS
-- Descripción: Staging, secuencias del ETL y modelo estrella (02) ya instalados.
-- ==============================================================
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

-- ==============================================================
-- SECCIÓN 1: PREPARACIÓN
-- Descripción: Calcula una sola vez las filas válidas y la transformación, y las guarda en las tablas de
--   trabajo WK_ETL_* con estadísticas. Así el MERGE de hechos no recalcula las validaciones.
-- ==============================================================
PROMPT Preparando tablas de trabajo del ETL (inscripciones, calificaciones, asistencias, hechos)...
DECLARE
  PROCEDURE stats(p_tabla VARCHAR2) IS
  BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, p_tabla, no_invalidate => FALSE);
  END;
BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_ins';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_cal';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_asi';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_ses_raw';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_pp';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_ad';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_ca';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_ses';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_asist';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE wk_etl_hechos';

  INSERT /*+ APPEND */ INTO wk_etl_ins
  SELECT * FROM vw_etl_val_inscripciones WHERE motivo_rechazo IS NULL;
  DBMS_OUTPUT.PUT_LINE('Inscripciones validas: ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_INS');

  INSERT /*+ APPEND */ INTO wk_etl_cal
  SELECT * FROM vw_etl_val_calificaciones WHERE motivo_rechazo IS NULL;
  DBMS_OUTPUT.PUT_LINE('Calificaciones validas: ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_CAL');

  INSERT /*+ APPEND */ INTO wk_etl_asi
  SELECT id_asistencia, id_inscripcion, id_sesion, estado
    FROM vw_etl_val_asistencias WHERE motivo_rechazo IS NULL;
  DBMS_OUTPUT.PUT_LINE('Asistencias validas: ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_ASI');

  INSERT /*+ APPEND */ INTO wk_etl_ses_raw
  SELECT id_sesion, id_ponderacion_periodo, fecha_academica
    FROM vw_etl_stg_sesiones WHERE estado = 'IMPARTIDA';
  COMMIT;
  stats('WK_ETL_SES_RAW');

  INSERT /*+ APPEND */ INTO wk_etl_pp
  SELECT id_ponderacion_periodo, id_curso_asignatura, id_periodo, peso FROM vw_etl_stg_ponderaciones;
  COMMIT;
  stats('WK_ETL_PP');

  INSERT /*+ APPEND */ INTO wk_etl_ad
  SELECT id_asignacion, id_docente FROM vw_etl_stg_asignaciones_docentes;
  COMMIT;
  stats('WK_ETL_AD');

  INSERT /*+ APPEND */ INTO wk_etl_ca
  SELECT id_curso_asignatura, id_curso FROM vw_etl_stg_cursos_asignaturas;
  COMMIT;
  stats('WK_ETL_CA');

  INSERT /*+ APPEND */ INTO wk_etl_ses
  SELECT * FROM vw_etl_ses_calc;
  DBMS_OUTPUT.PUT_LINE('Sesiones impartidas: ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_SES');

  INSERT /*+ APPEND */ INTO wk_etl_asist
  SELECT * FROM vw_etl_asist_calc;
  DBMS_OUTPUT.PUT_LINE('Asistencia calculada (inscripcion x ponderacion): ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_ASIST');

  INSERT /*+ APPEND */ INTO wk_etl_hechos
  SELECT * FROM vw_etl_hechos_resultados;
  DBMS_OUTPUT.PUT_LINE('Resultados transformados: ' || SQL%ROWCOUNT);
  COMMIT;
  stats('WK_ETL_HECHOS');
END;
/

-- ==============================================================
-- SECCIÓN 2: CARGA AL MODELO ESTRELLA
-- Descripción: Una ejecución en auditoria_etl_evaluaciones: valida, carga dimensiones y hechos con MERGE
--   y la cierra. Los triggers cuentan insertados, actualizados y rechazados.
-- ==============================================================
DECLARE
  v_ejec  NUMBER;
  v_total NUMBER;
  v_carga NUMBER;
BEGIN
  SELECT id_carga INTO v_carga FROM vw_etl_ultima_carga;
  IF v_carga IS NULL THEN
    RAISE_APPLICATION_ERROR(-20113, 'No hay ninguna carga de staging COMPLETADA: ejecute EXEC pr_cargar_staging;');
  END IF;

  -- === 1. Abrir la ejecucion ===
  SELECT (SELECT COUNT(*) FROM vw_etl_stg_calificaciones) + (SELECT COUNT(*) FROM vw_etl_stg_asistencias)
       + (SELECT COUNT(*) FROM vw_etl_stg_inscripciones)  + (SELECT COUNT(*) FROM vw_etl_stg_estudiantes)
       + (SELECT COUNT(*) FROM vw_etl_stg_cursos)
    INTO v_total FROM dual;
  SELECT seq_etl_carga.NEXTVAL INTO v_ejec FROM dual;
  INSERT INTO auditoria_etl_evaluaciones
    (id_ejecucion, fuente, inicio, fin, estado, total_leidos, insertados, actualizados, rechazados)
  VALUES
    (v_ejec, 'Data_Mart/03_ETL_CARGA_ESTRELLA.sql (staging #' || v_carga || ' -> modelo estrella)',
     LOCALTIMESTAMP, NULL, 'EN_PROCESO', 0, 0, 0, 0);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Ejecucion ETL #' || v_ejec || ' sobre la carga de staging #' || v_carga
                       || ' - filas de staging revisadas: ' || v_total);

  BEGIN
    -- === 2. Validacion ===
    INSERT INTO errores_etl_evaluaciones
      (id_error, id_ejecucion, entidad, clave_origen, tipo_error, detalle, json_original, fecha_registro)
    SELECT seq_etl_error.NEXTVAL, v_ejec, 'DM:STG_CALIFICACIONES', TO_CHAR(v.id_calificacion), v.motivo_rechazo, v.detalle,
           JSON_OBJECT('id_calificacion' VALUE v.id_calificacion,
                       'id_inscripcion' VALUE v.id_inscripcion,
                       'id_ponderacion_periodo' VALUE v.id_ponderacion_periodo,
                       'tipo_intento' VALUE v.tipo_intento,
                       'numero_intento' VALUE v.numero_intento,
                       'version' VALUE v.version,
                       'id_calificacion_ordinaria' VALUE v.id_calificacion_ordinaria,
                       'id_calificacion_sustituida' VALUE v.id_calificacion_sustituida,
                       'id_asignacion_docente' VALUE v.id_asignacion_docente,
                       'id_docente_registra' VALUE v.id_docente_registra,
                       'nota' VALUE v.nota,
                       'resultado_cualitativo' VALUE v.resultado_cualitativo,
                       'fecha_evaluacion' VALUE v.fecha_evaluacion,
                       'fecha_registro' VALUE v.fecha_registro,
                       'fecha_validacion' VALUE v.fecha_validacion,
                       'fecha_anulacion' VALUE v.fecha_anulacion,
                       'motivo_anulacion' VALUE v.motivo_anulacion
                       RETURNING CLOB),
           LOCALTIMESTAMP
      FROM vw_etl_val_calificaciones v
     WHERE v.motivo_rechazo IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('Rechazados en STG_CALIFICACIONES: ' || SQL%ROWCOUNT);

    INSERT INTO errores_etl_evaluaciones
      (id_error, id_ejecucion, entidad, clave_origen, tipo_error, detalle, json_original, fecha_registro)
    SELECT seq_etl_error.NEXTVAL, v_ejec, 'DM:STG_ASISTENCIAS', TO_CHAR(v.id_asistencia), v.motivo_rechazo, v.detalle,
           JSON_OBJECT('id_asistencia' VALUE v.id_asistencia,
                       'id_inscripcion' VALUE v.id_inscripcion,
                       'id_sesion' VALUE v.id_sesion,
                       'estado' VALUE v.estado,
                       'hora_llegada' VALUE v.hora_llegada,
                       'fecha_registro' VALUE v.fecha_registro,
                       'observaciones' VALUE v.observaciones
                       RETURNING CLOB),
           LOCALTIMESTAMP
      FROM vw_etl_val_asistencias v
     WHERE v.motivo_rechazo IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('Rechazados en STG_ASISTENCIAS: ' || SQL%ROWCOUNT);

    INSERT INTO errores_etl_evaluaciones
      (id_error, id_ejecucion, entidad, clave_origen, tipo_error, detalle, json_original, fecha_registro)
    SELECT seq_etl_error.NEXTVAL, v_ejec, 'DM:STG_INSCRIPCIONES', TO_CHAR(v.id_inscripcion), v.motivo_rechazo, v.detalle,
           JSON_OBJECT('id_inscripcion' VALUE v.id_inscripcion,
                       'id_estudiante' VALUE v.id_estudiante,
                       'id_curso' VALUE v.id_curso,
                       'fecha_inscripcion' VALUE v.fecha_inscripcion,
                       'fecha_inicio' VALUE v.fecha_inicio,
                       'fecha_fin' VALUE v.fecha_fin,
                       'estado' VALUE v.estado,
                       'motivo_fin_inscripcion' VALUE v.motivo_fin_inscripcion,
                       'resultado_cierre' VALUE v.resultado_cierre
                       RETURNING CLOB),
           LOCALTIMESTAMP
      FROM vw_etl_val_inscripciones v
     WHERE v.motivo_rechazo IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('Rechazados en STG_INSCRIPCIONES: ' || SQL%ROWCOUNT);

    INSERT INTO errores_etl_evaluaciones
      (id_error, id_ejecucion, entidad, clave_origen, tipo_error, detalle, json_original, fecha_registro)
    SELECT seq_etl_error.NEXTVAL, v_ejec, 'DM:STG_ESTUDIANTES', TO_CHAR(v.id_estudiante), v.motivo_rechazo, v.detalle,
           JSON_OBJECT('id_estudiante' VALUE v.id_estudiante,
                       'id_persona' VALUE v.id_persona,
                       'nie' VALUE v.nie,
                       'fecha_registro_estudiante' VALUE v.fecha_registro_estudiante,
                       'estudiante_activo' VALUE v.estudiante_activo,
                       'fecha_nacimiento' VALUE v.fecha_nacimiento,
                       'sexo' VALUE v.sexo
                       RETURNING CLOB),
           LOCALTIMESTAMP
      FROM vw_etl_val_estudiantes v
     WHERE v.motivo_rechazo IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('Rechazados en STG_ESTUDIANTES: ' || SQL%ROWCOUNT);

    INSERT INTO errores_etl_evaluaciones
      (id_error, id_ejecucion, entidad, clave_origen, tipo_error, detalle, json_original, fecha_registro)
    SELECT seq_etl_error.NEXTVAL, v_ejec, 'DM:STG_CURSOS', TO_CHAR(v.id_curso), v.motivo_rechazo, v.detalle,
           JSON_OBJECT('id_curso' VALUE v.id_curso,
                       'id_institucion' VALUE v.id_institucion,
                       'id_ciclo' VALUE v.id_ciclo,
                       'id_grado' VALUE v.id_grado,
                       'id_jornada' VALUE v.id_jornada,
                       'id_modalidad' VALUE v.id_modalidad,
                       'codigo' VALUE v.codigo,
                       'nombre' VALUE v.nombre,
                       'seccion' VALUE v.seccion,
                       'capacidad_maxima' VALUE v.capacidad_maxima,
                       'estado' VALUE v.estado
                       RETURNING CLOB),
           LOCALTIMESTAMP
      FROM vw_etl_val_cursos v
     WHERE v.motivo_rechazo IS NOT NULL;
    DBMS_OUTPUT.PUT_LINE('Rechazados en STG_CURSOS: ' || SQL%ROWCOUNT);

    -- === 3. Dimensiones ===
    MERGE INTO dim_modalidad t
    USING (SELECT id_modalidad, codigo, descripcion FROM vw_etl_stg_modalidades) s
    ON (t.id_modalidad = s.id_modalidad)
    WHEN MATCHED THEN UPDATE SET
      t.tipo_modalidad = s.codigo, t.descripcion = s.descripcion, t.fecha_actualizacion = LOCALTIMESTAMP
    WHEN NOT MATCHED THEN INSERT (id_modalidad, tipo_modalidad, descripcion, fecha_actualizacion)
      VALUES (s.id_modalidad, s.codigo, s.descripcion, LOCALTIMESTAMP);

    MERGE INTO dim_asignatura t
    USING (
      SELECT a.id_asignatura, a.codigo, a.nombre, ar.descripcion AS area, nv.niveles, nv.tipo_resultado
        FROM vw_etl_stg_asignaturas a
        LEFT JOIN vw_etl_stg_areas_conocimiento ar ON ar.id_area = a.id_area
        LEFT JOIN (SELECT x.id_asignatura,
                          LISTAGG(x.nivel, ', ') WITHIN GROUP (ORDER BY x.orden) AS niveles,
                          MAX(x.tipo_resultado) AS tipo_resultado
                     FROM (SELECT DISTINCT ca.id_asignatura, n.nombre AS nivel, n.orden, ca.tipo_resultado
                             FROM vw_etl_stg_cursos_asignaturas ca
                             JOIN vw_etl_stg_cursos c  ON c.id_curso = ca.id_curso
                             JOIN vw_etl_stg_grados g  ON g.id_grado = c.id_grado
                             JOIN vw_etl_stg_niveles n ON n.id_nivel = g.id_nivel) x
                    GROUP BY x.id_asignatura) nv ON nv.id_asignatura = a.id_asignatura
    ) s
    ON (t.id_asignatura = s.id_asignatura)
    WHEN MATCHED THEN UPDATE SET
      t.codigo = s.codigo, t.nombre = s.nombre, t.area_conocimiento = s.area,
      t.nivel = s.niveles, t.tipo_resultado = s.tipo_resultado, t.fecha_actualizacion = LOCALTIMESTAMP
    WHEN NOT MATCHED THEN INSERT
      (id_asignatura, codigo, nombre, area_conocimiento, nivel, tipo_resultado, fecha_actualizacion)
      VALUES (s.id_asignatura, s.codigo, s.nombre, s.area, s.niveles, s.tipo_resultado, LOCALTIMESTAMP);

    MERGE INTO dim_curso t
    USING (
      SELECT c.id_curso, c.codigo, c.nombre, c.seccion, cy.anio, cy.nombre AS ciclo,
             g.nombre AS grado, g.orden AS orden_grado,
             n.nombre AS nivel, j.descripcion AS jornada, m.codigo AS modalidad,
             ins.nombre AS institucion, ins.codigo_institucion, ti.codigo AS tipo_institucion,
             z.nombre AS zona, d.nombre AS departamento,
             CASE WHEN d.codigo LIKE 'SV-__' THEN d.codigo END AS codigo_iso,
             c.capacidad_maxima
        FROM vw_etl_val_cursos c
        JOIN vw_etl_stg_ciclos cy              ON cy.id_ciclo = c.id_ciclo
        JOIN vw_etl_stg_grados g               ON g.id_grado = c.id_grado
        JOIN vw_etl_stg_niveles n              ON n.id_nivel = g.id_nivel
        JOIN vw_etl_stg_jornadas j             ON j.id_jornada = c.id_jornada
        JOIN vw_etl_stg_modalidades m          ON m.id_modalidad = c.id_modalidad
        JOIN vw_etl_stg_instituciones_ciclo ic ON ic.id_institucion = c.id_institucion AND ic.id_ciclo = c.id_ciclo
        JOIN vw_etl_stg_instituciones ins      ON ins.id_institucion = c.id_institucion
        JOIN vw_etl_stg_tipos_institucion ti   ON ti.id_tipo_institucion = ic.id_tipo_institucion
        JOIN vw_etl_stg_zonas z                ON z.id_zona = ic.id_zona
        JOIN vw_etl_stg_departamentos d        ON d.id_departamento = ic.id_departamento
       WHERE c.motivo_rechazo IS NULL
    ) s
    ON (t.id_curso = s.id_curso)
    WHEN MATCHED THEN UPDATE SET
      t.codigo = s.codigo, t.nombre = s.nombre, t.seccion = s.seccion, t.anio = s.anio, t.ciclo = s.ciclo,
      t.grado = s.grado, t.orden_grado = s.orden_grado, t.nivel = s.nivel, t.jornada = s.jornada,
      t.modalidad = s.modalidad, t.institucion = s.institucion, t.codigo_institucion = s.codigo_institucion,
      t.tipo_institucion = s.tipo_institucion, t.zona = s.zona, t.departamento = s.departamento,
      t.codigo_iso = s.codigo_iso, t.capacidad_maxima = s.capacidad_maxima,
      t.fecha_actualizacion = LOCALTIMESTAMP
    WHEN NOT MATCHED THEN INSERT
      (id_curso, codigo, nombre, seccion, anio, ciclo, grado, orden_grado, nivel, jornada, modalidad,
       institucion, codigo_institucion, tipo_institucion, zona, departamento, codigo_iso,
       capacidad_maxima, fecha_actualizacion)
      VALUES (s.id_curso, s.codigo, s.nombre, s.seccion, s.anio, s.ciclo, s.grado, s.orden_grado, s.nivel,
       s.jornada, s.modalidad, s.institucion, s.codigo_institucion, s.tipo_institucion, s.zona,
       s.departamento, s.codigo_iso, s.capacidad_maxima, LOCALTIMESTAMP);

    MERGE INTO dim_docente t
    USING (
      SELECT dc.id_docente,
             dc.primer_nombre || NVL2(dc.segundo_nombre, ' ' || dc.segundo_nombre, '') || ' '
               || dc.primer_apellido || NVL2(dc.segundo_apellido, ' ' || dc.segundo_apellido, '') AS nombre_completo,
             dc.especialidad,
             GREATEST(0, TRUNC(MONTHS_BETWEEN(SYSDATE, CAST(dc.fecha_registro_docente AS DATE)) / 12)) AS anios_experiencia,
             ua.institucion, dc.docente_activo
        FROM vw_etl_stg_docentes dc
        LEFT JOIN (SELECT ad.id_docente, ins.nombre AS institucion,
                          ROW_NUMBER() OVER (PARTITION BY ad.id_docente
                                             ORDER BY ad.fecha_inicio DESC, ad.id_asignacion DESC) AS rn
                     FROM vw_etl_stg_asignaciones_docentes ad
                     JOIN vw_etl_stg_cursos_asignaturas ca ON ca.id_curso_asignatura = ad.id_curso_asignatura
                     JOIN vw_etl_stg_cursos c              ON c.id_curso = ca.id_curso
                     JOIN vw_etl_stg_instituciones ins     ON ins.id_institucion = c.id_institucion) ua
               ON ua.id_docente = dc.id_docente AND ua.rn = 1
    ) s
    ON (t.id_docente = s.id_docente)
    WHEN MATCHED THEN UPDATE SET
      t.nombre_completo = s.nombre_completo, t.especialidad = s.especialidad,
      t.anios_experiencia = s.anios_experiencia, t.institucion = s.institucion, t.activo = s.docente_activo,
      t.fecha_actualizacion = LOCALTIMESTAMP
    WHEN NOT MATCHED THEN INSERT
      (id_docente, nombre_completo, especialidad, anios_experiencia, institucion, activo, fecha_actualizacion)
      VALUES (s.id_docente, s.nombre_completo, s.especialidad, s.anios_experiencia,
              s.institucion, s.docente_activo, LOCALTIMESTAMP);

    MERGE INTO dim_estudiante t
    USING (
      SELECT e.id_estudiante, e.nie, e.sexo, e.fecha_nacimiento,
             TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecha_nacimiento) / 12) AS edad,
             CASE WHEN li.id_estudiante IS NULL THEN 'SIN INSCRIPCION'
                  WHEN li.estado = 'VIGENTE' THEN 'ACTIVO'
                  WHEN li.resultado_cierre = 'GRADUADO' THEN 'GRADUADO'
                  WHEN li.estado = 'RETIRADA' THEN 'RETIRADO'
                  ELSE 'NO CONTINUO' END AS tipo_estudiante,
             ins.nombre AS institucion_actual, z.nombre AS zona_actual, d.nombre AS departamento_actual
        FROM vw_etl_val_estudiantes e
        LEFT JOIN (SELECT i.id_estudiante, i.id_curso, i.estado, i.resultado_cierre,
                          ROW_NUMBER() OVER (PARTITION BY i.id_estudiante
                                             ORDER BY i.fecha_inicio DESC, i.id_inscripcion DESC) AS rn
                     FROM vw_etl_val_inscripciones i
                    WHERE i.motivo_rechazo IS NULL) li
               ON li.id_estudiante = e.id_estudiante AND li.rn = 1
        LEFT JOIN vw_etl_stg_cursos c              ON c.id_curso = li.id_curso
        LEFT JOIN vw_etl_stg_instituciones_ciclo ic ON ic.id_institucion = c.id_institucion AND ic.id_ciclo = c.id_ciclo
        LEFT JOIN vw_etl_stg_instituciones ins     ON ins.id_institucion = c.id_institucion
        LEFT JOIN vw_etl_stg_zonas z               ON z.id_zona = ic.id_zona
        LEFT JOIN vw_etl_stg_departamentos d       ON d.id_departamento = ic.id_departamento
       WHERE e.motivo_rechazo IS NULL
    ) s
    ON (t.id_estudiante = s.id_estudiante)
    WHEN MATCHED THEN UPDATE SET
      t.nie = s.nie, t.sexo = s.sexo, t.fecha_nacimiento = s.fecha_nacimiento, t.edad = s.edad,
      t.tipo_estudiante = s.tipo_estudiante, t.institucion_actual = s.institucion_actual,
      t.zona_actual = s.zona_actual, t.departamento_actual = s.departamento_actual,
      t.fecha_actualizacion = LOCALTIMESTAMP
    WHEN NOT MATCHED THEN INSERT
      (id_estudiante, nie, sexo, fecha_nacimiento, edad, tipo_estudiante,
       institucion_actual, zona_actual, departamento_actual, fecha_actualizacion)
      VALUES (s.id_estudiante, s.nie, s.sexo, s.fecha_nacimiento, s.edad, s.tipo_estudiante,
              s.institucion_actual, s.zona_actual, s.departamento_actual, LOCALTIMESTAMP);
    DBMS_OUTPUT.PUT_LINE('Dimensiones cargadas.');

    -- === 4. Hechos: inserta nuevos y actualiza solo los que cambiaron ===
    MERGE INTO hechos_resultados t
    USING (
      SELECT v.*, de.sk_estudiante, dd.sk_docente, da.sk_asignatura, dc.sk_curso, dm.sk_modalidad
        FROM wk_etl_hechos v
        JOIN dim_estudiante de ON de.id_estudiante = v.id_estudiante
        JOIN dim_docente dd    ON dd.id_docente = v.id_docente
        JOIN dim_asignatura da ON da.id_asignatura = v.id_asignatura
        JOIN dim_curso dc      ON dc.id_curso = v.id_curso
        JOIN dim_modalidad dm  ON dm.id_modalidad = v.id_modalidad
        JOIN dim_tiempo dt     ON dt.id_tiempo = v.id_tiempo
    ) s
    ON (t.id_resultado_origen = s.id_resultado)
    WHEN MATCHED THEN UPDATE SET
        t.sk_estudiante = s.sk_estudiante,
        t.sk_docente = s.sk_docente,
        t.sk_asignatura = s.sk_asignatura,
        t.sk_curso = s.sk_curso,
        t.sk_modalidad = s.sk_modalidad,
        t.id_tiempo = s.id_tiempo,
        t.id_periodo = s.id_periodo,
        t.anio = s.anio,
        t.periodo_numero = s.periodo_numero,
        t.nota = s.nota,
        t.resultado_cualitativo = s.resultado_cualitativo,
        t.peso = s.peso,
        t.aprobado = s.aprobado,
        t.tipo_intento = s.tipo_intento,
        t.criterio = s.criterio,
        t.sesiones_aplicables = s.sesiones_aplicables,
        t.sesiones_registradas = s.sesiones_registradas,
        t.presencias = s.presencias,
        t.asistencia_pct = s.asistencia_pct,
        t.promedio_periodo_estudiante = s.promedio_periodo_estudiante,
        t.asistencia_periodo_estudiante = s.asistencia_periodo_estudiante,
        t.en_riesgo = s.en_riesgo,
        t.promedio_anual_materia = s.promedio_anual_materia,
        t.cobertura_anual_pct = s.cobertura_anual_pct,
        t.promedio_curso = s.promedio_curso,
        t.percentil_curso = s.percentil_curso,
        t.cuartil_curso = s.cuartil_curso,
        t.nota_anio_anterior = s.nota_anio_anterior,
        t.variacion_interanual = s.variacion_interanual,
        t.beca_vigente = s.beca_vigente,
        t.id_ejecucion = v_ejec,
        t.fecha_carga = LOCALTIMESTAMP
      WHERE DECODE(t.sk_estudiante, s.sk_estudiante, 0, 1) = 1
         OR DECODE(t.sk_docente, s.sk_docente, 0, 1) = 1
         OR DECODE(t.sk_asignatura, s.sk_asignatura, 0, 1) = 1
         OR DECODE(t.sk_curso, s.sk_curso, 0, 1) = 1
         OR DECODE(t.sk_modalidad, s.sk_modalidad, 0, 1) = 1
         OR DECODE(t.id_tiempo, s.id_tiempo, 0, 1) = 1
         OR DECODE(t.id_periodo, s.id_periodo, 0, 1) = 1
         OR DECODE(t.anio, s.anio, 0, 1) = 1
         OR DECODE(t.periodo_numero, s.periodo_numero, 0, 1) = 1
         OR DECODE(t.nota, s.nota, 0, 1) = 1
         OR DECODE(t.resultado_cualitativo, s.resultado_cualitativo, 0, 1) = 1
         OR DECODE(t.peso, s.peso, 0, 1) = 1
         OR DECODE(t.aprobado, s.aprobado, 0, 1) = 1
         OR DECODE(t.tipo_intento, s.tipo_intento, 0, 1) = 1
         OR DECODE(t.criterio, s.criterio, 0, 1) = 1
         OR DECODE(t.sesiones_aplicables, s.sesiones_aplicables, 0, 1) = 1
         OR DECODE(t.sesiones_registradas, s.sesiones_registradas, 0, 1) = 1
         OR DECODE(t.presencias, s.presencias, 0, 1) = 1
         OR DECODE(t.asistencia_pct, s.asistencia_pct, 0, 1) = 1
         OR DECODE(t.promedio_periodo_estudiante, s.promedio_periodo_estudiante, 0, 1) = 1
         OR DECODE(t.asistencia_periodo_estudiante, s.asistencia_periodo_estudiante, 0, 1) = 1
         OR DECODE(t.en_riesgo, s.en_riesgo, 0, 1) = 1
         OR DECODE(t.promedio_anual_materia, s.promedio_anual_materia, 0, 1) = 1
         OR DECODE(t.cobertura_anual_pct, s.cobertura_anual_pct, 0, 1) = 1
         OR DECODE(t.promedio_curso, s.promedio_curso, 0, 1) = 1
         OR DECODE(t.percentil_curso, s.percentil_curso, 0, 1) = 1
         OR DECODE(t.cuartil_curso, s.cuartil_curso, 0, 1) = 1
         OR DECODE(t.nota_anio_anterior, s.nota_anio_anterior, 0, 1) = 1
         OR DECODE(t.variacion_interanual, s.variacion_interanual, 0, 1) = 1
         OR DECODE(t.beca_vigente, s.beca_vigente, 0, 1) = 1
    WHEN NOT MATCHED THEN INSERT (id_resultado_origen, sk_estudiante, sk_docente, sk_asignatura, sk_curso, sk_modalidad, id_tiempo, id_periodo, anio, periodo_numero, nota, resultado_cualitativo, peso, aprobado, tipo_intento, criterio, sesiones_aplicables, sesiones_registradas, presencias, asistencia_pct, promedio_periodo_estudiante, asistencia_periodo_estudiante, en_riesgo, promedio_anual_materia, cobertura_anual_pct, promedio_curso, percentil_curso, cuartil_curso, nota_anio_anterior, variacion_interanual, beca_vigente, id_ejecucion, fecha_carga)
      VALUES (s.id_resultado, s.sk_estudiante, s.sk_docente, s.sk_asignatura, s.sk_curso, s.sk_modalidad, s.id_tiempo, s.id_periodo, s.anio, s.periodo_numero, s.nota, s.resultado_cualitativo, s.peso, s.aprobado, s.tipo_intento, s.criterio, s.sesiones_aplicables, s.sesiones_registradas, s.presencias, s.asistencia_pct, s.promedio_periodo_estudiante, s.asistencia_periodo_estudiante, s.en_riesgo, s.promedio_anual_materia, s.cobertura_anual_pct, s.promedio_curso, s.percentil_curso, s.cuartil_curso, s.nota_anio_anterior, s.variacion_interanual, s.beca_vigente, v_ejec, LOCALTIMESTAMP);
    DBMS_OUTPUT.PUT_LINE('Hechos insertados o actualizados: ' || SQL%ROWCOUNT);

    -- Quitar hechos cuyo resultado ya no esta en la ultima carga de staging
    DELETE FROM hechos_resultados h
     WHERE NOT EXISTS (SELECT 1 FROM vw_etl_stg_resultados_periodo r WHERE r.id_resultado = h.id_resultado_origen);
    DBMS_OUTPUT.PUT_LINE('Hechos eliminados por no existir en origen: ' || SQL%ROWCOUNT);

    -- === 5. Cerrar la ejecucion ===
    -- Regla del equipo (ck_auditoria_etl_cierre): al completar, total_leidos = insertados + actualizados + rechazados.
    -- Se registran las filas que produjeron un cambio; las que no cambiaron no se cuentan.
    UPDATE auditoria_etl_evaluaciones
       SET estado = 'COMPLETADA', fin = LOCALTIMESTAMP,
           total_leidos = insertados + actualizados + rechazados
     WHERE id_ejecucion = v_ejec;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      UPDATE auditoria_etl_evaluaciones
         SET estado = 'ERROR', fin = LOCALTIMESTAMP
       WHERE id_ejecucion = v_ejec;
      COMMIT;
      RAISE;
  END;
END;
/

-- ==============================================================
-- SECCIÓN 3: REFRESCO DE LAS VISTAS MATERIALIZADAS
-- Descripción: Si ya están instaladas (Vistas_Materializadas/), las refresca con PR_REFRESCAR_VISTAS_DM.
-- ==============================================================
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_objects
   WHERE object_name = 'PR_REFRESCAR_VISTAS_DM' AND object_type = 'PROCEDURE' AND status = 'VALID';
  IF n = 1 THEN
    EXECUTE IMMEDIATE 'BEGIN pr_refrescar_vistas_dm; END;';
  ELSE
    DBMS_OUTPUT.PUT_LINE('Vistas materializadas no instaladas todavia (ejecute Vistas_Materializadas/INSTALAR_VISTAS.sql).');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Aviso: no se pudieron refrescar las vistas materializadas: ' || SQLERRM);
    DBMS_OUTPUT.PUT_LINE('Ejecute Vistas_Materializadas/INSTALAR_VISTAS.sql para volver a crearlas.');
END;
/

-- ==============================================================
-- SECCIÓN 4: VERIFICACIÓN
-- Descripción: Resumen de la ejecución, rechazos por tipo, filas por tabla, conciliación y KPI por año.
-- ==============================================================
SELECT id_ejecucion, fuente, estado, total_leidos, insertados, actualizados, rechazados
  FROM auditoria_etl_evaluaciones
 ORDER BY id_ejecucion DESC
 FETCH FIRST 3 ROWS ONLY;

SELECT entidad, tipo_error, COUNT(*) AS filas
  FROM errores_etl_evaluaciones
 WHERE id_ejecucion = (SELECT MAX(id_ejecucion) FROM auditoria_etl_evaluaciones
                        WHERE fuente LIKE 'Data_Mart/03%')
 GROUP BY entidad, tipo_error
 ORDER BY entidad, tipo_error;

SELECT 'DIM_ESTUDIANTE' AS tabla, COUNT(*) AS registros FROM dim_estudiante
UNION ALL SELECT 'DIM_DOCENTE', COUNT(*) FROM dim_docente
UNION ALL SELECT 'DIM_ASIGNATURA', COUNT(*) FROM dim_asignatura
UNION ALL SELECT 'DIM_MODALIDAD', COUNT(*) FROM dim_modalidad
UNION ALL SELECT 'DIM_CURSO', COUNT(*) FROM dim_curso
UNION ALL SELECT 'DIM_TIEMPO', COUNT(*) FROM dim_tiempo
UNION ALL SELECT 'HECHOS_RESULTADOS', COUNT(*) FROM hechos_resultados;

-- Conciliacion: filas de staging (incluye versiones corregidas) -> resultados vigentes -> hechos
SELECT (SELECT COUNT(*) FROM vw_etl_stg_resultados_periodo) AS filas_staging,
       (SELECT COUNT(*) FROM (SELECT DISTINCT id_estudiante, id_asignatura, id_periodo
                                FROM vw_etl_stg_resultados_periodo))  AS resultados_vigentes,
       (SELECT COUNT(*) FROM wk_etl_hechos)                     AS listos_para_cargar,
       (SELECT COUNT(*) FROM hechos_resultados)                 AS hechos_cargados
  FROM dual;

-- Prueba rapida de KPI por anio
SELECT h.anio,
       ROUND(AVG(h.nota), 2) AS promedio,
       ROUND(100 * AVG(h.aprobado), 2) AS pct_aprobacion,
       ROUND(100 * SUM(h.presencias) / NULLIF(SUM(h.sesiones_registradas), 0), 2) AS pct_asistencia,
       COUNT(DISTINCT CASE WHEN h.en_riesgo = 1 THEN h.sk_estudiante || '-' || h.id_periodo END) AS estudiante_periodo_en_riesgo
  FROM hechos_resultados h
 GROUP BY h.anio
 ORDER BY h.anio;
