# FileServer Issue -- Part 1

## Overview

Initial troubleshooting focused on determining whether the issue
preventing file attachments was related to:

-   Active Directory authentication
-   NTFS permissions
-   SMB Share permissions
-   SharePoint access
-   User group membership

After validation, the issue was confirmed **not to be server-side** and
is likely client/Outlook related.

------------------------------------------------------------------------

## 1. Active Directory Validation

### Verify user account status

``` powershell
net user scott.morath /domain
```

Validated: - Account active - No expiration - No logon restrictions -
Correct group memberships

### Verify last domain logon
En el DC/AD:

``` powershell
Get-ADUser scott.morath -Properties LastLogonDate |
Select Name, LastLogonDate
```

Confirmed recent authentication in the domain.

------------------------------------------------------------------------

## 2. SMB Share Permissions

### Check share access
En el File Server:

``` powershell
Get-SmbShareAccess -Name "Users"
```

Confirmed: - Domain Users have access - No explicit deny entries
affecting the user

------------------------------------------------------------------------

## 3. NTFS Permissions Validation

### Check folder permissions

``` powershell
icacls "D:\ALLPRO Corporation\Users - Documents"
```

Findings: - Accounting group: (F) Full Control - Domain Users: (M)
Modify - No deny entry affecting Scott Morath

------------------------------------------------------------------------

## 4. Effective Group Membership (Client Side)

To validate token membership on user workstation:

``` powershell
whoami
whoami /groups
```

Ensures user receives: - ALLPRO`\Accounting`{=tex} -
ALLPRO`\Domain `{=tex}Users

------------------------------------------------------------------------

## 5. Network Drive Validation

Confirmed H: drive maps to:

\\10.10.228.15`\Users `{=tex}- Documents

User can: - Browse folders - View files - Select files

This confirms no permission-based access restriction.

------------------------------------------------------------------------

## 6. Conclusion (Part 1)

Infrastructure validation confirms:

-   Active Directory functioning correctly
-   User authentication successful
-   NTFS permissions correct
-   SMB share permissions correct
-   No server-side deny entries
-   Network drive accessible

Issue likely related to: - Outlook profile - Add-ins - Client security
policy - Attachment from network path behavior

Further troubleshooting should focus on client-side diagnostics.
