-- ==============================================================
-- SECCIÓN 3: PROCEDIMIENTOS BASE
-- Descripción: El motor de las validaciones: guardia, ejecución y diagnóstico de reglas, alcance de cada regla
--   y funciones de limpieza. Los usan los triggers, las operaciones y el cargador.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === FN_LIMPIAR_TEXTO ===
CREATE OR REPLACE FUNCTION fn_limpiar_texto(p_texto VARCHAR2) RETURN VARCHAR2
 AUTHID DEFINER DETERMINISTIC IS
  -- ----------------------------------------------------------------------
  -- FN_LIMPIAR_TEXTO
  -- Quita espacios al inicio y al final de un texto. La usan los triggers antes de guardar.
  -- ----------------------------------------------------------------------
BEGIN RETURN TRIM(p_texto); END;
/

-- === FN_NORMALIZAR_CODIGO ===
CREATE OR REPLACE FUNCTION fn_normalizar_codigo(p_texto VARCHAR2) RETURN VARCHAR2
 AUTHID DEFINER DETERMINISTIC IS
  -- ----------------------------------------------------------------------
  -- FN_NORMALIZAR_CODIGO
  -- Quita espacios y pasa a mayúsculas un código.
  -- ----------------------------------------------------------------------
BEGIN RETURN UPPER(TRIM(p_texto)); END;
/

-- === FN_ID_TRANSACCION ===
CREATE OR REPLACE FUNCTION fn_id_transaccion RETURN VARCHAR2 AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- FN_ID_TRANSACCION
  -- Devuelve el id de la transacción en curso, para agrupar los cambios en val_cambio.
  -- ----------------------------------------------------------------------
BEGIN RETURN DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(FALSE); END;
/

-- === PR_BLOQUEAR_VALIDACIONES ===
CREATE OR REPLACE PROCEDURE pr_bloquear_validaciones AUTHID DEFINER IS n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_BLOQUEAR_VALIDACIONES
  -- Guardia global: toma la fila de val_guardia (espera hasta 10 s). Serializa los cambios del
  -- OLTP para que dos sesiones no validen datos a medias. La llama cada trigger al inicio de
  -- la sentencia.
  -- ----------------------------------------------------------------------
BEGIN
 SELECT version INTO n FROM val_guardia WHERE id=1 FOR UPDATE WAIT 10;
 UPDATE val_guardia SET version=version+1 WHERE id=1;
END;
/

-- === PR_VALIDAR_OPERACION ===
CREATE OR REPLACE PROCEDURE pr_validar_operacion(p_capa VARCHAR2 DEFAULT 'OPERACION',p_tabla VARCHAR2 DEFAULT NULL)
 AUTHID DEFINER IS n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_VALIDAR_OPERACION
  -- Ejecuta las reglas BLOQUEO de val_regla. Sin p_tabla revisa todas las de la capa
  -- (instalación, cargador, pruebas). Con p_tabla (desde los triggers) revisa solo las que
  -- leen esa tabla y omite las reglas espejo que ya aplica el DDL. Si una regla encuentra
  -- filas, falla con -20802 y el nombre de la regla.
  -- Sin p_tabla revisa todas las reglas BLOQUEO de la capa (instalacion, cargador, pruebas).
  -- Con p_tabla (triggers) revisa solo las que leen esa tabla y omite las espejo cubiertas por el DDL:
  -- una sentencia sobre otra tabla no puede cambiar su resultado.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_capa NOT IN ('OPERACION','STAGING') OR p_capa IS NULL THEN
  RAISE_APPLICATION_ERROR(-20801,'Capa invalida.'); END IF;
 IF p_tabla IS NOT NULL THEN
  SELECT COUNT(*) INTO n FROM val_regla_tabla WHERE ROWNUM=1;
  IF n=0 THEN RAISE_APPLICATION_ERROR(-20801,'Alcance de reglas no calculado: ejecutar PR_RECALCULAR_ALCANCE.'); END IF;
 END IF;
 FOR r IN (SELECT v.* FROM val_regla v WHERE v.capa=p_capa AND v.severidad='BLOQUEO'
  AND (p_tabla IS NULL OR (EXISTS (SELECT 1 FROM val_regla_tabla t WHERE t.id_regla=v.id_regla AND t.tabla=UPPER(p_tabla))
   AND NOT EXISTS (SELECT 1 FROM val_regla_ddl d WHERE d.id_regla=v.id_regla AND d.cubierta=1)))
  ORDER BY v.id_regla) LOOP
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||r.consulta||')' INTO n;
  IF n>0 THEN RAISE_APPLICATION_ERROR(-20802,SUBSTR(r.id_regla||': '||n||' registros; '||r.descripcion,1,1800)); END IF;
 END LOOP;
END;
/

