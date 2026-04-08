# Guía de Reinicio — SAP Business One ServerTools

> **Ambiente:** SAP Business One for SAP HANA | Linux SLES | IaaS  
> **Servidor SLD:** `https://sld.invicon.privatcloud.biz:40000/ControlCenter`

---

## ⚠️ Regla principal

> El **Authentication Service depende del ServerTools**.  
> Nunca arranques el Authentication Service antes de que el ServerTools esté completamente iniciado.

---

## 🔴 Orden para DETENER

```
1° → sapb1servertools-authentication
2° → sapb1servertools
```

```bash
sudo systemctl stop sapb1servertools-authentication
sudo systemctl stop sapb1servertools
```

---

## 🟢 Orden para INICIAR

```
1° → sapb1servertools
     (esperar confirmación de startup completo)
2° → sapb1servertools-authentication
```

```bash
sudo systemctl start sapb1servertools

# Verificar que Tomcat esté completamente listo antes de continuar:
tail -f /opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/catalina.out
# Esperar la línea: "INFO: Server startup in XXXX ms"

sudo systemctl start sapb1servertools-authentication
```

---

## 🔁 Orden para REINICIAR (secuencia completa)

```bash
# 1. Detener Authentication Service
sudo systemctl stop sapb1servertools-authentication

# 2. Detener ServerTools
sudo systemctl stop sapb1servertools

# 3. Iniciar ServerTools
sudo systemctl start sapb1servertools

# 4. Verificar startup completo de Tomcat
tail -f /opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/catalina.out
# Esperar: "INFO: Server startup in XXXX ms"

# 5. Iniciar Authentication Service
sudo systemctl start sapb1servertools-authentication
```

---

## ✅ Verificar estado de los servicios

```bash
sudo systemctl status sapb1servertools
sudo systemctl status sapb1servertools-authentication
```

---

## 📋 ¿Por qué este orden?

| Motivo | Detalle |
|---|---|
| Dependencia de Tomcat | El Authentication Service corre sobre Apache Tomcat, que es provisto por el ServerTools |
| Dependencia del SLD | El Authentication Service necesita que el SLD esté activo para exponer sus endpoints |
| Startup lento en IaaS | En ambientes cloud, Tomcat puede tardar 20-40 segundos en inicializar completamente |
| Estado inconsistente | Arrancar el Authentication Service antes de tiempo puede dejarlo desconectado del SLD, reproduciendo el problema original |

---

## 📁 Logs relevantes

| Log | Ruta |
|---|---|
| Tomcat (ServerTools) | `/opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/catalina.out` |
| SLD | `/opt/sap/SAPBusinessOne/ServerTools/tomcat/logs/` |
|     |                                                    |

---

*Última revisión: Marzo 2026*
