# Configuración de Attachments - Montedamina

## 📋 Información General

**Cliente:** Montedamina  
**Fecha:** 11 de Febrero de 2026  
**Tipo de Configuración:** Montaje CIFS de Windows a Linux para Attachments SAP B1

---

## 🏗️ Arquitectura

### Servidores Involucrados

| Servidor | Sistema Operativo | Rol | Hostname |
|----------|-------------------|-----|----------|
| **RDS** | Windows Server 2019 | Almacenamiento de archivos PDF | `RDS` |
| **SLD** | SUSE Linux Enterprise Server | SAP Business One HANA | `sld` |

### Estructura de Directorios

**Windows (RDS):**
```
C:\RepositorioSAP\
├── Alma da Amendoeira\
│   └── Anexos\
├── FrutaCaroco\
│   └── Anexos\
├── Monte da Mina\
│   └── Anexos\
├── Monte do Canal\
│   └── Anexos\
└── SocAgriMonteAmendoa\
    └── Anexos\
```

**Linux (SLD):**
```
/usr/sap/SAPBusinessOne/B1_SHF/Attachments/
├── Alma da Amendoeira/
│   └── Anexos/
├── FrutaCaroco/
│   └── Anexos/
├── Monte da Mina/
│   └── Anexos/
├── Monte do Canal/
│   └── Anexos/
└── SocAgriMonteAmendoa/
    └── Anexos/
```

---

## 🔐 Credenciales

**Ubicación:** `/hana/scripts/sbomailer.txt`

```ini
username=RepositorioSAP
password=alsjkcbh67879$
domain=montedamina.privatcloud.biz
```

**Permisos del archivo:**
```bash
chmod 600 /hana/scripts/sbomailer.txt
```

---

## ⚙️ Configuración Paso a Paso

### 1️⃣ Verificación en Windows Server (RDS)

#### Verificar recurso compartido existente

```powershell
net share
```

**Salida esperada:**
```
Share name   Resource                        Remark
-------------------------------------------------------------------------------
RepositorioSAP  C:\RepositorioSAP
```

---

### 2️⃣ Configuración en Linux SLES (SLD)

#### Instalar paquetes necesarios

```bash
zypper install cifs-utils
```

#### Verificar carpeta de destino

```bash
ls -la /usr/sap/SAPBusinessOne/B1_SHF/
```

**Salida esperada:**
```
drwxrwxrwx  2 b1service0 b1service0    6 Nov 19 17:41 Addon
drwxrwxrwx  7 b1service0 b1service0  115 Feb  3 01:22 Attachments
```

#### Crear archivo de credenciales (si no existe)

```bash
vi /hana/scripts/sbomailer.txt
```

**Contenido:**
```ini
username=RepositorioSAP
password=alsjkcbh67879$
domain=montedamina.privatcloud.biz
```

**Proteger el archivo:**
```bash
chmod 600 /hana/scripts/sbomailer.txt
```

---

### 3️⃣ Montaje CIFS

#### Montaje manual (prueba)

```bash
mount -t cifs //RDS/RepositorioSAP /usr/sap/SAPBusinessOne/B1_SHF/Attachments \
  -o credentials=/hana/scripts/sbomailer.txt,uid=b1service0,gid=b1service0,file_mode=0775,dir_mode=0775
```

**Salida esperada:**
```
(sin salida = éxito)
```

#### Verificar montaje

```bash
df -h | grep Attachments
```

**Salida esperada:**
```
//RDS/RepositorioSAP  100G   55G   46G  55% /usr/sap/SAPBusinessOne/B1_SHF/Attachments
```

#### Verificar contenido

```bash
ls -la /usr/sap/SAPBusinessOne/B1_SHF/Attachments/
```

**Salida esperada:**
```
drwxrwxr-x  2 b1service0 b1service0    0 Nov 24 15:26 Alma da Amendoeira
drwxrwxr-x  2 b1service0 b1service0    0 Nov 26 10:51 FrutaCaroco
drwxrwxr-x  2 b1service0 b1service0    0 Nov 24 13:45 Monte da Mina
drwxrwxr-x  2 b1service0 b1service0    0 Nov 24 13:53 Monte do Canal
drwxrwxr-x  2 b1service0 b1service0    0 Nov 24 15:47 SocAgriMonteAmendoa
```

