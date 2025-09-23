# Script: Verificar-FormatoRegional.ps1
# Muestra separador decimal y de miles para todos los perfiles de usuario

$profiles = Get-ChildItem "C:\Users" -Directory | Where-Object {
    Test-Path "$($_.FullName)\NTUSER.DAT"
}

foreach ($profile in $profiles) {
    $userProfile = "$($profile.FullName)\NTUSER.DAT"

    try {
        # Cargar el hive del usuario
        reg load HKU\TempUser $userProfile | Out-Null

        # Leer valores regionales
        $intl = Get-ItemProperty "Registry::HKU\TempUser\Control Panel\International"
        $decimal = $intl.sDecimal
        $thousand = $intl.sThousand

        Write-Output "---------------------------------------------"
        Write-Output "Usuario (perfil): $($profile.Name)"
        Write-Output "Separador decimal : $decimal"
        Write-Output "Separador de miles: $thousand"

        # Descargar hive
        reg unload HKU\TempUser | Out-Null
    }
    catch {
        Write-Output "---------------------------------------------"
        Write-Output "Usuario (perfil): $($profile.Name)"
        Write-Output "⚠️ No se pudo leer la configuración."
    }
}
