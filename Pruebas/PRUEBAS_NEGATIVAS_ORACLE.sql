-- ==============================================================
-- PRUEBAS_NEGATIVAS_ORACLE.sql: CASOS INVÁLIDOS EN STAGING
-- Descripción: Mete datos inválidos en las tablas STG y comprueba que cada regla los detecta.
--   Solo toca STG y cada cambio se revierte (SAVEPOINT / ROLLBACK).
-- ==============================================================
-- Oracle Database 23ai (también 19c y 21c). Ejecutar como script en SQL*Plus o SQLcl.
-- Sesión dedicada, sin trabajo pendiente. No usar SYS/SYSTEM.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';

DECLARE v_n NUMBER; BEGIN
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET nota=101 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES WHERE nota IS NOT NULL)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (nota BETWEEN 0 AND 100))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Nota mayor que 100 no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Nota mayor que 100');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET numero_intento=0 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (numero_intento >= 1))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Intento cero no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Intento cero');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET numero_intento=2 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT ((tipo_intento = 'ORDINARIA' AND numero_intento = 1 AND id_calificacion_ordinaria IS NULL) OR (tipo_intento = 'RECUPERACION' AND numero_intento >= 2 AND id_calificacion_ordinaria IS NOT NULL)))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Ordinaria marcada como intento dos no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Ordinaria marcada como intento dos');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_INSCRIPCIONES SET id_curso=-999999 WHERE id_inscripcion=601~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Referencia de curso inexistente no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Referencia de curso inexistente');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET id_ponderacion_periodo=30111 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=n.id_inscripcion JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=n.id_asignacion_docente WHERE i.id_curso<>o.id_curso OR a.id_curso_asignatura<>o.id_curso_asignatura OR i.estado='ANULADA' OR a.estado='ANULADA' OR p.estado<>'PUBLICADO')~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Calificación ligada a otro curso no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Calificación ligada a otro curso');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_ESTUDIANTES SET sexo='X' WHERE id_estudiante=1001~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE NOT (sexo IN ('M','F','OTRO')))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Sexo fuera del dominio no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Sexo fuera del dominio');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~INSERT INTO STG_CALIFICACIONES (id_calificacion,id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento,version,id_calificacion_ordinaria,id_calificacion_sustituida,id_asignacion_docente,id_docente_registra,nota,resultado_cualitativo,fecha_evaluacion,fecha_registro,fecha_validacion,fecha_anulacion,motivo_anulacion,id_ejecucion_carga,fecha_carga) SELECT id_calificacion,id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento,version,id_calificacion_ordinaria,id_calificacion_sustituida,id_asignacion_docente,id_docente_registra,nota,resultado_cualitativo,fecha_evaluacion,fecha_registro,fecha_validacion,fecha_anulacion,motivo_anulacion,id_ejecucion_carga,fecha_carga FROM STG_CALIFICACIONES WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_calificacion) AS duplicados FROM STG_CALIFICACIONES s) q WHERE q.duplicados>1 AND (id_calificacion IS NOT NULL))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Clave académica duplicada no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Clave académica duplicada');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_BECAS_VIGENCIA SET fecha_inicio=DATE '2026-06-01' WHERE id_vigencia=70061~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM STG_BECAS_VIGENCIA v JOIN STG_BECAS b ON b.id_beca=v.id_beca JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE EXISTS (SELECT 1 FROM STG_BECAS_VIGENCIA w WHERE w.id_beca=v.id_beca AND w.id_vigencia<>v.id_vigencia AND v.fecha_inicio<=COALESCE(w.fecha_fin,x.fecha_fin) AND w.fecha_inicio<=COALESCE(v.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Intervalos de beca solapados no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Intervalos de beca solapados');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET fecha_evaluacion=fecha_evaluacion+1/24 WHERE id_calificacion=(SELECT MIN(id_calificacion) FROM STG_CALIFICACIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (fecha_evaluacion = TRUNC(fecha_evaluacion)))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Fecha académica con hora no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Fecha académica con hora');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_SESIONES SET fin=inicio WHERE id_sesion=(SELECT MIN(id_sesion) FROM STG_SESIONES)~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=s.id_asignacion WHERE p.id_curso_asignatura<>a.id_curso_asignatura OR s.fecha_academica<x.fecha_inicio OR s.fecha_academica>x.fecha_fin OR s.fecha_academica<a.fecha_inicio OR s.fecha_academica>COALESCE(a.fecha_fin,x.fecha_fin) OR s.fin<=s.inicio OR TRUNC(s.inicio)<>s.fecha_academica OR a.estado='ANULADA')~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Sesión sin duración positiva no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Sesión sin duración positiva');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_PERIODOS SET fecha_inicio=DATE '2026-04-30' WHERE id_periodo=20262~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PERIODOS p WHERE EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND q.fecha_inicio<=p.fecha_fin AND p.fecha_inicio<=q.fecha_fin))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Períodos con extremo inclusivo solapado no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Períodos con extremo inclusivo solapado');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~INSERT INTO STG_BECAS (id_beca,id_inscripcion,id_tipo_beca,porcentaje,fecha_otorgamiento,fecha_registro,id_ejecucion_carga,fecha_carga) SELECT 999999,id_inscripcion,id_tipo_beca,60,fecha_otorgamiento,fecha_registro,id_ejecucion_carga,fecha_carga FROM STG_BECAS WHERE id_beca=7003~';
    EXECUTE IMMEDIATE q'~INSERT INTO STG_BECAS_VIGENCIA (id_vigencia,id_beca,fecha_inicio,fecha_fin,motivo_fin,fecha_registro,id_ejecucion_carga,fecha_carga) SELECT 999999,999999,fecha_inicio,fecha_fin,motivo_fin,fecha_registro,id_ejecucion_carga,fecha_carga FROM STG_BECAS_VIGENCIA WHERE id_vigencia=70030~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM STG_BECAS_VIGENCIA v JOIN STG_BECAS b ON b.id_beca=v.id_beca JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE (SELECT SUM(z.porcentaje) FROM STG_BECAS_VIGENCIA w JOIN STG_BECAS z ON z.id_beca=w.id_beca WHERE z.id_inscripcion=b.id_inscripcion AND w.fecha_inicio<=v.fecha_inicio AND COALESCE(w.fecha_fin,x.fecha_fin)>=v.fecha_inicio)>100)~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Becas simultáneas suman más de 100 no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Becas simultáneas suman más de 100');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_RESULTADOS_PERIODO SET id_calificacion_seleccionada=10042,fecha_seleccion=TIMESTAMP '2025-12-15 10:00:00' WHERE id_resultado=8041~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM STG_RESULTADOS_PERIODO r WHERE r.id_resultado IN (SELECT x.id_resultado FROM STG_RESULTADOS_PERIODO x JOIN STG_CALIFICACIONES n ON n.id_calificacion=x.id_calificacion_seleccionada JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_CALIFICACIONES m ON m.id_inscripcion=n.id_inscripcion AND m.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE m.fecha_validacion<=x.fecha_seleccion AND (m.fecha_anulacion IS NULL OR m.fecha_anulacion>x.fecha_seleccion) AND ((o.regla_recuperacion='MEJOR_NOTA' AND o.tipo_resultado='NUMERICA' AND m.nota>n.nota) OR (o.regla_recuperacion='ULTIMA_RECUPERACION' AND m.numero_intento>n.numero_intento)) AND NOT EXISTS (SELECT 1 FROM STG_CALIFICACIONES v WHERE v.id_inscripcion=m.id_inscripcion AND v.id_ponderacion_periodo=m.id_ponderacion_periodo AND v.tipo_intento=m.tipo_intento AND v.numero_intento=m.numero_intento AND v.version>m.version AND v.fecha_validacion<=x.fecha_seleccion)))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Selección de recuperación peor bajo MEJOR_NOTA no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Selección de recuperación peor bajo MEJOR_NOTA');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CALIFICACIONES SET nota=70 WHERE id_calificacion=(SELECT id_calificacion_seleccionada FROM STG_RESULTADOS_PERIODO WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=2)~';
    EXECUTE IMMEDIATE q'~UPDATE STG_RESULTADOS_PERIODO SET id_calificacion_seleccionada=(SELECT id_calificacion_seleccionada FROM STG_RESULTADOS_PERIODO WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=1) WHERE id_estudiante=1001 AND id_asignatura=501 AND id_periodo=20251 AND version=2~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM STG_RESULTADOS_PERIODO r JOIN STG_CALIFICACIONES n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE EXISTS (SELECT 1 FROM STG_CALIFICACIONES v WHERE v.id_inscripcion=n.id_inscripcion AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.tipo_intento=n.tipo_intento AND v.numero_intento=n.numero_intento AND v.version>n.version AND v.fecha_validacion<=r.fecha_seleccion))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Selección de una versión ya corregida no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Selección de una versión ya corregida');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_ASIGNACIONES_DOCENTES SET fecha_fin=DATE '2025-08-31' WHERE id_asignacion=2001~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='RECUPERACION' AND (a.fecha_inicio>x.fecha_fin OR COALESCE(a.fecha_fin,x.fecha_fin)<x.fecha_inicio))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Recuperación a cargo de una asignación ajena al período no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Recuperación a cargo de una asignación ajena al período');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_PERIODOS SET numero=5 WHERE id_periodo=20263~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PERIODOS p WHERE EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo GROUP BY q.id_ciclo HAVING MAX(q.numero)<>COUNT(*)) OR EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND ((q.numero<p.numero AND q.fecha_inicio>p.fecha_inicio) OR (q.numero>p.numero AND q.fecha_inicio<p.fecha_inicio))))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Numeración de períodos con hueco no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Numeración de períodos con hueco');
    SAVEPOINT caso_negativo;
    EXECUTE IMMEDIATE q'~UPDATE STG_CICLOS SET anio=2030 WHERE id_ciclo=2024~';
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT c.* FROM STG_CICLOS c WHERE c.anio<>EXTRACT(YEAR FROM c.fecha_inicio))~' INTO v_n;
    IF v_n=0 THEN ROLLBACK TO caso_negativo; RAISE_APPLICATION_ERROR(-20060,'Año de referencia distinto del inicio del ciclo no fue detectado.'); END IF;
    ROLLBACK TO caso_negativo;
    DBMS_OUTPUT.PUT_LINE('OK negativo: Año de referencia distinto del inicio del ciclo');
    ROLLBACK;
END;
/
