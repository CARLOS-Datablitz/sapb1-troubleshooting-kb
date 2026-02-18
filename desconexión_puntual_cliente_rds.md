# RFO – Desconexión Puntual Cliente RDS
**Cliente:** xploranfr  
**Usuario afectado:** xploranfr\xplora1  
**Servidor RDS:** rds.xploranfr.privatcloud.biz  
**Fecha del incidente:** 08/02/2026  
**Hora del reporte:** 4:00 PM (hora local, UTC-5)  
**Hora del error (imagen cliente):** 20:57:14 UTC = 15:57 hora local  
**Investigado por:** xploranfr\administrator  

---

## 1. Contexto del Incidente

El cliente reportó que no podía conectarse al entorno de trabajo a través de RDS. La imagen enviada mostraba un error RDP con los siguientes códigos:

- **Código de error:** 0x3  
- **Código de error extendido:** 0x7  

Estos códigos indican que el cliente no pudo alcanzar el servidor remoto al momento del intento de conexión.

El ambiente utiliza:
- Windows Server 2019 con rol RDS
- SAP Business One como aplicación principal
- SAP HANA como base de datos (servidor externo)
- Conexión del usuario a través de **VPN**

---

## 2. Pasos de Investigación

### Paso 1 – Verificar zona horaria del servidor

**Comando ejecutado:**
```powershell
Get-TimeZone
```

**Salida:**
```
Id                         : SA Pacific Standard Time
DisplayName                : (UTC-05:00) Bogota, Lima, Quito, Rio Branco
BaseUtcOffset              : -05:00:00
SupportsDaylightSavingTime : False
```

**¿Qué hace este comando?**  
Obtiene la zona horaria configurada en el servidor. Es fundamental para correlacionar correctamente los timestamps del log de eventos con la hora local del incidente.

**Conclusión:** El servidor está en UTC-5. El error reportado a las 20:57 UTC equivale a las **15:57 hora local**.

---

### Paso 2 – Verificar si el servidor fue reiniciado

**Comando ejecutado:**
```powershell
(Get-CimInstance Win32_OperatingSystem).LastBootUpTime
```

**Salida:**
```
Wednesday, February 11, 2026 3:55:08 AM
```

**¿Qué hace este comando?**  
Consulta la fecha y hora del último arranque del sistema operativo. Sirve para determinar si el servidor se reinició durante o cerca del incidente, lo cual podría explicar las desconexiones.

**Conclusión:** El servidor lleva más de 5 meses sin reiniciarse (arrancó el 11/02/2026). No hubo reboot durante el incidente. Se descarta crash o reinicio como causa.

---

### Paso 3 – Verificar rango de eventos disponibles en el log System

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName System -Oldest -MaxEvents 1 | Select-Object TimeCreated
Get-WinEvent -LogName System -MaxEvents 1 | Select-Object TimeCreated
```

**Salida:**
```
TimeCreated
-----------
10/15/2025 3:52:31 AM   ← Evento más antiguo
2/17/2026 5:47:18 PM    ← Evento más reciente
```

**¿Qué hace este comando?**  
Consulta el primer y último evento registrado en el log System para confirmar que el rango de fechas cubre el día del incidente (08/02/2026).

**Conclusión:** El log cubre el período del incidente. Se puede continuar la investigación.

---

### Paso 4 – Revisar todos los eventos del día del incidente en el log System

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName System | Where-Object {
    $_.TimeCreated -ge "2026-02-08 00:00:00" -and
    $_.TimeCreated -le "2026-02-08 23:59:59"
} | Select-Object TimeCreated, Id, LevelDisplayName | Sort-Object TimeCreated | Format-Table -AutoSize
```

**¿Qué hace este comando?**  
Filtra todos los eventos del log System correspondientes al día del incidente, ordenados cronológicamente. Permite identificar actividad inusual, gaps de tiempo o patrones de errores a lo largo del día.

**Hallazgos relevantes:**

| Hora | Event ID | Nivel | Descripción |
|------|----------|-------|-------------|
| 10:11 AM | 1801 | Error | Error registrado |
| 10:33 AM | 2004 | Warning | Warning de recursos |
| 11:17 AM | 7034 | Error | Servicio terminado inesperadamente |
| 2:11 PM | 7034 | Error | Servicio terminado inesperadamente |
| 2:12 PM | 7034 | Error | Servicio terminado inesperadamente |
| 2:16 PM | 7034 | Error | Servicio terminado inesperadamente |
| 8:08 PM | 137, 140, 50 | Error/Warning | Ráfaga de errores de disco/almacenamiento |

---

