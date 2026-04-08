# SAP HANA + SAP Business One
## Troubleshooting: "Database Unreachable / Connection Lost"

---

## 🧠 Scenario
Client reports:
- Database unreachable
- Database connection lost
- Specific schema (e.g., Omega GTI) appears down

---

## ✅ Step 1 – Validate HANA Services

```bash
HDB info
```

### ✔ Expected
- hdbnameserver → running
- hdbindexserver → running
- hdbxsengine → running

### 🔎 Conclusion
If all services are up → issue is NOT infrastructure

---

## ✅ Step 2 – Validate Tenant Status

Connect to SYSTEMDB:

```bash
hdbsql -i 00 -d SYSTEMDB -u SYSTEM -p '<password>'
```

Run:

```sql
SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES;
```

### ✔ Expected
- SYSTEMDB → YES
- NDB → YES

### 🔎 Conclusion
If tenant is ACTIVE → database is NOT down

---

## ❌ Step 3 – Test Authentication (Critical Step)

Test connection to tenant:

```bash
hdbsql -i 00 -d NDB -u SYSTEM -p '<password>'
```

### Possible Results

#### ❌ authentication failed
- SYSTEM user not valid for tenant
- Password mismatch or user locked

#### ✅ Successful login
- Tenant is healthy

---

## ✅ Step 4 – Test Alternative DB User

Example:

```bash
hdbsql -i 00 -d NDB -u B1SYSTEM -p '<password>'
```

### ✔ If SUCCESS
👉 Database is OK
👉 Issue is NOT HANA
👉 Issue is SLD / credentials

---

## ✅ Step 5 – Identify User Used by SAP B1

```sql
SELECT * FROM SLDDATA."COMMONDBS";
```

### Key Fields
- CREDNAME → DB user used by SAP B1

### Example
```
B1_SBOCOMMON
```

### 🔎 Conclusion
If this user ≠ working user → credential mismatch

---

## 💥 Root Cause Pattern

- HANA is UP
- Tenant is ACTIVE
- Valid DB user exists (e.g., B1SYSTEM)
- SAP B1 uses different/invalid credentials

👉 Result:
- Database unreachable
- Connection lost

---

## 🛠️ Step 6 – Fix SLD Credentials (SAFE)

Execute in tenant (NDB):

```sql
update SLDDATA."COMPANYDBS" set CREDENTIALLEVEL = 0;

update "SLDDATA"."COMMONDBS"
set CREDNAME=null,
    CREDPASS=null,
    ROCREDNAME=null,
    ROCREDPASS=null;
```

### ✔ Effect
- Clears stored credentials
- Forces SAP B1 to re-authenticate

### ⚠️ Impact
- Temporary connection interruption
- No data impact

---

## 🔧 Step 7 – Reconfigure in SLD

1. Access SLD / Control Center
2. Go to Landscape
3. Select database (SBOCOMMON)
4. Re-enter credentials:

```
User: B1SYSTEM
Password: <valid password>
```

---

## ✅ Step 8 – Validation

- Login to SAP Business One
- Access company database
- Confirm no connection errors

---

## 📌 Notes & Best Practices

- SYSTEM user in SYSTEMDB ≠ SYSTEM in tenant
- Always validate with hdbsql before making changes
- Do NOT change passwords in production unless necessary
- Prefer SLD credential reset over password reset
- Reinicios del servidor pueden causar desincronización de credenciales

---

## 🚨 Common Mistakes

❌ Running SQL outside hdbsql
❌ Using wrong database (SYSTEMDB vs NDB)
❌ Assuming database is down when it’s authentication issue
❌ Changing SYSTEM password without validation

---

## 🧠 Quick Decision Flow

1. HANA UP? → YES
2. Tenant ACTIVE? → YES
3. Can connect with DB user? → YES

👉 Then:
💥 Problem = SLD credentials

---

## 📁 Useful Commands Summary

```bash
HDB info

hdbsql -i 00 -d SYSTEMDB -u SYSTEM -p '<password>'

hdbsql -i 00 -d NDB -u <user> -p '<password>'
```

```sql
SELECT DATABASE_NAME, ACTIVE_STATUS FROM SYS.M_DATABASES;

SELECT * FROM SLDDATA."COMMONDBS";
```

---

## ✅ Final Takeaway

Most "Database Unreachable" issues in SAP B1 on HANA are:

> NOT infrastructure issues
> NOT database failures

👉 They are **credential inconsistencies in SLD**

---

