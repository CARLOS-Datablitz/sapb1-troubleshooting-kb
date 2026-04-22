# Troubleshooting — Recolección de Logs Service Layer
**Cliente:** ED Brands  
**Servidor SL:** sl.edbrands.privatcloud.biz  
**OS:** SUSE Linux Enterprise Server 15 SP5  
**Fecha:** 14 de Abril, 2026  
**Ejecutado por:** [Tu nombre]  
**Solicitado por:** Jennifer (cliente) vía Samuel (N2)  
**SAP Note de referencia:** 3157498 — Service Layer Log File Configuration

---

## Contexto del caso

Jennifer abrió un ticket con SAP Support relacionado con problemas de TrueCommerce y el upgrade a la versión FP 2602. SAP solicitó los logs del Service Layer para diagnóstico. Samuel realizó el upgrade del sistema y una de las bases de datos para verificar si las alertas funcionaban correctamente. Jennifer solicitó a Samuel los logs según la SAP Note 3157498.

**¿Por qué SAP pide estos logs?**  
El Service Layer es la API REST de SAP Business One. Cuando hay problemas de integración (como TrueCommerce), lentitud, errores de autenticación o comportamiento inesperado tras un upgrade, SAP Support necesita los logs del SL para:
- Ver exactamente qué requests llegaron y cuál fue la respuesta
- Identificar errores HTTP, timeouts, o fallos internos del proceso httpd
- Rastrear el flujo lógico de SAP B1 (OBServer) durante la operación problemática
- Verificar que el SSL está negociando correctamente
- Detectar crashes o dumps del proceso

---

## Arquitectura del entorno

| Componente | Hostname | Puerto | Descripción |
|---|---|---|---|
| SLD | sld.edbrands.privatcloud.biz | 40000 | System Landscape Directory |
| Service Layer | sl.edbrands.privatcloud.biz | 50000 | Load Balancer (LB) |
| Service Layer | sl.edbrands.privatcloud.biz | 50001–50004 | Nodos del SL |
| SL Controller | sl.edbrands.privatcloud.biz | 40005 | ServiceLayerController (Tomcat/Java) |
| Auth (Keycloak) | sld.edbrands.privatcloud.biz | 40020 | OIDC login para el Controller |

**Versión SAP B1:** 10.00.320 — Special Build 22 — Codeline 10.0_REL  
**Servicios systemd relevantes:**
- `b1s50000.service` — The Service Layer Load Balancer
- `b1s50001.service` a `b1s50004.service` — Nodos del Service Layer
- `sapb1servertools-servicelayercontroller.service` — ServiceLayerController (Tomcat)

---

## Tipos de logs solicitados y qué revelan

### 1. Service Layer Error Logs (`error_${PORT}_log_%Y_%m_%d`)
**Ruta:** `/usr/sap/SAPBusinessOne/ServiceLayer/logs/`  
**Estado inicial:** ✅ Ya estaban habilitados por defecto  
**Qué revela:** Todos los errores técnicos del proceso httpd — errores HTTP, módulos fallando, problemas de configuración del servidor web. Cada nodo (50000–50004) genera su propio archivo diario. Es el log más básico y siempre activo.

### 2. Service Layer Access Logs (`access_${PORT}_log_%Y_%m_%d`)
**Ruta:** `/usr/sap/SAPBusinessOne/ServiceLayer/logs/`  
**Estado inicial:** ❌ Deshabilitado — se habilitó durante esta intervención  
**Qué revela:** Cada request que llega al Service Layer: IP de origen, timestamp, método HTTP (GET/POST), endpoint llamado, código de respuesta, tamaño en bytes, tiempo de procesamiento y session ID. Es el log de tráfico completo — permite a SAP ver exactamente qué estaba llamando TrueCommerce y qué respuesta recibió.

### 3. Service Layer Request & Response Logs (`dumphttp.log_%Y_%m_%d`)
**Ruta:** `/usr/sap/SAPBusinessOne/ServiceLayer/logs/`  
**Estado inicial:** ❌ Deshabilitado — se habilitó durante esta intervención  
**Qué revela:** El contenido completo de cada request y response HTTP procesado por el Service Layer. A diferencia del Access Log que solo registra metadatos, este log incluye el body completo de cada llamada. Muy útil para ver exactamente qué datos envía/recibe TrueCommerce.  
⚠️ Consume mucho espacio en disco — revertir después de recolectar.

