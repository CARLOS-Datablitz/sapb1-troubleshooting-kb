# Configuración de Usuarios en Windows Server 2019

Guía paso a paso para la creación y configuración de usuarios locales en Windows Server 2019 usando PowerShell.

---

## 1. Crear Usuario Administrador Local

### Usuario: dmonroe (Administrador)

Abrir PowerShell como administrador y ejecutar:

```powershell
# Crear el usuario con contraseña interactiva
$Password = Read-Host -AsSecureString "Ingresa la contraseña para dmonroe"
New-LocalUser "dmonroe" -Password $Password -FullName "D Monroe" -Description "Administrador Local"

# Agregar al grupo Administrators
Add-LocalGroupMember -Group "Administrators" -Member "dmonroe"
```

### Verificar la creación del usuario administrador

```powershell
# Ver información del usuario
Get-LocalUser -Name "dmonroe"

# Confirmar que está en el grupo Administrators
Get-LocalGroupMember -Group "Administrators"
```

---

## 2. Cambiar Contraseña de Usuario Existente

### Cambiar contraseña de dmonroe

```powershell
# Método interactivo (recomendado)
$Password = Read-Host -AsSecureString "Ingresa la nueva contraseña"
Set-LocalUser -Name "dmonroe" -Password $Password
```

### Alternativa con CMD

```cmd
net user dmonroe *
```

---

## 3. Crear Usuario con Acceso RDP y Permisos Read/Write

### Usuario: mdezerga (Michael Dezerga)

```powershell
# Crear el usuario con contraseña específica
$Password = ConvertTo-SecureString "5XHeM7/6I1Ha+&c" -AsPlainText -Force
New-LocalUser "mdezerga" -Password $Password -FullName "Michael Dezerga" -Description "Usuario con acceso RDP"

# Configurar que la contraseña nunca expire
Set-LocalUser -Name "mdezerga" -PasswordNeverExpires $true

# Agregar al grupo Users (permisos estándar de lectura/escritura)
Add-LocalGroupMember -Group "Users" -Member "mdezerga"

# Agregar al grupo Remote Desktop Users (acceso RDP)
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "mdezerga"
```

### Verificar la configuración del usuario RDP

```powershell
# Ver información del usuario
Get-LocalUser -Name "mdezerga"

# Verificar membresía en grupo Users
Get-LocalGroupMember -Group "Users" | Where-Object {$_.Name -like "*mdezerga*"}

# Verificar membresía en grupo Remote Desktop Users
Get-LocalGroupMember -Group "Remote Desktop Users" | Where-Object {$_.Name -like "*mdezerga*"}
```

---

## 4. Comandos Útiles Adicionales

### Listar todos los usuarios locales

```powershell
Get-LocalUser
```

### Listar miembros de un grupo específico

```powershell
Get-LocalGroupMember -Group "Administrators"
Get-LocalGroupMember -Group "Remote Desktop Users"
Get-LocalGroupMember -Group "Users"
```

### Deshabilitar un usuario

```powershell
Disable-LocalUser -Name "nombreusuario"
```

### Habilitar un usuario

```powershell
Enable-LocalUser -Name "nombreusuario"
```

### Eliminar un usuario

```powershell
Remove-LocalUser -Name "nombreusuario"
```

### Remover usuario de un grupo

```powershell
Remove-LocalGroupMember -Group "NombreGrupo" -Member "nombreusuario"
```

---

## Notas Importantes

- **Permisos de Administrador**: Los comandos deben ejecutarse desde PowerShell con privilegios de administrador
- **Políticas de Contraseña**: Asegúrate de que las contraseñas cumplan con las políticas de complejidad del servidor
- **Grupo Users**: Proporciona permisos estándar de lectura/escritura en carpetas del perfil del usuario
- **Grupo Remote Desktop Users**: Permite conexión remota vía RDP sin otorgar privilegios administrativos
- **PasswordNeverExpires**: Útil para cuentas de servicio, pero considera las políticas de seguridad de tu organización

---

## Información de Conexión RDP

Para conectarse remotamente al servidor:

- **Usuario Administrador**: `AP-INTSRV1\dmonroe`
- **Usuario Estándar**: `AP-INTSRV1\mdezerga`
- **Servidor**: AP-INTSRV1 (o su dirección IP)

---

**Fecha de creación**: 12 de febrero de 2026  
**Sistema**: Windows Server 2019  
**Método**: PowerShell
