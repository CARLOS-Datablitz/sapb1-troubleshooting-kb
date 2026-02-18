# Configuración de Acceso RDP para Usuario de Dominio - Windows Server 2019

Guía de configuración para otorgar acceso RDP con permisos de lectura/escritura a un usuario del Active Directory en un servidor Windows Server 2019.

---

## Contexto del Caso

- **Servidor:** AP-INTSRV1 (identificado como .44)
- **Usuario:** mike.dezerga (del dominio ALLPRO)
- **Requerimiento:** Acceso RDP con permisos de lectura/escritura en todo el servidor
- **Nota:** El usuario ya existe en el Active Directory/Domain Controller

---

## Paso 1: Eliminar Usuario Local (si fue creado por error)

Si se creó un usuario local por error, eliminarlo primero:

```powershell
# Eliminar usuario local
Remove-LocalUser -Name "mdezerga"

# Verificar que se eliminó
Get-LocalUser -Name "mdezerga"
```

---

## Paso 2: Agregar Usuario del Dominio al Grupo "Remote Desktop Users"

### Método GUI (Interfaz Gráfica):

1. Abrir **Server Manager**
2. Ir a **Tools** → **Computer Management**
3. Expandir **Local Users and Groups** → **Groups**
4. Hacer doble clic en **"Remote Desktop Users"**
5. Hacer clic en **"Add..."**
6. Escribir: `mike.dezerga`
7. Hacer clic en **"Check Names"** (debe resolverse mostrando ALLPRO\mike.dezerga)
8. Hacer clic en **"OK"**
9. Hacer clic en **"OK"** nuevamente

### Método PowerShell:

```powershell
# Agregar usuario del dominio al grupo Remote Desktop Users
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "ALLPRO\mike.dezerga"
```

---

## Paso 3: Verificar Permisos de Lectura/Escritura

**Importante:** No es necesario agregar al usuario al grupo "Users" si el grupo **ALLPRO\Domain Users** ya está incluido, ya que todos los usuarios del dominio heredan automáticamente esos permisos.

### Verificar configuración del grupo Users:

```powershell
Get-LocalGroupMember -Group "Users"
```

**Resultado esperado:** Debe aparecer **ALLPRO\Domain Users** en la lista.

---

## Paso 4: Verificación Completa

### Verificar acceso RDP configurado:

```powershell
Get-LocalGroupMember -Group "Remote Desktop Users"
```

**Resultado esperado:**
```
ObjectClass Name                PrincipalSource
----------- ----                ---------------
User        ALLPRO\mike.dezerga ActiveDirectory
```

### Verificar permisos de lectura/escritura:

```powershell
Get-LocalGroupMember -Group "Users"
```

**Resultado esperado:**
```
ObjectClass Name                             PrincipalSource
----------- ----                             ---------------
Group       ALLPRO\Domain Users              ActiveDirectory
Group       NT AUTHORITY\Authenticated Users Unknown
Group       NT AUTHORITY\INTERACTIVE         Unknown
```

### Verificación específica del usuario:

```powershell
Get-LocalGroupMember -Group "Remote Desktop Users" | Where-Object {$_.Name -like "*mike.dezerga*"}
```

**Resultado esperado:**
```
ObjectClass Name                PrincipalSource
----------- ----                ---------------
User        ALLPRO\mike.dezerga ActiveDirectory
```

---

## Paso 5: Comando de Verificación Completa

Ejecutar este script para verificar toda la configuración de una vez:

```powershell
Write-Host "=== Verificación de usuario mike.dezerga ===" -ForegroundColor Green

Write-Host "`nGrupo Remote Desktop Users:" -ForegroundColor Yellow
Get-LocalGroupMember -Group "Remote Desktop Users" | Where-Object {$_.Name -like "*mike.dezerga*"}

Write-Host "`nGrupo Users (Domain Users):" -ForegroundColor Yellow
Get-LocalGroupMember -Group "Users" | Where-Object {$_.Name -like "*Domain Users*"}

Write-Host "`n=== Verificación Completa ===" -ForegroundColor Green
```

---

## Resumen de Permisos Otorgados

Una vez completada la configuración, el usuario **mike.dezerga** tiene:

✅ **Acceso RDP** al servidor .44  
✅ **Permisos de lectura** en todo el servidor  
✅ **Permisos de escritura** en áreas permitidas (su perfil, documentos, carpetas compartidas)  
✅ **Sin privilegios administrativos** (seguridad según mejores prácticas)  

---

## Información de Conexión

Para que el usuario se conecte al servidor:

- **Usuario:** `ALLPRO\mike.dezerga`
- **Contraseña:** Su contraseña de dominio
- **Servidor:** AP-INTSRV1 (o dirección IP del servidor .44)
- **Método:** Remote Desktop Protocol (RDP)

---

## Notas Importantes

1. **Usuario de Dominio vs Usuario Local:**
   - Los usuarios del dominio usan sus credenciales de Active Directory
   - No es necesario crear usuarios locales si ya existen en el dominio
   - Los permisos se heredan automáticamente del grupo Domain Users

2. **Grupos Locales Relevantes:**
   - **Remote Desktop Users:** Otorga acceso RDP al servidor
   - **Users:** Otorga permisos básicos de lectura/escritura
   - **Administrators:** Otorga privilegios administrativos (NO usado en este caso)

3. **Verificación Post-Configuración:**
   - Siempre verificar con PowerShell que el usuario está en los grupos correctos
   - Solicitar al usuario o al cliente que valide el acceso
   - Documentar cualquier ajuste adicional necesario

---

**Fecha:** 13 de febrero de 2026  
**Sistema:** Windows Server 2019 (AP-INTSRV1)  
**Dominio:** ALLPRO  
**Cliente:** Bradley  
**Usuario configurado:** mike.dezerga (Michael Dezerga)
