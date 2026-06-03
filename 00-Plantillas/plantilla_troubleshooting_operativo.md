# Plantilla de Troubleshooting Operativo (paso a paso)

> Objetivo: resolver el incidente con método, registrando qué se revisó, qué comando se ejecutó, qué resultado devolvió y qué decisión se tomó.

## 0) Metadatos del caso
- **Ticket / Incidente:**
- **Fecha y hora de inicio:**
- **Cliente / Entorno:**
- **Tipo de problema (taxonomía):**
- **Servicios críticos afectados:**
- **Severidad (Alta/Media/Baja):**

## 1) Planteamiento del problema
Define el problema en una sola frase:
- **Problema observado:**
- **Síntoma principal:**
- **Desde cuándo ocurre:**
- **Cambios recientes conocidos (parches, reinicios, certificados, usuarios, red):**
- **Alcance (quiénes/sistemas afectados):**

## 2) Objetivo de resolución
- **Qué significa “resuelto” para este caso:**
- **Tiempo objetivo de diagnóstico inicial (ej. 15 min):**
- **Riesgos operativos si no se resuelve pronto:**

## 3) Hipótesis iniciales (priorizadas)
Para cada hipótesis, define evidencia esperada.

### H1:
- **Descripción:**
- **Qué evidencia la confirma:**
- **Qué evidencia la descarta:**

### H2:
- **Descripción:**
- **Qué evidencia la confirma:**
- **Qué evidencia la descarta:**

### H3:
- **Descripción:**
- **Qué evidencia la confirma:**
- **Qué evidencia la descarta:**

## 4) Checklist de revisión por capas
Marca cada punto como: `pendiente`, `ok`, `fallo`, `no-aplica`.

### 4.1 Red y conectividad
- DNS resuelve hostnames críticos
- Puertos críticos accesibles
- Latencia o pérdida anormal
- Sesiones RDP/SSH posibles

### 4.2 Sistema operativo
- CPU/Memoria/Disco dentro de umbrales
- Hora/NTP correcta
- Servicios base del SO en estado esperado
- Eventos de error recientes

### 4.3 Servicios de aplicación
- Servicios SAP B1/SLD/Service Layer activos
- Dependencias entre servicios correctas
- Certificados vigentes y accesibles

### 4.4 Base de datos HANA
- Tenant/SystemDB en estado correcto
- Conectividad hacia DB confirmada
- Alertas de logs/trace relevantes
- Operaciones recientes (backup/restore/import) consistentes

## 5) Ejecución del troubleshooting (bitácora técnica)
Usa este bloque en orden cronológico. Repite tantas veces como sea necesario.

### Paso N
- **Hora:**
- **Servidor/Rol:** (RDS / ADM / DC / TS01 / HANA / SLD / otro)
- **Objetivo del paso:** (qué quiero comprobar)
- **Comando o acción ejecutada:**
- **Salida relevante (texto corto):**
- **Interpretación técnica:**
- **Decisión siguiente:** (continuar / cambiar hipótesis / escalar)

## 6) Logs y evidencias relevantes
Registra solo hallazgos útiles (no ruido).

### Evidencia N
- **Origen:** (archivo log / visor de eventos / consola / query)
- **Ruta o referencia:**
- **Filtro usado:**
- **Hallazgo clave:**
- **Relación con hipótesis:**

## 7) Resolución aplicada
- **Cambio aplicado:**
- **Servidor(es) intervenidos:**
- **Orden de ejecución:**
- **Riesgo del cambio:**
- **Plan de rollback preparado:** (sí/no, detallar)

## 8) Validación de resolución
- **Prueba funcional principal:**
- **Pruebas secundarias:**
- **Resultado final:** (resuelto / parcial / no resuelto)
- **Evidencia de validación:**

## 9) Cierre y aprendizaje reutilizable
- **Causa raíz confirmada:**
- **Comando(s) que más ayudaron:**
- **Punto de revisión más determinante:**
- **Qué automatizar o convertir en runbook:**
- **Tags sugeridos:**

## 10) Comandos a reciclar (agregar a biblioteca)
- Comando:
- Cuándo usarlo:
- Qué confirma:
- Riesgo:

