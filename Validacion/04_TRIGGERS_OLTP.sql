-- ==============================================================
-- SECCIÓN 4: TRIGGERS DEL OLTP
-- Descripción: Un trigger por tabla. Normaliza textos, impide cambios que rompen la historia, audita cada
--   cambio y, al terminar la sentencia, revisa las reglas que leen la tabla. Cada trigger lista sus reglas
--   dentro de su código, para verlas al abrirlo en Oracle.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === TRG_VAL_CAT_TIPO_DOCUMENTO ===
CREATE OR REPLACE TRIGGER trg_val_cat_tipo_documento
 FOR INSERT OR UPDATE OR DELETE ON cat_tipo_documento
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_TIPO_DOCUMENTO: protege cat_tipo_documento.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_tipo_documento<>:NEW.id_tipo_documento THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_tipo_documento' VALUE :OLD.id_tipo_documento,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_tipo_documento' VALUE :NEW.id_tipo_documento,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_tipo_documento,:OLD.id_tipo_documento));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_tipo_documento',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_TIPO_DOCUMENTO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_TIPO_INSTITUCION ===
CREATE OR REPLACE TRIGGER trg_val_cat_tipo_institucion
 FOR INSERT OR UPDATE OR DELETE ON cat_tipo_institucion
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_TIPO_INSTITUCION: protege cat_tipo_institucion.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 11 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_tipo_institucion<>:NEW.id_tipo_institucion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_tipo_institucion' VALUE :OLD.id_tipo_institucion,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_tipo_institucion' VALUE :NEW.id_tipo_institucion,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_tipo_institucion,:OLD.id_tipo_institucion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_tipo_institucion',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_TIPO_INSTITUCION'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_DEPARTAMENTO ===
CREATE OR REPLACE TRIGGER trg_val_cat_departamento
 FOR INSERT OR UPDATE OR DELETE ON cat_departamento
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_DEPARTAMENTO: protege cat_departamento.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 11 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_departamento<>:NEW.id_departamento THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_departamento' VALUE :OLD.id_departamento,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_departamento' VALUE :NEW.id_departamento,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_departamento,:OLD.id_departamento));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_departamento',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_DEPARTAMENTO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_ZONA ===
CREATE OR REPLACE TRIGGER trg_val_cat_zona
 FOR INSERT OR UPDATE OR DELETE ON cat_zona
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_ZONA: protege cat_zona.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: nombre.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 9 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_zona<>:NEW.id_zona THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_zona' VALUE :OLD.id_zona,'nombre' VALUE :OLD.nombre,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_zona' VALUE :NEW.id_zona,'nombre' VALUE :NEW.nombre,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_zona,:OLD.id_zona));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_zona',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_ZONA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_MODALIDAD ===
CREATE OR REPLACE TRIGGER trg_val_cat_modalidad
 FOR INSERT OR UPDATE OR DELETE ON cat_modalidad
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_MODALIDAD: protege cat_modalidad.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_modalidad<>:NEW.id_modalidad THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_modalidad' VALUE :OLD.id_modalidad,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_modalidad' VALUE :NEW.id_modalidad,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_modalidad,:OLD.id_modalidad));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_modalidad',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_MODALIDAD'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_JORNADA ===
CREATE OR REPLACE TRIGGER trg_val_cat_jornada
 FOR INSERT OR UPDATE OR DELETE ON cat_jornada
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_JORNADA: protege cat_jornada.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_jornada<>:NEW.id_jornada THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_jornada' VALUE :OLD.id_jornada,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_jornada' VALUE :NEW.id_jornada,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_jornada,:OLD.id_jornada));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_jornada',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_JORNADA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_AREA_CONOCIMIENTO ===
CREATE OR REPLACE TRIGGER trg_val_cat_area_conocimiento
 FOR INSERT OR UPDATE OR DELETE ON cat_area_conocimiento
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_AREA_CONOCIMIENTO: protege cat_area_conocimiento.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_area<>:NEW.id_area THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_area' VALUE :OLD.id_area,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_area' VALUE :NEW.id_area,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_area,:OLD.id_area));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_area_conocimiento',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_AREA_CONOCIMIENTO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_TIPO_BECA ===
CREATE OR REPLACE TRIGGER trg_val_cat_tipo_beca
 FOR INSERT OR UPDATE OR DELETE ON cat_tipo_beca
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_TIPO_BECA: protege cat_tipo_beca.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_tipo_beca<>:NEW.id_tipo_beca THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_tipo_beca' VALUE :OLD.id_tipo_beca,'codigo' VALUE :OLD.codigo,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_tipo_beca' VALUE :NEW.id_tipo_beca,'codigo' VALUE :NEW.codigo,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_tipo_beca,:OLD.id_tipo_beca));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_tipo_beca',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_TIPO_BECA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_NIVEL ===
CREATE OR REPLACE TRIGGER trg_val_cat_nivel
 FOR INSERT OR UPDATE OR DELETE ON cat_nivel
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_NIVEL: protege cat_nivel.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 9 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_nivel<>:NEW.id_nivel THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_nivel' VALUE :OLD.id_nivel,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'orden' VALUE :OLD.orden RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_nivel' VALUE :NEW.id_nivel,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'orden' VALUE :NEW.orden RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_nivel,:OLD.id_nivel));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_nivel',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_NIVEL'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_CAT_GRADO ===
CREATE OR REPLACE TRIGGER trg_val_cat_grado
 FOR INSERT OR UPDATE OR DELETE ON cat_grado
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_CAT_GRADO: protege cat_grado.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre.
  --   - es_ultimo_grado no cambia si el grado ya tiene inscripciones con resultado_cierre.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 14 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_grado<>:NEW.id_grado THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

IF UPDATING AND :OLD.es_ultimo_grado<>:NEW.es_ultimo_grado THEN DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso WHERE c.id_grado=:OLD.id_grado AND i.resultado_cierre IS NOT NULL;IF n>0 THEN RAISE_APPLICATION_ERROR(-20805,'Terminalidad utilizada por cierres historicos.');END IF;END;END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_grado' VALUE :OLD.id_grado,'id_nivel' VALUE :OLD.id_nivel,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'orden' VALUE :OLD.orden,'es_ultimo_grado' VALUE :OLD.es_ultimo_grado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_grado' VALUE :NEW.id_grado,'id_nivel' VALUE :NEW.id_nivel,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'orden' VALUE :NEW.orden,'es_ultimo_grado' VALUE :NEW.es_ultimo_grado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_grado,:OLD.id_grado));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('cat_grado',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','CAT_GRADO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_MAE_INSTITUCION ===
CREATE OR REPLACE TRIGGER trg_val_mae_institucion
 FOR INSERT OR UPDATE OR DELETE ON mae_institucion
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_MAE_INSTITUCION: protege mae_institucion.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo_institucion, nombre, direccion,
  --     telefono, email.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 24 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_institucion<>:NEW.id_institucion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo_institucion:=fn_limpiar_texto(:NEW.codigo_institucion); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

IF NOT DELETING THEN :NEW.direccion:=fn_limpiar_texto(:NEW.direccion); END IF;

IF NOT DELETING THEN :NEW.telefono:=fn_limpiar_texto(:NEW.telefono); END IF;

IF NOT DELETING THEN :NEW.email:=fn_limpiar_texto(:NEW.email); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_institucion' VALUE :OLD.id_institucion,'codigo_institucion' VALUE :OLD.codigo_institucion,'nombre' VALUE :OLD.nombre,'id_tipo_institucion' VALUE :OLD.id_tipo_institucion,'id_departamento' VALUE :OLD.id_departamento,'id_zona' VALUE :OLD.id_zona,'permite_becas' VALUE :OLD.permite_becas,'direccion' VALUE :OLD.direccion,'telefono' VALUE :OLD.telefono,'email' VALUE :OLD.email,'fecha_creacion' VALUE :OLD.fecha_creacion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_institucion' VALUE :NEW.id_institucion,'codigo_institucion' VALUE :NEW.codigo_institucion,'nombre' VALUE :NEW.nombre,'id_tipo_institucion' VALUE :NEW.id_tipo_institucion,'id_departamento' VALUE :NEW.id_departamento,'id_zona' VALUE :NEW.id_zona,'permite_becas' VALUE :NEW.permite_becas,'direccion' VALUE :NEW.direccion,'telefono' VALUE :NEW.telefono,'email' VALUE :NEW.email,'fecha_creacion' VALUE :NEW.fecha_creacion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_institucion,:OLD.id_institucion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('mae_institucion',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','MAE_INSTITUCION'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_MAE_PERSONA ===
CREATE OR REPLACE TRIGGER trg_val_mae_persona
 FOR INSERT OR UPDATE OR DELETE ON mae_persona
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_MAE_PERSONA: protege mae_persona.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: numero_documento, primer_nombre,
  --     segundo_nombre, primer_apellido, segundo_apellido, email, telefono, direccion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 1 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_NACIMIENTO_FUTURO: Nacimiento no futuro.
  -- Otras 15 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_persona<>:NEW.id_persona THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.numero_documento:=fn_limpiar_texto(:NEW.numero_documento); END IF;

IF NOT DELETING THEN :NEW.primer_nombre:=fn_limpiar_texto(:NEW.primer_nombre); END IF;

IF NOT DELETING THEN :NEW.segundo_nombre:=fn_limpiar_texto(:NEW.segundo_nombre); END IF;

IF NOT DELETING THEN :NEW.primer_apellido:=fn_limpiar_texto(:NEW.primer_apellido); END IF;

IF NOT DELETING THEN :NEW.segundo_apellido:=fn_limpiar_texto(:NEW.segundo_apellido); END IF;

IF NOT DELETING THEN :NEW.email:=fn_limpiar_texto(:NEW.email); END IF;

IF NOT DELETING THEN :NEW.telefono:=fn_limpiar_texto(:NEW.telefono); END IF;

IF NOT DELETING THEN :NEW.direccion:=fn_limpiar_texto(:NEW.direccion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_persona' VALUE :OLD.id_persona,'id_tipo_documento' VALUE :OLD.id_tipo_documento,'numero_documento' VALUE :OLD.numero_documento,'primer_nombre' VALUE :OLD.primer_nombre,'segundo_nombre' VALUE :OLD.segundo_nombre,'primer_apellido' VALUE :OLD.primer_apellido,'segundo_apellido' VALUE :OLD.segundo_apellido,'fecha_nacimiento' VALUE :OLD.fecha_nacimiento,'sexo' VALUE :OLD.sexo,'email' VALUE :OLD.email,'telefono' VALUE :OLD.telefono,'direccion' VALUE :OLD.direccion,'fecha_registro' VALUE :OLD.fecha_registro RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_persona' VALUE :NEW.id_persona,'id_tipo_documento' VALUE :NEW.id_tipo_documento,'numero_documento' VALUE :NEW.numero_documento,'primer_nombre' VALUE :NEW.primer_nombre,'segundo_nombre' VALUE :NEW.segundo_nombre,'primer_apellido' VALUE :NEW.primer_apellido,'segundo_apellido' VALUE :NEW.segundo_apellido,'fecha_nacimiento' VALUE :NEW.fecha_nacimiento,'sexo' VALUE :NEW.sexo,'email' VALUE :NEW.email,'telefono' VALUE :NEW.telefono,'direccion' VALUE :NEW.direccion,'fecha_registro' VALUE :NEW.fecha_registro RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_persona,:OLD.id_persona));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('mae_persona',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','MAE_PERSONA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_MAE_ESTUDIANTE ===
CREATE OR REPLACE TRIGGER trg_val_mae_estudiante
 FOR INSERT OR UPDATE OR DELETE ON mae_estudiante
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_MAE_ESTUDIANTE: protege mae_estudiante.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: nie.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 13 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_estudiante<>:NEW.id_estudiante THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.nie:=fn_limpiar_texto(:NEW.nie); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_estudiante' VALUE :OLD.id_estudiante,'id_persona' VALUE :OLD.id_persona,'nie' VALUE :OLD.nie,'fecha_registro' VALUE :OLD.fecha_registro,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_estudiante' VALUE :NEW.id_estudiante,'id_persona' VALUE :NEW.id_persona,'nie' VALUE :NEW.nie,'fecha_registro' VALUE :NEW.fecha_registro,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_estudiante,:OLD.id_estudiante));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('mae_estudiante',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','MAE_ESTUDIANTE'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_MAE_DOCENTE ===
CREATE OR REPLACE TRIGGER trg_val_mae_docente
 FOR INSERT OR UPDATE OR DELETE ON mae_docente
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_MAE_DOCENTE: protege mae_docente.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: especialidad.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_docente<>:NEW.id_docente THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.especialidad:=fn_limpiar_texto(:NEW.especialidad); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_docente' VALUE :OLD.id_docente,'id_persona' VALUE :OLD.id_persona,'especialidad' VALUE :OLD.especialidad,'fecha_registro' VALUE :OLD.fecha_registro,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_docente' VALUE :NEW.id_docente,'id_persona' VALUE :NEW.id_persona,'especialidad' VALUE :NEW.especialidad,'fecha_registro' VALUE :NEW.fecha_registro,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_docente,:OLD.id_docente));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('mae_docente',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','MAE_DOCENTE'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_MAE_ASIGNATURA ===
CREATE OR REPLACE TRIGGER trg_val_mae_asignatura
 FOR INSERT OR UPDATE OR DELETE ON mae_asignatura
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_MAE_ASIGNATURA: protege mae_asignatura.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre, descripcion.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 0 reglas BLOQUEO que leen esta tabla:
  -- Otras 13 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_asignatura<>:NEW.id_asignatura THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

IF NOT DELETING THEN :NEW.descripcion:=fn_limpiar_texto(:NEW.descripcion); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_asignatura' VALUE :OLD.id_asignatura,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'id_area' VALUE :OLD.id_area,'descripcion' VALUE :OLD.descripcion,'activo' VALUE :OLD.activo RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_asignatura' VALUE :NEW.id_asignatura,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'id_area' VALUE :NEW.id_area,'descripcion' VALUE :NEW.descripcion,'activo' VALUE :NEW.activo RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_asignatura,:OLD.id_asignatura));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('mae_asignatura',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','MAE_ASIGNATURA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_CICLO ===
CREATE OR REPLACE TRIGGER trg_val_est_ciclo
 FOR INSERT OR UPDATE OR DELETE ON est_ciclo
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_CICLO: protege est_ciclo.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre.
  --   - Pasar a CERRADO o salir de CERRADO solo con PR_CERRAR_CICLO / PR_REABRIR_CICLO, que
  --     registran el motivo en val_cambio en la misma transacción.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 11 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASIGNACIONES_SOLAPADAS: Un responsable por oferta y fecha.
  --   - OPERACION_ASIGNACION_CICLO: La responsabilidad ordinaria pertenece al ciclo de la
  --     oferta.
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_BECA_SOLAPADA: Una beca no tiene intervalos efectivos solapados.
  --   - OPERACION_BECA_VIGENCIA: El intervalo efectivo queda dentro de matrícula y ciclo.
  --   - OPERACION_CAPACIDAD_ESTRICTA: Capacidad simultanea solo cuando se active expresamente la
  --     politica.
  --   - OPERACION_CORTE_EN_CICLO: Corte de matrícula contenido en su ciclo.
  --   - OPERACION_INSCRIPCIONES_SOLAPADAS: No solapar matrículas ordinarias del mismo estudiante
  --     y ciclo.
  --   - OPERACION_INSCRIPCION_CICLO: Pertenencia dentro del ciclo, con intervalos inclusivos.
  --   - OPERACION_PERIODO_CICLO: Períodos configurables positivos, contenidos en su ciclo, sin
  --     duración fija.
  --   - OPERACION_PORCENTAJE_SIMULTANEO: Beneficios simultáneos de la misma inscripción y base
  --     no superan 100.
  -- Otras 18 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_ciclo<>:NEW.id_ciclo THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

IF (UPDATING AND :OLD.estado<>:NEW.estado AND (:OLD.estado='CERRADO' OR :NEW.estado='CERRADO')) OR (INSERTING AND :NEW.estado='CERRADO') THEN DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM val_cambio WHERE entidad='est_ciclo' AND clave=TO_CHAR(:NEW.id_ciclo) AND transaccion=fn_id_transaccion() AND accion=CASE WHEN :NEW.estado='CERRADO' THEN 'CIERRE' ELSE 'REAPERTURA' END AND TRIM(motivo) IS NOT NULL;IF n=0 THEN RAISE_APPLICATION_ERROR(-20805,'Cierre/reapertura requiere procedimiento y motivo.');END IF;END;END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_ciclo' VALUE :OLD.id_ciclo,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'anio' VALUE :OLD.anio,'fecha_inicio' VALUE :OLD.fecha_inicio,'fecha_fin' VALUE :OLD.fecha_fin,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_ciclo' VALUE :NEW.id_ciclo,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'anio' VALUE :NEW.anio,'fecha_inicio' VALUE :NEW.fecha_inicio,'fecha_fin' VALUE :NEW.fecha_fin,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_ciclo,:OLD.id_ciclo));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_ciclo',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_CICLO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_PERIODO_ACADEMICO ===
CREATE OR REPLACE TRIGGER trg_val_est_periodo_academico
 FOR INSERT OR UPDATE OR DELETE ON est_periodo_academico
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_PERIODO_ACADEMICO: protege est_periodo_academico.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: nombre.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 9 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_CONTROL_CICLO: El curso y período del control pertenecen al mismo ciclo.
  --   - OPERACION_ORDINARIA_VIGENCIA: La fecha académica ordinaria está en período, matrícula y
  --     responsabilidad.
  --   - OPERACION_PERIODOS_SOLAPADOS: No solapar períodos del mismo ciclo.
  --   - OPERACION_PERIODO_CICLO: Períodos configurables positivos, contenidos en su ciclo, sin
  --     duración fija.
  --   - OPERACION_PLAN_CICLO: Curso y período deben pertenecer al mismo ciclo.
  --   - OPERACION_PLAN_COMPLETO: Un plan publicado cubre todos los períodos configurados de su
  --     ciclo.
  --   - OPERACION_PLAZO_CICLO: El período del plazo pertenece a su ciclo.
  --   - OPERACION_RECUPERACION_RESPONSABLE: La recuperación queda a cargo de una asignación
  --     vigente en algún momento del período que recupera.
  --   - OPERACION_SESION_CONTEXTO: Sesión y responsabilidad compatibles; noche puede terminar al
  --     día siguiente.
  -- Otras 16 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_periodo<>:NEW.id_periodo THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_periodo' VALUE :OLD.id_periodo,'id_ciclo' VALUE :OLD.id_ciclo,'numero' VALUE :OLD.numero,'nombre' VALUE :OLD.nombre,'fecha_inicio' VALUE :OLD.fecha_inicio,'fecha_fin' VALUE :OLD.fecha_fin RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_periodo' VALUE :NEW.id_periodo,'id_ciclo' VALUE :NEW.id_ciclo,'numero' VALUE :NEW.numero,'nombre' VALUE :NEW.nombre,'fecha_inicio' VALUE :NEW.fecha_inicio,'fecha_fin' VALUE :NEW.fecha_fin RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_periodo,:OLD.id_periodo));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_periodo_academico',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_PERIODO_ACADEMICO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_INSTITUCION_CICLO ===
