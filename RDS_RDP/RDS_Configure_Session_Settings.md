# Runbook: Sin Conexión a RDS / Terminal Server
**Entorno:** Multi-TS Farm (TS01, TS02, TS03) con RD Gateway y RD Connection Broker  
**Aplica a:** N1 y N2 Support  
**Última actualización:** 2026-03-18

---

## Índice

1. [Síntoma y primer diagnóstico](#1-síntoma-y-primer-diagnóstico)
2. [Árbol de decisión principal](#2-árbol-de-decisión-principal)
3. [Escenario A — TSSDIS detenido](#3-escenario-a--tssdis-detenido)
4. [Escenario B — DWM en crash loop](#4-escenario-b--dwm-en-crash-loop)
5. [Escenario C — RD Gateway caído](#5-escenario-c--rd-gateway-caído)
6. [Escenario D — RD Connection Broker no disponible](#6-escenario-d--rd-connection-broker-no-disponible)
7. [Verificación de salud general del farm](#7-verificación-de-salud-general-del-farm)
8. [Prevención y configuración permanente](#8-prevención-y-configuración-permanente)
9. [Tabla de Event IDs clave](#9-tabla-de-event-ids-clave)
10. [Historial de incidentes documentados](#10-historial-de-incidentes-documentados)

---

## 1. Síntoma y primer diagnóstico

### Síntoma reportado por el usuario
El usuario ve uno de estos mensajes al intentar conectarse vía RDP:

```
"Remote Desktop can't find the computer [nombre]"
"This computer can't connect to the remote computer"
"The connection was denied because the user account is not authorized"
```

### Preguntas clave para N1 (antes de escalar)

| Pregunta | Propósito |
|---|---|
| ¿El problema es solo para ti o para varios usuarios? | Si es solo uno → problema de cuenta/perfil. Si son varios → problema de servidor |
| ¿Afecta a todos los servidores o solo a uno? | Determina si es el Gateway/Broker o un TS específico |
| ¿Cuándo comenzó exactamente? | Correlacionar con updates, nuevos logins, cambios |
| ¿Pueden conectarse a otros clientes hosted? | Si sí → descarta problema de red general |
| ¿Ocurre desde múltiples PCs y múltiples ISPs? | Si sí → descarta problema local del usuario |

---

## 2. Árbol de decisión principal

```
Usuario no puede conectarse al RDS
              │
              ▼
  ¿Afecta a TODOS los usuarios
   de TODOS los servidores?
         │
    ┌────┴────┐
   SÍ        NO
    │         │
    ▼         ▼
Revisar    ¿Afecta solo a
Gateway    un TS específico?
y Broker        │
(ver C, D) ┌───┴───┐
          SÍ       NO
           │        │
           ▼        ▼
       Revisar   Revisar
       ese TS    Broker +
      (ver A, B) TSSDIS en
                 todos los TS
                 (ver A, D)
```

---

## 3. Escenario A — TSSDIS detenido

### ¿Qué es TSSDIS?
El servicio **TSSDIS** (Terminal Services Session Directory Integration Service) es el mensajero entre cada Terminal Server y el RD Connection Broker. Si se detiene, el Broker pierde visibilidad del TS y deja de enviarle usuarios.

### Causa más común
- Windows Update detuvo el servicio sin reiniciar el servidor
- El servicio crasheó sin recovery automático configurado

### Cómo detectarlo

```powershell
# Verificar TSSDIS en un TS específico
Get-Service -ComputerName TS02 -Name "TSSDIS"

# Verificar en todos los TS del farm de un vistazo
$servers = @("TS01","TS02","TS03")
foreach ($ts in $servers) {
    Get-Service -ComputerName $ts -Name "TSSDIS" |
    Select-Object MachineName, Name, Status
}
```

**Resultado problemático:**
```
Status   Name    DisplayName
------   ----    -----------
Stopped  TSSDIS  TS Session Directory/Broker Integration
```

### Solución inmediata

```powershell
# Iniciar el servicio en el TS afectado
Start-Service -ComputerName TS02 -Name "TSSDIS"

# Verificar que arrancó correctamente
Get-Service -ComputerName TS02 -Name "TSSDIS"
```

### Verificar en Event Viewer
- **Log:** System
- **Source:** Service Control Manager
- **Event ID 7036** → "TSSDIS service entered the stopped state"
- **Event ID 7040** → cambio en tipo de inicio del servicio

### Prevención

```powershell
# Configurar recovery automático — 3 intentos con 5 segundos entre cada uno
sc.exe \\TS02 failure TSSDIS reset= 86400 actions= restart/5000/restart/5000/restart/5000

# Verificar que quedó configurado
sc.exe \\TS02 qfailure TSSDIS
```

**Aplicar en todos los TS del farm:**
```powershell
$servers = @("TS01","TS02","TS03")
foreach ($ts in $servers) {
    sc.exe \\$ts failure TSSDIS reset= 86400 actions= restart/5000/restart/5000/restart/5000
}
```

---

## 4. Escenario B — DWM en crash loop

### ¿Qué es DWM?
El **Desktop Window Manager (DWM)** es el componente de Windows responsable de renderizar la interfaz gráfica de cada sesión RDS. En VMs (como Proxmox, VMware, Hyper-V) puede crashear si intenta usar aceleración gráfica por hardware que no existe físicamente.

### Causa más común
- Primer login de un usuario nuevo mientras Windows inicializa perfil + DWM simultáneamente
- VM sin GPU física y sin la política de software rendering configurada
- Perfil de usuario corrupto que impide inicialización correcta de DWM

### Cómo detectarlo

```powershell
# Buscar crashes de DWM en el Event Log
Get-EventLog -ComputerName TS02 -LogName Application `
  -Source "Application Error" `
  -Newest 50 | Where-Object { $_.Message -like "*dwm.exe*" }
```

**En Event Viewer (manualmente):**
- **Log:** Application
- **Event ID 1000** — Application Error, faulting application: `dwm.exe`
- **Log:** Applications and Services Logs → Microsoft → Windows → TerminalServices-RemoteConnectionManager → Operational
- **Event ID 9009** — DWM terminó inesperadamente
- **Event ID 9010** — Sesión RDS terminada por error de DWM

**Patrón típico en logs (crash loop):**
```
1:00:03  Event 1149  → Usuario RBoggs inició sesión
1:00:05  Event 1000  → dwm.exe crashed
1:00:06  Event 1000  → dwm.exe crashed (reinicio #1)
1:00:08  Event 1000  → dwm.exe crashed (reinicio #2)
1:00:09  Event 9009  → DWM terminado, sesión inestable
```

### Solución inmediata

Reiniciar el TS afectado. El loop se interrumpe y el servidor vuelve a aceptar conexiones.

```powershell
# Reinicio controlado con aviso a usuarios conectados (300 segundos = 5 minutos)
shutdown /r /m \\TS02 /t 300 /c "TS02 será reiniciado en 5 minutos por mantenimiento"
```

### Verificar perfil del usuario que causó el incidente

Cuando DWM crashea durante la creación de un perfil, puede quedar una entrada corrupta `.bak` en el registry:

```powershell
# Buscar entradas .bak (perfil corrupto)
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /s | findstr ".bak"

# Verificar que el perfil existe en disco
Get-Item "\\TS02\C$\Users\RBoggs"

# Eliminar perfil corrupto si existe
Get-CimInstance -ComputerName TS02 Win32_UserProfile |
  Where-Object { $_.LocalPath -like "*RBoggs*" } |
  Remove-CimInstance
```

> ⚠️ **Importante:** Pedir al usuario que haga login nuevamente después de limpiar el perfil para que se regenere correctamente.

### Prevención — GPO (aplicar en todos los TS)

```
gpedit.msc (local) o gpmc.msc (dominio)

Computer Configuration
└── Administrative Templates
    └── Windows Components
        └── Remote Desktop Services
            └── Remote Desktop Session Host
                └── Remote Session Environment
```

| Política | Valor |
|---|---|
| Use hardware graphics adapters for all RDS connections | **Disabled** |
| Configure H.264/AVC hardware encoding for RDS connections | **Disabled** |
| Prioritize H.264/AVC 444 graphics mode | **Disabled** |

```powershell
# Aplicar y verificar
gpupdate /force
gpresult /h C:\GPReport.html /f
# Abrir GPReport.html y buscar "Remote Session Environment"
```

### Prevención — Recovery automático de DWM

```powershell
# Configurar en cada TS
sc.exe \\TS02 failure UxSms reset= 86400 actions= restart/5000/restart/5000/restart/5000

# Verificar
sc.exe \\TS02 qfailure UxSms
```

---

## 5. Escenario C — RD Gateway caído

### ¿Qué es el RD Gateway?
Es el punto de entrada externo para conexiones RDP. Todos los usuarios externos pasan por él antes de llegar a los TS. Si cae, **nadie puede conectarse** desde fuera de la red.

### Cómo detectarlo

```powershell
# Verificar servicios del Gateway
Get-Service -ComputerName RDS-GW -Name "TSGateway"
Get-Service -ComputerName RDS-GW -Name "W3SVC"  # IIS — requerido por Gateway

# Test de conectividad al Gateway desde fuera
Test-NetConnection RDS.tingue.PRIVATCLOUD.BIZ -Port 443
```

**Verificar en Event Viewer del Gateway:**
- **Log:** Applications and Services Logs → Microsoft → Windows → TerminalServices-Gateway → Operational
- **Event ID 302** → Gateway no pudo autenticar conexión
- **Event ID 303** → Conexión rechazada por política

### Solución inmediata

```powershell
# Reiniciar servicio de Gateway
Restart-Service -ComputerName RDS-GW -Name "TSGateway"
```

---

## 6. Escenario D — RD Connection Broker no disponible

### ¿Qué es el RD Connection Broker?
Es el componente que balancea y redirige usuarios entre TS01, TS02 y TS03. Si falla, las nuevas conexiones no pueden ser enrutadas aunque los TS estén sanos.

### Cómo detectarlo

```powershell
# Verificar servicio del Broker
Get-Service -ComputerName <FQDN-Broker> -Name "Tssdis"
Get-Service -ComputerName <FQDN-Broker> -Name "ClusSvc"  # Si está en cluster

# Ver estado de los TS desde el Broker
Get-RDSessionHost `
  -CollectionName "<NombreColeccion>" `
  -ConnectionBroker "<FQDN-Broker>"
```

**Estado esperado vs problemático:**

| Campo | Esperado | Problemático |
|---|---|---|
| NewConnectionAllowed | Yes | No |
| SessionHostState | Available | Unavailable |

### Solución inmediata

```powershell
# Reiniciar Broker
Restart-Service -ComputerName <FQDN-Broker> -Name "Tssdis"

# Si un TS específico está marcado como Unavailable, forzar que vuelva al pool
Set-RDSessionHost `
  -SessionHost TS02 `
  -NewConnectionAllowed Yes `
  -ConnectionBroker "<FQDN-Broker>"
```

---

## 7. Verificación de salud general del farm

Ejecutar este script para obtener un snapshot rápido de todos los componentes:

```powershell
$TS = @("TS01","TS02","TS03")
$GW = "RDS-GW"
$Broker = "<FQDN-Broker>"

Write-Host "========== ESTADO DE TERMINAL SERVERS ==========" -ForegroundColor Cyan
foreach ($ts in $TS) {
    Write-Host "`n--- $ts ---" -ForegroundColor Yellow
    
    # Ping
    $ping = Test-Connection $ts -Count 1 -Quiet
    Write-Host "Ping: $(if($ping){'OK'}else{'FALLO'})" -ForegroundColor $(if($ping){'Green'}else{'Red'})
    
    # Puerto RDP
    $rdp = Test-NetConnection $ts -Port 3389 -WarningAction SilentlyContinue
    Write-Host "RDP (3389): $(if($rdp.TcpTestSucceeded){'OK'}else{'FALLO'})" -ForegroundColor $(if($rdp.TcpTestSucceeded){'Green'}else{'Red'})
    
    # Servicios críticos
    $services = @("TermService","TSSDIS","UxSms")
    foreach ($svc in $services) {
        try {
            $s = Get-Service -ComputerName $ts -Name $svc -ErrorAction Stop
            Write-Host "$svc : $($s.Status)" -ForegroundColor $(if($s.Status -eq 'Running'){'Green'}else{'Red'})
        } catch {
            Write-Host "$svc : No accesible" -ForegroundColor Red
        }
    }
}

Write-Host "`n========== ESTADO DEL GATEWAY ==========" -ForegroundColor Cyan
$gw443 = Test-NetConnection $GW -Port 443 -WarningAction SilentlyContinue
Write-Host "Gateway HTTPS (443): $(if($gw443.TcpTestSucceeded){'OK'}else{'FALLO'})" -ForegroundColor $(if($gw443.TcpTestSucceeded){'Green'}else{'Red'})
```

---

## 8. Prevención y configuración permanente

### Para todos los Terminal Servers

| Acción | Comando/Método | Prioridad |
|---|---|---|
| Recovery automático de TSSDIS | `sc.exe failure TSSDIS ...` | 🔴 Alta |
| Recovery automático de DWM (UxSms) | `sc.exe failure UxSms ...` | 🔴 Alta |
| Deshabilitar HW Graphics via GPO | gpedit.msc / gpmc.msc | 🔴 Alta |
| Windows Update con maintenance window y reinicio controlado | Configurar en WSUS o política | 🟡 Media |
| Monitoreo de Event IDs críticos | Task Scheduler / SIEM | 🟡 Media |
| Pre-crear perfiles para usuarios nuevos | Default User profile template | 🟢 Baja |

### Configurar alertas por Event ID críticos

```powershell
# En cada TS, crear tarea que alerte si DWM crashea
$filter = @{
    LogName = 'Application'
    Id = 1000
    ProviderName = 'Application Error'
}

# Registrar via Event Viewer → Right-click Event ID 1000 → Attach Task to this Event
# Acción recomendada: ejecutar script que envíe email o cree ticket automático
```

---

## 9. Tabla de Event IDs clave

| Event ID | Log | Source | Significado |
|---|---|---|---|
| **1000** | Application | Application Error | Crash de aplicación (dwm.exe, etc.) |
| **1001** | Application | Windows Error Reporting | Reporte post-crash |
| **7036** | System | Service Control Manager | Servicio cambió de estado (started/stopped) |
| **7040** | System | Service Control Manager | Tipo de inicio de servicio modificado |
| **9009** | TerminalServices-RemoteConnectionManager | Microsoft-Windows | DWM terminó inesperadamente |
| **9010** | TerminalServices-RemoteConnectionManager | Microsoft-Windows | Sesión RDS terminada por error DWM |
| **1149** | TerminalServices-RemoteConnectionManager | Microsoft-Windows | Usuario autenticado correctamente |
| **302** | TerminalServices-Gateway | Microsoft-Windows | Fallo de autenticación en Gateway |
| **303** | TerminalServices-Gateway | Microsoft-Windows | Conexión rechazada por política |

---

## 10. Historial de incidentes documentados

### Incidente 001 — TSSDIS detenido por Windows Update
- **Fecha:** Reciente (hace unos días)
- **Cliente:** [Cliente anterior]
- **Síntoma:** Sin conexión a RDS para todos los usuarios
- **Causa raíz:** Windows Update detuvo el servicio TSSDIS sin reiniciar el servidor
- **Solución aplicada:** Inicio manual del servicio TSSDIS
- **Prevención aplicada:** Recovery automático configurado en TSSDIS
- **Escenario:** A

---

### Incidente 002 — DWM en crash loop por nuevo usuario
- **Fecha:** 2026-03-18
- **Cliente:** Tingue Brown
- **Síntoma:** Sin conexión a TS02, TS01 y TS03 funcionando normalmente
- **Causa raíz:** Primer login del usuario RBoggs provocó crash de DWM en loop. TS02 corre en VM Proxmox sin GPU física y sin política de software rendering configurada.
- **Solución aplicada:** Reinicio de TS02
- **Prevención aplicada:** GPO para deshabilitar hardware graphics en RDS + recovery automático de DWM (UxSms)
- **Escenario:** B

---

*Documento mantenido por el equipo de soporte. Agregar nuevos incidentes en la sección 10 con cada caso resuelto.*
