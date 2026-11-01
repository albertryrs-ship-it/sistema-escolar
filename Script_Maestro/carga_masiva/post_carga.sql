-- Después de cargar: conteos exactos, restricciones habilitadas y estadísticas.
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE n NUMBER; f NUMBER:=0; BEGIN
 SELECT COUNT(*) INTO n FROM cat_tipo_documento; IF n<>1 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_tipo_documento: '||n||' filas, se esperaban 1'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_tipo_institucion; IF n<>2 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_tipo_institucion: '||n||' filas, se esperaban 2'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_departamento; IF n<>14 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_departamento: '||n||' filas, se esperaban 14'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_zona; IF n<>2 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_zona: '||n||' filas, se esperaban 2'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_modalidad; IF n<>1 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_modalidad: '||n||' filas, se esperaban 1'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_jornada; IF n<>2 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_jornada: '||n||' filas, se esperaban 2'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_area_conocimiento; IF n<>9 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_area_conocimiento: '||n||' filas, se esperaban 9'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_tipo_beca; IF n<>3 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_tipo_beca: '||n||' filas, se esperaban 3'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_nivel; IF n<>2 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_nivel: '||n||' filas, se esperaban 2'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_ciclo; IF n<>4 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_ciclo: '||n||' filas, se esperaban 4'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM auditoria_etl_evaluaciones; IF n<>2 THEN DBMS_OUTPUT.PUT_LINE('FALLO auditoria_etl_evaluaciones: '||n||' filas, se esperaban 2'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM cat_grado; IF n<>12 THEN DBMS_OUTPUT.PUT_LINE('FALLO cat_grado: '||n||' filas, se esperaban 12'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM mae_institucion; IF n<>42 THEN DBMS_OUTPUT.PUT_LINE('FALLO mae_institucion: '||n||' filas, se esperaban 42'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM mae_persona; IF n<>7714 THEN DBMS_OUTPUT.PUT_LINE('FALLO mae_persona: '||n||' filas, se esperaban 7714'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM mae_asignatura; IF n<>10 THEN DBMS_OUTPUT.PUT_LINE('FALLO mae_asignatura: '||n||' filas, se esperaban 10'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_periodo_academico; IF n<>14 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_periodo_academico: '||n||' filas, se esperaban 14'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM mae_estudiante; IF n<>7168 THEN DBMS_OUTPUT.PUT_LINE('FALLO mae_estudiante: '||n||' filas, se esperaban 7168'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM mae_docente; IF n<>546 THEN DBMS_OUTPUT.PUT_LINE('FALLO mae_docente: '||n||' filas, se esperaban 546'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_institucion_ciclo; IF n<>96 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_institucion_ciclo: '||n||' filas, se esperaban 96'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_curso; IF n<>1008 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_curso: '||n||' filas, se esperaban 1008'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_plazo_registro_notas; IF n<>6120 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_plazo_registro_notas: '||n||' filas, se esperaban 6120'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_curso_asignatura; IF n<>8064 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_curso_asignatura: '||n||' filas, se esperaban 8064'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_inscripcion; IF n<>12906 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_inscripcion: '||n||' filas, se esperaban 12906'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_control_carga; IF n<>9762 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_control_carga: '||n||' filas, se esperaban 9762'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM est_ponderacion_periodo; IF n<>24480 THEN DBMS_OUTPUT.PUT_LINE('FALLO est_ponderacion_periodo: '||n||' filas, se esperaban 24480'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_asignacion_docente; IF n<>8148 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_asignacion_docente: '||n||' filas, se esperaban 8148'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_beca; IF n<>774 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_beca: '||n||' filas, se esperaban 774'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_calificacion; IF n<>335447 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_calificacion: '||n||' filas, se esperaban 335447'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_sesion_clase; IF n<>252864 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_sesion_clase: '||n||' filas, se esperaban 252864'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_beca_vigencia; IF n<>896 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_beca_vigencia: '||n||' filas, se esperaban 896'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_resultado_periodo; IF n<>335447 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_resultado_periodo: '||n||' filas, se esperaban 335447'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM trx_asistencia; IF n<>3114006 THEN DBMS_OUTPUT.PUT_LINE('FALLO trx_asistencia: '||n||' filas, se esperaban 3114006'); f:=f+1; END IF;
 SELECT COUNT(*) INTO n FROM user_constraints WHERE table_name IN (SELECT table_name FROM user_tables WHERE table_name NOT LIKE 'STG\_%' ESCAPE '\') AND (status<>'ENABLED' OR validated<>'VALIDATED');
 IF n>0 THEN DBMS_OUTPUT.PUT_LINE('FALLO: '||n||' restricciones deshabilitadas o sin validar.'); f:=f+1; END IF;
 IF f>0 THEN RAISE_APPLICATION_ERROR(-20901,f||' comprobaciones fallaron; revisar logs/*.log y logs/*.bad.'); END IF;
 DBMS_OUTPUT.PUT_LINE('OK: conteos exactos y restricciones habilitadas.');
END;
/
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>USER, cascade=>TRUE)
PROMPT Estadísticas actualizadas. Siguiente paso: Staging/CREACION_STAGING.sql y después Validacion/INSTALAR_VALIDACIONES.sql.
