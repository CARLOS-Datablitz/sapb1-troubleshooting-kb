# Runbook: Restaurar backup de tenant y exportar/importar schema en SAP B1 HANA

## 1) Objetivo
Restaurar un backup histórico de un tenant HANA multitenant y exportar/importar un schema hacia el entorno solicitado, de forma controlada y repetible.

## 2) Alcance
- **Sistemas:** HANA multitenant sobre SLES, servidor SFTP, entorno SAP B1 destino.
- **Versiones:** aplicar según versión HANA vigente del cliente.
- **Dependencias:** acceso a backup, acceso SFTP, usuario técnico con permisos en SYSTEMDB y tenant.

## 3) Pre-checks obligatorios
1. Confirmar tenant objetivo, fecha de backup y nombre de schema a recuperar.
2. Validar que el archivo de backup exista y sea íntegro.
3. Verificar espacio en disco (`/backup` y `/tmp`) y permisos de usuario del sistema.
4. Confirmar ventana de mantenimiento y plan de rollback.
5. Definir credenciales desde gestor seguro (nunca en texto plano).

## 4) Procedimiento (paso a paso)
1. **Validar tipo de entorno y tenant**
   - Confirmar si el entorno es multitenant.
   - Identificar tenant, schema y host objetivo.
2. **Transferir backup al SFTP intermedio**
   - Subir el `.tgz` del backup al directorio autorizado.
3. **Preparar tenant de trabajo en HANA**
   - En `SYSTEM@SYSTEMDB`, crear tenant si no existe.
   - Detener tenant antes del recover.
4. **Preparar filesystem y descargar backup al host HANA**
   - Crear ruta de trabajo, ajustar ownership/permisos y descargar backup.
   - Extraer contenido del `.tgz`.
5. **Ejecutar recuperación del tenant**
   - Ejecutar `RECOVER DATA FOR <TENANT> USING FILE (...) CLEAR LOG;`
   - Iniciar tenant si no arranca automáticamente.
6. **Aplicar configuración previa de import/export (si corresponde)**
   - Aplicar workaround para tablas históricas (SAP Note 2356350) cuando aplique.
7. **Exportar schema**
   - Exportar schema en binario desde tenant de trabajo.
   - Comprimir resultado y subir al SFTP.
8. **Importar schema en entorno destino**
   - Descargar paquete desde SFTP.
   - Importar schema y renombrar según requerimiento.
9. **Limpieza**
   - Eliminar artefactos temporales en `/tmp` y rutas de staging.
10. **Cierre operativo**
   - Restaurar snapshots de VMs auxiliares (si aplica).
   - Mantener VMs temporales apagadas al finalizar.

## 5) Validación posterior
1. Confirmar tenant en estado activo.
2. Verificar presencia del schema importado y objetos esperados.
3. Confirmar que usuarios de negocio validan el requerimiento.
4. Documentar tiempos, comandos y evidencia.

## 6) Rollback
1. Si el recover/import falla, detener proceso y preservar evidencia.
2. Revertir snapshots de VMs auxiliares utilizadas para el procedimiento.
3. Eliminar tenant/schema de prueba si fue creado parcialmente.
4. Restaurar estado previo y notificar a stakeholders.

## 7) Señales de éxito/falla
- **Éxito:** tenant operativo, schema accesible y validación funcional aprobada.
- **Falla:** errores en `RECOVER`, export/import incompleto o inconsistencia de objetos.

## 8) Riesgos y consideraciones
- Exposición accidental de credenciales en scripts o notas.
- Permisos incorrectos en rutas de backup/restore.
- Diferencias de versión/compatibilidad al importar schemas históricos.
- Impacto por ejecutar fuera de ventana de mantenimiento.

## 9) Frecuencia recomendada de revisión
Revisar trimestralmente o tras cambios de versión HANA/SAP B1 y de políticas de seguridad.

## 10) Historial de cambios
- 2026-06-03: creación inicial del runbook a partir de caso real de restauración de tenant E11.

## 11) Snippets de referencia (credenciales saneadas)
```bash
# Variables (usar un gestor de secretos; no hardcodear contraseñas)
export SFTP_USER="{{SFTP_USER}}"
export SFTP_HOST="{{SFTP_HOST}}"
export SFTP_PORT="2022"
export HDBSQL_BIN="{{HDBSQL_BIN_PATH}}"
export HDB_INSTANCE="{{HDB_INSTANCE}}"
export HDB_HOST="{{HDB_HOST}}"
export HDB_TENANT="{{HDB_TENANT}}"
export HDB_USER="{{HDB_USER}}"
export HDB_PASS="{{HDB_PASSWORD_FROM_SECRET_MANAGER}}"

# Ejemplo de prueba de conexión
"$HDBSQL_BIN" -i "$HDB_INSTANCE" -d "$HDB_TENANT" -n "$HDB_HOST" -u "$HDB_USER" -p "$HDB_PASS" \
  'select * from "SYS"."M_DATABASES";'
```

