# 🧰 SAP Business One - Guía de Troubleshooting
## Caso: SAP B1 no levanta por fallo en servicios dependientes (XPS / Server Tools / SLD)

---

## 🎯 Objetivo
Esta guía explica **cómo diagnosticar paso a paso** un escenario donde SAP Business One no levanta, aun cuando la base de datos está operativa.

Incluye:
- Procedimiento práctico
- Explicación teórica de cada paso
- Identificación de causa raíz

---

## 🧠 Conceptos clave (Teoría)

Antes del troubleshooting, debes entender la arquitectura básica:

### 🔗 Dependencias principales

SAP B1 (cliente) depende de:

1. **HANA / SQL Server (Base de datos)**
2. **Server Tools Service (B1ServerTools64)**
3. **SLD (System Landscape Directory)**
4. **Servicios adicionales (addons / integraciones como XPS)**

### ⚠️ Punto crítico

El servicio **Server Tools** es clave porque:
- Gestiona el acceso al SLD
- Coordina servicios internos
- Si cae → el cliente no puede conectarse

Además:
- Servicios externos (como XPS) pueden afectar indirectamente a SAP
- Un servicio en fallo constante puede tumbar otros servicios críticos

---

## 🔍 Procedimiento de Troubleshooting (Paso a Paso)

---

### 🟢 Paso 1: Confirmar síntoma

**Qué validar:**
- Usuario no puede ingresar a SAP
- Error de conexión o acceso al SLD

**Por qué:**
Esto define si el problema es:
- Cliente
- Red
- Servicios backend

---

### 🟢 Paso 2: Validar base de datos

**Acción:**
- Verificar que HANA/SQL esté arriba

**Ejemplo HANA:**
```
HDB info
```

**Resultado esperado:**
- Servicios en estado GREEN

**Por qué:**
Si la DB está caída → SAP nunca funcionará

✔ En este caso: DB OK → continuar

---

### 🟢 Paso 3: Revisar servicios de SAP B1

**Acción:**
Abrir:
```
services.msc
```

Revisar:
- SAP Business One Server Tools Service (B1ServerTools64)
- SAP Business One Messaging Service

**Resultado encontrado:**
- Server Tools: DETENIDO
- Otros servicios: inestables o pendientes

**Por qué:**
Este paso identifica si el problema está en la capa de aplicación

---

### 🟢 Paso 4: Revisar Event Viewer

**Acción:**
Abrir:
```
eventvwr.msc
```

Ir a:
- Windows Logs → System

Buscar errores recientes

**Resultado encontrado:**
Error:
```
El servicio XPS: Complemento FE no se pudo iniciar...
El nombre de usuario o la contraseña no son correctos
```

**Por qué:**
El Event Viewer es la fuente principal para:
- Errores de autenticación
- Fallos de servicios
- Dependencias

---

### 🟢 Paso 5: Identificar servicio problemático

**Hallazgo:**
- Servicio: XPS (Complemento FE)
- Estado: Detenido
- Tipo: Automático

**Por qué es importante:**
Servicios en automático que fallan:
- Intentan reiniciarse constantemente
- Generan inestabilidad

---

### 🟢 Paso 6: Analizar impacto en cadena

**Relación detectada:**

1. XPS falla (credenciales incorrectas)
2. Genera intentos continuos
3. Provoca caída de Server Tools
4. Server Tools cae
5. SLD deja de responder
6. SAP B1 no conecta

**Por qué:**
En entornos Windows:
- Servicios pueden compartir recursos
- Fallos repetitivos afectan estabilidad general

---

### 🟢 Paso 7: Validar credenciales del servicio

**Acción:**

1. Ir a propiedades del servicio XPS
2. Pestaña: "Iniciar sesión"
3. Revisar usuario configurado

**Problema encontrado:**
- Contraseña incorrecta o expirada

**Por qué:**
Los servicios con credenciales:
- Dependen de autenticación válida
- Si falla → no inician

---

### 🟢 Paso 8: Aplicar solución

**Opciones:**

#### ✔ Opción A: Corregir credenciales
- Reingresar contraseña correcta
- Usar cuenta de servicio

#### ✔ Opción B: Deshabilitar temporalmente
- Tipo de inicio: Manual o Deshabilitado

**Por qué:**
Permite aislar el problema sin afectar SAP

---

### 🟢 Paso 9: Levantar servicios SAP

**Acción:**

1. Iniciar Server Tools
2. Validar servicios dependientes

**Resultado esperado:**
- Server Tools en Running
- SAP accesible

---

### 🟢 Paso 10: Validar SLD

**Acción:**
Abrir en navegador:
```
https://<server>:40000/ControlCenter
```

**Resultado esperado:**
- Acceso correcto

**Por qué:**
Confirma que la capa de servicios está operativa

---

## 🧨 Causa raíz

Credenciales incorrectas en servicio:

→ XPS (Complemento FE)

Que provocó:

→ Caída de Server Tools
→ Caída del SLD
→ SAP B1 inaccesible

---

## 📌 Lecciones aprendidas

- No todos los problemas de SAP son SAP
- Servicios externos pueden impactar el core
- Event Viewer es clave en diagnóstico
- Siempre validar dependencias antes de reiniciar

---

## 🛡️ Buenas prácticas

- Usar cuentas de servicio dedicadas
- Evitar contraseñas que expiren
- Documentar servicios críticos
- Monitorear Event Viewer regularmente

---

## 🚀 Resumen rápido (Checklist)

✔ DB arriba  
✔ Server Tools activo  
✔ Revisar Event Viewer  
✔ Identificar servicios fallando  
✔ Validar credenciales  
✔ Levantar servicios  
✔ Validar SLD  

---

**Fin de la guía**

