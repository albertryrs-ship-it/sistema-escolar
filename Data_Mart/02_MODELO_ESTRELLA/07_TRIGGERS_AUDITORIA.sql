-- ==============================================================
-- SECCIÓN 7: TRIGGERS DE AUDITORÍA
-- Descripción: Cuentan en auditoria_etl_evaluaciones lo que hace cada ejecución del ETL: insertados y actualizados
--   desde hechos_resultados, y rechazados desde los errores del data mart (entidad DM:...).
--   La fecha de fin la pone el 03 al cerrar la ejecución.
-- ==============================================================

-- Se ejecuta desde INSTALAR_MODELO_ESTRELLA.sql, que fija las opciones de la sesión.

-- === TRG_HECHOS_AUDITORIA ===
CREATE OR REPLACE TRIGGER trg_hechos_auditoria
FOR INSERT OR UPDATE ON hechos_resultados
COMPOUND TRIGGER
  -- TRG_HECHOS_AUDITORIA: suma a la ejecución en curso las filas insertadas y actualizadas
  -- en hechos_resultados (una actualización por sentencia, no por fila).
  v_ins  PLS_INTEGER := 0;
  v_upd  PLS_INTEGER := 0;
  v_ejec NUMBER;

  AFTER EACH ROW IS
  BEGIN
    v_ejec := :NEW.id_ejecucion;
    IF INSERTING THEN
      v_ins := v_ins + 1;
    ELSE
      v_upd := v_upd + 1;
    END IF;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF v_ins + v_upd > 0 THEN
      UPDATE auditoria_etl_evaluaciones
         SET insertados = insertados + v_ins,
             actualizados = actualizados + v_upd
       WHERE id_ejecucion = v_ejec;
    END IF;
    v_ins := 0;
    v_upd := 0;
  END AFTER STATEMENT;
END trg_hechos_auditoria;
/

-- === TRG_ERRORES_ETL_AUDITORIA ===
CREATE OR REPLACE TRIGGER trg_errores_etl_auditoria
FOR INSERT ON errores_etl_evaluaciones
COMPOUND TRIGGER
  -- TRG_ERRORES_ETL_AUDITORIA: suma a la ejecución los rechazos del data mart (entidad DM:...).
  -- Los rechazos del cargador de staging no se cuentan aquí.
  v_ins  PLS_INTEGER := 0;
  v_upd  PLS_INTEGER := 0;
  v_ejec NUMBER;

  AFTER EACH ROW IS
  BEGIN
    IF :NEW.entidad LIKE 'DM:%' THEN
      v_ejec := :NEW.id_ejecucion;
      v_ins := v_ins + 1;
    END IF;
  END AFTER EACH ROW;

  AFTER STATEMENT IS
  BEGIN
    IF v_ins + v_upd > 0 THEN
      UPDATE auditoria_etl_evaluaciones
         SET rechazados = rechazados + v_ins
       WHERE id_ejecucion = v_ejec;
    END IF;
    v_ins := 0;
    v_upd := 0;
  END AFTER STATEMENT;
END trg_errores_etl_auditoria;
/
