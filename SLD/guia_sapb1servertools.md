# Guía de Troubleshooting: sapb1servertools.service
## SAP Business One ServerTools — Linux (SUSE)

**Servicio:** `sapb1servertools.service - SAP BusinessOne ServerTools`  
**Servidor:** SLD / SAP Business One App Server (Linux)  
**Usuario de servicio:** `b1service0`  
**Ruta base:** `/usr/sap/SAPBusinessOne/`

---

## 1. ¿Qué es este servicio?

`sapb1servertools.service` es el servicio principal de SAP Business One en Linux. Gestiona el servidor de aplicaciones (Tomcat), el SLD (System Landscape Directory), la licencia y la comunicación con la base de datos SAP HANA. Si este servicio está caído, SAP B1 no puede conectarse a HANA ni procesar operaciones como exports de base de datos.

---

## 2. Verificar el estado del servicio

### 2.1 Estado general
```bash
systemctl status sapb1servertools.service -l
```

**Salida esperada cuando está OK:**
```
● sapb1servertools.service - SAP BusinessOne ServerTools
   Loaded: loaded (/etc/systemd/system/sapb1servertools.service; enabled)
   Active: active (running) since ...
   Main PID: XXXX (java)
```

**Salida cuando está caído:**
```
● sapb1servertools.service - SAP BusinessOne ServerTools
   Loaded: loaded (/etc/systemd/system/sapb1servertools.service; enabled)
   Active: inactive (dead)
```

### 2.2 Buscar servicios SAP B1 relacionados
```bash
# Ver todos los servicios SAP B1 activos
systemctl | grep -i b1

# Ver todos los servicios con "servertools"
systemctl | grep -i servertools
```

### 2.3 Ver timestamps clave del servicio
```bash
systemctl show sapb1servertools.service | grep -E "ActiveEnterTimestamp|InactiveEnterTimestamp|ExecMainStartTimestamp|UnitFileState"
```

| Campo | Significado |
|---|---|
| `ActiveEnterTimestamp` | Cuándo arrancó por última vez |
| `InactiveEnterTimestamp` | Cuándo se detuvo (si aplica) |
| `UnitFileState=enabled` | Arranca automáticamente con el sistema |
| `UnitFileState=disabled` | **No arranca automáticamente** ← problema |

---

## 3. Ver logs del servicio

### 3.1 Log completo del servicio
```bash
journalctl -u sapb1servertools.service --no-pager -l
```

### 3.2 Log de las últimas horas (ajustar fecha según necesidad)
```bash
journalctl -u sapb1servertools.service --since "2026-03-17 00:00:00" --no-pager -l
```

### 3.3 Log en tiempo real (útil al intentar arrancar)
```bash
journalctl -u sapb1servertools.service -f
```

### 3.4 Ver errores del sistema relacionados
```bash
journalctl -p 0..4 --since "2026-03-17 00:00:00" --no-pager | grep -iE "b1|sap|servertools|tomcat|java"
```

---

## 4. Arrancar el servicio — Procedimiento paso a paso

> ⚠️ Ejecutar siempre como usuario `root`.

### Paso 1 — Intentar arranque directo con systemctl
```bash
systemctl start sapb1servertools.service
```

Verificar resultado inmediatamente:
```bash
systemctl status sapb1servertools.service -l
```

Si quedó `active (running)` → ✅ **Problema resuelto.**  
Si sigue `inactive` o `failed` → continuar con Paso 2.

---

### Paso 2 — Reiniciar también el servicio de autenticación
SAP B1 ServerTools tiene un servicio de autenticación complementario que puede bloquear el arranque:

```bash
systemctl stop sapb1servertools-authentication.service
systemctl start sapb1servertools-authentication.service
systemctl restart sapb1servertools.service
```

Verificar:
```bash
systemctl status sapb1servertools.service -l
systemctl status sapb1servertools-authentication.service -l
```

Si quedó `active (running)` → ✅ **Problema resuelto.**  
Si sigue fallando → continuar con Paso 3.

---

### Paso 3 — Arranque manual con variable de entorno
En algunos casos el servicio requiere la variable `USER_INSTALL_DIR` definida explícitamente:

```bash
export USER_INSTALL_DIR=/usr/sap/SAPBusinessOne
/usr/sap/SAPBusinessOne/Common/support/bin/ServerToolsTomcat_service.sh start
```

