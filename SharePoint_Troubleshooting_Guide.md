# Guía de Troubleshooting: Problemas de Adjuntos de SharePoint en Outlook

## Contexto del Problema
Usuario no puede adjuntar documentos desde SharePoint a correos de Outlook, aunque tiene acceso a los archivos.
Login Microsoft: isystems@allprocorp.com / sync@allprocorp.com
iSystems#99208977 ---> Allpro

## 🔧 ACCESOS DISPONIBLES
- ✅ Windows Server AD/DC (Active Directory Domain Controller)
- ✅ Windows Server File Server
- ✅ Office 365 (Admin Portal)
- ❌ PC/Laptop del usuario final (Scott)

---

## ⚡ GUÍA RÁPIDA: Verificar Estado de Sincronización de un Usuario

Si solo necesitas verificar rápidamente si un usuario está sincronizado correctamente:

```powershell
# 1. Importar módulo
Import-Module ADSync

# 2. Buscar usuario en AD
Get-ADUser -Filter {Name -like "*NombreUsuario*"} | Select-Object Name, SamAccountName, DistinguishedName

# 3. Obtener ID del conector de AD local
$adConnector = Get-ADSyncConnector | Where-Object {$_.Type -eq "AD"}
$adConnectorId = $adConnector.Identifier

# 4. Verificar usuario en AD local (reemplaza el Distinguished Name)
$adObject = Get-ADSyncCSObject -ConnectorIdentifier $adConnectorId -DistinguishedName "CN=Usuario,OU=Users,DC=domain,DC=com"

# 5. Ver si tiene errores
Write-Host "HasSyncError: $($adObject.HasSyncError)"
Write-Host "HasExportError: $($adObject.HasExportError)"
Write-Host "ConnectedMVObjectId: $($adObject.ConnectedMVObjectId)"

# 6. Verificar en Metaverse
$mvObject = Get-ADSyncMVObject -Identifier $adObject.ConnectedMVObjectId
$mvObject.Lineage

# 7. Verificar en Azure AD (obtener ID de Azure del lineage)
$aadLineage = $mvObject.Lineage | Where-Object {$_.ConnectorName -like "*AAD*"}
$aadObject = Get-ADSyncCSObject -Identifier $aadLineage.ConnectedCsObjectId

# 8. Ver estado en Azure AD
Write-Host "Azure AD HasSyncError: $($aadObject.HasSyncError)"
Write-Host "Azure AD HasExportError: $($aadObject.HasExportError)"
```

**Interpretación:**
- ✅ Si `HasSyncError` y `HasExportError` son `False` en ambos = Usuario sincronizado correctamente
- ✅ Si existe `ConnectedMVObjectId` = Usuario conectado al Metaverse
- ✅ Si aparece en el lineage con ambos conectores = Sincronización bidireccional funcionando
- ❌ Si cualquier error es `True` = Hay problema de sincronización

---

## 📋 CHECKLIST DE TROUBLESHOOTING

### 1️⃣ VERIFICAR PERMISOS EN SHAREPOINT (Office 365)

#### A. Verificar permisos del sitio
**Ubicación:** SharePoint Admin Center > Sitios activos > Seleccionar sitio

**Pasos:**
1. Ir a `https://[tenant]-admin.sharepoint.com`
2. Navegar a **"Sitios activos"**
3. Buscar el sitio específico (ej: "Users - Documents")
4. Click en el sitio → **"Permisos"**
5. Verificar que el usuario está listado con permisos adecuados

**Para qué sirve:**
- Confirmar que el usuario tiene acceso al sitio de SharePoint
- Ver el nivel de permisos (Lectura, Contribución, Control Total)

---

#### B. Verificar permisos de biblioteca específica
**Ubicación:** Sitio de SharePoint > Biblioteca de documentos > Configuración

**Pasos:**
1. Abrir el sitio de SharePoint en el navegador
2. Ir a la biblioteca de documentos problemática
3. Click en ⚙️ **"Configuración"** → **"Permisos de biblioteca"**
4. Verificar que el usuario está en la lista
5. Revisar si hay **"Permisos de elementos únicos"** activados

**Para qué sirve:**
- A veces una biblioteca tiene permisos diferentes al sitio principal
- Identificar si hay herencia de permisos rota

---

