# Cambio de Políticas de Contraseñas en Active Directory

**Dominio:** be1eye.privatcloud.biz  
**Servidor:** Windows Server 2019 AD/DC  
**Fecha:** 13 de febrero de 2026  
**Objetivo:** Cambiar el período de expiración de contraseñas de 42 días a 180 días

---

## 📊 Situación Inicial (Verificada)

```powershell
PS C:\Users\Administrator> Get-ADDefaultDomainPasswordPolicy

ComplexityEnabled           : True
DistinguishedName           : DC=be1eye,DC=privatcloud,DC=biz
LockoutDuration             : 00:10:00
LockoutObservationWindow    : 00:10:00
LockoutThreshold            : 0
MaxPasswordAge              : 42.00:00:00    ← Valor actual
MinPasswordAge              : 00:00:00       ⚠️ Riesgo de seguridad
MinPasswordLength           : 0              ⚠️ Riesgo de seguridad
objectClass                 : {domainDNS}
objectGuid                  : d06a205f-c439-49ea-8ffa-f309ceb95f19
PasswordHistoryCount        : 0              ⚠️ Riesgo de seguridad
ReversibleEncryptionEnabled : False
```

**Fine-Grained Password Policies:** Ninguna configurada

---

## ✅ Solución 1: Mediante PowerShell (RECOMENDADO)

### Cambio solo de MaxPasswordAge (Solicitud del cliente)

```powershell
# Cambiar solo el período de expiración a 180 días
Set-ADDefaultDomainPasswordPolicy -Identity "be1eye.privatcloud.biz" -MaxPasswordAge "180.00:00:00"
```

### Verificar el cambio

```powershell
# Verificar que se aplicó correctamente
Get-ADDefaultDomainPasswordPolicy | Select-Object MaxPasswordAge

# Resultado esperado:
# MaxPasswordAge
# --------------
# 180.00:00:00
```

### Configuración Completa Recomendada (Incluye mejoras de seguridad)

```powershell
# Cambiar todas las políticas de contraseña (RECOMENDADO)
Set-ADDefaultDomainPasswordPolicy -Identity "be1eye.privatcloud.biz" `
    -MaxPasswordAge "180.00:00:00" `
    -MinPasswordAge "1.00:00:00" `
    -MinPasswordLength 12 `
    -PasswordHistoryCount 24 `
    -LockoutThreshold 5 `
    -LockoutDuration "00:15:00" `
    -ComplexityEnabled $true
```

### Verificación completa

```powershell
# Ver todas las políticas aplicadas
Get-ADDefaultDomainPasswordPolicy
```

---

## 🖥️ Solución 2: Mediante Interfaz Gráfica (GUI)

### Paso 1: Abrir Group Policy Management Console

1. Presionar `Windows + R`
2. Escribir: `gpmc.msc`
3. Presionar **Enter**

**O alternativamente:**
- Ir a **Server Manager** → **Tools** → **Group Policy Management**

### Paso 2: Navegar a Default Domain Policy

1. En el árbol de la izquierda, expandir:
   - **Forest: be1eye.privatcloud.biz**
   - **Domains**
   - **be1eye.privatcloud.biz**

2. Hacer clic derecho en **Default Domain Policy**
3. Seleccionar **Edit**

### Paso 3: Navegar a Password Policy

En el **Group Policy Management Editor**, seguir esta ruta en el árbol izquierdo:

```
Computer Configuration
  └── Policies
      └── Windows Settings
          └── Security Settings
              └── Account Policies
                  └── Password Policy
```

### Paso 4: Configurar Maximum Password Age

1. En el panel derecho, hacer **doble clic** en:
   - **"Maximum password age"**

2. En la ventana que se abre:
   - ☑️ **Marcar** la casilla: **"Define this policy setting"**
   - Cambiar el valor de días a: **180**
   - Hacer clic en **Apply**
   - Hacer clic en **OK**

### Paso 5: Configurar políticas adicionales (RECOMENDADO)

Mientras estés en **Password Policy**, configura también:

#### a) Minimum password length
- Doble clic en **"Minimum password length"**
- ☑️ Marcar "Define this policy setting"
- Valor: **12** caracteres
- **Apply** → **OK**

#### b) Enforce password history
- Doble clic en **"Enforce password history"**
- ☑️ Marcar "Define this policy setting"
- Valor: **24** passwords remembered
- **Apply** → **OK**

#### c) Minimum password age
- Doble clic en **"Minimum password age"**
- ☑️ Marcar "Define this policy setting"
- Valor: **1** día
- **Apply** → **OK**

#### d) Password must meet complexity requirements
- Doble clic en **"Password must meet complexity requirements"**
- ☑️ Marcar "Define this policy setting"
- Seleccionar: **Enabled**
- **Apply** → **OK**

### Paso 6: Configurar Account Lockout Policy (Opcional pero recomendado)

Navegar a:
```
Computer Configuration
  └── Policies
      └── Windows Settings
          └── Security Settings
              └── Account Policies
                  └── Account Lockout Policy
