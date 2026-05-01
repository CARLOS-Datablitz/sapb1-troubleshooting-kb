# Instalación de Adobe Acrobat Reader (64-bit) en Windows Server 2022

**Fecha:** Abril 2025  
**Sistema:** Windows Server 2022 — 64 bits  
**Versión instalada:** Adobe Acrobat 26.001.21431 (64-bit)

---

## 1. Descarga del instalador

Abrir el navegador en el servidor y acceder a la página oficial de Adobe:

```
https://get.adobe.com/reader/otherversions/
```

Seleccionar:
- **Step 1 — OS:** Windows
- **Step 2 — Language:** English (o Spanish)
- **Step 3 — Version:** Reader DC (64 bit)

Hacer clic en **Download Now**. El archivo descargado será: `Reader_en_install.exe`

> **Nota:** Los enlaces directos al `.exe` en los servidores de Adobe cambian frecuentemente y no son confiables. Siempre descargar desde la página oficial anterior.

---

## 2. Instalación silenciosa

Abrir **PowerShell como Administrador** y ejecutar:

```powershell
Start-Process -FilePath "C:\Users\administrator.RZ\Downloads\Reader_en_install.exe" -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait
```

| Parámetro | Descripción |
|---|---|
| `/sAll` | Modo silencioso total (sin ventanas) |
| `/rs` | Suprime el reinicio automático |
| `/msi EULA_ACCEPT=YES` | Acepta automáticamente los términos de licencia |

La instalación tarda entre 3 y 5 minutos sin mostrar progreso. Al finalizar, puede aparecer un error de `SingleClientServicesUpdater.exe (0xc0000142)` — es normal en Windows Server y no afecta la instalación. Hacer clic en **OK** y luego en **Fertig stellen / Finish**.

---

## 3. Verificación de la instalación

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
Where-Object { $_.DisplayName -like "*Acrobat*" } |
Select-Object DisplayName, DisplayVersion
```

**Resultado esperado:**

```
DisplayName              DisplayVersion
-----------              --------------
Adobe Acrobat (64-bit)   26.001.21431
```

---

## 4. Desactivar el servicio de actualizaciones automáticas

El servicio `AdobeARMservice` causa el error `SingleClientServicesUpdater.exe` en entornos de servidor. Se recomienda desactivarlo:

```powershell
Stop-Service -Name "AdobeARMservice" -ErrorAction SilentlyContinue
Set-Service -Name "AdobeARMservice" -StartupType Disabled
```

---

## Notas adicionales

- **Entornos RDS / Terminal Server:** Adobe Acrobat puede ejecutarse en modo Reader para usuarios sin licencia. Los usuarios free pueden usar las funcionalidades gratuitas sin necesidad de iniciar sesión.
- **Compatibilidad confirmada:** Windows Server 2022 x64, Windows Server 2019 x64, Windows Server 2016 x64.
- El instalador descargado es de tipo **online installer** — requiere conexión a Internet durante la instalación.