### 4. OBServer Performance Logs (`httpd.servicelayer.*.log.csv`)
**Ruta:** `/usr/sap/SAPBusinessOne/home/b1service0/SAP/SAP Business One/Log/BusinessOne/`  
**Estado inicial:** ✅ Ya existían archivos hasta Mar 23 (previos al upgrade)  
**Qué revela:** El flujo interno de lógica de SAP B1 durante el procesamiento de cada request — tiempos de ejecución por componente, consultas SQL generadas, rendimiento del OBServer. Permite a SAP identificar cuellos de botella o comportamiento anómalo en la lógica de negocio post-upgrade.

### 5. Log Levels (OBServer Debug)
**Estado inicial:** ⚠️ En `Warn` — se cambió a `Debug` durante esta intervención  
**Qué revela:** Con nivel Debug, los logs de OBServer capturan el flujo completo de ejecución, no solo warnings y errores. SAP puede ver exactamente qué código path se ejecutó, qué objetos se instanciaron y dónde ocurrió un fallo.  
⚠️ Revertir a `Warn` después de recolectar.

---

## Comandos ejecutados (los que funcionaron)

### Verificación inicial del servidor

```bash
cat /etc/os-release
# Verifica la versión del sistema operativo. Resultado: SLES 15 SP5.
```

```bash
df -h
# Muestra el uso de disco por filesystem. Confirmó /usr/sap al 41% (48G libres) — seguro para habilitar logs.
```

```bash
ls -lht /usr/sap/SAPBusinessOne/ServiceLayer/logs/
# Lista los logs del Service Layer ordenados por fecha. Confirmó que solo existían error_* logs, sin access ni dumphttp.
```

```bash
ls -lht "/usr/sap/SAPBusinessOne/home/b1service0/SAP/SAP Business One/Log/BusinessOne/"
# Lista los OBServer performance logs. Confirmó archivos httpd.servicelayer.*.log.csv hasta Mar 23.
```

### Identificación de servicios y puertos

```bash
systemctl list-units --type=service | grep -i "sap\|b1\|service"
# Lista todos los servicios activos del sistema filtrando por SAP/B1.
# Reveló: b1s50000–50004 (SL nodes) y sapb1servertools-servicelayercontroller (Tomcat).
```

```bash
ps aux | grep -i "sap\|b1s\|httpd" | grep -v grep
# Lista procesos activos de SAP/httpd con sus PIDs y archivos de configuración.
# Confirmó que el SL corre con httpd custom de SAP, no el del sistema.
```

```bash
ss -tlnp | grep -E "5000[0-9]"
# Muestra puertos TCP en LISTEN filtrando por rango 50000-50009.
# Confirmó: 50000 (LB) y 50001–50004 (nodos) activos.
```

```bash
ss -tlnp | grep java
# Busca puertos TCP abiertos por procesos Java.
# Reveló el ServiceLayerController en puerto 40005 (no en 50000 como se esperaba inicialmente).
```

```bash
ip addr | grep "inet " | grep -v 127.0.0.1
# Muestra la IP del servidor (excluyendo loopback).
# Resultado: 10.3.94.91
```

### Acceso al ServiceLayerController

URL de acceso:
```
https://sl.edbrands.privatcloud.biz:40005/ServiceLayerController
```
> El login redirige a Keycloak en `sld.edbrands.privatcloud.biz:40020`. Se requieren credenciales de administrador SAP B1.

### Forzar generación de logs (verificación)

```bash
curl -k https://localhost:50000/b1s/v1/$metadata
# Envía un request HTTP al Service Layer para forzar la generación de entradas en los logs.
# El error 301 "Invalid session" es normal — igual registra el request en access y dumphttp logs.
```

### Verificación post-habilitación

```bash
ls -lht /usr/sap/SAPBusinessOne/ServiceLayer/logs/ | grep -E "access|dump"
# Confirma que los nuevos logs access_* y dumphttp.log_* se están generando.
```

### Empaquetado de logs

