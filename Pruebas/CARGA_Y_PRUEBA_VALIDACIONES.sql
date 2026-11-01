-- ==============================================================
-- CARGA_Y_PRUEBA_VALIDACIONES.sql: CARGA REAL Y RECHAZOS
-- Descripción: Carga un colegio completo a través de las validaciones y comprueba que rechazan los casos inválidos.
--   Oracle 23ai (también 19c y 21c). Generado por Pruebas/scripts/generar_prueba_carga.py.
-- ==============================================================
-- Requiere: OLTP creado, Validacion/INSTALAR_VALIDACIONES.sql instalado y datos existentes que cumplan las reglas BLOQUEO.
-- Ejecutar COMO SCRIPT en un esquema de pruebas. Una sola vez: los identificadores 99xxxx deben estar libres.
-- Parte 1 carga y confirma (COMMIT) un colegio bilingüe con calendario agosto-junio y bachillerato de 4 períodos:
--   catálogos, institución, ciclo, períodos, plazos, planes publicados, personas (entrada JSON), docentes con cambio
--   de responsable, inscripciones, sesiones, asistencia, notas validadas con recuperación y una beca suspendida y reanudada.
-- Parte 2 intenta cambios inválidos: cada uno debe ser rechazado con el error esperado y se revierte.
-- Parte 3 hace cambios que solo generan avisos/pendientes: no deben bloquear y la regla debe detectarlos; se revierten.
-- El resultado se imprime como OK/FALLO; si hay fallos, el script termina con error -20899 sin deshacer la parte 1.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';
PROMPT 0/3 Comprobaciones previas...
DECLARE n NUMBER; BEGIN
 SELECT COUNT(*) INTO n FROM user_objects WHERE object_name IN ('PR_REGISTRAR_CALIFICACION','PR_VALIDAR_OPERACION','VAL_REGLA') AND status='VALID';
 IF n<>3 THEN RAISE_APPLICATION_ERROR(-20890,'Instalar Validacion/INSTALAR_VALIDACIONES.sql antes de este script.'); END IF;
 SELECT COUNT(*) INTO n FROM (SELECT id_ciclo FROM est_ciclo WHERE id_ciclo BETWEEN 9901 AND 9904 UNION ALL SELECT id_institucion FROM mae_institucion WHERE id_institucion=9901
   UNION ALL SELECT id_persona FROM mae_persona WHERE id_persona BETWEEN 990101 AND 990113);
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20890,'El escenario de prueba ya existe; este script se ejecuta una sola vez por esquema.'); END IF;
 pr_validar_operacion;