CREATE OR REPLACE TRIGGER trg_val_est_institucion_ciclo
 FOR INSERT OR UPDATE OR DELETE ON est_institucion_ciclo
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_INSTITUCION_CICLO: protege est_institucion_ciclo.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Pasar a CERRADO o salir de CERRADO solo con PR_CERRAR_CICLO / PR_REABRIR_CICLO, que
  --     registran el motivo en val_cambio en la misma transacción.
  --   - Tipo, departamento, zona y permite_becas no cambian si el contexto ya tiene cursos.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 2 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_BECA_HABILITADA: El beneficio respeta la habilitación histórica del centro.
  --   - OPERACION_CORTE_EN_CICLO: Corte de matrícula contenido en su ciclo.
  -- Otras 19 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_institucion<>:NEW.id_institucion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF UPDATING AND :OLD.id_ciclo<>:NEW.id_ciclo THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF (UPDATING AND :OLD.estado<>:NEW.estado AND (:OLD.estado='CERRADO' OR :NEW.estado='CERRADO')) OR (INSERTING AND :NEW.estado='CERRADO') THEN DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM val_cambio WHERE entidad='est_ciclo' AND clave=TO_CHAR(:NEW.id_ciclo) AND transaccion=fn_id_transaccion() AND accion=CASE WHEN :NEW.estado='CERRADO' THEN 'CIERRE' ELSE 'REAPERTURA' END AND TRIM(motivo) IS NOT NULL;IF n=0 THEN RAISE_APPLICATION_ERROR(-20805,'Cierre/reapertura requiere procedimiento y motivo.');END IF;END;END IF;

IF UPDATING AND (:OLD.id_departamento<>:NEW.id_departamento OR :OLD.id_tipo_institucion<>:NEW.id_tipo_institucion OR :OLD.id_zona<>:NEW.id_zona OR :OLD.permite_becas<>:NEW.permite_becas) THEN DECLARE n NUMBER; BEGIN SELECT COUNT(*) INTO n FROM est_curso WHERE id_institucion=:OLD.id_institucion AND id_ciclo=:OLD.id_ciclo; IF n>0 THEN RAISE_APPLICATION_ERROR(-20805,'Contexto historico utilizado: requiere migracion revisada.'); END IF; END; END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_institucion' VALUE :OLD.id_institucion,'id_ciclo' VALUE :OLD.id_ciclo,'id_tipo_institucion' VALUE :OLD.id_tipo_institucion,'id_departamento' VALUE :OLD.id_departamento,'id_zona' VALUE :OLD.id_zona,'permite_becas' VALUE :OLD.permite_becas,'fecha_corte_matricula' VALUE :OLD.fecha_corte_matricula,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_institucion' VALUE :NEW.id_institucion,'id_ciclo' VALUE :NEW.id_ciclo,'id_tipo_institucion' VALUE :NEW.id_tipo_institucion,'id_departamento' VALUE :NEW.id_departamento,'id_zona' VALUE :NEW.id_zona,'permite_becas' VALUE :NEW.permite_becas,'fecha_corte_matricula' VALUE :NEW.fecha_corte_matricula,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_institucion,:OLD.id_institucion))||'/'||TO_CHAR(COALESCE(:NEW.id_ciclo,:OLD.id_ciclo));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_institucion_ciclo',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_INSTITUCION_CICLO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_CURSO ===
CREATE OR REPLACE TRIGGER trg_val_est_curso
 FOR INSERT OR UPDATE OR DELETE ON est_curso
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_CURSO: protege est_curso.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: codigo, nombre, seccion.
  --   - Institución, ciclo, grado, jornada y sección no cambian si el grupo tiene inscripciones;
  --     se crea otro grupo.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 15 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASIGNACIONES_SOLAPADAS: Un responsable por oferta y fecha.
  --   - OPERACION_ASIGNACION_CICLO: La responsabilidad ordinaria pertenece al ciclo de la
  --     oferta.
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_BECA_HABILITADA: El beneficio respeta la habilitación histórica del centro.
  --   - OPERACION_BECA_SOLAPADA: Una beca no tiene intervalos efectivos solapados.
  --   - OPERACION_BECA_VIGENCIA: El intervalo efectivo queda dentro de matrícula y ciclo.
  --   - OPERACION_CAPACIDAD_ESTRICTA: Capacidad simultanea solo cuando se active expresamente la
  --     politica.
  --   - OPERACION_CAPTURA_AUTORIZADA: Existe plazo compatible y la captura no precede apertura
  --     ni supera cierre real.
  --   - OPERACION_CONTROL_CICLO: El curso y período del control pertenecen al mismo ciclo.
  --   - OPERACION_INSCRIPCIONES_SOLAPADAS: No solapar matrículas ordinarias del mismo estudiante
  --     y ciclo.
  --   - OPERACION_INSCRIPCION_CICLO: Pertenencia dentro del ciclo, con intervalos inclusivos.
  --   - OPERACION_PESOS_COMPARABLES: Mismo ciclo, grado y asignatura: igual vector normalizado.
  --   - OPERACION_PLAN_CICLO: Curso y período deben pertenecer al mismo ciclo.
  --   - OPERACION_PLAN_COMPLETO: Un plan publicado cubre todos los períodos configurados de su
  --     ciclo.
  --   - OPERACION_PORCENTAJE_SIMULTANEO: Beneficios simultáneos de la misma inscripción y base
  --     no superan 100.
  -- Otras 27 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_curso<>:NEW.id_curso THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.codigo:=fn_limpiar_texto(:NEW.codigo); END IF;

IF NOT DELETING THEN :NEW.nombre:=fn_limpiar_texto(:NEW.nombre); END IF;

IF NOT DELETING THEN :NEW.seccion:=fn_limpiar_texto(:NEW.seccion); END IF;

