Muestra todos los usuarios(habilitados y deshabilitados), en el AD:

=========================================================
# Script para listar usuarios habilitados y deshabilitados en AD
# Mostrar solo nombre, cuenta y estado

# Obtener todos los usuarios con la propiedad Enabled
$usuarios = Get-ADUser -Filter * -Properties Enabled | 
    Select-Object Name, SamAccountName, Enabled, @{Name="Estado";Expression={
        if($_.Enabled -eq $true) { "Habilitado" } else { "Deshabilitado" }
    }} | 
    Sort-Object Estado, Name

# Separar usuarios habilitados y deshabilitados
$usuariosHabilitados = $usuarios | Where-Object { $_.Enabled -eq $true }
$usuariosDeshabilitados = $usuarios | Where-Object { $_.Enabled -eq $false }

# Mostrar usuarios habilitados
Write-Host "`n=== USUARIOS HABILITADOS ===" -ForegroundColor Green
$usuariosHabilitados | Format-Table -AutoSize -Property Name, SamAccountName, Estado

# Mostrar usuarios deshabilitados
Write-Host "`n=== USUARIOS DESHABILITADOS ===" -ForegroundColor Red
$usuariosDeshabilitados | Format-Table -AutoSize -Property Name, SamAccountName, Estado

# Mostrar totales
Write-Host "`n=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Total usuarios habilitados: $($usuariosHabilitados.Count)" -ForegroundColor Green
Write-Host "Total usuarios deshabilitados: $($usuariosDeshabilitados.Count)" -ForegroundColor Red
Write-Host "Total general de usuarios: $($usuarios.Count)" -ForegroundColor Cyan


=========================================================