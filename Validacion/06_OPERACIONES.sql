-- ==============================================================
-- SECCIÓN 6: OPERACIONES
-- Descripción: Procedimientos para las acciones de negocio: guardar registros, publicar planes, trasladar,
--   registrar, corregir y anular notas, becas, reaperturas, cierre de ciclo y permisos.
--   Cada uno valida su caso y falla con un error -208xx y el motivo; la operación se revierte.
-- ==============================================================

-- Se ejecuta desde INSTALAR_VALIDACIONES.sql, que fija las opciones de la sesión.

-- === PR_VALIDAR_JSON_NUMEROS ===
CREATE OR REPLACE PROCEDURE pr_validar_json_numeros(p_json CLOB) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_VALIDAR_JSON_NUMEROS
  -- Revisa que los números de un JSON de entrada sean decimales simples (sin exponente, hasta
  -- 38 dígitos) antes de convertirlos.
  -- ----------------------------------------------------------------------
 i PLS_INTEGER:=1;n PLS_INTEGER:=DBMS_LOB.GETLENGTH(p_json);ini PLS_INTEGER;
 c VARCHAR2(1 CHAR);t VARCHAR2(1000);dig PLS_INTEGER;en_texto BOOLEAN:=FALSE;esc BOOLEAN:=FALSE;
BEGIN
 WHILE i<=n LOOP
  c:=DBMS_LOB.SUBSTR(p_json,1,i);
  IF en_texto THEN
   IF esc THEN esc:=FALSE;
   ELSIF c=CHR(92) THEN esc:=TRUE;
   ELSIF c='"' THEN en_texto:=FALSE;END IF;
  ELSIF c='"' THEN en_texto:=TRUE;
  ELSIF c='-' OR c BETWEEN '0' AND '9' THEN
   ini:=i;dig:=0;
   WHILE i<=n LOOP
    c:=DBMS_LOB.SUBSTR(p_json,1,i);
    EXIT WHEN INSTR('0123456789eE+-.',c)=0;
    IF c BETWEEN '0' AND '9' THEN dig:=dig+1;END IF;
    IF c IN ('e','E') OR dig>38 THEN
     RAISE_APPLICATION_ERROR(-20803,'Numero JSON: usar decimal sin exponente y hasta 38 digitos; no se redondea.');END IF;
    i:=i+1;
   END LOOP;
   i:=i-1;
  END IF;
  i:=i+1;
 END LOOP;
END;
/

-- === PR_GUARDAR_REGISTRO ===
CREATE OR REPLACE PROCEDURE pr_guardar_registro(p_tabla VARCHAR2,p_datos CLOB,
 p_accion VARCHAR2 DEFAULT 'INSERT',p_historico NUMBER DEFAULT 0) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_GUARDAR_REGISTRO
  -- Entrada recomendada para cualquier tabla del OLTP: recibe la tabla, los datos en JSON y la
  -- acción (INSERT o UPDATE). Valida tipos, largos, precisión, fechas y claves antes de
  -- ejecutar; el UPDATE exige toda la clave primaria y no la cambia. Las reglas entre filas
  -- las aplican después los triggers.
  -- ----------------------------------------------------------------------
 j JSON_OBJECT_T; ks JSON_KEY_LIST; e JSON_ELEMENT_T;
 tabla VARCHAR2(128):=LOWER(TRIM(p_tabla)); accion VARCHAR2(6):=UPPER(p_accion);
 v_sql VARCHAR2(32767); v_cols VARCHAR2(32767); v_vals VARCHAR2(32767); v_where VARCHAR2(32767);
 v_cur INTEGER:=NULL; v_ret INTEGER; v_num NUMBER; v_txt VARCHAR2(32767); v_date DATE; v_ts TIMESTAMP;
 v_tipo VARCHAR2(30); v_prec NUMBER; v_scale NUMBER; v_largo NUMBER; v_pk NUMBER; v_known NUMBER;
 PROCEDURE meta(p_col VARCHAR2) IS BEGIN
  v_known:=0; v_tipo:=NULL; v_prec:=NULL; v_scale:=NULL; v_largo:=NULL; v_pk:=0;

IF tabla='cat_tipo_documento' THEN

IF p_col='id_tipo_documento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_tipo_institucion' THEN

IF p_col='id_tipo_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_departamento' THEN

IF p_col='id_departamento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_zona' THEN

IF p_col='id_zona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_modalidad' THEN

IF p_col='id_modalidad' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_jornada' THEN

IF p_col='id_jornada' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_area_conocimiento' THEN

IF p_col='id_area' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_tipo_beca' THEN

IF p_col='id_tipo_beca' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_nivel' THEN

IF p_col='id_nivel' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='orden' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='cat_grado' THEN

IF p_col='id_grado' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_nivel' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='orden' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='es_ultimo_grado' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='mae_institucion' THEN

IF p_col='id_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo_institucion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='id_tipo_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_departamento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_zona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='permite_becas' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='direccion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='telefono' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='email' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=254;v_pk:=0;

ELSIF p_col='fecha_creacion' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='mae_persona' THEN

IF p_col='id_persona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_tipo_documento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='numero_documento' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='primer_nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=100;v_pk:=0;

ELSIF p_col='segundo_nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=100;v_pk:=0;

ELSIF p_col='primer_apellido' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=100;v_pk:=0;

ELSIF p_col='segundo_apellido' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=100;v_pk:=0;

ELSIF p_col='fecha_nacimiento' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='sexo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='email' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=254;v_pk:=0;

ELSIF p_col='telefono' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='direccion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='mae_estudiante' THEN

IF p_col='id_estudiante' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_persona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='nie' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='mae_docente' THEN

IF p_col='id_docente' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_persona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='especialidad' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=250;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='mae_asignatura' THEN

IF p_col='id_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='id_area' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='descripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='activo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='est_ciclo' THEN

IF p_col='id_ciclo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='anio' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=4;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_inicio' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='est_periodo_academico' THEN

IF p_col='id_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_ciclo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='numero' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='fecha_inicio' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='est_institucion_ciclo' THEN

IF p_col='id_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_ciclo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_tipo_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_departamento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_zona' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='permite_becas' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=1;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_corte_matricula' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='est_curso' THEN

IF p_col='id_curso' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_ciclo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_grado' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_jornada' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_modalidad' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='codigo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=50;v_pk:=0;

ELSIF p_col='nombre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=150;v_pk:=0;

ELSIF p_col='seccion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=20;v_pk:=0;

ELSIF p_col='capacidad_maxima' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='est_curso_asignatura' THEN

IF p_col='id_curso_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_curso' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='horas_semanales' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=8;v_scale:=4;v_largo:=NULL;v_pk:=0;

ELSIF p_col='creditos' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=8;v_scale:=4;v_largo:=NULL;v_pk:=0;

ELSIF p_col='tipo_resultado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='regla_recuperacion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='est_ponderacion_periodo' THEN

IF p_col='id_ponderacion_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_curso_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='peso' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='est_plazo_registro_notas' THEN

IF p_col='id_plazo_registro_notas' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_institucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_ciclo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_grado' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='tipo_intento' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='fecha_inicio_recuperacion' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin_recuperacion' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_apertura_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_limite_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_cierre_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='trx_asignacion_docente' THEN

IF p_col='id_asignacion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_docente' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_curso_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_asignacion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_inicio' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='trx_inscripcion' THEN

IF p_col='id_inscripcion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_estudiante' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_curso' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_inscripcion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_inicio' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='motivo_fin_inscripcion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

ELSIF p_col='resultado_cierre' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

END IF;

ELSIF tabla='trx_calificacion' THEN

IF p_col='id_calificacion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_inscripcion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_ponderacion_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='tipo_intento' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='numero_intento' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='version' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_calificacion_ordinaria' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_calificacion_sustituida' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_asignacion_docente' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_docente_registra' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='nota' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=7;v_scale:=4;v_largo:=NULL;v_pk:=0;

ELSIF p_col='resultado_cualitativo' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=100;v_pk:=0;

ELSIF p_col='fecha_evaluacion' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_validacion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_anulacion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='motivo_anulacion' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=500;v_pk:=0;

END IF;

ELSIF tabla='trx_resultado_periodo' THEN

IF p_col='id_resultado' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_estudiante' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_asignatura' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_calificacion_seleccionada' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='version' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='criterio' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='fecha_seleccion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_cierre' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='trx_sesion_clase' THEN

IF p_col='id_sesion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_ponderacion_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_asignacion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_academica' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='inicio' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fin' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='observaciones' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=1000;v_pk:=0;

END IF;

ELSIF tabla='trx_asistencia' THEN

IF p_col='id_asistencia' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_inscripcion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_sesion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='hora_llegada' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='observaciones' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=1000;v_pk:=0;

