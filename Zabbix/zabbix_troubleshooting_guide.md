# Guía de Troubleshooting — Zabbix Agent en Windows Server 2019 a Zabbix Proxy en Linux

**Entorno:** SAP Business One + HANA | Windows Server 2019 (Terminal Servers) | Ubuntu Linux (Zabbix Proxy)  
**Fecha de elaboración:** 2026-04-16  
**Elaborado por:** Soporte N1  

---

## Contexto del Incidente

El cliente reportó que no podía conectarse al servidor TS01 (Terminal Server) y que los usuarios experimentaban lentitud extrema. Paralelamente, el panel de Zabbix dejó de mostrar datos de consumo de recursos (RAM, CPU, etc.) para todas las VMs del cliente (TS01, TS02, TS03, TS04, ADM, AD/DC).

**Arquitectura del entorno monitoreado:**

```
[Agentes Zabbix en VMs Windows]
        TS01 (10.3.101.166)
        TS02, TS03, TS04
        ADM, AD/DC
              ↓  Puerto 10051
    [Zabbix Proxy: zabbixproxy.dctpa.privatcloud.biz]
         IP: 172.19.5.250 | Ubuntu Linux
              ↓  Puerto 10051
    [Zabbix Server Central: 192.168.191.250]
              ↓
    [Panel de Monitoreo Zabbix]
```

---

## Fase 1 — Diagnóstico desde el Windows Server (TS01)

### Paso 1.1 — Verificar estado del servicio Zabbix Agent

**Comando:**
```powershell
Get-Service -Name "Zabbix Agent 2" | Select-Object Name, Status, StartType
```

**Para qué sirve:** Confirma si el servicio del agente está corriendo, detenido o en estado de error. Es el primer paso porque si el servicio está caído, no tiene sentido revisar conectividad o configuración.

**Resultado esperado (normal):**
```
Name            Status StartType
Zabbix Agent 2  Running Automatic
```

**En este caso:** El servicio estaba `Running` — descartamos que el problema fuera el agente en sí.

---

### Paso 1.2 — Revisar la configuración del agente

**Comando:**
```powershell
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" | Select-String "Server=|ServerActive=|Hostname="
```

**Para qué sirve:** Muestra los tres parámetros críticos de configuración del agente:
- `Server=` → IP del Zabbix Server/Proxy que puede hacer consultas pasivas al agente
- `ServerActive=` → IP a la que el agente envía datos activamente (la más importante para monitoreo activo)
- `Hostname=` → Nombre con el que el agente se identifica ante el servidor Zabbix

**Por qué se revisa:** Si la IP configurada es incorrecta o apunta a un servidor inexistente, el agente no podrá reportar aunque esté corriendo perfectamente.

**Resultado obtenido:**
```
Server=172.19.5.250
ServerActive=172.19.5.250
Hostname=ts01.vintage.privatcloud.biz
```

> ⚠️ **Observación importante:** La IP del Zabbix Proxy en la configuración era `172.19.5.250`, diferente a la IP `192.168.191.250` que se conocía como el servidor Zabbix central. Esto reveló que existe un **Zabbix Proxy intermedio**, arquitectura común cuando los agentes y el servidor central están en segmentos de red diferentes.

---

### Paso 1.3 — Probar conectividad TCP al Zabbix Proxy

**Comando:**
```powershell
$zbxIP = (Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" | Select-String "^ServerActive=") -replace "ServerActive=",""
Test-NetConnection -ComputerName $zbxIP.Trim() -Port 10051
```

**Para qué sirve:** Verifica si el agente puede establecer una conexión TCP al puerto 10051 del Zabbix Proxy. `Test-NetConnection` es superior a un simple `ping` porque prueba el puerto específico, no solo la conectividad ICMP.

> 💡 **Diferencia clave:**
> - `PingSucceeded: True` pero `TcpTestSucceeded: False` → El servidor destino está vivo en red pero el servicio en ese puerto no responde. El problema es del servicio, no de la red.
> - Ambos `False` → Problema de red o firewall bloqueando todo el tráfico.

**Resultado obtenido:**
```
PingSucceeded    : True   ✅
TcpTestSucceeded : False  ❌
```

**Conclusión:** El servidor `172.19.5.250` está en red pero el puerto 10051 no responde. El Zabbix Proxy tiene el servicio caído o bloqueado.

---

### Paso 1.4 — Revisar los logs del Zabbix Agent para confirmar el error

**Comando:**
```powershell
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.log" -Tail 50
```

**Para qué sirve:** Muestra las últimas 50 líneas del log del agente. El agente registra cada intento de conexión al servidor/proxy, lo que permite ver el error exacto que está ocurriendo.

**Por qué se usa `-Tail 50`:** Los logs pueden ser muy grandes; ver solo el final es suficiente para identificar el error más reciente.

**Resultado obtenido (líneas clave):**
```
cannot connect to [172.19.5.250:10051]: dial tcp :0->172.19.5.250:10051: 
connectex: A connection attempt failed because the connected party did not 
properly respond after a period of time...

[101] active check configuration update from host [ts01.vintage.privatcloud.biz] started to fail
[101] sending of heartbeat message for [ts01.vintage.privatcloud.biz] started to fail
```

