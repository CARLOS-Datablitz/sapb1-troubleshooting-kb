# SAP HANA License Installation Guide
**Standard Operating Procedure — License Installation via hdbsql**

---

## Prerequisites

| Requisito | Detalle |
|---|---|
| Usuario del SO | `<sid>adm` (ej: `ndbadm`, `hxeadm`) — NO ejecutar como root |
| Herramienta | `hdbsql` — solo disponible en el PATH del usuario `<sid>adm` |
| Base de datos destino | `SYSTEMDB` |
| Archivo de licencia | Proporcionado por SAP (contiene campos como `HARDWARE-KEY`, `LKEY`, etc.) |

---

## Paso 1 — Cambiar al usuario administrador de HANA

```bash
su - ndbadm
# Reemplaza "ndb" con el SID de tu instancia en minúsculas
# Ejemplos: hxeadm, s4hadm, ndbadm
```

> ⚠️ **IMPORTANTE:** Si ejecutas `hdbsql` como root u otro usuario, recibirás el error:
> `If 'hdbsql' is not a typo you can use command-not-found...`
> Siempre debes estar como `<sid>adm` antes de continuar.

---

## Paso 2 — Crear el archivo de licencia

```bash
cat > /tmp/hana_license.txt << 'EOF'
----- Begin SAP License -----
SAPSYSTEM=NDB
HARDWARE-KEY=Y3566548620
INSTNO=0021243722
BEGIN=20260414
EXPIRATION=99991231
LKEY=MIIBOgYJKoZIhvcNAQcCoIIBKzCCAScCAQExCzAJBgUrDgMCGgUA...
SWPRODUCTNAME=SAP-HANA
SWPRODUCTLIMIT=0000000064
SYSTEM-NR=000000000801082389
EOF
```

> ✅ Reemplaza el contenido con los datos reales de tu licencia SAP.

Verifica que el archivo se creó correctamente:

```bash
cat /tmp/hana_license.txt
```

Debes ver saltos de línea reales entre cada campo, NO caracteres `\n` literales.

---

## Paso 3 — Aplicar la licencia

```bash
hdbsql -u SYSTEM -p <TuPassword> -d SYSTEMDB \
  "SET SYSTEM LICENSE '$(cat /tmp/hana_license.txt)'"
```

**Respuesta esperada (éxito):**
```
0 rows affected (overall time 21.729 msec; server time 21.490 msec)
```

---

## Paso 4 — Verificar la instalación

```bash
hdbsql -u SYSTEM -p <TuPassword> -d SYSTEMDB \
  "SELECT SYSTEM_ID, HARDWARE_KEY, INSTALL_NO, START_DATE, EXPIRATION_DATE, VALID FROM M_LICENSE"
```

**Salida esperada:**
```
SYSTEM_ID,HARDWARE_KEY,INSTALL_NO,START_DATE,EXPIRATION_DATE,VALID
"NDB","Y3566548620","0021243722","2026-04-14 00:00:00.000000000",?,"TRUE"
```

| Campo | Valor Esperado | Notas |
|---|---|---|
| `SYSTEM_ID` | Tu SID | Ej: NDB, HXE, S4H |
| `HARDWARE_KEY` | Debe coincidir con la licencia | Ver nota abajo |
| `EXPIRATION_DATE` | `?` o `9999-12-31` | Licencia permanente |
| `VALID` | `TRUE` | Confirmación final |

> ℹ️ El valor `?` en `EXPIRATION_DATE` es la representación de `9999-12-31` en hdbsql — indica licencia **permanente**. No es un error.

---

## Troubleshooting — Errores Comunes

### ❌ Error: `unterminated quoted string literal`
```
* 257: sql syntax error: unterminated quoted string literal: line 1 col 20
```
**Causa:** Pegaste el texto de la licencia directamente en hdbsql con saltos de línea reales. El shell interpreta cada `Enter` como fin de comando.

**Solución:** Siempre usa el método de archivo (`cat > /tmp/hana_license.txt`) descrito en el Paso 2.

---

### ❌ Error: `could not set system license` / `$ret$=4`
```
* 436: could not set system license: exception 6999001: Failed to install a permanent license.
```
**Causa A:** La cadena de licencia contiene `\n` literales en lugar de saltos de línea reales.

**Solución A:** No uses `\n` en el comando. Usa siempre el método de archivo del Paso 2.

**Causa B:** El `HARDWARE-KEY` de la licencia no coincide con el hardware real del servidor.

**Solución B:** Verifica tu Hardware Key real:
```bash
hdbsql -u SYSTEM -p <TuPassword> -d SYSTEMDB \
  "SELECT HARDWARE_KEY FROM M_LICENSE"
```
Si no coincide, solicita una nueva licencia a SAP con el Hardware Key correcto.

---

### ❌ Error: `hdbsql: command not found`
```
If 'hdbsql' is not a typo you can use command-not-found to lookup the package...
```
**Causa:** Estás ejecutando el comando como `root` u otro usuario sin el PATH de HANA.

**Solución:** Cambiar al usuario `<sid>adm`:
```bash
su - ndbadm   # Ajusta según tu SID
```

Para identificar el usuario correcto:
```bash
cat /etc/passwd | grep adm
# o
ps aux | grep hdb
```

---

### ❌ Error: `incorrect syntax near "SAPSYSTEM"`
```
* 257: sql syntax error: incorrect syntax near "SAPSYSTEM": line 1 col 1
```
**Causa:** hdbsql está procesando cada línea de la licencia como un comando SQL separado (consecuencia del error `unterminated quoted string`).

**Solución:** Igual que el primer error — usa el método de archivo del Paso 2.

---

## Referencia Rápida — Comandos Útiles

```bash
# Ver licencia completa
hdbsql -u SYSTEM -p <password> -d SYSTEMDB "SELECT * FROM M_LICENSE"

# Ver solo campos clave
hdbsql -u SYSTEM -p <password> -d SYSTEMDB \
  "SELECT SYSTEM_ID, HARDWARE_KEY, INSTALL_NO, START_DATE, EXPIRATION_DATE, VALID FROM M_LICENSE"

# Verificar Hardware Key del servidor
hdbsql -u SYSTEM -p <password> -d SYSTEMDB \
  "SELECT HARDWARE_KEY FROM M_LICENSE"

# Identificar usuario administrador de HANA
cat /etc/passwd | grep adm
ps aux | grep hdb
```

---

## Notas Importantes

- **Nunca pegues la licencia multilínea directamente en hdbsql** — siempre usa el método de archivo.
- **El usuario `<sid>adm` es obligatorio** — root no tiene acceso a `hdbsql` en el PATH por defecto.
- **`EXPIRATION_DATE = ?`** en la salida de hdbsql equivale a `9999-12-31` — es correcto para licencias permanentes.
- **El Hardware Key es único por servidor** — una licencia generada para un servidor no funcionará en otro.
- **El archivo `/tmp/hana_license.txt`** puede eliminarse tras la instalación exitosa:
  ```bash
  rm /tmp/hana_license.txt
  ```
- **Base de datos destino:** Siempre usar `-d SYSTEMDB`. Aplicar la licencia en un tenant incorrecto causará error.

---

*Guía generada a partir de instalación real — SAP HANA SID: NDB | Fecha: Abril 2026*