#### C. Verificar permisos de carpeta específica
**Pasos:**
1. Navegar a la carpeta problemática (ej: "Styx Agreement")
2. Click derecho → **"Detalles"**
3. En el panel derecho, click en **"Administrar acceso"**
4. Verificar miembros con acceso

**Para qué sirve:**
- Las carpetas pueden tener permisos únicos diferentes a la biblioteca
- Ver quién exactamente tiene acceso a esa carpeta específica

---

### 2️⃣ VERIFICAR SINCRONIZACIÓN DE ONEDRIVE (Office 365)

#### A. Revisar estado de sincronización del usuario
**Ubicación:** OneDrive Admin Center

**Pasos:**
```
1. Ir a: https://[tenant]-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx
2. Click en "OneDrive" en el menú lateral
3. Buscar al usuario por email
4. Ver el estado de "Sync Status"
```

**Para qué sirve:**
- Ver si OneDrive está sincronizando correctamente para ese usuario
- Identificar errores de sincronización a nivel de cuenta

---

#### B. Forzar re-sincronización (desde Office 365)
**No hay opción directa desde Office 365**, pero puedes:

**Pasos:**
1. OneDrive Admin Center → Buscar usuario
2. **"Restablecer OneDrive"** (⚠️ CUIDADO: esto borra la sincronización local)
3. El usuario deberá volver a sincronizar desde cero

**Para qué sirve:**
- Solución drástica cuando hay corrupción en la sincronización
- ⚠️ Solo usar como último recurso

---

### 3️⃣ VERIFICAR ACTIVE DIRECTORY (Windows Server AD/DC)

#### A. Verificar membresía de grupos
**Herramienta:** Active Directory Users and Computers (ADUC)

**Pasos PowerShell:**
```powershell
# Conectarse al servidor AD/DC via RDP o PowerShell remoto

# Ver grupos del usuario
Get-ADUser -Identity "scott.morath" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Ver detalles completos del usuario
Get-ADUser -Identity "scott.morath" -Properties *

# Verificar si está en un grupo específico de SharePoint
Get-ADGroupMember -Identity "SharePoint_Users_Group" | Where-Object {$_.Name -like "*Scott*"}
```

**Para qué sirve:**
- Verificar que el usuario pertenece a los grupos correctos de Active Directory
- Los grupos de AD se sincronizan con Office 365
- Si no está en el grupo correcto, no tendrá permisos aunque esté listado en SharePoint

---

#### B. Verificar sincronización de AD con Azure AD (Office 365)
**Herramienta:** Azure AD Connect (en servidor de sincronización)

**Pasos PowerShell:**
```powershell
# En el servidor donde está instalado Azure AD Connect

# Ver último ciclo de sincronización
Get-ADSyncScheduler

# Forzar sincronización manual
Start-ADSyncSyncCycle -PolicyType Delta

# Ver errores de sincronización del usuario específico
Get-ADSyncCSObject -ConnectorName "yourdomain.onmicrosoft.com" -DistinguishedName "CN=Scott Morath,OU=Users,DC=yourdomain,DC=com"
```

**Para qué sirve:**
- Confirmar que los cambios en AD se están sincronizando a Office 365
- Si hay un retraso o error, el usuario podría tener permisos desactualizados en SharePoint

---

### 4️⃣ VERIFICAR FILE SERVER (Windows Server File Server)

#### A. Verificar permisos NTFS (si SharePoint mapea carpetas de red)
**Herramienta:** File Explorer o PowerShell

**Pasos PowerShell:**
```powershell
# Ver permisos NTFS de una carpeta
Get-Acl "C:\Shares\ALLPRO\Users\Documents\House\SPRING SHOWS\2023\Styx Agreement" | Format-List

# Ver permisos detallados
(Get-Acl "C:\Shares\ALLPRO\Users\Documents\House\SPRING SHOWS\2023\Styx Agreement").Access | Format-Table IdentityReference,FileSystemRights,AccessControlType

# Verificar si un usuario específico tiene acceso
(Get-Acl "C:\Shares\ALLPRO\Users\Documents\House\SPRING SHOWS\2023\Styx Agreement").Access | Where-Object {$_.IdentityReference -like "*Scott*"}
```

**Para qué sirve:**
- Si SharePoint está configurado para usar carpetas de red del File Server
- Verificar que los permisos NTFS coincidan con los de SharePoint

---