### Paso 5 – Obtener detalle de los errores 7034 en el rango del incidente

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName System | Where-Object {
    $_.TimeCreated -ge "2026-02-08 14:00:00" -and
    $_.TimeCreated -le "2026-02-08 16:30:00" -and
    $_.Id -eq 7034
} | Select-Object TimeCreated, Id, Message | Format-List
```

**Salida:**
```
TimeCreated : 2/8/2026 2:16:15 PM
Id          : 7034
Message     : The Windows Internal Database service terminated unexpectedly. It has done this 1 time(s).

TimeCreated : 2/8/2026 2:12:37 PM
Id          : 7034
Message     : The SQL Server (MSSQLSERVER) service terminated unexpectedly. It has done this 1 time(s).

TimeCreated : 2/8/2026 2:11:11 PM
Id          : 7034
Message     : The XPS : Extractor FE service terminated unexpectedly. It has done this 1 time(s).
```

**¿Qué hace este comando?**  
Filtra específicamente los eventos con ID 7034 (servicio terminado inesperadamente) en el rango horario del incidente, mostrando el detalle del mensaje para identificar qué servicios cayeron.

**Hallazgos:**
- **2:11 PM** – Cae el servicio **XPS : Extractor FE**
- **2:12 PM** – Cae **SQL Server (MSSQLSERVER)** (instancia local del sistema, no la BD principal)
- **2:16 PM** – Cae **Windows Internal Database**

> **Nota:** El ambiente usa SAP HANA como base de datos principal en un servidor externo. El SQL Server (MSSQLSERVER) que aparece es una instancia local utilizada por componentes del sistema operativo o aplicaciones secundarias.

---

### Paso 6 – Revisar el log Application para identificar causa de las caídas

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName Application | Where-Object {
    $_.TimeCreated -ge "2026-02-08 13:45:00" -and
    $_.TimeCreated -le "2026-02-08 14:20:00" -and
    $_.LevelDisplayName -in @("Critical","Error","Warning")
} | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-List
```

**Salida:**
```
TimeCreated      : 2/8/2026 2:18:53 PM
Id               : 1002
Message          : The program hdbstudio.exe stopped interacting with Windows and was closed.
                   Hang type: Unknown
                   Application Path: C:\Program Files\sap\hdbstudio\hdbstudio.exe

TimeCreated      : 2/8/2026 2:12:23 PM
Id               : 1002
Message          : The program hdbstudio.exe stopped interacting with Windows and was closed.
                   Hang type: Unknown
                   Application Path: C:\Program Files\sap\hdbstudio\hdbstudio.exe

TimeCreated      : 2/8/2026 2:11:35 PM
Id               : 1002
Message          : The program SAP Business One.exe stopped interacting with Windows and was closed.
                   Hang type: Top level window is idle
                   Application Path: C:\Program Files\sap\SAP Business One\SAP Business One.exe
```

**¿Qué hace este comando?**  
Consulta el log de Application (donde las aplicaciones registran sus propios eventos) filtrando por errores y warnings. Permite identificar qué aplicaciones fallaron y en qué orden, proporcionando contexto sobre la causa raíz.

**Hallazgos – Secuencia de caída:**

| Hora | Aplicación | Evento |
|------|-----------|--------|
| 2:11 PM | SAP Business One.exe | Se colgó ("Top level window is idle") y fue cerrado por Windows |
| 2:11 PM | XPS : Extractor FE | Servicio cae (dependiente de SAP B1) |
| 2:12 PM | hdbstudio.exe | Se colgó ("Unknown hang") y fue cerrado por Windows |
| 2:12 PM | SQL Server (MSSQLSERVER) | Servicio cae en cascada |
| 2:16 PM | Windows Internal Database | Servicio cae en cascada |
| 2:18 PM | hdbstudio.exe | Segundo cuelgue registrado |

---