END IF;

ELSIF tabla='trx_beca' THEN

IF p_col='id_beca' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_inscripcion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_tipo_beca' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='porcentaje' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=7;v_scale:=4;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_otorgamiento' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='observaciones' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=1000;v_pk:=0;

END IF;

ELSIF tabla='trx_beca_vigencia' THEN

IF p_col='id_vigencia' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_beca' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_inicio' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_fin' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='motivo_fin' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='fecha_registro' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

END IF;

ELSIF tabla='trx_control_carga' THEN

IF p_col='id_control' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=1;

ELSIF p_col='id_curso' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_periodo' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='dominio' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='fecha_corte' THEN v_known:=1;v_tipo:='DATE';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='estado' THEN v_known:=1;v_tipo:='VARCHAR2';v_prec:=NULL;v_scale:=NULL;v_largo:=30;v_pk:=0;

ELSIF p_col='registros_declarados' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

ELSIF p_col='fecha_recepcion' THEN v_known:=1;v_tipo:='TIMESTAMP';v_prec:=NULL;v_scale:=NULL;v_largo:=NULL;v_pk:=0;

ELSIF p_col='id_ejecucion' THEN v_known:=1;v_tipo:='NUMBER';v_prec:=10;v_scale:=0;v_largo:=NULL;v_pk:=0;

END IF;

END IF;
 END;
 -- JSON_OBJECT_T.has lanza ORA-40565 con on_error(1) en 21c si la clave falta: buscar en la lista de claves.
 FUNCTION tiene(p_clave VARCHAR2) RETURN BOOLEAN IS BEGIN
  FOR k IN 1..ks.COUNT LOOP IF ks(k)=p_clave THEN RETURN TRUE; END IF; END LOOP; RETURN FALSE;
 END;
BEGIN
 SAVEPOINT sv_guardar;
 pr_bloquear_validaciones;
 IF accion IS NULL OR accion NOT IN ('INSERT','UPDATE') THEN RAISE_APPLICATION_ERROR(-20804,'Accion invalida.'); END IF;
 SELECT COUNT(*) INTO v_known FROM dual WHERE p_datos IS JSON STRICT WITH UNIQUE KEYS;
 IF v_known<>1 THEN RAISE_APPLICATION_ERROR(-20804,'JSON invalido o claves repetidas.'); END IF;
 pr_validar_json_numeros(p_datos);
 j:=JSON_OBJECT_T.parse(p_datos); j.on_error(1);ks:=j.get_keys;
 IF p_historico IS NULL OR p_historico NOT IN (0,1) THEN RAISE_APPLICATION_ERROR(-20804,'Modo historico invalido.');END IF;
 IF p_historico=1 AND SYS_CONTEXT('USERENV','SESSION_USER')<>SYS_CONTEXT('USERENV','CURRENT_USER') THEN
  RAISE_APPLICATION_ERROR(-20804,'Importacion historica reservada al propietario.');END IF;
 IF tabla IN ('trx_resultado_periodo','trx_control_carga') THEN RAISE_APPLICATION_ERROR(-20804,'Usar procedimiento especializado para resultados/cobertura.'); END IF;
 IF tabla='trx_calificacion' THEN
  IF accion='UPDATE' THEN RAISE_APPLICATION_ERROR(-20804,'Validar/anular con procedimiento especializado.');END IF;
  IF tiene('fecha_validacion') THEN e:=j.get('fecha_validacion');IF NOT e.is_null THEN RAISE_APPLICATION_ERROR(-20804,'Registrar sin validar; usar PR_VALIDAR_CALIFICACION.');END IF;END IF;
  IF tiene('fecha_anulacion') THEN e:=j.get('fecha_anulacion');IF NOT e.is_null THEN RAISE_APPLICATION_ERROR(-20804,'Registrar sin anular; usar PR_ANULAR_CALIFICACION.');END IF;END IF;
 END IF;
 IF tabla IN ('est_ciclo','est_institucion_ciclo') AND tiene('estado') THEN
  IF j.get_string('estado')='CERRADO' THEN RAISE_APPLICATION_ERROR(-20804,'Cerrar mediante PR_CERRAR_CICLO.');END IF;
 END IF;
 IF ks.COUNT=0 THEN RAISE_APPLICATION_ERROR(-20804,'Objeto vacio.'); END IF;
 FOR i IN 1..ks.COUNT LOOP
  meta(ks(i));
  IF v_known<>1 THEN RAISE_APPLICATION_ERROR(-20804,'Tabla/campo no autorizado: '||tabla||'.'||ks(i)); END IF;
  IF v_pk=1 AND accion='UPDATE' THEN
   v_where:=v_where||CASE WHEN v_where IS NULL THEN '' ELSE ' AND ' END||ks(i)||'=:b'||i;
  ELSE
   v_cols:=v_cols||CASE WHEN v_cols IS NULL THEN '' ELSE ',' END||ks(i)||CASE WHEN accion='UPDATE' THEN '=:b'||i END;
   v_vals:=v_vals||CASE WHEN v_vals IS NULL THEN '' ELSE ',' END||':b'||i;
  END IF;
 END LOOP;
 -- Todas las claves de UPDATE son obligatorias; no se permite una actualizacion masiva accidental.

