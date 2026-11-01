-- ==============================================================
-- INSTALAR_VALIDACIONES.sql
-- Descripción: Instala las validaciones del modelo educativo (Oracle 23ai; también 19c y 21c)
--   sobre un OLTP ya creado (General/SCRIPT_BASE.sql) y su staging (Staging/CREACION_STAGING.sql).
--   Ejecuta los archivos 00 a 10 de esta carpeta, en orden.
--
-- Cómo ejecutarlo: como script (F5 en SQL Developer, o SQLcl / SQL*Plus), en una sesión del
--   propietario sin transacciones pendientes. El script maestro lo llama en su paso 4.
-- Es aditivo y se instala una vez: no borra ni corrige datos. Oracle confirma cada DDL, así que
--   la instalación no es atómica; si se interrumpe, revisar USER_ERRORS y los objetos VAL_*
--   antes de seguir. Para reinstalar, empezar con un usuario nuevo.
--
-- Después de instalar:
--   EXEC pr_cargar_staging;               copia el OLTP a staging
--   EXEC pr_diagnosticar_validaciones;    revisa todas las reglas sin bloquear; ver vw_avisos_calidad
--   EXEC pr_probar_validaciones;          pruebas nativas, SOLO en un esquema de pruebas
--   EXEC pr_recalcular_alcance;           si cambia el DDL del OLTP o se agregan reglas
--
-- Notas de uso:
--   - Entrada recomendada: pr_guardar_registro(tabla, JSON, 'INSERT' | 'UPDATE'). Números JSON sin
--     comillas ni exponentes (hasta 38 dígitos); fechas YYYY-MM-DD; timestamps YYYY-MM-DD HH24:MI:SS.FF6.
--   - Una guardia global (val_guardia) serializa los cambios del OLTP: espera hasta 10 segundos.
--   - Solo bloquean las reglas de severidad BLOQUEO; PENDIENTE y AVISO se consultan.
--   - Capacidad estricta y tardanza vienen desactivadas (val_politica). No se envían correos.
--   - El propietario puede deshabilitar cualquier control: no es una frontera de seguridad.
--     Para usuarios de trabajo, ver pr_configurar_acceso.
-- ==============================================================

SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';

PROMPT  0/10 Prevalidación: sesión, nombres reservados y contrato del OLTP...
@@00_PREVALIDACION.sql
PROMPT  1/10 Tablas de control...
@@01_TABLAS_CONTROL.sql
PROMPT  2/10 Restricciones adicionales (ENABLE VALIDATE)...
@@02_RESTRICCIONES.sql
PROMPT  3/10 Procedimientos base...
@@03_PROCEDIMIENTOS_BASE.sql
PROMPT  4/10 Triggers del OLTP...
@@04_TRIGGERS_OLTP.sql
PROMPT  5/10 Consultas y seguimiento...
@@05_CONSULTAS.sql
PROMPT  6/10 Operaciones...
@@06_OPERACIONES.sql
PROMPT  7/10 Cargador de staging y protección de las copias...
@@07_CARGADOR_STAGING.sql
PROMPT  8/10 Pruebas nativas (se instalan, no se ejecutan)...
@@08_PRUEBAS.sql
PROMPT  9/10 Catálogo de reglas...
@@09_CATALOGO_REGLAS.sql
PROMPT 10/10 Verificación: alcance, compilación y datos existentes...
@@10_VERIFICACION.sql