#### B. Verificar recursos compartidos (Shares)
**Pasos PowerShell:**
```powershell
# Listar todos los shares del servidor
Get-SmbShare

# Ver permisos de un share específico
Get-SmbShareAccess -Name "ALLPRO"

# Ver quién tiene acceso a un share
Get-SmbShareAccess -Name "ALLPRO" | Where-Object {$_.AccountName -like "*Scott*"}

# Ver sesiones abiertas (si el usuario está conectado)
Get-SmbSession | Where-Object {$_.ClientUserName -like "*Scott*"}
```

**Para qué sirve:**
- Verificar permisos a nivel de recurso compartido
- Ver si el usuario está actualmente conectado al share

---

### 5️⃣ COMANDOS DE DIAGNÓSTICO AVANZADO

#### A. Verificar políticas de SharePoint
**Ubicación:** SharePoint Admin Center → Políticas

**Pasos:**
```
1. SharePoint Admin Center
2. "Políticas" → "Uso compartido"
3. Verificar que la sincronización no está bloqueada
4. "Políticas" → "Acceso"
5. Verificar políticas de acceso condicional
```

**Para qué sirve:**
- Políticas globales pueden bloquear la sincronización
- Verificar si hay restricciones por ubicación, dispositivo, etc.

---

#### B. Revisar logs de auditoría (Office 365)
**Ubicación:** Microsoft 365 Compliance Center

**Pasos PowerShell:**
```powershell
# Conectarse a Exchange Online PowerShell
Connect-ExchangeOnline

# Buscar actividades de SharePoint del usuario
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -UserIds "scott.morath@domain.com" -RecordType SharePoint

# Buscar intentos de acceso denegado
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -UserIds "scott.morath@domain.com" -Operations FileAccessedExtended,FileAccessed -ResultSize 500 | Where-Object {$_.ResultStatus -eq "Failed"}
```

**Para qué sirve:**
- Ver historial de accesos del usuario a SharePoint
- Identificar si hay intentos fallidos de acceso
- Determinar el momento exacto en que comenzó el problema

---

#### C. Verificar licencias de Office 365
**Ubicación:** Microsoft 365 Admin Center

**Pasos PowerShell:**
```powershell
# Conectarse a Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Ver licencias del usuario
Get-MgUserLicenseDetail -UserId "scott.morath@domain.com"

# Ver servicios habilitados
Get-MgUser -UserId "scott.morath@domain.com" -Property AssignedLicenses,AssignedPlans | Select-Object -ExpandProperty AssignedPlans
```

**Para qué sirve:**
- Confirmar que el usuario tiene licencia activa de SharePoint/OneDrive
- Ver si algún servicio está deshabilitado

---

### 6️⃣ SOLUCIONES REMOTAS (SIN ACCESO A LA PC DEL USUARIO)

#### A. Revocar sesiones de OneDrive
**Ubicación:** OneDrive Admin Center

**Pasos:**
```
1. OneDrive Admin Center
2. Buscar al usuario
3. "..." → "Revocar sesiones"
```

**Para qué sirve:**
- Fuerza al usuario a cerrar sesión en todos sus dispositivos
- Al volver a iniciar sesión, se refresca la conexión

---

#### B. Eliminar dispositivos registrados
**Ubicación:** Azure AD → Dispositivos

**Pasos:**
```
1. Azure AD Admin Center
2. "Dispositivos" → "Todos los dispositivos"
3. Buscar dispositivos del usuario
4. Seleccionar y "Eliminar"
```

**Para qué sirve:**
- Eliminar registros de dispositivos antiguos o corruptos
- Forzar re-registro del dispositivo

---

#### C. Restablecer contraseña (como último recurso)
**Ubicación:** Microsoft 365 Admin Center

**Pasos:**
```
1. Admin Center → Usuarios activos
2. Buscar al usuario
3. "Restablecer contraseña"
4. ✅ "Obligar al usuario a cambiar la contraseña en el siguiente inicio de sesión"
```

**Para qué sirve:**
- Refresca completamente las credenciales
- Fuerza nuevas conexiones en todos los servicios

---

## 🔍 PROCESO RECOMENDADO DE TROUBLESHOOTING

### Paso 1: Verificación de Permisos (5-10 min)
```
✅ SharePoint Admin Center → Verificar permisos del sitio
✅ SharePoint → Verificar permisos de biblioteca
✅ SharePoint → Verificar permisos de carpeta específica
```