**Conclusión:** El agente está intentando conectarse pero no recibe respuesta. Confirma que el problema está en el servidor `172.19.5.250`, no en el agente del TS01.

---

### Conclusión de Fase 1

| Componente | Estado | Veredicto |
|---|---|---|
| Servicio Zabbix Agent 2 | ✅ Running | OK |
| Configuración (IPs, Hostname) | ✅ Correcta | OK |
| Conectividad ICMP a proxy | ✅ OK | Red OK |
| Conectividad TCP 10051 a proxy | ❌ Falla | **Problema en el Proxy** |

**El agente del TS01 funciona correctamente. El problema está en el Zabbix Proxy.**

---

## Fase 2 — Validación de impacto en otros servidores

### Verificación rápida

Antes de ir al proxy, se confirmó que **todas las VMs del cliente desaparecieron del panel Zabbix simultáneamente**. Esto es un indicador determinante:

| Escenario | Causa probable |
|---|---|
| Solo 1 VM sin datos | Problema en el agente de esa VM |
| Todas las VMs del cliente sin datos al mismo tiempo | **Problema en el Zabbix Proxy del cliente** |
| Todas las VMs de todos los clientes sin datos | Problema en el Zabbix Server central |

**En este caso:** Todas las VMs del cliente desaparecieron → el problema es el **Zabbix Proxy**.

---

## Fase 3 — Diagnóstico del Zabbix Proxy (Servidor Linux)

### Acceso al servidor

El servidor proxy (`172.19.5.250 / zabbixproxy.dctpa.privatcloud.biz`) no respondía SSH en el puerto 22. Se accedió mediante **consola de Proxmox** (hipervisor).

> ⚠️ **Lección aprendida:** Siempre tener acceso por consola del hipervisor como alternativa cuando SSH falla. Un servidor puede estar vivo (responde ping) pero con SSH caído.

---

### Paso 3.1 — Verificar estado del servicio Zabbix Proxy

**Comando:**
```bash
systemctl status zabbix-proxy --no-pager
```

**Para qué sirve:** Muestra el estado actual del servicio, cuándo fue el último cambio de estado, el PID del proceso principal y los procesos hijos. El flag `--no-pager` evita que el output se pague y permite verlo completo en consola.

**Resultado obtenido:**
```
Active: deactivating (stop-sigterm) since Thu 2026-04-09 06:19:29 UTC; 1 week 0 days ago
Main PID: 260119 (zabbix_proxy)
[todos los procesos hijos: terminated]
```

**Diagnóstico:** El servicio lleva **7 días atascado en estado `deactivating`**. Recibió una señal de parada el 9 de abril pero el proceso principal nunca terminó completamente, bloqueando el reinicio del servicio. Todos los procesos hijos (trappers, pollers, housekeepers) ya terminaron, pero el proceso padre quedó en estado zombie.

---

### Paso 3.2 — Verificar recursos del servidor (solo lectura)

**Comandos:**
```bash
uptime -s          # Fecha y hora del último reinicio del servidor
df -h              # Uso de disco en todos los filesystems
free -h            # Uso de RAM y Swap
```

**Para qué sirven:**
- `uptime -s` → Determina si el servidor fue reiniciado recientemente, lo que podría explicar por qué el servicio no levantó.
- `df -h` → Un disco lleno al 100% impide que el proceso escriba logs o bases de datos temporales, causando fallos.
- `free -h` → Falta de RAM puede causar que el proceso sea terminado por el OOM Killer del kernel.

**Resultados obtenidos:**
```
Último reboot: 2026-03-02 11:22:14  (45 días sin reiniciar)
Disco /: 19G / 145G (14%)           ✅ OK
RAM: 1.5G / 31G usada               ✅ OK
Swap: 0 bytes usados                ✅ OK
```

**Conclusión:** Los recursos están bien. El problema no es de capacidad sino del proceso en sí.

---

### Paso 3.3 — Revisar logs del Zabbix Proxy

**Comando:**
```bash
journalctl -u zabbix-proxy --no-pager --since "2026-04-09" | tail -50
```

**Para qué sirve:** Muestra los logs del servicio desde la fecha en que falló. `journalctl` es el sistema de logs de systemd en Linux. El flag `--since` filtra desde una fecha específica para no revisar semanas de logs innecesarios.

**En el resultado se observó:**
- El servicio arrancó exitosamente el **24 de marzo de 2026**
- Los procesos hijos (history syncers, pollers, trappers) estaban funcionando
- El servicio se detuvo el **9 de abril de 2026** sin registrar un error crítico evidente

---

## Conclusión Final — Causa Raíz del Problema Zabbix

| Capa | Componente | Estado | Causa |
|---|---|---|---|
| Agentes | Zabbix Agent 2 en TS01-TS04 | ✅ OK | Sin problemas |
| Proxy | `zabbixproxy.dctpa.privatcloud.biz` | 🔴 **CAÍDO** | Servicio atascado en `deactivating` desde 2026-04-09 |
| Servidor central | Zabbix Server 192.168.191.250 | ✅ OK | Sin problemas |

