# Guía de Troubleshooting — SAP Business One SLD
**Servidor:** sld.montedamina.privatcloud.biz  
**Puerto SLD:** 40000  
**OS:** Linux SLES  
**Última actualización:** Abril 2026

---

## Contexto del caso

Solicitud recibida del cliente:
> *"Hello, Could you please restart sapb1 on Monte da Mina. Thanks"*

Antes de ejecutar cualquier reinicio, seguir este procedimiento completo para diagnosticar, actuar y confirmar el estado del servicio.

---

## 1. Conexión al servidor

```bash
# Verificar conectividad
ping -c 4 sld.montedamina.privatcloud.biz

# Conectarse vía SSH
ssh root@sld.montedamina.privatcloud.biz
```

> Si no responde el ping, verificar VPN activa y reglas de firewall antes de continuar.

```bash
# Ver uso de recursos antes de tocar nada
top -bn1 | head -20
df -h && free -h
```

---

## 2. Estado de servicios SAP B1

```bash
# Listar todos los servicios SAP activos
systemctl list-units --type=service | grep -i sap

# Estado del SAP B1 Server Tools (SLD)
systemctl status sapb1servertools

# Estado de HANA DB (si aplica en este entorno)
systemctl status hana
HDB info

# Verificar que el puerto SLD está escuchando
ss -tlnp | grep 40000
```

**Resultado esperado en puerto 40000:** `LISTEN` → servicio activo.  
Si no aparece → el servicio está caído o con error.

---

## 3. Restart de SAP B1 — Procedimiento recomendado

> ⚠️ **Avisar a los usuarios conectados antes de proceder.** El reinicio corta todas las sesiones activas.

### Paso a paso (modo diagnóstico)

```bash
# 1. Detener el servicio
systemctl stop sapb1servertools

# 2. Esperar y confirmar que no quedan procesos SAP activos
sleep 15 && ps aux | grep -i sap | grep -v grep

# 3. Si quedan procesos colgados, matarlos manualmente
ps aux | grep -i "sap\|b1s\|b1i" | grep -v grep
kill -9 <PID>

# 4. Iniciar el servicio
systemctl start sapb1servertools

# 5. Verificar estado y puerto
systemctl status sapb1servertools
ss -tlnp | grep 40000
```

### Alternativa rápida (si no se necesita diagnóstico)

```bash
systemctl restart sapb1servertools
```

---

## 4. Revisión de logs

### Logs del servicio (systemd)

```bash
# Ver las últimas 100 líneas
journalctl -u sapb1servertools -n 100 --no-pager

# Seguimiento en tiempo real
journalctl -u sapb1servertools -f

# Filtrar solo errores
journalctl -u sapb1servertools -p err --no-pager
```

### Logs de aplicación SAP B1

```bash
# Listar logs disponibles (ordenados por fecha)
ls -lt /var/opt/sap/b1/log/

# Ver los últimos 100 registros
tail -100 /var/opt/sap/b1/log/*.log

# Buscar errores específicos en logs
grep -i "error\|exception\|fatal" /var/opt/sap/b1/log/*.log | tail -50
```

> El path `/var/opt/sap/b1/log/` puede variar según la versión e instalación. Alternativas comunes:
> - `/opt/sap/b1/ServerTools/logs/`
> - `/usr/sap/B1/log/`

---

## 5. Troubleshooting adicional del servidor

### Disco lleno (causa más común de fallos recurrentes)

```bash
df -h
du -sh /var/log/* | sort -rh | head -20
```

> 🔴 **Peligroso si `/var` o `/` están al 90% o más.**  
> Acción: limpiar logs antiguos o archivos temporales antes de reiniciar SAP.

```bash
# Limpiar logs de systemd (conservar últimos 100MB)
journalctl --vacuum-size=100M

# Limpiar archivos temporales del sistema
rm -rf /tmp/* /var/tmp/*
```

### Memoria y swap agotada

```bash
free -h
vmstat 1 5
cat /proc/meminfo | grep -i "memfree\|memavailable\|swapfree"
```

