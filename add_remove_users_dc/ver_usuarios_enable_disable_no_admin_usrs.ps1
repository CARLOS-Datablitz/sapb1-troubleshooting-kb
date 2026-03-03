# Script para listar usuarios habilitados y deshabilitados en AD
# Mostrar solo nombre, cuenta y estado

# Obtener todos los usuarios con la propiedad Enabled
$usuarios = Get-ADUser -Filter * -Properties Enabled | 
    Select-Object Name, SamAccountName, Enabled, @{Name="Estado";Expression={
        if($_.Enabled -eq $true) { "Habilitado" } else { "Deshabilitado" }
    }} | 
    Sort-Object Estado, Name

# Separar usuarios habilitados y deshabilitados
$usuariosHabilitados    = $usuarios | Where-Object { $_.Enabled -eq $true }
$usuariosDeshabilitados = $usuarios | Where-Object { $_.Enabled -eq $false }

# Mostrar usuarios habilitados
Write-Host "`n=== USUARIOS HABILITADOS ===" -ForegroundColor Green
$usuariosHabilitados | Format-Table -AutoSize -Property Name, SamAccountName, Estado

# Mostrar usuarios deshabilitados
Write-Host "`n=== USUARIOS DESHABILITADOS ===" -ForegroundColor Red
$usuariosDeshabilitados | Format-Table -AutoSize -Property Name, SamAccountName, Estado

# ============================================================
# APARTADO: Usuarios críticos / privilegiados
# ============================================================
$cuentasCriticas = @("administrator", "guest", "krbtgt", "sshd", "test")

$usuariosCriticos = $usuarios | Where-Object {
    $sam    = $_.SamAccountName.ToLower()
    $nombre = $_.Name.ToLower()
    # Coincide si es una cuenta crítica exacta O si contiene la palabra "admin"
    ($cuentasCriticas -contains $sam) -or
    ($sam    -like "*admin*")         -or
    ($nombre -like "*admin*")
}

Write-Host "`n=== USUARIOS CRÍTICOS / PRIVILEGIADOS ===" -ForegroundColor Yellow

if ($usuariosCriticos.Count -gt 0) {
    foreach ($u in $usuariosCriticos) {
        $color = if ($u.Enabled) { "Green" } else { "Red" }
        Write-Host ("  [{0,-30}] SamAccount: {1,-25} Estado: {2}" -f `
            $u.Name, $u.SamAccountName, $u.Estado) -ForegroundColor $color
    }
} else {
    Write-Host "  No se encontraron usuarios críticos." -ForegroundColor Gray
}

# Mostrar totales
Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "  Total usuarios habilitados   : $($usuariosHabilitados.Count)"    -ForegroundColor Green
Write-Host "  Total usuarios deshabilitados: $($usuariosDeshabilitados.Count)"  -ForegroundColor Red
Write-Host "  Total general de usuarios    : $($usuarios.Count)"                -ForegroundColor Cyan
Write-Host "  Usuarios críticos encontrados: $($usuariosCriticos.Count)"        -ForegroundColor Yellow