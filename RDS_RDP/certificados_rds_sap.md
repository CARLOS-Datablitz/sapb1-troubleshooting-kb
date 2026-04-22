# Certificados RDS — Guía de referencia interna
> Ambiente SAP Business One | Acceso remoto vía RDS

---

## ¿Qué es un certificado RDS?

Es el "documento de identidad" del servidor remoto. Cuando una computadora se conecta al servidor, este presenta su certificado para demostrar que la conexión es segura y legítima. Si el certificado es válido y confiable, la conexión procede sin advertencias. Si está vencido o no es reconocido, el sistema bloquea o advierte al usuario.

---

## Los dos archivos de certificado

### `.cer` — Certificado público

| Atributo | Detalle |
|---|---|
| Contiene | Solo la información pública del certificado |
| Se instala en | La computadora de **cada usuario** |
| Se puede compartir | ✅ Sí, sin ningún riesgo |
| Propósito | Permite que la computadora del cliente "reconozca y confíe" en el servidor |

El archivo `.cer` es el que se distribuye a los usuarios cuando el certificado vence o cuando se incorpora un nuevo colaborador. Sin él instalado, el cliente RDP bloquea la conexión.

---

### `.pfx` — Certificado privado (llave maestra)

| Atributo | Detalle |
|---|---|
| Contiene | Certificado público **+** clave privada del servidor |
| Se instala en | **Solo en el servidor RDS**, nunca en equipos de usuarios |
| Se puede compartir | ❌ No, es confidencial |
| Propósito | Permite al servidor cifrar y firmar las comunicaciones |
| Protección | Viene protegido con contraseña |

> ⚠️ **Nunca distribuir el `.pfx` a usuarios.** Si este archivo y su contraseña fueran comprometidos, un tercero podría suplantar al servidor.

---

## Por qué siempre se generan los dos juntos

Al crear o renovar un certificado, el sistema genera automáticamente un **par de claves criptográficas**:

- Una **clave privada** → queda dentro del `.pfx`
- Una **clave pública** → queda dentro del `.cer`

Estas dos claves están matemáticamente vinculadas desde el momento de su creación. No pueden existir por separado ni generarse en momentos distintos. **Nacen siempre juntas**, sin excepción.

### ¿Por qué son inseparables matemáticamente?

El sistema usa **criptografía asimétrica**: lo que cifra una clave, solo lo puede descifrar la otra.

```
Cliente  →  cifra con .cer (clave pública)   →  envía datos al servidor
Servidor →  descifra con .pfx (clave privada) →  lee los datos
```

Si solo existiera el `.cer`, nadie podría descifrar los mensajes.  
Si solo existiera el `.pfx`, nadie podría cifrarle correctamente al servidor.  
**Los dos son imprescindibles para que la comunicación cifrada funcione.**

---

## Por qué se distribuye el `.cer` cuando vence el certificado

Nuestro servidor usa un **certificado autofirmado** (*self-signed*), lo que significa que no fue emitido por una autoridad de certificación pública reconocida (como DigiCert o Let's Encrypt), sino generado internamente.

El problema es que Windows y los navegadores traen una lista de autoridades en las que ya confían por defecto, y nuestro servidor **no está en esa lista**. Por eso cada computadora cliente debe instalar el `.cer` manualmente para indicarle: *"a este servidor, confía en él"*.

### ¿Qué pasa cuando vence?

1. El administrador genera un **nuevo par de certificados** (nuevo `.pfx` + nuevo `.cer`)
2. El `.pfx` nuevo se instala en el servidor
3. El `.cer` nuevo debe distribuirse a **todos los usuarios**
4. Cada usuario instala el `.cer` nuevo en su computadora
5. Recién entonces el cliente RDP vuelve a reconocer el servidor como confiable

> El certificado viejo que tenían instalado los usuarios ya no sirve — es un archivo diferente al nuevo.

---

## Cómo afecta a cada método de acceso

| Método | URL | ¿Quién verifica el certificado? | ¿Qué pasa si hay problema? |
|---|---|---|---|
| **RDSLogin** | `.../rdweb` | El navegador | Pantalla roja de "conexión no segura" |
| **RDSHTML5** | `.../rdweb/webclient/index.html` | El navegador | Pantalla roja de "conexión no segura" |
| **RDSFeed + RemoteApp** | `.../rdweb/feed/webfeed.aspx` | El navegador **y** el cliente RDP | Advertencia al abrir sesión — **bloquea completamente** |

> El cliente de Escritorio Remoto (RDP) es más estricto que un navegador: no tiene botón de "continuar de todas formas". Sin el `.cer` instalado, no conecta.

---

## URLs del ambiente

| Nombre | URL |
|---|---|
| RDSLogin | `https://rds.aquaculture.privatcloud.biz:10094/rdweb` |
| RDSFeed | `https://rds.aquaculture.privatcloud.biz:10094/rdweb/feed/webfeed.aspx` |
| RDSHTML5 | `https://rds.aquaculture.privatcloud.biz:10094/rdweb/webclient/index.html` |

---

## Resumen rápido

| Pregunta | Respuesta |
|---|---|
| ¿Qué le doy al usuario cuando vence el certificado? | El archivo `.cer` nuevo |
| ¿Qué instalo en el servidor? | El archivo `.pfx` nuevo |
| ¿Por qué se generan siempre los dos? | Son un par matemático inseparable (criptografía asimétrica) |
| ¿Por qué hay que redistribuir el `.cer`? | Porque el nuevo es un archivo diferente al anterior |
| ¿Puedo compartir el `.pfx`? | Nunca — contiene la llave privada del servidor |
| ¿Qué método de acceso es más sensible al certificado? | RDSFeed / RemoteApp — bloquea la conexión completamente |

---

*Documento de uso interno — Ambiente SAP Business One*