**Causa raíz:** El servicio `zabbix-proxy` en el servidor Linux quedó atascado en estado `deactivating` el 9 de abril de 2026 a las 06:19:29 UTC. El proceso principal no terminó limpiamente, bloqueando cualquier reinicio automático del servicio.

---

## Acción Correctiva — Para N2

> **Escalar con la siguiente información:**

**Servidor afectado:** `zabbixproxy.dctpa.privatcloud.biz` — IP: `172.19.5.250`  
**OS:** Ubuntu Linux | Último reboot: 2026-03-02  
**Problema:** Servicio `zabbix-proxy` atascado en estado `deactivating` desde **2026-04-09 06:19:29 UTC** (7 días)  
**Impacto:** Sin monitoreo de todas las VMs del cliente (TS01-TS04, ADM, AD/DC) y posiblemente otros clientes que usen este mismo proxy  
**Recursos:** Normales — Disco 14%, RAM 5%, Swap 0%  
**SSH:** No responde en puerto 22 — acceso solo por consola Proxmox  
**Última vez funcional:** 2026-03-24 06:55:33  

**Comandos para N2 (requieren privilegios root):**
```bash
# Forzar terminación del proceso zombie
systemctl kill -s SIGKILL zabbix-proxy

# Resetear estado fallido y reiniciar
systemctl reset-failed zabbix-proxy
systemctl restart zabbix-proxy

# Verificar que levantó correctamente
systemctl status zabbix-proxy
```

---

## Referencia Rápida — Flujo de Troubleshooting Zabbix

```
¿Faltan datos en el panel Zabbix?
            ↓
¿Solo 1 VM o todas las VMs del cliente?
    ↓                        ↓
  1 VM                  Todas del cliente
    ↓                        ↓
Revisar agente          Revisar Zabbix Proxy
en esa VM               (esta guía, Fase 2-3)
    ↓
¿Servicio Agent corriendo?
    ↓ No → Iniciar servicio
    ↓ Sí
¿Configuración correcta (Server=, Hostname=)?
    ↓ No → Corregir conf y reiniciar agente
    ↓ Sí
¿TCP al proxy/server responde en 10051?
    ↓ No → Problema en el proxy/servidor destino
    ↓ Sí
Revisar logs del agente para error específico
```

---

## Comandos de Referencia Rápida

### Windows Server (Agente Zabbix)

| Propósito | Comando |
|---|---|
| Estado del servicio | `Get-Service -Name "Zabbix Agent 2"` |
| Ver configuración clave | `Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.conf" \| Select-String "Server=\|ServerActive=\|Hostname="` |
| Probar conectividad TCP al proxy | `Test-NetConnection -ComputerName <IP> -Port 10051` |
| Ver logs del agente (últimas 50 líneas) | `Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.log" -Tail 50` |
| Reiniciar agente (si es necesario) | `Restart-Service "Zabbix Agent 2"` |

### Linux (Zabbix Proxy / Server)

| Propósito | Comando |
|---|---|
| Estado del servicio proxy | `systemctl status zabbix-proxy --no-pager` |
| Logs desde una fecha específica | `journalctl -u zabbix-proxy --no-pager --since "YYYY-MM-DD" \| tail -50` |
| Verificar uso de disco | `df -h` |
| Verificar uso de RAM | `free -h` |
| Verificar fecha de último reboot | `uptime -s` |
| Probar puerto desde otro servidor | `nc -zv <IP> 10051` |

---

## Notas Importantes para Próximos Troubleshootings

1. **Si todas las VMs de un cliente desaparecen simultáneamente** → Ir directamente al Zabbix Proxy, no perder tiempo en los agentes individuales.

2. **SSH caído no significa servidor caído** → Un servidor puede responder ping pero tener SSH inactivo. Siempre tener acceso por consola del hipervisor (Proxmox, VMware, etc.).

3. **Estado `deactivating` en systemd** → Es un estado intermedio donde el servicio recibió señal de parada pero no terminó. Puede quedar indefinidamente así si el proceso principal es zombie. Requiere `systemctl kill -s SIGKILL` para forzar la terminación.

4. **Verificar siempre la IP configurada en el agente** → En entornos con múltiples segmentos de red, puede haber Zabbix Proxies intermedios. La IP en `ServerActive=` puede no ser el servidor Zabbix central sino un proxy.

5. **`PingSucceeded: True` + `TcpTestSucceeded: False`** → El servidor está vivo pero el servicio en ese puerto no responde. Nunca asumir que porque hay ping, el servicio funciona.

6. **Revisar el panel de Zabbix por alertas activas** → Antes de iniciar cualquier troubleshooting en los agentes, revisar si hay una alerta de `Zabbix proxy last seen more than 600 seconds ago` — eso apunta directamente al proxy como causa raíz.

---

*Documento elaborado como referencia para el equipo de Soporte N1. Para acciones correctivas que impliquen reinicio de servicios en producción, escalar a N2.*
