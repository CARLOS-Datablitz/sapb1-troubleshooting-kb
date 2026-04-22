# SAP Business One – Service Layer Attachments Troubleshooting Guide

## Context
This guide documents the troubleshooting and resolution approach for enabling SAP Business One Service Layer (Linux) to access attachment folders hosted on a Samba (SMB) share, while maintaining compatibility with Windows clients.

Date: 2026-04-16

---

## Architecture Overview

- Windows Clients → Access via UNC path:
  \\sld\B1_SHF\Attachments\TINGUEBROWN_PROD

- Service Layer (Linux) → Access via mount:
  /mnt/attachments_prod

Both point to the same physical storage.

---

## Key Constraint

SAP B1 Windows clients **require UNC paths**.
Changing OADP to Linux paths (/mnt/...) will break attachments.

---

## Step 1 – Validate SMB Access

### Command
```
smbclient -L //sld -U b1service0
```

### Purpose
- Lists available shares
- Confirms authentication works

---

## Step 2 – Access Specific Share

### Command
```
smbclient //sld/B1_SHF -U b1service0
```

### Purpose
- Validates access to the actual share
- Confirms visibility of Attachments folder

---

## Step 3 – Mount Share (Initial – not recommended)

### Command
```
mount -t cifs //sld/B1_SHF /mnt/b1_shf -o credentials=/root/.smbcred,uid=b1service0,gid=b1service0
```

### Purpose
- Mount entire share

### Issue
- Exposes unnecessary directories (security risk)

---

## Step 4 – Correct Mount (Best Practice)

### Command
```
mkdir -p /mnt/attachments_prod

mount -t cifs //sld/B1_SHF/Attachments/TINGUEBROWN_PROD /mnt/attachments_prod \
-o credentials=/root/.smbcred,uid=b1service0,gid=b1service0
```

### Purpose
- Mount only required directory
- Reduces attack surface

---

## Step 5 – Validate Access

### Read test
```
ls /mnt/attachments_prod | head
```

### Service Layer user test
```
sudo -u b1service0 ls /mnt/attachments_prod
```

### Write test
```
sudo -u b1service0 touch /mnt/attachments_prod/test.txt
rm /mnt/attachments_prod/test.txt
```

### Purpose
- Ensures Service Layer can read/write

---

## Step 6 – Check Current Mounts

```
df -h
mount | grep cifs
```

### Purpose
- Verify active mounts

---

## Step 7 – Troubleshooting Mount Issues

### Error: credential file missing
```
error opening credential file /root/.smbcred
```

### Solution
- Create file:
```
vi /root/.smbcred
```

Content:
```
username=b1service0
password=******
```

Permissions:
```
chmod 600 /root/.smbcred
```

---

## Step 8 – Unmount Issues

### Problem
```
umount: target is busy
```

### Diagnose
```
lsof +D /mnt/b1_shf
```

### Solution
```
cd /
umount /mnt/b1_shf
```

Or force:
```
umount -l /mnt/b1_shf
```

---

## Step 9 – SAP Validation (Database)

### Check attachment paths

**— Importante: Colocar el comando de abajo en una sola linea**
```
SELECT "FileName", "FileExt", "srcPath", "trgtPath"
FROM "TINGUEBROWNUS_PROD"."ATC1"
LIMIT 20;
```

### Purpose
- Confirm attachments use UNC path

---

## Step 10 – Critical Rule

DO NOT change OADP to Linux path.

Correct:
```
\\sld\B1_SHF\Attachments\TINGUEBROWN_PROD
```

Incorrect:
```
/mnt/attachments_prod/
```

---

## Final Design

- OADP → UNC path (Windows compatibility)
- Linux mount → internal Service Layer access

---

## Key Takeaways

- Always consider all consumers (Windows + Linux)
- Never break UNC paths in SAP B1
- Use mount points only as backend workaround
- Validate with Service Layer user (b1service0)

---

## Optional Next Step

- Test attachment upload via Service Layer API
- Monitor logs:
  /usr/sap/SAPBusinessOne/ServiceLayer/logs/

---

End of Guide
