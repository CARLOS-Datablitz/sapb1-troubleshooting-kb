# Guía de Troubleshooting: Acceso SMB a B1_SHF (SAP Business One en Linux)

## Contexto
Acceso a la carpeta compartida `B1_SHF` en un servidor Linux con SAP Business One, expuesta vía Samba (SMB), desde un cliente Windows.

Ruta en servidor:
```
/usr/sap/SAPBusinessOne/B1_SHF
```

---

## 1. Problema inicial
Al intentar acceder desde Windows (`\\sld\\B1_SHF`), el sistema solicita credenciales y no permite acceso.

---

## 2. Validación de configuración Samba

Archivo:
```
/etc/samba/smb.conf
```

Bloque relevante:
```ini
[B1_SHF]
    path = /usr/sap/SAPBusinessOne/B1_SHF
    guest ok = no
    writeable = yes
    force user = b1service0
    force group = b1service0
```

### Interpretación
- `guest ok = no` → No permite acceso anónimo
- `force user = b1service0` → Los archivos se crean como ese usuario, pero NO define el login

---

## 3. Error común
Intentar usar:
```bash
smbpasswd -L
```

### Resultado
Solicita contraseña → porque este comando NO lista usuarios

---

## 4. Ver usuarios Samba

Comando correcto:
```bash
pdbedit -L
```

### Función
Lista los usuarios registrados en la base de datos de Samba

---

## 5. Solución: Crear usuario Samba

Comando:
```bash
sudo smbpasswd -a b1service0
```

### Qué hace
- Agrega el usuario a Samba
- Solicita definir contraseña SMB

### Importante
- No usa la contraseña de Linux
- Es independiente

---

## 6. Acceso desde Windows

Credenciales:
```
Usuario: sld\b1service0
Password: (definida en smbpasswd)
```

---

## 7. Post-trabajo: Deshabilitar acceso

Comando:
```bash
sudo smbpasswd -d b1service0
```

### Qué hace
- Bloquea autenticación SMB
- No elimina el usuario

---

## 8. Verificar sesiones activas

Comando:
```bash
smbstatus
```

### Qué muestra
- Usuarios conectados
- IP origen
- Recursos abiertos

---

## 9. Problema detectado
Sesiones activas persistentes incluso después de deshabilitar usuario

Ejemplo:
```
B1_SHF   16350   10.3.94.149
```

---

## 10. Cierre de sesiones SMB

En esta versión de Samba, `smbstatus -k` no está disponible

### Solución
Matar procesos manualmente:
```bash
sudo kill -9 <PID>
```

Ejemplo:
```bash
sudo kill -9 16350 16867
```

### Qué hace
- Termina sesiones SMB activas
- Libera accesos y locks

---

## 11. Verificación final

```bash
smbstatus
```

### Resultado esperado
Sin sesiones activas

---

## 12. Opcional: Eliminación completa

```bash
sudo smbpasswd -x b1service0
```

### Qué hace
- Elimina el usuario de Samba
- No afecta al sistema Linux

---

## 13. Buenas prácticas

- No usar `guest ok = yes` en producción
- Usar usuarios temporales controlados
- Deshabilitar o eliminar después del uso
- Verificar siempre sesiones abiertas

---

## 14. Resumen operativo

1. Validar configuración Samba
2. Crear usuario SMB
3. Acceder desde Windows
4. Ejecutar tarea (upgrade/import)
5. Deshabilitar usuario
6. Cerrar sesiones activas
7. Verificar limpieza

---

## 15. Diagrama de flujo (Troubleshooting)

```mermaid
flowchart TD
    A[Inicio: No puedo acceder a \\sld\\B1_SHF] --> B{¿Pide credenciales?}
    B -- No --> C[Revisar red / DNS / firewall]
    B -- Sí --> D[Revisar smb.conf: guest ok = no]
    D --> E[Ver usuarios Samba: pdbedit -L]
    E --> F{¿Existe usuario válido?}
    F -- No --> G[Crear usuario: smbpasswd -a <usuario>]
    F -- Sí --> H[Usar formato sld\\usuario en Windows]
    G --> H
    H --> I{¿Accede?}
    I -- No --> J[Revisar credenciales / dominio / caché Windows]
    I -- Sí --> K[Ejecutar tarea (upgrade/import)]
    K --> L[Deshabilitar usuario: smbpasswd -d <usuario>]
    L --> M[Ver sesiones: smbstatus]
    M --> N{¿Hay sesiones activas?}
    N -- Sí --> O[Matar PIDs: kill -9 <PID>]
    N -- No --> P[Fin: entorno limpio]
    O --> P
```

---

## Estado final esperado

- Sin accesos SMB activos
- Usuario deshabilitado o eliminado
- Share protegido
- Sistema SAP sin impacto
