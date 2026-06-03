# Biblioteca de comandos y checkpoints reciclables

> Usa placeholders `{{}}` y nunca guardes credenciales en texto plano.
> Extraída de casos reales en Casuistica.

---

## 1) RDS — Remote Desktop Services (Windows Server)

### 1.1 Diagnóstico rápido (30 segundos)
```powershell
# Servicios críticos RDS
Get-Service TermService,Tssdis,UmRdpService,SessionEnv | Select Name,Status

# Sesiones activas
query session
qwinsta

# Puerto RDP
Test-NetConnection {{SERVER}} -Port 3389

# Último reinicio del servidor
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074} -MaxEvents 5

# Errores recientes en System
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-4)} |
  Where-Object {$_.LevelDisplayName -in @('Error','Critical')} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 30
```
**Checkpoint:** ¿Servicios stopped? ¿Puerto cerrado? ¿Reboot por Windows Update?

### 1.2 Sesiones colgadas
```powershell
# Forzar cierre de sesión por ID
logoff {{SESSION_ID}}

# Reset de sesión RDP (sin reboot)
Reset Session {{SESSION_ID}}
```
**Checkpoint:** ¿Sesiones en estado `Disc` que consumen licencias?

### 1.3 Recovery automático de servicios
```powershell
# Configurar restart automático si Tssdis se cae
sc failure Tssdis reset=86400 actions=restart/60000/restart/60000/restart/60000
```
**Checkpoint:** ¿Servicio configurado con recovery?

### 1.4 Exportar logs de sistema
```powershell
wevtutil epl System C:\Temp\systemlog_{{FECHA}}.evtx
```

### 1.5 Diagnóstico desde laptop del cliente
```powershell
nslookup {{RDS_HOST}}
ping {{RDS_HOST}}
Test-NetConnection {{RDS_HOST}} -Port 3389

# Limpiar caché RDP local
Remove-Item "$env:APPDATA\Microsoft\Terminal Server Client\Cache\*" -Force
```

---

## 2) DC / AD — Active Directory (Windows Server)

### 2.1 Políticas de contraseña
```powershell
# Ver política actual
Get-ADDefaultDomainPasswordPolicy

# Cambiar expiración a 180 días
Set-ADDefaultDomainPasswordPolicy -Identity "{{DOMAIN_FQDN}}" -MaxPasswordAge "180.00:00:00"

# Forzar actualización de GPO
gpupdate /force

# Forzar en todos los equipos del dominio
Invoke-GPUpdate -Force -RandomDelayInMinutes 0
```
**Checkpoint:** ¿MaxPasswordAge correcto? ¿MinPasswordLength seguro?

### 2.2 Diagnóstico de dominio
```powershell
# Ver DC disponible
nltest /dsgetdc:{{DOMAIN_FQDN}}

# Resolución DNS
Resolve-DnsName {{HOST}}

# Conectividad LDAP
Test-NetConnection {{DC_HOST}} -Port 389
Test-NetConnection {{DC_HOST}} -Port 53

# Ver resultado de políticas en un equipo
gpresult /h C:\gpresult.html
```
**Checkpoint:** ¿DC responde? ¿DNS funciona?

### 2.3 Eventos de seguridad
```powershell
# Cambios de contraseña (últimos 7 días)
Get-EventLog -LogName Security -After (Get-Date).AddDays(-7) |
  Where-Object {$_.EventID -eq 4724}

# Bloqueos de cuenta
Get-EventLog -LogName Security -After (Get-Date).AddDays(-1) |
  Where-Object {$_.EventID -eq 4740}
```

---

## 3) SLD / SAP B1 Server (Linux SLES)

### 3.1 Estado de servicios
```bash
# Estado del ServerTools
systemctl status sapb1servertools.service -l
systemctl status sapb1servertools-authentication.service -l

# Ver todos los servicios SAP
systemctl | grep -i b1
systemctl | grep -i servertools

# Timestamps del servicio
systemctl show sapb1servertools.service | grep -E "ActiveEnterTimestamp|InactiveEnterTimestamp|ExecMainStartTimestamp|UnitFileState"
```
**Checkpoint:** ¿Active running? ¿Habilitado para autoarranque?

