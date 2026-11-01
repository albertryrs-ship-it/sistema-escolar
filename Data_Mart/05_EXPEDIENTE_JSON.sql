-- =====================================================================
-- Data_Mart/05_EXPEDIENTE_JSON.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- Expediente academico JSON firmado: uno por estudiante por cada ciclo CERRADO.
--
--   ID:     EX-{CICLO}-{ID_ESTUDIANTE}-{SEQ}     ej. EX-NAC-2025-1010014-001
--           CICLO = codigo del ciclo (NAC-2025, BAC4-2025); SEQ = version del expediente.
--   Firma:  STANDARD_HASH(documento sin firma, 'SHA256'), en hexadecimal.
--   JSON:   id_expediente, estudiante{id_estudiante, nie, nombre, edad, sexo, institucion,
--           tipo_institucion, zona, departamento, modalidad}, ciclo_academico{...},
--           asignaturas[{id_asignatura, nombre, docente, promedio_final, asistencia, estatus}],
--           promedio_general, riesgo_academico (booleano), firma_digital.
--
-- Origen: modelo estrella (hechos ya validados). El nombre del estudiante se toma del OLTP
-- (mae_estudiante -> mae_persona) porque el staging del equipo no replica los nombres.
--
-- Re-ejecutable y con historial: si el contenido de un expediente no cambio, no se vuelve a
-- emitir; si cambio (por ejemplo, una nota corregida), se emite una version nueva (SEQ + 1).
-- Los expedientes emitidos no se pueden modificar ni borrar (trigger).
-- La ejecucion queda registrada en auditoria_etl_evaluaciones.
--
-- Requiere: 02 y 03 (modelo estrella con datos). Ejecutar como el usuario del proyecto:
--   @05_EXPEDIENTE_JSON.sql  (desde la carpeta Data_Mart; el script maestro lo ejecuta en su paso 12)
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
SET LONG 20000
SET LONGCHUNKSIZE 20000
SET LINESIZE 32767
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- ==============================================================
-- SECCIÓN 0: REQUISITOS
-- Descripción: Modelo estrella con datos (02 y 03).
-- ==============================================================
DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name IN ('HECHOS_RESULTADOS', 'MAE_PERSONA', 'MAE_ESTUDIANTE');
  IF n <> 3 THEN
    RAISE_APPLICATION_ERROR(-20130, 'Faltan HECHOS_RESULTADOS o el OLTP: ejecute primero el script maestro, 02 y 03.');
  END IF;
END;
/

-- ==============================================================
-- SECCIÓN 1: TABLA DE EXPEDIENTES
-- Descripción: Se conserva entre ejecuciones: es el historial firmado. Se crea solo si no existe.
-- ==============================================================
-- CREATE TABLE IF NOT EXISTS es de 23ai; en 19c/21c se crea solo si no existe con un bloque PL/SQL.
DECLARE n NUMBER; BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'EXPEDIENTE_ACADEMICO';
  IF n = 0 THEN
    EXECUTE IMMEDIATE q'~CREATE TABLE expediente_academico (
    id_expediente     VARCHAR2(60 CHAR)   NOT NULL,
    id_ciclo          NUMBER(10,0)        NOT NULL,
    codigo_ciclo      VARCHAR2(50 CHAR)   NOT NULL,
    id_estudiante     NUMBER(10,0)        NOT NULL,
    nie               VARCHAR2(30 CHAR)   NOT NULL,
    seq               NUMBER(3,0)         NOT NULL,
    hash_contenido    VARCHAR2(64 CHAR)   NOT NULL,   -- SHA256 del contenido academico (detecta cambios)
    firma_digital     VARCHAR2(64 CHAR)   NOT NULL,   -- SHA256 del documento completo sin la firma
    documento         VARCHAR2(4000 CHAR) NOT NULL,
    promedio_general  NUMBER(5,2),
    riesgo_academico  NUMBER(1)           NOT NULL,
    id_ejecucion      NUMBER(10,0)        NOT NULL,
    fecha_generacion  TIMESTAMP(6)        DEFAULT LOCALTIMESTAMP NOT NULL,
    CONSTRAINT pk_expediente_academico PRIMARY KEY (id_expediente),
    CONSTRAINT uk_expediente_version UNIQUE (id_ciclo, id_estudiante, seq),
    CONSTRAINT chk_expediente_id CHECK (REGEXP_LIKE(id_expediente, '^EX-[A-Z0-9]+(-[A-Z0-9]+)*-[0-9]+-[0-9]{3}$')),
    CONSTRAINT chk_expediente_json CHECK (documento IS JSON),
    CONSTRAINT chk_expediente_firma CHECK (REGEXP_LIKE(firma_digital, '^[0-9a-f]{64}$')),
    CONSTRAINT chk_expediente_riesgo CHECK (riesgo_academico IN (0, 1)),
    CONSTRAINT chk_expediente_seq CHECK (seq BETWEEN 1 AND 999)
)~';
  END IF;
