-- =====================================================================
-- Data_Mart/01_CALENDARIO.sql  -  PROYECTO FINAL KODIGO (Caso 3)
-- DIM_TIEMPO: tabla calendario 2024-2027 (dim_tiempo del modelo estrella).
-- El codigo ISO 3166-2 de cada departamento (SV-AH, SV-SS...) viene en
-- cat_departamento.codigo y llega al modelo por STG_DEPARTAMENTOS.
-- Requiere el script maestro ya instalado. Re-ejecutable: crea la tabla solo si no existe
-- y actualiza el calendario con MERGE; no borra tablas ni datos.
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF
SET SQLBLANKLINES ON
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

DECLARE
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name IN ('STG_CALIFICACIONES', 'STG_DOCENTES', 'STG_ZONAS', 'STG_AREAS_CONOCIMIENTO');
  IF n <> 4 THEN
    RAISE_APPLICATION_ERROR(-20110, 'Falta el staging del equipo: ejecute primero el script maestro (INSTALACION_COMPLETA.sql).');
  END IF;
  SELECT COUNT(*) INTO n FROM user_sequences WHERE sequence_name IN ('SEQ_ETL_CARGA', 'SEQ_ETL_ERROR');
  IF n <> 2 THEN
    RAISE_APPLICATION_ERROR(-20111, 'Faltan SEQ_ETL_CARGA / SEQ_ETL_ERROR (se crean con Staging/CREACION_STAGING.sql).');
  END IF;
END;
/

-- ==============================================================
-- SECCIÓN 1: TABLA CALENDARIO
-- Descripción: DIM_TIEMPO: un día por fila, de 2024 a 2027. Se crea solo si no existe y se actualiza con MERGE.
-- ==============================================================
DECLARE n NUMBER; BEGIN
  SELECT COUNT(*) INTO n FROM user_tables WHERE table_name = 'DIM_TIEMPO';
  IF n = 0 THEN
    EXECUTE IMMEDIATE q'~CREATE TABLE dim_tiempo (
    id_tiempo       NUMBER(8,0)       NOT NULL,   -- AAAAMMDD
    fecha           DATE              NOT NULL,
    anio            NUMBER(4,0)       NOT NULL,
    semestre        NUMBER(1,0)       NOT NULL,
    trimestre       NUMBER(1,0)       NOT NULL,   -- trimestre calendario
    mes             NUMBER(2,0)       NOT NULL,
    nombre_mes      VARCHAR2(15 CHAR) NOT NULL,
    mes_corto       VARCHAR2(3 CHAR)  NOT NULL,
    anio_mes        VARCHAR2(7 CHAR)  NOT NULL,   -- AAAA-MM
    semana_iso      NUMBER(2,0)       NOT NULL,
    dia             NUMBER(2,0)       NOT NULL,
    dia_semana      NUMBER(1,0)       NOT NULL,   -- 1 = lunes ... 7 = domingo
    nombre_dia      VARCHAR2(10 CHAR) NOT NULL,
    es_fin_semana   NUMBER(1)         NOT NULL,
    es_dia_lectivo  NUMBER(1)         NOT NULL,   -- dentro de algun periodo academico y de lunes a viernes
    CONSTRAINT pk_dim_tiempo PRIMARY KEY (id_tiempo),
    CONSTRAINT uk_dim_tiempo_fecha UNIQUE (fecha),
    CONSTRAINT chk_dim_tiempo_fecha CHECK (fecha = TRUNC(fecha)),
    CONSTRAINT chk_dim_tiempo_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT chk_dim_tiempo_finde CHECK (es_fin_semana IN (0, 1)),
    CONSTRAINT chk_dim_tiempo_lectivo CHECK (es_dia_lectivo IN (0, 1))
)~';
  END IF;
END;
/

-- Si las tablas ya existían, deben tener la estructura esperada: el script no borra tablas ni datos.
-- Un cambio de estructura se migra con ALTER TABLE.
DECLARE
  PROCEDURE comprobar(p_tabla VARCHAR2, p_cols VARCHAR2) IS v VARCHAR2(4000); BEGIN
    SELECT LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_id) INTO v FROM user_tab_columns WHERE table_name = p_tabla;
    IF v IS NULL OR v <> p_cols THEN
      RAISE_APPLICATION_ERROR(-20114, 'Estructura distinta en '||p_tabla||'. Migrar con ALTER TABLE; el data mart no borra tablas.');
    END IF;
  END;
BEGIN
  comprobar('DIM_TIEMPO', 'ID_TIEMPO,FECHA,ANIO,SEMESTRE,TRIMESTRE,MES,NOMBRE_MES,MES_CORTO,ANIO_MES,SEMANA_ISO,DIA,DIA_SEMANA,NOMBRE_DIA,ES_FIN_SEMANA,ES_DIA_LECTIVO');