### 3.2 Logs del SLD
```bash
# Últimas líneas
journalctl -u sapb1servertools.service -n 100 --no-pager

# Por fecha
journalctl -u sapb1servertools.service --since "{{YYYY-MM-DD}} 00:00:00" --no-pager -l

# Solo errores
journalctl -u sapb1servertools.service -p err --no-pager

# Logs de aplicación
tail -100 /var/opt/sap/b1/log/*.log
grep -i "error\|exception\|fatal" /var/opt/sap/b1/log/*.log | tail -50

# Logs de Tomcat
tail -f /opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/catalina.out
```
**Checkpoint:** ¿Tomcat startup completo? ¿Errores de conexión a HANA?

### 3.3 Reinicio controlado de ServerTools
```bash
# Orden correcto: primero auth STOP, luego tools STOP
systemctl stop sapb1servertools-authentication
systemctl stop sapb1servertools

# Iniciar: primero tools START, esperar, luego auth START
systemctl start sapb1servertools
tail -f /opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/catalina.out
# Esperar: "INFO: Server startup in XXXX ms"
systemctl start sapb1servertools-authentication

# Verificar
systemctl status sapb1servertools
systemctl status sapb1servertools-authentication
ss -tlnp | grep 40000
```
**Checkpoint:** ¿Puerto 40000 en LISTEN? ¿Auth service iniciado después de tools?

### 3.4 Arranque manual con USER_INSTALL_DIR
```bash
export USER_INSTALL_DIR=/usr/sap/SAPBusinessOne
/usr/sap/SAPBusinessOne/Common/support/bin/ServerToolsTomcat_service.sh start

# O como usuario de servicio
su -s /bin/bash b1service0 -c \
  "export USER_INSTALL_DIR=/usr/sap/SAPBusinessOne && \
  /usr/sap/SAPBusinessOne/Common/support/bin/ServerToolsTomcat_service.sh start"
```

### 3.5 Verificar conectividad SLD
```bash
# Health check vía HTTP
curl -k https://localhost:40000/B1i/
curl -k https://{{SLD_HOST}}:40000/B1i/

# Conexiones activas al puerto
ss -tnp | grep 40000
netstat -an | grep 40000
```

### 3.6 Diagnóstico de HANA desde SLD
```bash
# El log de arranque muestra conexión probada:
journalctl -u sapb1servertools.service --no-pager -l | grep -i "testing\|connect\|hana\|error"
```

---

## 4) HANA (Linux SLES — Multitenant)

### 4.1 Estado de HANA
```bash
# Como usuario {{SID}}adm
su - {{SID_LOWER}}adm
HDB info
HDB version

# Procesos
sapcontrol -nr {{INSTANCE_NO}} -function GetProcessList

# Salud del sistema
df -h
free -h
top -bn1 | head -20
```
**Checkpoint:** ¿Procesos HANA en verde? ¿Disco/memoria suficiente?

### 4.2 Estado de tenants
```bash
# Conectar a SYSTEMDB
hdbsql -i 00 -d SYSTEMDB -u SYSTEM -p '{{PASSWORD}}'
```
```sql
SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES;
```
**Checkpoint:** ¿Tenant en estado YES?

### 4.3 Prueba de conexión a tenant
```bash
# Probar conexión directa a tenant
hdbsql -i 00 -d {{TENANT}} -u B1SYSTEM -p '{{PASSWORD}}'

# Probar con usuario SYSTEM (no siempre funciona en tenant)
hdbsql -i 00 -d {{TENANT}} -u SYSTEM -p '{{PASSWORD}}'

# Listar schemas
"{{HDBSQL_BIN}}" -i {{INSTANCE}} -d {{TENANT}} -n {{HOST}} -u {{USER}} -p '{{PASS}}' \
  'select * from "SYS"."SCHEMAS";'
```
**Checkpoint:** ¿Conexión exitosa? ¿Authentication issue vs DB caída?

