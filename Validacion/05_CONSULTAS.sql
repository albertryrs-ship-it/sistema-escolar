-- ==============================================================
-- SECCIÓN 5: CONSULTAS Y SEGUIMIENTO
-- Descripción: Vistas de pendientes y avisos, procedimientos de consulta y la revisión programada (opcional).
--   Solo leen datos: no validan ni modifican.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === VW_VAL_NOTAS_VIGENTES ===
CREATE OR REPLACE VIEW vw_val_notas_vigentes AS
 SELECT * FROM (SELECT n.*,ROW_NUMBER() OVER(PARTITION BY id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento ORDER BY version DESC) rn
 FROM trx_calificacion n WHERE fecha_validacion<=LOCALTIMESTAMP)
 WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>LOCALTIMESTAMP);
COMMENT ON TABLE vw_val_notas_vigentes IS 'Última versión validada y no anulada de cada intento de calificación.';

-- === VW_VAL_RESULTADO_VIGENTE ===
CREATE OR REPLACE VIEW vw_val_resultado_vigente AS
 SELECT r.id_resultado,r.id_estudiante,r.id_asignatura,r.id_periodo,r.id_calificacion_seleccionada,
 r.fecha_seleccion,r.fecha_cierre,n.nota,n.resultado_cualitativo FROM
 (SELECT r.*,ROW_NUMBER() OVER(PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) rn
 FROM trx_resultado_periodo r WHERE fecha_seleccion<=LOCALTIMESTAMP) r
 JOIN vw_val_notas_vigentes n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1;
COMMENT ON TABLE vw_val_resultado_vigente IS 'Selección vigente de cada estudiante, materia y período, con su nota.';

-- === VW_NOTAS_PENDIENTES ===
CREATE OR REPLACE VIEW vw_notas_pendientes AS
 SELECT DISTINCT i.id_estudiante,c.id_ciclo,c.id_institucion,c.id_curso,o.id_asignatura,p.id_periodo,
 w.fecha_limite_registro,
 CASE WHEN w.id_plazo_registro_notas IS NULL THEN 'SIN_PLAZO'
 WHEN LOCALTIMESTAMP>w.fecha_limite_registro THEN 'VENCIDA' ELSE 'NO_VENCIDA' END situacion
 FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso
 JOIN est_curso_asignatura o ON o.id_curso=c.id_curso
 JOIN est_ponderacion_periodo p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN est_periodo_academico a ON a.id_periodo=p.id_periodo
 LEFT JOIN est_plazo_registro_notas w ON w.id_institucion=c.id_institucion AND w.id_ciclo=c.id_ciclo
 AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA'
 WHERE i.estado<>'ANULADA' AND o.estado='ACTIVA' AND p.estado='PUBLICADO'
 AND i.fecha_inicio<=a.fecha_fin AND COALESCE(i.fecha_fin,a.fecha_fin)>=a.fecha_inicio
 AND NOT EXISTS (SELECT 1 FROM vw_val_resultado_vigente r WHERE r.id_estudiante=i.id_estudiante
 AND r.id_asignatura=o.id_asignatura AND r.id_periodo=p.id_periodo);
COMMENT ON TABLE vw_notas_pendientes IS 'Notas esperadas que aún no tienen resultado: SIN_PLAZO, VENCIDA o NO_VENCIDA.';

-- === VW_ASISTENCIA_PENDIENTE ===
CREATE OR REPLACE VIEW vw_asistencia_pendiente AS
 SELECT i.id_inscripcion,i.id_estudiante,c.id_ciclo,c.id_institucion,c.id_curso,s.id_sesion,s.fecha_academica,p.id_periodo
 FROM trx_sesion_clase s JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura
 JOIN est_curso c ON c.id_curso=o.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo
 JOIN trx_inscripcion i ON i.id_curso=c.id_curso AND i.estado<>'ANULADA'
 WHERE s.estado='IMPARTIDA' AND s.fin<=LOCALTIMESTAMP
 AND s.fecha_academica BETWEEN i.fecha_inicio AND COALESCE(i.fecha_fin,x.fecha_fin)
 AND NOT EXISTS (SELECT 1 FROM trx_asistencia a WHERE a.id_inscripcion=i.id_inscripcion
 AND a.id_sesion=s.id_sesion AND a.fecha_registro<=LOCALTIMESTAMP);
