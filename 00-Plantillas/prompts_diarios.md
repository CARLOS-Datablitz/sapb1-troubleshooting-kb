# Prompts diarios para opencode

> Uso: `opencode run --dir "C:\Users\c.pecho\OneDrive - iSystems GmbH\Dokumente\Casuistica" "{{prompt}}"`

---

## 1) Normalizar caso nuevo
"Toma estas notas crudas y conviértelas en un incidente usando 00-Plantillas/plantilla_troubleshooting_operativo.md. Guárdalo en la carpeta correspondiente con nombre YYYY-MM-DD__tipo__sistema__resumen.md. Si aplica, genera también un runbook."

## 2) Buscar casos similares
"Tengo este síntoma: {{describir}}. Busca en todos los .md casos similares y dame un resumen de causas raíz y resoluciones previas."

## 3) Diagnóstico rápido RDS
"El usuario no puede conectar a RDS. Dame un plan de diagnóstico en 15 minutos priorizando: servicios, sesiones, puerto, evento 1074, y logs de Tssdis."

## 4) Diagnóstico SLD/HANA
"El SLD está caído o DB unreachable. Dame flujo de diagnóstico: verificar HANA, tenants, credenciales SLD, servicios ServerTools y logs de Tomcat."

## 5) Export/Import de schema
"Voy a exportar el schema {{origen}} e importarlo como {{destino}} en el tenant {{tenant}}. Dame el flujo completo: pre-checks, comandos, validación y limpieza."

## 6) Backup de tenant
"Necesito restaurar el tenant {{tenant}} desde un backup del {{fecha}}. Dame el procedimiento: verificar backup, recover, iniciar tenant, validar."

## 7) Subir archivo a SFTP
"Guía para subir {{archivo}} al SFTP {{host}}:2022 usuario {{user}}, ruta destino {{ruta}}, y verificar integridad."

## 8) Generar runbook desde caso
"Toma el archivo {{ruta_caso}} y conviértelo en un runbook reutilizable siguiendo la plantilla 00-Plantillas/runbook.md con pre-checks, procedimiento, validación y rollback."

## 9) Checklist pre-cambio
"Antes de ejecutar {{cambio}} en {{servidor}}, genera un checklist de validación previa y posterior con criterio de rollback."

## 10) Actualizar índice
"Escanea todas las carpetas y actualiza un INDEX.md global agrupando casos por tipo de problema y frecuencia. Incluye enlaces a cada archivo."

## 11) Sanitizar credenciales
"Revisa todos los archivos .sh y .txt en busca de credenciales en texto plano (passwords, connection strings) y sugiere reemplazos con placeholders {{}}. No modifiques archivos sin confirmación."

## 12) Extraer comandos reciclables
"Del archivo {{ruta_caso}}, extrae los comandos que ayudaron al diagnóstico y agrégalos a 00-Plantillas/biblioteca_comandos_y_checkpoints.md en la sección correspondiente."
