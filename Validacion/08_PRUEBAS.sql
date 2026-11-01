-- ==============================================================
-- SECCIÓN 8: PRUEBAS NATIVAS
-- Descripción: pr_probar_validaciones se instala pero no se ejecuta: hace cambios de prueba y solo debe
--   correrse en un esquema de pruebas.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === PR_PROBAR_VALIDACIONES ===
CREATE OR REPLACE PROCEDURE pr_probar_validaciones AUTHID DEFINER IS n NUMBER;fallo BOOLEAN;c NUMBER;per NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_PROBAR_VALIDACIONES
  -- Pruebas nativas: intenta operaciones inválidas y comprueba que se rechazan. Solo en un
  -- esquema de pruebas: EXEC pr_probar_validaciones;
  -- ----------------------------------------------------------------------
 PROCEDURE exigir(p_ok BOOLEAN,p_texto VARCHAR2) IS BEGIN
 IF p_ok IS NULL OR NOT p_ok THEN RAISE_APPLICATION_ERROR(-20890,'PRUEBA: '||p_texto);END IF;
 DBMS_OUTPUT.PUT_LINE('OK: '||p_texto);END;
 PROCEDURE rechaza(p_sql VARCHAR2,p_codigo NUMBER,p_texto VARCHAR2) IS ok BOOLEAN:=FALSE;
 BEGIN
  SAVEPOINT sv_prueba;
  BEGIN EXECUTE IMMEDIATE p_sql;
  EXCEPTION WHEN OTHERS THEN IF SQLCODE=p_codigo THEN ok:=TRUE; ELSE RAISE; END IF; END;
  ROLLBACK TO sv_prueba;exigir(ok,p_texto);
 END;
BEGIN
 SAVEPOINT sv_todas_pruebas;
 pr_validar_operacion;
 exigir(fn_validar_numero(0,7,4)=0,'cero real permitido');
 exigir(fn_validar_numero(100,7,4)=100,'cien permitido');
 
 rechaza('DECLARE n NUMBER; BEGIN n:=fn_validar_numero(80.12345,7,4);END;',-20803,'no redondear decimales');
 rechaza('DECLARE n NUMBER; BEGIN n:=fn_validar_numero(1.1,10,0);END;',-20803,'identificador entero');
 rechaza(q'~BEGIN pr_validar_json_numeros('{"nota":80.12340000000000000000000000000000000000000001}');END;~',-20803,'no perder decimales por conversion NUMBER');
 rechaza(q'~BEGIN pr_guardar_registro('est_ciclo','{"id_ciclo":1,"campo_desconocido":0}');END;~',-20804,'campo desconocido rechazado');
 SELECT COALESCE(MAX(id_ciclo),0)+1 INTO c FROM est_ciclo;
 SELECT COALESCE(MAX(id_periodo),0)+1 INTO per FROM est_periodo_academico;
 INSERT INTO est_ciclo(id_ciclo,codigo,nombre,anio,fecha_inicio,fecha_fin,estado)
 VALUES(c,'PRUEBA_'||c,'Interciclo flexible',2026,DATE '2026-12-15',DATE '2027-01-15','PLANIFICADO');
 INSERT INTO est_periodo_academico(id_periodo,id_ciclo,numero,nombre,fecha_inicio,fecha_fin)
 VALUES(per,c,4,'Periodo configurable',DATE '2026-12-15',DATE '2027-01-15');
 exigir(TRUE,'ciclo de un mes, cruce de anio y cuarto periodo permitidos');
 SELECT COUNT(*) INTO n FROM val_regla_tabla WHERE tabla='EST_PERIODO_ACADEMICO';
 exigir(n>0,'alcance de reglas calculado para cada tabla');
 DECLARE q CLOB; BEGIN
  SELECT consulta INTO q FROM val_regla WHERE id_regla='OPERACION_PERIODOS_CONSECUTIVOS';
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||') WHERE id_ciclo=:c' INTO n USING c;
 END;
 exigir(n=1,'aviso de numeracion con huecos detectado sin bloquear');
 DECLARE q CLOB; BEGIN
  SELECT consulta INTO q FROM val_regla WHERE id_regla='OPERACION_CICLO_ANIO_INICIO';
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||') WHERE id_ciclo=:c' INTO n USING c;
 END;
 exigir(n=0,'ciclo que cruza anios usa su anio de inicio');
 UPDATE est_ciclo SET anio=2027 WHERE id_ciclo=c;
 DECLARE q CLOB; BEGIN
  SELECT consulta INTO q FROM val_regla WHERE id_regla='OPERACION_CICLO_ANIO_INICIO';
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||q||') WHERE id_ciclo=:c' INTO n USING c;
 END;
 exigir(n=1,'aviso de anio distinto del inicio detectado sin bloquear');
 rechaza('BEGIN pr_cargar_staging;END;',-20815,'cargador rechaza transaccion previa sin revertirla');
 SELECT COUNT(*) INTO n FROM est_ciclo WHERE id_ciclo=c;
 exigir(n=1,'trabajo previo conservado tras rechazo del cargador');
 rechaza('UPDATE est_periodo_academico SET fecha_fin=DATE ''2027-02-01'' WHERE id_periodo='||TO_CHAR(per,'FM9999999990'),-20802,'periodo fuera de ciclo rechazado');
 rechaza(q'~BEGIN pr_guardar_registro('est_ciclo','{"id_ciclo":1.1,"codigo":"X"}');END;~',-20803,'entrada valida precision antes de columna');
 ROLLBACK TO sv_todas_pruebas;
 DBMS_OUTPUT.PUT_LINE('Pruebas terminadas y revertidas. Aun falta probar concurrencia y carga en una copia dedicada.');
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_todas_pruebas;RAISE;
END;
/