END;
/
PROMPT 1/3 Carga del escenario valido...
BEGIN
 INSERT INTO cat_tipo_documento (id_tipo_documento,codigo,descripcion,activo) VALUES (9901,'PRB_DUI','Documento de prueba',1);
 INSERT INTO cat_tipo_institucion (id_tipo_institucion,codigo,descripcion,activo) VALUES (9901,'PRB_PRIVADA','Privada (prueba)',1);
 INSERT INTO cat_departamento (id_departamento,codigo,nombre,activo) VALUES (9901,'PRB-01','Departamento de prueba',1);
 INSERT INTO cat_zona (id_zona,nombre,activo) VALUES (9901,'Zona de prueba',1);
 INSERT INTO cat_modalidad (id_modalidad,codigo,descripcion,activo) VALUES (9901,'PRB_PRESENCIAL','Presencial (prueba)',1);
 INSERT INTO cat_jornada (id_jornada,codigo,descripcion,activo) VALUES (9901,'PRB_MATUTINA','Matutina (prueba)',1);
 INSERT INTO cat_area_conocimiento (id_area,codigo,descripcion,activo) VALUES (9901,'PRB_CIENCIAS','Ciencias (prueba)',1);
 INSERT INTO cat_area_conocimiento (id_area,codigo,descripcion,activo) VALUES (9902,'PRB_LENGUAJE','Lenguaje (prueba)',1);
 INSERT INTO cat_tipo_beca (id_tipo_beca,codigo,descripcion,activo) VALUES (9901,'PRB_MERITO','Mérito académico (prueba)',1);
 INSERT INTO cat_nivel (id_nivel,codigo,nombre,orden) VALUES (9901,'PRB_BAC','Bachillerato (prueba)',9);
 INSERT INTO cat_grado (id_grado,id_nivel,codigo,nombre,orden,es_ultimo_grado) VALUES (9901,9901,'1','Primero de bachillerato (prueba)',1,0);
 INSERT INTO mae_institucion (id_institucion,codigo_institucion,nombre,id_tipo_institucion,id_departamento,id_zona,permite_becas,direccion,telefono,email,fecha_creacion,activo) VALUES (9901,'PRB-CE-001','Colegio Bilingüe de Prueba',9901,9901,9901,1,'Dirección de prueba',NULL,NULL,DATE '2010-01-15',1);
 INSERT INTO est_ciclo (id_ciclo,codigo,nombre,anio,fecha_inicio,fecha_fin,estado) VALUES (9901,'PRB-2025-2026','Año escolar 2025-2026 (prueba)',2025,DATE '2025-08-11',DATE '2026-06-19','ABIERTO');
 INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990101,9901,1,'Período 1',DATE '2025-08-11',DATE '2025-10-17');
 INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990102,9901,2,'Período 2',DATE '2025-10-20',DATE '2025-12-19');
 INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990103,9901,3,'Período 3',DATE '2026-01-12',DATE '2026-03-27');
 INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990104,9901,4,'Período 4',DATE '2026-04-06',DATE '2026-06-19');
 INSERT INTO est_institucion_ciclo (id_institucion,id_ciclo,id_tipo_institucion,id_departamento,id_zona,permite_becas,fecha_corte_matricula,estado) VALUES (9901,9901,9901,9901,9901,1,DATE '2025-09-15','ABIERTO');
 INSERT INTO est_curso (id_curso,id_institucion,id_ciclo,id_grado,id_jornada,id_modalidad,codigo,nombre,seccion,capacidad_maxima,estado) VALUES (9901,9901,9901,9901,9901,9901,'PRB-1BA-A','Primero de bachillerato A (prueba)','A',30,'ACTIVO');
 INSERT INTO mae_asignatura (id_asignatura,codigo,nombre,id_area,descripcion,activo) VALUES (9901,'PRB_MAT','Matemática (prueba)',9901,NULL,1);
 INSERT INTO mae_asignatura (id_asignatura,codigo,nombre,id_area,descripcion,activo) VALUES (9902,'PRB_LEN','Lenguaje (prueba)',9902,NULL,1);
 INSERT INTO est_curso_asignatura (id_curso_asignatura,id_curso,id_asignatura,horas_semanales,creditos,tipo_resultado,regla_recuperacion,estado) VALUES (990101,9901,9901,5,NULL,'NUMERICA','MEJOR_NOTA','ACTIVA');
 INSERT INTO est_curso_asignatura (id_curso_asignatura,id_curso,id_asignatura,horas_semanales,creditos,tipo_resultado,regla_recuperacion,estado) VALUES (990102,9901,9902,4,NULL,'NUMERICA','MEJOR_NOTA','ACTIVA');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010101,990101,990101,25,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010102,990101,990102,25,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010103,990101,990103,25,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010104,990101,990104,25,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010201,990102,990101,1,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010202,990102,990102,1,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010203,990102,990103,1,'BORRADOR');
 INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010204,990102,990104,1,'BORRADOR');
 INSERT INTO est_plazo_registro_notas (id_plazo_registro_notas,id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento,fecha_inicio_recuperacion,fecha_fin_recuperacion,fecha_apertura_registro,fecha_limite_registro,fecha_cierre_registro,estado) VALUES (9901001,9901,9901,9901,990101,'ORDINARIA',NULL,NULL,TIMESTAMP '2025-10-01 00:00:00',TIMESTAMP '2025-10-24 23:59:59',TIMESTAMP '2025-10-24 18:00:00','CERRADA');
 INSERT INTO est_plazo_registro_notas (id_plazo_registro_notas,id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento,fecha_inicio_recuperacion,fecha_fin_recuperacion,fecha_apertura_registro,fecha_limite_registro,fecha_cierre_registro,estado) VALUES (9901002,9901,9901,9901,990102,'ORDINARIA',NULL,NULL,TIMESTAMP '2025-12-01 00:00:00',TIMESTAMP '2025-12-19 23:59:59',TIMESTAMP '2025-12-19 18:00:00','CERRADA');
 INSERT INTO est_plazo_registro_notas (id_plazo_registro_notas,id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento,fecha_inicio_recuperacion,fecha_fin_recuperacion,fecha_apertura_registro,fecha_limite_registro,fecha_cierre_registro,estado) VALUES (9901003,9901,9901,9901,990103,'ORDINARIA',NULL,NULL,TIMESTAMP '2026-03-16 00:00:00',TIMESTAMP '2026-03-31 23:59:59',NULL,'ABIERTA');
 INSERT INTO est_plazo_registro_notas (id_plazo_registro_notas,id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento,fecha_inicio_recuperacion,fecha_fin_recuperacion,fecha_apertura_registro,fecha_limite_registro,fecha_cierre_registro,estado) VALUES (9901004,9901,9901,9901,990104,'ORDINARIA',NULL,NULL,TIMESTAMP '2026-06-08 00:00:00',TIMESTAMP '2026-06-26 23:59:59',NULL,'ABIERTA');
 INSERT INTO est_plazo_registro_notas (id_plazo_registro_notas,id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento,fecha_inicio_recuperacion,fecha_fin_recuperacion,fecha_apertura_registro,fecha_limite_registro,fecha_cierre_registro,estado) VALUES (9901011,9901,9901,9901,990101,'RECUPERACION',DATE '2025-10-27',DATE '2025-10-31',TIMESTAMP '2025-10-27 00:00:00',TIMESTAMP '2025-11-07 23:59:59',TIMESTAMP '2025-11-07 18:00:00','CERRADA');
 pr_publicar_plan(990101);
 pr_publicar_plan(990102);
 pr_guardar_registro('mae_persona',q'~{"id_persona": 990101, "id_tipo_documento": 9901, "numero_documento": "PRB-DOC-001", "primer_nombre": "Marta", "segundo_nombre": null, "primer_apellido": "Docente", "segundo_apellido": "Prueba", "fecha_nacimiento": "1985-04-20", "sexo": "F", "email": "marta@example.invalid", "telefono": null, "direccion": null, "fecha_registro": "2025-07-01 08:00:00"}~');
 pr_guardar_registro('mae_persona',q'~{"id_persona": 990102, "id_tipo_documento": 9901, "numero_documento": "PRB-DOC-002", "primer_nombre": "Raúl", "segundo_nombre": null, "primer_apellido": "Docente", "segundo_apellido": "Prueba", "fecha_nacimiento": "1979-11-02", "sexo": "M", "email": null, "telefono": null, "direccion": null, "fecha_registro": "2025-07-01 08:05:00"}~');
 pr_guardar_registro('mae_persona',q'~{"id_persona": 990111, "id_tipo_documento": null, "numero_documento": null, "primer_nombre": "Andrea", "segundo_nombre": null, "primer_apellido": "Prueba", "segundo_apellido": null, "fecha_nacimiento": "2009-03-10", "sexo": "F", "email": null, "telefono": null, "direccion": null, "fecha_registro": "2025-07-15 09:00:00"}~');
 pr_guardar_registro('mae_persona',q'~{"id_persona": 990112, "id_tipo_documento": null, "numero_documento": null, "primer_nombre": "Bruno", "segundo_nombre": null, "primer_apellido": "Prueba", "segundo_apellido": null, "fecha_nacimiento": "2009-03-11", "sexo": "M", "email": null, "telefono": null, "direccion": null, "fecha_registro": "2025-07-15 09:00:00"}~');
 pr_guardar_registro('mae_persona',q'~{"id_persona": 990113, "id_tipo_documento": null, "numero_documento": null, "primer_nombre": "Camila", "segundo_nombre": null, "primer_apellido": "Prueba", "segundo_apellido": null, "fecha_nacimiento": "2009-03-12", "sexo": "F", "email": null, "telefono": null, "direccion": null, "fecha_registro": "2025-07-15 09:00:00"}~');
 pr_guardar_registro('mae_docente',q'~{"id_docente": 9901, "id_persona": 990101, "especialidad": "Matemática y lenguaje", "fecha_registro": "2025-07-01 08:10:00", "activo": 1}~');
 pr_guardar_registro('mae_docente',q'~{"id_docente": 9902, "id_persona": 990102, "especialidad": "Matemática", "fecha_registro": "2025-07-01 08:15:00", "activo": 1}~');
 pr_guardar_registro('mae_estudiante',q'~{"id_estudiante": 990111, "id_persona": 990111, "nie": "PRB00000001", "fecha_registro": "2025-07-15 09:10:00", "activo": 1}~');
 pr_guardar_registro('mae_estudiante',q'~{"id_estudiante": 990112, "id_persona": 990112, "nie": "PRB00000002", "fecha_registro": "2025-07-15 09:10:00", "activo": 1}~');
 pr_guardar_registro('mae_estudiante',q'~{"id_estudiante": 990113, "id_persona": 990113, "nie": "PRB00000003", "fecha_registro": "2025-07-15 09:10:00", "activo": 1}~');
 INSERT INTO trx_asignacion_docente (id_asignacion,id_docente,id_curso_asignatura,fecha_asignacion,fecha_inicio,fecha_fin,estado) VALUES (990101,9901,990101,TIMESTAMP '2025-08-01 10:00:00',DATE '2025-08-11',DATE '2025-12-19','FINALIZADA');
 INSERT INTO trx_asignacion_docente (id_asignacion,id_docente,id_curso_asignatura,fecha_asignacion,fecha_inicio,fecha_fin,estado) VALUES (990102,9902,990101,TIMESTAMP '2025-12-15 10:00:00',DATE '2026-01-12',NULL,'VIGENTE');
 INSERT INTO trx_asignacion_docente (id_asignacion,id_docente,id_curso_asignatura,fecha_asignacion,fecha_inicio,fecha_fin,estado) VALUES (990103,9901,990102,TIMESTAMP '2025-08-01 10:00:00',DATE '2025-08-11',NULL,'VIGENTE');
 INSERT INTO trx_inscripcion (id_inscripcion,id_estudiante,id_curso,fecha_inscripcion,fecha_inicio,fecha_fin,estado,motivo_fin_inscripcion,resultado_cierre) VALUES (990111,990111,9901,TIMESTAMP '2025-08-04 09:00:00',DATE '2025-08-11',NULL,'VIGENTE',NULL,NULL);
 INSERT INTO trx_inscripcion (id_inscripcion,id_estudiante,id_curso,fecha_inscripcion,fecha_inicio,fecha_fin,estado,motivo_fin_inscripcion,resultado_cierre) VALUES (990112,990112,9901,TIMESTAMP '2025-08-04 09:00:00',DATE '2025-08-11',NULL,'VIGENTE',NULL,NULL);
 INSERT INTO trx_inscripcion (id_inscripcion,id_estudiante,id_curso,fecha_inscripcion,fecha_inicio,fecha_fin,estado,motivo_fin_inscripcion,resultado_cierre) VALUES (990113,990113,9901,TIMESTAMP '2025-08-04 09:00:00',DATE '2025-08-11',NULL,'VIGENTE',NULL,NULL);
 INSERT INTO trx_sesion_clase (id_sesion,id_ponderacion_periodo,id_asignacion,fecha_academica,inicio,fin,estado,observaciones) VALUES (99010001,99010101,990101,DATE '2025-08-18',TIMESTAMP '2025-08-18 07:00:00',TIMESTAMP '2025-08-18 07:45:00','IMPARTIDA',NULL);
 INSERT INTO trx_sesion_clase (id_sesion,id_ponderacion_periodo,id_asignacion,fecha_academica,inicio,fin,estado,observaciones) VALUES (99010002,99010101,990101,DATE '2025-08-20',TIMESTAMP '2025-08-20 07:00:00',TIMESTAMP '2025-08-20 07:45:00','IMPARTIDA',NULL);
 INSERT INTO trx_sesion_clase (id_sesion,id_ponderacion_periodo,id_asignacion,fecha_academica,inicio,fin,estado,observaciones) VALUES (99010003,99010201,990103,DATE '2025-08-18',TIMESTAMP '2025-08-18 08:00:00',TIMESTAMP '2025-08-18 08:45:00','IMPARTIDA',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020001,990111,99010001,'PRESENTE',TIMESTAMP '2025-08-18 07:00:00',TIMESTAMP '2025-08-18 12:00:00',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020002,990112,99010001,'TARDE',TIMESTAMP '2025-08-18 07:12:00',TIMESTAMP '2025-08-18 12:00:00',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020003,990113,99010001,'AUSENTE',NULL,TIMESTAMP '2025-08-18 12:00:00',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020004,990111,99010003,'PRESENTE',TIMESTAMP '2025-08-18 08:00:00',TIMESTAMP '2025-08-18 12:00:00',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020005,990112,99010003,'TARDE',TIMESTAMP '2025-08-18 08:12:00',TIMESTAMP '2025-08-18 12:00:00',NULL);
 INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99020006,990113,99010003,'AUSENTE',NULL,TIMESTAMP '2025-08-18 12:00:00',NULL);
 pr_registrar_calificacion(q'~{"id_calificacion": 99011001, "id_inscripcion": 990111, "id_ponderacion_periodo": 99010101, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 50, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-10", "fecha_registro": "2025-10-15 08:00:00"}~',99012001,TIMESTAMP '2025-10-16 09:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011002, "id_inscripcion": 990112, "id_ponderacion_periodo": 99010101, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 82, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-10", "fecha_registro": "2025-10-15 08:00:00"}~',99012002,TIMESTAMP '2025-10-16 09:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011003, "id_inscripcion": 990113, "id_ponderacion_periodo": 99010101, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 90, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-10", "fecha_registro": "2025-10-15 08:00:00"}~',99012003,TIMESTAMP '2025-10-16 09:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011004, "id_inscripcion": 990111, "id_ponderacion_periodo": 99010201, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990103, "id_docente_registra": 9901, "nota": 70, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-09", "fecha_registro": "2025-10-15 08:30:00"}~',99012004,TIMESTAMP '2025-10-16 09:30:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011005, "id_inscripcion": 990112, "id_ponderacion_periodo": 99010201, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990103, "id_docente_registra": 9901, "nota": 88, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-09", "fecha_registro": "2025-10-15 08:30:00"}~',99012005,TIMESTAMP '2025-10-16 09:30:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011006, "id_inscripcion": 990113, "id_ponderacion_periodo": 99010201, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990103, "id_docente_registra": 9901, "nota": 64, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-09", "fecha_registro": "2025-10-15 08:30:00"}~',99012006,TIMESTAMP '2025-10-16 09:30:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011007, "id_inscripcion": 990111, "id_ponderacion_periodo": 99010101, "tipo_intento": "RECUPERACION", "numero_intento": 2, "version": 1, "id_calificacion_ordinaria": 99011001, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 75, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-29", "fecha_registro": "2025-10-30 10:00:00"}~',99012007,TIMESTAMP '2025-10-30 12:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011008, "id_inscripcion": 990111, "id_ponderacion_periodo": 99010102, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 68, "resultado_cualitativo": null, "fecha_evaluacion": "2025-12-12", "fecha_registro": "2025-12-15 08:00:00"}~',99012008,TIMESTAMP '2025-12-16 09:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011009, "id_inscripcion": 990112, "id_ponderacion_periodo": 99010102, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 74, "resultado_cualitativo": null, "fecha_evaluacion": "2025-12-12", "fecha_registro": "2025-12-15 08:00:00"}~',99012009,TIMESTAMP '2025-12-16 09:00:00');
 pr_registrar_calificacion(q'~{"id_calificacion": 99011010, "id_inscripcion": 990113, "id_ponderacion_periodo": 99010102, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990101, "id_docente_registra": 9901, "nota": 95, "resultado_cualitativo": null, "fecha_evaluacion": "2025-12-12", "fecha_registro": "2025-12-15 08:00:00"}~',99012010,TIMESTAMP '2025-12-16 09:00:00');
 pr_otorgar_beca(q'~{"id_beca": 99013001, "id_inscripcion": 990112, "id_tipo_beca": 9901, "porcentaje": 50, "fecha_otorgamiento": "2025-08-05", "fecha_registro": "2025-08-05 09:00:00", "observaciones": null}~',99013101,DATE '2025-08-11');
 pr_suspender_beca(99013001,DATE '2025-11-30','SUSPENSION');
 pr_reanudar_beca(99013001,99013102,DATE '2026-01-12');
