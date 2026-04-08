# Recuperación de acceso a Keycloak en SAP Business One (Service Layer) Windows SQL

LINK Bookstack: https://bookstack.isystems-integration.com/books/sap/page/wenn-du-das-passwort-vom-keycloak-admin-vergessen-hast-working-on-it

## Contexto

En entornos de SAP Business One con Service Layer, el sistema utiliza **Keycloak** como proveedor de autenticación.

En algunos casos:

* Se pierde la contraseña del usuario `admin`
* El acceso a `https://localhost:40020/auth` falla con:

  ```
  Invalid username or password
  ```

---

## Arquitectura clave

* Base de datos de autenticación: `B1AS`
* Tabla de usuarios: `USER_ENTITY`
* Realm principal: `master`

El usuario `admin` puede existir **solo en Keycloak**, no en SAP (`OUSR`)

---

## Recomendación previa

Antes de cualquier cambio:

```sql
BACKUP DATABASE B1AS 
TO DISK = 'C:\B1AS.bak'
WITH INIT;
```

---

## Verificar usuarios existentes

```sql
USE B1AS;

SELECT 
    ID,
    USERNAME,
    EMAIL,
    ENABLED
FROM USER_ENTITY;
```

---

## Verificar realm de usuarios

```sql
SELECT 
    U.USERNAME,
    R.NAME AS REALM
FROM USER_ENTITY U
JOIN REALM R ON U.REALM_ID = R.ID;
```

---

## Eliminación controlada del usuario `admin`

> NO eliminar usuarios del sistema como:
>
> * `service-account-*`
> * `b1siteuser`

---

### 1. Eliminar credenciales

```sql
DELETE FROM B1AS.dbo.CREDENTIAL
WHERE USER_ID IN (
    SELECT ID 
    FROM B1AS.dbo.USER_ENTITY 
    WHERE USERNAME = 'admin'
);
```

---

### 2. Eliminar roles

```sql
DELETE FROM B1AS.dbo.USER_ROLE_MAPPING
WHERE USER_ID IN (
    SELECT ID 
    FROM B1AS.dbo.USER_ENTITY 
    WHERE USERNAME = 'admin'
);
```

---

### 3. Eliminar usuario

```sql
DELETE FROM B1AS.dbo.USER_ENTITY
WHERE USERNAME = 'admin';
```

---

## Reinicio de servicios

Reiniciar:

* SAP Business One Service Layer
* Servicios relacionados a Keycloak

---

## Recuperación de acceso

Intentar acceso con:

```
Usuario: admin
Password: admin
```

> En algunos entornos, el usuario se regenera automáticamente.

---

## Notas importantes

* Este procedimiento es **quirúrgico**, no destructivo global
* No afecta usuarios SAP (`OUSR`)
* No elimina configuración de Service Layer
* Solo resetea acceso administrativo de Keycloak

---

## Resultado esperado

* Acceso restaurado al panel de Keycloak
* Usuario `admin` funcional nuevamente
* Entorno SAP intacto

---

## Lecciones aprendidas

* Keycloak en SAP B1 puede tener usuarios propios (`B1AS`)
* No siempre depende de SAP (`OUSR`)
* Evitar borrar todo el esquema → usar eliminación selectiva

---

## Estado final

✔ Acceso recuperado
✔ Servicio operativo
✔ Sin impacto en SAP Business One

---