```

#### a) Account lockout threshold
- Doble clic en **"Account lockout threshold"**
- ☑️ Marcar "Define this policy setting"
- Valor: **5** invalid logon attempts
- **Apply** → **OK**

#### b) Account lockout duration
- Doble clic en **"Account lockout duration"**
- ☑️ Marcar "Define this policy setting"
- Valor: **15** minutes
- **Apply** → **OK**

### Paso 7: Cerrar y Aplicar

1. Cerrar el **Group Policy Management Editor**
2. Cerrar **Group Policy Management Console**

### Paso 8: Forzar actualización de políticas

Abrir **PowerShell** o **CMD** como Administrador y ejecutar:

```powershell
# En el Domain Controller
gpupdate /force
```

Para aplicar en todos los equipos del dominio inmediatamente (opcional):
```powershell
# Forzar actualización en todos los equipos del dominio
Invoke-GPUpdate -Force -RandomDelayInMinutes 0
```

---

## 🔍 Verificación de Cambios

### Verificar en el Domain Controller

```powershell
# Ver las políticas actuales
Get-ADDefaultDomainPasswordPolicy

# Ver solo MaxPasswordAge
Get-ADDefaultDomainPasswordPolicy | Select-Object MaxPasswordAge

# Ver el RSoP (Resultant Set of Policy) de un usuario
gpresult /h C:\gpresult.html
```

### Verificar en un equipo cliente del dominio

```powershell
# En un equipo unido al dominio
gpupdate /force
gpresult /r
```

O generar reporte completo:
```powershell
gpresult /h C:\gpresult_client.html
```

---

## 📋 Resumen de Cambios Aplicados

| Política | Valor Anterior | Valor Nuevo | Estado |
|----------|----------------|-------------|--------|
| **Maximum password age** | 42 días | **180 días** | ✅ Aplicado |
| **Minimum password age** | 0 días | **1 día** | ⚠️ Recomendado |
| **Minimum password length** | 0 caracteres | **12 caracteres** | ⚠️ Recomendado |
| **Password history** | 0 passwords | **24 passwords** | ⚠️ Recomendado |
| **Complexity requirements** | Enabled | **Enabled** | ✅ Mantener |
| **Account lockout threshold** | 0 intentos | **5 intentos** | ⚠️ Recomendado |
| **Account lockout duration** | 10 minutos | **15 minutos** | ⚠️ Recomendado |

---

## ⚠️ Advertencias de Seguridad

### Problemas encontrados en la configuración inicial:

1. **MinPasswordLength: 0** 
   - ❌ Los usuarios pueden tener contraseñas vacías
   - ✅ Cambiar a mínimo 12 caracteres

2. **PasswordHistoryCount: 0**
   - ❌ Los usuarios pueden reutilizar la misma contraseña inmediatamente
   - ✅ Cambiar a 24 contraseñas recordadas

3. **MinPasswordAge: 0**
   - ❌ Los usuarios pueden cambiar la contraseña varias veces seguidas para volver a usar la anterior
   - ✅ Cambiar a 1 día mínimo

4. **LockoutThreshold: 0**
   - ❌ No hay bloqueo de cuenta tras intentos fallidos (ataques de fuerza bruta)
   - ✅ Cambiar a 5 intentos fallidos

---

## 📝 Notas Importantes

- La política se aplicará automáticamente a todos los usuarios del dominio
- El cambio puede tardar hasta 90 minutos en propagarse (intervalo predeterminado de actualización de GPO)
- Use `gpupdate /force` para aplicar inmediatamente en equipos específicos
- Los usuarios que ya cambiaron su contraseña recientemente tendrán 180 días desde su último cambio
- 180 días es el máximo recomendado por muchas políticas de cumplimiento (NIST, etc.)

---

## 🔐 Mejores Prácticas Adicionales

Para complementar el cambio a 180 días, considere:

1. **Implementar Autenticación Multifactor (MFA)**
   - Compensa períodos de expiración más largos
   - Azure AD MFA o soluciones on-premise

2. **Monitoreo de cambios de contraseña**
   ```powershell
   # Ver eventos de cambio de contraseña en los últimos 7 días
   Get-EventLog -LogName Security -After (Get-Date).AddDays(-7) | 
       Where-Object {$_.EventID -eq 4724}
   ```

3. **Auditoría periódica de contraseñas débiles**
   - Usar herramientas como DSInternals
   - Revisar contraseñas que nunca han expirado

4. **Documentar el cambio**
   - Notificar a usuarios sobre el nuevo período
   - Actualizar políticas de seguridad corporativas
   - Registrar en sistema de gestión de cambios

---

## 📧 Comunicación al Cliente

**Asunto:** Cambio de política de expiración de contraseñas completado

Estimado cliente,

Hemos completado exitosamente el cambio solicitado:

- **Política anterior:** Las contraseñas expiraban cada 42 días
- **Política nueva:** Las contraseñas ahora expirarán cada 180 días
- **Aplicación:** El cambio se ha aplicado y se propagará automáticamente a todos los equipos del dominio

Adicionalmente, hemos revisado y recomendamos implementar las siguientes mejoras de seguridad:
- Longitud mínima de contraseña: 12 caracteres
- Historial de contraseñas: 24 contraseñas recordadas
- Bloqueo de cuenta: 5 intentos fallidos

Los usuarios no necesitan tomar ninguna acción. Sus contraseñas actuales seguirán siendo válidas durante 180 días desde su último cambio.

Saludos cordiales,
Equipo de Soporte TI

---

## 📚 Referencias

- [Microsoft: Password Policy](https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-policy)
- [NIST Password Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [Active Directory Password Policy Best Practices](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/best-practices-for-securing-active-directory)

---

**Documento creado:** 13/02/2026  
**Última actualización:** 13/02/2026  
**Versión:** 1.0