END;
/

-- Un expediente firmado no se modifica ni se borra: si algo cambia, se emite otra version.
CREATE OR REPLACE TRIGGER trg_expediente_inmutable
BEFORE UPDATE OR DELETE ON expediente_academico
FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20140,
    'El expediente ' || :OLD.id_expediente || ' esta firmado y no se puede modificar ni borrar. '
    || 'Si cambio la informacion, vuelva a ejecutar 05_EXPEDIENTE_JSON.sql para emitir una version nueva.');
END;
/

-- ==============================================================
-- SECCIÓN 2: GENERACIÓN
-- Descripción: Arma el expediente JSON de cada estudiante y ciclo cerrado, lo firma con SHA256 y emite
--   una versión nueva solo si el contenido cambió.
-- ==============================================================
DECLARE
  v_ejec       NUMBER;
  v_candidatos NUMBER;
  v_nuevos     NUMBER;
BEGIN
  SELECT seq_etl_carga.NEXTVAL INTO v_ejec FROM dual;
  INSERT INTO auditoria_etl_evaluaciones
    (id_ejecucion, fuente, inicio, fin, estado, total_leidos, insertados, actualizados, rechazados)
  VALUES
    (v_ejec, 'Data_Mart/05_EXPEDIENTE_JSON.sql (expedientes por ciclo cerrado)',
     LOCALTIMESTAMP, NULL, 'EN_PROCESO', 0, 0, 0, 0);
  COMMIT;

  BEGIN
    INSERT INTO expediente_academico
      (id_expediente, id_ciclo, codigo_ciclo, id_estudiante, nie, seq, hash_contenido,
       firma_digital, documento, promedio_general, riesgo_academico, id_ejecucion)
    WITH per AS (          -- periodos de ciclos cerrados (tabla pequena)
      SELECT /*+ MATERIALIZE */ p.id_periodo, c.id_ciclo, c.codigo, c.nombre, c.anio,
             c.fecha_inicio, c.fecha_fin
        FROM vw_etl_stg_periodos p
        JOIN vw_etl_stg_ciclos c ON c.id_ciclo = p.id_ciclo
       WHERE c.estado = 'CERRADO'
    ), asig AS (           -- una fila por estudiante, ciclo y asignatura
      SELECT h.sk_estudiante, pe.id_ciclo, a.id_asignatura, a.nombre AS asignatura,
             MAX(d.nombre_completo) KEEP (DENSE_RANK LAST ORDER BY h.periodo_numero) AS docente,
             MAX(h.sk_curso)        KEEP (DENSE_RANK LAST ORDER BY h.periodo_numero) AS sk_curso,
             MAX(h.sk_modalidad)    KEEP (DENSE_RANK LAST ORDER BY h.periodo_numero) AS sk_modalidad,
             MAX(h.promedio_anual_materia)                                         AS promedio_final,
             ROUND(100 * SUM(h.presencias) / NULLIF(SUM(h.sesiones_registradas), 0), 2) AS asistencia,
             MAX(h.en_riesgo)                                                      AS en_riesgo,
             MAX(h.resultado_cualitativo)                                          AS resultado_cualitativo
        FROM hechos_resultados h
        JOIN per pe           ON pe.id_periodo = h.id_periodo
        JOIN dim_asignatura a ON a.sk_asignatura = h.sk_asignatura
        JOIN dim_docente d    ON d.sk_docente = h.sk_docente
       GROUP BY h.sk_estudiante, pe.id_ciclo, a.id_asignatura, a.nombre
    ), exp AS (            -- una fila por estudiante y ciclo, con la lista de asignaturas
      SELECT x.sk_estudiante, x.id_ciclo,
             MAX(x.sk_curso)     AS sk_curso,
             MAX(x.sk_modalidad) AS sk_modalidad,
             ROUND(AVG(x.promedio_final), 2) AS promedio_general,
             NVL(MAX(x.en_riesgo), 0)        AS en_riesgo,
             JSON_ARRAYAGG(
               JSON_OBJECT(
                 'id_asignatura'  VALUE x.id_asignatura,
                 'nombre'         VALUE x.asignatura,
                 'docente'        VALUE x.docente,
                 'promedio_final' VALUE x.promedio_final,
                 'asistencia'     VALUE x.asistencia,
                 'estatus'        VALUE CASE WHEN x.promedio_final IS NULL
                                              THEN NVL(x.resultado_cualitativo, 'SIN NOTA')
                                             WHEN x.promedio_final >= 60 THEN 'APROBADA'
                                             ELSE 'REPROBADA' END
                 NULL ON NULL)
               ORDER BY x.id_asignatura
               RETURNING VARCHAR2(4000)) AS asignaturas
        FROM asig x
       GROUP BY x.sk_estudiante, x.id_ciclo
    ), cuerpo AS (         -- contenido academico (sin id ni firma) y su hash
      SELECT e.id_ciclo, pe.codigo AS codigo_ciclo, de.id_estudiante, de.nie,
             e.promedio_general, e.en_riesgo,
             JSON_OBJECT(
               'estudiante' VALUE JSON_OBJECT(
                   'id_estudiante'    VALUE de.id_estudiante,
                   'nie'              VALUE de.nie,
                   'nombre'           VALUE REGEXP_REPLACE(TRIM(p.primer_nombre || ' ' || p.segundo_nombre || ' '
                                                 || p.primer_apellido || ' ' || p.segundo_apellido), ' {2,}', ' '),
                   'edad'             VALUE TRUNC(MONTHS_BETWEEN(pe.fecha_fin, de.fecha_nacimiento) / 12),
                   'sexo'             VALUE de.sexo,
                   'institucion'      VALUE c.institucion,
                   'tipo_institucion' VALUE c.tipo_institucion,
                   'zona'             VALUE c.zona,
                   'departamento'     VALUE c.departamento,
                   'modalidad'        VALUE m.tipo_modalidad
                   NULL ON NULL),
               'ciclo_academico' VALUE JSON_OBJECT(
                   'id_ciclo'     VALUE pe.id_ciclo,
                   'codigo'       VALUE pe.codigo,
                   'nombre'       VALUE pe.nombre,
                   'anio'         VALUE pe.anio,
                   'grado'        VALUE c.grado,
                   'seccion'      VALUE c.seccion,
                   'fecha_inicio' VALUE TO_CHAR(pe.fecha_inicio, 'YYYY-MM-DD'),
                   'fecha_fin'    VALUE TO_CHAR(pe.fecha_fin, 'YYYY-MM-DD')),
               'asignaturas'      VALUE e.asignaturas FORMAT JSON,
               'promedio_general' VALUE e.promedio_general,
               'riesgo_academico' VALUE CASE WHEN e.en_riesgo = 1 THEN 'true' ELSE 'false' END FORMAT JSON
               NULL ON NULL
               RETURNING VARCHAR2(4000)) AS contenido
        FROM exp e
        JOIN (SELECT DISTINCT id_ciclo, codigo, nombre, anio, fecha_inicio, fecha_fin FROM per) pe
          ON pe.id_ciclo = e.id_ciclo
        JOIN dim_estudiante de ON de.sk_estudiante = e.sk_estudiante
        JOIN dim_curso c       ON c.sk_curso = e.sk_curso
        JOIN dim_modalidad m   ON m.sk_modalidad = e.sk_modalidad
        JOIN mae_estudiante me ON me.id_estudiante = de.id_estudiante
        JOIN mae_persona p     ON p.id_persona = me.id_persona
    ), nuevos AS (         -- solo los que no existen o cambiaron desde la ultima version
      SELECT k.*,
             LOWER(RAWTOHEX(STANDARD_HASH(k.contenido, 'SHA256'))) AS hash_contenido,
             NVL(u.seq, 0) + 1 AS seq
        FROM cuerpo k
        LEFT JOIN (SELECT id_ciclo, id_estudiante,
                          MAX(seq) AS seq,
                          MAX(hash_contenido) KEEP (DENSE_RANK LAST ORDER BY seq) AS hash_contenido
                     FROM expediente_academico
                    GROUP BY id_ciclo, id_estudiante) u
          ON u.id_ciclo = k.id_ciclo AND u.id_estudiante = k.id_estudiante
       WHERE u.hash_contenido IS NULL
          OR u.hash_contenido <> LOWER(RAWTOHEX(STANDARD_HASH(k.contenido, 'SHA256')))
    ), con_id AS (
      SELECT n.*,
             'EX-' || n.codigo_ciclo || '-' || n.id_estudiante || '-' || LPAD(n.seq, 3, '0') AS id_expediente
        FROM nuevos n
    ), sin_firma AS (      -- documento completo: id al inicio + contenido
      SELECT i.*,
             '{"id_expediente":"' || i.id_expediente || '",' || SUBSTR(i.contenido, 2) AS documento_sin_firma
        FROM con_id i
    ), firmado AS (
      SELECT s.*,
             LOWER(RAWTOHEX(STANDARD_HASH(s.documento_sin_firma, 'SHA256'))) AS firma
        FROM sin_firma s
    )
    SELECT f.id_expediente, f.id_ciclo, f.codigo_ciclo, f.id_estudiante, f.nie, f.seq, f.hash_contenido,
           f.firma,
           SUBSTR(f.documento_sin_firma, 1, LENGTH(f.documento_sin_firma) - 1)
             || ',"firma_digital":"' || f.firma || '"}',
           f.promedio_general, f.en_riesgo, v_ejec
      FROM firmado f;
    v_nuevos := SQL%ROWCOUNT;

    WITH per AS (
      SELECT /*+ MATERIALIZE */ p.id_periodo, p.id_ciclo
        FROM vw_etl_stg_periodos p
        JOIN vw_etl_stg_ciclos c ON c.id_ciclo = p.id_ciclo
       WHERE c.estado = 'CERRADO'
    )
    SELECT COUNT(*) INTO v_candidatos
      FROM (SELECT DISTINCT h.sk_estudiante, pe.id_ciclo
              FROM hechos_resultados h
              JOIN per pe ON pe.id_periodo = h.id_periodo);

    UPDATE auditoria_etl_evaluaciones
       SET estado = 'COMPLETADA', fin = LOCALTIMESTAMP,
           insertados = v_nuevos, actualizados = 0, rechazados = 0,
           total_leidos = v_nuevos
     WHERE id_ejecucion = v_ejec;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Ejecucion #' || v_ejec || ': estudiante-ciclo cerrados: ' || v_candidatos
                         || ' | expedientes nuevos o nuevas versiones: ' || v_nuevos
                         || ' | sin cambios (no se reemiten): ' || (v_candidatos - v_nuevos));
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
-- SECCIÓN 3: VERIFICACIÓN
-- Descripción: Recalcula las firmas y muestra ejemplos.
-- ==============================================================
PROMPT Expedientes por ciclo
SELECT codigo_ciclo, COUNT(*) AS expedientes, MAX(seq) AS version_maxima,
       SUM(riesgo_academico) AS en_riesgo, ROUND(AVG(promedio_general), 2) AS promedio,
       MAX(LENGTH(documento)) AS largo_maximo
  FROM expediente_academico
 GROUP BY codigo_ciclo
 ORDER BY codigo_ciclo;

