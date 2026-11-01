-- ==============================================================
-- SECCIÓN 1: TABLAS DE CONTROL
-- Descripción: Las 8 tablas propias de las validaciones. Todo lo demás lee o escribe en ellas.
--   Sus filas iniciales (guardia, política y reglas) se cargan al final, en 09_CATALOGO_REGLAS.sql.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === VAL_GUARDIA ===
-- Fila única que serializa las validaciones del OLTP (pr_bloquear_validaciones).
CREATE TABLE val_guardia (id NUMBER PRIMARY KEY, version NUMBER NOT NULL,
 CONSTRAINT ck_val_guardia CHECK (id=1 AND version>=0 AND version=TRUNC(version)));
COMMENT ON TABLE val_guardia IS 'Fila única que serializa las validaciones del OLTP (pr_bloquear_validaciones).';

-- === VAL_POLITICA ===
-- Opciones de la instalación: capacidad estricta, tolerancia de tardanza, auditoría de cambios y horas para dar por interrumpida una carga.
CREATE TABLE val_politica (id NUMBER PRIMARY KEY, capacidad_estricta NUMBER DEFAULT 0 NOT NULL,
 minutos_tardanza NUMBER, auditar_cambios NUMBER DEFAULT 1 NOT NULL,
 horas_interrupcion NUMBER DEFAULT 24 NOT NULL,
 CONSTRAINT ck_val_politica CHECK (id=1 AND capacidad_estricta IN (0,1)
 AND auditar_cambios IN (0,1) AND (minutos_tardanza IS NULL OR minutos_tardanza>=0)
 AND horas_interrupcion>0));
COMMENT ON TABLE val_politica IS 'Opciones de la instalación: capacidad estricta, tolerancia de tardanza, auditoría de cambios y horas para dar por interrumpida una carga.';

-- === VAL_REGLA ===
-- Catálogo de reglas: capa, tabla, severidad, descripción y la consulta que devuelve las filas que la incumplen.
CREATE TABLE val_regla (id_regla VARCHAR2(128 CHAR) PRIMARY KEY, capa VARCHAR2(12 CHAR) NOT NULL,
 entidad VARCHAR2(128 CHAR) NOT NULL, severidad VARCHAR2(12 CHAR) NOT NULL,
 descripcion VARCHAR2(1000 CHAR) NOT NULL, consulta CLOB NOT NULL,
 CONSTRAINT ck_val_regla CHECK (capa IN ('OPERACION','STAGING') AND severidad IN ('BLOQUEO','PENDIENTE','AVISO')));
COMMENT ON TABLE val_regla IS 'Catálogo de reglas: capa, tabla, severidad, descripción y la consulta que devuelve las filas que la incumplen.';

-- === VAL_REGLA_TABLA ===
-- Tablas que lee cada regla; la calcula pr_recalcular_alcance.
CREATE TABLE val_regla_tabla (id_regla VARCHAR2(128 CHAR) NOT NULL REFERENCES val_regla(id_regla),
 tabla VARCHAR2(128 CHAR) NOT NULL, CONSTRAINT pk_val_regla_tabla PRIMARY KEY (id_regla,tabla));
CREATE INDEX ix_val_regla_tabla ON val_regla_tabla(tabla,id_regla);
COMMENT ON TABLE val_regla_tabla IS 'Tablas que lee cada regla; la calcula pr_recalcular_alcance.';

-- === VAL_REGLA_DDL ===
-- Reglas espejo de una restricción del DDL (NOT NULL, CHECK, UNIQUE, FK) y si esa restricción existe (cubierta).
CREATE TABLE val_regla_ddl (id_regla VARCHAR2(128 CHAR) PRIMARY KEY REFERENCES val_regla(id_regla),
 tipo VARCHAR2(2 CHAR) NOT NULL, tabla VARCHAR2(128 CHAR) NOT NULL, columnas VARCHAR2(1000 CHAR),
 referencia VARCHAR2(128 CHAR), condicion VARCHAR2(4000 CHAR), cubierta NUMBER(1) DEFAULT 0 NOT NULL,
 CONSTRAINT ck_val_regla_ddl CHECK (tipo IN ('NN','CK','UK','FK') AND cubierta IN (0,1)));
COMMENT ON TABLE val_regla_ddl IS 'Reglas espejo de una restricción del DDL (NOT NULL, CHECK, UNIQUE, FK) y si esa restricción existe (cubierta).';

-- === VAL_INCIDENCIA ===
-- Resultado del último diagnóstico de cada regla: cantidad de filas y estado.
CREATE TABLE val_incidencia (id_regla VARCHAR2(128 CHAR) PRIMARY KEY REFERENCES val_regla(id_regla),
 cantidad NUMBER NOT NULL, estado VARCHAR2(10 CHAR) NOT NULL,
 primera_deteccion TIMESTAMP(6) NOT NULL, ultima_revision TIMESTAMP(6) NOT NULL,
 fecha_resolucion TIMESTAMP(6), responsable VARCHAR2(128 CHAR), comentario VARCHAR2(1000 CHAR),
 CONSTRAINT ck_val_incidencia CHECK (cantidad>=0 AND estado IN ('ABIERTA','RESUELTA')));
COMMENT ON TABLE val_incidencia IS 'Resultado del último diagnóstico de cada regla: cantidad de filas y estado.';

-- === VAL_CAMBIO ===
-- Auditoría: quién cambió qué, cuándo, en qué transacción, con el antes y el después en JSON.
CREATE TABLE val_cambio (id_cambio NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 entidad VARCHAR2(128 CHAR) NOT NULL, clave VARCHAR2(1000 CHAR), accion VARCHAR2(30 CHAR) NOT NULL,
 actor VARCHAR2(128 CHAR) NOT NULL, fecha TIMESTAMP(6) NOT NULL,
 transaccion VARCHAR2(100 CHAR), motivo VARCHAR2(1000 CHAR),
 antes CLOB, despues CLOB,
 CONSTRAINT ck_val_cambio_a CHECK (antes IS JSON STRICT),
 CONSTRAINT ck_val_cambio_d CHECK (despues IS JSON STRICT));
COMMENT ON TABLE val_cambio IS 'Auditoría: quién cambió qué, cuándo, en qué transacción, con el antes y el después en JSON.';

-- === RAW_ENTRADA_DATOS ===
-- Entradas recibidas tal como llegaron, con su estado (RECIBIDA, ACEPTADA o RECHAZADA).
CREATE TABLE raw_entrada_datos (id_entrada NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 lote VARCHAR2(100 CHAR) NOT NULL, fila NUMBER NOT NULL, entidad VARCHAR2(128 CHAR) NOT NULL,
 origen VARCHAR2(500 CHAR) NOT NULL, contenido_original CLOB NOT NULL,
 fecha TIMESTAMP(6) NOT NULL, estado VARCHAR2(12 CHAR) DEFAULT 'RECIBIDA' NOT NULL,
 detalle VARCHAR2(1000 CHAR),
 CONSTRAINT uk_raw_entrada UNIQUE(lote,fila),
 CONSTRAINT ck_raw_entrada CHECK (fila>0 AND fila=TRUNC(fila) AND estado IN ('RECIBIDA','ACEPTADA','RECHAZADA')));
COMMENT ON TABLE raw_entrada_datos IS 'Entradas recibidas tal como llegaron, con su estado (RECIBIDA, ACEPTADA o RECHAZADA).';
