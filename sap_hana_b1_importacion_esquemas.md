# SAP HANA + SAP Business One: Importación de Esquemas

> Resumen técnico del proceso de exportación/importación de schemas entre ambientes de producción y pruebas.

---

## 1. Arquitectura: ¿Cómo se Relacionan HANA y Business One?

SAP HANA es el **motor de base de datos in-memory** donde se almacenan todos los datos de Business One (clientes, facturas, inventario, etc.). SAP Business One es el **sistema ERP (aplicación)** que usa HANA como su base de datos — es la interfaz donde los usuarios trabajan.

```
┌─────────────────────┐         ┌─────────────────────┐
│  SAP BUSINESS ONE   │ ◄─────► │     SAP HANA        │
│   (Aplicación)      │  TCP/IP │  (Base de Datos)    │
│                     │         │                     │
│ • Service Layer     │ Puerto  │ • Tenant Databases  │
│ • Server Tools      │  30013  │ • IndexServer       │
│ • License Manager   │         │ • NameServer        │
└─────────────────────┘         └─────────────────────┘
```

> **Sin HANA = Sin datos = Sin Business One**

---

## 2. Concepto Clave: Schema vs Tenant Database

Este es el punto más importante para entender la importación de esquemas.

En un ambiente SAP B1 típico, **no hay un tenant por empresa**. En cambio, **todas las empresas B1 viven como schemas dentro de un único tenant HANA**.

```
┌─────────────────────────────────────────────────────┐
│  SAP HANA Tenant: NDB (o E15, etc.)                 │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │   TTG_PROD   │  │  SBO-COMMON  │  │  _SYS_*  │  │
│  │   (schema)   │  │   (schema)   │  │ (system) │  │
│  └──────────────┘  └──────────────┘  └──────────┘  │
│                                                     │
│  Todos son SCHEMAS dentro del MISMO tenant          │
└─────────────────────────────────────────────────────┘
```

### SBO-COMMON: El Schema Más Crítico

`SBO-COMMON` actúa como el **catálogo central** de todas las empresas B1 registradas en el servidor. Todas las empresas del servidor comparten este repositorio.

- Si `SBO-COMMON` está corrupto o inaccesible → **ninguna empresa puede usarse**, aunque los schemas individuales estén perfectamente bien.
- Tras importar un schema, B1 lo registra aquí para que aparezca disponible en el login del cliente.

---

## 3. Flujo de Exportación / Importación entre Ambientes

```
AMBIENTE PRODUCCIÓN                    AMBIENTE PRUEBAS
──────────────────                     ────────────────

HANA Tenant: E15                       HANA Tenant: NDB
  └─ Schema: TTG_PROD  ──EXPORT──►  /tmp/esquema_01/TTG_PROD/
  └─ Schema: SBO-COMMON                    │
                                           │  hdbsql IMPORT
                                           ▼
                                       HANA Tenant: NDB
                                         └─ Schema: TTG_PROD  ✓ (creado)
                                         └─ Schema: SBO-COMMON (debe existir)
                                                │
                                                │ SAP B1 Client
                                                │ "Import Schema"
                                                ▼
                                       B1 lee TTG_PROD desde
                                       SBO-COMMON y lo registra
                                       en el Server Tools
```

> **Nota importante:** El schema no "recuerda" de qué tenant vino. HANA lo recrea por su nombre (`TTG_PROD`) independientemente del tenant de origen (`E15`). El import es completamente portátil entre tenants.

---

## 4. El Comando IMPORT: Anatomía y Explicación

```bash
dbSql="/hana/shared/NDB/HDB00/exe/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="NDB"
dbUser="B1SYSTEM"
dbPass="Test1234"

"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" \
'IMPORT 'TTG_PROD'."*" AS BINARY FROM '/tmp/esquema_01/TTG_PROD/' WITH IGNORE EXISTING THREADS 10;'
```

### Parámetros explicados

| Parámetro | Valor | Descripción |
|---|---|---|
| `-i` | `00` | Número de instancia HANA |
| `-d` | `NDB` | Tenant de destino donde se importa |
| `-n` | `127.0.0.1` | Host (local, desde el mismo servidor HANA) |
| `-u` | `B1SYSTEM` | Usuario con permisos de importación |
| `TTG_PROD'."*"` | — | Todo el schema TTG_PROD (tablas, vistas, datos, índices) |
| `AS BINARY` | — | Formato del export previo (binario) |
| `FROM '...'` | `/tmp/esquema_01/TTG_PROD/` | Carpeta con los archivos exportados |
| `IGNORE EXISTING` | — | Si algo ya existe, no falla — lo omite |
| `THREADS 10` | `10` | Paralelismo para acelerar la importación |

### ¿Qué hace HANA internamente al ejecutar el IMPORT?

```
/tmp/esquema_01/TTG_PROD/   (archivos .gz, .csv, control files)
         │
         │  hdbsql IMPORT command
         ▼
HANA crea el SCHEMA "TTG_PROD" dentro del tenant NDB
         │
         │  Recrea tablas, vistas, procedures,
         │  índices y carga todos los datos
         ▼
Schema TTG_PROD queda disponible en el tenant NDB
```

---

## 5. El Paso Final: Import Schema desde SAP B1 Client

