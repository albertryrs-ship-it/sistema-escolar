-- ==============================================================
-- VALIDAR_MODELOS.sql: REVISIÓN DE REGLAS (SOLO LECTURA)
-- Descripción: Ejecuta las 837 reglas del contrato sobre los datos existentes, sin modificar nada. Las demás reglas
--   del catálogo val_regla (texto no vacío y propias de las validaciones) las revisa pr_diagnosticar_validaciones.
--   Falla solo si una regla BLOQUEO encuentra filas; PENDIENTE y AVISO solo se informan.
--   Funciona con o sin las validaciones instaladas.
-- ==============================================================
-- Oracle Database 23ai (también 19c y 21c). Ejecutar como script en SQL*Plus o SQLcl.
-- Sesión dedicada, sin trabajo pendiente. No usar SYS/SYSTEM.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';

DECLARE v_n NUMBER;v_errores NUMBER:=0;
BEGIN

    -- === OPERACION: CAT_TIPO_DOCUMENTO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_documento s WHERE id_tipo_documento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_NN_id_tipo_documento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_documento s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_documento s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_documento s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_documento s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_documento) AS duplicados FROM cat_tipo_documento s) q WHERE q.duplicados>1 AND (id_tipo_documento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_tipo_documento s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_DOCUMENTO_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_TIPO_INSTITUCION ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_institucion s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_institucion s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_institucion s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_institucion s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_institucion s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_institucion) AS duplicados FROM cat_tipo_institucion s) q WHERE q.duplicados>1 AND (id_tipo_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_tipo_institucion s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_INSTITUCION_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_DEPARTAMENTO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_departamento s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_departamento s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_departamento s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_departamento s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_departamento s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_departamento) AS duplicados FROM cat_departamento s) q WHERE q.duplicados>1 AND (id_departamento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_departamento s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_DEPARTAMENTO_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_ZONA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_zona s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_zona s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_zona s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_zona s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_zona) AS duplicados FROM cat_zona s) q WHERE q.duplicados>1 AND (id_zona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY nombre) AS duplicados FROM cat_zona s) q WHERE q.duplicados>1 AND (nombre IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_ZONA_UK_nombre: '||v_n); END IF;

    -- === OPERACION: CAT_MODALIDAD ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_modalidad s WHERE id_modalidad IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_NN_id_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_modalidad s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_modalidad s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_modalidad s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_modalidad s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_modalidad) AS duplicados FROM cat_modalidad s) q WHERE q.duplicados>1 AND (id_modalidad IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_modalidad s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_MODALIDAD_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_JORNADA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_jornada s WHERE id_jornada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_NN_id_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_jornada s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_jornada s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_jornada s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_jornada s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_jornada) AS duplicados FROM cat_jornada s) q WHERE q.duplicados>1 AND (id_jornada IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_jornada s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_JORNADA_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_AREA_CONOCIMIENTO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_area_conocimiento s WHERE id_area IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_NN_id_area: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_area_conocimiento s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_area_conocimiento s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_area_conocimiento s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_area_conocimiento s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_area) AS duplicados FROM cat_area_conocimiento s) q WHERE q.duplicados>1 AND (id_area IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_area_conocimiento s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_AREA_CONOCIMIENTO_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_TIPO_BECA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_beca s WHERE id_tipo_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_NN_id_tipo_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_beca s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_beca s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_beca s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_tipo_beca s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_beca) AS duplicados FROM cat_tipo_beca s) q WHERE q.duplicados>1 AND (id_tipo_beca IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_tipo_beca s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_TIPO_BECA_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_NIVEL ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_nivel s WHERE id_nivel IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_NN_id_nivel: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_nivel s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_nivel s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_nivel s WHERE orden IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_NN_orden: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_nivel) AS duplicados FROM cat_nivel s) q WHERE q.duplicados>1 AND (id_nivel IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM cat_nivel s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_NIVEL_UK_codigo: '||v_n); END IF;

    -- === OPERACION: CAT_GRADO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE id_nivel IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_id_nivel: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE orden IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_orden: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE es_ultimo_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_NN_es_ultimo_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE NOT (es_ultimo_grado IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_CK_es_ultimo_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_grado) AS duplicados FROM cat_grado s) q WHERE q.duplicados>1 AND (id_grado IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_nivel,codigo) AS duplicados FROM cat_grado s) q WHERE q.duplicados>1 AND (id_nivel IS NOT NULL OR codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_UK_nivel_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM cat_grado s WHERE s.id_nivel IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_nivel p WHERE p.id_nivel=s.id_nivel))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAT_GRADO_FK_nivel: '||v_n); END IF;

    -- === OPERACION: MAE_INSTITUCION ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE codigo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_codigo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE permite_becas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE NOT (permite_becas IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_CK_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE direccion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_direccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE fecha_creacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_fecha_creacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE NOT (fecha_creacion = TRUNC(fecha_creacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_CK_fecha_creacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion) AS duplicados FROM mae_institucion s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo_institucion) AS duplicados FROM mae_institucion s) q WHERE q.duplicados>1 AND (codigo_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_UK_codigo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE s.id_tipo_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_tipo_institucion p WHERE p.id_tipo_institucion=s.id_tipo_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_FK_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE s.id_departamento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_departamento p WHERE p.id_departamento=s.id_departamento))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_FK_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_institucion s WHERE s.id_zona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_zona p WHERE p.id_zona=s.id_zona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_INSTITUCION_FK_zona: '||v_n); END IF;

    -- === OPERACION: MAE_PERSONA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE id_persona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_NN_id_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE primer_nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_NN_primer_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE primer_apellido IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_NN_primer_apellido: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE fecha_nacimiento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_NN_fecha_nacimiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE NOT (fecha_nacimiento = TRUNC(fecha_nacimiento)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_CK_fecha_nacimiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE NOT (sexo IN ('M','F','OTRO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_CK_sexo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE NOT ((id_tipo_documento IS NULL AND numero_documento IS NULL) OR (id_tipo_documento IS NOT NULL AND numero_documento IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_BC_DOCUMENTO_COMPLETO_O_AUSENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_persona) AS duplicados FROM mae_persona s) q WHERE q.duplicados>1 AND (id_persona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_documento,numero_documento) AS duplicados FROM mae_persona s) q WHERE q.duplicados>1 AND (id_tipo_documento IS NOT NULL OR numero_documento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_UK_tipo_documento_numero_documento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_persona s WHERE s.id_tipo_documento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_tipo_documento p WHERE p.id_tipo_documento=s.id_tipo_documento))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_PERSONA_FK_tipo_documento: '||v_n); END IF;

    -- === OPERACION: MAE_ESTUDIANTE ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE id_persona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_NN_id_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE nie IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_NN_nie: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante) AS duplicados FROM mae_estudiante s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_persona) AS duplicados FROM mae_estudiante s) q WHERE q.duplicados>1 AND (id_persona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_UK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY nie) AS duplicados FROM mae_estudiante s) q WHERE q.duplicados>1 AND (nie IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_UK_nie: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_estudiante s WHERE s.id_persona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_persona p WHERE p.id_persona=s.id_persona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ESTUDIANTE_FK_persona: '||v_n); END IF;

    -- === OPERACION: MAE_DOCENTE ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE id_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_NN_id_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE id_persona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_NN_id_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_docente) AS duplicados FROM mae_docente s) q WHERE q.duplicados>1 AND (id_docente IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_persona) AS duplicados FROM mae_docente s) q WHERE q.duplicados>1 AND (id_persona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_UK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_docente s WHERE s.id_persona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_persona p WHERE p.id_persona=s.id_persona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_DOCENTE_FK_persona: '||v_n); END IF;

    -- === OPERACION: MAE_ASIGNATURA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE id_area IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_NN_id_area: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asignatura) AS duplicados FROM mae_asignatura s) q WHERE q.duplicados>1 AND (id_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM mae_asignatura s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM mae_asignatura s WHERE s.id_area IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_area_conocimiento p WHERE p.id_area=s.id_area))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_MAE_ASIGNATURA_FK_area: '||v_n); END IF;

    -- === OPERACION: EST_CICLO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE anio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_anio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE fecha_fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ciclo s WHERE NOT (estado IN ('PLANIFICADO','ABIERTO','CERRADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ciclo) AS duplicados FROM est_ciclo s) q WHERE q.duplicados>1 AND (id_ciclo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM est_ciclo s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CICLO_UK_codigo: '||v_n); END IF;

    -- === OPERACION: EST_PERIODO_ACADEMICO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE numero IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_numero: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE fecha_fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_NN_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_periodo) AS duplicados FROM est_periodo_academico s) q WHERE q.duplicados>1 AND (id_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ciclo,numero) AS duplicados FROM est_periodo_academico s) q WHERE q.duplicados>1 AND (id_ciclo IS NOT NULL OR numero IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_UK_ciclo_numero: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_periodo_academico s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ciclo p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PERIODO_ACADEMICO_FK_ciclo: '||v_n); END IF;

    -- === OPERACION: EST_INSTITUCION_CICLO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE permite_becas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE NOT (permite_becas IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_CK_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE fecha_corte_matricula IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_fecha_corte_matricula: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE NOT (fecha_corte_matricula = TRUNC(fecha_corte_matricula)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_CK_fecha_corte_matricula: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE NOT (estado IN ('PLANIFICADO','ABIERTO','CERRADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo) AS duplicados FROM est_institucion_ciclo s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_institucion p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ciclo p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE s.id_tipo_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_tipo_institucion p WHERE p.id_tipo_institucion=s.id_tipo_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_FK_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE s.id_departamento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_departamento p WHERE p.id_departamento=s.id_departamento))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_FK_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_institucion_ciclo s WHERE s.id_zona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_zona p WHERE p.id_zona=s.id_zona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_INSTITUCION_CICLO_FK_zona: '||v_n); END IF;

    -- === OPERACION: EST_CURSO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_jornada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE id_modalidad IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_id_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE seccion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_seccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE capacidad_maxima IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_capacidad_maxima: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE NOT (capacidad_maxima > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_CK_capacidad_maxima: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE NOT (estado IN ('PLANIFICADO','ACTIVO','CERRADO','ANULADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso) AS duplicados FROM est_curso s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo,id_grado,id_jornada,seccion) AS duplicados FROM est_curso s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL OR id_grado IS NOT NULL OR id_jornada IS NOT NULL OR seccion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_UK_institucion_ciclo_grado_jornada_seccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_institucion p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ciclo p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_grado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_grado p WHERE p.id_grado=s.id_grado))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_jornada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_jornada p WHERE p.id_jornada=s.id_jornada))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_modalidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_modalidad p WHERE p.id_modalidad=s.id_modalidad))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso s WHERE s.id_institucion IS NOT NULL AND s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_institucion_ciclo p WHERE p.id_institucion=s.id_institucion AND p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_FK_institucion_ciclo: '||v_n); END IF;

    -- === OPERACION: EST_CURSO_ASIGNATURA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE horas_semanales IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_horas_semanales: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE NOT (horas_semanales > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_CK_horas_semanales: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE NOT (creditos >= 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_CK_creditos: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE tipo_resultado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_tipo_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE NOT (tipo_resultado IN ('NUMERICA','CUALITATIVA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_CK_tipo_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE regla_recuperacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_regla_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE NOT (regla_recuperacion IN ('MEJOR_NOTA','ULTIMA_RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_CK_regla_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE NOT (estado IN ('PLANIFICADA','ACTIVA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso_asignatura) AS duplicados FROM est_curso_asignatura s) q WHERE q.duplicados>1 AND (id_curso_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso,id_asignatura) AS duplicados FROM est_curso_asignatura s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL OR id_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_UK_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_curso p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_FK_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_curso_asignatura s WHERE s.id_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_asignatura p WHERE p.id_asignatura=s.id_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_CURSO_ASIGNATURA_FK_asignatura: '||v_n); END IF;

    -- === OPERACION: EST_PONDERACION_PERIODO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE peso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_NN_peso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE NOT (peso > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_CK_peso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE NOT (estado IN ('BORRADOR','PUBLICADO','ANULADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ponderacion_periodo) AS duplicados FROM est_ponderacion_periodo s) q WHERE q.duplicados>1 AND (id_ponderacion_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso_asignatura,id_periodo) AS duplicados FROM est_ponderacion_periodo s) q WHERE q.duplicados>1 AND (id_curso_asignatura IS NOT NULL OR id_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_UK_curso_asignatura_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE s.id_curso_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_curso_asignatura p WHERE p.id_curso_asignatura=s.id_curso_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_FK_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_ponderacion_periodo s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_periodo_academico p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PONDERACION_PERIODO_FK_periodo: '||v_n); END IF;

    -- === OPERACION: EST_PLAZO_REGISTRO_NOTAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE id_plazo_registro_notas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_id_plazo_registro_notas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE tipo_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE NOT (tipo_intento IN ('ORDINARIA','RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_CK_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE NOT (fecha_inicio_recuperacion = TRUNC(fecha_inicio_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_CK_fecha_inicio_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE NOT (fecha_fin_recuperacion = TRUNC(fecha_fin_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_CK_fecha_fin_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE fecha_apertura_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_fecha_apertura_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE fecha_limite_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_fecha_limite_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE NOT (estado IN ('PROGRAMADA','ABIERTA','CERRADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE NOT (fecha_apertura_registro <= fecha_limite_registro AND ((estado = 'CERRADA' AND fecha_cierre_registro IS NOT NULL AND fecha_cierre_registro >= fecha_apertura_registro) OR (estado IN ('PROGRAMADA','ABIERTA') AND fecha_cierre_registro IS NULL))))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_BC_PLAZO_CIERRE_COHERENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_plazo_registro_notas) AS duplicados FROM est_plazo_registro_notas s) q WHERE q.duplicados>1 AND (id_plazo_registro_notas IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento) AS duplicados FROM est_plazo_registro_notas s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL OR id_grado IS NOT NULL OR id_periodo IS NOT NULL OR tipo_intento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_UK_institucion_ciclo_grado_periodo_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_institucion p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ciclo p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE s.id_grado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_grado p WHERE p.id_grado=s.id_grado))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_FK_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_periodo_academico p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM est_plazo_registro_notas s WHERE s.id_institucion IS NOT NULL AND s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_institucion_ciclo p WHERE p.id_institucion=s.id_institucion AND p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_EST_PLAZO_REGISTRO_NOTAS_FK_institucion_ciclo: '||v_n); END IF;

    -- === OPERACION: TRX_ASIGNACION_DOCENTE ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE id_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_id_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE id_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_id_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE fecha_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_fecha_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE NOT (estado IN ('PROGRAMADA','VIGENTE','FINALIZADA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asignacion) AS duplicados FROM trx_asignacion_docente s) q WHERE q.duplicados>1 AND (id_asignacion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE s.id_docente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_docente p WHERE p.id_docente=s.id_docente))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_FK_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asignacion_docente s WHERE s.id_curso_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_curso_asignatura p WHERE p.id_curso_asignatura=s.id_curso_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASIGNACION_DOCENTE_FK_curso_asignatura: '||v_n); END IF;

    -- === OPERACION: TRX_INSCRIPCION ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE fecha_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_fecha_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE NOT (estado IN ('VIGENTE','FINALIZADA','RETIRADA','TRASLADADA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE NOT (resultado_cierre IN ('PROMOVIDO','REPITE','GRADUADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_CK_resultado_cierre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion) AS duplicados FROM trx_inscripcion s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante,id_curso,fecha_inicio) AS duplicados FROM trx_inscripcion s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL OR id_curso IS NOT NULL OR fecha_inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_UK_estudiante_curso_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE s.id_estudiante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_estudiante p WHERE p.id_estudiante=s.id_estudiante))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_FK_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_inscripcion s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_curso p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_INSCRIPCION_FK_curso: '||v_n); END IF;

    -- === OPERACION: TRX_CALIFICACION ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE id_calificacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_id_calificacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE tipo_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT (tipo_intento IN ('ORDINARIA','RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_CK_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE numero_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_numero_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT (numero_intento >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_CK_numero_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE version IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT (version >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_CK_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE id_asignacion_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_id_asignacion_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE id_docente_registra IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_id_docente_registra: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT (nota BETWEEN 0 AND 100))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_CK_nota: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE fecha_evaluacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_fecha_evaluacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT (fecha_evaluacion = TRUNC(fecha_evaluacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_CK_fecha_evaluacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT ((tipo_intento = 'ORDINARIA' AND numero_intento = 1 AND id_calificacion_ordinaria IS NULL) OR (tipo_intento = 'RECUPERACION' AND numero_intento >= 2 AND id_calificacion_ordinaria IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT ((nota IS NOT NULL AND resultado_cualitativo IS NULL) OR (nota IS NULL AND resultado_cualitativo IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_BC_RESULTADO_REAL_EXCLUYENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT ((version = 1 AND id_calificacion_sustituida IS NULL) OR (version > 1 AND id_calificacion_sustituida IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_BC_VERSION_CON_ANTECEDENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE NOT ((fecha_validacion IS NULL OR fecha_validacion >= fecha_registro) AND (fecha_anulacion IS NULL OR (fecha_anulacion >= fecha_registro AND motivo_anulacion IS NOT NULL))))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_BC_FECHAS_CALIFICACION_ORDENADAS: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_calificacion) AS duplicados FROM trx_calificacion s) q WHERE q.duplicados>1 AND (id_calificacion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento,version) AS duplicados FROM trx_calificacion s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL OR id_ponderacion_periodo IS NOT NULL OR tipo_intento IS NOT NULL OR numero_intento IS NOT NULL OR version IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_UK_inscripcion_ponderacion_periodo_tipo_intento_numero_intento_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_inscripcion p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_ponderacion_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo=s.id_ponderacion_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_calificacion_ordinaria IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_calificacion p WHERE p.id_calificacion=s.id_calificacion_ordinaria))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_calificacion_ordinaria: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_calificacion_sustituida IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_calificacion p WHERE p.id_calificacion=s.id_calificacion_sustituida))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_calificacion_sustituida: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_asignacion_docente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_asignacion_docente p WHERE p.id_asignacion=s.id_asignacion_docente))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_asignacion_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_calificacion s WHERE s.id_docente_registra IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_docente p WHERE p.id_docente=s.id_docente_registra))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CALIFICACION_FK_docente_registra: '||v_n); END IF;

    -- === OPERACION: TRX_RESULTADO_PERIODO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE id_resultado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_id_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE id_calificacion_seleccionada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_id_calificacion_seleccionada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE version IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE NOT (version >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_CK_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE criterio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_criterio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE NOT (criterio IN ('ORDINARIA','MEJOR_NOTA','ULTIMA_RECUPERACION','CORRECCION','TRASLADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_CK_criterio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE fecha_seleccion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_NN_fecha_seleccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_resultado) AS duplicados FROM trx_resultado_periodo s) q WHERE q.duplicados>1 AND (id_resultado IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo,version) AS duplicados FROM trx_resultado_periodo s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL OR id_asignatura IS NOT NULL OR id_periodo IS NOT NULL OR version IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_UK_estudiante_asignatura_periodo_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE s.id_estudiante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_estudiante p WHERE p.id_estudiante=s.id_estudiante))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_FK_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE s.id_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_asignatura p WHERE p.id_asignatura=s.id_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_FK_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_periodo_academico p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_resultado_periodo s WHERE s.id_calificacion_seleccionada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_calificacion p WHERE p.id_calificacion=s.id_calificacion_seleccionada))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_RESULTADO_PERIODO_FK_calificacion_seleccionada: '||v_n); END IF;

    -- === OPERACION: TRX_SESION_CLASE ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE id_sesion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_id_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE id_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_id_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE fecha_academica IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_fecha_academica: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE NOT (fecha_academica = TRUNC(fecha_academica)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_CK_fecha_academica: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE NOT (estado IN ('PROGRAMADA','IMPARTIDA','CANCELADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_sesion) AS duplicados FROM trx_sesion_clase s) q WHERE q.duplicados>1 AND (id_sesion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ponderacion_periodo,inicio) AS duplicados FROM trx_sesion_clase s) q WHERE q.duplicados>1 AND (id_ponderacion_periodo IS NOT NULL OR inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_UK_ponderacion_periodo_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE s.id_ponderacion_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo=s.id_ponderacion_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_FK_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE s.id_asignacion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_asignacion_docente p WHERE p.id_asignacion=s.id_asignacion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_SESION_CLASE_FK_asignacion: '||v_n); END IF;

    -- === OPERACION: TRX_ASISTENCIA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE id_asistencia IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_NN_id_asistencia: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE id_sesion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_NN_id_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE NOT (estado IN ('PRESENTE','TARDE','AUSENTE','JUSTIFICADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asistencia) AS duplicados FROM trx_asistencia s) q WHERE q.duplicados>1 AND (id_asistencia IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion,id_sesion) AS duplicados FROM trx_asistencia s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL OR id_sesion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_UK_inscripcion_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_inscripcion p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_asistencia s WHERE s.id_sesion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_sesion_clase p WHERE p.id_sesion=s.id_sesion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_ASISTENCIA_FK_sesion: '||v_n); END IF;

    -- === OPERACION: TRX_BECA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE id_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_id_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE id_tipo_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_id_tipo_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE porcentaje IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_porcentaje: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE NOT (porcentaje > 0 AND porcentaje <= 100))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_CK_porcentaje: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE fecha_otorgamiento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_fecha_otorgamiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE NOT (fecha_otorgamiento = TRUNC(fecha_otorgamiento)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_CK_fecha_otorgamiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_beca) AS duplicados FROM trx_beca s) q WHERE q.duplicados>1 AND (id_beca IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_inscripcion p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca s WHERE s.id_tipo_beca IS NOT NULL AND NOT EXISTS (SELECT 1 FROM cat_tipo_beca p WHERE p.id_tipo_beca=s.id_tipo_beca))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_FK_tipo_beca: '||v_n); END IF;

    -- === OPERACION: TRX_BECA_VIGENCIA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE id_vigencia IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_NN_id_vigencia: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE id_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_NN_id_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE NOT (motivo_fin IN ('FIN_VIGENCIA','SUSPENSION','CANCELACION','TRASLADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_CK_motivo_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_vigencia) AS duplicados FROM trx_beca_vigencia s) q WHERE q.duplicados>1 AND (id_vigencia IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_beca,fecha_inicio) AS duplicados FROM trx_beca_vigencia s) q WHERE q.duplicados>1 AND (id_beca IS NOT NULL OR fecha_inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_UK_beca_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_beca_vigencia s WHERE s.id_beca IS NOT NULL AND NOT EXISTS (SELECT 1 FROM trx_beca p WHERE p.id_beca=s.id_beca))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_BECA_VIGENCIA_FK_beca: '||v_n); END IF;

    -- === OPERACION: AUDITORIA_ETL_EVALUACIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE id_ejecucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_id_ejecucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE fuente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_fuente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE NOT (estado IN ('EN_PROCESO','COMPLETADA','ERROR')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE total_leidos IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_total_leidos: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE insertados IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_insertados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE actualizados IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_actualizados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM auditoria_etl_evaluaciones s WHERE rechazados IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_NN_rechazados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ejecucion) AS duplicados FROM auditoria_etl_evaluaciones s) q WHERE q.duplicados>1 AND (id_ejecucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_AUDITORIA_ETL_EVALUACIONES_PK: '||v_n); END IF;

    -- === OPERACION: ERRORES_ETL_EVALUACIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE id_error IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_id_error: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE id_ejecucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_id_ejecucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE entidad IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_entidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE tipo_error IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_tipo_error: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE detalle IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_detalle: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE json_original IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_json_original: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE NOT (json_original IS JSON STRICT))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_CK_json_original: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_error) AS duplicados FROM errores_etl_evaluaciones s) q WHERE q.duplicados>1 AND (id_error IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM errores_etl_evaluaciones s WHERE s.id_ejecucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones p WHERE p.id_ejecucion=s.id_ejecucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ERRORES_ETL_EVALUACIONES_FK_ejecucion: '||v_n); END IF;

    -- === OPERACION: TRX_CONTROL_CARGA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE id_control IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_id_control: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE dominio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_dominio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE NOT (dominio IN ('MATRICULA','NOTAS','ASISTENCIA','BECAS')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_CK_dominio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE fecha_corte IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE NOT (fecha_corte = TRUNC(fecha_corte)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_CK_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE NOT (estado IN ('COMPLETA','PARCIAL','NO_APLICA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE registros_declarados IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_registros_declarados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE NOT (registros_declarados >= 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_CK_registros_declarados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE fecha_recepcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_fecha_recepcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE id_ejecucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_NN_id_ejecucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_control) AS duplicados FROM trx_control_carga s) q WHERE q.duplicados>1 AND (id_control IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso,id_periodo,dominio,fecha_corte) AS duplicados FROM trx_control_carga s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL OR id_periodo IS NOT NULL OR dominio IS NOT NULL OR fecha_corte IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_UK_curso_periodo_dominio_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_curso p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_FK_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM est_periodo_academico p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_control_carga s WHERE s.id_ejecucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones p WHERE p.id_ejecucion=s.id_ejecucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TRX_CONTROL_CARGA_FK_ejecucion: '||v_n); END IF;

    -- === OPERACION: EST_PERIODO_ACADEMICO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_periodo_academico p JOIN est_ciclo c ON c.id_ciclo=p.id_ciclo WHERE (p.numero<1 OR p.numero<>TRUNC(p.numero)) OR p.fecha_inicio<c.fecha_inicio OR p.fecha_fin>c.fecha_fin OR p.fecha_fin<p.fecha_inicio)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PERIODO_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_periodo_academico p WHERE EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND q.fecha_inicio<=p.fecha_fin AND p.fecha_inicio<=q.fecha_fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PERIODOS_SOLAPADOS: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_periodo_academico p WHERE EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo GROUP BY q.id_ciclo HAVING MAX(q.numero)<>COUNT(*)) OR EXISTS (SELECT 1 FROM est_periodo_academico q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND ((q.numero<p.numero AND q.fecha_inicio>p.fecha_inicio) OR (q.numero>p.numero AND q.fecha_inicio<p.fecha_inicio))))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('AVISO OPERACION_PERIODOS_CONSECUTIVOS: '||v_n); END IF;

    -- === OPERACION: EST_CICLO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT c.* FROM est_ciclo c WHERE c.anio<>EXTRACT(YEAR FROM c.fecha_inicio))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('AVISO OPERACION_CICLO_ANIO_INICIO: '||v_n); END IF;

    -- === OPERACION: EST_PONDERACION_PERIODO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_ponderacion_periodo p JOIN est_curso_asignatura a ON a.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo WHERE c.id_ciclo<>x.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PLAN_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo IN (SELECT q.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_curso_asignatura,COUNT(*) OVER (PARTITION BY w.id_curso_asignatura) AS publicados FROM est_ponderacion_periodo w WHERE w.estado='PUBLICADO') q LEFT JOIN est_curso_asignatura a ON a.id_curso_asignatura=q.id_curso_asignatura LEFT JOIN est_curso c ON c.id_curso=a.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM est_periodo_academico GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE q.publicados<>COALESCE(v.periodos,0)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PLAN_COMPLETO: '||v_n); END IF;

    -- === OPERACION: EST_CURSO_ASIGNATURA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT o.* FROM est_curso_asignatura o LEFT JOIN (SELECT id_curso_asignatura,COUNT(*) AS publicados FROM est_ponderacion_periodo WHERE estado='PUBLICADO' GROUP BY id_curso_asignatura) w ON w.id_curso_asignatura=o.id_curso_asignatura LEFT JOIN est_curso c ON c.id_curso=o.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM est_periodo_academico GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE o.estado='ACTIVA' AND EXISTS (SELECT 1 FROM trx_inscripcion i WHERE i.id_curso=o.id_curso AND i.estado<>'ANULADA') AND COALESCE(w.publicados,0)<>COALESCE(v.periodos,0))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('PENDIENTE OPERACION_OFERTA_CON_PLAN: '||v_n); END IF;

    -- === OPERACION: EST_PONDERACION_PERIODO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_ponderacion_periodo p JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso WHERE p.estado='PUBLICADO' AND NOT EXISTS (SELECT 1 FROM est_plazo_registro_notas w WHERE w.id_institucion=c.id_institucion AND w.id_ciclo=c.id_ciclo AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA'))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('PENDIENTE OPERACION_PLAN_CON_PLAZO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM est_ponderacion_periodo p WHERE p.id_ponderacion_periodo IN (SELECT x.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM est_ponderacion_periodo w JOIN est_curso_asignatura a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') x JOIN (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM est_ponderacion_periodo w JOIN est_curso_asignatura a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN est_curso c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') y ON y.id_periodo=x.id_periodo AND y.id_ciclo=x.id_ciclo AND y.id_grado=x.id_grado AND y.id_asignatura=x.id_asignatura WHERE ABS(x.peso*y.total-y.peso*x.total)>0.00000001))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PESOS_COMPARABLES: '||v_n); END IF;

    -- === OPERACION: TRX_INSCRIPCION (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT i.* FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE i.fecha_inicio<x.fecha_inicio OR i.fecha_inicio>x.fecha_fin OR (i.fecha_fin IS NOT NULL AND (i.fecha_fin<i.fecha_inicio OR i.fecha_fin>x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_INSCRIPCION_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT i.* FROM trx_inscripcion i WHERE i.id_inscripcion IN (SELECT w.id_inscripcion FROM (SELECT v.*,LAG(v.max_fin) OVER (PARTITION BY v.id_estudiante,v.id_ciclo ORDER BY v.fecha_inicio,v.id_inscripcion) AS fin_previo FROM (SELECT t.id_inscripcion,t.id_estudiante,c.id_ciclo,t.fecha_inicio,COALESCE(t.fecha_fin,x.fecha_fin) AS fin,MAX(COALESCE(t.fecha_fin,x.fecha_fin)) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion ROWS UNBOUNDED PRECEDING) AS max_fin,LEAD(t.fecha_inicio) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion) AS inicio_siguiente FROM trx_inscripcion t JOIN est_curso c ON c.id_curso=t.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE t.estado<>'ANULADA') v) w WHERE w.fin_previo>=w.fecha_inicio OR w.inicio_siguiente<=w.fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_INSCRIPCIONES_SOLAPADAS: '||v_n); END IF;

    -- === OPERACION: TRX_ASIGNACION_DOCENTE (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM trx_asignacion_docente a JOIN est_curso_asignatura o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE a.fecha_inicio<x.fecha_inicio OR a.fecha_inicio>x.fecha_fin OR (a.fecha_fin IS NOT NULL AND (a.fecha_fin<a.fecha_inicio OR a.fecha_fin>x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ASIGNACION_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM trx_asignacion_docente a JOIN est_curso_asignatura o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN est_curso c ON c.id_curso=o.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE a.estado<>'ANULADA' AND EXISTS (SELECT 1 FROM trx_asignacion_docente b WHERE b.id_asignacion<>a.id_asignacion AND b.id_curso_asignatura=a.id_curso_asignatura AND b.estado<>'ANULADA' AND a.fecha_inicio<=COALESCE(b.fecha_fin,x.fecha_fin) AND b.fecha_inicio<=COALESCE(a.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ASIGNACIONES_SOLAPADAS: '||v_n); END IF;

    -- === OPERACION: EST_PLAZO_REGISTRO_NOTAS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT w.* FROM est_plazo_registro_notas w JOIN est_periodo_academico p ON p.id_periodo=w.id_periodo WHERE w.id_ciclo<>p.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PLAZO_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT w.* FROM est_plazo_registro_notas w WHERE (w.tipo_intento='ORDINARIA' AND (w.fecha_inicio_recuperacion IS NOT NULL OR w.fecha_fin_recuperacion IS NOT NULL)) OR (w.tipo_intento='RECUPERACION' AND (w.fecha_inicio_recuperacion IS NULL OR w.fecha_fin_recuperacion IS NULL OR w.fecha_fin_recuperacion<w.fecha_inicio_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_RECUPERACION_FECHAS: '||v_n); END IF;

    -- === OPERACION: TRX_CALIFICACION (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE i.id_curso<>o.id_curso OR a.id_curso_asignatura<>o.id_curso_asignatura OR i.estado='ANULADA' OR a.estado='ANULADA' OR p.estado<>'PUBLICADO')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CALIFICACION_CONTEXTO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE (o.tipo_resultado='NUMERICA' AND (n.nota IS NULL OR n.resultado_cualitativo IS NOT NULL)) OR (o.tipo_resultado='CUALITATIVA' AND (n.nota IS NOT NULL OR n.resultado_cualitativo IS NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_TIPO_RESULTADO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='ORDINARIA' AND (n.fecha_evaluacion<x.fecha_inicio OR n.fecha_evaluacion>x.fecha_fin OR n.fecha_evaluacion<i.fecha_inicio OR n.fecha_evaluacion>COALESCE(i.fecha_fin,x.fecha_fin) OR n.fecha_evaluacion<a.fecha_inicio OR n.fecha_evaluacion>COALESCE(a.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ORDINARIA_VIGENCIA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='RECUPERACION' AND (a.fecha_inicio>x.fecha_fin OR COALESCE(a.fecha_fin,x.fecha_fin)<x.fecha_inicio))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_RECUPERACION_RESPONSABLE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN trx_calificacion b ON b.id_calificacion=n.id_calificacion_ordinaria WHERE n.tipo_intento='RECUPERACION' AND (b.tipo_intento<>'ORDINARIA' OR b.numero_intento<>1 OR b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.fecha_evaluacion>n.fecha_evaluacion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ORIGEN_RECUPERACION: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN trx_calificacion b ON b.id_calificacion=n.id_calificacion_sustituida WHERE b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.tipo_intento<>n.tipo_intento OR b.numero_intento<>n.numero_intento OR b.version+1<>n.version OR b.fecha_registro>n.fecha_registro)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_VERSION_ANTERIOR: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE n.id_calificacion NOT IN (SELECT m.id_calificacion FROM trx_calificacion m JOIN trx_inscripcion j ON j.id_inscripcion=m.id_inscripcion JOIN est_curso d ON d.id_curso=j.id_curso JOIN est_ponderacion_periodo q ON q.id_ponderacion_periodo=m.id_ponderacion_periodo JOIN est_plazo_registro_notas w ON w.id_institucion=d.id_institucion AND w.id_ciclo=d.id_ciclo AND w.id_grado=d.id_grado AND w.id_periodo=q.id_periodo AND w.tipo_intento=m.tipo_intento WHERE m.fecha_registro>=w.fecha_apertura_registro AND (w.fecha_cierre_registro IS NULL OR m.fecha_registro<=w.fecha_cierre_registro) AND (m.tipo_intento='ORDINARIA' OR m.fecha_evaluacion BETWEEN w.fecha_inicio_recuperacion AND w.fecha_fin_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CAPTURA_AUTORIZADA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM trx_calificacion n WHERE TRUNC(n.fecha_registro)<n.fecha_evaluacion)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_REGISTRO_NO_ANTICIPADO: '||v_n); END IF;

    -- === OPERACION: TRX_RESULTADO_PERIODO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM trx_resultado_periodo r JOIN trx_calificacion n ON n.id_calificacion=r.id_calificacion_seleccionada JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE r.id_estudiante<>i.id_estudiante OR r.id_asignatura<>o.id_asignatura OR r.id_periodo<>p.id_periodo OR n.fecha_validacion IS NULL OR r.fecha_seleccion<n.fecha_validacion OR (r.fecha_cierre IS NOT NULL AND r.fecha_cierre<r.fecha_seleccion) OR (n.fecha_anulacion IS NOT NULL AND n.fecha_anulacion<=r.fecha_seleccion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_RESULTADO_CORRESPONDE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM trx_resultado_periodo r JOIN trx_calificacion n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=n.id_inscripcion AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.tipo_intento=n.tipo_intento AND v.numero_intento=n.numero_intento AND v.version>n.version AND v.fecha_validacion<=r.fecha_seleccion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_SELECCION_VERSION_VIGENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM trx_resultado_periodo r WHERE r.id_resultado IN (SELECT x.id_resultado FROM trx_resultado_periodo x JOIN trx_calificacion n ON n.id_calificacion=x.id_calificacion_seleccionada JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN trx_calificacion m ON m.id_inscripcion=n.id_inscripcion AND m.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE m.fecha_validacion<=x.fecha_seleccion AND (m.fecha_anulacion IS NULL OR m.fecha_anulacion>x.fecha_seleccion) AND ((o.regla_recuperacion='MEJOR_NOTA' AND o.tipo_resultado='NUMERICA' AND m.nota>n.nota) OR (o.regla_recuperacion='ULTIMA_RECUPERACION' AND m.numero_intento>n.numero_intento)) AND NOT EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=m.id_inscripcion AND v.id_ponderacion_periodo=m.id_ponderacion_periodo AND v.tipo_intento=m.tipo_intento AND v.numero_intento=m.numero_intento AND v.version>m.version AND v.fecha_validacion<=x.fecha_seleccion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_SELECCION_POLITICA: '||v_n); END IF;

    -- === OPERACION: TRX_SESION_CLASE (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN est_periodo_academico x ON x.id_periodo=p.id_periodo JOIN trx_asignacion_docente a ON a.id_asignacion=s.id_asignacion WHERE p.id_curso_asignatura<>a.id_curso_asignatura OR s.fecha_academica<x.fecha_inicio OR s.fecha_academica>x.fecha_fin OR s.fecha_academica<a.fecha_inicio OR s.fecha_academica>COALESCE(a.fecha_fin,x.fecha_fin) OR s.fin<=s.inicio OR TRUNC(s.inicio)<>s.fecha_academica OR a.estado='ANULADA')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_SESION_CONTEXTO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM trx_sesion_clase s WHERE s.id_sesion IN (SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,b.id_docente AS k,MAX(t.fin) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM trx_sesion_clase t JOIN trx_asignacion_docente b ON b.id_asignacion=t.id_asignacion WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin UNION SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,z.id_curso AS k,MAX(t.fin) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM trx_sesion_clase t JOIN est_ponderacion_periodo q ON q.id_ponderacion_periodo=t.id_ponderacion_periodo JOIN est_curso_asignatura z ON z.id_curso_asignatura=q.id_curso_asignatura WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_SESIONES_SIMULTANEAS: '||v_n); END IF;

    -- === OPERACION: TRX_ASISTENCIA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM trx_asistencia a JOIN trx_inscripcion i ON i.id_inscripcion=a.id_inscripcion JOIN trx_sesion_clase s ON s.id_sesion=a.id_sesion JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE i.id_curso<>o.id_curso OR i.estado='ANULADA' OR s.estado<>'IMPARTIDA' OR s.fecha_academica<i.fecha_inicio OR s.fecha_academica>COALESCE(i.fecha_fin,x.fecha_fin) OR a.fecha_registro<s.fin OR (a.estado IN ('AUSENTE','JUSTIFICADA') AND a.hora_llegada IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_ASISTENCIA_CONTEXTO: '||v_n); END IF;

    -- === OPERACION: TRX_BECA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT b.* FROM trx_beca b JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_institucion_ciclo h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE h.permite_becas<>1 OR i.estado='ANULADA')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_BECA_HABILITADA: '||v_n); END IF;

    -- === OPERACION: TRX_BECA_VIGENCIA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE v.fecha_inicio<i.fecha_inicio OR v.fecha_inicio>COALESCE(i.fecha_fin,x.fecha_fin) OR (v.fecha_fin IS NOT NULL AND (v.fecha_fin<v.fecha_inicio OR v.fecha_fin>COALESCE(i.fecha_fin,x.fecha_fin))) OR (v.fecha_fin IS NULL AND v.motivo_fin IS NOT NULL) OR (v.fecha_fin IS NOT NULL AND v.motivo_fin IS NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_BECA_VIGENCIA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE EXISTS (SELECT 1 FROM trx_beca_vigencia w WHERE w.id_beca=v.id_beca AND w.id_vigencia<>v.id_vigencia AND v.fecha_inicio<=COALESCE(w.fecha_fin,x.fecha_fin) AND w.fecha_inicio<=COALESCE(v.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_BECA_SOLAPADA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion JOIN est_curso c ON c.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=c.id_ciclo WHERE (SELECT SUM(z.porcentaje) FROM trx_beca_vigencia w JOIN trx_beca z ON z.id_beca=w.id_beca WHERE z.id_inscripcion=b.id_inscripcion AND w.fecha_inicio<=v.fecha_inicio AND COALESCE(w.fecha_fin,x.fecha_fin)>=v.fecha_inicio)>100)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_PORCENTAJE_SIMULTANEO: '||v_n); END IF;

    -- === OPERACION: TRX_CONTROL_CARGA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT z.* FROM trx_control_carga z JOIN est_curso c ON c.id_curso=z.id_curso JOIN est_periodo_academico p ON p.id_periodo=z.id_periodo WHERE c.id_ciclo<>p.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('OPERACION_CONTROL_CICLO: '||v_n); END IF;

    -- === STAGING: STG_CALIFICACIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE id_calificacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_id_calificacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE tipo_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (tipo_intento IN ('ORDINARIA','RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_CK_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE numero_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_numero_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (numero_intento >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_CK_numero_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE version IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (version >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_CK_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE id_asignacion_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_id_asignacion_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE id_docente_registra IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_id_docente_registra: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (nota BETWEEN 0 AND 100))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_CK_nota: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE fecha_evaluacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_fecha_evaluacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT (fecha_evaluacion = TRUNC(fecha_evaluacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_CK_fecha_evaluacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT ((tipo_intento = 'ORDINARIA' AND numero_intento = 1 AND id_calificacion_ordinaria IS NULL) OR (tipo_intento = 'RECUPERACION' AND numero_intento >= 2 AND id_calificacion_ordinaria IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_BC_INTENTO_ORDINARIO_Y_RECUPERACION: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT ((nota IS NOT NULL AND resultado_cualitativo IS NULL) OR (nota IS NULL AND resultado_cualitativo IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_BC_RESULTADO_REAL_EXCLUYENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT ((version = 1 AND id_calificacion_sustituida IS NULL) OR (version > 1 AND id_calificacion_sustituida IS NOT NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_BC_VERSION_CON_ANTECEDENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE NOT ((fecha_validacion IS NULL OR fecha_validacion >= fecha_registro) AND (fecha_anulacion IS NULL OR (fecha_anulacion >= fecha_registro AND motivo_anulacion IS NOT NULL))))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_BC_FECHAS_CALIFICACION_ORDENADAS: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_calificacion) AS duplicados FROM STG_CALIFICACIONES s) q WHERE q.duplicados>1 AND (id_calificacion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,tipo_intento,numero_intento,version) AS duplicados FROM STG_CALIFICACIONES s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL OR id_ponderacion_periodo IS NOT NULL OR tipo_intento IS NOT NULL OR numero_intento IS NOT NULL OR version IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_UK_inscripcion_ponderacion_periodo_tipo_intento_numero_intento_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_ponderacion_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PONDERACIONES p WHERE p.id_ponderacion_periodo=s.id_ponderacion_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_calificacion_ordinaria IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CALIFICACIONES p WHERE p.id_calificacion=s.id_calificacion_ordinaria))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_calificacion_ordinaria: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_calificacion_sustituida IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CALIFICACIONES p WHERE p.id_calificacion=s.id_calificacion_sustituida))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_calificacion_sustituida: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_asignacion_docente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ASIGNACIONES_DOCENTES p WHERE p.id_asignacion=s.id_asignacion_docente))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_asignacion_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_docente_registra IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_DOCENTES p WHERE p.id_docente=s.id_docente_registra))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_FK_docente_registra: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CALIFICACIONES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CALIFICACION_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_ASISTENCIAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE id_asistencia IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_NN_id_asistencia: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE id_sesion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_NN_id_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE NOT (estado IN ('PRESENTE','TARDE','AUSENTE','JUSTIFICADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asistencia) AS duplicados FROM STG_ASISTENCIAS s) q WHERE q.duplicados>1 AND (id_asistencia IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion,id_sesion) AS duplicados FROM STG_ASISTENCIAS s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL OR id_sesion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_UK_inscripcion_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE s.id_sesion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_SESIONES p WHERE p.id_sesion=s.id_sesion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_FK_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASISTENCIAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASISTENCIA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_INSCRIPCIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE fecha_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_fecha_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE NOT (estado IN ('VIGENTE','FINALIZADA','RETIRADA','TRASLADADA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE NOT (resultado_cierre IN ('PROMOVIDO','REPITE','GRADUADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_CK_resultado_cierre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_inscripcion) AS duplicados FROM STG_INSCRIPCIONES s) q WHERE q.duplicados>1 AND (id_inscripcion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante,id_curso,fecha_inicio) AS duplicados FROM STG_INSCRIPCIONES s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL OR id_curso IS NOT NULL OR fecha_inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_UK_estudiante_curso_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE s.id_estudiante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ESTUDIANTES p WHERE p.id_estudiante=s.id_estudiante))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_FK_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_FK_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSCRIPCIONES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_INSCRIPCION_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_ESTUDIANTES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE id_persona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_id_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE nie IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_nie: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE fecha_registro_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_fecha_registro_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE estudiante_activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_estudiante_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE NOT (estudiante_activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_CK_estudiante_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante) AS duplicados FROM STG_ESTUDIANTES s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_persona) AS duplicados FROM STG_ESTUDIANTES s) q WHERE q.duplicados>1 AND (id_persona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_UK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY nie) AS duplicados FROM STG_ESTUDIANTES s) q WHERE q.duplicados>1 AND (nie IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_UK_nie: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE s.id_persona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_persona p WHERE p.id_persona=s.id_persona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_FK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE fecha_nacimiento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_NN_JOIN_fecha_nacimiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE NOT (fecha_nacimiento = TRUNC(fecha_nacimiento)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_CK_JOIN_fecha_nacimiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE NOT (sexo IN ('M','F','OTRO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_CK_JOIN_sexo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ESTUDIANTES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ESTUDIANTE_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_CICLOS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE anio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_anio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE fecha_fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE NOT (estado IN ('PLANIFICADO','ABIERTO','CERRADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ciclo) AS duplicados FROM STG_CICLOS s) q WHERE q.duplicados>1 AND (id_ciclo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_CICLOS s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CICLOS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CICLO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_PERIODOS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE numero IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_numero: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE fecha_fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_NN_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_periodo) AS duplicados FROM STG_PERIODOS s) q WHERE q.duplicados>1 AND (id_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ciclo,numero) AS duplicados FROM STG_PERIODOS s) q WHERE q.duplicados>1 AND (id_ciclo IS NOT NULL OR numero IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_UK_ciclo_numero: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CICLOS p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PERIODOS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PERIODO_ACADEMICO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_CURSOS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_jornada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE id_modalidad IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_id_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE seccion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_seccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE capacidad_maxima IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_capacidad_maxima: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE NOT (capacidad_maxima > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_CK_capacidad_maxima: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE NOT (estado IN ('PLANIFICADO','ACTIVO','CERRADO','ANULADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso) AS duplicados FROM STG_CURSOS s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo,id_grado,id_jornada,seccion) AS duplicados FROM STG_CURSOS s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL OR id_grado IS NOT NULL OR id_jornada IS NOT NULL OR seccion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_UK_institucion_ciclo_grado_jornada_seccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSTITUCIONES p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CICLOS p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_grado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_GRADOS p WHERE p.id_grado=s.id_grado))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_jornada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_JORNADAS p WHERE p.id_jornada=s.id_jornada))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_modalidad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_MODALIDADES p WHERE p.id_modalidad=s.id_modalidad))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_institucion IS NOT NULL AND s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSTITUCIONES_CICLO p WHERE p.id_institucion=s.id_institucion AND p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_FK_institucion_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_CURSOS_ASIGNATURAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE horas_semanales IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_horas_semanales: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE NOT (horas_semanales > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_CK_horas_semanales: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE NOT (creditos >= 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_CK_creditos: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE tipo_resultado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_tipo_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE NOT (tipo_resultado IN ('NUMERICA','CUALITATIVA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_CK_tipo_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE regla_recuperacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_regla_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE NOT (regla_recuperacion IN ('MEJOR_NOTA','ULTIMA_RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_CK_regla_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE NOT (estado IN ('PLANIFICADA','ACTIVA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso_asignatura) AS duplicados FROM STG_CURSOS_ASIGNATURAS s) q WHERE q.duplicados>1 AND (id_curso_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso,id_asignatura) AS duplicados FROM STG_CURSOS_ASIGNATURAS s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL OR id_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_UK_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_FK_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE s.id_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ASIGNATURAS p WHERE p.id_asignatura=s.id_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_FK_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CURSOS_ASIGNATURAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_CURSO_ASIGNATURA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_PONDERACIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE peso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_NN_peso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE NOT (peso > 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_CK_peso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE NOT (estado IN ('BORRADOR','PUBLICADO','ANULADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ponderacion_periodo) AS duplicados FROM STG_PONDERACIONES s) q WHERE q.duplicados>1 AND (id_ponderacion_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso_asignatura,id_periodo) AS duplicados FROM STG_PONDERACIONES s) q WHERE q.duplicados>1 AND (id_curso_asignatura IS NOT NULL OR id_periodo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_UK_curso_asignatura_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE s.id_curso_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS_ASIGNATURAS p WHERE p.id_curso_asignatura=s.id_curso_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_FK_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PERIODOS p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PONDERACIONES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PONDERACION_PERIODO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_RESULTADOS_PERIODO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE id_resultado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_id_resultado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE id_estudiante IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_id_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE id_calificacion_seleccionada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_id_calificacion_seleccionada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE version IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE NOT (version >= 1))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_CK_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE criterio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_criterio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE NOT (criterio IN ('ORDINARIA','MEJOR_NOTA','ULTIMA_RECUPERACION','CORRECCION','TRASLADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_CK_criterio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE fecha_seleccion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_NN_fecha_seleccion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_resultado) AS duplicados FROM STG_RESULTADOS_PERIODO s) q WHERE q.duplicados>1 AND (id_resultado IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo,version) AS duplicados FROM STG_RESULTADOS_PERIODO s) q WHERE q.duplicados>1 AND (id_estudiante IS NOT NULL OR id_asignatura IS NOT NULL OR id_periodo IS NOT NULL OR version IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_UK_estudiante_asignatura_periodo_version: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE s.id_estudiante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ESTUDIANTES p WHERE p.id_estudiante=s.id_estudiante))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_FK_estudiante: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE s.id_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ASIGNATURAS p WHERE p.id_asignatura=s.id_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_FK_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PERIODOS p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE s.id_calificacion_seleccionada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CALIFICACIONES p WHERE p.id_calificacion=s.id_calificacion_seleccionada))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_FK_calificacion_seleccionada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_RESULTADOS_PERIODO s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_RESULTADO_PERIODO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_SESIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE id_sesion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_id_sesion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE id_ponderacion_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_id_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE id_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_id_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE fecha_academica IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_fecha_academica: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE NOT (fecha_academica = TRUNC(fecha_academica)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_CK_fecha_academica: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE fin IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE NOT (estado IN ('PROGRAMADA','IMPARTIDA','CANCELADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_sesion) AS duplicados FROM STG_SESIONES s) q WHERE q.duplicados>1 AND (id_sesion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_ponderacion_periodo,inicio) AS duplicados FROM STG_SESIONES s) q WHERE q.duplicados>1 AND (id_ponderacion_periodo IS NOT NULL OR inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_UK_ponderacion_periodo_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE s.id_ponderacion_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PONDERACIONES p WHERE p.id_ponderacion_periodo=s.id_ponderacion_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_FK_ponderacion_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE s.id_asignacion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ASIGNACIONES_DOCENTES p WHERE p.id_asignacion=s.id_asignacion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_FK_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_SESION_CLASE_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_ASIGNACIONES_DOCENTES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE id_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_id_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE id_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_id_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE id_curso_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_id_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE fecha_asignacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_fecha_asignacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE NOT (estado IN ('PROGRAMADA','VIGENTE','FINALIZADA','ANULADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asignacion) AS duplicados FROM STG_ASIGNACIONES_DOCENTES s) q WHERE q.duplicados>1 AND (id_asignacion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE s.id_docente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_DOCENTES p WHERE p.id_docente=s.id_docente))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_FK_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE s.id_curso_asignatura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS_ASIGNATURAS p WHERE p.id_curso_asignatura=s.id_curso_asignatura))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_FK_curso_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNACIONES_DOCENTES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_ASIGNACION_DOCENTE_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_INSTITUCIONES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE codigo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_codigo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE permite_becas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE NOT (permite_becas IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_CK_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE fecha_creacion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_fecha_creacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE NOT (fecha_creacion = TRUNC(fecha_creacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_CK_fecha_creacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion) AS duplicados FROM STG_INSTITUCIONES s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo_institucion) AS duplicados FROM STG_INSTITUCIONES s) q WHERE q.duplicados>1 AND (codigo_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_UK_codigo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE s.id_tipo_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_TIPOS_INSTITUCION p WHERE p.id_tipo_institucion=s.id_tipo_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_FK_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE s.id_departamento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_DEPARTAMENTOS p WHERE p.id_departamento=s.id_departamento))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_FK_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE s.id_zona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ZONAS p WHERE p.id_zona=s.id_zona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_FK_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_INSTITUCION_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_INSTITUCIONES_CICLO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE permite_becas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE NOT (permite_becas IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_CK_permite_becas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE fecha_corte_matricula IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_fecha_corte_matricula: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE NOT (fecha_corte_matricula = TRUNC(fecha_corte_matricula)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_CK_fecha_corte_matricula: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE NOT (estado IN ('PLANIFICADO','ABIERTO','CERRADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo) AS duplicados FROM STG_INSTITUCIONES_CICLO s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSTITUCIONES p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CICLOS p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_tipo_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_TIPOS_INSTITUCION p WHERE p.id_tipo_institucion=s.id_tipo_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_FK_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_departamento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_DEPARTAMENTOS p WHERE p.id_departamento=s.id_departamento))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_FK_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_zona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_ZONAS p WHERE p.id_zona=s.id_zona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_FK_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_INSTITUCIONES_CICLO s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_INSTITUCION_CICLO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_GRADOS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE id_nivel IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_id_nivel: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE orden IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_orden: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE es_ultimo_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_NN_es_ultimo_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE NOT (es_ultimo_grado IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_CK_es_ultimo_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_grado) AS duplicados FROM STG_GRADOS s) q WHERE q.duplicados>1 AND (id_grado IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_nivel,codigo) AS duplicados FROM STG_GRADOS s) q WHERE q.duplicados>1 AND (id_nivel IS NOT NULL OR codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_UK_nivel_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE s.id_nivel IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_NIVELES p WHERE p.id_nivel=s.id_nivel))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_FK_nivel: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_GRADOS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_GRADO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_NIVELES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_NIVELES s WHERE id_nivel IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_NN_id_nivel: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_NIVELES s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_NIVELES s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_NIVELES s WHERE orden IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_NN_orden: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_nivel) AS duplicados FROM STG_NIVELES s) q WHERE q.duplicados>1 AND (id_nivel IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_NIVELES s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_NIVELES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_NIVEL_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_BECAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE id_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_id_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE id_inscripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_id_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE id_tipo_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_id_tipo_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE porcentaje IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_porcentaje: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE NOT (porcentaje > 0 AND porcentaje <= 100))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_CK_porcentaje: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE fecha_otorgamiento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_fecha_otorgamiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE NOT (fecha_otorgamiento = TRUNC(fecha_otorgamiento)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_CK_fecha_otorgamiento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_beca) AS duplicados FROM STG_BECAS s) q WHERE q.duplicados>1 AND (id_beca IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE s.id_inscripcion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES p WHERE p.id_inscripcion=s.id_inscripcion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_FK_inscripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE s.id_tipo_beca IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_TIPOS_BECA p WHERE p.id_tipo_beca=s.id_tipo_beca))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_FK_tipo_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_BECAS_VIGENCIA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE id_vigencia IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_NN_id_vigencia: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE id_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_NN_id_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE fecha_inicio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_NN_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE NOT (fecha_inicio = TRUNC(fecha_inicio)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_CK_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE NOT (fecha_fin = TRUNC(fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_CK_fecha_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE NOT (motivo_fin IN ('FIN_VIGENCIA','SUSPENSION','CANCELACION','TRASLADO')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_CK_motivo_fin: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE fecha_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_NN_fecha_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_vigencia) AS duplicados FROM STG_BECAS_VIGENCIA s) q WHERE q.duplicados>1 AND (id_vigencia IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_beca,fecha_inicio) AS duplicados FROM STG_BECAS_VIGENCIA s) q WHERE q.duplicados>1 AND (id_beca IS NOT NULL OR fecha_inicio IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_UK_beca_fecha_inicio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE s.id_beca IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_BECAS p WHERE p.id_beca=s.id_beca))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_FK_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_BECAS_VIGENCIA s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_BECA_VIGENCIA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_PLAZOS_NOTAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE id_plazo_registro_notas IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_id_plazo_registro_notas: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE id_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_id_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE id_ciclo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_id_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE id_grado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_id_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE tipo_intento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE NOT (tipo_intento IN ('ORDINARIA','RECUPERACION')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_CK_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE NOT (fecha_inicio_recuperacion = TRUNC(fecha_inicio_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_CK_fecha_inicio_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE NOT (fecha_fin_recuperacion = TRUNC(fecha_fin_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_CK_fecha_fin_recuperacion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE fecha_apertura_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_fecha_apertura_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE fecha_limite_registro IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_fecha_limite_registro: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE NOT (estado IN ('PROGRAMADA','ABIERTA','CERRADA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE NOT (fecha_apertura_registro <= fecha_limite_registro AND ((estado = 'CERRADA' AND fecha_cierre_registro IS NOT NULL AND fecha_cierre_registro >= fecha_apertura_registro) OR (estado IN ('PROGRAMADA','ABIERTA') AND fecha_cierre_registro IS NULL))))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_BC_PLAZO_CIERRE_COHERENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_plazo_registro_notas) AS duplicados FROM STG_PLAZOS_NOTAS s) q WHERE q.duplicados>1 AND (id_plazo_registro_notas IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_institucion,id_ciclo,id_grado,id_periodo,tipo_intento) AS duplicados FROM STG_PLAZOS_NOTAS s) q WHERE q.duplicados>1 AND (id_institucion IS NOT NULL OR id_ciclo IS NOT NULL OR id_grado IS NOT NULL OR id_periodo IS NOT NULL OR tipo_intento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_UK_institucion_ciclo_grado_periodo_tipo_intento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_institucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSTITUCIONES p WHERE p.id_institucion=s.id_institucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_FK_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CICLOS p WHERE p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_FK_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_grado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_GRADOS p WHERE p.id_grado=s.id_grado))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_FK_grado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PERIODOS p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_institucion IS NOT NULL AND s.id_ciclo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_INSTITUCIONES_CICLO p WHERE p.id_institucion=s.id_institucion AND p.id_ciclo=s.id_ciclo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_FK_institucion_ciclo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_PLAZOS_NOTAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_EST_PLAZO_REGISTRO_NOTAS_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_CONTROL_CARGA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE id_control IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_id_control: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE id_curso IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_id_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE id_periodo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_id_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE dominio IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_dominio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE NOT (dominio IN ('MATRICULA','NOTAS','ASISTENCIA','BECAS')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_CK_dominio: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE fecha_corte IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE NOT (fecha_corte = TRUNC(fecha_corte)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_CK_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE estado IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE NOT (estado IN ('COMPLETA','PARCIAL','NO_APLICA')))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_CK_estado: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE registros_declarados IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_registros_declarados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE NOT (registros_declarados >= 0))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_CK_registros_declarados: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE fecha_recepcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_fecha_recepcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE id_ejecucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_NN_id_ejecucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_control) AS duplicados FROM STG_CONTROL_CARGA s) q WHERE q.duplicados>1 AND (id_control IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_curso,id_periodo,dominio,fecha_corte) AS duplicados FROM STG_CONTROL_CARGA s) q WHERE q.duplicados>1 AND (id_curso IS NOT NULL OR id_periodo IS NOT NULL OR dominio IS NOT NULL OR fecha_corte IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_UK_curso_periodo_dominio_fecha_corte: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE s.id_curso IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_CURSOS p WHERE p.id_curso=s.id_curso))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_FK_curso: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE s.id_periodo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_PERIODOS p WHERE p.id_periodo=s.id_periodo))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_FK_periodo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE s.id_ejecucion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones p WHERE p.id_ejecucion=s.id_ejecucion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_FK_ejecucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_CONTROL_CARGA s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TRX_CONTROL_CARGA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_ASIGNATURAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE id_asignatura IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_NN_id_asignatura: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE id_area IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_NN_id_area: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_asignatura) AS duplicados FROM STG_ASIGNATURAS s) q WHERE q.duplicados>1 AND (id_asignatura IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_ASIGNATURAS s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE s.id_area IS NOT NULL AND NOT EXISTS (SELECT 1 FROM STG_AREAS_CONOCIMIENTO p WHERE p.id_area=s.id_area))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_FK_area: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ASIGNATURAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_ASIGNATURA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_DEPARTAMENTOS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE id_departamento IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_NN_id_departamento: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_departamento) AS duplicados FROM STG_DEPARTAMENTOS s) q WHERE q.duplicados>1 AND (id_departamento IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_DEPARTAMENTOS s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DEPARTAMENTOS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_DEPARTAMENTO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_TIPOS_BECA ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE id_tipo_beca IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_NN_id_tipo_beca: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_beca) AS duplicados FROM STG_TIPOS_BECA s) q WHERE q.duplicados>1 AND (id_tipo_beca IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_TIPOS_BECA s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_BECA s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_BECA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_TIPOS_INSTITUCION ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE id_tipo_institucion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_NN_id_tipo_institucion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_tipo_institucion) AS duplicados FROM STG_TIPOS_INSTITUCION s) q WHERE q.duplicados>1 AND (id_tipo_institucion IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_TIPOS_INSTITUCION s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_TIPOS_INSTITUCION s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_TIPO_INSTITUCION_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_JORNADAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE id_jornada IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_NN_id_jornada: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_jornada) AS duplicados FROM STG_JORNADAS s) q WHERE q.duplicados>1 AND (id_jornada IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_JORNADAS s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_JORNADAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_JORNADA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_MODALIDADES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE id_modalidad IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_NN_id_modalidad: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_modalidad) AS duplicados FROM STG_MODALIDADES s) q WHERE q.duplicados>1 AND (id_modalidad IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_MODALIDADES s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_MODALIDADES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_MODALIDAD_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_DOCENTES ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE id_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_id_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE id_persona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_id_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE fecha_registro_docente IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_fecha_registro_docente: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE docente_activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_docente_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE NOT (docente_activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_CK_docente_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_docente) AS duplicados FROM STG_DOCENTES s) q WHERE q.duplicados>1 AND (id_docente IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_persona) AS duplicados FROM STG_DOCENTES s) q WHERE q.duplicados>1 AND (id_persona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_UK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE s.id_persona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM mae_persona p WHERE p.id_persona=s.id_persona))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_FK_persona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE primer_nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_JOIN_primer_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE primer_apellido IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_NN_JOIN_primer_apellido: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_DOCENTES s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_MAE_DOCENTE_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_ZONAS ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ZONAS s WHERE id_zona IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_NN_id_zona: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ZONAS s WHERE nombre IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_NN_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ZONAS s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ZONAS s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_zona) AS duplicados FROM STG_ZONAS s) q WHERE q.duplicados>1 AND (id_zona IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY nombre) AS duplicados FROM STG_ZONAS s) q WHERE q.duplicados>1 AND (nombre IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_UK_nombre: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_ZONAS s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_ZONA_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_AREAS_CONOCIMIENTO ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE id_area IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_NN_id_area: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE codigo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_NN_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE descripcion IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_NN_descripcion: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE activo IS NULL)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_NN_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE NOT (activo IN (0,1)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_CK_activo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY id_area) AS duplicados FROM STG_AREAS_CONOCIMIENTO s) q WHERE q.duplicados>1 AND (id_area IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_PK: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT q.* FROM (SELECT s.*,COUNT(*) OVER (PARTITION BY codigo) AS duplicados FROM STG_AREAS_CONOCIMIENTO s) q WHERE q.duplicados>1 AND (codigo IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_UK_codigo: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_AREAS_CONOCIMIENTO s WHERE s.id_ejecucion_carga IS NULL OR s.fecha_carga IS NULL OR NOT EXISTS (SELECT 1 FROM auditoria_etl_evaluaciones a WHERE a.id_ejecucion=s.id_ejecucion_carga AND a.inicio<=s.fecha_carga))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAT_AREA_CONOCIMIENTO_METADATOS: '||v_n); END IF;

    -- === STAGING: STG_PERIODOS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PERIODOS p JOIN STG_CICLOS c ON c.id_ciclo=p.id_ciclo WHERE (p.numero<1 OR p.numero<>TRUNC(p.numero)) OR p.fecha_inicio<c.fecha_inicio OR p.fecha_fin>c.fecha_fin OR p.fecha_fin<p.fecha_inicio)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PERIODO_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PERIODOS p WHERE EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND q.fecha_inicio<=p.fecha_fin AND p.fecha_inicio<=q.fecha_fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PERIODOS_SOLAPADOS: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PERIODOS p WHERE EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo GROUP BY q.id_ciclo HAVING MAX(q.numero)<>COUNT(*)) OR EXISTS (SELECT 1 FROM STG_PERIODOS q WHERE q.id_ciclo=p.id_ciclo AND q.id_periodo<>p.id_periodo AND ((q.numero<p.numero AND q.fecha_inicio>p.fecha_inicio) OR (q.numero>p.numero AND q.fecha_inicio<p.fecha_inicio))))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('AVISO STAGING_PERIODOS_CONSECUTIVOS: '||v_n); END IF;

    -- === STAGING: STG_CICLOS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT c.* FROM STG_CICLOS c WHERE c.anio<>EXTRACT(YEAR FROM c.fecha_inicio))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('AVISO STAGING_CICLO_ANIO_INICIO: '||v_n); END IF;

    -- === STAGING: STG_PONDERACIONES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PONDERACIONES p JOIN STG_CURSOS_ASIGNATURAS a ON a.id_curso_asignatura=p.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=a.id_curso JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo WHERE c.id_ciclo<>x.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PLAN_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PONDERACIONES p WHERE p.id_ponderacion_periodo IN (SELECT q.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_curso_asignatura,COUNT(*) OVER (PARTITION BY w.id_curso_asignatura) AS publicados FROM STG_PONDERACIONES w WHERE w.estado='PUBLICADO') q LEFT JOIN STG_CURSOS_ASIGNATURAS a ON a.id_curso_asignatura=q.id_curso_asignatura LEFT JOIN STG_CURSOS c ON c.id_curso=a.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM STG_PERIODOS GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE q.publicados<>COALESCE(v.periodos,0)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PLAN_COMPLETO: '||v_n); END IF;

    -- === STAGING: STG_CURSOS_ASIGNATURAS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT o.* FROM STG_CURSOS_ASIGNATURAS o LEFT JOIN (SELECT id_curso_asignatura,COUNT(*) AS publicados FROM STG_PONDERACIONES WHERE estado='PUBLICADO' GROUP BY id_curso_asignatura) w ON w.id_curso_asignatura=o.id_curso_asignatura LEFT JOIN STG_CURSOS c ON c.id_curso=o.id_curso LEFT JOIN (SELECT id_ciclo,COUNT(*) AS periodos FROM STG_PERIODOS GROUP BY id_ciclo) v ON v.id_ciclo=c.id_ciclo WHERE o.estado='ACTIVA' AND EXISTS (SELECT 1 FROM STG_INSCRIPCIONES i WHERE i.id_curso=o.id_curso AND i.estado<>'ANULADA') AND COALESCE(w.publicados,0)<>COALESCE(v.periodos,0))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('PENDIENTE STAGING_OFERTA_CON_PLAN: '||v_n); END IF;

    -- === STAGING: STG_PONDERACIONES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PONDERACIONES p JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=o.id_curso WHERE p.estado='PUBLICADO' AND NOT EXISTS (SELECT 1 FROM STG_PLAZOS_NOTAS w WHERE w.id_institucion=c.id_institucion AND w.id_ciclo=c.id_ciclo AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA'))~' INTO v_n;
    IF v_n>0 THEN DBMS_OUTPUT.PUT_LINE('PENDIENTE STAGING_PLAN_CON_PLAZO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT p.* FROM STG_PONDERACIONES p WHERE p.id_ponderacion_periodo IN (SELECT x.id_ponderacion_periodo FROM (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM STG_PONDERACIONES w JOIN STG_CURSOS_ASIGNATURAS a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') x JOIN (SELECT w.id_ponderacion_periodo,w.id_periodo,w.peso,SUM(w.peso) OVER (PARTITION BY w.id_curso_asignatura) AS total,c.id_ciclo,c.id_grado,a.id_asignatura FROM STG_PONDERACIONES w JOIN STG_CURSOS_ASIGNATURAS a ON a.id_curso_asignatura=w.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=a.id_curso WHERE w.estado='PUBLICADO') y ON y.id_periodo=x.id_periodo AND y.id_ciclo=x.id_ciclo AND y.id_grado=x.id_grado AND y.id_asignatura=x.id_asignatura WHERE ABS(x.peso*y.total-y.peso*x.total)>0.00000001))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PESOS_COMPARABLES: '||v_n); END IF;

    -- === STAGING: STG_INSCRIPCIONES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT i.* FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE i.fecha_inicio<x.fecha_inicio OR i.fecha_inicio>x.fecha_fin OR (i.fecha_fin IS NOT NULL AND (i.fecha_fin<i.fecha_inicio OR i.fecha_fin>x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_INSCRIPCION_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT i.* FROM STG_INSCRIPCIONES i WHERE i.id_inscripcion IN (SELECT w.id_inscripcion FROM (SELECT v.*,LAG(v.max_fin) OVER (PARTITION BY v.id_estudiante,v.id_ciclo ORDER BY v.fecha_inicio,v.id_inscripcion) AS fin_previo FROM (SELECT t.id_inscripcion,t.id_estudiante,c.id_ciclo,t.fecha_inicio,COALESCE(t.fecha_fin,x.fecha_fin) AS fin,MAX(COALESCE(t.fecha_fin,x.fecha_fin)) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion ROWS UNBOUNDED PRECEDING) AS max_fin,LEAD(t.fecha_inicio) OVER (PARTITION BY t.id_estudiante,c.id_ciclo ORDER BY t.fecha_inicio,t.id_inscripcion) AS inicio_siguiente FROM STG_INSCRIPCIONES t JOIN STG_CURSOS c ON c.id_curso=t.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE t.estado<>'ANULADA') v) w WHERE w.fin_previo>=w.fecha_inicio OR w.inicio_siguiente<=w.fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_INSCRIPCIONES_SOLAPADAS: '||v_n); END IF;

    -- === STAGING: STG_ASIGNACIONES_DOCENTES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM STG_ASIGNACIONES_DOCENTES a JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=o.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE a.fecha_inicio<x.fecha_inicio OR a.fecha_inicio>x.fecha_fin OR (a.fecha_fin IS NOT NULL AND (a.fecha_fin<a.fecha_inicio OR a.fecha_fin>x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_ASIGNACION_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM STG_ASIGNACIONES_DOCENTES a JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=a.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=o.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE a.estado<>'ANULADA' AND EXISTS (SELECT 1 FROM STG_ASIGNACIONES_DOCENTES b WHERE b.id_asignacion<>a.id_asignacion AND b.id_curso_asignatura=a.id_curso_asignatura AND b.estado<>'ANULADA' AND a.fecha_inicio<=COALESCE(b.fecha_fin,x.fecha_fin) AND b.fecha_inicio<=COALESCE(a.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_ASIGNACIONES_SOLAPADAS: '||v_n); END IF;

    -- === STAGING: STG_PLAZOS_NOTAS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT w.* FROM STG_PLAZOS_NOTAS w JOIN STG_PERIODOS p ON p.id_periodo=w.id_periodo WHERE w.id_ciclo<>p.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PLAZO_CICLO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT w.* FROM STG_PLAZOS_NOTAS w WHERE (w.tipo_intento='ORDINARIA' AND (w.fecha_inicio_recuperacion IS NOT NULL OR w.fecha_fin_recuperacion IS NOT NULL)) OR (w.tipo_intento='RECUPERACION' AND (w.fecha_inicio_recuperacion IS NULL OR w.fecha_fin_recuperacion IS NULL OR w.fecha_fin_recuperacion<w.fecha_inicio_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_RECUPERACION_FECHAS: '||v_n); END IF;

    -- === STAGING: STG_CALIFICACIONES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=n.id_inscripcion JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=n.id_asignacion_docente WHERE i.id_curso<>o.id_curso OR a.id_curso_asignatura<>o.id_curso_asignatura OR i.estado='ANULADA' OR a.estado='ANULADA' OR p.estado<>'PUBLICADO')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CALIFICACION_CONTEXTO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE (o.tipo_resultado='NUMERICA' AND (n.nota IS NULL OR n.resultado_cualitativo IS NOT NULL)) OR (o.tipo_resultado='CUALITATIVA' AND (n.nota IS NOT NULL OR n.resultado_cualitativo IS NULL)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_TIPO_RESULTADO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=n.id_inscripcion JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='ORDINARIA' AND (n.fecha_evaluacion<x.fecha_inicio OR n.fecha_evaluacion>x.fecha_fin OR n.fecha_evaluacion<i.fecha_inicio OR n.fecha_evaluacion>COALESCE(i.fecha_fin,x.fecha_fin) OR n.fecha_evaluacion<a.fecha_inicio OR n.fecha_evaluacion>COALESCE(a.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_ORDINARIA_VIGENCIA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=n.id_asignacion_docente WHERE n.tipo_intento='RECUPERACION' AND (a.fecha_inicio>x.fecha_fin OR COALESCE(a.fecha_fin,x.fecha_fin)<x.fecha_inicio))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_RECUPERACION_RESPONSABLE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_CALIFICACIONES b ON b.id_calificacion=n.id_calificacion_ordinaria WHERE n.tipo_intento='RECUPERACION' AND (b.tipo_intento<>'ORDINARIA' OR b.numero_intento<>1 OR b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.fecha_evaluacion>n.fecha_evaluacion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_ORIGEN_RECUPERACION: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_CALIFICACIONES b ON b.id_calificacion=n.id_calificacion_sustituida WHERE b.id_inscripcion<>n.id_inscripcion OR b.id_ponderacion_periodo<>n.id_ponderacion_periodo OR b.tipo_intento<>n.tipo_intento OR b.numero_intento<>n.numero_intento OR b.version+1<>n.version OR b.fecha_registro>n.fecha_registro)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_VERSION_ANTERIOR: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=n.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE n.id_calificacion NOT IN (SELECT m.id_calificacion FROM STG_CALIFICACIONES m JOIN STG_INSCRIPCIONES j ON j.id_inscripcion=m.id_inscripcion JOIN STG_CURSOS d ON d.id_curso=j.id_curso JOIN STG_PONDERACIONES q ON q.id_ponderacion_periodo=m.id_ponderacion_periodo JOIN STG_PLAZOS_NOTAS w ON w.id_institucion=d.id_institucion AND w.id_ciclo=d.id_ciclo AND w.id_grado=d.id_grado AND w.id_periodo=q.id_periodo AND w.tipo_intento=m.tipo_intento WHERE m.fecha_registro>=w.fecha_apertura_registro AND (w.fecha_cierre_registro IS NULL OR m.fecha_registro<=w.fecha_cierre_registro) AND (m.tipo_intento='ORDINARIA' OR m.fecha_evaluacion BETWEEN w.fecha_inicio_recuperacion AND w.fecha_fin_recuperacion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CAPTURA_AUTORIZADA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT n.* FROM STG_CALIFICACIONES n WHERE TRUNC(n.fecha_registro)<n.fecha_evaluacion)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_REGISTRO_NO_ANTICIPADO: '||v_n); END IF;

    -- === STAGING: STG_RESULTADOS_PERIODO (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM STG_RESULTADOS_PERIODO r JOIN STG_CALIFICACIONES n ON n.id_calificacion=r.id_calificacion_seleccionada JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=n.id_inscripcion JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE r.id_estudiante<>i.id_estudiante OR r.id_asignatura<>o.id_asignatura OR r.id_periodo<>p.id_periodo OR n.fecha_validacion IS NULL OR r.fecha_seleccion<n.fecha_validacion OR (r.fecha_cierre IS NOT NULL AND r.fecha_cierre<r.fecha_seleccion) OR (n.fecha_anulacion IS NOT NULL AND n.fecha_anulacion<=r.fecha_seleccion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_RESULTADO_CORRESPONDE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM STG_RESULTADOS_PERIODO r JOIN STG_CALIFICACIONES n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE EXISTS (SELECT 1 FROM STG_CALIFICACIONES v WHERE v.id_inscripcion=n.id_inscripcion AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.tipo_intento=n.tipo_intento AND v.numero_intento=n.numero_intento AND v.version>n.version AND v.fecha_validacion<=r.fecha_seleccion))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_SELECCION_VERSION_VIGENTE: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT r.* FROM STG_RESULTADOS_PERIODO r WHERE r.id_resultado IN (SELECT x.id_resultado FROM STG_RESULTADOS_PERIODO x JOIN STG_CALIFICACIONES n ON n.id_calificacion=x.id_calificacion_seleccionada JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_CALIFICACIONES m ON m.id_inscripcion=n.id_inscripcion AND m.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE m.fecha_validacion<=x.fecha_seleccion AND (m.fecha_anulacion IS NULL OR m.fecha_anulacion>x.fecha_seleccion) AND ((o.regla_recuperacion='MEJOR_NOTA' AND o.tipo_resultado='NUMERICA' AND m.nota>n.nota) OR (o.regla_recuperacion='ULTIMA_RECUPERACION' AND m.numero_intento>n.numero_intento)) AND NOT EXISTS (SELECT 1 FROM STG_CALIFICACIONES v WHERE v.id_inscripcion=m.id_inscripcion AND v.id_ponderacion_periodo=m.id_ponderacion_periodo AND v.tipo_intento=m.tipo_intento AND v.numero_intento=m.numero_intento AND v.version>m.version AND v.fecha_validacion<=x.fecha_seleccion)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_SELECCION_POLITICA: '||v_n); END IF;

    -- === STAGING: STG_SESIONES (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo JOIN STG_ASIGNACIONES_DOCENTES a ON a.id_asignacion=s.id_asignacion WHERE p.id_curso_asignatura<>a.id_curso_asignatura OR s.fecha_academica<x.fecha_inicio OR s.fecha_academica>x.fecha_fin OR s.fecha_academica<a.fecha_inicio OR s.fecha_academica>COALESCE(a.fecha_fin,x.fecha_fin) OR s.fin<=s.inicio OR TRUNC(s.inicio)<>s.fecha_academica OR a.estado='ANULADA')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_SESION_CONTEXTO: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT s.* FROM STG_SESIONES s WHERE s.id_sesion IN (SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,b.id_docente AS k,MAX(t.fin) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY b.id_docente ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM STG_SESIONES t JOIN STG_ASIGNACIONES_DOCENTES b ON b.id_asignacion=t.id_asignacion WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin UNION SELECT id_sesion FROM (SELECT v.*,LAG(v.max_hasta) OVER (PARTITION BY v.k ORDER BY v.inicio,v.id_sesion) AS fin_previo FROM (SELECT t.id_sesion,t.inicio,t.fin,z.id_curso AS k,MAX(t.fin) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion ROWS UNBOUNDED PRECEDING) AS max_hasta,LEAD(t.inicio) OVER (PARTITION BY z.id_curso ORDER BY t.inicio,t.id_sesion) AS inicio_siguiente FROM STG_SESIONES t JOIN STG_PONDERACIONES q ON q.id_ponderacion_periodo=t.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS z ON z.id_curso_asignatura=q.id_curso_asignatura WHERE t.estado<>'CANCELADA') v) w WHERE w.fin_previo>w.inicio OR w.inicio_siguiente<w.fin))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_SESIONES_SIMULTANEAS: '||v_n); END IF;

    -- === STAGING: STG_ASISTENCIAS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT a.* FROM STG_ASISTENCIAS a JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=a.id_inscripcion JOIN STG_SESIONES s ON s.id_sesion=a.id_sesion JOIN STG_PONDERACIONES p ON p.id_ponderacion_periodo=s.id_ponderacion_periodo JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso_asignatura=p.id_curso_asignatura JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE i.id_curso<>o.id_curso OR i.estado='ANULADA' OR s.estado<>'IMPARTIDA' OR s.fecha_academica<i.fecha_inicio OR s.fecha_academica>COALESCE(i.fecha_fin,x.fecha_fin) OR a.fecha_registro<s.fin OR (a.estado IN ('AUSENTE','JUSTIFICADA') AND a.hora_llegada IS NOT NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_ASISTENCIA_CONTEXTO: '||v_n); END IF;

    -- === STAGING: STG_BECAS (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT b.* FROM STG_BECAS b JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_INSTITUCIONES_CICLO h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE h.permite_becas<>1 OR i.estado='ANULADA')~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_BECA_HABILITADA: '||v_n); END IF;

    -- === STAGING: STG_BECAS_VIGENCIA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM STG_BECAS_VIGENCIA v JOIN STG_BECAS b ON b.id_beca=v.id_beca JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE v.fecha_inicio<i.fecha_inicio OR v.fecha_inicio>COALESCE(i.fecha_fin,x.fecha_fin) OR (v.fecha_fin IS NOT NULL AND (v.fecha_fin<v.fecha_inicio OR v.fecha_fin>COALESCE(i.fecha_fin,x.fecha_fin))) OR (v.fecha_fin IS NULL AND v.motivo_fin IS NOT NULL) OR (v.fecha_fin IS NOT NULL AND v.motivo_fin IS NULL))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_BECA_VIGENCIA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM STG_BECAS_VIGENCIA v JOIN STG_BECAS b ON b.id_beca=v.id_beca JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE EXISTS (SELECT 1 FROM STG_BECAS_VIGENCIA w WHERE w.id_beca=v.id_beca AND w.id_vigencia<>v.id_vigencia AND v.fecha_inicio<=COALESCE(w.fecha_fin,x.fecha_fin) AND w.fecha_inicio<=COALESCE(v.fecha_fin,x.fecha_fin)))~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_BECA_SOLAPADA: '||v_n); END IF;
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT v.* FROM STG_BECAS_VIGENCIA v JOIN STG_BECAS b ON b.id_beca=v.id_beca JOIN STG_INSCRIPCIONES i ON i.id_inscripcion=b.id_inscripcion JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_CICLOS x ON x.id_ciclo=c.id_ciclo WHERE (SELECT SUM(z.porcentaje) FROM STG_BECAS_VIGENCIA w JOIN STG_BECAS z ON z.id_beca=w.id_beca WHERE z.id_inscripcion=b.id_inscripcion AND w.fecha_inicio<=v.fecha_inicio AND COALESCE(w.fecha_fin,x.fecha_fin)>=v.fecha_inicio)>100)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_PORCENTAJE_SIMULTANEO: '||v_n); END IF;

    -- === STAGING: STG_CONTROL_CARGA (reglas entre tablas) ===
    EXECUTE IMMEDIATE q'~SELECT COUNT(*) FROM (SELECT z.* FROM STG_CONTROL_CARGA z JOIN STG_CURSOS c ON c.id_curso=z.id_curso JOIN STG_PERIODOS p ON p.id_periodo=z.id_periodo WHERE c.id_ciclo<>p.id_ciclo)~' INTO v_n;
    IF v_n>0 THEN v_errores:=v_errores+1; DBMS_OUTPUT.PUT_LINE('STAGING_CONTROL_CICLO: '||v_n); END IF;
    IF v_errores>0 THEN RAISE_APPLICATION_ERROR(-20040,TO_CHAR(v_errores)||' reglas BLOQUEO con infracciones.'); END IF;
    DBMS_OUTPUT.PUT_LINE('829 reglas BLOQUEO sin infracciones; 8 reglas PENDIENTE/AVISO informadas arriba si tienen filas.');
END;
/
