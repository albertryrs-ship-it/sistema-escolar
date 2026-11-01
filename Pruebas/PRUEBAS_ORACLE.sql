-- ==============================================================
-- PRUEBAS_ORACLE.sql: RESULTADOS ESPERADOS
-- Descripción: Comprueba en Oracle los resultados conocidos de los datos ficticios (promedios, selección,
--   cobertura, retención…), después de cargar staging (EXEC pr_cargar_staging). Solo lee.
-- ==============================================================
-- Oracle Database 23ai (también 19c y 21c). Ejecutar como script en SQL*Plus o SQLcl.
-- Sesión dedicada, sin trabajo pendiente. No usar SYS/SYSTEM.
SET SERVEROUTPUT ON
SET DEFINE OFF
SET AUTOCOMMIT OFF
WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
ALTER SESSION SET TIME_ZONE = '-06:00';

DECLARE v_valor NUMBER;

 PROCEDURE comprobar(p_nombre VARCHAR2,p_sql VARCHAR2,p_esperado NUMBER) IS
 BEGIN
   EXECUTE IMMEDIATE p_sql INTO v_valor;
   IF (p_esperado IS NULL AND v_valor IS NOT NULL)
      OR (p_esperado IS NOT NULL AND (v_valor IS NULL OR ABS(v_valor-p_esperado)>0.00000001)) THEN
     RAISE_APPLICATION_ERROR(-20050,p_nombre||': esperado '||NVL(TO_CHAR(p_esperado),'NULL')||', obtenido '||NVL(TO_CHAR(v_valor),'NULL'));
   END IF;
   DBMS_OUTPUT.PUT_LINE('OK: '||p_nombre);
 END;
BEGIN

 comprobar('Promedio actual: pendientes no son cero',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-15 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-15 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-15 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1001 AND o.id_asignatura=501 AND c.id_ciclo=2026
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=x.fecha_inicio
) SELECT SUM(r.nota*o.peso_relativo)/NULLIF(SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo END),0) AS valor FROM obligaciones o LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',70);
 comprobar('Cobertura ponderada actual',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-15 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-15 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-15 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1001 AND o.id_asignatura=501 AND c.id_ciclo=2026
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=x.fecha_inicio
) SELECT 100*SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo ELSE 0 END)/NULLIF(SUM(o.peso_relativo),0) AS valor FROM obligaciones o LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',60);
 comprobar('Final todavía no publicable',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-15 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-15 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-15 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1001 AND o.id_asignatura=501 AND c.id_ciclo=2026
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=x.fecha_inicio
), cierre AS (
 SELECT CASE WHEN x.estado='CERRADO' AND x.fecha_fin<=TRUNC(TIMESTAMP '2026-09-15 23:59:59')
        AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_INSTITUCIONES_CICLO h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE i.id_estudiante=1001 AND c.id_ciclo=2026 AND i.estado<>'ANULADA' AND h.estado<>'CERRADO')
        THEN 1 ELSE 0 END AS listo
 FROM STG_CICLOS x WHERE x.id_ciclo=2026
) SELECT CASE WHEN COUNT(r.nota)=COUNT(*) AND COUNT(*)>0
        AND MIN(CASE WHEN r.fecha_cierre IS NOT NULL AND r.fecha_cierre<=TIMESTAMP '2026-09-15 23:59:59' THEN 1 ELSE 0 END)=1
        AND MIN(k.listo)=1
        THEN SUM(r.nota*o.peso_relativo)/NULLIF(SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo END),0) ELSE NULL END AS valor FROM obligaciones o CROSS JOIN cierre k LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',NULL);
 comprobar('Cero real participa',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-15 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-15 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-15 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1005 AND o.id_asignatura=501 AND c.id_ciclo=2026
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=x.fecha_inicio
) SELECT SUM(r.nota*o.peso_relativo)/NULLIF(SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo END),0) AS valor FROM obligaciones o LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',40);
 comprobar('Final completo de año cerrado',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-01-16 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-01-16 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-01-16 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1001 AND o.id_asignatura=501 AND c.id_ciclo=2025
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2025-11-30')>=x.fecha_inicio
), cierre AS (
 SELECT CASE WHEN x.estado='CERRADO' AND x.fecha_fin<=TRUNC(TIMESTAMP '2026-01-16 23:59:59')
        AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_INSTITUCIONES_CICLO h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE i.id_estudiante=1001 AND c.id_ciclo=2025 AND i.estado<>'ANULADA' AND h.estado<>'CERRADO')
        THEN 1 ELSE 0 END AS listo
 FROM STG_CICLOS x WHERE x.id_ciclo=2025
) SELECT CASE WHEN COUNT(r.nota)=COUNT(*) AND COUNT(*)>0
        AND MIN(CASE WHEN r.fecha_cierre IS NOT NULL AND r.fecha_cierre<=TIMESTAMP '2026-01-16 23:59:59' THEN 1 ELSE 0 END)=1
        AND MIN(k.listo)=1
        THEN SUM(r.nota*o.peso_relativo)/NULLIF(SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo END),0) ELSE NULL END AS valor FROM obligaciones o CROSS JOIN cierre k LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',78);
 comprobar('Traslado usa pesos normalizados',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-01-16 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-01-16 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-01-16 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), pesos AS (
 SELECT p.*,p.peso/SUM(p.peso) OVER (PARTITION BY p.id_curso_asignatura) AS peso_relativo
 FROM STG_PONDERACIONES p WHERE p.estado='PUBLICADO'
), obligaciones AS (
 SELECT DISTINCT i.id_estudiante,o.id_asignatura,p.id_periodo,p.peso_relativo
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN pesos p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 WHERE i.id_estudiante=1004 AND o.id_asignatura=501 AND c.id_ciclo=2025
 AND i.estado<>'ANULADA' AND o.tipo_resultado='NUMERICA'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2025-11-30')>=x.fecha_inicio
), cierre AS (
 SELECT CASE WHEN x.estado='CERRADO' AND x.fecha_fin<=TRUNC(TIMESTAMP '2026-01-16 23:59:59')
        AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso JOIN STG_INSTITUCIONES_CICLO h ON h.id_institucion=c.id_institucion AND h.id_ciclo=c.id_ciclo WHERE i.id_estudiante=1004 AND c.id_ciclo=2025 AND i.estado<>'ANULADA' AND h.estado<>'CERRADO')
        THEN 1 ELSE 0 END AS listo
 FROM STG_CICLOS x WHERE x.id_ciclo=2025
) SELECT CASE WHEN COUNT(r.nota)=COUNT(*) AND COUNT(*)>0
        AND MIN(CASE WHEN r.fecha_cierre IS NOT NULL AND r.fecha_cierre<=TIMESTAMP '2026-01-16 23:59:59' THEN 1 ELSE 0 END)=1
        AND MIN(k.listo)=1
        THEN SUM(r.nota*o.peso_relativo)/NULLIF(SUM(CASE WHEN r.nota IS NOT NULL THEN o.peso_relativo END),0) ELSE NULL END AS valor FROM obligaciones o CROSS JOIN cierre k LEFT JOIN resultados r ON r.id_estudiante=o.id_estudiante AND r.id_asignatura=o.id_asignatura AND r.id_periodo=o.id_periodo~',76);
 comprobar('Mejor recuperación, no necesariamente la última',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-01-16 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-01-16 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-01-16 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
) SELECT MAX(nota) FROM resultados WHERE id_estudiante=1002 AND id_asignatura=501 AND id_periodo=20253~',70);
 comprobar('Anulada sin revivir versión anterior',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-05 12:00:00'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-05 12:00:00')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-05 12:00:00'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
) SELECT MAX(nota) FROM resultados WHERE id_estudiante=1007 AND id_asignatura=502 AND id_periodo=20262~',NULL);
 comprobar('Nueva versión válida posterior',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-18 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-18 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-18 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
) SELECT MAX(nota) FROM resultados WHERE id_estudiante=1007 AND id_asignatura=502 AND id_periodo=20262~',50);
 comprobar('Retención: traslado y repetición continúan',q'~WITH cohorte AS (
 SELECT DISTINCT i.id_estudiante FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 WHERE c.id_ciclo=2025 AND i.estado<>'ANULADA' AND i.fecha_inicio<=DATE '2025-02-15' AND COALESCE(i.fecha_fin,DATE '2025-11-30')>=DATE '2025-02-15'
 AND NOT EXISTS (SELECT 1 FROM STG_INSCRIPCIONES g JOIN STG_CURSOS h ON h.id_curso=g.id_curso JOIN STG_GRADOS z ON z.id_grado=h.id_grado WHERE g.id_estudiante=i.id_estudiante AND h.id_ciclo=2025 AND g.estado<>'ANULADA' AND g.resultado_cierre='GRADUADO' AND z.es_ultimo_grado=1)
), seguidos AS (
 SELECT DISTINCT i.id_estudiante FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 WHERE c.id_ciclo=2026 AND i.estado<>'ANULADA' AND i.fecha_inicio<=DATE '2026-02-15' AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=DATE '2026-02-15'
), cobertura AS (
 SELECT CASE WHEN EXISTS (SELECT 1 FROM STG_CURSOS c WHERE c.id_ciclo=2026 AND c.estado<>'ANULADO' AND NOT EXISTS (SELECT 1 FROM STG_CONTROL_CARGA z WHERE z.id_curso=c.id_curso AND z.dominio='MATRICULA' AND z.fecha_corte=DATE '2026-02-15' AND z.estado='COMPLETA')) THEN 0 ELSE 1 END AS completa
 FROM STG_CICLOS x WHERE x.id_ciclo=2026
)
SELECT CASE WHEN MIN(k.completa)=1 THEN 100*SUM(CASE WHEN s.id_estudiante IS NOT NULL THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) END
FROM cohorte c CROSS JOIN cobertura k LEFT JOIN seguidos s ON s.id_estudiante=c.id_estudiante~',80);
 comprobar('Beca suspendida en julio',q'~SELECT COUNT(*) FROM STG_BECAS_VIGENCIA WHERE id_beca=7006 AND fecha_inicio<=DATE '2026-07-15' AND COALESCE(fecha_fin,DATE '2026-11-30')>=DATE '2026-07-15'~',0);
 comprobar('Beca reanudada en agosto',q'~SELECT COUNT(*) FROM STG_BECAS_VIGENCIA WHERE id_beca=7006 AND fecha_inicio<=DATE '2026-08-15' AND COALESCE(fecha_fin,DATE '2026-11-30')>=DATE '2026-08-15'~',1);
 comprobar('Hay sesiones nocturnas que cruzan medianoche',q'~SELECT CASE WHEN COUNT(*)>0 THEN 1 ELSE 0 END FROM STG_SESIONES WHERE TRUNC(fin)>fecha_academica AND fin>inicio~',1);
 comprobar('Se conserva cobertura desconocida de becas',q'~SELECT COUNT(*) FROM STG_CONTROL_CARGA WHERE id_curso=301 AND dominio='BECAS' AND fecha_corte=DATE '2026-09-15' AND estado='PARCIAL'~',1);
 comprobar('Completitud: 21 de 22 obligaciones vencidas',q'~WITH versiones AS (
 SELECT n.*,ROW_NUMBER() OVER (PARTITION BY id_inscripcion,id_ponderacion_periodo,numero_intento ORDER BY version DESC) AS rn
 FROM STG_CALIFICACIONES n WHERE fecha_validacion<=TIMESTAMP '2026-09-15 23:59:59'
), intentos AS (
 SELECT * FROM versiones WHERE rn=1 AND (fecha_anulacion IS NULL OR fecha_anulacion>TIMESTAMP '2026-09-15 23:59:59')
), elecciones AS (
 SELECT r.*,ROW_NUMBER() OVER (PARTITION BY id_estudiante,id_asignatura,id_periodo ORDER BY version DESC) AS rn
 FROM STG_RESULTADOS_PERIODO r WHERE fecha_seleccion<=TIMESTAMP '2026-09-15 23:59:59'
), resultados AS (
 SELECT r.id_estudiante,r.id_asignatura,r.id_periodo,n.nota,r.fecha_cierre
 FROM elecciones r JOIN intentos n ON n.id_calificacion=r.id_calificacion_seleccionada WHERE r.rn=1
), candidatas AS (
 SELECT i.id_estudiante,o.id_asignatura,p.id_periodo,w.fecha_limite_registro,
 ROW_NUMBER() OVER (PARTITION BY i.id_estudiante,o.id_asignatura,p.id_periodo ORDER BY i.fecha_inicio DESC,i.id_inscripcion DESC) AS rn
 FROM STG_INSCRIPCIONES i JOIN STG_CURSOS c ON c.id_curso=i.id_curso
 JOIN STG_CURSOS_ASIGNATURAS o ON o.id_curso=c.id_curso
 JOIN STG_PONDERACIONES p ON p.id_curso_asignatura=o.id_curso_asignatura
 JOIN STG_PERIODOS x ON x.id_periodo=p.id_periodo
 JOIN STG_PLAZOS_NOTAS w ON w.id_institucion=c.id_institucion AND w.id_ciclo=c.id_ciclo AND w.id_grado=c.id_grado AND w.id_periodo=p.id_periodo AND w.tipo_intento='ORDINARIA'
 WHERE c.id_ciclo=2026 AND i.estado<>'ANULADA' AND p.estado='PUBLICADO'
 AND i.fecha_inicio<=x.fecha_fin AND COALESCE(i.fecha_fin,DATE '2026-11-30')>=x.fecha_inicio
), vencidas AS (
 SELECT * FROM candidatas WHERE rn=1 AND fecha_limite_registro<TIMESTAMP '2026-09-15 23:59:59'
)
SELECT 100.0*SUM(CASE WHEN r.id_estudiante IS NOT NULL THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0)
FROM vencidas v LEFT JOIN resultados r ON r.id_estudiante=v.id_estudiante AND r.id_asignatura=v.id_asignatura AND r.id_periodo=v.id_periodo~',95.45454545454545);
END;
/