END;
/
COMMIT;
DECLARE c NUMBER; s NUMBER; cr VARCHAR2(30); BEGIN
 SELECT COUNT(*) INTO c FROM trx_calificacion WHERE id_calificacion BETWEEN 99011001 AND 99019999;
 IF c<>10 THEN RAISE_APPLICATION_ERROR(-20891,'Cantidad de notas inesperada: '||c); END IF;
 SELECT id_calificacion_seleccionada,criterio INTO s,cr FROM trx_resultado_periodo WHERE id_estudiante=990111 AND id_asignatura=9901 AND id_periodo=990101 AND version=2;
 IF s<>99011007 OR cr<>'MEJOR_NOTA' THEN RAISE_APPLICATION_ERROR(-20891,'La recuperacion no quedo seleccionada con MEJOR_NOTA.'); END IF;
 SELECT COUNT(*) INTO c FROM trx_beca_vigencia WHERE id_beca=99013001;
 IF c<>2 THEN RAISE_APPLICATION_ERROR(-20891,'La beca debe tener dos intervalos (suspension y reanudacion).'); END IF;
 pr_validar_operacion;
 DBMS_OUTPUT.PUT_LINE('OK    Escenario cargado: '||c||' intervalos de beca, recuperacion seleccionada por MEJOR_NOTA, sin infracciones BLOQUEO.');