COMMENT ON TABLE vw_asistencia_pendiente IS 'Sesiones impartidas sin asistencia registrada para un estudiante inscrito.';

-- === VW_CONFIGURACION_PENDIENTE ===
CREATE OR REPLACE VIEW vw_configuracion_pendiente AS
 SELECT 'OFERTA_SIN_PLAN' tipo,c.id_institucion,c.id_ciclo,c.id_curso,o.id_curso_asignatura clave
 FROM est_curso_asignatura o JOIN est_curso c ON c.id_curso=o.id_curso
 WHERE o.estado='ACTIVA' AND NOT EXISTS (SELECT 1 FROM est_ponderacion_periodo p
 WHERE p.id_curso_asignatura=o.id_curso_asignatura AND p.estado='PUBLICADO')
 UNION ALL
 SELECT 'SIN_RESPONSABLE',c.id_institucion,c.id_ciclo,c.id_curso,o.id_curso_asignatura
 FROM est_curso_asignatura o JOIN est_curso c ON c.id_curso=o.id_curso
 WHERE o.estado='ACTIVA' AND NOT EXISTS (SELECT 1 FROM trx_asignacion_docente a
 WHERE a.id_curso_asignatura=o.id_curso_asignatura AND a.estado<>'ANULADA')
 UNION ALL
 SELECT 'SIN_PLAZO',c.id_institucion,c.id_ciclo,c.id_curso,p.id_ponderacion_periodo
 FROM est_ponderacion_periodo p JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura
 JOIN est_curso c ON c.id_curso=o.id_curso WHERE p.estado='PUBLICADO' AND NOT EXISTS
 (SELECT 1 FROM est_plazo_registro_notas w WHERE w.id_institucion=c.id_institucion
 AND w.id_ciclo=c.id_ciclo AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA');
COMMENT ON TABLE vw_configuracion_pendiente IS 'Materias sin plan publicado, sin docente responsable o sin plazo de notas.';

-- === VW_COBERTURA_PENDIENTE ===
CREATE OR REPLACE VIEW vw_cobertura_pendiente AS
 SELECT z.*,CASE WHEN z.estado='PARCIAL' THEN 'ENTREGA_PARCIAL' ELSE 'REVISAR_DECLARACION' END situacion
 FROM trx_control_carga z WHERE z.estado='PARCIAL';
COMMENT ON TABLE vw_cobertura_pendiente IS 'Declaraciones de carga parcial que hay que revisar.';

-- === VW_EJECUCIONES_PENDIENTES ===
CREATE OR REPLACE VIEW vw_ejecuciones_pendientes AS
 SELECT a.*,CASE WHEN a.inicio<LOCALTIMESTAMP-NUMTODSINTERVAL(p.horas_interrupcion,'HOUR')
 THEN 'POSIBLE_INTERRUPCION' ELSE 'EN_CURSO' END situacion
 FROM auditoria_etl_evaluaciones a CROSS JOIN val_politica p WHERE a.estado='EN_PROCESO' AND p.id=1;
COMMENT ON TABLE vw_ejecuciones_pendientes IS 'Cargas EN_PROCESO; marca POSIBLE_INTERRUPCION si superan las horas de val_politica.';

-- === VW_AVISOS_CALIDAD ===
CREATE OR REPLACE VIEW vw_avisos_calidad AS
 SELECT r.id_regla,r.capa,r.entidad,r.severidad,r.descripcion,i.cantidad,i.estado,i.ultima_revision,
 i.responsable,i.comentario FROM val_incidencia i JOIN val_regla r ON r.id_regla=i.id_regla WHERE i.estado='ABIERTA';
COMMENT ON TABLE vw_avisos_calidad IS 'Incidencias abiertas de pr_diagnosticar_validaciones, con la descripción de la regla.';

-- === VW_CAPACIDAD_CURSOS ===
CREATE OR REPLACE VIEW vw_capacidad_cursos AS
 SELECT c.id_curso,c.capacidad_maxima,
 (SELECT COUNT(*) FROM trx_inscripcion i JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo
 WHERE i.id_curso=c.id_curso AND i.estado<>'ANULADA' AND TRUNC(CURRENT_DATE)
 BETWEEN i.fecha_inicio AND COALESCE(i.fecha_fin,x.fecha_fin)) ocupacion_actual FROM est_curso c;
COMMENT ON TABLE vw_capacidad_cursos IS 'Ocupación actual de cada curso frente a su capacidad máxima.';

-- === VW_CONTACTOS_REVISAR ===
CREATE OR REPLACE VIEW vw_contactos_revisar AS
 SELECT id_persona,
 CASE WHEN email IS NOT NULL AND NOT REGEXP_LIKE(email,'^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$') THEN 'REVISAR_EMAIL'
 WHEN telefono IS NOT NULL AND NOT REGEXP_LIKE(telefono,'^[+() 0-9.-]+$') THEN 'REVISAR_TELEFONO' END aviso
 FROM mae_persona WHERE
 (email IS NOT NULL AND NOT REGEXP_LIKE(email,'^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'))
 OR (telefono IS NOT NULL AND NOT REGEXP_LIKE(telefono,'^[+() 0-9.-]+$'));
COMMENT ON TABLE vw_contactos_revisar IS 'Personas con correo o teléfono de formato dudoso.';

-- === VW_POSIBLES_DUPLICADOS ===
CREATE OR REPLACE VIEW vw_posibles_duplicados AS
 SELECT a.id_persona id_persona_1,b.id_persona id_persona_2
 FROM mae_persona a JOIN mae_persona b ON a.id_persona<b.id_persona
 AND UPPER(a.primer_nombre)=UPPER(b.primer_nombre) AND UPPER(a.primer_apellido)=UPPER(b.primer_apellido)
 AND a.fecha_nacimiento=b.fecha_nacimiento;
COMMENT ON TABLE vw_posibles_duplicados IS 'Pares de personas con el mismo nombre, apellido y fecha de nacimiento (no se fusionan solas).';

-- === FN_CLASIFICAR_LLEGADA ===
CREATE OR REPLACE FUNCTION fn_clasificar_llegada(p_inicio TIMESTAMP,p_llegada TIMESTAMP)
 RETURN VARCHAR2 AUTHID DEFINER IS m NUMBER;
  -- ----------------------------------------------------------------------
  -- FN_CLASIFICAR_LLEGADA
  -- Clasifica una llegada como PRESENTE o TARDE según los minutos de tolerancia de
  -- val_politica. Opcional: sin política devuelve SIN_POLITICA.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_llegada IS NULL THEN RETURN 'SIN_HORA';END IF;
 SELECT minutos_tardanza INTO m FROM val_politica WHERE id=1;
 IF m IS NULL THEN RETURN 'SIN_POLITICA';END IF;
 IF p_llegada>p_inicio+NUMTODSINTERVAL(m,'MINUTE') THEN RETURN 'TARDE';END IF;
 RETURN 'PRESENTE';
END;
/

-- === PR_CONSULTAR_PENDIENTES ===
CREATE OR REPLACE PROCEDURE pr_consultar_pendientes(p_ciclo NUMBER,p_salida OUT SYS_REFCURSOR)
 AUTHID DEFINER IS BEGIN
  -- ----------------------------------------------------------------------
  -- PR_CONSULTAR_PENDIENTES
  -- Devuelve las notas y asistencias pendientes de un ciclo.
  -- ----------------------------------------------------------------------
 OPEN p_salida FOR
 SELECT 'NOTAS' dominio,id_institucion,id_curso,id_estudiante,id_periodo,situacion
 FROM vw_notas_pendientes WHERE id_ciclo=p_ciclo
 UNION ALL SELECT 'ASISTENCIA',id_institucion,id_curso,id_estudiante,id_periodo,'SIN_REGISTRAR'
 FROM vw_asistencia_pendiente WHERE id_ciclo=p_ciclo;
END;
/

-- === PR_CONSULTAR_PROMEDIOS ===
CREATE OR REPLACE PROCEDURE pr_consultar_promedios(p_estudiante NUMBER,p_asignatura NUMBER,
 p_ciclo NUMBER,p_corte TIMESTAMP,p_salida OUT SYS_REFCURSOR) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_CONSULTAR_PROMEDIOS
  -- Devuelve el promedio actual, la cobertura y el promedio final (solo con todo cerrado) de
  -- un estudiante en una materia y ciclo, a una fecha de corte.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_corte IS NULL THEN RAISE_APPLICATION_ERROR(-20817,'Corte requerido.');END IF;
 OPEN p_salida FOR
 WITH planes AS (SELECT p.*,p.peso/SUM(p.peso) OVER(PARTITION BY p.id_curso_asignatura) peso_relativo
  FROM est_ponderacion_periodo p WHERE p.estado='PUBLICADO'),
 obligaciones AS (SELECT o.id_asignatura,p.id_periodo,p.peso_relativo,
 ROW_NUMBER() OVER(PARTITION BY o.id_asignatura,p.id_periodo ORDER BY i.fecha_inicio DESC,i.id_inscripcion DESC) rn
 FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso
 JOIN est_curso_asignatura o ON o.id_curso=c.id_curso JOIN planes p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN est_periodo_academico a ON a.id_periodo=p.id_periodo
 WHERE i.id_estudiante=p_estudiante AND o.id_asignatura=p_asignatura AND c.id_ciclo=p_ciclo
 AND o.tipo_resultado='NUMERICA' AND i.estado<>'ANULADA'
 AND i.fecha_inicio<=a.fecha_fin AND COALESCE(i.fecha_fin,a.fecha_fin)>=a.fecha_inicio),
 ultimas AS (SELECT r.*,ROW_NUMBER() OVER(PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) rn
 FROM trx_resultado_periodo r WHERE r.fecha_seleccion<=p_corte AND r.id_estudiante=p_estudiante AND r.id_asignatura=p_asignatura),
 notas AS (SELECT n.* FROM trx_calificacion n WHERE n.fecha_validacion<=p_corte
 AND (n.fecha_anulacion IS NULL OR n.fecha_anulacion>p_corte)
 AND NOT EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=n.id_inscripcion
 AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.numero_intento=n.numero_intento
 AND v.tipo_intento=n.tipo_intento AND v.version>n.version AND v.fecha_validacion<=p_corte)),
 base AS (SELECT o.peso_relativo,n.nota,r.fecha_cierre FROM obligaciones o
 LEFT JOIN ultimas r ON r.id_periodo=o.id_periodo AND r.rn=1
 LEFT JOIN notas n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE o.rn=1),
 medidas AS (SELECT SUM(nota*peso_relativo)/NULLIF(SUM(CASE WHEN nota IS NOT NULL THEN peso_relativo END),0) actual,
 SUM(CASE WHEN nota IS NOT NULL THEN peso_relativo ELSE 0 END)/NULLIF(SUM(peso_relativo),0)*100 cobertura,
 COUNT(*) esperadas,COUNT(nota) disponibles,
 SUM(CASE WHEN nota IS NOT NULL AND fecha_cierre<=p_corte THEN 1 ELSE 0 END) cerradas FROM base)
 SELECT m.actual promedio_actual,m.cobertura,
 CASE WHEN m.esperadas>0 AND m.disponibles=m.esperadas AND m.cerradas=m.esperadas
 AND x.estado='CERRADO' AND x.fecha_fin<=TRUNC(CAST(p_corte AS DATE))
 AND NOT EXISTS (SELECT 1 FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso
 JOIN est_institucion_ciclo h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo
 WHERE i.id_estudiante=p_estudiante AND c.id_ciclo=p_ciclo AND h.estado<>'CERRADO') THEN m.actual END promedio_final,
 m.esperadas,m.disponibles,p_corte fecha_corte FROM medidas m JOIN est_ciclo x ON x.id_ciclo=p_ciclo;