IF UPDATING AND (:OLD.id_institucion<>:NEW.id_institucion OR :OLD.id_ciclo<>:NEW.id_ciclo OR :OLD.id_grado<>:NEW.id_grado OR :OLD.id_jornada<>:NEW.id_jornada OR :OLD.seccion<>:NEW.seccion) THEN DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM trx_inscripcion WHERE id_curso=:OLD.id_curso;IF n>0 THEN RAISE_APPLICATION_ERROR(-20805,'Grupo con historial; crear otro grupo.');END IF;END;END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_curso' VALUE :OLD.id_curso,'id_institucion' VALUE :OLD.id_institucion,'id_ciclo' VALUE :OLD.id_ciclo,'id_grado' VALUE :OLD.id_grado,'id_jornada' VALUE :OLD.id_jornada,'id_modalidad' VALUE :OLD.id_modalidad,'codigo' VALUE :OLD.codigo,'nombre' VALUE :OLD.nombre,'seccion' VALUE :OLD.seccion,'capacidad_maxima' VALUE :OLD.capacidad_maxima,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_curso' VALUE :NEW.id_curso,'id_institucion' VALUE :NEW.id_institucion,'id_ciclo' VALUE :NEW.id_ciclo,'id_grado' VALUE :NEW.id_grado,'id_jornada' VALUE :NEW.id_jornada,'id_modalidad' VALUE :NEW.id_modalidad,'codigo' VALUE :NEW.codigo,'nombre' VALUE :NEW.nombre,'seccion' VALUE :NEW.seccion,'capacidad_maxima' VALUE :NEW.capacidad_maxima,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_curso,:OLD.id_curso));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_curso',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_CURSO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_CURSO_ASIGNATURA ===
CREATE OR REPLACE TRIGGER trg_val_est_curso_asignatura
 FOR INSERT OR UPDATE OR DELETE ON est_curso_asignatura
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_CURSO_ASIGNATURA: protege est_curso_asignatura.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - tipo_resultado y regla_recuperacion no cambian si la oferta tiene notas validadas.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 11 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASIGNACIONES_SOLAPADAS: Un responsable por oferta y fecha.
  --   - OPERACION_ASIGNACION_CICLO: La responsabilidad ordinaria pertenece al ciclo de la
  --     oferta.
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_CALIFICACION_CONTEXTO: Calificación, inscripción y asignación corresponden a
  --     la misma oferta publicada.
  --   - OPERACION_PESOS_COMPARABLES: Mismo ciclo, grado y asignatura: igual vector normalizado.
  --   - OPERACION_PLAN_CICLO: Curso y período deben pertenecer al mismo ciclo.
  --   - OPERACION_PLAN_COMPLETO: Un plan publicado cubre todos los períodos configurados de su
  --     ciclo.
  --   - OPERACION_RESULTADO_CORRESPONDE: La referencia seleccionada corresponde a estudiante,
  --     materia y período.
  --   - OPERACION_SELECCION_POLITICA: La elección respeta mejor nota o última recuperación a
  --     fecha de selección, sin anticipar eventos futuros.
  --   - OPERACION_SESIONES_SIMULTANEAS: Un docente o grupo no recibe dos sesiones simultáneas.
  --   - OPERACION_TIPO_RESULTADO: Resultado numérico o cualitativo coherente con la oferta.
  -- Otras 18 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_curso_asignatura<>:NEW.id_curso_asignatura THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF UPDATING AND (:OLD.tipo_resultado<>:NEW.tipo_resultado OR :OLD.regla_recuperacion<>:NEW.regla_recuperacion) THEN DECLARE n NUMBER; BEGIN SELECT COUNT(*) INTO n FROM trx_calificacion n JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo WHERE p.id_curso_asignatura=:OLD.id_curso_asignatura AND n.fecha_validacion IS NOT NULL; IF n>0 THEN RAISE_APPLICATION_ERROR(-20805,'Regla/tipo utilizados por notas validadas.'); END IF; END; END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_curso_asignatura' VALUE :OLD.id_curso_asignatura,'id_curso' VALUE :OLD.id_curso,'id_asignatura' VALUE :OLD.id_asignatura,'horas_semanales' VALUE :OLD.horas_semanales,'creditos' VALUE :OLD.creditos,'tipo_resultado' VALUE :OLD.tipo_resultado,'regla_recuperacion' VALUE :OLD.regla_recuperacion,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_curso_asignatura' VALUE :NEW.id_curso_asignatura,'id_curso' VALUE :NEW.id_curso,'id_asignatura' VALUE :NEW.id_asignatura,'horas_semanales' VALUE :NEW.horas_semanales,'creditos' VALUE :NEW.creditos,'tipo_resultado' VALUE :NEW.tipo_resultado,'regla_recuperacion' VALUE :NEW.regla_recuperacion,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_curso_asignatura,:OLD.id_curso_asignatura));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_curso_asignatura',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_CURSO_ASIGNATURA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_PONDERACION_PERIODO ===
CREATE OR REPLACE TRIGGER trg_val_est_ponderacion_periodo
 FOR INSERT OR UPDATE OR DELETE ON est_ponderacion_periodo
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_PONDERACION_PERIODO: protege est_ponderacion_periodo.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Un componente del plan con notas validadas no se modifica ni se borra.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 13 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_CALIFICACION_CONTEXTO: Calificación, inscripción y asignación corresponden a
  --     la misma oferta publicada.
  --   - OPERACION_CAPTURA_AUTORIZADA: Existe plazo compatible y la captura no precede apertura
  --     ni supera cierre real.
  --   - OPERACION_ORDINARIA_VIGENCIA: La fecha académica ordinaria está en período, matrícula y
  --     responsabilidad.
  --   - OPERACION_PESOS_COMPARABLES: Mismo ciclo, grado y asignatura: igual vector normalizado.
  --   - OPERACION_PLAN_CICLO: Curso y período deben pertenecer al mismo ciclo.
  --   - OPERACION_PLAN_COMPLETO: Un plan publicado cubre todos los períodos configurados de su
  --     ciclo.
  --   - OPERACION_RECUPERACION_RESPONSABLE: La recuperación queda a cargo de una asignación
  --     vigente en algún momento del período que recupera.
  --   - OPERACION_RESULTADO_CORRESPONDE: La referencia seleccionada corresponde a estudiante,
  --     materia y período.
  --   - OPERACION_SELECCION_POLITICA: La elección respeta mejor nota o última recuperación a
  --     fecha de selección, sin anticipar eventos futuros.
  --   - OPERACION_SESIONES_SIMULTANEAS: Un docente o grupo no recibe dos sesiones simultáneas.
  --   - OPERACION_SESION_CONTEXTO: Sesión y responsabilidad compatibles; noche puede terminar al
  --     día siguiente.
  --   - OPERACION_TIPO_RESULTADO: Resultado numérico o cualitativo coherente con la oferta.
  -- Otras 13 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_ponderacion_periodo<>:NEW.id_ponderacion_periodo THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF UPDATING OR DELETING THEN DECLARE n NUMBER; BEGIN SELECT COUNT(*) INTO n FROM trx_calificacion WHERE id_ponderacion_periodo=:OLD.id_ponderacion_periodo AND fecha_validacion IS NOT NULL; IF n>0 THEN RAISE_APPLICATION_ERROR(-20805,'Plan con notas validadas: no alterar historia.'); END IF; END; END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_ponderacion_periodo' VALUE :OLD.id_ponderacion_periodo,'id_curso_asignatura' VALUE :OLD.id_curso_asignatura,'id_periodo' VALUE :OLD.id_periodo,'peso' VALUE :OLD.peso,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_ponderacion_periodo' VALUE :NEW.id_ponderacion_periodo,'id_curso_asignatura' VALUE :NEW.id_curso_asignatura,'id_periodo' VALUE :NEW.id_periodo,'peso' VALUE :NEW.peso,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_ponderacion_periodo,:OLD.id_ponderacion_periodo));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_ponderacion_periodo',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_PONDERACION_PERIODO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_EST_PLAZO_REGISTRO_NOTAS ===
