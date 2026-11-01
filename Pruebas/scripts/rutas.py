"""Ubicación de cada archivo del proyecto. ROOT es la carpeta que contiene General/, Staging/, etc."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
RUTA={
 'Acerca_del_modelo.md':'General','DER.mmd':'General',
 'Diccionario_Datos_Educacion.md':'General','Diccionario_KPI_Educacion.md':'General',
 'modelo_logico.json':'General','SCRIPT_BASE.sql':'General',
 'CREACION_STAGING.sql':'Staging','07_CARGADOR_STAGING.sql':'Validacion','DATOS_FICTICIOS.sql':'Script_Maestro/datos_ficticios',
 'Diccionario_Staging.md':'Staging','modelo_staging.json':'Staging',
 'VALIDAR_MODELOS.sql':'Validacion','INSTALAR_VALIDACIONES.sql':'Validacion','Reglas_por_tabla.md':'Validacion',
 'PRUEBAS_ORACLE.sql':'Pruebas','PRUEBAS_NEGATIVAS_ORACLE.sql':'Pruebas','CARGA_Y_PRUEBA_VALIDACIONES.sql':'Pruebas',
 'datos_sinteticos.json':'Pruebas/datos','reglas_validacion.json':'Pruebas/datos','casos_invalidos.json':'Pruebas/datos',
 'resultado_ultima_revision.json':'Pruebas/resultados','tres_revisiones.json':'Pruebas/resultados',
}
def ruta(nombre,root=ROOT):
    if nombre.startswith('revision_') and nombre.endswith('.log'):return root/'Pruebas/resultados'/nombre
    return root/RUTA[nombre]/nombre

def archivos_validaciones(root=ROOT):
    """Los archivos de Validacion/ que instala INSTALAR_VALIDACIONES.sql, en orden (00 a 10)."""
    return sorted((root/'Validacion').glob('[0-9][0-9]_*.sql'))

def texto_validaciones(root=ROOT):
    """Todas las validaciones como un solo texto, en orden de instalación."""
    return '\n'.join(p.read_text() for p in archivos_validaciones(root))

def texto_cargador(root=ROOT):
    """Código de PR_CARGAR_STAGING (el cargador de staging), sin los triggers que lo acompañan."""
    t=(root/'Validacion/07_CARGADOR_STAGING.sql').read_text()
    return t[t.index('CREATE OR REPLACE PROCEDURE pr_cargar_staging'):t.index('\n/\n',t.index('CREATE OR REPLACE PROCEDURE pr_cargar_staging'))+3]