O ejecutarlo con el usuario de servicio `b1service0`:
```bash
su -s /bin/bash b1service0 -c \
  "export USER_INSTALL_DIR=/usr/sap/SAPBusinessOne && \
  /usr/sap/SAPBusinessOne/Common/support/bin/ServerToolsTomcat_service.sh start"
```

Luego verificar con systemctl:
```bash
systemctl status sapb1servertools.service -l
```

Si quedó `active (running)` → ✅ **Problema resuelto.**  
Si sigue fallando → continuar con Paso 4.

---

### Paso 4 — Verificar que el servicio esté habilitado para autoarranque
Si el servicio no estaba habilitado, systemd no lo intenta arrancar al inicio:

```bash
# Verificar estado de habilitación
systemctl is-enabled sapb1servertools.service

# Si devuelve "disabled", habilitarlo:
systemctl enable sapb1servertools.service
systemctl start sapb1servertools.service
```

---

### Paso 5 — Reinicio del servidor (última opción)
Si ninguno de los pasos anteriores funcionó, el reinicio del servidor permite que systemd arranque todos los servicios en el orden y contexto correcto:

```bash
# Verificar que no haya usuarios conectados antes de reiniciar
who
w

# Reiniciar el servidor
reboot
```

Tras el reinicio, verificar que el servicio arrancó automáticamente:
```bash
systemctl status sapb1servertools.service -l
```

---

## 5. Verificar conectividad con HANA tras arranque

Una vez el servicio esté `active (running)`, confirmar que conecta correctamente al servidor HANA:

```bash
# El log de arranque muestra la conexión probada:
journalctl -u sapb1servertools.service --no-pager -l | grep -i "testing\|connect\|hana\|error"
```

**Salida esperada:**
```
Testing connection to <hostname_hana>/<instancia>/<tenant>
```

Si aparece un hostname o IP incorrecto en esa línea (por ejemplo, apuntando al servidor antiguo tras una migración), el problema puede ser de configuración del SLD, no del servicio en sí.

---

## 6. Diagrama de decisión

```
¿El servicio está active (running)?
        │
       NO
        │
        ▼
systemctl start sapb1servertools.service
        │
   ¿Funcionó?──── SÍ ──→ ✅ Resuelto
        │
       NO
        │
        ▼
Reiniciar authentication + restart servertools
        │
   ¿Funcionó?──── SÍ ──→ ✅ Resuelto
        │
       NO
        │
        ▼
Arranque manual con USER_INSTALL_DIR
        │
   ¿Funcionó?──── SÍ ──→ ✅ Resuelto
        │
       NO
        │
        ▼
Verificar systemctl enable + start
        │
   ¿Funcionó?──── SÍ ──→ ✅ Resuelto
        │
       NO
        │
        ▼
    Reboot del servidor
        │
        ▼
systemctl status sapb1servertools.service
        │
   ¿Funcionó?──── SÍ ──→ ✅ Resuelto
        │
       NO
        │
        ▼
   Escalar a N2 / SAP Support
```

---

## 7. Referencia rápida de comandos

| Acción | Comando |
|---|---|
| Ver estado | `systemctl status sapb1servertools.service -l` |
| Ver logs | `journalctl -u sapb1servertools.service --no-pager -l` |
| Ver logs en vivo | `journalctl -u sapb1servertools.service -f` |
| Iniciar servicio | `systemctl start sapb1servertools.service` |
| Detener servicio | `systemctl stop sapb1servertools.service` |
| Reiniciar servicio | `systemctl restart sapb1servertools.service` |
| Habilitar autoarranque | `systemctl enable sapb1servertools.service` |
| Ver todos los servicios SAP | `systemctl \| grep -i b1` |
| Ver último reboot | `last reboot \| head -5` |

---

## 8. Notas importantes

- **El servicio corre con Java (Tomcat)** — puede tardar hasta 60 segundos en quedar completamente operativo tras el arranque. No asumir que falló si no responde de inmediato.
- **Tras una migración de tenant HANA**, verificar que el hostname/IP en la configuración del SLD apunta al servidor nuevo y no al antiguo.
- **Si el servidor estuvo mucho tiempo sin reboot**, el servicio puede caerse sin dejar rastro en journalctl porque los logs rotan. En ese caso el reboot es la acción más efectiva.
- **Habilitar auditoría de systemd** para detectar caídas futuras a tiempo con herramientas de monitoreo como Zabbix (ya instalado en este servidor).

---

*Guía generada a partir del troubleshooting real realizado el 17 de marzo de 2026*  
*Servidor: sld | Sistema Operativo: SUSE Linux (kernel 5.14.21-150400)*
