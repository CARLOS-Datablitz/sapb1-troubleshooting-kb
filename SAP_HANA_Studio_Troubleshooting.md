# SAP HANA Studio -- Troubleshooting Guide

## Issue: Unable to open Stored Procedure and database connection problems

------------------------------------------------------------------------

## 1. Incident Summary

**Environment:** - SAP HANA Database 2.0 - SAP Business One (SAP B1) -
SAP HANA Studio - Windows Server 2019

**Reported Symptoms:** - Error opening Stored Procedures in SAP HANA
Studio - Database connection showing gray icon - Error message:

> "Unable to restore working set state"

-   Later error:

    > "There is not enough space on the disk"

------------------------------------------------------------------------

## 2. Initial Diagnostic Steps

### Step 1 --- Verify SAP HANA services status

Command executed:

``` bash
HDB info
```

Result: - All services running correctly - indexserver, nameserver,
compileserver in running state

------------------------------------------------------------------------

Command executed:

``` bash
sapcontrol -nr 00 -function GetProcessList
```

Result: - All services GREEN - SAP HANA fully operational

------------------------------------------------------------------------

## 3. Verify Stored Procedure existence

SQL executed:

``` sql
SELECT SCHEMA_NAME, PROCEDURE_NAME, CREATE_TIME
FROM SYS.PROCEDURES
WHERE SCHEMA_NAME = 'SBO_PROD_XH'
AND PROCEDURE_NAME = 'XPS_FE_EXTRACCION_IMPUESTO';
```

Result: - Procedure exists correctly in catalog

------------------------------------------------------------------------

## 4. Verify Stored Procedure definition

SQL executed:

``` sql
SELECT DEFINITION
FROM SYS.PROCEDURES
WHERE SCHEMA_NAME = 'SBO_PROD_XH'
AND PROCEDURE_NAME = 'XPS_FE_EXTRACCION_IMPUESTO';
```

Result: - Procedure definition returned successfully - No corruption
detected

------------------------------------------------------------------------

## 5. Recompile Stored Procedure

SQL executed:

``` sql
ALTER PROCEDURE "SBO_PROD_XH"."XPS_FE_EXTRACCION_IMPUESTO"
RECOMPILE;
```

Result: - Successful execution - Procedure opened normally afterward

------------------------------------------------------------------------

## 6. Verify database connectivity from server

Command executed:

``` bash
hdbsql -i 00 -d E08 -u B1SYSTEM -p <password>
```

Result:

    hdbsql E08=>

Conclusion: - Database accessible - Listener working correctly

------------------------------------------------------------------------

## 7. Identify SAP HANA Studio issue

SAP HANA Studio error:

    There is not enough space on the disk

This indicates local workspace cannot function properly.

------------------------------------------------------------------------

## 8. Verify disk space on Windows Server

PowerShell command:

``` powershell
Get-PSDrive C
```

Alternative command:

``` powershell
Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" |
Select-Object DeviceID,
@{Name="TotalGB";Expression={[math]::Round($_.Size/1GB,2)}},
@{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}}
```

Result: - Disk C: had insufficient free space

------------------------------------------------------------------------

## 9. Root Cause

Root cause identified as:

**Insufficient disk space on drive C:**

Impact: - SAP HANA Studio unable to save workspace state - Unable to
reconnect to database - Stored Procedures could not be opened via GUI

Important: - SAP HANA Database itself was fully operational - Issue
limited to SAP HANA Studio client environment

------------------------------------------------------------------------

## 10. Resolution

Resolution steps:

-   Free disk space on drive C:
-   Remove unnecessary files
-   Clear temporary files
-   Ensure at least 5 GB free space

After freeing space: - Restart SAP HANA Studio - Reconnect to SAP HANA
system

System returned to normal operation.

------------------------------------------------------------------------

## 11. Preventive Recommendations

Recommended actions:

-   Maintain minimum 10 GB free space on system drive
-   Monitor disk usage regularly
-   Configure alerts for low disk space
-   Consider moving SAP HANA Studio workspace to secondary drive

Example:

    hdbstudio.exe -data D:\hdbstudio

------------------------------------------------------------------------

## 12. Final Conclusion

SAP HANA Database: HEALTHY\
SAP Services: HEALTHY\
Root Cause: Disk space exhaustion on client system\
Resolution: Free disk space and reconnect SAP HANA Studio

------------------------------------------------------------------------

**Document prepared for troubleshooting reference and future
incidents.**
