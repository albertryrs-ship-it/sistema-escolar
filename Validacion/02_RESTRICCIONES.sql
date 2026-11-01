-- ==============================================================
-- SECCIÓN 2: RESTRICCIONES (CHECK)
-- Descripción: Reglas de una sola fila que Oracle aplica sin código: textos no vacíos y condiciones simples.
--   ENABLE VALIDATE revisa también los datos que ya existen: si alguno no cumple, la instalación se detiene
--   con ORA-02293 y el nombre de la restricción. NOT NULL, claves y demás CHECK ya vienen en SCRIPT_BASE.sql.
--   Oracle no guarda comentarios en las restricciones: la descripción de cada una está aquí y en val_regla.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === CAT_TIPO_DOCUMENTO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_documento ADD CONSTRAINT ck_tipo_documento_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_documento ADD CONSTRAINT ck_tipo_documento_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_TIPO_INSTITUCION ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_institucion ADD CONSTRAINT ck_tipo_institucion_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_institucion ADD CONSTRAINT ck_tipo_institucion_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_DEPARTAMENTO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_departamento ADD CONSTRAINT ck_departamento_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_departamento ADD CONSTRAINT ck_departamento_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_ZONA ===
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_zona ADD CONSTRAINT ck_zona_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_MODALIDAD ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_modalidad ADD CONSTRAINT ck_modalidad_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_modalidad ADD CONSTRAINT ck_modalidad_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_JORNADA ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_jornada ADD CONSTRAINT ck_jornada_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_jornada ADD CONSTRAINT ck_jornada_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_AREA_CONOCIMIENTO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_area_conocimiento ADD CONSTRAINT ck_area_conocimiento_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_area_conocimiento ADD CONSTRAINT ck_area_conocimiento_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_TIPO_BECA ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_beca ADD CONSTRAINT ck_tipo_beca_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- descripcion no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_tipo_beca ADD CONSTRAINT ck_tipo_beca_descripcion_no_vacio CHECK (TRIM(descripcion) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_NIVEL ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_nivel ADD CONSTRAINT ck_nivel_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_nivel ADD CONSTRAINT ck_nivel_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === CAT_GRADO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_grado ADD CONSTRAINT ck_grado_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE cat_grado ADD CONSTRAINT ck_grado_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === MAE_INSTITUCION ===
-- codigo_institucion no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_institucion ADD CONSTRAINT ck_institucion_codigo_institucion_no_vacio CHECK (TRIM(codigo_institucion) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_institucion ADD CONSTRAINT ck_institucion_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;
-- direccion no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_institucion ADD CONSTRAINT ck_institucion_direccion_no_vacio CHECK (TRIM(direccion) IS NOT NULL) ENABLE VALIDATE;

-- === MAE_PERSONA ===
-- primer_nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_persona ADD CONSTRAINT ck_persona_primer_nombre_no_vacio CHECK (TRIM(primer_nombre) IS NOT NULL) ENABLE VALIDATE;
-- primer_apellido no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_persona ADD CONSTRAINT ck_persona_primer_apellido_no_vacio CHECK (TRIM(primer_apellido) IS NOT NULL) ENABLE VALIDATE;

-- === MAE_ESTUDIANTE ===
-- nie no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_estudiante ADD CONSTRAINT ck_estudiante_nie_no_vacio CHECK (TRIM(nie) IS NOT NULL) ENABLE VALIDATE;

-- === MAE_ASIGNATURA ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_asignatura ADD CONSTRAINT ck_asignatura_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE mae_asignatura ADD CONSTRAINT ck_asignatura_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === EST_CICLO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_ciclo ADD CONSTRAINT ck_ciclo_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_ciclo ADD CONSTRAINT ck_ciclo_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === EST_PERIODO_ACADEMICO ===
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_periodo_academico ADD CONSTRAINT ck_periodo_academico_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;

-- === EST_CURSO ===
-- codigo no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_curso ADD CONSTRAINT ck_curso_codigo_no_vacio CHECK (TRIM(codigo) IS NOT NULL) ENABLE VALIDATE;
-- nombre no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_curso ADD CONSTRAINT ck_curso_nombre_no_vacio CHECK (TRIM(nombre) IS NOT NULL) ENABLE VALIDATE;
-- seccion no puede quedar vacío ni ser solo espacios.
ALTER TABLE est_curso ADD CONSTRAINT ck_curso_seccion_no_vacio CHECK (TRIM(seccion) IS NOT NULL) ENABLE VALIDATE;

-- === AUDITORIA_ETL_EVALUACIONES ===
-- fuente no puede quedar vacío ni ser solo espacios.
ALTER TABLE auditoria_etl_evaluaciones ADD CONSTRAINT ck_auditoria_etl_fuente_no_vacio CHECK (TRIM(fuente) IS NOT NULL) ENABLE VALIDATE;

-- === ERRORES_ETL_EVALUACIONES ===
-- entidad no puede quedar vacío ni ser solo espacios.
ALTER TABLE errores_etl_evaluaciones ADD CONSTRAINT ck_errores_etl_entidad_no_vacio CHECK (TRIM(entidad) IS NOT NULL) ENABLE VALIDATE;
-- tipo_error no puede quedar vacío ni ser solo espacios.
ALTER TABLE errores_etl_evaluaciones ADD CONSTRAINT ck_errores_etl_tipo_error_no_vacio CHECK (TRIM(tipo_error) IS NOT NULL) ENABLE VALIDATE;
-- detalle no puede quedar vacío ni ser solo espacios.
ALTER TABLE errores_etl_evaluaciones ADD CONSTRAINT ck_errores_etl_detalle_no_vacio CHECK (TRIM(detalle) IS NOT NULL) ENABLE VALIDATE;

-- === EST_PERIODO_ACADEMICO ===
-- El número de período empieza en 1.
ALTER TABLE est_periodo_academico ADD CONSTRAINT ck_periodo_academico_numero_positivo CHECK (numero>=1) ENABLE VALIDATE;

-- === CAT_NIVEL ===
-- El orden es un entero positivo.
ALTER TABLE cat_nivel ADD CONSTRAINT ck_nivel_orden_positivo CHECK (orden>0) ENABLE VALIDATE;

-- === CAT_GRADO ===
-- El orden es un entero positivo.
ALTER TABLE cat_grado ADD CONSTRAINT ck_grado_orden_positivo CHECK (orden>0) ENABLE VALIDATE;

-- === TRX_ASISTENCIA ===
-- Una ausencia (AUSENTE o JUSTIFICADA) no tiene hora de llegada.
ALTER TABLE trx_asistencia ADD CONSTRAINT ck_asistencia_ausente_sin_llegada CHECK (estado NOT IN ('AUSENTE','JUSTIFICADA') OR hora_llegada IS NULL) ENABLE VALIDATE;

-- === TRX_RESULTADO_PERIODO ===
-- Un resultado se cierra después de seleccionarse, no antes.
ALTER TABLE trx_resultado_periodo ADD CONSTRAINT ck_resultado_periodo_cierre_tras_seleccion CHECK (fecha_cierre IS NULL OR fecha_cierre>=fecha_seleccion) ENABLE VALIDATE;

-- === TRX_INSCRIPCION ===
-- Una inscripción FINALIZADA, RETIRADA o TRASLADADA tiene fecha de fin y motivo.
ALTER TABLE trx_inscripcion ADD CONSTRAINT ck_inscripcion_fin_con_fecha_y_motivo CHECK (estado NOT IN ('FINALIZADA','RETIRADA','TRASLADADA') OR (fecha_fin IS NOT NULL AND TRIM(motivo_fin_inscripcion) IS NOT NULL)) ENABLE VALIDATE;

-- === AUDITORIA_ETL_EVALUACIONES ===
-- Una carga EN_PROCESO no tiene fin; una ERROR o COMPLETADA tiene fin, posterior al inicio.
ALTER TABLE auditoria_etl_evaluaciones ADD CONSTRAINT ck_auditoria_etl_estado_y_fin CHECK ((estado='EN_PROCESO' AND fin IS NULL) OR (estado IN ('ERROR','COMPLETADA') AND fin IS NOT NULL AND fin>=inicio)) ENABLE VALIDATE;
