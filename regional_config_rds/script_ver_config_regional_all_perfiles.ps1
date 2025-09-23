# Recorrer todos los perfiles en C:\Users y leer separador decimal y de miles

$profiles = Get-ChildItem C:\Users -Directory | Where-Object {
    Test-Path "$($_.FullName)\NTUSER.DAT"
}

foreach ($profile in $profiles) {
    $ntuser = "$($profile.FullName)\NTUSER.DAT"
    $mountPoint = "HKU\TempUser"

    try {
        # Cargar el hive del perfil
        reg load $mountPoint $ntuser | Out-Null

        # Leer claves de configuración regional
        $intl = Get-ItemProperty "Registry::$mountPoint\Control Panel\International" -ErrorAction Stop

        Write-Host "---------------------------------------------"
        Write-Host "Usuario (perfil): $($profile.Name)"
        Write-Host "Separador decimal : $($intl.sDecimal)"
        Write-Host "Separador de miles: $($intl.sThousand)"
    }
    catch {
        Write-Host "⚠️  No se pudo leer el perfil: $($profile.Name)"
    }
    finally {
        # Descargar el hive para evitar bloqueo
        reg unload $mountPoint | Out-Null
    }
}
