# Troubleshooting: OutOfMemoryError Java Heap Space — SAP Business One Authentication Service

**Sistema:** SUSE Linux Enterprise (SLD)  
**Servicio afectado:** `sapb1servertools-authentication.service` (Keycloak)  
**Error:** `java.lang.OutOfMemoryError: Java heap space`  
**Fecha de diagnóstico:** Febrero 2026

---

## 1. Descripción del problema

El servicio de autenticación de SAP Business One (`sapb1servertools-authentication.service`), que internamente ejecuta **Keycloak** como proveedor de identidad, terminaba abruptamente con el siguiente error en los logs:

```
Feb 11 13:49:29 sld startup.sh[3681]: Terminating due to java.lang.OutOfMemoryError: Java heap space
```

El servicio aparecía en estado **`active (exited)`**, lo que indica que arrancó correctamente pero el proceso terminó de forma inesperada durante su ejecución.

### ¿Qué es el Java Heap Space?

La JVM (Java Virtual Machine) reserva una región de memoria llamada **heap** para almacenar objetos en tiempo de ejecución. Cuando esta región se llena y el recolector de basura (Garbage Collector) no puede liberar suficiente memoria, la JVM lanza un `OutOfMemoryError` y el proceso muere.

Si no se configuran los parámetros `-Xms` (mínimo) y `-Xmx` (máximo), la JVM asigna valores por defecto que suelen ser muy conservadores (~256MB a 512MB), insuficientes para una aplicación como Keycloak bajo carga real.

---

## 2. Proceso de diagnóstico paso a paso

### Paso 1 — Verificar el estado del servicio y los logs iniciales

**Comando ejecutado:**
```bash
systemctl status sapb1servertools-authentication.service
```

**Lógica:** Este es siempre el primer paso ante cualquier fallo de servicio en systemd. Nos muestra el estado actual, la última vez que estuvo activo y las últimas líneas del journal, donde pudimos identificar claramente el error `OutOfMemoryError: Java heap space`.

---

### Paso 2 — Revisar la configuración de heap en el script de arranque

**Comando ejecutado:**
```bash
cat /usr/sap/SAPBusinessOne/Common/keycloak/bin/startup.sh | grep -i heap
```

**Lógica:** El `startup.sh` es el punto de entrada del servicio. Si hubiera parámetros de heap configurados, estarían aquí. El comando `grep -i heap` filtra solo las líneas relevantes para no leer el archivo completo.

**Resultado:** Sin salida — no hay configuración de heap en este archivo.

---

### Paso 3 — Verificar memoria disponible en el servidor

**Comando ejecutado:**
```bash
free -h
```

**Resultado:**
```
               total        used        free      shared  buff/cache   available
Mem:            31Gi        20Gi        10Gi       173Mi       1.5Gi        10Gi
Swap:          2.0Gi          0B       2.0Gi
```

**Lógica:** Antes de aumentar el heap, debemos confirmar que el servidor tiene RAM suficiente. Con **10GB disponibles** de 31GB totales, hay margen más que suficiente para aumentar la memoria asignada a Keycloak sin comprometer otros procesos (HANA, SAP B1, etc.).

---

### Paso 4 — Leer el script de arranque completo para entender la cadena de ejecución

**Comando ejecutado:**
```bash
cat /usr/sap/SAPBusinessOne/Common/keycloak/bin/startup.sh
```

**Lógica:** Al no encontrar configuración de heap con `grep`, se leyó el archivo completo para entender cómo arranca el proceso. Se identificó que el startup.sh llama a:

```bash
"${INSTALL_DIR}/kc.sh" -cf "${INSTALL_DIR}/../conf/sapb1.conf" "start"
```

Es decir, el verdadero punto de configuración está en **`sapb1.conf`** y en los archivos que `kc.sh` (wrapper de Keycloak) pueda leer.

---

### Paso 5 — Revisar el archivo de configuración de Keycloak

**Comandos ejecutados:**
```bash
cat /usr/sap/SAPBusinessOne/Common/keycloak/conf/sapb1.conf
ls /usr/sap/SAPBusinessOne/Common/keycloak/conf/
```

**Lógica:** Siguiendo la cadena identificada en el paso anterior, se inspeccionó `sapb1.conf`. No contenía parámetros JVM. Sin embargo, el listado del directorio reveló la existencia de **`env.conf`**, que en Keycloak es el archivo estándar para variables de entorno de la JVM.

