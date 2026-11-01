-- ==============================================================
-- SECCIÓN 0: PREVALIDACIÓN
-- Descripción: Revisa que se pueda instalar sin tocar nada: sesión sin transacción pendiente,
--   objetos con nombres reservados y contrato del OLTP (33 tablas con sus columnas y tipos).
--   Si algo falla aquí, la base queda igual que antes.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === Nombres reservados por las validaciones ===
-- Si ya existe un objeto con alguno de estos nombres, se detiene en vez de reemplazarlo.
DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM user_objects WHERE object_name IN ('FN_LIMPIAR_TEXTO','FN_NORMALIZAR_CODIGO','FN_ID_TRANSACCION','PR_BLOQUEAR_VALIDACIONES','PR_VALIDAR_OPERACION','PR_DIAGNOSTICAR_VALIDACIONES','FN_VALIDAR_NUMERO','PR_VALIDAR_JSON_NUMEROS','PR_GUARDAR_REGISTRO','PR_PUBLICAR_PLAN','PR_TRASLADAR_ESTUDIANTE','FN_ELEGIR_CALIFICACION','PR_SELECCIONAR_RESULTADO','PR_VALIDAR_CALIFICACION','PR_ANULAR_CALIFICACION','PR_SUSPENDER_BECA','PR_REANUDAR_BECA','PR_RECIBIR_ENTRADA','PR_PROCESAR_ENTRADA','PR_REGISTRAR_CALIFICACION','PR_CORREGIR_CALIFICACION','PR_OTORGAR_BECA','PR_REABRIR_CICLO','PR_REABRIR_PLAZO','PR_DECLARAR_COBERTURA','PR_CONFIGURAR_ACCESO','TRG_VAL_CAT_TIPO_DOCUMENTO','TRG_VAL_CAT_TIPO_INSTITUCION','TRG_VAL_CAT_DEPARTAMENTO','TRG_VAL_CAT_ZONA','TRG_VAL_CAT_MODALIDAD','TRG_VAL_CAT_JORNADA','TRG_VAL_CAT_AREA_CONOCIMIENTO','TRG_VAL_CAT_TIPO_BECA','TRG_VAL_CAT_NIVEL','TRG_VAL_CAT_GRADO','TRG_VAL_MAE_INSTITUCION','TRG_VAL_MAE_PERSONA','TRG_VAL_MAE_ESTUDIANTE','TRG_VAL_MAE_DOCENTE','TRG_VAL_MAE_ASIGNATURA','TRG_VAL_EST_CICLO','TRG_VAL_EST_PERIODO_ACADEMICO','TRG_VAL_EST_INSTITUCION_CICLO','TRG_VAL_EST_CURSO','TRG_VAL_EST_CURSO_ASIGNATURA','TRG_VAL_EST_PONDERACION_PERIODO','TRG_VAL_EST_PLAZO_REGISTRO_NOTAS','TRG_VAL_TRX_ASIGNACION_DOCENTE','TRG_VAL_TRX_INSCRIPCION','TRG_VAL_TRX_CALIFICACION','TRG_VAL_TRX_RESULTADO_PERIODO','TRG_VAL_TRX_SESION_CLASE','TRG_VAL_TRX_ASISTENCIA','TRG_VAL_TRX_BECA','TRG_VAL_TRX_BECA_VIGENCIA','TRG_VAL_TRX_CONTROL_CARGA','PR_CARGAR_STAGING','PR_RECALCULAR_ALCANCE','TRG_STG_CALIFICACIONES_INMUTABLE','TRG_STG_ASISTENCIAS_INMUTABLE','TRG_STG_INSCRIPCIONES_INMUTABLE','TRG_STG_ESTUDIANTES_INMUTABLE','TRG_STG_CICLOS_INMUTABLE','TRG_STG_PERIODOS_INMUTABLE','TRG_STG_CURSOS_INMUTABLE','TRG_STG_CURSOS_ASIGNATURAS_INMUTABLE','TRG_STG_PONDERACIONES_INMUTABLE','TRG_STG_RESULTADOS_PERIODO_INMUTABLE','TRG_STG_SESIONES_INMUTABLE','TRG_STG_ASIGNACIONES_DOCENTES_INMUTABLE','TRG_STG_INSTITUCIONES_INMUTABLE','TRG_STG_INSTITUCIONES_CICLO_INMUTABLE','TRG_STG_GRADOS_INMUTABLE','TRG_STG_NIVELES_INMUTABLE','TRG_STG_BECAS_INMUTABLE','TRG_STG_BECAS_VIGENCIA_INMUTABLE','TRG_STG_PLAZOS_NOTAS_INMUTABLE','TRG_STG_CONTROL_CARGA_INMUTABLE','TRG_STG_ASIGNATURAS_INMUTABLE','TRG_STG_DEPARTAMENTOS_INMUTABLE','TRG_STG_TIPOS_BECA_INMUTABLE','TRG_STG_TIPOS_INSTITUCION_INMUTABLE','TRG_STG_JORNADAS_INMUTABLE','TRG_STG_MODALIDADES_INMUTABLE','TRG_STG_DOCENTES_INMUTABLE','TRG_STG_ZONAS_INMUTABLE','TRG_STG_AREAS_CONOCIMIENTO_INMUTABLE','VW_VAL_NOTAS_VIGENTES','VW_VAL_RESULTADO_VIGENTE','VW_NOTAS_PENDIENTES','VW_ASISTENCIA_PENDIENTE','VW_CONFIGURACION_PENDIENTE','VW_COBERTURA_PENDIENTE','VW_EJECUCIONES_PENDIENTES','VW_AVISOS_CALIDAD','VW_CAPACIDAD_CURSOS','VW_CONTACTOS_REVISAR','VW_POSIBLES_DUPLICADOS','FN_CLASIFICAR_LLEGADA','PR_CONSULTAR_PENDIENTES','PR_CONSULTAR_PROMEDIOS','PR_CERRAR_CICLO','PR_PROGRAMAR_REVISION','PR_PROBAR_VALIDACIONES');IF n>0 THEN RAISE_APPLICATION_ERROR(-20800,'Existe un objeto con nombre reservado por las validaciones; revisar antes de reemplazarlo.');END IF;END;
/