```bash
tar -czvf /tmp/ED_Brands_SL_logs_$(date +%Y%m%d_%H%M).tar.gz \
  /usr/sap/SAPBusinessOne/ServiceLayer/logs/ \
  "/usr/sap/SAPBusinessOne/home/b1service0/SAP/SAP Business One/Log/BusinessOne/"
# Empaqueta en un solo .tar.gz todos los logs del Service Layer y los OBServer logs.
# El nombre del archivo incluye fecha y hora automáticamente.
```

```bash
ls -lh /tmp/ED_Brands_SL_logs_*.tar.gz
# Verifica que el archivo se creó correctamente y muestra su tamaño.
# Resultado: ED_Brands_SL_logs_20260414_1544.tar.gz — 18K
```

### Transferencia a máquina local (desde la PC del técnico)

```bash
scp root@sl.edbrands.privatcloud.biz:/tmp/ED_Brands_SL_logs_20260414_1544.tar.gz .
# Descarga el archivo de logs desde el servidor SL a la máquina local del técnico.
```

### Reinicio del Service Layer (post-cambios de configuración)

```bash
systemctl restart b1s50000.service b1s50001.service b1s50002.service b1s50003.service b1s50004.service
# Reinicia el Load Balancer y los 4 nodos del Service Layer.
# Necesario después de cambiar la configuración en el ServiceLayerController para que los cambios tomen efecto.
```

### Verificación post-reinicio

```bash
systemctl status b1s50000 b1s50001 b1s50002 b1s50003 b1s50004 | grep -E "Active|b1s"
# Verifica que todos los servicios del SL están en estado active (running).
```

---

## Cambios realizados en el ServiceLayerController

**Ruta:** `https://sl.edbrands.privatcloud.biz:40005/ServiceLayerController` → Service Layer Settings → Service Layer Configuration

| Parámetro | Antes | Durante (para recolección) | Después (revertido) |
|---|---|---|---|
| Enable Access Log | ❌ Off | ✅ On | ❌ Off |
| Request & Response Logs | ❌ Off | ✅ On | ❌ Off |
| Log Levels | Warn | Debug | Warn |
| Core Dump | ❌ Off | ❌ Off (no se tocó) | ❌ Off |

> ⚠️ La SAP Note 3157498 indica explícitamente revertir estos cambios una vez recolectados los logs, ya que consumen espacio en disco de forma significativa.

---

## Archivos entregados

| Archivo | Tamaño | Contenido | Ruta SFTP |
|---|---|---|---|
| `ED_Brands_SL_logs_20260414_1544.tar.gz` | 17 KiB | Error logs + Access logs + Request/Response logs + OBServer performance logs | `clientsfirst/edbrands/backup_14_04_2026/` |

---

## Estado final del servidor

- ✅ Todos los servicios `b1s50000–50004` en `active (running)` desde las 15:53 EDT
- ✅ Configuración revertida a estado original (Log Level: Warn, Access Log: Off, R&R Logs: Off)
- ✅ Disco `/usr/sap` al 41% — sin impacto
- ✅ Logs entregados en SFTP y notificado a Jennifer

---

## Notas importantes para intervenciones futuras

1. **El ServiceLayerController NO está en el puerto del SL (50000).** En este entorno corre en el puerto **40005** vía Tomcat/Java. Siempre verificar con `ss -tlnp | grep java`.

2. **El servicio NO se llama `sapb1servertools`.** En este entorno los servicios son `b1s50000` a `b1s50004`. Verificar siempre con `systemctl list-units | grep -i b1`.

3. **El login del Controller usa Keycloak (OIDC).** Requiere credenciales de administrador SAP B1, no credenciales del SO.

4. **Los OBServer logs se guardan en una ruta con espacios** (`SAP Business One`). Siempre usar comillas al referenciarla en bash.

5. **El curl con error 301 es normal.** Un request sin sesión válida igual registra actividad en los logs — suficiente para verificar que los logs están funcionando.

6. **Después de habilitar logs adicionales, siempre hacer Force Restart** desde el Controller o reiniciar los servicios b1s* para que los cambios tomen efecto.

---

*Documento preparado para referencia interna — Ambiente ED Brands — Linux SLES 15 SP5 — SAP Business One 10.00.320*