-- === PR_DIAGNOSTICAR_VALIDACIONES ===
CREATE OR REPLACE PROCEDURE pr_diagnosticar_validaciones(p_capa VARCHAR2 DEFAULT 'OPERACION')
 AUTHID DEFINER IS n NUMBER; f TIMESTAMP:=LOCALTIMESTAMP;
  -- ----------------------------------------------------------------------
  -- PR_DIAGNOSTICAR_VALIDACIONES
  -- Revisa todas las reglas de la capa, de cualquier severidad, sin bloquear. Guarda la
  -- cantidad de filas de cada regla en val_incidencia (ABIERTA o RESUELTA). Se consulta con
  -- vw_avisos_calidad.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_diagnostico;
 pr_bloquear_validaciones;
 IF p_capa IS NULL OR p_capa NOT IN ('OPERACION','STAGING') THEN RAISE_APPLICATION_ERROR(-20801,'Capa invalida.'); END IF;
 FOR r IN (SELECT * FROM val_regla WHERE capa=p_capa ORDER BY id_regla) LOOP
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||r.consulta||')' INTO n;
  MERGE INTO val_incidencia d USING (SELECT r.id_regla id_regla FROM dual) s ON (d.id_regla=s.id_regla)
   WHEN MATCHED THEN UPDATE SET d.cantidad=n,d.estado=CASE WHEN n=0 THEN 'RESUELTA' ELSE 'ABIERTA' END,
     d.ultima_revision=f,d.fecha_resolucion=CASE WHEN n=0 THEN COALESCE(d.fecha_resolucion,f) END
   WHEN NOT MATCHED THEN INSERT(id_regla,cantidad,estado,primera_deteccion,ultima_revision)
     VALUES(s.id_regla,n,'ABIERTA',f,f) WHERE n>0;
 END LOOP;
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_diagnostico; RAISE;
END;
/

-- === PR_RECALCULAR_ALCANCE ===
CREATE OR REPLACE PROCEDURE pr_recalcular_alcance AUTHID DEFINER IS n NUMBER;c VARCHAR2(4000);
  -- ----------------------------------------------------------------------
  -- PR_RECALCULAR_ALCANCE
  -- Calcula qué tablas lee cada regla (val_regla_tabla) y marca las reglas espejo que ya cubre
  -- una restricción habilitada del DDL (val_regla_ddl.cubierta). Ejecutar de nuevo si cambia
  -- el DDL del OLTP o se agregan reglas.
  -- Tablas que lee cada regla y reglas espejo cubiertas por una restriccion habilitada del DDL.
  -- Ejecutar de nuevo si cambia el DDL del OLTP o se agregan reglas.
  -- ----------------------------------------------------------------------
 FUNCTION norm(p VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN UPPER(REGEXP_REPLACE(p,'[[:space:]"]',''));END;
BEGIN
 pr_bloquear_validaciones;
 DELETE FROM val_regla_tabla;
 INSERT INTO val_regla_tabla(id_regla,tabla)
 SELECT r.id_regla,t.table_name FROM val_regla r JOIN user_tables t
 ON REGEXP_LIKE(UPPER(r.consulta),'(^|[^A-Z0-9_$#])'||t.table_name||'([^A-Z0-9_$#]|$)');
 UPDATE val_regla_ddl SET cubierta=0;
 FOR d IN (SELECT * FROM val_regla_ddl) LOOP
  n:=0;
  IF d.tipo='NN' THEN
   SELECT COUNT(*) INTO n FROM user_tab_columns WHERE table_name=UPPER(d.tabla) AND column_name=d.columnas AND nullable='N';
  ELSIF d.tipo='CK' THEN
   FOR k IN (SELECT search_condition_vc s FROM user_constraints WHERE table_name=UPPER(d.tabla)
    AND constraint_type='C' AND status='ENABLED') LOOP
    IF norm(k.s)=norm(d.condicion) THEN n:=1; END IF;
   END LOOP;
  ELSE
   FOR k IN (SELECT uc.constraint_name,(SELECT x.table_name FROM user_constraints x WHERE x.constraint_name=uc.r_constraint_name) padre
    FROM user_constraints uc WHERE uc.table_name=UPPER(d.tabla) AND uc.status='ENABLED'
    AND ((d.tipo='UK' AND uc.constraint_type IN ('P','U')) OR (d.tipo='FK' AND uc.constraint_type='R'))) LOOP
    SELECT LISTAGG(column_name,',') WITHIN GROUP (ORDER BY NLSSORT(column_name,'NLS_SORT=BINARY')) INTO c FROM user_cons_columns
    WHERE constraint_name=k.constraint_name;
    IF c=d.columnas AND (d.tipo='UK' OR k.padre=d.referencia) THEN n:=1; END IF;
   END LOOP;
  END IF;
  IF n>0 THEN UPDATE val_regla_ddl SET cubierta=1 WHERE id_regla=d.id_regla; END IF;
 END LOOP;
 SELECT COUNT(*) INTO n FROM val_regla_tabla;
 IF n=0 THEN RAISE_APPLICATION_ERROR(-20801,'No se pudo calcular el alcance de las reglas.'); END IF;
END;
/

-- === FN_VALIDAR_NUMERO ===
CREATE OR REPLACE FUNCTION fn_validar_numero(p_num NUMBER,p_precision NUMBER,p_escala NUMBER)
 RETURN NUMBER AUTHID DEFINER DETERMINISTIC IS
  -- ----------------------------------------------------------------------
  -- FN_VALIDAR_NUMERO
  -- Devuelve el número si cabe en la precisión y escala indicadas; si no, falla con -20803. No
  -- redondea.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_num IS NULL THEN RETURN NULL; END IF;
 IF p_num<>TRUNC(p_num,NVL(p_escala,0)) OR
   (p_precision IS NOT NULL AND ABS(p_num)>=POWER(10,p_precision-NVL(p_escala,0))) THEN
  RAISE_APPLICATION_ERROR(-20803,'Numero excede precision/escala; no se redondea.'); END IF;
 RETURN p_num;
END;
/
