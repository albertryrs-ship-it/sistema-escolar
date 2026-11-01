-- Antes de cargar: el OLTP debe existir y estar vacío. No instalar las validaciones antes de la carga masiva.
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE n NUMBER; t NUMBER:=0; BEGIN
 SELECT COUNT(*) INTO n FROM cat_tipo_documento; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_tipo_institucion; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_departamento; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_zona; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_modalidad; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_jornada; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_area_conocimiento; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_tipo_beca; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_nivel; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_ciclo; t:=t+n;
 SELECT COUNT(*) INTO n FROM auditoria_etl_evaluaciones; t:=t+n;
 SELECT COUNT(*) INTO n FROM cat_grado; t:=t+n;
 SELECT COUNT(*) INTO n FROM mae_institucion; t:=t+n;
 SELECT COUNT(*) INTO n FROM mae_persona; t:=t+n;
 SELECT COUNT(*) INTO n FROM mae_asignatura; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_periodo_academico; t:=t+n;
 SELECT COUNT(*) INTO n FROM errores_etl_evaluaciones; t:=t+n;
 SELECT COUNT(*) INTO n FROM mae_estudiante; t:=t+n;
 SELECT COUNT(*) INTO n FROM mae_docente; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_institucion_ciclo; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_curso; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_plazo_registro_notas; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_curso_asignatura; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_inscripcion; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_control_carga; t:=t+n;
 SELECT COUNT(*) INTO n FROM est_ponderacion_periodo; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_asignacion_docente; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_beca; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_calificacion; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_sesion_clase; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_beca_vigencia; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_resultado_periodo; t:=t+n;
 SELECT COUNT(*) INTO n FROM trx_asistencia; t:=t+n;
 IF t>0 THEN RAISE_APPLICATION_ERROR(-20900,'El OLTP no está vacío: '||t||' filas.'); END IF;
 SELECT COUNT(*) INTO n FROM user_objects WHERE object_name='VAL_REGLA';
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20900,'las validaciones ya están instaladas: cargar antes de instalarlas.'); END IF;
 DBMS_OUTPUT.PUT_LINE('OK: OLTP vacío y sin validaciones instaladas.');
END;
/
