# Diagnóstico de Conexión RDS desde Laptop del Cliente

Este procedimiento permite verificar rápidamente problemas de conexión
al servidor RDS **tacticademo.privatcloud.biz** desde la computadora del
usuario.

------------------------------------------------------------------------

## 1. Verificar resolución DNS

Abrir **Command Prompt (CMD)** y ejecutar:

    nslookup tacticademo.privatcloud.biz

Resultado esperado:

    Name: tacticademo.privatcloud.biz
    Address: X.X.X.X

Si **no devuelve una IP**, existe un problema de **DNS**.

------------------------------------------------------------------------

## 2. Verificar conectividad al servidor

En **CMD** ejecutar:

    ping tacticademo.privatcloud.biz

Posibles resultados:

-   **Responde** → El servidor es alcanzable.
-   **No responde** → Puede existir un problema de red, firewall o VPN.

------------------------------------------------------------------------

## 3. Verificar acceso al puerto RDP (3389)

Abrir **PowerShell** y ejecutar:

    Test-NetConnection tacticademo.privatcloud.biz -Port 3389

Resultado clave:

    TcpTestSucceeded : True

Interpretación:

-   **True** → El puerto RDP está accesible.
-   **False** → Firewall o red bloqueando el acceso.

------------------------------------------------------------------------

## 4. Probar conexión usando la IP

Abrir **Remote Desktop Connection**:

    mstsc

Intentar conectarse usando la **IP del servidor** en lugar del nombre.

Ejemplo:

    mstsc /v:10.x.x.x

Si funciona con IP pero no con nombre → problema de **DNS o
certificado**.

------------------------------------------------------------------------

## 5. Revisar configuración de RDP Gateway

Abrir **Remote Desktop Connection**:

1.  Clic en **Show Options**
2.  Ir a **Advanced**
3.  Clic en **Settings**

Revisar si hay configurado un **Gateway Server** incorrecto.

------------------------------------------------------------------------

## 6. Limpiar caché de Remote Desktop

Presionar **Win + R** y ejecutar:

    %appdata%\Microsoft\Terminal Server Client\Cache

Eliminar los archivos dentro de esa carpeta.

------------------------------------------------------------------------

## 7. Verificar si el problema afecta a todos los usuarios

Preguntar al cliente:

-   ¿El problema ocurre en **todas las computadoras**?
-   ¿Solo ocurre en **esta laptop**?

Si solo ocurre en una laptop, puede ser causado por:

-   Firewall local
-   Antivirus
-   Caché de RDP
-   Certificados

------------------------------------------------------------------------

## 8. Verificar certificados instalados

Abrir:

    certmgr.msc

Revisar en:

    Trusted Root Certification Authorities

Verificar que el certificado del servidor esté instalado si el entorno
lo requiere.

------------------------------------------------------------------------

## Prueba rápida recomendada

El comando más rápido para detectar el problema:

    Test-NetConnection tacticademo.privatcloud.biz -Port 3389

Este comando permite determinar en segundos si el puerto RDP está
accesible desde la laptop del usuario.
