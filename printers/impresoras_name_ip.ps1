# Script Completo para Detectar Todas las Impresoras con IP
Write-Host "=== DETECTOR COMPLETO DE IMPRESORAS ===" -ForegroundColor Green
Write-Host "Buscando todas las impresoras..." -ForegroundColor Yellow

$resultados = @()

# Método 1: Usar WMI para obtener todas las impresoras
$impresorasWMI = Get-WmiObject -Class Win32_Printer

foreach ($printer in $impresorasWMI) {
    $ip = "No disponible"
    $tipo = "Desconocido"
    $puerto = $printer.PortName
    
    # Determinar tipo de impresora
    if ($printer.Local) {
        $tipo = "Local"
    } elseif ($printer.Network) {
        $tipo = "Red"
    } else {
        $tipo = "Otro"
    }
    
    # Método A: Detectar IP directa en el nombre del puerto
    if ($puerto -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
        $ip = $matches[1]
        $tipo = "TCP/IP Directo"
    }
    # Método B: Detectar IP en URLs (IPP/HTTP)
    elseif ($puerto -match 'https?://(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
        $ip = $matches[1]
        $tipo = "IPP/HTTP"
    }
    # Método C: Buscar en puertos TCP/IP configurados
    else {
        $portInfo = Get-WmiObject -Class Win32_TCPIPPrinterPort -Filter "Name='$puerto'" -ErrorAction SilentlyContinue
        if ($portInfo -and $portInfo.HostAddress) {
            $ip = $portInfo.HostAddress
            $tipo = "TCP/IP Configurado"
        }
        # Método D: Buscar en el registro de Windows
        else {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports\$puerto"
            if (Test-Path $regPath) {
                $regIP = Get-ItemProperty -Path $regPath -Name "HostName" -ErrorAction SilentlyContinue
                if ($regIP.HostName) {
                    $ip = $regIP.HostName
                    $tipo = "TCP/IP Registro"
                }
            }
        }
    }
    
    # Método E: Extraer IP del campo Location si existe
    if ($ip -eq "No disponible" -and $printer.Location -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
        $ip = $matches[1]
        $tipo = "IPP/Location"
    }
    
    # Método F: Usar CIM para más información
    try {
        $cimPrinter = Get-CimInstance -ClassName Win32_Printer -Filter "Name='$($printer.Name)'" -ErrorAction SilentlyContinue
        if ($cimPrinter -and $cimPrinter.PortName -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
            $ip = $matches[1]
            $tipo = "CIM Detection"
        }
    } catch { }

    $resultados += [PSCustomObject]@{
        Nombre    = $printer.Name
        IP        = $ip
        Puerto    = $puerto
        Tipo      = $tipo
        Estado    = switch ($printer.PrinterStatus) {
            1 { "Otro" }
            2 { "Desconocido" }
            3 { "Inactiva" }
            4 { "Activando" }
            5 { "Imprimiendo" }
            6 { "Calentando" }
            7 { "Detenida" }
            default { "Desconocido ($($printer.PrinterStatus))" }
        }
        Compartida = if ($printer.Shared) { "Sí" } else { "No" }
        Location  = $printer.Location
        Driver    = $printer.DriverName
    }
}

# Método 2: Usar cmdlets modernos de PowerShell como respaldo
$impresorasModernas = Get-Printer -ErrorAction SilentlyContinue
foreach ($printer in $impresorasModernas) {
    # Verificar si ya tenemos esta impresora en los resultados
    $existe = $resultados | Where-Object { $_.Nombre -eq $printer.Name }
    
    if (-not $existe) {
        $ip = "No disponible"
        $tipo = "Modern API"
        
        # Intentar obtener IP del puerto moderno
        try {
            $portInfo = Get-PrinterPort -Name $printer.PortName -ErrorAction SilentlyContinue
            if ($portInfo.PrinterHostAddress) {
                $ip = $portInfo.PrinterHostAddress
                $tipo = "TCP/IP Moderno"
            }
        } catch { }
        
        $resultados += [PSCustomObject]@{
            Nombre    = $printer.Name
            IP        = $ip
            Puerto    = $printer.PortName
            Tipo      = $tipo
            Estado    = "Desconocido"
            Compartida = if ($printer.Shared) { "Sí" } else { "No" }
            Location  = ""
            Driver    = $printer.DriverName
        }
    }
}

# Mostrar resultados
Write-Host "`n=== RESULTADOS ENCONTRADOS ===" -ForegroundColor Cyan
Write-Host "Total de impresoras detectadas: $($resultados.Count)" -ForegroundColor White

if ($resultados.Count -eq 0) {
    Write-Host "No se encontraron impresoras." -ForegroundColor Red
} else {
    $resultados | Format-Table -AutoSize -Property Nombre, IP, Tipo, Estado, Compartida, Puerto
    
    # Mostrar resumen por tipos
    Write-Host "`n=== RESUMEN POR TIPOS ===" -ForegroundColor Cyan
    $resultados | Group-Object Tipo | Format-Table -AutoSize
}

# Información adicional para impresoras problemáticas
Write-Host "`n=== IMPRESORAS SIN IP DETECTADA ===" -ForegroundColor Yellow
$sinIP = $resultados | Where-Object { $_.IP -eq "No disponible" }
if ($sinIP) {
    $sinIP | Format-Table -AutoSize -Property Nombre, Tipo, Puerto, Location
    Write-Host "`nSugerencias para estas impresoras:" -ForegroundColor Magenta
    Write-Host "- Verificar configuración manualmente en 'Administración de impresoras'" -ForegroundColor Gray
    Write-Host "- Pueden ser impresoras locales (LPT, USB) o con configuración especial" -ForegroundColor Gray
} else {
    Write-Host "¡Todas las impresoras tienen IP detectada!" -ForegroundColor Green
}

# Comando para verificar una impresora específica
Write-Host "`n=== COMANDOS ÚTILES ===" -ForegroundColor Cyan
Write-Host "Para ver detalles de una impresora específica:" -ForegroundColor White
Write-Host "  Get-WmiObject -Class Win32_Printer -Filter ""Name='NombreImpresora'""" -ForegroundColor Gray
Write-Host "  Get-Printer -Name ""NombreImpresora""" -ForegroundColor Gray