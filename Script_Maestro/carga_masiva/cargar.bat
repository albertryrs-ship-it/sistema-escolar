@echo off
REM ===================================================================
REM cargar.bat - version Windows de cargar.sh (carga masiva con SQL*Loader)
REM Antes de usarlo: indique la carpeta del Instant Client (IC) y la conexion (ORACLE_CONN),
REM en las lineas de abajo o como variables de entorno. Ejemplo de conexion:
REM   usuario/clave@//host:puerto/servicio   (ver "Configuracion de cada equipo" en Script_Maestro/README.md)
REM Ejecutar con doble clic o desde cmd. Se detiene en el primer error.
REM ===================================================================
if not defined IC set /p "IC=Carpeta del Instant Client (con sqlldr.exe): "
if not defined ORACLE_CONN set /p "ORACLE_CONN=Conexion (usuario/clave@//host:puerto/servicio): "
set "CONN=%ORACLE_CONN%"

cd /d "%~dp0"
if not exist "%IC%\sqlldr.exe" (
  echo No se encontro sqlldr.exe en %IC%. Revise la carpeta del Instant Client (variable IC).
  pause
  exit /b 1
)
if not exist logs mkdir logs

echo Cargando cat_tipo_documento...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_tipo_documento.ctl log=logs\cat_tipo_documento.log bad=logs\cat_tipo_documento.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_tipo_documento. Revise logs\cat_tipo_documento.log & pause & exit /b 1 )
echo Cargando cat_tipo_institucion...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_tipo_institucion.ctl log=logs\cat_tipo_institucion.log bad=logs\cat_tipo_institucion.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_tipo_institucion. Revise logs\cat_tipo_institucion.log & pause & exit /b 1 )
echo Cargando cat_departamento...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_departamento.ctl log=logs\cat_departamento.log bad=logs\cat_departamento.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_departamento. Revise logs\cat_departamento.log & pause & exit /b 1 )
echo Cargando cat_zona...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_zona.ctl log=logs\cat_zona.log bad=logs\cat_zona.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_zona. Revise logs\cat_zona.log & pause & exit /b 1 )
echo Cargando cat_modalidad...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_modalidad.ctl log=logs\cat_modalidad.log bad=logs\cat_modalidad.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_modalidad. Revise logs\cat_modalidad.log & pause & exit /b 1 )
echo Cargando cat_jornada...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_jornada.ctl log=logs\cat_jornada.log bad=logs\cat_jornada.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_jornada. Revise logs\cat_jornada.log & pause & exit /b 1 )
echo Cargando cat_area_conocimiento...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_area_conocimiento.ctl log=logs\cat_area_conocimiento.log bad=logs\cat_area_conocimiento.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_area_conocimiento. Revise logs\cat_area_conocimiento.log & pause & exit /b 1 )
echo Cargando cat_tipo_beca...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_tipo_beca.ctl log=logs\cat_tipo_beca.log bad=logs\cat_tipo_beca.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_tipo_beca. Revise logs\cat_tipo_beca.log & pause & exit /b 1 )
echo Cargando cat_nivel...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_nivel.ctl log=logs\cat_nivel.log bad=logs\cat_nivel.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_nivel. Revise logs\cat_nivel.log & pause & exit /b 1 )
echo Cargando est_ciclo...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_ciclo.ctl log=logs\est_ciclo.log bad=logs\est_ciclo.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_ciclo. Revise logs\est_ciclo.log & pause & exit /b 1 )
echo Cargando auditoria_etl_evaluaciones...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\auditoria_etl_evaluaciones.ctl log=logs\auditoria_etl_evaluaciones.log bad=logs\auditoria_etl_evaluaciones.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar auditoria_etl_evaluaciones. Revise logs\auditoria_etl_evaluaciones.log & pause & exit /b 1 )
echo Cargando cat_grado...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\cat_grado.ctl log=logs\cat_grado.log bad=logs\cat_grado.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar cat_grado. Revise logs\cat_grado.log & pause & exit /b 1 )
echo Cargando mae_institucion...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\mae_institucion.ctl log=logs\mae_institucion.log bad=logs\mae_institucion.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar mae_institucion. Revise logs\mae_institucion.log & pause & exit /b 1 )
echo Cargando mae_persona...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\mae_persona.ctl log=logs\mae_persona.log bad=logs\mae_persona.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar mae_persona. Revise logs\mae_persona.log & pause & exit /b 1 )
echo Cargando mae_asignatura...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\mae_asignatura.ctl log=logs\mae_asignatura.log bad=logs\mae_asignatura.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar mae_asignatura. Revise logs\mae_asignatura.log & pause & exit /b 1 )
echo Cargando est_periodo_academico...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_periodo_academico.ctl log=logs\est_periodo_academico.log bad=logs\est_periodo_academico.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_periodo_academico. Revise logs\est_periodo_academico.log & pause & exit /b 1 )
echo Cargando mae_estudiante...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\mae_estudiante.ctl log=logs\mae_estudiante.log bad=logs\mae_estudiante.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar mae_estudiante. Revise logs\mae_estudiante.log & pause & exit /b 1 )
echo Cargando mae_docente...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\mae_docente.ctl log=logs\mae_docente.log bad=logs\mae_docente.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar mae_docente. Revise logs\mae_docente.log & pause & exit /b 1 )
echo Cargando est_institucion_ciclo...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_institucion_ciclo.ctl log=logs\est_institucion_ciclo.log bad=logs\est_institucion_ciclo.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_institucion_ciclo. Revise logs\est_institucion_ciclo.log & pause & exit /b 1 )
echo Cargando est_curso...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_curso.ctl log=logs\est_curso.log bad=logs\est_curso.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_curso. Revise logs\est_curso.log & pause & exit /b 1 )
echo Cargando est_plazo_registro_notas...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_plazo_registro_notas.ctl log=logs\est_plazo_registro_notas.log bad=logs\est_plazo_registro_notas.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_plazo_registro_notas. Revise logs\est_plazo_registro_notas.log & pause & exit /b 1 )
echo Cargando est_curso_asignatura...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_curso_asignatura.ctl log=logs\est_curso_asignatura.log bad=logs\est_curso_asignatura.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_curso_asignatura. Revise logs\est_curso_asignatura.log & pause & exit /b 1 )
echo Cargando trx_inscripcion...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_inscripcion.ctl log=logs\trx_inscripcion.log bad=logs\trx_inscripcion.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_inscripcion. Revise logs\trx_inscripcion.log & pause & exit /b 1 )
echo Cargando trx_control_carga...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_control_carga.ctl log=logs\trx_control_carga.log bad=logs\trx_control_carga.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_control_carga. Revise logs\trx_control_carga.log & pause & exit /b 1 )
echo Cargando est_ponderacion_periodo...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\est_ponderacion_periodo.ctl log=logs\est_ponderacion_periodo.log bad=logs\est_ponderacion_periodo.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar est_ponderacion_periodo. Revise logs\est_ponderacion_periodo.log & pause & exit /b 1 )
echo Cargando trx_asignacion_docente...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_asignacion_docente.ctl log=logs\trx_asignacion_docente.log bad=logs\trx_asignacion_docente.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_asignacion_docente. Revise logs\trx_asignacion_docente.log & pause & exit /b 1 )
echo Cargando trx_beca...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_beca.ctl log=logs\trx_beca.log bad=logs\trx_beca.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_beca. Revise logs\trx_beca.log & pause & exit /b 1 )
echo Cargando trx_calificacion...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_calificacion.ctl log=logs\trx_calificacion.log bad=logs\trx_calificacion.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_calificacion. Revise logs\trx_calificacion.log & pause & exit /b 1 )
echo Cargando trx_sesion_clase...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_sesion_clase.ctl log=logs\trx_sesion_clase.log bad=logs\trx_sesion_clase.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_sesion_clase. Revise logs\trx_sesion_clase.log & pause & exit /b 1 )
echo Cargando trx_beca_vigencia...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_beca_vigencia.ctl log=logs\trx_beca_vigencia.log bad=logs\trx_beca_vigencia.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_beca_vigencia. Revise logs\trx_beca_vigencia.log & pause & exit /b 1 )
echo Cargando trx_resultado_periodo...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_resultado_periodo.ctl log=logs\trx_resultado_periodo.log bad=logs\trx_resultado_periodo.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_resultado_periodo. Revise logs\trx_resultado_periodo.log & pause & exit /b 1 )
echo Cargando trx_asistencia...
"%IC%\sqlldr.exe" userid="%CONN%" control=ctl\trx_asistencia.ctl log=logs\trx_asistencia.log bad=logs\trx_asistencia.bad silent=header,feedback
if errorlevel 1 ( echo ERROR al cargar trx_asistencia. Revise logs\trx_asistencia.log & pause & exit /b 1 )

echo.
echo Carga terminada. Ahora ejecute Script_Maestro\MASIVA_2_STAGING_Y_ESTRELLA.sql
pause