END;
/

-- MERGE por fecha: re-ejecutable sin duplicar días; actualiza es_dia_lectivo si cambian los períodos.
MERGE INTO dim_tiempo t
USING (
  SELECT TO_NUMBER(TO_CHAR(f.fecha, 'YYYYMMDD')) AS id_tiempo,
         f.fecha,
         EXTRACT(YEAR FROM f.fecha) AS anio,
         CASE WHEN EXTRACT(MONTH FROM f.fecha) <= 6 THEN 1 ELSE 2 END AS semestre,
         TO_NUMBER(TO_CHAR(f.fecha, 'Q')) AS trimestre,
         EXTRACT(MONTH FROM f.fecha) AS mes,
         CASE EXTRACT(MONTH FROM f.fecha)
           WHEN 1 THEN 'Enero'  WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'      WHEN 4 THEN 'Abril'
           WHEN 5 THEN 'Mayo'   WHEN 6 THEN 'Junio'   WHEN 7 THEN 'Julio'      WHEN 8 THEN 'Agosto'
           WHEN 9 THEN 'Septiembre' WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' ELSE 'Diciembre' END AS nombre_mes,
         CASE EXTRACT(MONTH FROM f.fecha)
           WHEN 1 THEN 'Ene' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar' WHEN 4 THEN 'Abr'
           WHEN 5 THEN 'May' WHEN 6 THEN 'Jun' WHEN 7 THEN 'Jul' WHEN 8 THEN 'Ago'
           WHEN 9 THEN 'Sep' WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' ELSE 'Dic' END AS mes_corto,
         TO_CHAR(f.fecha, 'YYYY-MM') AS anio_mes,
         TO_NUMBER(TO_CHAR(f.fecha, 'IW')) AS semana_iso,
         EXTRACT(DAY FROM f.fecha) AS dia,
         f.dsem AS dia_semana,
         CASE f.dsem WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN TO_CHAR(UNISTR('Mi\00E9rcoles'))
                     WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN TO_CHAR(UNISTR('S\00E1bado'))
                     ELSE 'Domingo' END AS nombre_dia,
         CASE WHEN f.dsem >= 6 THEN 1 ELSE 0 END AS es_fin_semana,
         CASE WHEN f.dsem <= 5 AND EXISTS (SELECT 1 FROM stg_periodos p
                                            WHERE f.fecha BETWEEN p.fecha_inicio AND p.fecha_fin)
              THEN 1 ELSE 0 END AS es_dia_lectivo
    FROM (SELECT DATE '2024-01-01' + LEVEL - 1 AS fecha,
                 (DATE '2024-01-01' + LEVEL - 1) - TRUNC(DATE '2024-01-01' + LEVEL - 1, 'IW') + 1 AS dsem
            FROM dual
          CONNECT BY LEVEL <= DATE '2027-12-31' - DATE '2024-01-01' + 1) f
) s
ON (t.id_tiempo = s.id_tiempo)
WHEN MATCHED THEN UPDATE SET
  t.fecha = s.fecha, t.anio = s.anio, t.semestre = s.semestre, t.trimestre = s.trimestre, t.mes = s.mes,
  t.nombre_mes = s.nombre_mes, t.mes_corto = s.mes_corto, t.anio_mes = s.anio_mes, t.semana_iso = s.semana_iso,
  t.dia = s.dia, t.dia_semana = s.dia_semana, t.nombre_dia = s.nombre_dia, t.es_fin_semana = s.es_fin_semana,
  t.es_dia_lectivo = s.es_dia_lectivo
WHEN NOT MATCHED THEN INSERT
  (id_tiempo, fecha, anio, semestre, trimestre, mes, nombre_mes, mes_corto, anio_mes, semana_iso, dia,
   dia_semana, nombre_dia, es_fin_semana, es_dia_lectivo)
  VALUES (s.id_tiempo, s.fecha, s.anio, s.semestre, s.trimestre, s.mes, s.nombre_mes, s.mes_corto, s.anio_mes,
          s.semana_iso, s.dia, s.dia_semana, s.nombre_dia, s.es_fin_semana, s.es_dia_lectivo);
COMMIT;

-- Departamentos: el codigo debe tener formato ISO (SV-__) para el mapa
SELECT codigo, nombre,
       CASE WHEN codigo LIKE 'SV-__' THEN 'OK' ELSE 'NO ES ISO' END AS formato_iso
  FROM cat_departamento
 ORDER BY nombre;

SELECT anio, COUNT(*) AS dias, SUM(es_dia_lectivo) AS dias_lectivos
  FROM dim_tiempo
 GROUP BY anio
 ORDER BY anio;