### Paso 7 – Revisar logs de sesiones RDS (LocalSessionManager)

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" | Where-Object {
    $_.TimeCreated -ge "2026-02-08 00:00:00" -and
    $_.TimeCreated -le "2026-02-08 23:59:59"
} | Select-Object TimeCreated, Id, Message | Format-List
```

**¿Qué hace este comando?**  
Consulta el log operacional del servicio de sesiones locales de RDS. Registra eventos de logon, logoff, desconexión y reconexión de usuarios, incluyendo el reason code de cada desconexión.

**Salida relevante:**

| Hora | Event ID | Descripción |
|------|----------|-------------|
| 10:28 AM | 21 | xplora1 inicia sesión (Session ID: 15) |
| 1:13 PM | 24/40 | **Desconexión inesperada** – reason code 3489660929 |
| 1:52 PM | 25 | Reconexión exitosa |
| 1:56 PM | 24/40 | **Desconexión inesperada** – reason code 3489660929 |
| 2:02 PM | 25 | Reconexión exitosa |
| 2:44 PM | 24/40 | **Desconexión inesperada** – reason code 3489660929 |
| 4:44 PM | 23 | Logoff final (usuario no pudo reconectarse → reporta el problema) |

**Análisis del reason code:**  
El código **3489660929 (0xD0000009)** corresponde a: **"The connection was lost due to a network error"**. Indica que la desconexión fue causada por una interrupción de red entre el cliente y el servidor, no por un fallo interno del servidor.

**Dato clave:** Solo la sesión 15 (xplora1) fue afectada. Ningún otro usuario presentó desconexiones en los mismos momentos. Esto descarta un problema del servidor como causa principal.

---

### Paso 8 – Confirmar que no hubo errores de red en el servidor

**Comando ejecutado:**
```powershell
Get-WinEvent -LogName System | Where-Object {
    $_.TimeCreated -ge "2026-02-08 13:00:00" -and
    $_.TimeCreated -le "2026-02-08 15:00:00" -and
    $_.ProviderName -in @("Tcpip", "Dhcp-Client", "Netwtw08", "e1iexpress", "vmxnet3")
} | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message | Format-List
```

**Salida:** Sin resultados.

**¿Qué hace este comando?**  
Busca eventos generados por los proveedores del stack de red de Windows (TCP/IP, DHCP, drivers de adaptador de red). Si el servidor hubiera tenido problemas de red, estos proveedores habrían registrado eventos.

**Conclusión:** El servidor no presentó ningún problema de red durante el incidente. El problema estuvo del lado del cliente.

---

## 3. Causa Raíz

La investigación determinó que las desconexiones de xplora1 fueron causadas por **inestabilidad en la conexión VPN del equipo cliente**, no por un fallo del servidor RDS.

**Evidencia que sustenta esta conclusión:**

1. El reason code **0xD0000009** indica pérdida de conectividad de red entre cliente y servidor.
2. **Solo el usuario xplora1** fue afectado. Ninguna otra sesión RDS se desconectó en los mismos momentos.
3. El servidor no registró ningún evento de error de red en su propio stack.
4. La caída de SAP Business One y hdbstudio ocurrió **después** de las primeras desconexiones, como consecuencia de la inestabilidad de la sesión, no como causa.
5. El usuario se conecta a través de **VPN**, componente externo al servidor que no puede ser monitoreado desde los logs del servidor RDS.

**Cronología final del incidente:**

| Hora | Evento |
|------|--------|
| 10:28 AM | xplora1 inicia sesión RDS normalmente |
| 1:13 PM | Primera desconexión por pérdida de red (VPN inestable) |
| 1:52 PM | Reconexión exitosa |
| 1:56 PM | Segunda desconexión por pérdida de red (VPN inestable) |
| 2:02 PM | Reconexión exitosa |
| 2:11 PM | SAP Business One se cuelga (sesión inestable) |
| 2:11–2:16 PM | Servicios dependientes caen en cascada |
| 2:44 PM | Tercera desconexión por pérdida de red (VPN inestable) |
| 4:00 PM | Cliente reporta que no puede conectarse |
| 4:44 PM | Logoff final de la sesión |

---

## 4. Acciones Correctivas Recomendadas

1. **Revisar logs del cliente VPN** – Verificar si el cliente VPN registró reconexiones o caídas del túnel en los horarios 1:13 PM, 1:56 PM y 2:44 PM del 08/02/2026.
2. **Revisar estabilidad de la conexión a Internet del cliente** – Evaluar si hay intermitencias en el ISP o en el router del usuario.
3. **Evaluar cambio de protocolo VPN** – Si el problema es recurrente, considerar un protocolo más estable o con mejor tolerancia a pérdidas de paquetes.
4. **Configurar reconexión automática en el cliente RDP** – Habilitar la opción de reconexión automática para minimizar el impacto al usuario en caso de caídas momentáneas.

---

## 5. Observaciones Adicionales

- Se detectaron eventos de tipo **Warning (ID 2004)** en el log System durante la mañana del 08/02/2026, que podrían indicar presión de recursos. Se recomienda monitorear el uso de memoria RAM del servidor de forma preventiva.
- El servidor lleva **más de 5 meses sin reiniciarse**. Se recomienda programar un reinicio controlado en horario de baja actividad.

---

*Documento generado como referencia de soporte RDS – iSystems GmbH*
