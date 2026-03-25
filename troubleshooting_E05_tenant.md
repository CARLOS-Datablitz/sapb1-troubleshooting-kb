# Troubleshooting: Fallo en Export de Base de Datos — Tenant E05 (SAP HANA)

**Fecha de análisis:** 16 de marzo de 2026  
**Sistema:** SAP HANA Multitenant — Instancia `NDB`, Instancia `00`  
**Host:** `hanamt.dctpamt092.privatcloud.biz`  
**Tenant afectado:** `E05`  
**Usuario de aplicación:** `B1SYSTEM`

---

## 1. Síntoma Inicial

Al intentar conectarse al tenant **E05** para realizar un export de base de datos, se obtuvo el siguiente error:

```
* -10709: Connection failed (RTE:[89006] System call 'connect' failed,
rc=111:Connection refused {10.3.92.2:16532 -> 10.3.92.2:30065}
(10.3.92.2:16532 -> 10.3.92.2:30065)) SQLSTATE: HY000
```

**Comando que generó el error:**
```bash
dbSql="/hana/shared/NDB/hdbclient/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E05"
dbUser="B1SYSTEM"
dbPass="lyGF9D99flLVpf7V"

"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" \
  'select * from "SYS"."SCHEMAS";'
```

**Interpretación del error:**  
El error `rc=111: Connection refused` indica que ningún proceso estaba escuchando en el puerto `30065` (puerto SQL del tenant E05 con instancia `00`). Esto apunta directamente a que el tenant no está activo.

---

## 2. Paso 1 — Verificar Estado General de la Instancia HANA

**Comando ejecutado:**
```bash
sapcontrol -nr 00 -function GetProcessList
```

**Resultado relevante:**  
Todos los procesos de HANA estaban en estado `GREEN / Running`, pero **no aparecía ningún `hdbindexserver` para E05**, mientras que sí existían para E01, E03, E04, E06, E07, E08, E09, E10, E11, E13, E14, E15 y NDB.

**Conclusión:** La instancia HANA está saludable, pero el tenant E05 no tiene proceso activo.

---

## 3. Paso 2 — Verificar Estado de Todos los Tenants

**Comando ejecutado:**
```bash
"$dbSql" -i "$dbInstance" -n "$dbHost" -u SYSTEM -p "$dbPass" -d SYSTEMDB \
  'SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES;'
```

**Resultado:**

| DATABASE_NAME | ACTIVE_STATUS |
|---|---|
| SYSTEMDB | YES |
| E01 | YES |
| E02 | **NO** |
| E03 | YES |
| E04 | YES |
| **E05** | **NO** ← Tenant afectado |
| E06 | YES |
| E07 | YES |
| E08 | YES |
| E09 | YES |
| E10 | YES |
| E11 | YES |
| E12 | **NO** |
| E13 | YES |
| E14 | YES |
| E15 | YES |
| NDB | YES |

**Conclusión:** El tenant **E05 está detenido** (`ACTIVE_STATUS = NO`). Esto confirma la causa raíz del error de conexión. También se observa que E02 y E12 están igualmente inactivos.

---

## 4. Paso 3 — Investigar Cuándo y Cómo se Detuvo E05

### 4.1 Búsqueda en vistas del sistema

Se intentó consultar `SYS.M_DATABASE_HISTORY`, pero la vista no existe en esta versión de HANA:

```bash
"$dbSql" -i "$dbInstance" -n "$dbHost" -u SYSTEM -p "$dbPass" -d SYSTEMDB \
  'SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
   WHERE TABLE_NAME = '"'"'M_DATABASE_HISTORY'"'"'
   ORDER BY POSITION;'
# Resultado: 0 rows selected
```

### 4.2 Búsqueda en el trace del nameserver ✅

**Comando ejecutado:**
```bash
grep -iE "E05.*(stop|start|shutdown|deactivat)" \
  /hana/shared/NDB/HDB00/*/trace/nameserver*.trc | tail -30
```

**Resultado:**
```
nameserver_hanamt...30001.010.trc:[5528]{158944}[30/-1] 2026-02-13 18:24:39.049687
  i MultiDB MDCRequestHandler.cpp(01337) :
  Stop database E05(8) : Stopped by user via ALTER SYSTEM STOP DATABASE

nameserver_hanamt...30001.010.trc:[5194]{158944}[30/-1] 2026-02-13 18:27:50.698209
  i MultiDB MDCRequestHandler.cpp(01337) :
  Stop database E05(8) : Stopped by user via ALTER SYSTEM STOP DATABASE

nameserver_hanamt...30001.011.trc:[5516]{165509}[30/-1] 2026-02-25 03:31:59.460285
  i MultiDB MDCRequestHandler.cpp(01337) :
  Stop database E05(8) : Stopped by user via ALTER SYSTEM STOP DATABASE
```

---

## 5. Conclusión — Causa Raíz Confirmada

El tenant **E05 fue detenido manualmente** en tres ocasiones mediante el comando `ALTER SYSTEM STOP DATABASE`:

| # | Fecha y Hora (UTC-5) | Método |
|---|---|---|
| 1 | **2026-02-13 18:24:39** | `ALTER SYSTEM STOP DATABASE` — manual |
| 2 | **2026-02-13 18:27:50** | `ALTER SYSTEM STOP DATABASE` — manual (reintento) |
| 3 | **2026-02-25 03:31:59** | `ALTER SYSTEM STOP DATABASE` — manual ← **última parada** |

> **El tenant E05 lleva detenido desde el 25 de febrero de 2026 (03:31 AM).**  
> No existe evidencia de crash, corrupción de datos ni errores internos.  
> La parada fue **intencional y ejecutada por un usuario del sistema**.

El audit log de HANA no tiene registros del usuario específico que ejecutó el comando (`SYS.AUDIT_LOG` retornó 0 filas), lo que indica que la auditoría no estaba habilitada para este tipo de operaciones en ese momento.

---

## 6. Próximos Pasos Recomendados

### 6.1 Identificar al responsable de la parada (opcional)
```bash
# Buscar contexto de sesión por connection ID {158944}
grep "{158944}" \
  /hana/shared/NDB/HDB00/*/trace/nameserver*.trc | \
  grep -iE "user|login|connect|session" | head -20
```

### 6.2 Iniciar el tenant E05
Una vez confirmado que es seguro levantarlo:
```bash
"$dbSql" -i "$dbInstance" -n "$dbHost" -u SYSTEM -p "$dbPass" -d SYSTEMDB \
  'ALTER SYSTEM START DATABASE E05;'
```

### 6.3 Verificar que levantó correctamente
```bash
# Verificar estado en M_DATABASES
"$dbSql" -i "$dbInstance" -n "$dbHost" -u SYSTEM -p "$dbPass" -d SYSTEMDB \
  'SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES WHERE DATABASE_NAME = '"'"'E05'"'"';'

# Verificar proceso indexserver
sapcontrol -nr 00 -function GetProcessList | grep E05
```

### 6.4 Reintentar el export original
```bash
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" \
  'select * from "SYS"."SCHEMAS";'
```

### 6.5 Habilitar auditoría para futuras investigaciones
Para evitar no poder identificar quién ejecuta comandos críticos en el futuro:
```sql
-- Ejecutar en SYSTEMDB
ALTER SYSTEM ALTER CONFIGURATION ('global.ini', 'SYSTEM')
  SET ('auditing configuration', 'global_auditing_state') = 'true'
  WITH RECONFIGURE;
```

---

*Documento generado como resultado del proceso de troubleshooting — SAP HANA Multitenant*