### Paso 2: Verificación de Active Directory (5 min)
```powershell
# Buscar al usuario
Get-ADUser -Filter {Name -like "*Scott*"} | Select-Object Name, SamAccountName, DistinguishedName

# Ver grupos del usuario
Get-ADUser -Identity "scott.morath" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Forzar sincronización si hay cambios recientes
Start-ADSyncSyncCycle -PolicyType Delta
```

### Paso 3: Verificación de Azure AD Connect (10-15 min)
```powershell
# 1. Importar módulo
Import-Module ADSync

# 2. Ver estado de sincronización
Get-ADSyncScheduler

# 3. Ver conectores
Get-ADSyncConnector | Select-Object Name, Type, Identifier

# 4. Ver historial reciente
Get-ADSyncRunProfileResult | Select-Object -First 10

# 5. Buscar errores
Get-ADSyncRunProfileResult | Where-Object {$_.Result -like "*error*"}

# 6. Verificar usuario en AD local (usa el Distinguished Name del paso 2)
Get-ADSyncCSObject -ConnectorIdentifier "AD_CONNECTOR_ID" -DistinguishedName "CN=Scott Morath,OU=Users,OU=Tampa,OU=Allpro OU,DC=Allpro,DC=local"

# 7. Verificar usuario en Metaverse (usa ConnectedMVObjectId del paso anterior)
Get-ADSyncMVObject -Identifier "MVOBJECT_ID"

# 8. Ver lineage para confirmar sincronización a Azure AD
Get-ADSyncMVObject -Identifier "MVOBJECT_ID" | Select-Object -ExpandProperty Lineage

# 9. Verificar usuario en Azure AD (usa ConnectedCsObjectId del Azure AD lineage)
Get-ADSyncCSObject -Identifier "AZURE_CSOBJECT_ID"
```

### Paso 4: Verificación de Licencias (2 min)
```
✅ Microsoft 365 Admin Center → Verificar licencias activas
```

### Paso 5: Revisar Auditoría (10 min)
```powershell
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -UserIds "scott.morath@domain.com" -RecordType SharePoint
```

### Paso 6: Soluciones Remotas
```
1. Revocar sesiones de OneDrive
2. Esperar 5 minutos
3. Solicitar al usuario que cierre Outlook
4. Solicitar al usuario que cierre OneDrive
5. Solicitar al usuario que reinicie ambos
```

---

## 💡 EJEMPLO DE CASO REAL: Usuario no puede adjuntar archivos de SharePoint

### Contexto:
- **Usuario:** Scott Morath
- **Problema:** No puede adjuntar documentos desde SharePoint a correos de Outlook
- **Síntoma:** Los archivos aparecen con ícono de "no sincronizado"

### Proceso de diagnóstico paso a paso:

#### 1. Verificar permisos en SharePoint (Web)
```
✅ Navegué a la carpeta "Styx Agreement" en SharePoint
✅ Confirmé que Scott aparece en "Pertenencia al grupo" como "Miembro"
✅ Conclusión: Scott tiene permisos correctos
```

#### 2. Verificar sincronización de Azure AD Connect
```powershell
# Ver estado del scheduler
PS> Get-ADSyncScheduler
# Resultado: SyncCycleEnabled: True, NextSyncCycle: 10:55:20 PM
# Conclusión: Sincronización automática funcionando correctamente

# Ver conectores
PS> Get-ADSyncConnector | Select-Object Name, Type
# Resultado: 
# - Allpro.local (AD)
# - allprocorp.onmicrosoft.com - AAD (Extensible2)
# Conclusión: Ambos conectores configurados

# Ver historial de sincronizaciones
PS> Get-ADSyncRunProfileResult | Select-Object -First 5
# Resultado: Varias sincronizaciones exitosas
# Nota: Una con "completed-export-errors" pero sin detalles específicos
```

#### 3. Buscar al usuario en Active Directory
```powershell
PS> Get-ADUser -Filter {Name -like "*Scott*"} | Select-Object Name, SamAccountName, DistinguishedName

# Resultado:
# Name: Scott Morath
# SamAccountName: scott.morath
# DistinguishedName: CN=Scott Morath,OU=Users,OU=Tampa,OU=Allpro OU,DC=Allpro,DC=local
```

