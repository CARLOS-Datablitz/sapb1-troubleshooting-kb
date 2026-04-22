# Troubleshooting Completo: B1SiteUser en SAP Business One (Arquitectura con Keycloak)

## 🎯 Objetivo
Esta guía permite diagnosticar y resolver problemas relacionados con el usuario técnico **B1SiteUser** en entornos SAP Business One que utilizan **Keycloak como Identity Provider (IdP)**.

No solo cubre la remediación, sino también la **identificación de causa raíz**.

---

## 🧠 1. Entendimiento de Arquitectura

En versiones modernas de SAP B1 (10 FP 2102+):

- **Keycloak** → Maneja autenticación (usuarios, passwords, locks)
- **Service Layer** → Consume autenticación vía tokens
- **SLD (System Landscape Directory)** → Configuración
- **HANA** → Backend (NO controla autenticación en este caso)

👉 Conclusión clave:
> Si B1SiteUser falla, primero revisar Keycloak.

---

## 🚨 2. Síntomas comunes

- No acceso a Extension Manager
- Error de autenticación en Control Center
- Add-ons no pueden desplegarse
- Logs con errores tipo:
  - `401 Unauthorized`
  - `invalid_user_credentials`

---

## 🔎 3. Flujo de Troubleshooting (Nivel Profesional)

---

### 🔹 Paso 1: Confirmar que el entorno usa Keycloak

Accede a:
```
https://<server>:40020/auth/
```

Si ves consola de Keycloak → ✔ entorno moderno

---

### 🔹 Paso 2: Validar estado del usuario en Keycloak

1. Ingresar a Administration Console
2. Cambiar realm a: `sapb1`
3. Ir a: Users → buscar `b1siteuser`

Verificar:
- Enabled = ON
- Email verified (opcional)
- Required actions (vacío)

---

### 🔹 Paso 3: Revisar credenciales

Ir a pestaña **Credentials**:
- Reset password si es necesario
- Verificar que no esté en estado temporal

---

### 🔹 Paso 4: Revisar si el usuario fue bloqueado

En Keycloak:
- Revisar si está deshabilitado
- Validar si hay política de lock por intentos fallidos

---

### 🔹 Paso 5: Análisis de logs (CRÍTICO)

#### 📂 Keycloak logs
```
/usr/sap/SAPBusinessOne/Common/keycloak/standalone/log/
```

Buscar:
- `invalid_user_credentials`
- `user temporarily disabled`
- `failed login`

---

#### 📂 Service Layer logs
```
/usr/sap/SAPBusinessOne/ServiceLayer/logs/
```

Buscar:
- `401`
- `authentication failed`

---

## 🧪 4. Identificación de causa raíz

### 🔸 Causa 1: Password incorrecto en algún servicio

Síntomas:
- Muchos intentos fallidos en logs
- Usuario se bloquea repetidamente

Origen típico:
- Service Layer
- Integraciones externas
- Scripts

---

### 🔸 Causa 2: Password expirado

Síntomas:
- Usuario activo pero no autentica

Acción:
- Reset password en Keycloak

---

### 🔸 Causa 3: Usuario deshabilitado manualmente

Síntomas:
- Enabled = OFF

Acción:
- Habilitar usuario

---

### 🔸 Causa 4: Required Actions pendientes

Síntomas:
- Login bloqueado aunque credenciales correctas

Acción:
- Limpiar acciones pendientes

---

### 🔸 Causa 5: Desincronización con servicios

Síntomas:
- Se corrige password pero vuelve a fallar

Causa:
- Algún componente sigue usando credenciales antiguas

---

## 🔧 5. Remediación correcta

### Paso 1: Resetear password en Keycloak

### Paso 2: Habilitar usuario si aplica

### Paso 3: Actualizar credenciales en:
- Service Layer
- Integraciones externas

### Paso 4: Reiniciar servicios

```bash
service b1s restart
service sapb1servertools restart
```

---

## ✅ 6. Validación post-fix

Confirmar:
- Acceso a Extension Manager
- Login correcto
- No nuevos errores en logs

---

## ⚠️ 7. Buenas prácticas

- Nunca solo habilitar usuario sin revisar logs
- Siempre identificar qué generó el bloqueo
- Documentar servicios que usan B1SiteUser
- Monitorear intentos fallidos

---

## 🧭 8. Checklist rápido

- [ ] Acceso a Keycloak OK
- [ ] Usuario habilitado
- [ ] Password actualizado
- [ ] Logs revisados
- [ ] Servicios sincronizados
- [ ] Validación final OK

---

## 🧠 Conclusión

El problema de B1SiteUser en entornos con Keycloak **no es solo de usuario**, sino de:
- Autenticación centralizada
- Integraciones dependientes
- Políticas de seguridad

👉 Resolver sin analizar causa raíz genera recurrencia.

