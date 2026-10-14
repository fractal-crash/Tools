<#
===============================================================================
Nombre      : Auditoria-BloqueosAD.ps1
Autor       : José Luis Rodríguez García
Puesto      : Analista Administrador de Sistemas
Fecha       : 14/10/2026
Versión     : 2.0

Descripción :
    Obtiene todos los eventos de bloqueo de cuentas de Active Directory
    (Event ID 4740) registrados en las últimas 24 horas e identifica
    los equipos origen responsables de los bloqueos.

Funcionalidad :
    - Detecta automáticamente usuarios bloqueados.
    - Cuenta el número de bloqueos por usuario.
    - Identifica los equipos de origen.
    - Muestra la fecha del último bloqueo.
    - Ordena los resultados por cantidad de incidencias.

===============================================================================
#>

# Intervalo de búsqueda
$Desde = (Get-Date).AddDays(-1)

# Obtener eventos de bloqueo de cuentas
$Eventos = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    ID        = 4740
    StartTime = $Desde
}

# Agrupar por usuario bloqueado
$Resultado = $Eventos |
    Group-Object { $_.Properties[0].Value } |
    ForEach-Object {

        $Usuario = $_.Name
        $Bloqueos = $_.Group

        [PSCustomObject]@{
            Usuario          = $Usuario
            CantidadBloqueos = $Bloqueos.Count

            EquiposOrigen = (
                $Bloqueos |
                ForEach-Object { $_.Properties[1].Value } |
                Sort-Object -Unique
            ) -join ", "

            UltimoBloqueo = (
                $Bloqueos |
                Sort-Object TimeCreated -Descending |
                Select-Object -First 1 -ExpandProperty TimeCreated
            )
        }
    }

# Mostrar resultados
$Resultado |
    Sort-Object CantidadBloqueos -Descending |
    Format-Table Usuario, CantidadBloqueos, UltimoBloqueo, EquiposOrigen -AutoSize