---

### Paso 6 — Inspeccionar env.conf — El archivo clave

**Comando ejecutado:**
```bash
cat /usr/sap/SAPBusinessOne/Common/keycloak/conf/env.conf
```

**Resultado:**
```bash
JAVA_HOME='/usr/sap/SAPBusinessOne/Common/sapmachine_17'
JAVA='/usr/sap/SAPBusinessOne/Common/sapmachine_17/bin/java'
SLD_INSTALLER_TOOL_PATH='/usr/sap/SAPBusinessOne/Common/support/bin/SLDInstallerTool.jar'
HDBSQL='/usr/sap/hdbclient/hdbsql'
HANA_HOST=hana.sthamer.local
HANA_INSTANCE=00
HANA_TENANT_DB=NDB
HANA_USER_PROTECTED='R0V1NnhYaUNWTVFwvgzoWxHbxR/tr5N8z7G4ujvn4fKWNQld'
HANA_PASSWORD_PROTECTED='WG1GQ3Q1Snd6b2haE8lWkiaw2DHMsXtgwBMvGmW/qzB89ADm'
HTTPS_KEYSTORE_PASSWORD_PROTECTED='S1JJeFhlWTdHbDd1GnEUMYU/M9rt56I6B9tHqc5TDcML9vU='
JAVA_OPTS_APPEND='-Djavax.net.ssl.trustStore=/var/lib/ca-certificates/java-cacerts'
```

**Diagnóstico confirmado:** La variable `JAVA_OPTS_APPEND` existe pero **no contiene parámetros de heap** (`-Xms` / `-Xmx`). La JVM usa valores por defecto, que son insuficientes para Keycloak.

---

## 3. Solución aplicada

### Paso 7 — Backup y modificación de env.conf

**Backup de seguridad:**
```bash
cp /usr/sap/SAPBusinessOne/Common/keycloak/conf/env.conf \
   /usr/sap/SAPBusinessOne/Common/keycloak/conf/env.conf.bak
```

**Aplicación del fix:**
```bash
sed -i "s|JAVA_OPTS_APPEND='-Djavax.net.ssl.trustStore=/var/lib/ca-certificates/java-cacerts'|JAVA_OPTS_APPEND='-Djavax.net.ssl.trustStore=/var/lib/ca-certificates/java-cacerts -Xms512m -Xmx2048m'|" \
   /usr/sap/SAPBusinessOne/Common/keycloak/conf/env.conf
```

**Verificación:**
```bash
cat /usr/sap/SAPBusinessOne/Common/keycloak/conf/env.conf
```

### ¿Por qué estos valores de heap?

| Parámetro | Valor | Significado |
|-----------|-------|-------------|
| `-Xms512m` | 512 MB | Heap mínimo inicial que la JVM reserva al arrancar |
| `-Xmx2048m` | 2 GB | Heap máximo que la JVM puede usar |

Con 10GB de RAM disponible en el servidor, asignar 2GB a Keycloak es razonable y deja margen amplio para HANA y los demás procesos de SAP B1.

---

### Paso 8 — Reiniciar el servicio y verificar

```bash
systemctl restart sapb1servertools-authentication.service
systemctl status sapb1servertools-authentication.service
```

Se debe esperar unos segundos ya que Keycloak necesita tiempo para inicializar la conexión con HANA y levantar el servidor Quarkus.

---

## 4. Resumen del diagnóstico

```
Síntoma
  └─> OOM en logs del servicio Keycloak
        └─> startup.sh sin parámetros heap
              └─> sapb1.conf sin parámetros JVM
                    └─> env.conf: JAVA_OPTS_APPEND sin -Xms/-Xmx
                          └─> SOLUCIÓN: agregar -Xms512m -Xmx2048m
```

---

## 5. Prevención futura

- Monitorear el consumo de heap con herramientas como `jcmd` o revisando los logs de Keycloak en `/usr/sap/SAPBusinessOne/Common/keycloak/bin/sapb1authentication.log`.
- Si el error vuelve a ocurrir con `-Xmx2048m`, considerar aumentar a `-Xmx3072m` o `-Xmx4096m`.
- Revisar si existen memory leaks en extensiones o configuraciones personalizadas de Keycloak.

---

*Documento generado como resultado del troubleshooting realizado en el sistema SLD.*