Una vez que el comando `IMPORT` termina y el schema `TTG_PROD` existe en HANA, **el cliente B1 aún no lo conoce**. Es necesario registrarlo.

### ¿Qué hace el "Import Schema" del cliente B1?

```
SAP B1 Client (Windows Server RDS)
     │
     │  1. Usuario inicia "Import Schema"
     ▼
SAP B1 Server Tools (Service Layer)
     │
     │  2. Se conecta al tenant NDB vía puerto 30013
     │  3. Detecta TTG_PROD y verifica tabla OADM
     │     (firma que identifica una empresa B1)
     ▼
SBO-COMMON (en HANA)
     │
     │  4. Registra TTG_PROD como empresa disponible:
     │     - Nombre de empresa
     │     - Schema HANA asociado
     │     - Servidor y puerto
     │     - Versión de B1
     ▼
SAP B1 Client
     └─ La empresa aparece disponible en el login ✓
```

### Relación final establecida

```
┌─────────────────────────────────────────────────────────┐
│              SAP HANA Server (Pruebas)                  │
│                                                         │
│  Tenant NDB                                             │
│    ├─ SBO-COMMON → catálogo: "TTG_PROD registrada"      │
│    └─ TTG_PROD   → tablas: OADM, OCRD, OINV, etc.      │
└────────────────────────┬────────────────────────────────┘
                         │ TCP 30013
┌────────────────────────▼────────────────────────────────┐
│              SAP B1 Server Tools                        │
│    b1s.conf → "NDB@hana-pruebas.servidor.biz:30013"    │
│    Service Layer sirve requests del cliente             │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS 50000
┌────────────────────────▼────────────────────────────────┐
│         SAP B1 Client (Windows Server RDS 2019)         │
│    └─ Login → selecciona empresa "TTG_PROD" ✓           │
└─────────────────────────────────────────────────────────┘
```

---

## 6. Errores Comunes Durante el Proceso

| Error | Causa real | Dónde verificar |
|---|---|---|
| Schema no aparece en B1 | Falta el paso "Import Schema" desde el cliente | Ejecutar Import Schema en B1 Client |
| `Authentication failed` | B1SYSTEM sin permisos sobre el schema en el tenant | `SELECT * FROM SYS.USERS WHERE USER_NAME = 'B1SYSTEM'` en HANA |
| Schema ya existe / conflicto | Import previo sin limpiar — `IGNORE EXISTING` lo maneja | Usar `IGNORE EXISTING` o hacer DROP del schema primero |
| Inconsistencia en SBO-COMMON | Registro previo de TTG_PROD en SBO-COMMON desactualizado | Re-ejecutar "Import Schema" desde B1 Client para reconciliar |
| `Disk full` durante import | `/hana/data` sin espacio (los binarios se expanden al importar) | `df -h` — verificar espacio antes de importar |
| Archivos de export incompletos | La carpeta `/tmp/` tiene un export parcial o corrupto | Verificar que existan los archivos control + datos en la carpeta |
| `Connection refused` al importar desde B1 | Puerto 30013 cerrado o HANA caído | `nc -zv <hana_host> 30013` desde el servidor B1 |

---

## 7. Checklist del Proceso Completo

### Antes de importar
- [ ] Verificar espacio disponible en `/hana/data` (debe tener margen suficiente para el schema expandido)
- [ ] Confirmar que los archivos del export están completos en `/tmp/esquema_01/TTG_PROD/`
- [ ] Confirmar que el tenant destino (`NDB`) está `ACTIVE` en HANA
- [ ] Confirmar que `SBO-COMMON` existe en el tenant destino
- [ ] Verificar que `B1SYSTEM` tiene permisos en el tenant destino

### Ejecutar import
- [ ] Correr el comando `hdbsql IMPORT` con los parámetros correctos
- [ ] Esperar a que termine (sin interrumpir — puede tomar varios minutos)
- [ ] Verificar que no hubo errores en la salida del comando

### Después del import
- [ ] Confirmar que el schema aparece en HANA: `SELECT SCHEMA_NAME FROM SYS.SCHEMAS WHERE SCHEMA_NAME = 'TTG_PROD'`
- [ ] Ejecutar "Import Schema" desde SAP B1 Client
- [ ] Verificar que la empresa aparece disponible en el login de B1
- [ ] Hacer login de prueba en la empresa importada

---

## 8. Comandos de Referencia Rápida

```bash
# Verificar que el schema fue creado en HANA
hdbsql -i 00 -d NDB -n 127.0.0.1 -u B1SYSTEM -p <password> \
  "SELECT SCHEMA_NAME FROM SYS.SCHEMAS WHERE SCHEMA_NAME = 'TTG_PROD';"

# Verificar que el tenant destino está activo
hdbsql -i 00 -d SYSTEMDB -n 127.0.0.1 -u SYSTEM -p <password> \
  "SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES;"

# Verificar espacio antes de importar
df -h /hana/data

# Verificar estado de HANA
su - ndbadm
HDB info

# Ver puertos escuchando (confirmar tenant activo)
ss -tuln | grep :300
```

---

*Documento generado a partir de sesión técnica de troubleshooting y análisis de arquitectura SAP HANA + SAP Business One.*
*Ambiente de referencia: SLES 15 SP4, SAP HANA NDB/E15, SAP B1 Service Layer, Windows Server 2019 RDS.*