CREATE OR REPLACE TRIGGER trg_val_est_plazo_registro_notas
 FOR INSERT OR UPDATE OR DELETE ON est_plazo_registro_notas
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_EST_PLAZO_REGISTRO_NOTAS: protege est_plazo_registro_notas.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Un plazo CERRADO solo se reabre con PR_REABRIR_PLAZO y motivo.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 3 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_CAPTURA_AUTORIZADA: Existe plazo compatible y la captura no precede apertura
  --     ni supera cierre real.
  --   - OPERACION_PLAZO_CICLO: El período del plazo pertenece a su ciclo.
  --   - OPERACION_RECUPERACION_FECHAS: Recuperación exige intervalo ordenado; ordinaria lo deja
  --     vacío.
  -- Otras 21 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_plazo_registro_notas<>:NEW.id_plazo_registro_notas THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF UPDATING AND :OLD.estado='CERRADA' AND :NEW.estado<>'CERRADA' THEN DECLARE n NUMBER;BEGIN SELECT COUNT(*) INTO n FROM val_cambio WHERE entidad='est_plazo_registro_notas' AND clave=TO_CHAR(:OLD.id_plazo_registro_notas) AND accion='REAPERTURA' AND transaccion=fn_id_transaccion() AND TRIM(motivo) IS NOT NULL;IF n=0 THEN RAISE_APPLICATION_ERROR(-20805,'Reabrir plazo mediante procedimiento y motivo.');END IF;END;END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_plazo_registro_notas' VALUE :OLD.id_plazo_registro_notas,'id_institucion' VALUE :OLD.id_institucion,'id_ciclo' VALUE :OLD.id_ciclo,'id_grado' VALUE :OLD.id_grado,'id_periodo' VALUE :OLD.id_periodo,'tipo_intento' VALUE :OLD.tipo_intento,'fecha_inicio_recuperacion' VALUE :OLD.fecha_inicio_recuperacion,'fecha_fin_recuperacion' VALUE :OLD.fecha_fin_recuperacion,'fecha_apertura_registro' VALUE :OLD.fecha_apertura_registro,'fecha_limite_registro' VALUE :OLD.fecha_limite_registro,'fecha_cierre_registro' VALUE :OLD.fecha_cierre_registro,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_plazo_registro_notas' VALUE :NEW.id_plazo_registro_notas,'id_institucion' VALUE :NEW.id_institucion,'id_ciclo' VALUE :NEW.id_ciclo,'id_grado' VALUE :NEW.id_grado,'id_periodo' VALUE :NEW.id_periodo,'tipo_intento' VALUE :NEW.tipo_intento,'fecha_inicio_recuperacion' VALUE :NEW.fecha_inicio_recuperacion,'fecha_fin_recuperacion' VALUE :NEW.fecha_fin_recuperacion,'fecha_apertura_registro' VALUE :NEW.fecha_apertura_registro,'fecha_limite_registro' VALUE :NEW.fecha_limite_registro,'fecha_cierre_registro' VALUE :NEW.fecha_cierre_registro,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_plazo_registro_notas,:OLD.id_plazo_registro_notas));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('est_plazo_registro_notas',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','EST_PLAZO_REGISTRO_NOTAS'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_ASIGNACION_DOCENTE ===
CREATE OR REPLACE TRIGGER trg_val_trx_asignacion_docente
 FOR INSERT OR UPDATE OR DELETE ON trx_asignacion_docente
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_ASIGNACION_DOCENTE: protege trx_asignacion_docente.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 7 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASIGNACIONES_SOLAPADAS: Un responsable por oferta y fecha.
  --   - OPERACION_ASIGNACION_CICLO: La responsabilidad ordinaria pertenece al ciclo de la
  --     oferta.
  --   - OPERACION_CALIFICACION_CONTEXTO: Calificación, inscripción y asignación corresponden a
  --     la misma oferta publicada.
  --   - OPERACION_ORDINARIA_VIGENCIA: La fecha académica ordinaria está en período, matrícula y
  --     responsabilidad.
  --   - OPERACION_RECUPERACION_RESPONSABLE: La recuperación queda a cargo de una asignación
  --     vigente en algún momento del período que recupera.
  --   - OPERACION_SESIONES_SIMULTANEAS: Un docente o grupo no recibe dos sesiones simultáneas.
  --   - OPERACION_SESION_CONTEXTO: Sesión y responsabilidad compatibles; noche puede terminar al
  --     día siguiente.
  -- Otras 14 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_asignacion<>:NEW.id_asignacion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_asignacion' VALUE :OLD.id_asignacion,'id_docente' VALUE :OLD.id_docente,'id_curso_asignatura' VALUE :OLD.id_curso_asignatura,'fecha_asignacion' VALUE :OLD.fecha_asignacion,'fecha_inicio' VALUE :OLD.fecha_inicio,'fecha_fin' VALUE :OLD.fecha_fin,'estado' VALUE :OLD.estado RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_asignacion' VALUE :NEW.id_asignacion,'id_docente' VALUE :NEW.id_docente,'id_curso_asignatura' VALUE :NEW.id_curso_asignatura,'fecha_asignacion' VALUE :NEW.fecha_asignacion,'fecha_inicio' VALUE :NEW.fecha_inicio,'fecha_fin' VALUE :NEW.fecha_fin,'estado' VALUE :NEW.estado RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_asignacion,:OLD.id_asignacion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_asignacion_docente',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_ASIGNACION_DOCENTE'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_INSCRIPCION ===
CREATE OR REPLACE TRIGGER trg_val_trx_inscripcion
 FOR INSERT OR UPDATE OR DELETE ON trx_inscripcion
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_INSCRIPCION: protege trx_inscripcion.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: motivo_fin_inscripcion.
  --   - id_estudiante e id_curso no se reasignan; el cambio de grupo se hace con
  --     PR_TRASLADAR_ESTUDIANTE.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 13 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_BECA_HABILITADA: El beneficio respeta la habilitación histórica del centro.
  --   - OPERACION_BECA_SOLAPADA: Una beca no tiene intervalos efectivos solapados.
  --   - OPERACION_BECA_VIGENCIA: El intervalo efectivo queda dentro de matrícula y ciclo.
  --   - OPERACION_CALIFICACION_CONTEXTO: Calificación, inscripción y asignación corresponden a
  --     la misma oferta publicada.
  --   - OPERACION_CAPACIDAD_ESTRICTA: Capacidad simultanea solo cuando se active expresamente la
  --     politica.
  --   - OPERACION_CAPTURA_AUTORIZADA: Existe plazo compatible y la captura no precede apertura
  --     ni supera cierre real.
  --   - OPERACION_CIERRE_INSCRIPCION: Inscripción terminada con fecha y motivo.
  --   - OPERACION_INSCRIPCIONES_SOLAPADAS: No solapar matrículas ordinarias del mismo estudiante
  --     y ciclo.
  --   - OPERACION_INSCRIPCION_CICLO: Pertenencia dentro del ciclo, con intervalos inclusivos.
  --   - OPERACION_ORDINARIA_VIGENCIA: La fecha académica ordinaria está en período, matrícula y
  --     responsabilidad.
  --   - OPERACION_PORCENTAJE_SIMULTANEO: Beneficios simultáneos de la misma inscripción y base
  --     no superan 100.
  --   - OPERACION_RESULTADO_CORRESPONDE: La referencia seleccionada corresponde a estudiante,
  --     materia y período.
  -- Otras 17 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_inscripcion<>:NEW.id_inscripcion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.motivo_fin_inscripcion:=fn_limpiar_texto(:NEW.motivo_fin_inscripcion); END IF;

IF UPDATING AND (:OLD.id_estudiante<>:NEW.id_estudiante OR :OLD.id_curso<>:NEW.id_curso) THEN RAISE_APPLICATION_ERROR(-20805,'No reasignar historial de inscripcion; usar traslado.');END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_inscripcion' VALUE :OLD.id_inscripcion,'id_estudiante' VALUE :OLD.id_estudiante,'id_curso' VALUE :OLD.id_curso,'fecha_inscripcion' VALUE :OLD.fecha_inscripcion,'fecha_inicio' VALUE :OLD.fecha_inicio,'fecha_fin' VALUE :OLD.fecha_fin,'estado' VALUE :OLD.estado,'motivo_fin_inscripcion' VALUE :OLD.motivo_fin_inscripcion,'resultado_cierre' VALUE :OLD.resultado_cierre RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_inscripcion' VALUE :NEW.id_inscripcion,'id_estudiante' VALUE :NEW.id_estudiante,'id_curso' VALUE :NEW.id_curso,'fecha_inscripcion' VALUE :NEW.fecha_inscripcion,'fecha_inicio' VALUE :NEW.fecha_inicio,'fecha_fin' VALUE :NEW.fecha_fin,'estado' VALUE :NEW.estado,'motivo_fin_inscripcion' VALUE :NEW.motivo_fin_inscripcion,'resultado_cierre' VALUE :NEW.resultado_cierre RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_inscripcion,:OLD.id_inscripcion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_inscripcion',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_INSCRIPCION'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_CALIFICACION ===
CREATE OR REPLACE TRIGGER trg_val_trx_calificacion
 FOR INSERT OR UPDATE OR DELETE ON trx_calificacion
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_CALIFICACION: protege trx_calificacion.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: resultado_cualitativo, motivo_anulacion.
  --   - Columnas inmutables (una corrección crea otra versión): id_calificacion, id_inscripcion,
  --     id_ponderacion_periodo, tipo_intento, numero_intento, version,
  --     id_calificacion_ordinaria, id_calificacion_sustituida, id_asignacion_docente,
  --     id_docente_registra, nota, resultado_cualitativo, fecha_evaluacion, fecha_registro.
  --   - Se escriben una sola vez; después solo con nueva versión o reapertura: fecha_validacion,
  --     fecha_anulacion, motivo_anulacion.
  --   - No se permite DELETE: se anula o se corrige con una versión nueva.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 11 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_CALIFICACION_CONTEXTO: Calificación, inscripción y asignación corresponden a
  --     la misma oferta publicada.
  --   - OPERACION_CAPTURA_AUTORIZADA: Existe plazo compatible y la captura no precede apertura
  --     ni supera cierre real.
  --   - OPERACION_ORDINARIA_VIGENCIA: La fecha académica ordinaria está en período, matrícula y
  --     responsabilidad.
  --   - OPERACION_ORIGEN_RECUPERACION: La recuperación referencia su ordinaria y conserva
  --     inscripción y plan.
  --   - OPERACION_RECUPERACION_RESPONSABLE: La recuperación queda a cargo de una asignación
  --     vigente en algún momento del período que recupera.
  --   - OPERACION_REGISTRO_NO_ANTICIPADO: El registro no precede al hecho académico.
  --   - OPERACION_RESULTADO_CORRESPONDE: La referencia seleccionada corresponde a estudiante,
  --     materia y período.
  --   - OPERACION_SELECCION_POLITICA: La elección respeta mejor nota o última recuperación a
  --     fecha de selección, sin anticipar eventos futuros.
  --   - OPERACION_SELECCION_VERSION_VIGENTE: Una selección usa la última versión validada de su
  --     intento en ese momento.
  --   - OPERACION_TIPO_RESULTADO: Resultado numérico o cualitativo coherente con la oferta.
  --   - OPERACION_VERSION_ANTERIOR: La sustituida es la versión previa del mismo intento y
  --     contexto.
  -- Otras 28 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_calificacion<>:NEW.id_calificacion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.resultado_cualitativo:=fn_limpiar_texto(:NEW.resultado_cualitativo); END IF;

IF NOT DELETING THEN :NEW.motivo_anulacion:=fn_limpiar_texto(:NEW.motivo_anulacion); END IF;

IF DELETING THEN RAISE_APPLICATION_ERROR(-20805,'No se borra historia academica; usar anulacion/correccion.'); END IF;

IF UPDATING AND ((:OLD.id_calificacion<>:NEW.id_calificacion) OR (:OLD.id_calificacion IS NULL AND :NEW.id_calificacion IS NOT NULL) OR (:OLD.id_calificacion IS NOT NULL AND :NEW.id_calificacion IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_calificacion.'); END IF;

IF UPDATING AND ((:OLD.id_inscripcion<>:NEW.id_inscripcion) OR (:OLD.id_inscripcion IS NULL AND :NEW.id_inscripcion IS NOT NULL) OR (:OLD.id_inscripcion IS NOT NULL AND :NEW.id_inscripcion IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_inscripcion.'); END IF;

IF UPDATING AND ((:OLD.id_ponderacion_periodo<>:NEW.id_ponderacion_periodo) OR (:OLD.id_ponderacion_periodo IS NULL AND :NEW.id_ponderacion_periodo IS NOT NULL) OR (:OLD.id_ponderacion_periodo IS NOT NULL AND :NEW.id_ponderacion_periodo IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_ponderacion_periodo.'); END IF;

IF UPDATING AND ((:OLD.tipo_intento<>:NEW.tipo_intento) OR (:OLD.tipo_intento IS NULL AND :NEW.tipo_intento IS NOT NULL) OR (:OLD.tipo_intento IS NOT NULL AND :NEW.tipo_intento IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir tipo_intento.'); END IF;

IF UPDATING AND ((:OLD.numero_intento<>:NEW.numero_intento) OR (:OLD.numero_intento IS NULL AND :NEW.numero_intento IS NOT NULL) OR (:OLD.numero_intento IS NOT NULL AND :NEW.numero_intento IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir numero_intento.'); END IF;

IF UPDATING AND ((:OLD.version<>:NEW.version) OR (:OLD.version IS NULL AND :NEW.version IS NOT NULL) OR (:OLD.version IS NOT NULL AND :NEW.version IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir version.'); END IF;

IF UPDATING AND ((:OLD.id_calificacion_ordinaria<>:NEW.id_calificacion_ordinaria) OR (:OLD.id_calificacion_ordinaria IS NULL AND :NEW.id_calificacion_ordinaria IS NOT NULL) OR (:OLD.id_calificacion_ordinaria IS NOT NULL AND :NEW.id_calificacion_ordinaria IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_calificacion_ordinaria.'); END IF;

IF UPDATING AND ((:OLD.id_calificacion_sustituida<>:NEW.id_calificacion_sustituida) OR (:OLD.id_calificacion_sustituida IS NULL AND :NEW.id_calificacion_sustituida IS NOT NULL) OR (:OLD.id_calificacion_sustituida IS NOT NULL AND :NEW.id_calificacion_sustituida IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_calificacion_sustituida.'); END IF;

IF UPDATING AND ((:OLD.id_asignacion_docente<>:NEW.id_asignacion_docente) OR (:OLD.id_asignacion_docente IS NULL AND :NEW.id_asignacion_docente IS NOT NULL) OR (:OLD.id_asignacion_docente IS NOT NULL AND :NEW.id_asignacion_docente IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_asignacion_docente.'); END IF;

IF UPDATING AND ((:OLD.id_docente_registra<>:NEW.id_docente_registra) OR (:OLD.id_docente_registra IS NULL AND :NEW.id_docente_registra IS NOT NULL) OR (:OLD.id_docente_registra IS NOT NULL AND :NEW.id_docente_registra IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_docente_registra.'); END IF;

IF UPDATING AND ((:OLD.nota<>:NEW.nota) OR (:OLD.nota IS NULL AND :NEW.nota IS NOT NULL) OR (:OLD.nota IS NOT NULL AND :NEW.nota IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir nota.'); END IF;

IF UPDATING AND ((:OLD.resultado_cualitativo<>:NEW.resultado_cualitativo) OR (:OLD.resultado_cualitativo IS NULL AND :NEW.resultado_cualitativo IS NOT NULL) OR (:OLD.resultado_cualitativo IS NOT NULL AND :NEW.resultado_cualitativo IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir resultado_cualitativo.'); END IF;

IF UPDATING AND ((:OLD.fecha_evaluacion<>:NEW.fecha_evaluacion) OR (:OLD.fecha_evaluacion IS NULL AND :NEW.fecha_evaluacion IS NOT NULL) OR (:OLD.fecha_evaluacion IS NOT NULL AND :NEW.fecha_evaluacion IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir fecha_evaluacion.'); END IF;

IF UPDATING AND ((:OLD.fecha_registro<>:NEW.fecha_registro) OR (:OLD.fecha_registro IS NULL AND :NEW.fecha_registro IS NOT NULL) OR (:OLD.fecha_registro IS NOT NULL AND :NEW.fecha_registro IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir fecha_registro.'); END IF;

IF UPDATING AND :OLD.fecha_validacion IS NOT NULL AND (:NEW.fecha_validacion IS NULL OR :OLD.fecha_validacion<>:NEW.fecha_validacion) THEN RAISE_APPLICATION_ERROR(-20805,'No se reescribe fecha_validacion; nueva version o reapertura.'); END IF;

IF UPDATING AND :OLD.fecha_anulacion IS NOT NULL AND (:NEW.fecha_anulacion IS NULL OR :OLD.fecha_anulacion<>:NEW.fecha_anulacion) THEN RAISE_APPLICATION_ERROR(-20805,'No se reescribe fecha_anulacion; nueva version o reapertura.'); END IF;

IF UPDATING AND :OLD.motivo_anulacion IS NOT NULL AND (:NEW.motivo_anulacion IS NULL OR :OLD.motivo_anulacion<>:NEW.motivo_anulacion) THEN RAISE_APPLICATION_ERROR(-20805,'No se reescribe motivo_anulacion; nueva version o reapertura.'); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_calificacion' VALUE :OLD.id_calificacion,'id_inscripcion' VALUE :OLD.id_inscripcion,'id_ponderacion_periodo' VALUE :OLD.id_ponderacion_periodo,'tipo_intento' VALUE :OLD.tipo_intento,'numero_intento' VALUE :OLD.numero_intento,'version' VALUE :OLD.version,'id_calificacion_ordinaria' VALUE :OLD.id_calificacion_ordinaria,'id_calificacion_sustituida' VALUE :OLD.id_calificacion_sustituida,'id_asignacion_docente' VALUE :OLD.id_asignacion_docente,'id_docente_registra' VALUE :OLD.id_docente_registra,'nota' VALUE :OLD.nota,'resultado_cualitativo' VALUE :OLD.resultado_cualitativo,'fecha_evaluacion' VALUE :OLD.fecha_evaluacion,'fecha_registro' VALUE :OLD.fecha_registro,'fecha_validacion' VALUE :OLD.fecha_validacion,'fecha_anulacion' VALUE :OLD.fecha_anulacion,'motivo_anulacion' VALUE :OLD.motivo_anulacion RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_calificacion' VALUE :NEW.id_calificacion,'id_inscripcion' VALUE :NEW.id_inscripcion,'id_ponderacion_periodo' VALUE :NEW.id_ponderacion_periodo,'tipo_intento' VALUE :NEW.tipo_intento,'numero_intento' VALUE :NEW.numero_intento,'version' VALUE :NEW.version,'id_calificacion_ordinaria' VALUE :NEW.id_calificacion_ordinaria,'id_calificacion_sustituida' VALUE :NEW.id_calificacion_sustituida,'id_asignacion_docente' VALUE :NEW.id_asignacion_docente,'id_docente_registra' VALUE :NEW.id_docente_registra,'nota' VALUE :NEW.nota,'resultado_cualitativo' VALUE :NEW.resultado_cualitativo,'fecha_evaluacion' VALUE :NEW.fecha_evaluacion,'fecha_registro' VALUE :NEW.fecha_registro,'fecha_validacion' VALUE :NEW.fecha_validacion,'fecha_anulacion' VALUE :NEW.fecha_anulacion,'motivo_anulacion' VALUE :NEW.motivo_anulacion RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_calificacion,:OLD.id_calificacion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_calificacion',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_CALIFICACION'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_RESULTADO_PERIODO ===
CREATE OR REPLACE TRIGGER trg_val_trx_resultado_periodo
 FOR INSERT OR UPDATE OR DELETE ON trx_resultado_periodo
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_RESULTADO_PERIODO: protege trx_resultado_periodo.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Columnas inmutables (una corrección crea otra versión): id_resultado, id_estudiante,
  --     id_asignatura, id_periodo, id_calificacion_seleccionada, version, criterio,
  --     fecha_seleccion.
  --   - Se escriben una sola vez; después solo con nueva versión o reapertura: fecha_cierre.
  --   - No se permite DELETE: se anula o se corrige con una versión nueva.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 3 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_RESULTADO_CORRESPONDE: La referencia seleccionada corresponde a estudiante,
  --     materia y período.
  --   - OPERACION_SELECCION_POLITICA: La elección respeta mejor nota o última recuperación a
  --     fecha de selección, sin anticipar eventos futuros.
  --   - OPERACION_SELECCION_VERSION_VIGENTE: Una selección usa la última versión validada de su
  --     intento en ese momento.
  -- Otras 16 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_resultado<>:NEW.id_resultado THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF DELETING THEN RAISE_APPLICATION_ERROR(-20805,'No se borra historia academica; usar anulacion/correccion.'); END IF;

IF UPDATING AND ((:OLD.id_resultado<>:NEW.id_resultado) OR (:OLD.id_resultado IS NULL AND :NEW.id_resultado IS NOT NULL) OR (:OLD.id_resultado IS NOT NULL AND :NEW.id_resultado IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_resultado.'); END IF;

IF UPDATING AND ((:OLD.id_estudiante<>:NEW.id_estudiante) OR (:OLD.id_estudiante IS NULL AND :NEW.id_estudiante IS NOT NULL) OR (:OLD.id_estudiante IS NOT NULL AND :NEW.id_estudiante IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_estudiante.'); END IF;

IF UPDATING AND ((:OLD.id_asignatura<>:NEW.id_asignatura) OR (:OLD.id_asignatura IS NULL AND :NEW.id_asignatura IS NOT NULL) OR (:OLD.id_asignatura IS NOT NULL AND :NEW.id_asignatura IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_asignatura.'); END IF;

IF UPDATING AND ((:OLD.id_periodo<>:NEW.id_periodo) OR (:OLD.id_periodo IS NULL AND :NEW.id_periodo IS NOT NULL) OR (:OLD.id_periodo IS NOT NULL AND :NEW.id_periodo IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_periodo.'); END IF;

IF UPDATING AND ((:OLD.id_calificacion_seleccionada<>:NEW.id_calificacion_seleccionada) OR (:OLD.id_calificacion_seleccionada IS NULL AND :NEW.id_calificacion_seleccionada IS NOT NULL) OR (:OLD.id_calificacion_seleccionada IS NOT NULL AND :NEW.id_calificacion_seleccionada IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir id_calificacion_seleccionada.'); END IF;

IF UPDATING AND ((:OLD.version<>:NEW.version) OR (:OLD.version IS NULL AND :NEW.version IS NOT NULL) OR (:OLD.version IS NOT NULL AND :NEW.version IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir version.'); END IF;

IF UPDATING AND ((:OLD.criterio<>:NEW.criterio) OR (:OLD.criterio IS NULL AND :NEW.criterio IS NOT NULL) OR (:OLD.criterio IS NOT NULL AND :NEW.criterio IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir criterio.'); END IF;

IF UPDATING AND ((:OLD.fecha_seleccion<>:NEW.fecha_seleccion) OR (:OLD.fecha_seleccion IS NULL AND :NEW.fecha_seleccion IS NOT NULL) OR (:OLD.fecha_seleccion IS NOT NULL AND :NEW.fecha_seleccion IS NULL)) THEN RAISE_APPLICATION_ERROR(-20805,'Crear nueva version; no sobrescribir fecha_seleccion.'); END IF;

IF UPDATING AND :OLD.fecha_cierre IS NOT NULL AND (:NEW.fecha_cierre IS NULL OR :OLD.fecha_cierre<>:NEW.fecha_cierre) THEN RAISE_APPLICATION_ERROR(-20805,'No se reescribe fecha_cierre; nueva version o reapertura.'); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_resultado' VALUE :OLD.id_resultado,'id_estudiante' VALUE :OLD.id_estudiante,'id_asignatura' VALUE :OLD.id_asignatura,'id_periodo' VALUE :OLD.id_periodo,'id_calificacion_seleccionada' VALUE :OLD.id_calificacion_seleccionada,'version' VALUE :OLD.version,'criterio' VALUE :OLD.criterio,'fecha_seleccion' VALUE :OLD.fecha_seleccion,'fecha_cierre' VALUE :OLD.fecha_cierre RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_resultado' VALUE :NEW.id_resultado,'id_estudiante' VALUE :NEW.id_estudiante,'id_asignatura' VALUE :NEW.id_asignatura,'id_periodo' VALUE :NEW.id_periodo,'id_calificacion_seleccionada' VALUE :NEW.id_calificacion_seleccionada,'version' VALUE :NEW.version,'criterio' VALUE :NEW.criterio,'fecha_seleccion' VALUE :NEW.fecha_seleccion,'fecha_cierre' VALUE :NEW.fecha_cierre RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_resultado,:OLD.id_resultado));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_resultado_periodo',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_RESULTADO_PERIODO'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_SESION_CLASE ===
CREATE OR REPLACE TRIGGER trg_val_trx_sesion_clase
 FOR INSERT OR UPDATE OR DELETE ON trx_sesion_clase
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_SESION_CLASE: protege trx_sesion_clase.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: observaciones.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 3 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_SESIONES_SIMULTANEAS: Un docente o grupo no recibe dos sesiones simultáneas.
  --   - OPERACION_SESION_CONTEXTO: Sesión y responsabilidad compatibles; noche puede terminar al
  --     día siguiente.
  -- Otras 14 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_sesion<>:NEW.id_sesion THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.observaciones:=fn_limpiar_texto(:NEW.observaciones); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_sesion' VALUE :OLD.id_sesion,'id_ponderacion_periodo' VALUE :OLD.id_ponderacion_periodo,'id_asignacion' VALUE :OLD.id_asignacion,'fecha_academica' VALUE :OLD.fecha_academica,'inicio' VALUE :OLD.inicio,'fin' VALUE :OLD.fin,'estado' VALUE :OLD.estado,'observaciones' VALUE :OLD.observaciones RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_sesion' VALUE :NEW.id_sesion,'id_ponderacion_periodo' VALUE :NEW.id_ponderacion_periodo,'id_asignacion' VALUE :NEW.id_asignacion,'fecha_academica' VALUE :NEW.fecha_academica,'inicio' VALUE :NEW.inicio,'fin' VALUE :NEW.fin,'estado' VALUE :NEW.estado,'observaciones' VALUE :NEW.observaciones RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_sesion,:OLD.id_sesion));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_sesion_clase',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_SESION_CLASE'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_ASISTENCIA ===
CREATE OR REPLACE TRIGGER trg_val_trx_asistencia
 FOR INSERT OR UPDATE OR DELETE ON trx_asistencia
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_ASISTENCIA: protege trx_asistencia.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: observaciones.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 2 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_ASISTENCIA_CONTEXTO: La asistencia pertenece al curso e intervalo de la
  --     sesión.
  --   - OPERACION_ASISTENCIA_LLEGADA: Ausencia/justificación sin hora de llegada.
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_asistencia<>:NEW.id_asistencia THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.observaciones:=fn_limpiar_texto(:NEW.observaciones); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_asistencia' VALUE :OLD.id_asistencia,'id_inscripcion' VALUE :OLD.id_inscripcion,'id_sesion' VALUE :OLD.id_sesion,'estado' VALUE :OLD.estado,'hora_llegada' VALUE :OLD.hora_llegada,'fecha_registro' VALUE :OLD.fecha_registro,'observaciones' VALUE :OLD.observaciones RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_asistencia' VALUE :NEW.id_asistencia,'id_inscripcion' VALUE :NEW.id_inscripcion,'id_sesion' VALUE :NEW.id_sesion,'estado' VALUE :NEW.estado,'hora_llegada' VALUE :NEW.hora_llegada,'fecha_registro' VALUE :NEW.fecha_registro,'observaciones' VALUE :NEW.observaciones RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_asistencia,:OLD.id_asistencia));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_asistencia',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_ASISTENCIA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_BECA ===
CREATE OR REPLACE TRIGGER trg_val_trx_beca
 FOR INSERT OR UPDATE OR DELETE ON trx_beca
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_BECA: protege trx_beca.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  --   - Normaliza espacios de texto antes de guardar: observaciones.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 4 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_BECA_HABILITADA: El beneficio respeta la habilitación histórica del centro.
  --   - OPERACION_BECA_SOLAPADA: Una beca no tiene intervalos efectivos solapados.
  --   - OPERACION_BECA_VIGENCIA: El intervalo efectivo queda dentro de matrícula y ciclo.
  --   - OPERACION_PORCENTAJE_SIMULTANEO: Beneficios simultáneos de la misma inscripción y base
  --     no superan 100.
  -- Otras 12 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_beca<>:NEW.id_beca THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

IF NOT DELETING THEN :NEW.observaciones:=fn_limpiar_texto(:NEW.observaciones); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_beca' VALUE :OLD.id_beca,'id_inscripcion' VALUE :OLD.id_inscripcion,'id_tipo_beca' VALUE :OLD.id_tipo_beca,'porcentaje' VALUE :OLD.porcentaje,'fecha_otorgamiento' VALUE :OLD.fecha_otorgamiento,'fecha_registro' VALUE :OLD.fecha_registro,'observaciones' VALUE :OLD.observaciones RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_beca' VALUE :NEW.id_beca,'id_inscripcion' VALUE :NEW.id_inscripcion,'id_tipo_beca' VALUE :NEW.id_tipo_beca,'porcentaje' VALUE :NEW.porcentaje,'fecha_otorgamiento' VALUE :NEW.fecha_otorgamiento,'fecha_registro' VALUE :NEW.fecha_registro,'observaciones' VALUE :NEW.observaciones RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_beca,:OLD.id_beca));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_beca',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_BECA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_BECA_VIGENCIA ===
CREATE OR REPLACE TRIGGER trg_val_trx_beca_vigencia
 FOR INSERT OR UPDATE OR DELETE ON trx_beca_vigencia
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_BECA_VIGENCIA: protege trx_beca_vigencia.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 3 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_BECA_SOLAPADA: Una beca no tiene intervalos efectivos solapados.
  --   - OPERACION_BECA_VIGENCIA: El intervalo efectivo queda dentro de matrícula y ciclo.
  --   - OPERACION_PORCENTAJE_SIMULTANEO: Beneficios simultáneos de la misma inscripción y base
  --     no superan 100.
  -- Otras 10 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_vigencia<>:NEW.id_vigencia THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_vigencia' VALUE :OLD.id_vigencia,'id_beca' VALUE :OLD.id_beca,'fecha_inicio' VALUE :OLD.fecha_inicio,'fecha_fin' VALUE :OLD.fecha_fin,'motivo_fin' VALUE :OLD.motivo_fin,'fecha_registro' VALUE :OLD.fecha_registro RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_vigencia' VALUE :NEW.id_vigencia,'id_beca' VALUE :NEW.id_beca,'fecha_inicio' VALUE :NEW.fecha_inicio,'fecha_fin' VALUE :NEW.fecha_fin,'motivo_fin' VALUE :NEW.motivo_fin,'fecha_registro' VALUE :NEW.fecha_registro RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_vigencia,:OLD.id_vigencia));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_beca_vigencia',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_BECA_VIGENCIA'); END AFTER STATEMENT;
END;
/

-- === TRG_VAL_TRX_CONTROL_CARGA ===
CREATE OR REPLACE TRIGGER trg_val_trx_control_carga
 FOR INSERT OR UPDATE OR DELETE ON trx_control_carga
 COMPOUND TRIGGER
  -- ----------------------------------------------------------------------
  -- TRG_VAL_TRX_CONTROL_CARGA: protege trx_control_carga.
  -- Al iniciar la sentencia: toma la guardia (pr_bloquear_validaciones).
  -- Antes de cada fila:
  --   - La clave primaria no se renumera en un UPDATE.
  -- Después de cada fila: registra el cambio en val_cambio (si val_politica.auditar_cambios = 1).
  -- Al terminar la sentencia: pr_validar_operacion revisa las 1 reglas BLOQUEO que leen esta tabla:
  --   - OPERACION_CONTROL_CICLO: El curso y período del control pertenecen al mismo ciclo.
  -- Otras 18 reglas espejo (NOT NULL, claves, CHECK) las aplica la propia tabla con su DDL.
  -- ----------------------------------------------------------------------
 BEFORE STATEMENT IS BEGIN pr_bloquear_validaciones; END BEFORE STATEMENT;
 BEFORE EACH ROW IS BEGIN

IF UPDATING AND :OLD.id_control<>:NEW.id_control THEN RAISE_APPLICATION_ERROR(-20805,'No se renumeran claves primarias.'); END IF;

END BEFORE EACH ROW;
AFTER EACH ROW IS
 a CLOB;d CLOB;n NUMBER; k VARCHAR2(1000);ac VARCHAR2(10);
BEGIN
SELECT auditar_cambios INTO n FROM val_politica WHERE id=1;
IF n=1 THEN
IF INSERTING THEN ac:='INSERT';ELSIF UPDATING THEN ac:='UPDATE';ELSE ac:='DELETE';END IF;

IF NOT INSERTING THEN SELECT JSON_OBJECT('id_control' VALUE :OLD.id_control,'id_curso' VALUE :OLD.id_curso,'id_periodo' VALUE :OLD.id_periodo,'dominio' VALUE :OLD.dominio,'fecha_corte' VALUE :OLD.fecha_corte,'estado' VALUE :OLD.estado,'registros_declarados' VALUE :OLD.registros_declarados,'fecha_recepcion' VALUE :OLD.fecha_recepcion,'id_ejecucion' VALUE :OLD.id_ejecucion RETURNING CLOB) INTO a FROM dual; END IF;

IF NOT DELETING THEN SELECT JSON_OBJECT('id_control' VALUE :NEW.id_control,'id_curso' VALUE :NEW.id_curso,'id_periodo' VALUE :NEW.id_periodo,'dominio' VALUE :NEW.dominio,'fecha_corte' VALUE :NEW.fecha_corte,'estado' VALUE :NEW.estado,'registros_declarados' VALUE :NEW.registros_declarados,'fecha_recepcion' VALUE :NEW.fecha_recepcion,'id_ejecucion' VALUE :NEW.id_ejecucion RETURNING CLOB) INTO d FROM dual; END IF;

k:=TO_CHAR(COALESCE(:NEW.id_control,:OLD.id_control));

INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,antes,despues) VALUES ('trx_control_carga',k,ac,SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,fn_id_transaccion(),a,d);

END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS BEGIN pr_validar_operacion('OPERACION','TRX_CONTROL_CARGA'); END AFTER STATEMENT;
END;
/