END;
/

-- === PR_PROGRAMAR_REVISION ===
CREATE OR REPLACE PROCEDURE pr_programar_revision(p_minutos NUMBER DEFAULT 60) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_PROGRAMAR_REVISION
  -- Crea, desactivado, un job que ejecuta pr_diagnosticar_validaciones cada p_minutos.
  -- Requiere CREATE JOB; el instalador no lo activa.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_minutos IS NULL OR p_minutos<>TRUNC(p_minutos) OR p_minutos<1 THEN
  RAISE_APPLICATION_ERROR(-20819,'Periodicidad debe ser entero positivo.');END IF;
 -- Opcion explicita: requiere CREATE JOB. El instalador no crea ni activa tareas automaticamente.
 EXECUTE IMMEDIATE q'~BEGIN DBMS_SCHEDULER.CREATE_JOB(job_name=>'VAL_REVISION_CALIDAD',job_type=>'PLSQL_BLOCK',
 job_action=>'BEGIN pr_diagnosticar_validaciones; COMMIT; END;',repeat_interval=>:r,enabled=>FALSE,
 auto_drop=>FALSE,comments=>'Revision consultable de calidad; sin mensajes externos');END;~'
 USING 'FREQ=MINUTELY;INTERVAL='||TO_CHAR(p_minutos,'FM999999990');
END;
/