END;
/
PROMPT 2/3 y 3/3 Casos invalidos y avisos...
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE v_ok PLS_INTEGER:=0; v_fallos PLS_INTEGER:=0;
 PROCEDURE esperar(p_nombre VARCHAR2,p_bloque VARCHAR2,p_c1 NUMBER,p_c2 NUMBER DEFAULT NULL,p_texto VARCHAR2 DEFAULT NULL) IS
  v_code NUMBER:=0; v_msg VARCHAR2(4000);
 BEGIN
  SAVEPOINT sv_caso;
  BEGIN EXECUTE IMMEDIATE p_bloque; EXCEPTION WHEN OTHERS THEN v_code:=SQLCODE; v_msg:=SQLERRM; END;
  ROLLBACK TO sv_caso;
  IF v_code<>0 AND v_code IN (p_c1,NVL(p_c2,p_c1)) AND (p_texto IS NULL OR INSTR(v_msg,p_texto)>0) THEN
   v_ok:=v_ok+1; DBMS_OUTPUT.PUT_LINE('OK    Rechazado: '||p_nombre||' ('||v_code||')');
  ELSE v_fallos:=v_fallos+1;
   DBMS_OUTPUT.PUT_LINE('FALLO '||p_nombre||': '||CASE WHEN v_code=0 THEN 'no fue rechazado' ELSE SUBSTR(v_msg,1,300) END); END IF;
 END;
 PROCEDURE avisar(p_nombre VARCHAR2,p_bloque VARCHAR2,p_regla VARCHAR2) IS
  q CLOB; n0 NUMBER; n1 NUMBER; v_msg VARCHAR2(4000);
 BEGIN
  SELECT consulta INTO q FROM val_regla WHERE id_regla=p_regla;
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||')' INTO n0;
  SAVEPOINT sv_aviso;
  BEGIN EXECUTE IMMEDIATE p_bloque; EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||')' INTO n1;
  EXCEPTION WHEN OTHERS THEN v_msg:=SQLERRM; END;
  ROLLBACK TO sv_aviso;
  IF v_msg IS NULL AND n1>n0 THEN v_ok:=v_ok+1; DBMS_OUTPUT.PUT_LINE('OK    Aviso sin bloqueo: '||p_nombre||' ('||p_regla||')');
  ELSE v_fallos:=v_fallos+1; DBMS_OUTPUT.PUT_LINE('FALLO '||p_nombre||': '||NVL(SUBSTR(v_msg,1,300),'la regla no lo detecto')); END IF;
 END;