PROMPT Verificacion de firmas: se recalcula el hash de cada documento sin su firma
SELECT COUNT(*) AS expedientes,
       SUM(CASE WHEN LOWER(RAWTOHEX(STANDARD_HASH(
                       SUBSTR(documento, 1, INSTR(documento, ',"firma_digital":') - 1) || '}',
                       'SHA256'))) = firma_digital THEN 1 ELSE 0 END) AS firmas_validas
  FROM expediente_academico;

PROMPT Muestra: un expediente en riesgo (o el primero si no hay) con formato legible
SELECT JSON_SERIALIZE(documento RETURNING CLOB PRETTY) AS expediente
  FROM (SELECT documento FROM expediente_academico
         ORDER BY riesgo_academico DESC, id_expediente
         FETCH FIRST 1 ROW ONLY);

PROMPT Consulta de un expediente por sus campos JSON
SELECT id_expediente,
       JSON_VALUE(documento, '$.estudiante.nombre')        AS nombre,
       JSON_VALUE(documento, '$.estudiante.institucion')   AS institucion,
       JSON_VALUE(documento, '$.ciclo_academico.grado')    AS grado,
       JSON_VALUE(documento, '$.promedio_general')         AS promedio_general,
       JSON_VALUE(documento, '$.riesgo_academico')         AS riesgo,
       SUBSTR(firma_digital, 1, 16) || '...'               AS firma
  FROM expediente_academico
 ORDER BY riesgo_academico DESC, id_expediente
 FETCH FIRST 5 ROWS ONLY;

PROMPT Prueba de integridad: si se altera una nota, la firma ya no coincide
SELECT id_expediente,
       firma_digital AS firma_original,
       LOWER(RAWTOHEX(STANDARD_HASH(
         REGEXP_REPLACE(SUBSTR(documento, 1, INSTR(documento, ',"firma_digital":') - 1) || '}',
                        '"promedio_general":[0-9.]+', '"promedio_general":99.99'),
         'SHA256'))) AS firma_si_se_altera,
       'NO COINCIDE: el documento fue alterado' AS resultado
  FROM expediente_academico
 ORDER BY id_expediente
 FETCH FIRST 1 ROW ONLY;
