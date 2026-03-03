# RDS - Cómo llegar a "Configure Session Settings"

## Ruta de navegación

**Server Manager → Remote Desktop Services → Collections → [Nombre de la Colección]**

---

## Pasos detallados

1. Abrir **Server Manager** en el servidor RDS.

2. En el panel izquierdo, hacer clic en **Remote Desktop Services**.

3. Hacer clic en **Collections**.

4. En la lista de colecciones, hacer clic directamente sobre el **nombre de la colección** que se desea configurar (por ejemplo: "SAP"). Esto te lleva a la vista interna de esa colección.

5. Una vez dentro de la colección, en el panel **PROPERTIES** (parte superior izquierda), hacer clic en **TASKS** → **Edit Properties**.

6. Se abrirá la ventana **"[Nombre] Properties"**. En el menú izquierdo, seleccionar **Session**.

7. Aparecerá la pantalla **"Configure Session Settings"**.

---

## Opciones disponibles y para qué sirve cada una

### End a disconnected session
Define cuánto tiempo el servidor mantiene viva una sesión después de que el usuario se desconectó (cerró la ventana RDP sin hacer log off).

- **Never**: La sesión permanece activa indefinidamente hasta que el usuario vuelva a conectarse o haga log off manualmente.
- **Tiempo definido (ej. 2 hours)**: Pasado ese tiempo, el servidor termina la sesión automáticamente, liberando recursos.

> ⚠️ Si está en "Never" y los usuarios no hacen log off correctamente, pueden acumularse sesiones huérfanas que consumen memoria y licencias RDS.

---

### Active session limit
Define el tiempo máximo que una sesión puede estar **activa y en uso** antes de ser desconectada o terminada, independientemente de si el usuario está trabajando o no.

- **Never**: No hay límite de tiempo para sesiones activas.
- **Tiempo definido**: Pasado ese tiempo, el servidor aplica la acción configurada (desconectar o terminar sesión).

> Generalmente se deja en "Never" para no interrumpir al usuario mientras trabaja.

---

### Idle session limit
Define cuánto tiempo puede estar una sesión **activa pero sin actividad de teclado o mouse** antes de ser desconectada o terminada.

- **Never**: El servidor nunca desconecta sesiones por inactividad.
- **Tiempo definido (ej. 2 hours)**: Si el usuario no interactúa durante ese tiempo, el servidor aplica la acción configurada.

> Es útil para liberar recursos y licencias de usuarios que olvidaron cerrar su sesión.

---

### When a session limit is reached or a connection is broken

Define qué hacer cuando se cumple alguno de los límites anteriores o se cae la conexión:

- **Disconnect from the session**: El servidor desconecta al usuario pero mantiene la sesión viva en memoria. El usuario puede reconectarse y retomar desde donde estaba.
  - **Enable automatic reconnection**: Si está marcado, el cliente RDP intentará reconectarse automáticamente al servidor.
- **End the session**: El servidor termina y elimina la sesión completamente. El usuario pierde el trabajo no guardado.

---

### Temporary folder settings

- **Delete temporary folders on exit**: Al cerrar la sesión, se eliminan los archivos temporales generados durante la misma.
- **Use temporary folders per session**: Cada sesión tiene su propia carpeta temporal independiente, evitando conflictos entre usuarios.

---

## Resumen visual de la ruta

```
Server Manager
  └── Remote Desktop Services
        └── Collections
              └── [Clic en la colección, ej: SAP]
                    └── PROPERTIES > TASKS > Edit Properties
                          └── Session  ← aquí está Configure Session Settings
```