BEGIN
 esperar('Nota mayor que 100',q'#BEGIN pr_guardar_registro('trx_calificacion',q'~{"id_calificacion": 99019001, "id_inscripcion": 990113, "id_ponderacion_periodo": 99010202, "tipo_intento": "ORDINARIA", "numero_intento": 1, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990103, "id_docente_registra": 9901, "nota": 101, "resultado_cualitativo": null, "fecha_evaluacion": "2025-12-10", "fecha_registro": "2025-12-15 08:00:00"}~'); END;#',-2290,-20802);
 esperar('Ordinaria registrada como intento 2',q'#BEGIN pr_guardar_registro('trx_calificacion',q'~{"id_calificacion": 99019001, "id_inscripcion": 990113, "id_ponderacion_periodo": 99010202, "tipo_intento": "ORDINARIA", "numero_intento": 2, "version": 1, "id_calificacion_ordinaria": null, "id_calificacion_sustituida": null, "id_asignacion_docente": 990103, "id_docente_registra": 9901, "nota": 80, "resultado_cualitativo": null, "fecha_evaluacion": "2025-12-10", "fecha_registro": "2025-12-15 08:00:00"}~'); END;#',-2290,-20802);
 esperar('Recuperación a cargo de un docente de otro período',q'#BEGIN pr_guardar_registro('trx_calificacion',q'~{"id_calificacion": 99019001, "id_inscripcion": 990112, "id_ponderacion_periodo": 99010101, "tipo_intento": "RECUPERACION", "numero_intento": 2, "version": 1, "id_calificacion_ordinaria": 99011002, "id_calificacion_sustituida": null, "id_asignacion_docente": 990102, "id_docente_registra": 9901, "nota": 85, "resultado_cualitativo": null, "fecha_evaluacion": "2025-10-29", "fecha_registro": "2025-10-30 10:00:00"}~'); END;#',-20802,NULL,'OPERACION_RECUPERACION_RESPONSABLE');
 esperar('Inscripción ordinaria solapada',q'#BEGIN INSERT INTO trx_inscripcion (id_inscripcion,id_estudiante,id_curso,fecha_inscripcion,fecha_inicio,fecha_fin,estado,motivo_fin_inscripcion,resultado_cierre) VALUES (99019002,990111,9901,TIMESTAMP '2025-08-25 09:00:00',DATE '2025-09-01',NULL,'VIGENTE',NULL,NULL); END;#',-20802,NULL,'OPERACION_INSCRIPCIONES_SOLAPADAS');
 esperar('Dos docentes responsables a la vez',q'#BEGIN INSERT INTO trx_asignacion_docente (id_asignacion,id_docente,id_curso_asignatura,fecha_asignacion,fecha_inicio,fecha_fin,estado) VALUES (99019003,9902,990101,TIMESTAMP '2025-08-25 10:00:00',DATE '2025-09-01',DATE '2025-09-30','VIGENTE'); END;#',-20802,NULL,'OPERACION_ASIGNACIONES_SOLAPADAS');
 esperar('Período fuera de su ciclo',q'#BEGIN INSERT INTO est_ciclo (id_ciclo,codigo,nombre,anio,fecha_inicio,fecha_fin,estado) VALUES (9902,'PRB-NEG-1','Ciclo negativo',2027,DATE '2027-02-01',DATE '2027-11-30','PLANIFICADO'); INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990201,9902,1,'Período 1',DATE '2027-02-01',DATE '2027-12-15'); END;#',-20802,NULL,'OPERACION_PERIODO_CICLO');
 esperar('Sesión que empieza otro día que su fecha académica',q'#BEGIN INSERT INTO trx_sesion_clase (id_sesion,id_ponderacion_periodo,id_asignacion,fecha_academica,inicio,fin,estado,observaciones) VALUES (99019004,99010101,990101,DATE '2025-08-25',TIMESTAMP '2025-08-26 07:00:00',TIMESTAMP '2025-08-26 07:45:00','IMPARTIDA',NULL); END;#',-20802,NULL,'OPERACION_SESION_CONTEXTO');
 esperar('Asistencia registrada antes de terminar la clase',q'#BEGIN INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99019005,990111,99010002,'PRESENTE',TIMESTAMP '2025-08-20 07:00:00',TIMESTAMP '2025-08-20 07:10:00',NULL); END;#',-20802,NULL,'OPERACION_ASISTENCIA_CONTEXTO');
 esperar('Ausente con hora de llegada',q'#BEGIN INSERT INTO trx_asistencia (id_asistencia,id_inscripcion,id_sesion,estado,hora_llegada,fecha_registro,observaciones) VALUES (99019006,990111,99010002,'AUSENTE',TIMESTAMP '2025-08-20 07:05:00',TIMESTAMP '2025-08-20 12:00:00',NULL); END;#',-2290,-20802);
 esperar('Beca mayor al 100 %',q'#BEGIN INSERT INTO trx_beca (id_beca,id_inscripcion,id_tipo_beca,porcentaje,fecha_otorgamiento,fecha_registro,observaciones) VALUES (99019007,990113,9901,150,DATE '2025-08-05',TIMESTAMP '2025-08-05 09:00:00',NULL); END;#',-2290,-20802);
 esperar('Vigencia de beca anterior a la inscripción',q'#BEGIN INSERT INTO trx_beca (id_beca,id_inscripcion,id_tipo_beca,porcentaje,fecha_otorgamiento,fecha_registro,observaciones) VALUES (99019008,990113,9901,30,DATE '2025-07-20',TIMESTAMP '2025-07-20 09:00:00',NULL); INSERT INTO trx_beca_vigencia (id_vigencia,id_beca,fecha_inicio,fecha_fin,motivo_fin,fecha_registro) VALUES (99019009,99019008,DATE '2025-08-01',NULL,NULL,TIMESTAMP '2025-07-20 09:00:00'); END;#',-20802,NULL,'OPERACION_BECA_VIGENCIA');
 esperar('Retiro sin fecha de fin ni motivo',q'#BEGIN UPDATE trx_inscripcion SET estado='RETIRADA' WHERE id_inscripcion=990113; END;#',-2290,-20802);
 esperar('Plan publicado con un período faltante',q'#BEGIN INSERT INTO mae_asignatura (id_asignatura,codigo,nombre,id_area,descripcion,activo) VALUES (9903,'PRB_CIE','Ciencias (prueba)',9901,NULL,1); INSERT INTO est_curso_asignatura (id_curso_asignatura,id_curso,id_asignatura,horas_semanales,creditos,tipo_resultado,regla_recuperacion,estado) VALUES (990103,9901,9903,3,NULL,'NUMERICA','MEJOR_NOTA','ACTIVA'); INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010301,990103,990101,1,'BORRADOR'); INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010302,990103,990102,1,'BORRADOR'); INSERT INTO est_ponderacion_periodo (id_ponderacion_periodo,id_curso_asignatura,id_periodo,peso,estado) VALUES (99010303,990103,990103,1,'BORRADOR'); pr_publicar_plan(990103); END;#',-20810);
 esperar('Modificar una nota ya validada',q'#BEGIN UPDATE trx_calificacion SET nota=60 WHERE id_calificacion=99011002; END;#',-20805);
 esperar('Borrar una calificación',q'#BEGIN DELETE FROM trx_calificacion WHERE id_calificacion=99011002; END;#',-20805);
 esperar('Cambiar el peso de un plan con notas validadas',q'#BEGIN UPDATE est_ponderacion_periodo SET peso=40 WHERE id_ponderacion_periodo=99010101; END;#',-20805);
 esperar('Cerrar el ciclo sin procedimiento',q'#BEGIN UPDATE est_ciclo SET estado='CERRADO' WHERE id_ciclo=9901; END;#',-20805);
 esperar('Entrada JSON: identificador con decimales',q'#BEGIN pr_guardar_registro('cat_zona',q'~{"id_zona":9902.5,"nombre":"Zona decimal","activo":1}~'); END;#',-20803);
 esperar('Entrada JSON: campo desconocido',q'#BEGIN pr_guardar_registro('cat_zona',q'~{"id_zona":9902,"nombre":"Zona extra","activo":1,"color":"rojo"}~'); END;#',-20804);
 avisar('Numeración de períodos con hueco',q'#BEGIN INSERT INTO est_ciclo (id_ciclo,codigo,nombre,anio,fecha_inicio,fecha_fin,estado) VALUES (9903,'PRB-AVISO-1','Ciclo con hueco',2027,DATE '2027-02-01',DATE '2027-11-30','PLANIFICADO'); INSERT INTO est_periodo_academico (id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin) VALUES (990302,9903,2,'Período 2',DATE '2027-02-01',DATE '2027-05-31'); END;#','OPERACION_PERIODOS_CONSECUTIVOS');
 avisar('Año de referencia distinto del inicio del ciclo',q'#BEGIN INSERT INTO est_ciclo (id_ciclo,codigo,nombre,anio,fecha_inicio,fecha_fin,estado) VALUES (9904,'PRB-AVISO-2','Ciclo con año incorrecto',2026,DATE '2027-02-01',DATE '2027-11-30','PLANIFICADO'); END;#','OPERACION_CICLO_ANIO_INICIO');
 avisar('Oferta activa con matrícula y sin plan',q'#BEGIN INSERT INTO mae_asignatura (id_asignatura,codigo,nombre,id_area,descripcion,activo) VALUES (9904,'PRB_ART','Artes (prueba)',9902,NULL,1); INSERT INTO est_curso_asignatura (id_curso_asignatura,id_curso,id_asignatura,horas_semanales,creditos,tipo_resultado,regla_recuperacion,estado) VALUES (990104,9901,9904,2,NULL,'NUMERICA','MEJOR_NOTA','ACTIVA'); END;#','OPERACION_OFERTA_CON_PLAN');
 DBMS_OUTPUT.PUT_LINE('Resultado: '||v_ok||' correctos, '||v_fallos||' fallidos.');
 IF v_fallos>0 THEN RAISE_APPLICATION_ERROR(-20899,v_fallos||' casos no se comportaron como se esperaba.'); END IF;
END;
/
PROMPT Prueba terminada. El escenario valido queda confirmado; los casos invalidos y avisos se revirtieron.