### 4.4 Diagnóstico de credenciales SLD (DB unreachable)
```sql
-- En el tenant: ver qué usuario usa SAP B1
SELECT * FROM SLDDATA."COMMONDBS";

-- Forzar re-autenticación (seguro, sin pérdida de datos)
UPDATE SLDDATA."COMPANYDBS" SET CREDENTIALLEVEL = 0;
UPDATE "SLDDATA"."COMMONDBS"
SET CREDNAME=null, CREDPASS=null, ROCREDNAME=null, ROCREDPASS=null;
```
**Checkpoint:** ¿CREDNAME coincide con B1SYSTEM? Si no → reset de credenciales SLD.

### 4.5 Export/Import de schema (flujo completo)
```bash
# 1. Preparar directorio
cd /tmp
mkdir {{SCHEMA_NAME}}
chmod -R 777 {{SCHEMA_NAME}}
chown -R {{SID}}adm:sapsys {{SCHEMA_NAME}}

# 2. Variables (desde Desktop/SAP_Configuration.txt)
dbSql="/hana/shared/{{SID}}/hdbclient/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="{{TENANT}}"
dbUser="B1SYSTEM"
dbPass="{{PASSWORD}}"

# 3. Exportar schema como binario
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" \
  'export '{{SCHEMA_ORIGEN}}'."*" as binary into '\''/tmp/{{DIR}}'\'' with ignore existing threads 10;'

# 4. Comprimir
tar -czf /tmp/{{SCHEMA_NAME}}.tar.gz /tmp/{{DIR}}

# 5. Importar con rename
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" \
  'import '{{SCHEMA_ORIGEN}}'."*" as binary from '\''/tmp/{{DIR}}'\'' with ignore existing threads 10 rename schema "{{SCHEMA_ORIGEN}}" to "{{SCHEMA_DESTINO}}";'

# 6. Limpiar
cd /tmp && rm -rf {{DIR}} {{SCHEMA_NAME}}/
```
**Checkpoint:** ¿Export sin errores? ¿Import con 0 rows affected ok? ¿Schema renombrado correctamente?

### 4.6 Subir a SFTP
```bash
sftp -P 2022 {{USER}}@{{SFTP_HOST}}
# --- dentro de sftp ---
cd /xplora/{{CLIENTE}}/
mkdir backup_{{FECHA}}
cd backup_{{FECHA}}
put {{ARCHIVO}}.tar.gz
bye
# ---

# Verificar archivos subidos
ls -lha /tmp/
```
**Checkpoint:** ¿Archivo subido correctamente?

### 4.7 Backup/Restore de tenant
```sql
-- En SYSTEMDB:
-- Crear tenant si no existe
CREATE DATABASE {{TENANT}} FOR CONTENT RESTORE;

-- Detener tenant
ALTER SYSTEM STOP DATABASE {{TENANT}};

-- Recuperar desde backup
RECOVER DATA FOR {{TENANT}} USING FILE ('{{RUTA_BACKUP}}') CLEAR LOG;

-- Iniciar tenant
ALTER SYSTEM START DATABASE {{TENANT}};
```

### 4.8 Verificar espacio y limpiar
```bash
df -h
du -sh /var/log/* | sort -rh | head -20
journalctl --vacuum-size=100M
```

---

## 5) Flujo de decisión rápida

| Síntoma | Qué revisar primero |
|---|---|
| RDS: usuario no conecta | `Test-NetConnection` puerto 3389 → `Get-Service Tssdis,TermService` → sesiones colgadas |
| RDS: nadie conecta | Servicios + reboot por Windows Update + event log 1074 |
| DB unreachable desde SAP B1 | `HDB info` → `hdbsql` a tenant → `SLDDATA.COMMONDBS` → reset credenciales |
| SLD caído | `systemctl status sapb1servertools` → `journalctl` → puerto 40000 → Tomcat |
| Export/Import schema | Variables desde SAP_Configuration.txt → test conexión → export → tar → sftp |
| AD: contraseñas | `Get-ADDefaultDomainPasswordPolicy` → `Set-ADDefaultDomainPasswordPolicy` |