#### Verificar subcarpetas Anexos

```bash
ls -la /usr/sap/SAPBusinessOne/B1_SHF/Attachments/Monte\ da\ Mina/
```

**Salida esperada:**
```
drwxrwxr-x 2 b1service0 b1service0    0 Feb  3 17:29 Anexos
drwxrwxr-x 2 b1service0 b1service0    0 Nov 20 16:13 Imagens
drwxrwxr-x 2 b1service0 b1service0    0 Jan 12 22:47 XML
```

---

### 4️⃣ Pruebas de Permisos

#### Crear archivo de prueba

```bash
touch /usr/sap/SAPBusinessOne/B1_SHF/Attachments/Monte\ da\ Mina/Anexos/test.txt
```

#### Verificar propietario y permisos

```bash
ls -la /usr/sap/SAPBusinessOne/B1_SHF/Attachments/Monte\ da\ Mina/Anexos/test.txt
```

**Salida esperada:**
```
-rwxrwxr-x 1 b1service0 b1service0 0 Feb 11 21:37 test.txt
```

#### Eliminar archivo de prueba

```bash
rm /usr/sap/SAPBusinessOne/B1_SHF/Attachments/Monte\ da\ Mina/Anexos/test.txt
```

---

### 5️⃣ Montaje Permanente

#### Desmontar (si está montado manualmente)

```bash
umount /usr/sap/SAPBusinessOne/B1_SHF/Attachments
```

**Salida si no está montado:**
```
umount: /usr/sap/SAPBusinessOne/B1_SHF/Attachments: not mounted.
```

#### Editar /etc/fstab

```bash
vi /etc/fstab
```

**Agregar esta línea al final:**
```
//RDS/RepositorioSAP /usr/sap/SAPBusinessOne/B1_SHF/Attachments cifs credentials=/hana/scripts/sbomailer.txt,uid=b1service0,gid=b1service0,file_mode=0775,dir_mode=0775,_netdev,x-systemd.automount 0 0
```

#### Montar desde fstab

```bash
mount -a
```

#### Verificar montaje final

```bash
df -h | grep Attachments
```

**Salida esperada:**
```
//RDS/RepositorioSAP  100G   54G   46G  55% /usr/sap/SAPBusinessOne/B1_SHF/Attachments
```

---

## 🔍 Troubleshooting y Diagnóstico

### Verificar conectividad SMB desde Linux

#### Listar recursos compartidos del servidor Windows

```bash
smbclient -L RDS -U montedamina.privatcloud.biz\\RepositorioSAP
```

**Salida esperada:**
```
Password for [MONTEDAMINA.PRIVATCLOUD.BIZ\RepositorioSAP]:
        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        RepositorioSAP  Disk
        Scanner         Disk
SMB1 disabled -- no workgroup available
```

#### Conectar al recurso compartido

```bash
smbclient //RDS/RepositorioSAP -U montedamina.privatcloud.biz\\RepositorioSAP
```

**Dentro de smbclient:**
```
smb: \> ls
  .                                   D        0  Wed Jan 28 19:42:14 2026
  ..                                  D        0  Wed Jan 28 19:42:14 2026
  Alma da Amendoeira                  D        0  Mon Nov 24 15:26:18 2025
  FrutaCaroco                         D        0  Wed Nov 26 10:51:33 2025
  Monte da Mina                       D        0  Mon Nov 24 13:45:21 2025
  Monte do Canal                      D        0  Mon Nov 24 13:53:55 2025
  SocAgriMonteAmendoa                 D        0  Mon Nov 24 15:47:35 2025
                26073087 blocks of size 4096. 11917922 blocks available

smb: \> exit
```

### Verificar montaje en /proc/mounts

```bash
cat /proc/mounts | grep Attachments
```

