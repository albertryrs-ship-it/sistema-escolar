-- ==============================================================
-- SECCIÓN 10: VERIFICACIÓN
-- Descripción: Calcula el alcance de cada regla, revisa que todo compile y valida los datos existentes
--   con todas las reglas BLOQUEO. Si algo falla, se detiene con el motivo.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === Alcance de las reglas ===
BEGIN pr_recalcular_alcance; END;
/
DECLARE n NUMBER;m NUMBER; BEGIN
 SELECT COUNT(*),SUM(cubierta) INTO n,m FROM val_regla_ddl;
 DBMS_OUTPUT.PUT_LINE('Alcance calculado: '||m||' de '||n||' reglas espejo cubiertas por el DDL.');
END;
/

-- === Compilación y datos existentes ===
DECLARE n NUMBER; BEGIN
 SELECT COUNT(*) INTO n FROM user_errors WHERE name LIKE 'TRG_%' OR name LIKE 'PR_%' OR name LIKE 'FN_%';
 IF n>0 THEN
  FOR r IN (SELECT name,line,position,text FROM user_errors WHERE name LIKE 'TRG_%' OR name LIKE 'PR_%' OR name LIKE 'FN_%' ORDER BY name,sequence) LOOP
   DBMS_OUTPUT.PUT_LINE(r.name||' '||r.line||':'||r.position||' '||r.text);
  END LOOP;
  RAISE_APPLICATION_ERROR(-20899,'Hay errores de compilacion; no usar antes de corregirlos.');
 END IF;
 pr_validar_operacion;
END;
/
COMMIT;
PROMPT Instalacion terminada. La carga NO se ha ejecutado. Probar PR_PROBAR_VALIDACIONES en un esquema de pruebas.
PROMPT Registrar resultados de las pruebas concurrentes en dos sesiones; la guarda espera hasta 10 segundos.
PROMPT Antes de usar PR_CARGAR_STAGING, confirmar o revertir cualquier transaccion pendiente.
