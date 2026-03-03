# RDP Session Management — Admin Rights on Terminal Server

> **Objetivo:** Permitir a un usuario de dominio cerrar/desconectar sesiones RDP de otros usuarios en un Terminal Server, sin otorgarle Domain Admin.

---

## Cuándo usar esta guía

- Un usuario necesita gestionar (sign out / disconnect) sesiones RDP de otros usuarios en un Terminal Server.
- El usuario tenía este permiso en un servidor anterior y necesita replicarlo en uno nuevo.
- El cliente solicita el mínimo privilegio necesario (Local Admin es suficiente; Domain Admin NO es requerido).

---

## Credenciales necesarias

Dos credenciales distintas están involucradas — es importante entender la diferencia:

| Quién | Tipo de cuenta | Para qué |
|---|---|---|
| Tú (técnico) | `.\Administrator` (Local) | Conectarte al TS y hacer el cambio |
| Usuario destino | `DOMINIO\usuario` (Dominio) | La cuenta a la que se le otorgan permisos |

> **Nota:** Usa `.\Administrator` (con el prefijo punto-backslash) para autenticarte explícitamente como cuenta local y evitar confusión con una cuenta de dominio con el mismo nombre.

---

## Paso a Paso

### Paso 1 — Conectarse al Terminal Server

Abrir una sesión RDP al Terminal Server usando credenciales de administrador local:

- Usuario: `.\Administrator`
- Contraseña: la del administrador local del servidor

---

### Paso 2 — Abrir Computer Management

Una vez dentro del servidor, presionar `Win + R` y ejecutar:

```
compmgmt.msc
```

---

### Paso 3 — Navegar al grupo Administrators

En el panel izquierdo de Computer Management, expandir:

```
Computer Management
 └── System Tools
      └── Local Users and Groups
           └── Groups
                └── Administrators  ← doble click
```

---

### Paso 4 — Agregar el usuario de dominio

Dentro de la ventana del grupo **Administrators**:

1. Click en **Add...**
2. Escribir el usuario en formato: `DOMINIO\usuario` (ej: `PREILLY\dsimmons`)
3. Click en **Check Names** — debe resolverse y aparecer subrayado ✅
4. Click **OK** → **Apply** → **OK**

---

### Paso 5 — Verificar desde CMD

Abrir un Command Prompt en el servidor y ejecutar:

```cmd
net localgroup Administrators
```

El usuario debe aparecer en la lista. Ejemplo de output correcto:

```
Alias name     Administrators
Members
-------------------------------------------------------------------------------
Administrator
PREILLY\Domain Admins
PREILLY\dsimmons          ← ✅ confirmado
The command completed successfully.
```

---

### Paso 6 — Validar con el usuario

Pedirle al usuario que:
1. Inicie sesión en el Terminal Server.
2. Abra **Task Manager** → pestaña **Users**.
3. Haga click derecho sobre la sesión de otro usuario → **Sign out**.

---

## Comparativa de opciones

| Opción | Nivel de acceso | ¿Puede hacer Sign Out? | ¿Recomendado? |
|---|---|---|---|
| `Remote Desktop Users` | Bajo (solo RDP) | ❌ No | No — insuficiente |
| `Local Administrators` ✅ | Medio (local únicamente) | ✅ Sí | ✅ Sí — preferido |
| `Domain Admins` | Alto (todo el dominio) | ✅ Sí | No — excesivo |

---

## Notas importantes

> ⚠️ Los permisos de Local Admin otorgados aquí son **exclusivos del Terminal Server**. El usuario NO gana privilegios elevados en otros servidores ni a nivel de dominio.

> ⚠️ El grupo `Remote Desktop Users` solo permite conectarse por RDP — **NO** otorga la capacidad de cerrar sesiones de otros usuarios.

> ⚠️ **Domain Admin no es necesario** para esta tarea. Evitar otorgarlo salvo que sea explícitamente requerido y aprobado por el cliente.

> ⚠️ Si el usuario existía en un servidor anterior, verificar que no haya una cuenta local creada por error en el nuevo servidor antes de proceder.

---

## Caso de referencia

| Campo | Valor |
|---|---|
| Fecha | Marzo 2026 |
| Servidor | Terminal Server (Windows Server 2019) |
| Dominio | PREILLY |
| Usuario | `PREILLY\dsimmons` (David Simmons) |
| Acceso otorgado | Grupo Local Administrators |
| Verificado con | `net localgroup Administrators` |