#### 4. Verificar usuario en Azure AD Connect - AD Local
```powershell
PS> Get-ADSyncCSObject -ConnectorIdentifier "5bda23ac-965c-4672-b6a6-49957fe03cb0" -DistinguishedName "CN=Scott Morath,OU=Users,OU=Tampa,OU=Allpro OU,DC=Allpro,DC=local"

# Resultado clave:
# HasSyncError: False
# HasExportError: False
# ConnectedMVObjectId: b2ceced1-c209-ee11-9b74-005056a9d673
# mail: Scott.Morath@ALLPROCORP.com
# userPrincipalName: scott.morath@allprocorp.com
# Conclusión: Usuario sincronizado correctamente en AD local
```

#### 5. Verificar usuario en Metaverse
```powershell
PS> Get-ADSyncMVObject -Identifier "b2ceced1-c209-ee11-9b74-005056a9d673"

# Resultado:
# Lineage: {Allpro.local, allprocorp.onmicrosoft.com - AAD}
# Conclusión: Usuario conectado a ambos sistemas

# Ver detalles del lineage
PS> Get-ADSyncMVObject -Identifier "b2ceced1-c209-ee11-9b74-005056a9d673" | Select-Object -ExpandProperty Lineage

# Resultado importante:
# ConnectorName: Allpro.local
# ConnectedCsObjectId: c93fd4cb-c209-ee11-9b74-005056a9d673
# 
# ConnectorName: allprocorp.onmicrosoft.com - AAD
# ConnectedCsObjectId: 5141d4cb-c209-ee11-9b74-005056a9d673
# Conclusión: Usuario existe en Azure AD Connect con ID específico
```

#### 6. Verificar usuario en Azure AD
```powershell
PS> Get-ADSyncCSObject -Identifier "5141d4cb-c209-ee11-9b74-005056a9d673"

# Resultado clave:
# ConnectorName: allprocorp.onmicrosoft.com - AAD
# HasSyncError: False
# HasExportError: False
# accountEnabled: true
# mail: Scott.Morath@ALLPROCORP.com
# userPrincipalName: scott.morath@allprocorp.com
# Conclusión: Usuario sincronizado correctamente en Azure AD
```

### 🎯 Diagnóstico Final:

**✅ LO QUE ESTÁ FUNCIONANDO:**
- Permisos de SharePoint: Scott tiene acceso como "Miembro"
- Active Directory: Usuario existe sin errores
- Azure AD Connect: Sincronización funcionando cada 30 minutos
- Azure AD: Usuario sincronizado correctamente
- No hay errores de sincronización en ningún nivel

**❌ PROBLEMA IDENTIFICADO:**
El problema NO está en permisos ni en sincronización. El problema está en:
1. **OneDrive no está sincronizando** correctamente en la PC de Scott
2. **Caché de Outlook** desactualizado
3. **Cliente de SharePoint** en la PC del usuario

### 🔧 Solución Recomendada:

Dado que todos los sistemas backend están funcionando correctamente, el problema está en la **PC del usuario final**:

1. **Solicitar al usuario que:**
   - Cierre completamente Outlook
   - Haga click derecho en el ícono de OneDrive en la bandeja del sistema
   - Seleccione "Cerrar OneDrive"
   - Espere 1 minuto
   - Vuelva a abrir OneDrive
   - Espere que termine de sincronizar
   - Abra Outlook e intente adjuntar nuevamente

2. **Si el problema persiste:**
   - Resetear OneDrive: `Settings → Account → Unlink this PC`
   - Volver a vincular OneDrive con la cuenta
   - Esperar sincronización completa

3. **Como último recurso (desde Office 365 Admin):**
   - OneDrive Admin Center → Buscar usuario → "Restablecer OneDrive"
   - ⚠️ Advertencia: El usuario tendrá que re-sincronizar todos sus archivos

### 📝 Lecciones Aprendidas:

1. **Siempre verificar de arriba hacia abajo:**
   - Primero: Permisos en SharePoint
   - Segundo: Active Directory y grupos
   - Tercero: Azure AD Connect
   - Último: Cliente local del usuario

2. **Los comandos que realmente funcionan:**
   - `Get-ADSyncScheduler` para ver estado de sincronización
   - `Get-ADSyncConnector` para ver conectores
   - `Get-ADSyncRunProfileResult` para historial
   - `Get-ADSyncCSObject` con `-Identifier` para objetos específicos
   - `Get-ADSyncMVObject` para ver el Metaverse

3. **Errores comunes de cmdlets:**
   - ❌ `Get-ADSyncRunHistory` → No funciona en versiones recientes
   - ❌ `Get-ADSyncConnectorRunStatus` → No devuelve datos útiles
   - ✅ `Get-ADSyncRunProfileResult` → Este sí funciona