> Si el swap está al 100%, SAP B1 puede caer o comportarse de forma inestable. Evaluar reinicio completo del servidor o ajuste de parámetros de HANA.

### Verificar conectividad interna del SLD

```bash
# Respuesta HTML = servicio activo. Error de conexión = servicio caído.
curl -k https://localhost:40000/B1i/

# Verificar desde fuera (sustituir IP si es necesario)
curl -k https://sld.montedamina.privatcloud.biz:40000/B1i/
```

### Revisar conexiones activas al puerto SAP

```bash
ss -tnp | grep 40000
netstat -an | grep 40000
```

### Base de datos HANA — Comandos útiles

```bash
# Como usuario hxeadm o sidadm
su - hxeadm

# Ver estado de HANA
HDB info
HDB version

# Iniciar / detener HANA
HDB start
HDB stop
```

> SAP B1 depende de HANA. Si la DB está caída, el reinicio de `sapb1servertools` no resolverá el problema.

### Reinicio completo del servidor (último recurso)

```bash
# Programar reinicio con aviso (1 minuto de espera)
shutdown -r +1 "SAP B1 maintenance restart"

# Cancelar si fue un error
shutdown -c

# Reinicio inmediato (sin aviso)
reboot
```

> 🔴 **Coordinar siempre con el cliente antes de reiniciar el servidor completo.** Afecta todos los servicios del entorno.

---

## 6. Checklist rápido post-reinicio

Confirmar cada punto antes de notificar al cliente:

- [ ] `systemctl status sapb1servertools` → **Active: running**
- [ ] `ss -tlnp | grep 40000` → **LISTEN** en puerto 40000
- [ ] `curl -k https://localhost:40000/B1i/` → responde HTML
- [ ] `df -h` → disco por debajo del 85%
- [ ] `free -h` → memoria disponible razonable
- [ ] Usuarios pueden conectarse al SAP B1 Client sin errores

---

## 7. Puntos clave a recordar

1. **Revisar disco y memoria antes de reiniciar.** Un disco lleno al 100% hace que SAP B1 vuelva a caer de inmediato tras el reinicio.

2. **El orden correcto es `stop → esperar → start`.** No usar `restart` a ciegas si se quiere diagnosticar la causa raíz del problema.

3. **Confirmar puerto 40000 en LISTEN después del reinicio.** Eso valida que el SLD levantó correctamente y está aceptando conexiones.

4. **Matar procesos colgados antes del `start`.** Si hay procesos SAP que no mueren con el `stop`, deben eliminarse manualmente con `kill -9` antes de iniciar de nuevo.

5. **SAP B1 depende de HANA.** Si la base de datos está caída o con problemas, reiniciar solo `sapb1servertools` no resolverá el incidente. Verificar HANA primero.

6. **Avisar siempre a los usuarios activos.** El reinicio corta todas las sesiones abiertas en SAP B1.

7. **Documentar cada intervención.** Anotar hora de inicio, acciones tomadas, hora de restauración del servicio y comunicación al cliente.

---

## 8. Plantilla de respuesta al cliente

### Confirmación de reinicio exitoso

```
Hi [nombre],

I've restarted the SAP B1 service on Monte da Mina.

- Service status: Active and running
- Port 40000: Listening
- Time of restart: [HH:MM UTC]

Users should now be able to connect normally. Please let me know if you experience any further issues.

Best regards,
[Tu nombre]
```

### Si se detectó un problema adicional

```
Hi [nombre],

I've restarted the SAP B1 service on Monte da Mina. During the process I noticed [descripción del problema, ej: disk usage at 87%].

- Service status: Active and running
- Port 40000: Listening
- Time of restart: [HH:MM UTC]

I recommend we address [el problema] to prevent future incidents. Please let me know if you'd like me to proceed.

Best regards,
[Tu nombre]
```

---

*Guía preparada para entorno Monte da Mina — Linux SLES — SAP Business One*
