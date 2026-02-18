Filtrar en PowerShell del AD:
=========================================================================
#Esto te da una lista de usuarios habilitados que han iniciado sesión en los últimos 90 días:

$cutoff = (Get-Date).AddDays(-90)

$usuarios = Get-ADUser -Filter * -Properties LastLogonTimeStamp, Enabled | Where-Object {
    $_.Enabled -eq $true -and
    $_.LastLogonTimeStamp -ne $null -and
    [DateTime]::FromFileTime($_.LastLogonTimeStamp) -gt $cutoff
} | Select-Object Name, SamAccountName, @{Name="LastLogon";Expression={
    [DateTime]::FromFileTime($_.LastLogonTimeStamp)
}} | Sort-Object LastLogon -Descending

# Muestra la lista de usuarios
$usuarios

# Muestra el total de usuarios al final
Write-Host "Total de usuarios habilitados que iniciaron sesión en los últimos 90 días: $($usuarios.Count)" -ForegroundColor Cyan

=========================================================================
Esto te da el número(solo cantidad) de usuarios habilitados en el AD:
Get-ADUser -Filter {Enabled -eq $true} | Measure-Object

******** Revisa usuarios sin logon en +90 días para limpiar cuentas obsoletas:

Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90.00:00:00

***** Script para listar y contar usuarios activos por logon reciente:

$days = 30
$cutoff = (Get-Date).AddDays(-$days)

$users = Get-ADUser -Filter * -Properties LastLogonTimeStamp, Enabled | Where-Object {
    $_.Enabled -eq $true -and `
    ($_.LastLogonTimeStamp -ne $null) -and `
    ([DateTime]::FromFileTime($_.LastLogonTimeStamp) -gt $cutoff)
}

$users.Count

******** Para consultar el último logon:
Get-ADUser -Identity "user11" -Properties LastLogonDate, LastLogon | 
    Select-Object Name, SamAccountName, LastLogonDate, LastLogon
*** Ver la fecha de creación:
Get-ADUser -Identity "nombreUsuario" -Properties whenCreated | 
    Select-Object Name, SamAccountName, whenCreated


----- BUSCAR LAST LOGON DE UN USUARIO EN PARTICULAR ------

Get-ADUser -Identity "lissa.nelson" -Properties LastLogonDate, LastLogon | Select-Object Name, SamAccountName, LastLogonDate, LastLogon
Get-ADUser -Identity "rolandoarmien" -Properties LastLogonDate, LastLogon | Select-Object Name, SamAccountName, LastLogonDate, LastLogon

VER SI ESTA ENABLE:
Get-ADUser -Identity "leo.chavez" -Properties Enabled | Select-Object Name, Enabled

----- ALLPRO muestra usuarios habilitados y deshabilitados en una OU------

# OU específica
$ou = "OU=Tampa,OU=Allpro OU,DC=Allpro,DC=local"

# Obtener usuarios de la OU 'Tampa'
$usuarios = Get-ADUser -SearchBase $ou -Filter * -Properties Enabled | Where-Object { $_.ObjectClass -eq 'user' }

# Contar habilitados y deshabilitados 
$habilitados = ($usuarios | Where-Object { $_.Enabled -eq $true }).Count
$deshabilitados = ($usuarios | Where-Object { $_.Enabled -eq $false }).Count

# Mostrar resultados
Write-Host "Usuarios habilitados en OU 'Tampa': $habilitados" -ForegroundColor Green
Write-Host "Usuarios deshabilitados en OU 'Tampa': $deshabilitados" -ForegroundColor Red
Write-Host "Total de usuarios en OU 'Tampa': $($habilitados + $deshabilitados)" -ForegroundColor Cyan

==============  Lista los usuarios habilitados y deshabilitados ===============


$usuarios = Get-ADUser -Filter * -Properties Enabled |
Select-Object `
    Name,
    SamAccountName,
    @{Name="Estado"; Expression={
        if ($_.Enabled) { "Habilitado" } else { "Deshabilitado" }
    }} |
Sort-Object Name

# Mostrar la lista de usuarios
$usuarios | Format-Table -AutoSize

# Calcular totales
$habilitados   = ($usuarios | Where-Object { $_.Estado -eq "Habilitado"   }).Count
$deshabilitados = ($usuarios | Where-Object { $_.Estado -eq "Deshabilitado" }).Count
$total          = $usuarios.Count

# Mostrar resumen
Write-Host ""
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "  RESUMEN DE USUARIOS EN AD"     -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "  Habilitados  : $habilitados"   -ForegroundColor Green
Write-Host "  Deshabilitados: $deshabilitados" -ForegroundColor Red
Write-Host "  Total         : $total"         -ForegroundColor White
Write-Host "===============================" -ForegroundColor Cyan


======================= DURACION DE PASSWORDS=====================================
PS C:\Windows\system32> Get-ADDefaultDomainPasswordPolicy


================================================
AD/DC:
- 12 usuarios activos(user01 al user12, aunque los usuarios user11 y user12, nunca han iniciado sesión).
- Usuario quiere 03 usuarios más, con esto serian 15 en total.

RDS: 
- Licencias disponibles 03
- Recursos: RAM 22GB(uso 75%, para 15 usuarios se necesita 36, 38 GB), CPU: 12(para 15 usuarios se necesita 16 cores), HD: 100GB
================================================