**Salida esperada:**
```
//RDS/RepositorioSAP /usr/sap/SAPBusinessOne/B1_SHF/Attachments cifs rw,relatime,vers=3.1.1,cache=strict,upcall_target=app,username=RepositorioSAP,domain=montedamina.privatcloud.biz,uid=463,noforceuid,gid=462,noforcegid,addr=10.2.93.165,file_mode=0775,dir_mode=0775,soft,nounix,serverino,mapposix,reparse=nfs,rsize=4194304,wsize=4194304,bsize=1048576,retrans=1,echo_interval=60,actimeo=1,closetimeo=1 0 0
```

**⚠️ Nota importante:** El nombre del servidor en `/proc/mounts` debe ser `//RDS/RepositorioSAP` (NO una IP) para que SBOMailer pueda resolver correctamente las rutas UNC.

### Verificar credenciales

```bash
cat /hana/scripts/sbomailer.txt
```

**Salida esperada:**
```
username=RepositorioSAP
password=alsjkcbh67879$
domain=montedamina.privatcloud.biz
```

---

## 📝 Configuración en SAP Business One

### Rutas de Attachments a configurar

**Ubicación en SAP B1:**  
`Administración → Inicialización del sistema → Configuración general → Ficha Attachments`

| Base de Datos / Empresa | Ruta de Attachments en OADP |
|-------------------------|------------------------------|
| **Alma da Amendoeira** | `\\RDS\RepositorioSAP\Alma da Amendoeira\Anexos\` |
| **FrutaCaroco** | `\\RDS\RepositorioSAP\FrutaCaroco\Anexos\` |
| **Monte da Mina** | `\\RDS\RepositorioSAP\Monte da Mina\Anexos\` |
| **Monte do Canal** | `\\RDS\RepositorioSAP\Monte do Canal\Anexos\` |
| **SocAgriMonteAmendoa** | `\\RDS\RepositorioSAP\SocAgriMonteAmendoa\Anexos\` |

### Consultar rutas actuales en HANA Studio

```sql
-- Para cada base de datos
SELECT "PrintId", SUBSTRING("AttachPath", 1, 200) AS "AttachPath" 
FROM SBO_FRUTACAROCO.OADP;

SELECT "PrintId", SUBSTRING("AttachPath", 1, 200) AS "AttachPath" 
FROM SBO_ALMADAAMENDOEIRA.OADP;

SELECT "PrintId", SUBSTRING("AttachPath", 1, 200) AS "AttachPath" 
FROM SBO_MONTEDAMINA.OADP;

SELECT "PrintId", SUBSTRING("AttachPath", 1, 200) AS "AttachPath" 
FROM SBO_MONTEDOCANAL.OADP;

SELECT "PrintId", SUBSTRING("AttachPath", 1, 200) AS "AttachPath" 
FROM SBO_SOCAGRIMONTEAMENDOA.OADP;
```

### Actualizar rutas en HANA Studio (alternativa)

```sql
-- Ejemplo para FrutaCaroco
UPDATE SBO_FRUTACAROCO.OADP 
SET "AttachPath" = '\\RDS\RepositorioSAP\FrutaCaroco\Anexos\'
WHERE "PrintId" = 'Empr';

-- Repetir para las otras 4 empresas cambiando el nombre de la carpeta
```

---

## 🔄 Cómo funciona SBOMailer

### Proceso de resolución de rutas

1. **SBOMailer lee la tabla OADP** y obtiene la ruta UNC:
   ```
   \\RDS\RepositorioSAP\FrutaCaroco\Anexos\
   ```

2. **SBOMailer busca en `/proc/mounts`** un montaje CIFS que coincida:
   ```
   //RDS/RepositorioSAP → /usr/sap/SAPBusinessOne/B1_SHF/Attachments
   ```

3. **SBOMailer traduce la ruta UNC a ruta Linux:**
   ```
   \\RDS\RepositorioSAP\FrutaCaroco\Anexos\
   ↓
   /usr/sap/SAPBusinessOne/B1_SHF/Attachments/FrutaCaroco/Anexos/
   ```

4. **SBOMailer lee el archivo PDF** desde la ruta Linux y lo adjunta al correo.

### ⚠️ Requisitos críticos

- ✅ El nombre del servidor en OADP (`\\RDS\...`) debe coincidir con el nombre en `/proc/mounts` (`//RDS/...`)
- ✅ El montaje debe estar activo cuando SBOMailer intenta acceder
- ✅ El usuario `b1service0` debe tener permisos de lectura en los archivos
- ✅ Las carpetas `Anexos` deben existir físicamente