4. **Cuando NO es problema de sincronización:**
   - Si `HasSyncError` y `HasExportError` son `False`
   - Si el usuario aparece en el Metaverse con lineage a ambos conectores
   - Si el usuario existe en Azure AD
   - Entonces el problema está en el **cliente local**

---

## 📝 NOTAS IMPORTANTES

### ⚠️ Precauciones
- **Restablecer OneDrive** borra la sincronización local (el usuario tendrá que re-sincronizar todo)
- **Eliminar dispositivos** puede afectar otros servicios (Teams, Outlook, etc.)
- **Cambios en AD** pueden tardar hasta 30 minutos en sincronizarse con Office 365

### 💡 Tips
- Siempre documentar los cambios realizados
- Tomar capturas de pantalla de los permisos ANTES de modificar
- Comunicarse con el usuario antes de realizar cambios drásticos
- Revisar logs de auditoría para identificar patrones

### 🚀 Escalamiento
Si después de todos estos pasos el problema persiste:
1. Crear ticket con Microsoft Support
2. Proporcionar logs de auditoría
3. Proporcionar capturas de permisos
4. Indicar todas las soluciones intentadas

---

## 📚 COMANDOS DE REFERENCIA RÁPIDA

### PowerShell - Active Directory
```powershell
# Información del usuario
Get-ADUser -Identity "username" -Properties *

# Grupos del usuario
Get-ADUser -Identity "username" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Buscar usuario por nombre (cuando no sabes el username exacto)
Get-ADUser -Filter {Name -like "*Scott*"} | Select-Object Name, SamAccountName, DistinguishedName

# Sincronizar AD con Azure AD
Start-ADSyncSyncCycle -PolicyType Delta
```

### PowerShell - Azure AD Connect (COMANDOS QUE FUNCIONAN)
```powershell
# Importar módulo
Import-Module ADSync

# Ver estado del scheduler
Get-ADSyncScheduler

# Ver conectores configurados
Get-ADSyncConnector | Select-Object Name, Type, Identifier

# Ver historial de sincronizaciones
Get-ADSyncRunProfileResult | Select-Object -First 10

# Ver sincronizaciones con errores
Get-ADSyncRunProfileResult | Where-Object {$_.Result -like "*error*"} | Select-Object ConnectorName, RunProfileName, Result, StartDate

# Ver objeto de AD local en Azure AD Connect
Get-ADSyncCSObject -ConnectorIdentifier "CONNECTOR_ID" -DistinguishedName "CN=User,OU=Users,DC=domain,DC=com"

# Ver objeto en el Metaverse
Get-ADSyncMVObject -Identifier "MVOBJECT_ID"

# Ver lineage (conexiones del usuario)
Get-ADSyncMVObject -Identifier "MVOBJECT_ID" | Select-Object -ExpandProperty Lineage

# Ver objeto de Azure AD en Azure AD Connect
Get-ADSyncCSObject -Identifier "CSOBJECT_ID"

# Ver versión de Azure AD Connect
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Azure AD Connect\Setup").InstalledVersion
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Azure AD Connect" | Format-List *
```

### PowerShell - Office 365
```powershell
# Conectar a Exchange Online
Connect-ExchangeOnline

# Auditoría de SharePoint
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) -UserIds "user@domain.com" -RecordType SharePoint

# Conectar a Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Ver licencias
Get-MgUserLicenseDetail -UserId "user@domain.com"
```

### PowerShell - File Server
```powershell
# Ver permisos NTFS
Get-Acl "C:\Path\To\Folder" | Format-List

# Ver shares
Get-SmbShare

# Ver acceso a shares
Get-SmbShareAccess -Name "ShareName"

# Ver sesiones activas
Get-SmbSession
```

---

## ✅ CHECKLIST DE CIERRE

Después de resolver el problema:

- [ ] Documentar la causa raíz identificada
- [ ] Documentar la solución aplicada
- [ ] Verificar que el usuario puede adjuntar archivos
- [ ] Verificar que otros archivos/carpetas funcionan
- [ ] Actualizar documentación interna
- [ ] Notificar al cliente de la resolución

---

**Creado por:** IT Support Team  
**Fecha:** Febrero 2026  
**Versión:** 1.0  
**Casos relacionados:** SharePoint Sync Issues, Outlook Attachment Problems
