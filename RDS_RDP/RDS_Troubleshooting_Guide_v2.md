# RDS Troubleshooting Guide (Windows Server 2019)

Author: Support Runbook

## Purpose

Step-by-step troubleshooting procedure to diagnose and resolve Remote
Desktop Services (RDS) connectivity issues.

------------------------------------------------------------------------

# 1. Incident Intake

When a client reports: - "Unable to connect to remote computer" - RDP
errors - Disconnections - Users cannot log in

Collect:

-   Server name
-   Time issue started
-   Number of affected users
-   Connection method (VPN / Internet / LAN)

------------------------------------------------------------------------

# 2. Determine Scope

Ask:

-   Is the issue affecting **all users**?
-   Only **one user**?
-   Only **one location**?

Interpretation:

  Situation        Possible Cause
  ---------------- ---------------------
  One user         Client PC issue
  Multiple users   Server issue
  All users        RDS service failure

------------------------------------------------------------------------

# 3. Verify Server Availability

From another server:

    ping SERVERNAME

If ping fails:

Possible causes: - server offline - network problem - firewall

------------------------------------------------------------------------

# 4. Verify DNS

    nslookup SERVERNAME

Expected:

    Name: server.domain.local
    Address: 10.x.x.x

If DNS fails:

-   DNS record missing
-   wrong DNS server

Try connecting using IP.

------------------------------------------------------------------------

# 5. Test RDP Port

    Test-NetConnection SERVERNAME -Port 3389

Interpretation:

  Result   Meaning
  -------- -----------------------------
  True     RDP reachable
  False    Firewall or service problem

------------------------------------------------------------------------

# 6. Verify RDS Services

Check status:

    Get-Service TermService
    Get-Service Tssdis

Important services:

  Service       Role
  ------------- -------------------------
  TermService   Remote Desktop Services
  Tssdis        Connection Broker

Expected state:

    Running

If stopped:

    Start-Service Tssdis

------------------------------------------------------------------------

# 7. If RDP Is Not Accessible

Access server via:

-   Hypervisor console (Proxmox / VMware / Hyper-V)
-   PowerShell remoting
-   Server Manager
-   Computer Management

Hypervisor console is the most reliable recovery method.

------------------------------------------------------------------------

# 8. Check Active Sessions

    query session

or

    qwinsta

If sessions are stuck:

    logoff SESSIONID

------------------------------------------------------------------------

# 9. Check Event Logs

Open:

    Event Viewer

Check:

    Windows Logs
    System

Filter by:

    Service Control Manager

Important IDs:

  Event ID   Meaning
  ---------- -------------------------------
  7023       Service terminated with error
  7034       Service crashed
  7000       Service failed to start
  1074       System restart
  6005       System startup

------------------------------------------------------------------------

# 10. Check for Server Reboot

    Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074}

Example:

    svchost.exe initiated restart
    Reason: Windows Update

This confirms reboot triggered by updates.

------------------------------------------------------------------------

# 11. Check RDS Logs

Navigate:

    Applications and Services Logs
    Microsoft
    Windows
    TerminalServices-SessionBroker
    Operational

Look for:

-   Broker failures
-   session redirection errors

------------------------------------------------------------------------

# 12. Identify Root Cause

Common causes:

  Cause                     Explanation
  ------------------------- ------------------------
  Windows Updates reboot    services fail to start
  Connection Broker crash   RDS unavailable
  Firewall change           port 3389 blocked
  DNS issue                 hostname not resolving
  Network issue             routing failure

------------------------------------------------------------------------

# 13. Restore Services

Restart services:

    Restart-Service Tssdis
    Restart-Service TermService

Verify:

    Get-Service Tssdis

------------------------------------------------------------------------

# 14. Prevent Future Failures

Configure automatic restart:

    sc failure Tssdis reset=86400 actions=restart/60000/restart/60000/restart/60000

This automatically restarts the service if it crashes.

------------------------------------------------------------------------

# 15. Evidence Collection

Collect logs for documentation.

Export System log:

    wevtutil epl System C:\Temp\systemlog.evtx

Check service status:

    Get-Service Tssdis

Check reboot history:

    Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074}

------------------------------------------------------------------------

# 16. Example Incident Report

Root Cause: Windows Updates rebooted the server overnight. After reboot,
the Remote Desktop Connection Broker service failed to start.

Impact: Users could not connect to RDS.

Resolution: Service restarted via hypervisor console.

Prevention: Configured automatic service recovery.

------------------------------------------------------------------------

# 17. RDS Health Check -- 30 Second Diagnostics

When a client reports **RDP connection issues**, run these commands
immediately.

### Check core RDS services

    Get-Service TermService,Tssdis,UmRdpService,SessionEnv | Select Name,Status

Expected:

    Running

Key services:

  Service        Description
  -------------- -------------------------
  TermService    Remote Desktop Services
  Tssdis         Connection Broker
  UmRdpService   Port Redirector
  SessionEnv     Session Environment

------------------------------------------------------------------------

### Check if server is reachable

    ping SERVER

------------------------------------------------------------------------

### Check RDP port

    Test-NetConnection SERVER -Port 3389

------------------------------------------------------------------------

### Check active sessions

    query session

or

    qwinsta

------------------------------------------------------------------------

### Check if server rebooted

    Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074} -MaxEvents 5

------------------------------------------------------------------------

### Most common quick diagnosis

  Symptom                  Likely Cause
  ------------------------ ------------------------
  Port 3389 closed         Firewall or network
  Services stopped         RDS failure
  No sessions visible      Broker service stopped
  Recent reboot detected   Windows Updates

These commands usually identify the issue in **less than 30 seconds**.

------------------------------------------------------------------------

# 18. Quick Diagnostic Commands

    ping SERVER
    Test-NetConnection SERVER -Port 3389
    Get-Service Tssdis
    query session
    Get-WinEvent -FilterHashtable @{LogName='System'; Id=1074}

These commands can identify most RDS issues within minutes.
