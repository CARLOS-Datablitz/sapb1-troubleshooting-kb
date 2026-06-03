# Restauración de backup histórico de Tenant E11 y export/import de schema

## 1) Resumen ejecutivo
- **Fecha:** 2024-07-09
- **Tipo de problema:** `backup-restore-db`
- **Sistema:** `hana-sles` / `sap-business-one`
- **Impacto:** Medio (requerimiento de recuperación histórica de datos)
- **Estado:** Resuelto

## 2) Síntoma inicial
Se solicita restaurar el backup del tenant `E11` correspondiente al 2024-07-02 para extraer e importar un schema en otro entorno, manteniendo trazabilidad del proceso.

## 3) Alcance e impacto
- **Afectación:** proceso controlado de recuperación (sin caída general reportada).
- **Entornos involucrados:** servidor de backups, SFTP intermedio, HANA multitenant de laboratorio y entorno destino.
- **Objetivo funcional:** disponer de schema restaurado y renombrado para validación de negocio.

## 4) Evidencia recolectada
- Confirmación de existencia del artefacto de backup del tenant `E11` en servidor de respaldo.
- Transferencia del backup al SFTP y posterior descarga al host HANA de trabajo.
- Ejecución de sentencias de creación/parada/recuperación del tenant.
- Exportación e importación de schema con resultado exitoso (sin errores en salida final).

## 5) Hipótesis evaluadas
1. **Backup inexistente o incompleto** → descartado al validar presencia del archivo y su extracción.
2. **Permisos insuficientes en rutas de restore** → mitigado ajustando ownership y permisos antes del recover.
3. **Fallo de export/import por tablas de historial** → mitigado aplicando workaround de SAP Note 2356350.

## 6) Causa raíz (RCA)
No se trató de una caída de servicio, sino de una necesidad de recuperación de datos históricos. El riesgo principal del procedimiento era operativo: rutas/permisos de filesystem y compatibilidad de import/export de objetos históricos en HANA.

## 7) Resolución aplicada
1. Validación de tenant y backup objetivo.
2. Transferencia del backup vía SFTP hacia host de procesamiento.
3. Creación de tenant de trabajo y `RECOVER DATA ... CLEAR LOG`.
4. Verificación de estado del tenant restaurado.
5. Aplicación de configuración para import/export de history tables.
6. Export de schema, compresión, transferencia por SFTP y posterior import con rename en tenant destino.
7. Validación funcional del schema restaurado.
8. Rollback de snapshots de VMs auxiliares y apagado de VMs temporales.

## 8) Validación
- Tenant `E11` quedó operativo post-restauración.
- Schema esperado quedó disponible en el entorno objetivo con nombre solicitado.
- No se reportaron errores al finalizar export/import.

## 9) Prevención
- Usar checklist pre/post para restauraciones históricas.
- Estandarizar rutas y permisos antes de correr `RECOVER`.
- Mantener plantilla de comandos con variables y sin credenciales en texto plano.
- Registrar explícitamente ventana de mantenimiento y criterio de rollback.

## 10) Relación con otros casos
- Caso origen detallado: `backups/Restaurar tenantDB fecha diferente.md`
- Casos potencialmente relacionados: guías de restore en `Restaurar un TenantDB otra fecha/` y notas de `Hana SLES/`.

## 11) Etiquetas
`backup`, `restore`, `hana-multitenant`, `tenant-e11`, `schema-export`, `schema-import`, `sftp`, `sap-b1`

## 12) Pendientes
- Sanitizar documentación histórica para eliminar credenciales en texto plano.
- Consolidar este procedimiento en un runbook único para futuras solicitudes.