---

## 📊 Comparación con DPT

### Similitudes

| Aspecto | DPT | Montedamina |
|---------|-----|-------------|
| Servidor Windows | `adm` | `RDS` |
| Servidor Linux | `sles` | `sld` |
| Recurso compartido | `//adm/Attachments/` | `//RDS/RepositorioSAP` |
| Punto de montaje | `/usr/sap/.../SAP_Anhaenge` | `/usr/sap/.../Attachments` |
| Usuario Linux SAP | Usuario de sistema | `b1service0` |
| Archivo credenciales | Archivo `.smbcredentials` | `/hana/scripts/sbomailer.txt` |

### Diferencias clave

- **DPT:** 1 empresa, 1 carpeta
- **Montedamina:** 5 empresas, 5 carpetas (una por empresa)

---

## ✅ Checklist de Verificación Final

- [ ] Recurso compartido `RepositorioSAP` existe en Windows RDS
- [ ] Archivo de credenciales `/hana/scripts/sbomailer.txt` configurado
- [ ] Paquete `cifs-utils` instalado en Linux
- [ ] Montaje manual funciona correctamente
- [ ] Carpetas de las 5 empresas visibles desde Linux
- [ ] Subcarpetas `Anexos` existen en cada empresa
- [ ] Permisos de escritura verificados (test.txt)
- [ ] Entrada en `/etc/fstab` agregada
- [ ] Montaje automático funciona (`mount -a`)
- [ ] `/proc/mounts` muestra `//RDS/RepositorioSAP` (no IP)
- [ ] Conectividad SMB verificada con `smbclient`
- [ ] Rutas en SAP B1 OADP configuradas con formato `\\RDS\RepositorioSAP\...\`

---

## 🆘 Problemas Comunes

### Error: NT_STATUS_LOGON_FAILURE

**Causa:** Credenciales incorrectas o dominio mal especificado.

**Solución:**
```bash
smbclient -L RDS -U montedamina.privatcloud.biz\\RepositorioSAP
```

### Error: mount: wrong fs type, bad option, bad superblock

**Causa:** Paquete `cifs-utils` no instalado.

**Solución:**
```bash
zypper install cifs-utils
```

### El montaje no persiste después de reinicio

**Causa:** Falta opción `_netdev` en `/etc/fstab`.

**Solución:** Verificar que la línea en `/etc/fstab` incluya `,_netdev,x-systemd.automount`

### SBOMailer no encuentra los attachments

**Causa:** Mismatch entre nombre en OADP y nombre en `/proc/mounts`.

**Verificación:**
```bash
# 1. Ver qué nombre usa el montaje
cat /proc/mounts | grep Attachments

# 2. Verificar que en OADP use el mismo nombre
# Si en /proc/mounts dice //RDS/RepositorioSAP
# Entonces en OADP debe ser \\RDS\RepositorioSAP\...
```

### Carpetas con espacios no funcionan

**Solución:** NO requiere tratamiento especial. Usar el nombre tal cual:
```
\\RDS\RepositorioSAP\Alma da Amendoeira\Anexos\
```

---

## 📚 Referencias

- SAP Business One Administration Guide - Attachments Configuration
- SUSE Linux Enterprise Server - CIFS/SMB Client Configuration
- SAP Community - SBOMailer Path Resolution
- Configuración similar implementada en cliente DPT

---

## 📄 Información del Documento

**Autor:** Técnico SAP  
**Última actualización:** 11 de Febrero de 2026  
**Versión:** 1.0  
**Estado:** Pendiente de validación por cliente

---

## 🔐 Notas de Seguridad

- El archivo `/hana/scripts/sbomailer.txt` contiene credenciales en texto plano
- Mantener permisos `600` en el archivo de credenciales
- Solo el usuario `root` debe tener acceso de lectura
- Considerar cambiar la contraseña periódicamente
- Los permisos `0775` son apropiados para este caso de uso
- Auditar regularmente los accesos al recurso compartido

---

*Fin del documento*
