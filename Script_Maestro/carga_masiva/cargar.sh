#!/usr/bin/env bash
# Carga los CSV en orden de dependencias con SQL*Loader (ruta convencional: Oracle valida PK, UK, FK y CHECK fila a fila).
# Uso: ORACLE_CONN=usuario/clave@//host:puerto/servicio ./cargar.sh
set -euo pipefail
cd "$(dirname "$0")"
: "${ORACLE_CONN:?Definir ORACLE_CONN=usuario/clave@//host:puerto/servicio}"
mkdir -p logs
echo "Cargando cat_tipo_documento (1 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_tipo_documento.ctl log=logs/cat_tipo_documento.log bad=logs/cat_tipo_documento.bad silent=header,feedback
echo "Cargando cat_tipo_institucion (2 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_tipo_institucion.ctl log=logs/cat_tipo_institucion.log bad=logs/cat_tipo_institucion.bad silent=header,feedback
echo "Cargando cat_departamento (14 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_departamento.ctl log=logs/cat_departamento.log bad=logs/cat_departamento.bad silent=header,feedback
echo "Cargando cat_zona (2 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_zona.ctl log=logs/cat_zona.log bad=logs/cat_zona.bad silent=header,feedback
echo "Cargando cat_modalidad (1 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_modalidad.ctl log=logs/cat_modalidad.log bad=logs/cat_modalidad.bad silent=header,feedback
echo "Cargando cat_jornada (2 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_jornada.ctl log=logs/cat_jornada.log bad=logs/cat_jornada.bad silent=header,feedback
echo "Cargando cat_area_conocimiento (9 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_area_conocimiento.ctl log=logs/cat_area_conocimiento.log bad=logs/cat_area_conocimiento.bad silent=header,feedback
echo "Cargando cat_tipo_beca (3 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_tipo_beca.ctl log=logs/cat_tipo_beca.log bad=logs/cat_tipo_beca.bad silent=header,feedback
echo "Cargando cat_nivel (2 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_nivel.ctl log=logs/cat_nivel.log bad=logs/cat_nivel.bad silent=header,feedback
echo "Cargando est_ciclo (4 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_ciclo.ctl log=logs/est_ciclo.log bad=logs/est_ciclo.bad silent=header,feedback
echo "Cargando auditoria_etl_evaluaciones (2 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/auditoria_etl_evaluaciones.ctl log=logs/auditoria_etl_evaluaciones.log bad=logs/auditoria_etl_evaluaciones.bad silent=header,feedback
echo "Cargando cat_grado (12 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/cat_grado.ctl log=logs/cat_grado.log bad=logs/cat_grado.bad silent=header,feedback
echo "Cargando mae_institucion (42 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/mae_institucion.ctl log=logs/mae_institucion.log bad=logs/mae_institucion.bad silent=header,feedback
echo "Cargando mae_persona (7,714 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/mae_persona.ctl log=logs/mae_persona.log bad=logs/mae_persona.bad silent=header,feedback
echo "Cargando mae_asignatura (10 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/mae_asignatura.ctl log=logs/mae_asignatura.log bad=logs/mae_asignatura.bad silent=header,feedback
echo "Cargando est_periodo_academico (14 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_periodo_academico.ctl log=logs/est_periodo_academico.log bad=logs/est_periodo_academico.bad silent=header,feedback
echo "Cargando mae_estudiante (7,168 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/mae_estudiante.ctl log=logs/mae_estudiante.log bad=logs/mae_estudiante.bad silent=header,feedback
echo "Cargando mae_docente (546 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/mae_docente.ctl log=logs/mae_docente.log bad=logs/mae_docente.bad silent=header,feedback
echo "Cargando est_institucion_ciclo (96 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_institucion_ciclo.ctl log=logs/est_institucion_ciclo.log bad=logs/est_institucion_ciclo.bad silent=header,feedback
echo "Cargando est_curso (1,008 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_curso.ctl log=logs/est_curso.log bad=logs/est_curso.bad silent=header,feedback
echo "Cargando est_plazo_registro_notas (6,120 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_plazo_registro_notas.ctl log=logs/est_plazo_registro_notas.log bad=logs/est_plazo_registro_notas.bad silent=header,feedback
echo "Cargando est_curso_asignatura (8,064 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_curso_asignatura.ctl log=logs/est_curso_asignatura.log bad=logs/est_curso_asignatura.bad silent=header,feedback
echo "Cargando trx_inscripcion (12,906 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_inscripcion.ctl log=logs/trx_inscripcion.log bad=logs/trx_inscripcion.bad silent=header,feedback
echo "Cargando trx_control_carga (9,762 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_control_carga.ctl log=logs/trx_control_carga.log bad=logs/trx_control_carga.bad silent=header,feedback
echo "Cargando est_ponderacion_periodo (24,480 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/est_ponderacion_periodo.ctl log=logs/est_ponderacion_periodo.log bad=logs/est_ponderacion_periodo.bad silent=header,feedback
echo "Cargando trx_asignacion_docente (8,148 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_asignacion_docente.ctl log=logs/trx_asignacion_docente.log bad=logs/trx_asignacion_docente.bad silent=header,feedback
echo "Cargando trx_beca (774 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_beca.ctl log=logs/trx_beca.log bad=logs/trx_beca.bad silent=header,feedback
echo "Cargando trx_calificacion (335,447 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_calificacion.ctl log=logs/trx_calificacion.log bad=logs/trx_calificacion.bad silent=header,feedback
echo "Cargando trx_sesion_clase (252,864 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_sesion_clase.ctl log=logs/trx_sesion_clase.log bad=logs/trx_sesion_clase.bad silent=header,feedback
echo "Cargando trx_beca_vigencia (896 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_beca_vigencia.ctl log=logs/trx_beca_vigencia.log bad=logs/trx_beca_vigencia.bad silent=header,feedback
echo "Cargando trx_resultado_periodo (335,447 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_resultado_periodo.ctl log=logs/trx_resultado_periodo.log bad=logs/trx_resultado_periodo.bad silent=header,feedback
echo "Cargando trx_asistencia (3,114,006 filas)..."; sqlldr userid="$ORACLE_CONN" control=ctl/trx_asistencia.ctl log=logs/trx_asistencia.log bad=logs/trx_asistencia.bad silent=header,feedback
echo "Carga terminada. Ejecutar post_carga.sql en SQL*Plus o SQLcl."
