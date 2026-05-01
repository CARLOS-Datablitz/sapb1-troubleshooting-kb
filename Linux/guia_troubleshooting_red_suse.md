# Guía de Troubleshooting: Interfaz de red sin IPv4 en openSUSE/SLES (Proxmox VM)

## 📋 Información del entorno
- **Sistema:** openSUSE / SUSE Linux Enterprise
- **Hypervisor:** Proxmox VE (VM)
- **Servicio de red:** `wicked`
- **Interfaz afectada:** `eth0`

---

## ❌ Problema

La interfaz `eth0` aparece como **UP** pero **no tiene dirección IPv4** asignada. Solo muestra IPv6 link-local (`fe80::...`).

A pesar de tener el archivo de configuración `/etc/sysconfig/network/ifcfg-eth0` creado, `wicked` reporta el estado `device-unconfigured`.

---

## 🔍 Síntomas observados

```
# wicked show eth0
eth0    device-unconfigured

# ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    link/ether 42:42:0a:02:5d:aa
    inet6 fe80::.../64 scope link
    # <-- No aparece inet (IPv4)
```

---

## 🛠️ Pasos de diagnóstico y resolución

### Paso 1: Verificar configuración del archivo ifcfg

**Comando:**
```bash
cat /etc/sysconfig/network/ifcfg-eth0
```

**Explicación:** Muestra el contenido del archivo de configuración de la interfaz. En SUSE/openSUSE, `wicked` lee estos archivos para aplicar la configuración.

**Hallazgo:** La IP estaba en formato CIDR (`IPADDR='10.2.93.170/28'`), lo cual no es válido para `wicked` en esta distribución.

**Corrección aplicada:**
```bash
vim /etc/sysconfig/network/ifcfg-eth0
```
Contenido corregido:
```
IPADDR='10.2.93.170'
NETMASK='255.255.255.240'
BOOTPROTO='static'
STARTMODE='auto'
GATEWAY='10.2.93.163'
```

> **Nota:** En SUSE, `IPADDR` y `NETMASK` deben ir en variables separadas. No se admite notación CIDR (`/28`) dentro de `IPADDR`.

---

### Paso 2: Verificar estado de los servicios de red

**Comando:**
```bash
systemctl status wickedd wickedd-nanny wicked
```

**Explicación:** Verifica si los tres demonios de `wicked` están activos. `wickedd` es el daemon principal, `wickedd-nanny` monitorea cambios en interfaces, y `wicked` aplica la configuración al boot.

**Hallazgo:** Los servicios aparecían como `active (running)`, pero en los logs de `wickedd-nanny` se observó el error crítico:
```
org.freedesktop.DBus.Error.ServiceUnknown: The name org.opensuse.Network was not provided
Couldn't refresh list of active network interfaces
```

Esto indica que **D-Bus no estaba proporcionando el servicio de red** que `wicked` necesita para gestionar interfaces.

---

### Paso 3: Reiniciar el stack D-Bus y wicked

**Comandos ejecutados (en orden):**
```bash
systemctl restart dbus
systemctl restart wickedd
systemctl restart wickedd-nanny
systemctl restart wicked
```

**Explicación:**
- `systemctl restart dbus` → Reinicia el bus de mensajes del sistema. `wicked` depende de D-Bus para comunicarse entre sus componentes.
- `systemctl restart wickedd` → Reinicia el daemon principal de configuración de red.
- `systemctl restart wickedd-nanny` → Reinicia el monitor de interfaces.
- `systemctl restart wicked` → Reinicia el servicio que aplica la configuración a todas las interfaces.

---

### Paso 4: Levantar la interfaz

**Comando:**
```bash
wicked ifup eth0
```

**Explicación:** Ordena a `wicked` que lea el archivo `ifcfg-eth0` y aplique la configuración (IP, máscara, gateway) a la interfaz `eth0`.

**Resultado:** La interfaz se configuró correctamente y adquirió la IPv4.

---

### Paso 5: Verificación final

**Comandos:**
```bash
ip addr show eth0
ip route
ping -c 3 10.2.93.163
```

**Explicación:**
- `ip addr show eth0` → Confirma que la IPv4 (`inet 10.2.93.170/28`) aparece en la interfaz.
- `ip route` → Verifica que la ruta por defecto (`default via 10.2.93.163`) existe.
- `ping` → Prueba conectividad con el gateway.

**Resultado:** Conexión SSH exitosa al servidor.

---

## ✅ Resumen de la resolución

| Problema | Causa raíz | Solución |
|----------|-----------|----------|
| eth0 UP sin IPv4 | Error de D-Bus: `org.opensuse.Network` no disponible | Reiniciar `dbus` y el stack completo de `wicked` |
| wicked ignoraba ifcfg | D-Bus no registraba el servicio de red | `systemctl restart dbus wickedd wickedd-nanny wicked` |
| Formato inicial incorrecto | `IPADDR='10.2.93.170/28'` no válido en SUSE | Separar en `IPADDR` + `NETMASK` |

---

## 📝 Archivo de configuración final funcional

```bash
# /etc/sysconfig/network/ifcfg-eth0
IPADDR='10.2.93.170'
NETMASK='255.255.255.240'
BOOTPROTO='static'
STARTMODE='auto'
GATEWAY='10.2.93.163'
```

---

## 🚨 Notas importantes

1. **En SUSE/openSUSE**, `wicked` es el gestor de red por defecto. No usar notación CIDR en `IPADDR`.
2. **En VMs de Proxmox**, si `wicked` falla con errores de D-Bus, reiniciar el bus suele ser suficiente.
3. Si el problema persiste, revisar logs con: `journalctl -u wickedd -u wicked --no-pager -n 50`
4. Como alternativa definitiva, se puede migrar a **NetworkManager** si `wicked` presenta inestabilidad recurrente.