-- === Sesión limpia y tablas de control inexistentes ===
DECLARE n NUMBER; BEGIN
 IF DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(FALSE) IS NOT NULL THEN
  RAISE_APPLICATION_ERROR(-20800,'Instalar en una sesion sin transaccion pendiente.'); END IF;
 SELECT COUNT(*) INTO n FROM user_objects WHERE object_name IN
 ('VAL_REGLA','VAL_REGLA_TABLA','VAL_REGLA_DDL','VAL_GUARDIA','VAL_POLITICA','VAL_INCIDENCIA','VAL_CAMBIO','RAW_ENTRADA_DATOS');
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20800,'Ya existen objetos de esta instalacion: revisar antes de continuar.'); END IF;
END;
/


-- === Contrato del OLTP: tablas, columnas y tipos esperados ===
DECLARE n NUMBER; BEGIN

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_TIPO_DOCUMENTO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_tipo_documento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_DOCUMENTO' AND column_name='ID_TIPO_DOCUMENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_documento.id_tipo_documento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_DOCUMENTO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_documento.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_DOCUMENTO' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_documento.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_DOCUMENTO' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_documento.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_TIPO_INSTITUCION'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_tipo_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_INSTITUCION' AND column_name='ID_TIPO_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_institucion.id_tipo_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_INSTITUCION' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_institucion.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_INSTITUCION' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_institucion.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_INSTITUCION' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_institucion.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_DEPARTAMENTO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_departamento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_DEPARTAMENTO' AND column_name='ID_DEPARTAMENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_departamento.id_departamento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_DEPARTAMENTO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_departamento.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_DEPARTAMENTO' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_departamento.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_DEPARTAMENTO' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_departamento.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_ZONA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_zona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_ZONA' AND column_name='ID_ZONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_zona.id_zona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_ZONA' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_zona.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_ZONA' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_zona.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_MODALIDAD'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_modalidad'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_MODALIDAD' AND column_name='ID_MODALIDAD' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_modalidad.id_modalidad'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_MODALIDAD' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_modalidad.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_MODALIDAD' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_modalidad.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_MODALIDAD' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_modalidad.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_JORNADA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_jornada'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_JORNADA' AND column_name='ID_JORNADA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_jornada.id_jornada'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_JORNADA' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_jornada.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_JORNADA' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_jornada.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_JORNADA' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_jornada.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_AREA_CONOCIMIENTO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_area_conocimiento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_AREA_CONOCIMIENTO' AND column_name='ID_AREA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_area_conocimiento.id_area'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_AREA_CONOCIMIENTO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_area_conocimiento.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_AREA_CONOCIMIENTO' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_area_conocimiento.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_AREA_CONOCIMIENTO' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_area_conocimiento.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_TIPO_BECA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_tipo_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_BECA' AND column_name='ID_TIPO_BECA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_beca.id_tipo_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_BECA' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_beca.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_BECA' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_beca.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_TIPO_BECA' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_tipo_beca.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_NIVEL'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_nivel'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_NIVEL' AND column_name='ID_NIVEL' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_nivel.id_nivel'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_NIVEL' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_nivel.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_NIVEL' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_nivel.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_NIVEL' AND column_name='ORDEN' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_nivel.orden'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='CAT_GRADO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta cat_grado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='ID_GRADO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.id_grado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='ID_NIVEL' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.id_nivel'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='ORDEN' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.orden'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='CAT_GRADO' AND column_name='ES_ULTIMO_GRADO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: cat_grado.es_ultimo_grado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='MAE_INSTITUCION'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta mae_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='ID_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.id_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='CODIGO_INSTITUCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.codigo_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='ID_TIPO_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.id_tipo_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='ID_DEPARTAMENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.id_departamento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='ID_ZONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.id_zona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='PERMITE_BECAS' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.permite_becas'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='DIRECCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.direccion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='TELEFONO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.telefono'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='EMAIL' AND data_type='VARCHAR2' AND char_used='C' AND char_length=254; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.email'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='FECHA_CREACION' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.fecha_creacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_INSTITUCION' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_institucion.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='MAE_PERSONA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta mae_persona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='ID_PERSONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.id_persona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='ID_TIPO_DOCUMENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.id_tipo_documento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='NUMERO_DOCUMENTO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.numero_documento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='PRIMER_NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.primer_nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='SEGUNDO_NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.segundo_nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='PRIMER_APELLIDO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.primer_apellido'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='SEGUNDO_APELLIDO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.segundo_apellido'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='FECHA_NACIMIENTO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.fecha_nacimiento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='SEXO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.sexo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='EMAIL' AND data_type='VARCHAR2' AND char_used='C' AND char_length=254; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.email'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='TELEFONO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.telefono'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='DIRECCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.direccion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_PERSONA' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_persona.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='MAE_ESTUDIANTE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta mae_estudiante'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ESTUDIANTE' AND column_name='ID_ESTUDIANTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_estudiante.id_estudiante'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ESTUDIANTE' AND column_name='ID_PERSONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_estudiante.id_persona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ESTUDIANTE' AND column_name='NIE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_estudiante.nie'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ESTUDIANTE' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_estudiante.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ESTUDIANTE' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_estudiante.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='MAE_DOCENTE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta mae_docente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_DOCENTE' AND column_name='ID_DOCENTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_docente.id_docente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_DOCENTE' AND column_name='ID_PERSONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_docente.id_persona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_DOCENTE' AND column_name='ESPECIALIDAD' AND data_type='VARCHAR2' AND char_used='C' AND char_length=250; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_docente.especialidad'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_DOCENTE' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_docente.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_DOCENTE' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_docente.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='MAE_ASIGNATURA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta mae_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='ID_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.id_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='ID_AREA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.id_area'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='DESCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.descripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='MAE_ASIGNATURA' AND column_name='ACTIVO' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: mae_asignatura.activo'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_CICLO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='ID_CICLO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.id_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='ANIO' AND data_type='NUMBER' AND data_precision=4 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.anio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='FECHA_INICIO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.fecha_inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='FECHA_FIN' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.fecha_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CICLO' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ciclo.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_PERIODO_ACADEMICO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_periodo_academico'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='ID_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.id_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='ID_CICLO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.id_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='NUMERO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.numero'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='FECHA_INICIO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.fecha_inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PERIODO_ACADEMICO' AND column_name='FECHA_FIN' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_periodo_academico.fecha_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_INSTITUCION_CICLO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_institucion_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ID_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.id_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ID_CICLO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.id_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ID_TIPO_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.id_tipo_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ID_DEPARTAMENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.id_departamento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ID_ZONA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.id_zona'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='PERMITE_BECAS' AND data_type='NUMBER' AND data_precision=1 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.permite_becas'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='FECHA_CORTE_MATRICULA' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.fecha_corte_matricula'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_INSTITUCION_CICLO' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_institucion_ciclo.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_CURSO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_curso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_CURSO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_curso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_CICLO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_GRADO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_grado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_JORNADA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_jornada'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ID_MODALIDAD' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.id_modalidad'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='CODIGO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=50; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.codigo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='NOMBRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=150; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.nombre'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='SECCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=20; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.seccion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='CAPACIDAD_MAXIMA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.capacidad_maxima'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_CURSO_ASIGNATURA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_curso_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='ID_CURSO_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.id_curso_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='ID_CURSO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.id_curso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='ID_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.id_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='HORAS_SEMANALES' AND data_type='NUMBER' AND data_precision=8 AND data_scale=4; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.horas_semanales'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='CREDITOS' AND data_type='NUMBER' AND data_precision=8 AND data_scale=4; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.creditos'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='TIPO_RESULTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.tipo_resultado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='REGLA_RECUPERACION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.regla_recuperacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_CURSO_ASIGNATURA' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_curso_asignatura.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_PONDERACION_PERIODO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_ponderacion_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PONDERACION_PERIODO' AND column_name='ID_PONDERACION_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ponderacion_periodo.id_ponderacion_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PONDERACION_PERIODO' AND column_name='ID_CURSO_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ponderacion_periodo.id_curso_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PONDERACION_PERIODO' AND column_name='ID_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ponderacion_periodo.id_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PONDERACION_PERIODO' AND column_name='PESO' AND data_type='NUMBER'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ponderacion_periodo.peso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PONDERACION_PERIODO' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_ponderacion_periodo.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='EST_PLAZO_REGISTRO_NOTAS'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta est_plazo_registro_notas'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ID_PLAZO_REGISTRO_NOTAS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.id_plazo_registro_notas'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ID_INSTITUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.id_institucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ID_CICLO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.id_ciclo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ID_GRADO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.id_grado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ID_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.id_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='TIPO_INTENTO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.tipo_intento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='FECHA_INICIO_RECUPERACION' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.fecha_inicio_recuperacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='FECHA_FIN_RECUPERACION' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.fecha_fin_recuperacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='FECHA_APERTURA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.fecha_apertura_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='FECHA_LIMITE_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.fecha_limite_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='FECHA_CIERRE_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.fecha_cierre_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='EST_PLAZO_REGISTRO_NOTAS' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: est_plazo_registro_notas.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_ASIGNACION_DOCENTE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_asignacion_docente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='ID_ASIGNACION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.id_asignacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='ID_DOCENTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.id_docente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='ID_CURSO_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.id_curso_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='FECHA_ASIGNACION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.fecha_asignacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='FECHA_INICIO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.fecha_inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='FECHA_FIN' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.fecha_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASIGNACION_DOCENTE' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asignacion_docente.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_INSCRIPCION'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='ID_INSCRIPCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.id_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='ID_ESTUDIANTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.id_estudiante'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='ID_CURSO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.id_curso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='FECHA_INSCRIPCION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.fecha_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='FECHA_INICIO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.fecha_inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='FECHA_FIN' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.fecha_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='MOTIVO_FIN_INSCRIPCION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.motivo_fin_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_INSCRIPCION' AND column_name='RESULTADO_CIERRE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_inscripcion.resultado_cierre'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_CALIFICACION'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_calificacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_CALIFICACION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_calificacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_INSCRIPCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_PONDERACION_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_ponderacion_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='TIPO_INTENTO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.tipo_intento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='NUMERO_INTENTO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.numero_intento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='VERSION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.version'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_CALIFICACION_ORDINARIA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_calificacion_ordinaria'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_CALIFICACION_SUSTITUIDA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_calificacion_sustituida'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_ASIGNACION_DOCENTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_asignacion_docente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='ID_DOCENTE_REGISTRA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.id_docente_registra'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='NOTA' AND data_type='NUMBER' AND data_precision=7 AND data_scale=4; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.nota'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='RESULTADO_CUALITATIVO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.resultado_cualitativo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='FECHA_EVALUACION' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.fecha_evaluacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='FECHA_VALIDACION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.fecha_validacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='FECHA_ANULACION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.fecha_anulacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CALIFICACION' AND column_name='MOTIVO_ANULACION' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_calificacion.motivo_anulacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_RESULTADO_PERIODO'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_resultado_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='ID_RESULTADO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.id_resultado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='ID_ESTUDIANTE' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.id_estudiante'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='ID_ASIGNATURA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.id_asignatura'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='ID_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.id_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='ID_CALIFICACION_SELECCIONADA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.id_calificacion_seleccionada'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='VERSION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.version'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='CRITERIO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.criterio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='FECHA_SELECCION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.fecha_seleccion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_RESULTADO_PERIODO' AND column_name='FECHA_CIERRE' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_resultado_periodo.fecha_cierre'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_SESION_CLASE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_sesion_clase'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='ID_SESION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.id_sesion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='ID_PONDERACION_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.id_ponderacion_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='ID_ASIGNACION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.id_asignacion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='FECHA_ACADEMICA' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.fecha_academica'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='INICIO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='FIN' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_SESION_CLASE' AND column_name='OBSERVACIONES' AND data_type='VARCHAR2' AND char_used='C' AND char_length=1000; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_sesion_clase.observaciones'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_ASISTENCIA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_asistencia'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='ID_ASISTENCIA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.id_asistencia'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='ID_INSCRIPCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.id_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='ID_SESION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.id_sesion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='HORA_LLEGADA' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.hora_llegada'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_ASISTENCIA' AND column_name='OBSERVACIONES' AND data_type='VARCHAR2' AND char_used='C' AND char_length=1000; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_asistencia.observaciones'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_BECA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='ID_BECA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.id_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='ID_INSCRIPCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.id_inscripcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='ID_TIPO_BECA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.id_tipo_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='PORCENTAJE' AND data_type='NUMBER' AND data_precision=7 AND data_scale=4; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.porcentaje'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='FECHA_OTORGAMIENTO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.fecha_otorgamiento'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA' AND column_name='OBSERVACIONES' AND data_type='VARCHAR2' AND char_used='C' AND char_length=1000; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca.observaciones'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_BECA_VIGENCIA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_beca_vigencia'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='ID_VIGENCIA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.id_vigencia'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='ID_BECA' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.id_beca'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='FECHA_INICIO' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.fecha_inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='FECHA_FIN' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.fecha_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='MOTIVO_FIN' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.motivo_fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_BECA_VIGENCIA' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_beca_vigencia.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='AUDITORIA_ETL_EVALUACIONES'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta auditoria_etl_evaluaciones'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='ID_EJECUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.id_ejecucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='FUENTE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=500; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.fuente'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='INICIO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.inicio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='FIN' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.fin'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='TOTAL_LEIDOS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.total_leidos'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='INSERTADOS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.insertados'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='ACTUALIZADOS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.actualizados'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='AUDITORIA_ETL_EVALUACIONES' AND column_name='RECHAZADOS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: auditoria_etl_evaluaciones.rechazados'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='ERRORES_ETL_EVALUACIONES'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta errores_etl_evaluaciones'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='ID_ERROR' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.id_error'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='ID_EJECUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.id_ejecucion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='ENTIDAD' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.entidad'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='CLAVE_ORIGEN' AND data_type='VARCHAR2' AND char_used='C' AND char_length=250; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.clave_origen'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='TIPO_ERROR' AND data_type='VARCHAR2' AND char_used='C' AND char_length=100; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.tipo_error'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='DETALLE' AND data_type='VARCHAR2' AND char_used='C' AND char_length=1000; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.detalle'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='JSON_ORIGINAL' AND data_type='CLOB'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.json_original'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='ERRORES_ETL_EVALUACIONES' AND column_name='FECHA_REGISTRO' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: errores_etl_evaluaciones.fecha_registro'); END IF;

SELECT COUNT(*) INTO n FROM user_tables WHERE table_name='TRX_CONTROL_CARGA'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Falta trx_control_carga'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='ID_CONTROL' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.id_control'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='ID_CURSO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.id_curso'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='ID_PERIODO' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.id_periodo'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='DOMINIO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.dominio'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='FECHA_CORTE' AND data_type='DATE'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.fecha_corte'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='ESTADO' AND data_type='VARCHAR2' AND char_used='C' AND char_length=30; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.estado'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='REGISTROS_DECLARADOS' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.registros_declarados'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='FECHA_RECEPCION' AND data_type='TIMESTAMP(6)'; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.fecha_recepcion'); END IF;

SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name='TRX_CONTROL_CARGA' AND column_name='ID_EJECUCION' AND data_type='NUMBER' AND data_precision=10 AND data_scale=0; IF n<>1 THEN RAISE_APPLICATION_ERROR(-20800,'Contrato incompatible: trx_control_carga.id_ejecucion'); END IF;

END;
/