IF tabla='cat_tipo_documento' THEN IF accion='UPDATE' AND (NOT tiene('id_tipo_documento')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_tipo_institucion' THEN IF accion='UPDATE' AND (NOT tiene('id_tipo_institucion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_departamento' THEN IF accion='UPDATE' AND (NOT tiene('id_departamento')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_zona' THEN IF accion='UPDATE' AND (NOT tiene('id_zona')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_modalidad' THEN IF accion='UPDATE' AND (NOT tiene('id_modalidad')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_jornada' THEN IF accion='UPDATE' AND (NOT tiene('id_jornada')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_area_conocimiento' THEN IF accion='UPDATE' AND (NOT tiene('id_area')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_tipo_beca' THEN IF accion='UPDATE' AND (NOT tiene('id_tipo_beca')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_nivel' THEN IF accion='UPDATE' AND (NOT tiene('id_nivel')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='cat_grado' THEN IF accion='UPDATE' AND (NOT tiene('id_grado')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='mae_institucion' THEN IF accion='UPDATE' AND (NOT tiene('id_institucion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='mae_persona' THEN IF accion='UPDATE' AND (NOT tiene('id_persona')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='mae_estudiante' THEN IF accion='UPDATE' AND (NOT tiene('id_estudiante')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='mae_docente' THEN IF accion='UPDATE' AND (NOT tiene('id_docente')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='mae_asignatura' THEN IF accion='UPDATE' AND (NOT tiene('id_asignatura')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_ciclo' THEN IF accion='UPDATE' AND (NOT tiene('id_ciclo')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_periodo_academico' THEN IF accion='UPDATE' AND (NOT tiene('id_periodo')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_institucion_ciclo' THEN IF accion='UPDATE' AND (NOT tiene('id_institucion') OR NOT tiene('id_ciclo')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_curso' THEN IF accion='UPDATE' AND (NOT tiene('id_curso')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_curso_asignatura' THEN IF accion='UPDATE' AND (NOT tiene('id_curso_asignatura')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_ponderacion_periodo' THEN IF accion='UPDATE' AND (NOT tiene('id_ponderacion_periodo')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='est_plazo_registro_notas' THEN IF accion='UPDATE' AND (NOT tiene('id_plazo_registro_notas')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_asignacion_docente' THEN IF accion='UPDATE' AND (NOT tiene('id_asignacion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_inscripcion' THEN IF accion='UPDATE' AND (NOT tiene('id_inscripcion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_calificacion' THEN IF accion='UPDATE' AND (NOT tiene('id_calificacion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_resultado_periodo' THEN IF accion='UPDATE' AND (NOT tiene('id_resultado')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_sesion_clase' THEN IF accion='UPDATE' AND (NOT tiene('id_sesion')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_asistencia' THEN IF accion='UPDATE' AND (NOT tiene('id_asistencia')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_beca' THEN IF accion='UPDATE' AND (NOT tiene('id_beca')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_beca_vigencia' THEN IF accion='UPDATE' AND (NOT tiene('id_vigencia')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

ELSIF tabla='trx_control_carga' THEN IF accion='UPDATE' AND (NOT tiene('id_control')) THEN RAISE_APPLICATION_ERROR(-20804,'Falta clave de actualizacion.'); END IF;

END IF;

IF p_historico=0 THEN

IF tabla='mae_institucion' THEN
IF tiene('id_tipo_institucion') THEN e:=j.get('id_tipo_institucion');IF NOT e.is_null THEN v_num:=j.get_number('id_tipo_institucion');SELECT COUNT(*) INTO v_known FROM cat_tipo_institucion WHERE id_tipo_institucion=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_tipo_institucion');END IF;END IF;END IF;
IF tiene('id_departamento') THEN e:=j.get('id_departamento');IF NOT e.is_null THEN v_num:=j.get_number('id_departamento');SELECT COUNT(*) INTO v_known FROM cat_departamento WHERE id_departamento=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_departamento');END IF;END IF;END IF;
IF tiene('id_zona') THEN e:=j.get('id_zona');IF NOT e.is_null THEN v_num:=j.get_number('id_zona');SELECT COUNT(*) INTO v_known FROM cat_zona WHERE id_zona=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_zona');END IF;END IF;END IF;
END IF;

IF tabla='mae_persona' THEN
IF tiene('id_tipo_documento') THEN e:=j.get('id_tipo_documento');IF NOT e.is_null THEN v_num:=j.get_number('id_tipo_documento');SELECT COUNT(*) INTO v_known FROM cat_tipo_documento WHERE id_tipo_documento=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_tipo_documento');END IF;END IF;END IF;
END IF;

IF tabla='mae_asignatura' THEN
IF tiene('id_area') THEN e:=j.get('id_area');IF NOT e.is_null THEN v_num:=j.get_number('id_area');SELECT COUNT(*) INTO v_known FROM cat_area_conocimiento WHERE id_area=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_area_conocimiento');END IF;END IF;END IF;
END IF;

IF tabla='est_institucion_ciclo' THEN
IF tiene('id_institucion') THEN e:=j.get('id_institucion');IF NOT e.is_null THEN v_num:=j.get_number('id_institucion');SELECT COUNT(*) INTO v_known FROM mae_institucion WHERE id_institucion=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_institucion');END IF;END IF;END IF;
IF tiene('id_tipo_institucion') THEN e:=j.get('id_tipo_institucion');IF NOT e.is_null THEN v_num:=j.get_number('id_tipo_institucion');SELECT COUNT(*) INTO v_known FROM cat_tipo_institucion WHERE id_tipo_institucion=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_tipo_institucion');END IF;END IF;END IF;
IF tiene('id_departamento') THEN e:=j.get('id_departamento');IF NOT e.is_null THEN v_num:=j.get_number('id_departamento');SELECT COUNT(*) INTO v_known FROM cat_departamento WHERE id_departamento=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_departamento');END IF;END IF;END IF;
IF tiene('id_zona') THEN e:=j.get('id_zona');IF NOT e.is_null THEN v_num:=j.get_number('id_zona');SELECT COUNT(*) INTO v_known FROM cat_zona WHERE id_zona=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_zona');END IF;END IF;END IF;
END IF;

IF tabla='est_curso' THEN
IF tiene('id_institucion') THEN e:=j.get('id_institucion');IF NOT e.is_null THEN v_num:=j.get_number('id_institucion');SELECT COUNT(*) INTO v_known FROM mae_institucion WHERE id_institucion=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_institucion');END IF;END IF;END IF;
IF tiene('id_jornada') THEN e:=j.get('id_jornada');IF NOT e.is_null THEN v_num:=j.get_number('id_jornada');SELECT COUNT(*) INTO v_known FROM cat_jornada WHERE id_jornada=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_jornada');END IF;END IF;END IF;
IF tiene('id_modalidad') THEN e:=j.get('id_modalidad');IF NOT e.is_null THEN v_num:=j.get_number('id_modalidad');SELECT COUNT(*) INTO v_known FROM cat_modalidad WHERE id_modalidad=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_modalidad');END IF;END IF;END IF;
END IF;

IF tabla='est_curso_asignatura' THEN
IF tiene('id_asignatura') THEN e:=j.get('id_asignatura');IF NOT e.is_null THEN v_num:=j.get_number('id_asignatura');SELECT COUNT(*) INTO v_known FROM mae_asignatura WHERE id_asignatura=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_asignatura');END IF;END IF;END IF;
END IF;

IF tabla='est_plazo_registro_notas' THEN
IF tiene('id_institucion') THEN e:=j.get('id_institucion');IF NOT e.is_null THEN v_num:=j.get_number('id_institucion');SELECT COUNT(*) INTO v_known FROM mae_institucion WHERE id_institucion=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_institucion');END IF;END IF;END IF;
END IF;

IF tabla='trx_asignacion_docente' THEN
IF tiene('id_docente') THEN e:=j.get('id_docente');IF NOT e.is_null THEN v_num:=j.get_number('id_docente');SELECT COUNT(*) INTO v_known FROM mae_docente WHERE id_docente=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_docente');END IF;END IF;END IF;
END IF;

IF tabla='trx_inscripcion' THEN
IF tiene('id_estudiante') THEN e:=j.get('id_estudiante');IF NOT e.is_null THEN v_num:=j.get_number('id_estudiante');SELECT COUNT(*) INTO v_known FROM mae_estudiante WHERE id_estudiante=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_estudiante');END IF;END IF;END IF;
END IF;

IF tabla='trx_calificacion' THEN
IF tiene('id_docente_registra') THEN e:=j.get('id_docente_registra');IF NOT e.is_null THEN v_num:=j.get_number('id_docente_registra');SELECT COUNT(*) INTO v_known FROM mae_docente WHERE id_docente=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_docente');END IF;END IF;END IF;
END IF;

IF tabla='trx_resultado_periodo' THEN
IF tiene('id_estudiante') THEN e:=j.get('id_estudiante');IF NOT e.is_null THEN v_num:=j.get_number('id_estudiante');SELECT COUNT(*) INTO v_known FROM mae_estudiante WHERE id_estudiante=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_estudiante');END IF;END IF;END IF;
IF tiene('id_asignatura') THEN e:=j.get('id_asignatura');IF NOT e.is_null THEN v_num:=j.get_number('id_asignatura');SELECT COUNT(*) INTO v_known FROM mae_asignatura WHERE id_asignatura=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: mae_asignatura');END IF;END IF;END IF;
END IF;

IF tabla='trx_beca' THEN
IF tiene('id_tipo_beca') THEN e:=j.get('id_tipo_beca');IF NOT e.is_null THEN v_num:=j.get_number('id_tipo_beca');SELECT COUNT(*) INTO v_known FROM cat_tipo_beca WHERE id_tipo_beca=v_num AND activo=0;IF v_known>0 THEN RAISE_APPLICATION_ERROR(-20804,'Referencia inactiva: cat_tipo_beca');END IF;END IF;END IF;
END IF;

END IF;

IF v_cols IS NULL THEN RAISE_APPLICATION_ERROR(-20804,'No hay campos modificables.'); END IF;
 IF accion='INSERT' THEN v_sql:='INSERT INTO '||tabla||' ('||v_cols||') VALUES ('||v_vals||')';
 ELSE v_sql:='UPDATE '||tabla||' SET '||v_cols||' WHERE '||v_where; END IF;
 v_cur:=DBMS_SQL.OPEN_CURSOR;
 DBMS_SQL.PARSE(v_cur,v_sql,DBMS_SQL.NATIVE);
 FOR i IN 1..ks.COUNT LOOP
  meta(ks(i));e:=j.get(ks(i));
  IF v_tipo='NUMBER' THEN
   IF e.is_null THEN v_num:=NULL;
   ELSIF NOT e.is_number THEN RAISE_APPLICATION_ERROR(-20803,'Se requiere numero JSON: '||ks(i));
   ELSE v_num:=j.get_number(ks(i));
    IF v_prec IS NOT NULL THEN v_num:=fn_validar_numero(v_num,v_prec,v_scale); END IF;
   END IF;
   DBMS_SQL.BIND_VARIABLE(v_cur,':b'||i,v_num);
  ELSIF v_tipo IN ('VARCHAR2','CLOB') THEN
   IF e.is_null THEN v_txt:=NULL;
   ELSIF NOT e.is_string THEN RAISE_APPLICATION_ERROR(-20804,'Se requiere texto: '||ks(i));
   ELSE v_txt:=fn_limpiar_texto(j.get_string(ks(i))); END IF;
   IF v_largo IS NOT NULL AND LENGTH(v_txt)>v_largo THEN RAISE_APPLICATION_ERROR(-20804,'Texto demasiado largo: '||ks(i)); END IF;
   DBMS_SQL.BIND_VARIABLE(v_cur,':b'||i,v_txt);
  ELSIF v_tipo='DATE' THEN
   IF e.is_null THEN v_date:=NULL; ELSE
    v_txt:=j.get_string(ks(i));
    IF LENGTH(v_txt)<>10 THEN RAISE_APPLICATION_ERROR(-20804,'Fecha requiere YYYY-MM-DD.'); END IF;
    v_date:=TO_DATE(v_txt,'FXYYYY-MM-DD');
   END IF; DBMS_SQL.BIND_VARIABLE(v_cur,':b'||i,v_date);
  ELSIF v_tipo='TIMESTAMP' THEN
   IF e.is_null THEN v_ts:=NULL; ELSE
    v_txt:=j.get_string(ks(i));
    IF NOT REGEXP_LIKE(v_txt,'^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]{1,6})?$') THEN
     RAISE_APPLICATION_ERROR(-20804,'Timestamp requiere YYYY-MM-DD HH24:MI:SS[.ffffff].'); END IF;
    IF LENGTH(v_txt)=19 THEN v_ts:=TO_TIMESTAMP(v_txt,'FXYYYY-MM-DD HH24:MI:SS');
    ELSE v_ts:=TO_TIMESTAMP(v_txt,'FXYYYY-MM-DD HH24:MI:SS.FF6'); END IF;
   END IF; DBMS_SQL.BIND_VARIABLE(v_cur,':b'||i,v_ts);
  END IF;
 END LOOP;
 v_ret:=DBMS_SQL.EXECUTE(v_cur);DBMS_SQL.CLOSE_CURSOR(v_cur);v_cur:=NULL;
 IF v_ret<>1 THEN RAISE_APPLICATION_ERROR(-20804,'La operacion debe afectar exactamente una fila.'); END IF;
EXCEPTION WHEN OTHERS THEN
 IF v_cur IS NOT NULL THEN IF DBMS_SQL.IS_OPEN(v_cur) THEN DBMS_SQL.CLOSE_CURSOR(v_cur); END IF; END IF;
 ROLLBACK TO sv_guardar; RAISE;
END;
/

-- === PR_PUBLICAR_PLAN ===
CREATE OR REPLACE PROCEDURE pr_publicar_plan(p_oferta NUMBER) AUTHID DEFINER IS n NUMBER;e NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_PUBLICAR_PLAN
  -- Publica el plan de una materia solo si tiene un peso por cada período del ciclo.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_publicar;pr_bloquear_validaciones;
 SELECT COUNT(*) INTO n FROM est_ponderacion_periodo WHERE id_curso_asignatura=p_oferta AND estado<>'ANULADO';
 SELECT COUNT(*) INTO e FROM est_periodo_academico p JOIN est_curso c ON c.id_ciclo=p.id_ciclo
 JOIN est_curso_asignatura o ON o.id_curso=c.id_curso WHERE o.id_curso_asignatura=p_oferta;
 IF e=0 OR n<>e THEN RAISE_APPLICATION_ERROR(-20810,'Plan incompleto respecto de los periodos configurados.'); END IF;
 UPDATE est_ponderacion_periodo SET estado='PUBLICADO' WHERE id_curso_asignatura=p_oferta AND estado='BORRADOR';
 pr_validar_operacion('OPERACION','EST_PONDERACION_PERIODO');
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_publicar;RAISE;
END;
/

-- === PR_TRASLADAR_ESTUDIANTE ===
CREATE OR REPLACE PROCEDURE pr_trasladar_estudiante(p_origen NUMBER,p_nueva_inscripcion NUMBER,
 p_curso_destino NUMBER,p_inicio DATE,p_motivo VARCHAR2) AUTHID DEFINER IS e NUMBER;cy NUMBER;dy NUMBER;n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_TRASLADAR_ESTUDIANTE
  -- Cierra la inscripción de origen y abre la de destino en el mismo ciclo. No deja notas
  -- ordinarias posteriores a la salida.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_trasladar;pr_bloquear_validaciones;
 IF p_inicio IS NULL OR p_inicio<>TRUNC(p_inicio) OR TRIM(p_motivo) IS NULL THEN
  RAISE_APPLICATION_ERROR(-20811,'Traslado requiere dia de inicio y motivo.');END IF;
 SELECT i.id_estudiante,c.id_ciclo INTO e,cy FROM trx_inscripcion i JOIN est_curso c ON c.id_curso=i.id_curso
 WHERE i.id_inscripcion=p_origen AND i.estado='VIGENTE' AND i.fecha_inicio<p_inicio;
 SELECT id_ciclo INTO dy FROM est_curso WHERE id_curso=p_curso_destino AND estado='ACTIVO';
 IF cy<>dy THEN RAISE_APPLICATION_ERROR(-20811,'Traslado entre grupos del mismo ciclo; otro ciclo es nueva matricula.'); END IF;
 -- No trasladar una fecha antes de hechos academicos ya realizados en origen.
 SELECT COUNT(*) INTO n FROM trx_calificacion WHERE id_inscripcion=p_origen
 AND tipo_intento='ORDINARIA' AND fecha_evaluacion>=p_inicio;
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20811,'Hay notas ordinarias posteriores a la salida.'); END IF;
 SELECT COUNT(*) INTO n FROM trx_beca_vigencia v JOIN trx_beca b ON b.id_beca=v.id_beca
 WHERE b.id_inscripcion=p_origen AND v.fecha_inicio>=p_inicio;
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20811,'Revisar beneficios programados antes de trasladar.'); END IF;
 UPDATE trx_beca_vigencia SET fecha_fin=p_inicio-1,motivo_fin='TRASLADO'
 WHERE id_beca IN (SELECT id_beca FROM trx_beca WHERE id_inscripcion=p_origen)
 AND fecha_inicio<p_inicio AND (fecha_fin IS NULL OR fecha_fin>=p_inicio);
 UPDATE trx_inscripcion SET fecha_fin=p_inicio-1,estado='TRASLADADA',motivo_fin_inscripcion=TRIM(p_motivo)
 WHERE id_inscripcion=p_origen;
 INSERT INTO trx_inscripcion(id_inscripcion,id_estudiante,id_curso,fecha_inscripcion,fecha_inicio,estado)
 VALUES(fn_validar_numero(p_nueva_inscripcion,10,0),e,p_curso_destino,LOCALTIMESTAMP,p_inicio,'VIGENTE');
 -- La beca de destino requiere concesion explicita: no se copia automaticamente.
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_trasladar;RAISE;
END;
/

-- === FN_ELEGIR_CALIFICACION ===
CREATE OR REPLACE FUNCTION fn_elegir_calificacion(p_estudiante NUMBER,p_asignatura NUMBER,
 p_periodo NUMBER,p_corte TIMESTAMP) RETURN NUMBER AUTHID DEFINER IS v_id NUMBER;v_cualitativas NUMBER;
  -- ----------------------------------------------------------------------
  -- FN_ELEGIR_CALIFICACION
  -- Propone la calificación que cuenta en el período a una fecha de corte, según la regla de
  -- la materia (MEJOR_NOTA o ULTIMA_RECUPERACION). Usa la última versión validada de cada
  -- intento y no revive versiones anuladas.
  -- ----------------------------------------------------------------------
BEGIN
 IF p_corte IS NULL THEN RAISE_APPLICATION_ERROR(-20812,'Se requiere corte explicito.');END IF;
 SELECT COUNT(*) INTO v_cualitativas FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion
 JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura
 WHERE i.id_estudiante=p_estudiante AND o.id_asignatura=p_asignatura AND p.id_periodo=p_periodo
 AND o.tipo_resultado='CUALITATIVA' AND o.regla_recuperacion='MEJOR_NOTA'
 AND n.fecha_validacion<=p_corte AND (n.fecha_anulacion IS NULL OR n.fecha_anulacion>p_corte)
 AND NOT EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=n.id_inscripcion
 AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.numero_intento=n.numero_intento
 AND v.tipo_intento=n.tipo_intento AND v.version>n.version AND v.fecha_validacion<=p_corte);
 IF v_cualitativas>1 THEN RAISE_APPLICATION_ERROR(-20812,'MEJOR_NOTA cualitativa requiere una politica de orden explicita; no se inventa equivalencia numerica.');END IF;
 SELECT id_calificacion INTO v_id FROM (
 SELECT n.id_calificacion,
 ROW_NUMBER() OVER(ORDER BY
  CASE WHEN o.regla_recuperacion='MEJOR_NOTA' AND o.tipo_resultado='NUMERICA' THEN n.nota END DESC NULLS LAST,
  CASE WHEN o.regla_recuperacion='ULTIMA_RECUPERACION' THEN n.numero_intento END DESC NULLS LAST,
  n.numero_intento ASC,n.version DESC,n.fecha_validacion DESC,n.id_calificacion) rn
 FROM trx_calificacion n JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion
 JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura
 WHERE i.id_estudiante=p_estudiante AND o.id_asignatura=p_asignatura AND p.id_periodo=p_periodo
 AND n.fecha_validacion<=p_corte AND (n.fecha_anulacion IS NULL OR n.fecha_anulacion>p_corte)
 AND NOT EXISTS (SELECT 1 FROM trx_calificacion v WHERE v.id_inscripcion=n.id_inscripcion
  AND v.id_ponderacion_periodo=n.id_ponderacion_periodo AND v.numero_intento=n.numero_intento
  AND v.tipo_intento=n.tipo_intento AND v.version>n.version AND v.fecha_validacion<=p_corte)
 ) WHERE rn=1;
 RETURN v_id;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/

-- === PR_SELECCIONAR_RESULTADO ===
CREATE OR REPLACE PROCEDURE pr_seleccionar_resultado(p_estudiante NUMBER,p_asignatura NUMBER,
 p_periodo NUMBER,p_id_resultado NUMBER,p_corte TIMESTAMP,p_motivo VARCHAR2 DEFAULT NULL)
 AUTHID DEFINER IS n NUMBER;v NUMBER;cerrado NUMBER;criterio VARCHAR2(30);tipo VARCHAR2(30);regla VARCHAR2(30);
  -- ----------------------------------------------------------------------
  -- PR_SELECCIONAR_RESULTADO
  -- Crea una nueva versión de la selección del período con fn_elegir_calificacion. Un
  -- resultado cerrado exige motivo.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_seleccionar;pr_bloquear_validaciones;
 SELECT COUNT(*) INTO cerrado FROM trx_resultado_periodo r WHERE r.id_estudiante=p_estudiante
 AND r.id_asignatura=p_asignatura AND r.id_periodo=p_periodo AND r.fecha_cierre IS NOT NULL
 AND r.version=(SELECT MAX(q.version) FROM trx_resultado_periodo q WHERE q.id_estudiante=r.id_estudiante
 AND q.id_asignatura=r.id_asignatura AND q.id_periodo=r.id_periodo);
 IF cerrado>0 AND TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20812,'Resultado cerrado: reapertura requiere motivo.');END IF;
 n:=fn_elegir_calificacion(p_estudiante,p_asignatura,p_periodo,p_corte);
 IF n IS NULL THEN RETURN; END IF; -- No se inserta una nota ficticia; consulta de pendiente resuelve ausencia.
 SELECT COALESCE(MAX(version),0)+1 INTO v FROM trx_resultado_periodo
 WHERE id_estudiante=p_estudiante AND id_asignatura=p_asignatura AND id_periodo=p_periodo;
 SELECT n.tipo_intento,o.regla_recuperacion INTO tipo,regla FROM trx_calificacion n
 JOIN est_ponderacion_periodo p ON p.id_ponderacion_periodo=n.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=p.id_curso_asignatura WHERE n.id_calificacion=pr_seleccionar_resultado.n;
 criterio:=CASE WHEN tipo='ORDINARIA' THEN 'ORDINARIA' ELSE regla END;
 INSERT INTO trx_resultado_periodo(id_resultado,id_estudiante,id_asignatura,id_periodo,
 id_calificacion_seleccionada,version,criterio,fecha_seleccion)
 VALUES(fn_validar_numero(p_id_resultado,10,0),p_estudiante,p_asignatura,p_periodo,n,v,criterio,p_corte);
 IF p_motivo IS NOT NULL THEN
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('trx_resultado_periodo',TO_CHAR(p_id_resultado),'REAPERTURA',SYS_CONTEXT('USERENV','SESSION_USER'),
 LOCALTIMESTAMP,fn_id_transaccion(),p_motivo);END IF;
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_seleccionar;RAISE;
END;
/

-- === PR_VALIDAR_CALIFICACION ===
CREATE OR REPLACE PROCEDURE pr_validar_calificacion(p_calificacion NUMBER,p_id_resultado NUMBER,
 p_fecha TIMESTAMP,p_motivo VARCHAR2 DEFAULT NULL) AUTHID DEFINER IS e NUMBER;a NUMBER;p NUMBER;f TIMESTAMP;
  -- ----------------------------------------------------------------------
  -- PR_VALIDAR_CALIFICACION
  -- Registra la fecha de validación de una nota y actualiza la selección en la misma
  -- transacción.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_validar_nota;pr_bloquear_validaciones;
 IF p_fecha IS NULL THEN RAISE_APPLICATION_ERROR(-20813,'Fecha de validacion obligatoria.');END IF;
 SELECT i.id_estudiante,o.id_asignatura,w.id_periodo INTO e,a,p FROM trx_calificacion n
 JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo w ON w.id_ponderacion_periodo=n.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=w.id_curso_asignatura
 WHERE n.id_calificacion=p_calificacion AND n.fecha_validacion IS NULL AND n.fecha_anulacion IS NULL;
 UPDATE trx_calificacion SET fecha_validacion=p_fecha WHERE id_calificacion=p_calificacion;
 pr_seleccionar_resultado(e,a,p,p_id_resultado,p_fecha,p_motivo);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_validar_nota;RAISE;
END;
/

-- === PR_ANULAR_CALIFICACION ===
CREATE OR REPLACE PROCEDURE pr_anular_calificacion(p_calificacion NUMBER,p_id_resultado NUMBER,
 p_fecha TIMESTAMP,p_motivo VARCHAR2) AUTHID DEFINER IS e NUMBER;a NUMBER;p NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_ANULAR_CALIFICACION
  -- Anula una nota con fecha y motivo y actualiza la selección. No revive versiones
  -- anteriores.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_anular_nota;pr_bloquear_validaciones;
 IF p_fecha IS NULL OR TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20813,'Anulacion requiere fecha y motivo.');END IF;
 SELECT i.id_estudiante,o.id_asignatura,w.id_periodo INTO e,a,p FROM trx_calificacion n
 JOIN trx_inscripcion i ON i.id_inscripcion=n.id_inscripcion JOIN est_ponderacion_periodo w ON w.id_ponderacion_periodo=n.id_ponderacion_periodo
 JOIN est_curso_asignatura o ON o.id_curso_asignatura=w.id_curso_asignatura WHERE n.id_calificacion=p_calificacion AND n.fecha_anulacion IS NULL;
 UPDATE trx_calificacion SET fecha_anulacion=p_fecha,motivo_anulacion=TRIM(p_motivo) WHERE id_calificacion=p_calificacion;
 pr_seleccionar_resultado(e,a,p,p_id_resultado,p_fecha,p_motivo);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_anular_nota;RAISE;
END;
/

-- === PR_SUSPENDER_BECA ===
CREATE OR REPLACE PROCEDURE pr_suspender_beca(p_beca NUMBER,p_fin DATE,p_motivo VARCHAR2 DEFAULT 'SUSPENSION')
 AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_SUSPENDER_BECA
  -- Cierra el intervalo de vigencia abierto de una beca, con fecha y motivo.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_suspender;pr_bloquear_validaciones;
 IF p_fin IS NULL OR p_fin<>TRUNC(p_fin) OR p_motivo NOT IN ('SUSPENSION','FIN_VIGENCIA','CANCELACION','TRASLADO') THEN
 RAISE_APPLICATION_ERROR(-20814,'Fin y motivo de beca invalidos.');END IF;
 UPDATE trx_beca_vigencia SET fecha_fin=p_fin,motivo_fin=p_motivo
 WHERE id_beca=p_beca AND fecha_fin IS NULL;
 IF SQL%ROWCOUNT<>1 THEN RAISE_APPLICATION_ERROR(-20814,'Se requiere un intervalo abierto.');END IF;
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_suspender;RAISE;
END;
/

-- === PR_REANUDAR_BECA ===
CREATE OR REPLACE PROCEDURE pr_reanudar_beca(p_beca NUMBER,p_id_vigencia NUMBER,p_inicio DATE)
 AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_REANUDAR_BECA
  -- Abre un nuevo intervalo de vigencia de una beca suspendida.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_reanudar;pr_bloquear_validaciones;
 INSERT INTO trx_beca_vigencia(id_vigencia,id_beca,fecha_inicio,fecha_registro)
 VALUES(fn_validar_numero(p_id_vigencia,10,0),p_beca,p_inicio,LOCALTIMESTAMP);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_reanudar;RAISE;
END;
/

-- === PR_RECIBIR_ENTRADA ===
CREATE OR REPLACE PROCEDURE pr_recibir_entrada(p_lote VARCHAR2,p_fila NUMBER,p_tabla VARCHAR2,
 p_origen VARCHAR2,p_original CLOB) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_RECIBIR_ENTRADA
  -- Guarda una fila de entrada tal como llegó en raw_entrada_datos, con estado RECIBIDA.
  -- ----------------------------------------------------------------------
BEGIN
 INSERT INTO raw_entrada_datos(lote,fila,entidad,origen,contenido_original,fecha)
 VALUES(TRIM(p_lote),fn_validar_numero(p_fila,10,0),LOWER(TRIM(p_tabla)),TRIM(p_origen),p_original,LOCALTIMESTAMP);
END;
/

-- === PR_PROCESAR_ENTRADA ===
CREATE OR REPLACE PROCEDURE pr_procesar_entrada(p_entrada NUMBER,p_accion VARCHAR2 DEFAULT 'INSERT')
 AUTHID DEFINER IS t VARCHAR2(128);j CLOB;err VARCHAR2(1000);
  -- ----------------------------------------------------------------------
  -- PR_PROCESAR_ENTRADA
  -- Intenta guardar una entrada RECIBIDA con pr_guardar_registro. Si pasa, queda ACEPTADA; si
  -- falla, queda RECHAZADA con el motivo.
  -- ----------------------------------------------------------------------
BEGIN
 SELECT entidad,contenido_original INTO t,j FROM raw_entrada_datos WHERE id_entrada=p_entrada AND estado='RECIBIDA' FOR UPDATE;
 BEGIN
  pr_guardar_registro(t,j,p_accion);
  UPDATE raw_entrada_datos SET estado='ACEPTADA',detalle=NULL WHERE id_entrada=p_entrada;
 EXCEPTION WHEN OTHERS THEN
  err:=SUBSTR(SQLERRM,1,1000);
  UPDATE raw_entrada_datos SET estado='RECHAZADA',detalle=err WHERE id_entrada=p_entrada;
  -- Rechazo explicito conservado en RAW. No publica esa fila ni oculta el diagnostico.
  DBMS_OUTPUT.PUT_LINE('RECHAZADA '||p_entrada||': '||err);
 END;
END;
/

-- === PR_REGISTRAR_CALIFICACION ===
CREATE OR REPLACE PROCEDURE pr_registrar_calificacion(p_datos CLOB,p_id_resultado NUMBER DEFAULT NULL,
 p_validacion TIMESTAMP DEFAULT NULL) AUTHID DEFINER IS j JSON_OBJECT_T;n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_REGISTRAR_CALIFICACION
  -- Inserta una calificación. Si trae fecha de validación, la valida y actualiza la selección
  -- en la misma transacción.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_registrar_nota;
 pr_guardar_registro('trx_calificacion',p_datos,'INSERT');
 IF p_validacion IS NOT NULL THEN
  IF p_id_resultado IS NULL THEN RAISE_APPLICATION_ERROR(-20813,'Falta ID del resultado seleccionado.');END IF;
  j:=JSON_OBJECT_T.parse(p_datos);n:=j.get_number('id_calificacion');
  pr_validar_calificacion(n,p_id_resultado,p_validacion);
 END IF;
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_registrar_nota;RAISE;
END;
/

-- === PR_CORREGIR_CALIFICACION ===
CREATE OR REPLACE PROCEDURE pr_corregir_calificacion(p_anterior NUMBER,p_nueva NUMBER,
 p_nota NUMBER,p_cualitativo VARCHAR2,p_id_resultado NUMBER,p_motivo VARCHAR2) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_CORREGIR_CALIFICACION
  -- Corrige una nota sin borrarla: exige motivo, agrega una versión nueva sobre la última del
  -- intento, la valida y actualiza la selección.
  -- ----------------------------------------------------------------------
 n trx_calificacion%ROWTYPE;j CLOB;t TIMESTAMP:=LOCALTIMESTAMP;v NUMBER;
BEGIN
 SAVEPOINT sv_corregir;pr_bloquear_validaciones;
 IF TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20813,'Correccion requiere motivo.');END IF;
 SELECT * INTO n FROM trx_calificacion WHERE id_calificacion=p_anterior;
 SELECT MAX(version) INTO v FROM trx_calificacion WHERE id_inscripcion=n.id_inscripcion
 AND id_ponderacion_periodo=n.id_ponderacion_periodo AND numero_intento=n.numero_intento AND tipo_intento=n.tipo_intento;
 IF n.version<>v THEN RAISE_APPLICATION_ERROR(-20813,'Corregir la ultima version del intento.');END IF;
 v:=fn_validar_numero(p_nota,7,4);
 SELECT JSON_OBJECT('id_calificacion' VALUE p_nueva,'id_inscripcion' VALUE n.id_inscripcion,
 'id_ponderacion_periodo' VALUE n.id_ponderacion_periodo,'tipo_intento' VALUE n.tipo_intento,
 'numero_intento' VALUE n.numero_intento,'version' VALUE n.version+1,
 'id_calificacion_ordinaria' VALUE n.id_calificacion_ordinaria,'id_calificacion_sustituida' VALUE n.id_calificacion,
 'id_asignacion_docente' VALUE n.id_asignacion_docente,'id_docente_registra' VALUE n.id_docente_registra,
 'nota' VALUE v,'resultado_cualitativo' VALUE p_cualitativo,
 'fecha_evaluacion' VALUE TO_CHAR(n.fecha_evaluacion,'YYYY-MM-DD'),
 'fecha_registro' VALUE TO_CHAR(t,'YYYY-MM-DD HH24:MI:SS.FF6') RETURNING CLOB) INTO j FROM dual;
 pr_guardar_registro('trx_calificacion',j,'INSERT');
 pr_validar_calificacion(p_nueva,p_id_resultado,t,p_motivo);
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('trx_calificacion',TO_CHAR(p_nueva),'CORRECCION',SYS_CONTEXT('USERENV','SESSION_USER'),t,
 fn_id_transaccion(),p_motivo);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_corregir;RAISE;
END;
/

-- === PR_OTORGAR_BECA ===
CREATE OR REPLACE PROCEDURE pr_otorgar_beca(p_datos CLOB,p_id_vigencia NUMBER,p_inicio DATE)
 AUTHID DEFINER IS j JSON_OBJECT_T;b NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_OTORGAR_BECA
  -- Registra una beca y abre su primer intervalo de vigencia.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_otorgar;
 pr_guardar_registro('trx_beca',p_datos,'INSERT');
 j:=JSON_OBJECT_T.parse(p_datos);b:=j.get_number('id_beca');
 pr_reanudar_beca(b,p_id_vigencia,p_inicio);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_otorgar;RAISE;
END;
/

-- === PR_REABRIR_CICLO ===
CREATE OR REPLACE PROCEDURE pr_reabrir_ciclo(p_ciclo NUMBER,p_motivo VARCHAR2) AUTHID DEFINER IS n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_REABRIR_CICLO
  -- Reabre un ciclo cerrado, con motivo auditado en val_cambio.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_reabrir;pr_bloquear_validaciones;
 IF TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20818,'Reapertura requiere motivo.');END IF;
 SELECT COUNT(*) INTO n FROM est_ciclo WHERE id_ciclo=p_ciclo AND estado='CERRADO';
 IF n<>1 THEN RAISE_APPLICATION_ERROR(-20818,'Ciclo no cerrado.');END IF;
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('est_ciclo',TO_CHAR(p_ciclo),'REAPERTURA',SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,
 fn_id_transaccion(),p_motivo);
 UPDATE est_ciclo SET estado='ABIERTO' WHERE id_ciclo=p_ciclo;
 UPDATE est_institucion_ciclo SET estado='ABIERTO' WHERE id_ciclo=p_ciclo AND estado='CERRADO';
 -- Selecciones cerradas conservan su historia. PR_SELECCIONAR_RESULTADO crea nueva version con motivo.
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_reabrir;RAISE;
END;
/

-- === PR_REABRIR_PLAZO ===
CREATE OR REPLACE PROCEDURE pr_reabrir_plazo(p_plazo NUMBER,p_motivo VARCHAR2) AUTHID DEFINER IS
  -- ----------------------------------------------------------------------
  -- PR_REABRIR_PLAZO
  -- Reabre un plazo de registro de notas cerrado, con motivo auditado en val_cambio.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_reabrir_plazo;pr_bloquear_validaciones;
 IF TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20818,'Reabrir plazo requiere motivo.');END IF;
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('est_plazo_registro_notas',TO_CHAR(p_plazo),'REAPERTURA',SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,
 fn_id_transaccion(),p_motivo);
 UPDATE est_plazo_registro_notas SET estado='ABIERTA',fecha_cierre_registro=NULL
 WHERE id_plazo_registro_notas=p_plazo AND estado='CERRADA';
 IF SQL%ROWCOUNT<>1 THEN RAISE_APPLICATION_ERROR(-20818,'Plazo no cerrado o inexistente.');END IF;
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_reabrir_plazo;RAISE;
END;
/

-- === PR_DECLARAR_COBERTURA ===
CREATE OR REPLACE PROCEDURE pr_declarar_cobertura(p_datos CLOB,p_justificacion VARCHAR2)
 AUTHID DEFINER IS j JSON_OBJECT_T;c NUMBER;p NUMBER;d VARCHAR2(30);e VARCHAR2(30);f DATE;n NUMBER;idn NUMBER;esperados NUMBER;declarados NUMBER;habilitada NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_DECLARAR_COBERTURA
  -- Declara si los datos de un curso, período y dominio llegaron completos o parciales. No
  -- permite declarar COMPLETA si faltan registros o configuración al corte.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_cobertura;pr_bloquear_validaciones;
 SELECT COUNT(*) INTO n FROM dual WHERE p_datos IS JSON STRICT WITH UNIQUE KEYS;
 IF n<>1 THEN RAISE_APPLICATION_ERROR(-20820,'JSON de cobertura invalido.');END IF;
 pr_validar_json_numeros(p_datos);j:=JSON_OBJECT_T.parse(p_datos);j.on_error(1);
 IF TRIM(p_justificacion) IS NULL THEN RAISE_APPLICATION_ERROR(-20820,'Se requiere evidencia/justificacion de la declaracion.');END IF;
 c:=fn_validar_numero(j.get_number('id_curso'),10,0);p:=fn_validar_numero(j.get_number('id_periodo'),10,0);
 idn:=fn_validar_numero(j.get_number('id_control'),10,0);d:=j.get_string('dominio');e:=j.get_string('estado');
 f:=TO_DATE(j.get_string('fecha_corte'),'FXYYYY-MM-DD');
 IF e='COMPLETA' AND d='ASISTENCIA' THEN
  SELECT COUNT(*) INTO n FROM trx_sesion_clase s JOIN est_ponderacion_periodo w ON w.id_ponderacion_periodo=s.id_ponderacion_periodo
  JOIN est_curso_asignatura o ON o.id_curso_asignatura=w.id_curso_asignatura
  JOIN trx_inscripcion i ON i.id_curso=o.id_curso AND i.estado<>'ANULADA'
  JOIN est_curso cc ON cc.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=cc.id_ciclo
  WHERE o.id_curso=c AND w.id_periodo=p AND s.estado='IMPARTIDA'
  AND s.fin<CAST(f+1 AS TIMESTAMP) AND s.fecha_academica BETWEEN i.fecha_inicio AND COALESCE(i.fecha_fin,x.fecha_fin)
  AND NOT EXISTS (SELECT 1 FROM trx_asistencia a WHERE a.id_inscripcion=i.id_inscripcion AND a.id_sesion=s.id_sesion AND a.fecha_registro<CAST(f+1 AS TIMESTAMP));
  IF n>0 THEN RAISE_APPLICATION_ERROR(-20820,'No puede declarar asistencia completa: faltan registros al corte.');END IF;
 ELSIF e='COMPLETA' AND d='NOTAS' THEN
  SELECT COUNT(*) INTO n FROM trx_inscripcion i JOIN est_curso cc ON cc.id_curso=i.id_curso
  JOIN est_curso_asignatura o ON o.id_curso=i.id_curso JOIN est_ponderacion_periodo w ON w.id_curso_asignatura=o.id_curso_asignatura
  JOIN est_periodo_academico a ON a.id_periodo=w.id_periodo
  LEFT JOIN est_plazo_registro_notas pl ON pl.id_institucion=cc.id_institucion AND pl.id_ciclo=cc.id_ciclo
   AND pl.id_grado=cc.id_grado AND pl.id_periodo=w.id_periodo AND pl.tipo_intento='ORDINARIA'
  WHERE i.id_curso=c AND w.id_periodo=p AND i.estado<>'ANULADA' AND w.estado='PUBLICADO'
  AND i.fecha_inicio<=a.fecha_fin AND COALESCE(i.fecha_fin,a.fecha_fin)>=a.fecha_inicio
  AND (pl.id_plazo_registro_notas IS NULL OR (pl.fecha_limite_registro<CAST(f+1 AS TIMESTAMP)
   AND fn_elegir_calificacion(i.id_estudiante,o.id_asignatura,p,CAST(f+1 AS TIMESTAMP)-INTERVAL '0.000001' SECOND) IS NULL));
  IF n>0 THEN RAISE_APPLICATION_ERROR(-20820,'No puede declarar notas completas: notas/configuracion pendientes al corte.');END IF;
 END IF;
 declarados:=fn_validar_numero(j.get_number('registros_declarados'),10,0);
 -- Conteo de hechos unicos al corte, separado de intentos/versiones de notas.
 IF d='MATRICULA' THEN
  SELECT COUNT(*) INTO esperados FROM trx_inscripcion i JOIN est_curso cc ON cc.id_curso=i.id_curso
  JOIN est_ciclo x ON x.id_ciclo=cc.id_ciclo WHERE i.id_curso=c AND i.estado<>'ANULADA'
  AND f BETWEEN i.fecha_inicio AND COALESCE(i.fecha_fin,x.fecha_fin);
 ELSIF d='BECAS' THEN
  SELECT COUNT(DISTINCT b.id_beca) INTO esperados FROM trx_beca b JOIN trx_inscripcion i ON i.id_inscripcion=b.id_inscripcion
  JOIN trx_beca_vigencia v ON v.id_beca=b.id_beca JOIN est_curso cc ON cc.id_curso=i.id_curso JOIN est_ciclo x ON x.id_ciclo=cc.id_ciclo
  WHERE i.id_curso=c AND v.fecha_inicio<=f AND COALESCE(v.fecha_fin,x.fecha_fin)>=f;
 ELSIF d='ASISTENCIA' THEN
  SELECT COUNT(*) INTO esperados FROM trx_asistencia aa JOIN trx_inscripcion i ON i.id_inscripcion=aa.id_inscripcion
  JOIN trx_sesion_clase ss ON ss.id_sesion=aa.id_sesion JOIN est_ponderacion_periodo pp ON pp.id_ponderacion_periodo=ss.id_ponderacion_periodo
  WHERE i.id_curso=c AND pp.id_periodo=p AND ss.estado='IMPARTIDA' AND ss.fin<CAST(f+1 AS TIMESTAMP)
  AND aa.fecha_registro<CAST(f+1 AS TIMESTAMP);
 ELSIF d='NOTAS' THEN
  SELECT COUNT(*) INTO esperados FROM (
   SELECT DISTINCT i.id_estudiante,o.id_asignatura FROM trx_inscripcion i JOIN est_curso_asignatura o ON o.id_curso=i.id_curso
   JOIN trx_resultado_periodo rr ON rr.id_estudiante=i.id_estudiante AND rr.id_asignatura=o.id_asignatura AND rr.id_periodo=p
   JOIN trx_calificacion nn ON nn.id_calificacion=rr.id_calificacion_seleccionada
   WHERE i.id_curso=c AND rr.fecha_seleccion<CAST(f+1 AS TIMESTAMP)
   AND nn.fecha_validacion<CAST(f+1 AS TIMESTAMP) AND (nn.fecha_anulacion IS NULL OR nn.fecha_anulacion>=CAST(f+1 AS TIMESTAMP))
   AND NOT EXISTS (SELECT 1 FROM trx_resultado_periodo r2 WHERE r2.id_estudiante=rr.id_estudiante
    AND r2.id_asignatura=rr.id_asignatura AND r2.id_periodo=rr.id_periodo AND r2.version>rr.version AND r2.fecha_seleccion<CAST(f+1 AS TIMESTAMP))
   AND NOT EXISTS (SELECT 1 FROM trx_calificacion n2 WHERE n2.id_inscripcion=nn.id_inscripcion
    AND n2.id_ponderacion_periodo=nn.id_ponderacion_periodo AND n2.tipo_intento=nn.tipo_intento
    AND n2.numero_intento=nn.numero_intento AND n2.version>nn.version AND n2.fecha_validacion<CAST(f+1 AS TIMESTAMP)));
 ELSE RAISE_APPLICATION_ERROR(-20820,'Dominio de cobertura invalido.');END IF;
 IF e='COMPLETA' AND (declarados IS NULL OR declarados<>esperados) THEN
  RAISE_APPLICATION_ERROR(-20820,'Conteo declarado no coincide con hechos unicos aceptados al corte.');END IF;
 IF e='NO_APLICA' THEN
  IF d<>'BECAS' OR declarados<>0 OR esperados<>0 THEN RAISE_APPLICATION_ERROR(-20820,'NO_APLICA requiere regla explicita y cero hechos contradictorios.');END IF;
  SELECT h.permite_becas INTO habilitada FROM est_curso cc JOIN est_institucion_ciclo h
  ON h.id_institucion=cc.id_institucion AND h.id_ciclo=cc.id_ciclo WHERE cc.id_curso=c;
  IF habilitada<>0 THEN RAISE_APPLICATION_ERROR(-20820,'Becas habilitadas: cero becas no significa NO_APLICA.');END IF;
 END IF;
 INSERT INTO trx_control_carga(id_control,id_curso,id_periodo,dominio,fecha_corte,estado,registros_declarados,fecha_recepcion,id_ejecucion)
 VALUES(idn,c,p,d,f,e,declarados,LOCALTIMESTAMP,
 fn_validar_numero(j.get_number('id_ejecucion'),10,0));
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('trx_control_carga',TO_CHAR(idn),'DECLARACION',SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,
 fn_id_transaccion(),p_justificacion);
EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_cobertura;RAISE;
END;
/

-- === PR_CONFIGURAR_ACCESO ===
CREATE OR REPLACE PROCEDURE pr_configurar_acceso(p_usuario VARCHAR2) AUTHID DEFINER IS u VARCHAR2(128);n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_CONFIGURAR_ACCESO
  -- Prepara un usuario de trabajo: le quita INSERT, UPDATE y DELETE directos sobre las tablas
  -- y le da EXECUTE sobre los procedimientos de operación. Cargas, cierres y reaperturas
  -- quedan para el propietario.
  -- ----------------------------------------------------------------------
BEGIN
 u:=DBMS_ASSERT.SIMPLE_SQL_NAME(UPPER(TRIM(p_usuario)));
 IF u=USER THEN RAISE_APPLICATION_ERROR(-20821,'Usar un usuario distinto del propietario.');END IF;
 SELECT COUNT(*) INTO n FROM all_users WHERE username=u;
 IF n<>1 THEN RAISE_APPLICATION_ERROR(-20821,'Usuario inexistente.');END IF;
 -- Solo revoca concesiones directas de estas tablas. Revisar tambien roles y ANY TABLE.
 FOR r IN (SELECT table_name FROM user_tables WHERE table_name IN
 (SELECT DISTINCT UPPER(entidad) FROM val_regla WHERE capa='OPERACION') OR table_name LIKE 'STG\_%' ESCAPE '\') LOOP
  FOR g IN (SELECT privilege FROM user_tab_privs_made WHERE grantee=u AND table_name=r.table_name
    AND privilege IN ('INSERT','UPDATE','DELETE')) LOOP
   EXECUTE IMMEDIATE 'REVOKE '||g.privilege||' ON '||DBMS_ASSERT.SIMPLE_SQL_NAME(r.table_name)||' FROM '||u;
  END LOOP;
 END LOOP;
 FOR r IN (SELECT object_name FROM user_objects WHERE object_type='PROCEDURE' AND object_name IN
 ('PR_GUARDAR_REGISTRO','PR_PUBLICAR_PLAN','PR_TRASLADAR_ESTUDIANTE','PR_REGISTRAR_CALIFICACION',
 'PR_CORREGIR_CALIFICACION','PR_VALIDAR_CALIFICACION','PR_ANULAR_CALIFICACION','PR_SELECCIONAR_RESULTADO',
 'PR_OTORGAR_BECA','PR_SUSPENDER_BECA','PR_REANUDAR_BECA','PR_RECIBIR_ENTRADA','PR_PROCESAR_ENTRADA',
 'PR_DECLARAR_COBERTURA','PR_CONSULTAR_PENDIENTES','PR_CONSULTAR_PROMEDIOS')) LOOP
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON '||r.object_name||' TO '||u;
 END LOOP;
 -- Cargas, cierres, reaperturas, configuracion y revision programada quedan administrativos.
END;
/

-- === PR_CERRAR_CICLO ===
CREATE OR REPLACE PROCEDURE pr_cerrar_ciclo(p_ciclo NUMBER,p_motivo VARCHAR2) AUTHID DEFINER IS n NUMBER;
  -- ----------------------------------------------------------------------
  -- PR_CERRAR_CICLO
  -- Cierra un ciclo solo si ya terminó y no hay notas ni asistencias pendientes. Registra el
  -- motivo en val_cambio y diagnostica las reglas.
  -- ----------------------------------------------------------------------
BEGIN
 SAVEPOINT sv_cerrar;pr_bloquear_validaciones;
 IF TRIM(p_motivo) IS NULL THEN RAISE_APPLICATION_ERROR(-20818,'Cierre requiere motivo.');END IF;
 SELECT COUNT(*) INTO n FROM est_ciclo WHERE id_ciclo=p_ciclo AND fecha_fin<=TRUNC(CURRENT_DATE) AND estado='ABIERTO';
 IF n<>1 THEN RAISE_APPLICATION_ERROR(-20818,'Ciclo no finalizado o no abierto.');END IF;
 SELECT COUNT(*) INTO n FROM vw_notas_pendientes WHERE id_ciclo=p_ciclo;
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20818,'Hay notas pendientes.');END IF;
 SELECT COUNT(*) INTO n FROM vw_asistencia_pendiente WHERE id_ciclo=p_ciclo;
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20818,'Hay asistencias pendientes.');END IF;
 SELECT COUNT(*) INTO n FROM vw_configuracion_pendiente WHERE id_ciclo=p_ciclo;
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20818,'Configuracion pendiente.');END IF;
 SELECT COUNT(*) INTO n FROM trx_control_carga z JOIN est_curso c ON c.id_curso=z.id_curso
 WHERE c.id_ciclo=p_ciclo AND z.estado='PARCIAL' AND z.fecha_corte<=TRUNC(CURRENT_DATE)
 AND NOT EXISTS (SELECT 1 FROM trx_control_carga u WHERE u.id_curso=z.id_curso AND u.id_periodo=z.id_periodo
 AND u.dominio=z.dominio AND u.fecha_corte>z.fecha_corte AND u.fecha_corte<=TRUNC(CURRENT_DATE));
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20818,'Hay declaraciones parciales.');END IF;
 INSERT INTO val_cambio(entidad,clave,accion,actor,fecha,transaccion,motivo)
 VALUES('est_ciclo',TO_CHAR(p_ciclo),'CIERRE',SYS_CONTEXT('USERENV','SESSION_USER'),LOCALTIMESTAMP,
 fn_id_transaccion(),p_motivo);
 SELECT COUNT(*) INTO n FROM est_curso c CROSS JOIN est_periodo_academico p
 CROSS JOIN (SELECT 'MATRICULA' dominio FROM dual UNION ALL SELECT 'NOTAS' FROM dual
 UNION ALL SELECT 'ASISTENCIA' FROM dual UNION ALL SELECT 'BECAS' FROM dual) d
 WHERE c.id_ciclo=p_ciclo AND p.id_ciclo=p_ciclo AND c.estado<>'ANULADO'
 AND NOT EXISTS (SELECT 1 FROM trx_control_carga z WHERE z.id_curso=c.id_curso
 AND z.id_periodo=p.id_periodo AND z.dominio=d.dominio AND z.estado IN ('COMPLETA','NO_APLICA')
 AND z.fecha_corte<=TRUNC(CURRENT_DATE) AND NOT EXISTS (SELECT 1 FROM trx_control_carga u
 WHERE u.id_curso=z.id_curso AND u.id_periodo=z.id_periodo AND u.dominio=z.dominio
 AND u.fecha_corte>z.fecha_corte AND u.fecha_corte<=TRUNC(CURRENT_DATE)));
 IF n>0 THEN RAISE_APPLICATION_ERROR(-20818,'Faltan declaraciones completas por curso, periodo o dominio.');END IF;
 SELECT COUNT(*) INTO n FROM est_periodo_academico WHERE id_ciclo=p_ciclo;
 IF n=0 THEN RAISE_APPLICATION_ERROR(-20818,'Ciclo sin periodos configurados.');END IF;
 UPDATE trx_resultado_periodo SET fecha_cierre=LOCALTIMESTAMP WHERE fecha_cierre IS NULL
 AND id_periodo IN (SELECT id_periodo FROM est_periodo_academico WHERE id_ciclo=p_ciclo)
 AND version=(SELECT MAX(v.version) FROM trx_resultado_periodo v WHERE v.id_estudiante=trx_resultado_periodo.id_estudiante AND v.id_asignatura=trx_resultado_periodo.id_asignatura AND v.id_periodo=trx_resultado_periodo.id_periodo);
 UPDATE est_institucion_ciclo SET estado='CERRADO' WHERE id_ciclo=p_ciclo AND estado='ABIERTO';
 UPDATE est_ciclo SET estado='CERRADO' WHERE id_ciclo=p_ciclo;

EXCEPTION WHEN OTHERS THEN ROLLBACK TO sv_cerrar;RAISE;
END;
/
