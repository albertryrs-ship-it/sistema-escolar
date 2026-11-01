-- ==============================================================
-- comprobar_permisos.sql
-- Descripción: Antes de crear nada, revisa que el usuario tenga todos los permisos que usa la
--   instalación. Si falta alguno, se detiene y dice cuál, en vez de fallar a mitad de camino.
--   Lo llaman INSTALACION_COMPLETA.sql y MASIVA_1_ESTRUCTURA.sql.
-- ==============================================================
DECLARE
  v_faltan VARCHAR2(4000);
BEGIN
  SELECT LISTAGG(p.privilegio, ', ') WITHIN GROUP (ORDER BY p.privilegio)
    INTO v_faltan
    FROM (SELECT 'CREATE SESSION' privilegio FROM dual UNION ALL SELECT 'CREATE TABLE' FROM dual
          UNION ALL SELECT 'CREATE VIEW' FROM dual UNION ALL SELECT 'CREATE SEQUENCE' FROM dual
          UNION ALL SELECT 'CREATE PROCEDURE' FROM dual UNION ALL SELECT 'CREATE TRIGGER' FROM dual
          UNION ALL SELECT 'CREATE TYPE' FROM dual UNION ALL SELECT 'CREATE JOB' FROM dual
          UNION ALL SELECT 'CREATE MATERIALIZED VIEW' FROM dual) p   -- vistas materializadas (paso 11)
   WHERE NOT EXISTS (SELECT 1 FROM session_privs s WHERE s.privilege = p.privilegio);
  IF v_faltan IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20091, 'Faltan permisos: ' || v_faltan || '. Ver "Antes de empezar" en Script_Maestro/README.md.');
  END IF;
END;
/
