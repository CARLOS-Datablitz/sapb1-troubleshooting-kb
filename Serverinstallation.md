# PREMISE

## order

- [ ] IP configuration from the customer network
- [ ] familiarize with the order
- [ ] is a partner involved?
- [ ] create sharepoint folder + server Questions.xlsx
- [ ] fill in server Questions.xlsx + contact details from the customer
- [ ] support contract? ( if yes : VPN + SMB )
- [ ] create customer network on UTM
- [ ] create ansible config for Klaus

## setup

- [ ] management controller: XCC, IDRAC
- [ ] hypervisor: ESXI, PROXMOX
- [ ] virtual machines: WINDOWS,SLES
- [ ] software: B1, VEEAM, O365, ETC
- [ ] CHECK the system checklist
- [ ] monitoring was setup

## delivery

- [ ] delivery vs. order!
- [ ] SAP name
- [ ] CPU, RAM, HDD ( SAS, SSD, M.2, NVME ), LOM, PCI-E
- [ ] others ( Riser Card, USB, Altercate )
- [ ] mount the server cover with the serial number
- [ ] mount the server in the rack
- [ ] server serial numbers in SAP
- [ ] update server questions on FTP
- [ ] provide an update to the partner

## cleanup

- [ ] ESXI Backup and save on Sharepoint (Kunde-ESXIname.tzz)(`/bin/firmwareConfig.sh --backup /tmp/` `/bin/firmwareConfig.py --restore /tmp/`)
- [ ] Proxmox Backup and save on Sharepoint: `wget -q -O /root/prox_config_backup.sh https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_backup.sh;cd /root;myDir="/root/backup";mkdir $myDir;export BACK_DIR="$myDir";chmod +x /root/prox_config_backup.sh;./prox_config_backup.sh`
- [ ] server Questions & SAP: update usernames and passwords (keep root and administrator logins)
- [ ] create Thycotic folder
- [ ] test autostart and change VM version (z.B. SUSE 12 to SUSE 15) and upgrade VM compatibility (z.b ESXI6.5 to ESXI 7.0)
- [ ] remove all NFS shares from Esxi
- [ ] VPN and SMB
- [ ] licenses
- [ ] print server Questions (incl. checklist)
- [ ] server VPNs+Backups.xlsx
- [ ] hosting Excel (only Hosting server)
- [ ] backup table
- [ ] wrap up server
- [ ] delivery with Jessi
- [ ] customer network UTM

# HOSTED

## order

- [ ] IP configuration for the customer network
- [ ] familiarize with the order
- [ ] is a partner involved?
- [ ] create sharepoint folder + server Questions.xlsx
- [ ] fill in server Questions.xlsx + contact details from the customer
- [ ] create customer network on UTM
- [ ] Allow MultiTenant connection if needed
- [ ] create ansible config for Klaus

## setup

- [ ] virtual machines: WINDOWS,SLES
- [ ] software: B1, VEEAM, O365, etc
- [ ] CHECK the system checklist
- [ ] monitoring was setup

## delivery

- [ ] update hosting list with licenses
- [ ] update 'Server VPNs+Backups.xlsx'
- [ ] update server questions on FTP
- [ ] provide an update to the partner

## cleanup

- [ ] hosting Excel (keep root and administrator logins)
- [ ] add system to vpn & backup excel

# CHECK

global checklist for on premise and hosted environments. use detailed checklists in *SETUP*  as needed.

- [ ] backups: SCRIPT, VEEAM, PROXMOX BACKUP... are working
- [ ] login with hana studio is working
- [ ] hardware keys are entered in server questions
- [ ] hana sld backup service was setup and is working
- [ ] sld public url has been reconfigured
- [ ] windows updates are setup in GPO and are working
- [ ] additional software has been installed ( Server Components ( RSP, B1i, ... ) )
- [ ] allow icmp and smb access for server 2019: `Set-NetFirewallRule FPS-SMB-In-TCP -Enabled True;Set-NetFirewallRule FPS-ICMP4-ERQ-In -Enabled True;`
- [ ] insecure guest access may be needed on 2019 ( gpo "Computer > Administrative Vorlagen > Netzwerk > LanMan-Arbeitsstation: Unsicher Gastanmeldung aktivieren > aktivieren")
- [ ] windows defender exclusions were set
- [ ] windows was licensed using `slmgr.vbs /ipk QPGMN-4FHPW-7PXXY-XDXTH-PWHYQ`
- [ ] all pending windows updates were installed
- [ ] server dashboards show no errors and everything is green
- [ ] rds collection is logging off users with disconnected sessions
- [ ] RDWeb is working
- [ ] RDWebFeed is working
- [ ] RDHTML5 is working
- [ ] all vm's are being backed up by veeam or ProxmoxBackup
- [ ] details were entered in 'Server VPNs+Backups.xlsx'
- [ ] license usage was entered in Hosting Sheet: <https://isystemsde.sharepoint.com/Dokumente/Hosting/Hosting_Ubersicht_DCDUS.xlsx?web=1>
- [ ] server questions was copied to sftp for partner access
- [ ] re-checked the SOW if everything was completed

# UPDATE

B1 Update Checklists. Please note that you do not have to do all the steps. Skip a step if it does not make sense to you. Change the order of the steps if it makes more sense to you.

## before

- [ ] customer has support contract with isystems
- [ ] 'CUSTOMER UPDATE REQUEST' has been pre-filled for partner and then sent to partner
- [ ] 'CUSTOMER UPDATE REQUEST' has been filled out by partner and returned to isystems
- [ ] 'CUSTOMER UPDATE REQUEST' section '1.Pre-Update Information' is complete
- [ ] requested sles/hana/b1 versions are compatible, see 'sles_hana_b1_versions' (older comparison table see `SAP Business One Versions vs. Hana and SLES.jpg`)
- [ ] sles server review: is it necessary to update sles? `zypper sl;cat /etc/issue;cat /etc/os-release`
- [ ] sles server prepare: make sure you are able to update sles, see 'sles_updates', 'sles_updates_prep'
- [ ] hana server review: is it necessary to update hana? `su - ndbadm -c "HDB version"`
- [ ] hana and windows server review: is it necessary to update hana client (look for 'fullversion' in the manifests)? `cat "/usr/sap/hdbclient/manifest"`, "C:\\Program Files\\sap\\hdbclient\\manifest", "C:\\Program Files (x86)\\sap\\hdbclient\\manifest"
- [ ] sld config review (make screenshots)
- [ ] backup sld license and config `zip -ur /usr/sap/SAPBusinessOne/B1_SHF/B1License.zip /usr/sap/SAPBusinessOne/ServerTools/License/webapps/lib/B1*.*`
- [ ] install config review: `cat /usr/sap/SAPBusinessOne/.installer.properties`
- [ ] install b1 config review on sld server `zip -ur /usr/sap/SAPBusinessOne/B1_SHF/B1Installer.zip /var/log/SAPBusinessOne/B1Installer_*.log`
- [ ] Test Export & Import dbs, upload to sftp
- [ ] Test Upgrade on the Test windows vms
- [ ] edit '/etc/fstab' to use UUID and/or add disks, for example /backup
- [ ] install files on sld server ready to go
- [ ] sles is registered properly, see 'sles_updates'
- [ ] review disk size and other system details
- [ ] review ssl certificate and renew if needed
- [ ] ssl certificate on sld server for use during installation #/usr/sap/SAPBusinessOne/Common/tomcat/cert/ttg.privatcloud.biz.pfx #sapB1iP
- [ ] hana server disable ipv6
- [ ] hana server update /etc/hosts
- [ ] hana server update dns servers
- [ ] win vm: prepare for uninstallation of b1: `choco install -y bulk-crap-uninstaller`
- [ ] date(s) for upgrade have been scheduled with partner (incl. short todo list per server in the meeting invite)
- [ ] server auto update scheduled days before scheduled date
- [ ] server auto shutdown scheduled for scheduled date
- [ ] server update & reboot working
- [ ] server shutdown

## during

- [ ] ndb/sld/adm/rds vm's: veeam backup ok last night
- [ ] ndb: hana backup ok last night
- [ ] ndb: make one hana backup after sld shutdown
- [ ] ndb: update backup partition (see notes below)
- [ ] sld: increase size of /usr/sap disk
- [ ] ndb: export dbs, upload to sftp
- [ ] ndb/sld: comment all crontabs
- [ ] ndb/sld/adm/rds: snapshot create after auto shutdown / shutdown vm's and take snapshot 'start'
- [ ] ndb/sld/adm/rds: review RAM/HDD/CPU and adjust if necessary now
- [ ] ndb/sld: start vm, stop, then disable sld and ndb services, install updates, install patches, install missing packages, shutdown
- [ ] ndb/sld: update sles, see 'sles_updates' and 'sles_updates_prep', if you migrate from 12->15, go from 12.5->15.1 (use iso cd1)
- [ ] ndb/sld: shutdown vm, unmount/remove iso and make another snapshot 'sles'
- [ ] ndb/sld: start vm, systemctl start sapinit, systemctl start sapb1servertools, test login to :40000/ControlCenter
- [ ] ndb/sld: systemctl stop sapb1servertools, upgrade hana (afl, client, database, studio), see 'sles_hana_update'
- [ ] ndb/sld: update/install packages as required: `zypper in -y xmlstarlet;#zypper in -y libicu60_2 libcap-progs firewalld bc glibc-i18ndata python python-openssl python-pycrypto`
- [ ] sld: systemctl start sapb1servertools, test login to :40000/ControlCenter, then upgrade b1 using package installer
- [ ] sld: if b1 upgrade does not work, re-install b1, see 'sles_b1_reinstall', then shutdown sld, make snapshot 'sld', start vm
- [ ] ndb: alter system stop database BO2;alter system start database BO2;
- [ ] sld: `mv /usr/sap/SAPBusinessOne_/Common/tomcat/cert/healthcare-xnull.com.pfx /usr/sap/SAPBusinessOne/Common/tomcat/cert`
- [ ] sld: restore b1_shf files, cleanup
- [ ] adm/rds: start, no network, stop sap services, enable network, start upgrade OR uninstallation & installation
- [ ] adm: replace ssl certificate on integration framework
- [ ] adm: double check integration framework
- [ ] ndb/sld: initialize db's @ :40000/Enablement
- [ ] adm: collect b1 installation logs (C:\\ProgramData\\SAP\\SAP Business One\\Log\\SAP Business One\\Administrator\\SetupWizard\\SetupSummary) and update partner to take over
- [ ] adm/rds: `choco uninstall -y bulk-crap-uninstaller`
- [ ] ndb/sld/adm/rds: shutdown vms and make another snapshot when done with everything
- [ ] ndb/sld/adm/rds: double check vm network adapter checkmark, network should always be enabled at start
- [ ] ndb/sld/adm/rds: vm snapshot delete

## after

- [ ] veeam backup ok last night
- [ ] hana backup ok last night
- [ ] get confirmation from partner
- [ ] delete unneded snapshots or other files
- [ ] summarize
- [ ] log time
- [ ] delete LOGINS
- [ ] delete /usr/sap/SAPBusinessOne/B1_SHF_
- [ ] go sleep
- [ ] review this checklist
- [ ] review this checklist once more

# LEAVE

## customer

- [ ] remove system from monitoring / https://jezz.systems:64009/icingaweb2/monitoring/tactical / https://zabbix.isystems-integration.com/
- [ ] alter system stop database on multi tenant (login to SYSTEMDB as SYSTEM then `alter system stop database XYZ;`)
- [ ] VM shutdown, wait for next backup then remove VMs from the host
- [ ] disable not delete in UTM (users, network, interface, dhcp, firewall, nat, site2site)
- [ ] disable not delete in FTP (user account)
- [ ] point dns records to 127.0.0.1
- [ ] update sheets: server VPNs+Backups + Hosting
- [ ] zip sharepoint folder: customer-left.zip

## employee

- [ ] block VPN
- [ ] Change vCenter User Password
- [ ] Block Domain User
- [ ] Block O365 and remove licence
- [ ] Block Backup Server User
- [ ] Change FTP User Password
- [ ] Block Ansible Login
- [ ] Transfer Mailstore Archive to Steffen

# SETUP

detailed checklists for various systems

## xclarity

- [ ] log in and check : CPU, RAM
- [ ] if something is missing or wrong, correct it now
- [ ] BMC Configuration>User: Name from *USERID* to *admin_xcc*
- [ ] BMC Configuration>User: *admin_xcc* change password
- [ ] BMC Configuration>User: set password to not expire, set 0 where possible
- [ ] BMC Configuration>Network: Static IP, Disable ipv6, DNS
- [ ] Store SSH keys: iSystems Support - SAP > Templates & Documents > ssh-xcc.bat
- [ ] if it is imm and not xcc: ssh to server and execute the command   `tls -min 1.2`
- [ ] Events>Alert Recipients: configure SMTP Server (IP Address: `isystems-mailing.de` Port:`587` User: `eu@isystems-mailing.de` Password: `eEu^6k95`)
- [ ] Events>Alert Recipients: Create Email Recipient (Name: `iSystems` Email: `sysmessages@isystems-integration.com` Critical: `all` Attention: `all except Power redundancy warning and Warning Power Threshold Exceeded and Non-critical Fan events` System: `Operating System boot failure and Predicted failure(PFA)`)
- [ ] Server Configuration>Server Properties: Location (Address) and Contact (Email)
- [ ] Set Time: [pool.ntp.org](http://pool.ntp.org), Sync 30, Auto Adjust Daylight Savings
- [ ] Server Configuration>Boot Options:USB,CD,HDD
- [ ] Home > System Name: "XCC - Customer - Location - S/N"
- [ ] Register the Lenovo Server
- [ ] Raid:  Start the Server > F1 then configure Raid for SSD/SAS and M.2
- [ ] Maximum Performance: Start the Server > F1 > UEFI Setup > System Settings > Operating Modes > Maximum Performance / UEFI Setup > System Settings > Devices and I/O Ports > PCI 64-Bit Resource Allocation = Disable and MM Config Base 3GB ([System tuning for VMware on x86 Servers and ThinkSystem - Lenovo ThinkSystem and Lenovo Server - Lenovo Support DE](https://support.lenovo.com/de/en/solutions/ht115952-system-tuning-for-vmware-on-x86-servers-and-thinksystem-lenovo-thinksystem-and-lenovo-server))
- [ ] GPT Auto Repair: Start the Server > F1 > UEFI Setup > System Settings > Recovery and RAS > DISK GPT Recovery > Automatic + save & reboot
- [ ] Fix TPM Warning in vCenter7 (only for ESXI): uefi setup > system settings > security > physical presence > toggle and enable > save, then: uefi setup > system settings > security > physical presence > secure boot config > enable > save > exit bios

## idrac

- [ ] system > overview: check CPU and RAM
- [ ] storage > virtual hard disk check RAID5 ( SAS, SSD ), RAID1 (M.2)
- [ ] create raid if necessary: storage>  virtual hard disk > create virtual hard disk > advanced configuration
- [ ] if something is missing or wrong, correct it now
- [ ] iDRAC-settings > users > local user: name from *root* to *admin_idrac*
- [ ] iDRAC-settings > user > Lokale user: *admin_idrac* change password
- [ ] iDrac-settings > connectivity > network > general settings: change DNS name
- [ ] iDrac-settings > connectivity > network > general settings: change domainname
- [ ] iDrac-settings > connectivity > network > IPv4-settings: change static IP, DNS
- [ ] store SSH keys: iSystems Support - SAP > Templates & Documents > ssh-idrac.bat
- [ ] iDRAC-settings > settings > SMTP: configure SMTP server (IP Address: `isystems-mailing.de` send email address: `eu@isystems-mailing.de` SMTP-interface number:`587` user: `eu@isystems-mailing.de` password: `eEu^6k95` connection encryption: `STARTTLS`)
- [ ] configuration > systemsettings > warning configuration > warnings: enable
- [ ] configuration > systemsettings > warning configuration > warnings > quick alert configuration: 1. all, 2. critical and warning, 3. email
- [ ] configuration > systemsettings > warning configuration > SMTP: email warning 1 enable + adress `sysmessages@isystems-integration.com`
- [ ] system > details > systemdetails > location: register location
- [ ] configuration > asset-monitoring> name of owner: `name`, systemlocation: `adress`, user-defined assets `owners email: email`
- [ ] iDRAC-settings > settings > timezone and NTP: set time zone and add time server: [pool.ntp.org](http://pool.ntp.org)
- [ ] register the Dell server
- [ ] configuration > BIOS-settings > processor settings: Dell controlled turbo `enabled`

## esxi

- [ ] VIA USB ONLY: prepare the bootstick with *ks.cfg* and */efi/boot/boot.cfg* ( `kernelopt=ks=usb:/efi/boot/ks.cfg` or `kernelopt=runweasel ks=cdrom:/EFI/BOOT/KS.CFG` or `kernelopt=netdevice=vmnic0 bootproto=dhcp ks=nfs://192.168.182.71/ISO/etc/ks.cfg`)
- [ ] VIA NETWORK ONLY: edit ks.cfg on FTP (ESXI6.5:`/isystems/vmware/iso/VMware-ESXi-6.5.0.update02-9298722-LNV-20180919_ks_nfs.txt`, ESXI7:`/isystems/vmware/iso/VMware-ESXi-7.0.1.-16850804-LNV-20200917_ks_nfs.txt`) mount ISO via NFS
- [ ] mount NFS share *B1H*: B1H, 192.168.189.100, /B1H, NFS3 ( `ssh root@192.168.189.100 -p 60022 && cat /etc/exports && exportfs -ra` )
- [ ] mount NFS share *ISO*: ISO, 192.168.182.71,  /ISO, NFS3
- [ ] create storage
- [ ] install ovftool (SFTP and SSH to ESXI, copy Ovftool to a Datastore (`iSystems Support - Netzwerke > iSystems > ovftool`), chmod -R 777 and chmod +x,alias ovftool in /etc/profile.local)
- [ ] SNMP( `esxcli system snmp set --communities mgmt;esxcli system snmp set --enable true;esxcli network firewall ruleset set --ruleset-id snmp --allowed-all true;` )
- [ ] check autostart ( active, 300s, 300s, shutdown, tact wait / Order: 1.DC,2.SLES,3.ADM,4.OTHER )
- [ ] Copy most important ISO to Datastore for later use (Windows, Veeam, Paragon)
- [ ] #Download/Mount ISO (sftp://vmware:Zo7ou&igoh@gebck.privatcloud.biz:55667/backup/vmware/iso)
- [ ] esxcli network firewall set --enabled false && wget <https://blog.friedlandreas.net/wp-content/uploads/2014/12/ProfileESXi-Host-2.png> && esxcli network firewall set --enabled true

## proxmox

- [ ] to be added

## windows VM

- [ ] server vs. workstation, version, language
- [ ] create DC ( 2xCPU, 4GB RAM, 40GB HDD/SSD Thick, ISO )
- [ ] create ADM ( 4xCPU, 8GB RAM, 60GB HDD/SSD Thick, ISO )
- [ ] create RDS (4 CPU Cores per 5 Users and 2 GB RAM per User, 80GB HDD/SSD Thick, ISO )
- [ ] start VM and log in with default password
- [ ] drop VM into folder and customize Veeam (Hosted) or Check ProxmoxBackup Job
- [ ] server user=administrator, workstation user=admin
- [ ] VMWare-Tools install completely

### windows

- [ ] server Manager: hostname, diskmgmt, lusrmgr administrator PW (Password never expires), IPv4 Config, IPv6 off, file extension and hidden elements, privat network (secpol.msc > security settings > network-list-manager-guidelines), green dasboard, time, energy options maximum power, screen never off, reboot
- [ ] ChocolateyStd: `choco install -y googlechrome notepadplusplus 7zip && choco upgrade all`
- [ ] Install Tailscale (NOT ON DC!) (only Customer Site)
- [ ] install SAP B1: for terminal server & workstations install HDBClient&B1Client using `SAP.PS1`
- [ ] install SAP B1: for admin server install HDBClient&B1Client&HANAStudio&B1Components: set HANAStudio=1 before running `SAP.PS1`, then use setup wizard to install RSP,SDK,DTW,B1i (B1i="Integration Solution Components") + Crystal Reports see the correct version here SAP NOTE: [2329487 - Crystal Reports for SAP Business One Matrix](https://me.sap.com/notes/2329487)
- [ ] install language pack ( <https://dennisspan.com/managing-windows-languages-and-language-packs/#CompleteInstallationScript> )
- [ ] allow icmp and smb access for server 2019: `Set-NetFirewallRule FPS-SMB-In-TCP -Enabled True;Set-NetFirewallRule FPS-ICMP4-ERQ-In -Enabled True;` or `netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow`
- [ ] allow access to specific ports if needed: `netsh advfirewall firewall add rule name=SAP protocol=TCP dir=in localport=80,443,1433,7299,8080,8100,8443,40000,40020 action=allow`
- [ ] Install Sophos Antivirus on all Windows Servers but not on DC and not for DEMO Tenants (Only if customer is hybrid cloud customer)
  <https://bookstack.isystems-integration.com/books/sophos/page/install-sophos-antivirus-with-mdr-on-server-for-isystems-hosted-customers>
- [ ] install license: cmd > `slmgr.vbs /ipk QPGMN-4FHPW-7PXXY-XDXTH-PWHYQ`
- [ ] If Customer is Unirez set Display language to german and disable password reset for Unirez Admin User
- [ ] continue with WINDOWS_DOMAIN or WINDOWS_LOCAL
- [ ] install zabbix on all servers (check SLES Version, needs 15.2 or higher) https://bookstack.isystems-integration.com/books/zabbix

#### WINDOWS_DOMAIN

- [ ] Install Domain, use win_ad.ps1
- [ ] check reverse lookup domain
- [ ] join servers
- [ ] double check reverse lookup domain, joined servers should be there
- [ ] add missing dns records, ie: sld, hana, dbs
- [ ] import default domain policy settings `\iSystems Support - SAP\EMEA\Customers\Support\Microsoft\2k19_default_domain_policy.zip`
- [ ] Install RDS with Change Password Site (C:\\Windows\\Web\\RDWeb\\Pages\\en-US\\login.aspx tauschen), use win_rds.ps1
- [ ] Create Users use win_ad_users.ps1
- [ ] add rds user cals using Service Provider Lizense Aggrement 67475361 (User + 2)

#### WINDOWS_LOCAL

do this only in workgroup setup

- [ ] the steps to follow are only needed if you do not have a domain. if you have a domain, use the **rds-script.ps1**
- [ ] windows updates > gpedit.msc > computer > administrative templates > windows-components > windows update: configure automatic updates > 4, schedule daily, 3 am, install updates for other ms products ( OR <https://www.bheil.net/notes/1-klick-update-unter-windows-mit-powershell-und-chocolatey.html> )
- [ ] insecure guest access may be needed on 2019: gpedit.msc > computer > administrative templates > network > LanMan-workstation: enable insecure guest login > enabled
- [ ] add users to administrators as required
- [ ] Add the Feature >> Remote Desktop Services >> session host and license server
- [ ] open license manager and activate server
- [ ] add rds user cals using Service Provider Lizense Aggrement 67475361
- [ ] cmd > gpedit.msc > computerconfiguration > administrative templates > windows-components > remote desktop services > remote desktop session host > licensing > use specified remote desktop license servers > enable + enter license server (127.0.0.1)
- [ ] cmd > gpedit.msc > computerconfiguration > administrative templates > windows-components > remote desktop services > remote desktop session host > licensing > per user
- [ ] cmd > gpedit.msc > computerconfiguration > administrative templates > windows-components > remote desktop services > remote desktop session host> session time limits > set time limit for separate sessions > enable + 2 hours
- [ ] cmd > gpedit.msc > computerconfiguration > administrative templates > windows-components > remote desktop services > remote desktop session host> session time limits > end session when time limit is reached > enable
- [ ] cmd > `gpupdate /force`

### sql

- [ ] Create new disks for the VM (100GB = App // 100GB = Data // 200GB = Log)
- [ ] prefer IPv4 over IPv6: `Set-Itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters" -Name "DisabledComponents" -value 32`
- [ ] choco install -y sql-server-2019 sql-server-management-studio
- [ ] move the iso to your downloads folder and restart the windows server `C:\Users\Administrator\AppData\Local\Temp\1\chocolatey\sql-server-2019\14.0.1000\SQLServer2019-x64-ENU-Dev.iso`
- [ ] mount the iso > Maintenance > Edition Upgrade > enter key: `PHDV4-3VJWD-N7JVP-FGPKY-XBV89` (2017) `PMBDC-FXVM3-T777P-N4FY8-PKFF4` (2019)
- [ ] After Installation change Data paths in SQL Studio > SQL Server > Properties > DB Setting (Backup = Disk App // Data = Disk Data // Logs = Disk Log // Temp = Disk App)
- [ ] Change Maximum server Memory SQL Studio > SQL Server > Properties > Memory > Maximum server memory (in MB) choose Memory of SQL Server
- [ ] change the password and set sql login mode for sa user: see below **win_sql**
- [ ] set Lock Pages in Memory on 64-bit SQL Server ( sap note 1134345 ): gpedit.msc > Local Computer Policy > Computer Configuration > Windows Settings > Security Settings > Local Policies > User Rights Assignments > Lock pages in Memory > User = 'NT Service\\MSSQL'
- [ ] in SQL Server Configuration Manager > SQL Server Network Configuration > Protocols for SQL > TCP/IP > Enable/Activate ALL
- [ ] in SQL Server Configuration Manager > SQL Server Services > restart the SQL Server Instance

- [ ] install SAP B1 (Install on Disk App): Repository,RSP,ServiceLayer,ServerTools=SLD,JobServer,SAPBusinessOneClient
- [ ] Open SAP Business One Service Manager > Set License Manager to start when operating system starts, then start it
- [ ] set LicenseServer IPv4: `Set-Itemproperty -Path "HKLM:\SOFTWARE\WOW6432Node\ACE\TAO" -Name "TaoNamingServiceOptions" -value "-ORBEndPoint iiop://127.0.0.1:30000 -ORBDottedDecimalAddresses 1"`
- [ ] replace 'localhost' with 'SQL' in 'C:\\Program Files\\SAP\\SAP Business One\\Conf' and 'C:\\Program Files\\SAP\\SAP Business One DI API\\Conf' xml files
- [ ] open SAPBusinessOneClient as administrator
- [ ] set ntfs and sharing permissions 'C:\\Program Files (x86)\\SAP\\SAP Business One Server\\B1_SHR' (give full permission to domain users), disable caching on the share
- [ ] move the B1 Installation folder and SQL server iso to B1_SHR folder
- [ ] import SBODEMO (copied are on the ftp in iso folder or see  `iSystems Consulting e.K\iSystems Support - SAP\EMEA\Customers\Support\SAP\B1_Demo_Databases_Overview.pdf`)
- [ ] verify connectivity, ie. to SLD
- [ ] reboot and verify connectivity again
- [ ] install ODBC driver on other windows servers that do not run mssqlserver: `choco install -y sqlserver-odbcdriver` `choco install -y sqlserver-odbcdriver --version=18.3.1.1` `choco install -y sqlserver-odbcdriver --version=17.8.1.1` `choco install -y sqlserver-odbcdriver --version=13.1.4413.46`

### sysprep

- [ ] go to audit snapshot and boot system, update.cmd (few times), reboot if windows update, upgrade.cmd, sysprep audit reboot, sysprep audit shutdown, create update snapshot
- [ ] scan.cmd, clean.cmd, sysprep audit reboot, wisediskcleaner, sysprep audit shutdown, create snapshot audit
- [ ] sysprep oobe unattend ( set correct xml before running, ie. w2k19en )
- [ ] scsi mode sas, boot paragon, defrag & compress mft on all partitions, shutdown, set iso to guest local, scsi mode paravirtual ( + add "PG_Customer" nic for Klaus )
- [ ] make ova `myVM="" && myFolder=/vmfs/volumes/ISO/template/ova && mv "$myFolder/$myVM.ova" "$myFolder/$myVM.ova.bak" && ovftool --noSSLVerify "vi://root:Tarantu95@127.0.0.1/$myVM" "$myFolder/$myVM.ova"`
- [ ] test ova `myVM="" && myFolder=/vmfs/volumes/ISO/template/ova && ovftool -n="$myVM" -ds="NVME2" -dm="thick" "$myFolder/$myVM.ova" "vi://root:Tarantu95@127.0.0.1"` or `ovftool -n="lala" -ds="NVME2" -dm="thick" "ftp://vmware:secret@192.168.191.23:21/iso/win10.ova" "vi://root:Tarantu95@127.0.0.1"` or `cd /vmfs/volumes/RAID10 && wget "ftp://vmware:secret@192.168.191.23/iso/win10.ova" && echo run ovftool as usual`
- [ ] compare ova size, revert to last audit snapshot, delete all snapshots, cleanup scripts folder, sysprep audit shutdown, create audit snapshot
- [ ] exchange ova on other locations ( ie. our ftp, ansible servers, etc.?! )

### veeam

- [ ] latest Veeam version on backup server
- [ ] new datastores: REFS, 64K
- [ ] add datastores: Veeam > Backup Infrastructure > Backup Repositories > Add Repository
- [ ] add esxi: > Inventory > Virtual Infrastructure  > Add Server
- [ ] add daily hana backup task
- [ ] add daily windows backup tasl
- [ ] add service provider: `veeam.isystems-integration.com` (only if ordered), on 192.168.191.202 Veeam > Cloud Connect > Tenants > Add Tenant

## sles

- [ ] ESXI und HANA in hosts: `/home/ansible/hosts` ( `cd /home/ansible && ansible -m ping esxi` )
- [ ] HANA last used macs: `ssh -p 44556 root@isystems-integration.com "ls -lahr /var/www/wordpress/bz8d3ky5/controlfiles/44444*      |head -n 50"`
- [ ] Reserve Sles Mac:    `ssh -p 44556 root@isystems-integration.com "touch    /var/www/wordpress/bz8d3ky5/controlfiles/44444400444a"`
- [ ] HANA in configs: `/home/ansible/hosts/autoinst/configs/kunde.conf`
- [ ] install HANA: `screen -dRR && /home/ansible/00-scripts/02-createVM-ESXi-std-hanab1.sh kunde.conf && ssh-copy-id -i ~/.ssh/id_rsa.pub root@kundeipv4 && ansible kundehostname -m ping`
- [ ] change password
- [ ] RDP, eject CD and adjust time
- [ ] RDP, hana studio login with secure storage
- [ ] test backup script. if demo/test system do: `ALTER SYSTEM ALTER CONFIGURATION ('global.ini', 'SYSTEM') SET ('persistence', 'log_mode') = 'overwrite' WITH RECONFIGURE;`
- [ ] ndbadm allow `echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/sapb1servertools status'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/sapb1servertools restart'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/sapb1servertools stop'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/sapb1servertools start'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/b1s stop'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/b1s start'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /etc/init.d/b1s restart'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl stop sapb1servertools'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl start sapb1servertools'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl restart sapb1servertools'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl status sapb1servertools'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl status sapinit'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl stop sapinit'>>/etc/sudoers;echo 'ndbadm ALL=(ALL) NOPASSWD: /bin/systemctl start sapinit'>>/etc/sudoers;`
- [ ] enter hardware key in serverquestions, open `https://localhost:40000/LicenseControlCenter/`
- [ ] install Tailscale if needed (on all hana servers, not on SLD, delete connection if customer has no support): `hostname="3868dd4b3b78.pve.omega.tegrous" && zypper ar -g -r https://pkgs.tailscale.com/stable/opensuse/leap/15.1/tailscale.repo && zypper ref 'Tailscale stable' && zypper in -y tailscale && systemctl enable --now tailscaled && sleep 3 && tailscale up --authkey=tskey-b12beb40c36a8a4530ef0422 --hostname=$hostname && ip addr show tailscale0`
- [ ] for B1 V10, update JAVA_OPTS by editing `vi /etc/init.d/sapb1servertools` and replace `Xmx5120M` with `Xmx8192M`
- [ ] reconfigure backup service ( do not restart hana automatically! ): `tenant="NDB";mkdir -p /backup/service;mkdir -p /backup/service/$tenant;mkdir -p /backup/service/$tenant/working;mkdir -p /backup/service/$tenant/exports;chmod -R 777 /backup/service; chown -R b1service0:b1service0 /backup/service;`, run `/usr/sap/SAPBusinessOne/setup` > reconfigure > update backup service > backup folder: /backup/service/NDB/exports, log folder: leave as is, working folder: /backup/service/NDB/working; max size: 5000, compress: check > view changes and apply
- [ ] for hana V2 only: yast > system > boot loader > kernel parameters > transparent_hugepage=never // `ALTER SYSTEM ALTER CONFIGURATION ('global.ini','SYSTEM') SET ('memorymanager','global_allocation_limit') = '65535' WITH RECONFIGURE;`
- [ ] when partner is conplus, disable the webclient: `systemctl disable webclient;systemctl stop webclient`
- [ ] when partner is unirez, add their ssh keys to root user
- [ ] when partner is unirez, add additional ssh user for their backup tool
- [ ] shutdown: `systemctl stop sapb1servertools sapinit && systemctl poweroff`
- [ ] adjust vm hardware if needed
- [ ] import SBODEMODE or SBODEMOUS
- [ ] write down databse port for multitenant systems (SELECT DATABASE_NAME, SQL_PORT FROM SYS_DATABASES.M_SERVICES)
- [ ] update Hana/SLD services with customer ssl certificate

## sophos

### services

```
Services
Web:443         (Web Clients for SAP Business One)
Sld:40000       (System Landscape Directory:/ControlCenter,Mobile Service:/mobileservice/...)
B1s:50000       (Service Layer)
Dis:8100        (Dispatcher)
B1i:8443        (Integration Framework)
Rds:3389/?      (/rdweb)
Ssh:22     
Www:443,80,... (all other)

Example of Services:
External:{Partner}{Customer}_{Service}_{ExternalPort}
Internal:{Partner}{Customer}_{Service}_{ExternalPort}_{InternalPort}
External:ConplusFollowme_Rds_10043
Internal:-
External:ConplusFollowme_Dis_40104
Internal:ConplusFollowme_Dis_40104_8100
External:IsystemsKlaus_Ssh_1337
Internal:IsystemsKlaus_Ssh_1337_22
```

### sslvpn

- [ ] support > advanced > routes : Look for already existing network
- [ ] interfaces & routing > interfaces > additional address : add additional address
- [ ] definitions & users > network definitions > network definitions: create new network definition
- [ ] definitions & users > users & groups > groups: create new group if not yet available
- [ ] remote access > SSL > profiles > new remote access profile: create SSL VPN with the created group and at the new created network
- [ ] definitions & users > users & groups > users : download SSL VPN packages for the users and then put the packages on the FTP

## synology

- [ ] create admin user 'isystems' and note the password
- [ ] check details of the nas: what services are running, users&groups, storage, ipconfig, apps installed, what is actually being used
- [ ] disable all unused services, harden security
- [ ] install missing packages if needed (maybe tailscale?)
- [ ] create share 'veeam', remove all permissions, only for isystems user and ip of veeam backup server @ nfs
- [ ] add share to veeam backup server via NFS
- [ ] add backup job OR copy job, adjust archiving if you have a lot of space on NAS
- [ ] install ActiveBackupforBusiness+o365: see below, update ip+user+passwd+serial_number
- [ ] https://forum.tailscale.com/t/outbound-synology-not-working/2498/8
- [ ] sleep 1 && ( /var/packages/Tailscale/target/bin/tailscale configure-host ; synosystemctl restart pkgctl-Tailscale.service ) &

# RACK

- [ ] check address
- [ ] check devices or orders
- [ ] position rack appropriately
- [ ] screw on grounding
- [ ] adjust rails
- [ ] mounting devices
- [ ] take a picture of the devices, as well as the numbers
- [ ] name devices (label)
- [ ] connect the devices (z.B. Switch, Firewall, AP...)
- [ ] set up firewall
- [ ] set up switches
- [ ] set up accesspoint
- [ ] run tests
- [ ] lay cables neatly
- [ ] netbox
- [ ] fill empty spaces with bubble wrap
- [ ] check delivery bill and shipping address
- [ ] pack and secure properly

# hana_license_fix

## partner

- [ ] Remove existing license system pertaining SAP HANA Database from License key portal
- [ ] Request new license file for your SAP HANA Database 2.0, refer to SAP Note 1739427 (New system number will be generated with new license file)

## isystems

- [ ] received license file from partner
- [ ] coordinated downtime with customer
- [ ] check services are working
- [ ] Add connections via SYSTEM@SYSTEMDB & SYSTEM@NDB in Hana Studio
- [ ] Execute the following via SYSTEM@NDB       : `unset system license all;`
- [ ] Execute the following via SYSTEM@SYSTEMDB  : `unset system license all;`
- [ ] Install the license via SYSTEM@SYSTEMDB    : using hana studio > properties > license
- [ ] Install the license via SYSTEM@NDB #2645528: `set system license 'license_key';`
- [ ] check license assignment in hana studio
- [ ] check services are working
- [ ] Details see 'EMEA\\Customers\\Unirez\\Profagus\\20220906\\AW_ SAP Hänger.msg'

# CODE

code snippet collection

## win_sql

```sql
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO
ALTER LOGIN [sa] WITH PASSWORD=N'Test1234'
GO
ALTER LOGIN [sa] ENABLE
GO
```

## win_pki

Boockstack > iSystems > Windows > Certificates > Pki Script for RDS SSL

## win_ad

```powershell
#run:
#Enable-PSRemoting;winrm quickconfig;Set-Item wsman:\localhost\client\TrustedHosts -Value * -Force
#change:
$dcip       = "10.2.121.3"
$dcusr      = "administrator"
$dcpw       = "K2dZtb1m"
$rdsip      = "10.2.121.5"
$rdsusr     = "administrator"
$rdspw      = "K2dZtb1m"
$ndc        = "dc"
$nrd        = "rds"
$rdd        = "ukumwelt.privatcloud.biz"
$rnb        = "UKUMWELT"
$netw       = "10.2.121.0/28"
$dnsip1     = "$dcip"
$dnsip2     = "127.0.0.1"
$dnsfw1     = "9.9.9.9"
$dnsfw2     = "8.8.8.8"
$withadm    = "1"
#only when withadm=1
$nadm       = "adm"
$admip      = "10.2.121.4"
$admusr     = "administrator"
$admpw      = "K2dZtb1m"
#keep:
$dcpass     = ConvertTo-SecureString -AsPlainText $dcpw -Force
$rdspass    = ConvertTo-SecureString -AsPlainText $rdspw -Force
$admpass    = ConvertTo-SecureString -AsPlainText $admpw -Force
$dccred     = New-Object System.Management.Automation.PSCredential -ArgumentList $dcusr,$dcpass
$rdscred    = New-Object System.Management.Automation.PSCredential -ArgumentList $rdsusr,$rdspass
if ($withadm -eq 1 ) {
 $admcred   = New-Object System.Management.Automation.PSCredential -ArgumentList $admusr,$admpass
}
$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass
echo DomainControllerRename
Invoke-Command -ComputerName $dcip -Credential $dccred -ScriptBlock {
 Enable-PSRemoting;winrm quickconfig
 Rename-Computer -NewName $Using:ndc -Restart -Force
}
Start-Sleep -s 180
echo DomainControllerInstall
Invoke-Command -ComputerName $dcip -Credential $dccred -ScriptBlock {
 Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature
 Import-Module ADDSDeployment
 Install-ADDSForest -DomainName $Using:rdd -DomainNetBiosName $Using:rnb -DomainMode WinThreshold -ForestMode WinThreshold -SkipPreChecks -InstallDns:$true -SafeModeAdministratorPassword $Using:dcpass -Force
}
Start-Sleep -s 360
echo DomainControllerSetting
Invoke-Command -ComputerName $dcip -Credential $domaincred -ScriptBlock {
 (Get-ADDomain | Format-List Name, DomainMode) + (Get-ADForest | Format-List Name, ForestMode)
 Add-DnsServerPrimaryZone -NetworkID $Using:netw -ReplicationScope Domain -DynamicUpdate Secure -PassThru
 ipconfig /registerdns
 Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses "$Using:dnsip1","$Using:dnsip2"
 Set-DnsServerForwarder -IPAddress "$Using:dnsfw1","$Using:dnsfw2"
 Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation' -Name DependOnService -Value @('Bowser','MRxSmb20','NSI','DNS')
}
if ($withadm -eq 1 ) { 
 echo AdminServerRename
 Invoke-Command -ComputerName $admip -Credential $admcred -ScriptBlock {
  Enable-PSRemoting;winrm quickconfig
  Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses "$using:dnsip1"
  Rename-Computer -NewName $Using:nadm -Restart -Force
 }
 echo PleaseSetTheDnsServers
 Start-Sleep -s 180
 echo AdminServerJoin
 Invoke-Command -ComputerName $admip -Credential $admcred -ScriptBlock {
  $domain=$using:rdd
  Add-Computer –domainname $domain -restart -Credential $using:domaincred
 }
}
echo TerminalServerRename
Invoke-Command -ComputerName $rdsip -Credential $rdscred -ScriptBlock {
 Enable-PSRemoting;winrm quickconfig
 Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses "$using:dnsip1"
 Rename-Computer -NewName $Using:nrd -Restart -Force
}
echo PleaseSetTheDnsServers
Start-Sleep -s 180
echo TerminalServerJoin
Invoke-Command -ComputerName $rdsip -Credential $rdscred -ScriptBlock {
 $domain=$using:rdd
 Add-Computer –domainname $domain -restart -Credential $using:domaincred
}
```

## win_ad_users

```powershell
$dcip        = "10.2.119.3"
$rdd        = "mcbauchemie.privatcloud.biz"
$rnb        = "MCBAUCHEMIE"
$dcusr      = "administrator"
$dcpw       = "ow59neN4";$dcpass = ConvertTo-SecureString -AsPlainText $dcpw -Force;$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass
Invoke-Command -ComputerName $dcip -Credential $domainCred -ScriptBlock {
#admins
 $ADGroupMember="Domain Admins"
 $Username="acton1" ;$Password="";$Firstname="Partner";$Lastname="Admin";$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true;Add-ADGroupMember -Identity $ADGroupMember -Members $Username
 $Username="user1"  ;$Password="";$Firstname="User"   ;$Lastname="1"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user2"  ;$Password="";$Firstname="User"   ;$Lastname="2"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user3"  ;$Password="";$Firstname="User"   ;$Lastname="3"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user4"  ;$Password="";$Firstname="User"   ;$Lastname="4"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user5"  ;$Password="";$Firstname="User"   ;$Lastname="5"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user6"  ;$Password="";$Firstname="User"   ;$Lastname="6"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user7"  ;$Password="";$Firstname="User"   ;$Lastname="7"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user8"  ;$Password="";$Firstname="User"   ;$Lastname="8"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
 $Username="user9"  ;$Password="";$Firstname="User"   ;$Lastname="9"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $False -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $true
}
```

## win_rds

```powershell
#change:
$dcusr      = "administrator"                   #admin User on DC
$dcpw       = "w19w8QKL"                        #admin User Password on DC
$rnb        = "quooder"                        #Domain Name
$fqdn       = "quooder.privatcloud.biz"        #Fully Qualified Domain Name
$dcip       = "10.2.139.3"                       #IP from Domain Controller
$rdsip      = "10.2.139.5"                       #IP from RDS Server
$rdstcp     = "10237"                           #RDS Port
$tdc        = "dc.$fqdn"                        #DNS Server Name
$rdb        = "rds.$fqdn"                       #Connection Broker Name
$rdg        = "rds.$fqdn"                       #Gateway Server Name
$rds        = "rds.$fqdn"                       #Session Host Server Name
$rdw        = "rds.$fqdn"                       #Web Access Server Name
$rdl        = "rds.$fqdn"                       #License Server Name
$rdc        = "SAP"                             #Collection Name
$rdspw      = "sapB1iP";$rdspw = ConvertTo-SecureString -String "$rdspw" -AsPlainText -Force #Cert Password
$rdspfx     = 'c:\quooder.privatcloud.biz.pfx' #PFX file path
$rdscer     = 'c:\quooder.privatcloud.biz.cer' #CER file path
$langen        = "1"                            #1=en 0=de Windows Installation Language
#keep:
$dcpass     = ConvertTo-SecureString -AsPlainText $dcpw -Force #dont change $dcpass and $domaincred
$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass
echo "Enable PSRemoting"
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7.1
Enable-PSRemoting;winrm quickconfig;Set-Item wsman:\localhost\client\TrustedHosts -Value * -Force >> C:\log.txt
echo "Install Connection Broker and Web Access Server and Session Host"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/new-rdsessiondeployment?view=windowsserver2016-ps
Import-Module RemoteDesktop
New-RDSessionDeployment -ConnectionBroker $rdb -WebAccessServer $rdw -SessionHost $rds >> C:\log.txt
Start-Sleep -s 400
echo "Install Connection Broker and Session Host and Create Collection"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/new-rdsessioncollection?view=windowsserver2016-ps
New-RDSessionCollection -CollectionName $rdc -ConnectionBroker $rdb -SessionHost $rds >> C:\log.txt
echo Install Gateway Server
#https://www.it-visions.de/scripting/PowerShell/Commandlets.aspx?Add-WindowsFeature
Add-WindowsFeature -Name RDS-Gateway -IncludeManagementTools -ComputerName $rdg >> C:\log.txt
Start-Sleep -s 180
echo "ADD Gateway Server to Remote Desktop deployment"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/add-rdserver?view=windowsserver2016-ps
Add-RDServer -Server $rdg -Role "RDS-GATEWAY" -ConnectionBroker $rdb -GatewayExternalFqdn $rdg >> C:\log.txt
echo "create rdcap and rdrap and disable UDP and set Gateway Farm"
Invoke-Command -ComputerName $rdg{
 $GatewayAccessGroup = $args[0]
 $RDBrokerDNSInternalName = $args[1]
 $RDBrokerDNSInternalZone = $args[2]
 $RDSHost01 = $args[3]
 Import-Module RemoteDesktopServices
 Remove-Item -Path "RDS:\GatewayServer\CAP\RDG_CAP_AllUsers" -Force -recurse
 Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_RDConnectionBrokers" -Force -recurse
 Remove-Item -Path "RDS:\GatewayServer\RAP\RDG_AllDomainComputers" -Force -recurse
 Remove-Item -Path "RDS:\GatewayServer\GatewayManagedComputerGroups\RDG_RDCBComputers" -Force -recurse
 if ($Using:langen -eq 0 ) { 
  New-Item -Path "RDS:\GatewayServer\CAP\" -Name RDS -UserGroups "Domänen Benutzer@$using:fqdn" -AuthMethod "1"-Force
 }
 if ($Using:langen -eq 1 ) { 
  New-Item -Path "RDS:\GatewayServer\CAP\" -Name RDS -UserGroups "Domain Users@$using:fqdn" -AuthMethod "1"-Force
 }
 Set-Item -Path "RDS:\GatewayServer\CAP\RDS\DeviceRedirection\Printers" -Value "1"
 Set-Item -Path "RDS:\GatewayServer\CAP\RDS\DeviceRedirection\SerialPorts" -Value "0"
 Set-Item -Path "RDS:\GatewayServer\CAP\RDS\DeviceRedirection\PlugAndPlayDevices" -Value "0"
 if ($Using:langen -eq 0 ) { 
  New-Item -Path "RDS:\GatewayServer\RAP\" -Name RDS -UserGroups "Domänen Benutzer@$using:fqdn" -ComputerGroupType "2" -Force
 }
 if ($Using:langen -eq 1 ) { 
  New-Item -Path "RDS:\GatewayServer\RAP\" -Name RDS -UserGroups "Domain Users@$using:fqdn" -ComputerGroupType "2" -Force
 }
 #generates an error but seems working
 New-Item -Path "RDS:\GatewayServer\GatewayFarm\Servers" -Name $using:rdg -Force
 Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\TerminalServerGateway\Config\Core" IsUdpEnabled -Value 0
} >> C:\log.txt
echo set "rddeplyment configuration"
#https://docs.microsoft.com/en-us/powershell/module/rdmgmt/set-rddeploymentgatewayconfiguration?view=windowsserver2019-ps
Set-RDDeploymentGatewayConfiguration -GatewayMode Custom -GatewayExternalFQDN $rdg -LogonMethod AllowUserToSelectDuringConnection -UseCachedCredentials $True -BypassLocal $False -ConnectionBroker "$rdb" -force >> C:\log.txt
Start-Sleep -s 180
echo set "DNS Records"
#https://docs.microsoft.com/en-us/powershell/module/dnsserver/add-dnsserverresourcerecorda?view=windowsserver2019-ps
Import-Module RemoteDesktop
Add-DnsServerResourceRecordA -ComputerName $tdc -Name $rdg -ZoneName $fqdn -AllowUpdateAny -IPv4Address $rdsip >> C:\log.txt
echo "Install License Server and add to Remote Desktop deployment"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/add-rdserver?view=windowsserver2016-ps
Add-RDServer -Server $rdl -Role "RDS-LICENSING" -ConnectionBroker $rdb >> C:\log.txt
echo "change RDS Licence Configuration"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/set-rdlicenseconfiguration?view=windowsserver2016-ps
Set-RDLicenseConfiguration -LicenseServer $rdl -Mode PerUser -ConnectionBroker $rdb -Force >> C:\log.txt
if ($langen -eq 0 ) { 
 ADD-ADGroupMember "Terminalserver-Lizenzserver" –members "rds$" >> C:\log.txt
}
if ($langen -eq 1 ) { 
 ADD-ADGroupMember "Terminal Server License Servers" –members "rds$" >> C:\log.txt
}
echo "set Certificate"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/set-rdcertificate?view=windowsserver2016-ps
Set-RDCertificate -Role RDPublishing -ImportPath $rdspfx -Password $rdspw -ConnectionBroker $rdb -Force >> C:\log.txt
Set-RDCertificate -Role RDRedirector -ImportPath $rdspfx -Password $rdspw -ConnectionBroker $rdb -Force >> C:\log.txt
Set-RDCertificate -Role RDWebAccess  -ImportPath $rdspfx -Password $rdspw -ConnectionBroker $rdb -Force >> C:\log.txt
Set-RDCertificate -Role RDGateway    -ImportPath $rdspfx -Password $rdspw -ConnectionBroker $rdb -Force >> C:\log.txt
echo "copy Certificate to RDS Server"
copy $rdscer \\$rds\c$ >> C:\log.txt
echo "Install Nuget"
Invoke-Command -ComputerName $rdg -Credential $domaincred -ScriptBlock {
 [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Install-PackageProvider Nuget –Force;Install-Module -Name PowerShellGet -Force -SkipPublisherCheck
} >> C:\log.txt
Start-Sleep -s 30
echo "Install RDWeb HTML5"
Invoke-Command -ComputerName $rdg -Credential $domaincred -ScriptBlock {
 Import-Module RemoteDesktop
 Install-Module -Name RDWebClientManagement;Install-RDWebClientPackage;Get-RDWebClientPackage
 Import-RDWebClientBrokerCert $using:rdscer;Publish-RDWebClientPackage -Type Production -Latest
 netsh advfirewall firewall add rule name=RDG protocol=TCP dir=in localport=$using:rdstcp action=allow
} >> C:\log.txt
#https://woodward.digital/update-html-5-remote-desktop-web-client/
echo "Please change the transport settings and Set-RDSessionCollectionConfiguration, then set the session limits"
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/set-rdsessioncollectionconfiguration?view=windowsserver2016-ps
#$settings = @"
#gatewaycredentialssource:i:0
#gatewayhostname:s:rds.quooder.privatcloud.biz:10237
#gatewayprofileusagemethod:i:1
#gatewayusagemethod:i:1
#prompt for credentials:i:0
#prompt for credentials on client:i:1
#promptcredentialonce:i:1
#redirectclipboard:i:1
#redirectcomports:i:0
#redirectdirectx:i:0
#redirectdrives:i:1
#redirectposdevices:i:0
#redirectprinters:i:1
#redirectsmartcards:i:0
#session bpp:i:16
#span monitors:i:0
#use multimon:i:0
#use redirection server name:i:1
#videoplaybackmode:i:1
#"@
#Set-RDSessionCollectionConfiguration -CollectionName SAP -CustomRdpProperty $settings -ClientDeviceRedirectionOptions Clipboard,Drive -ClientPrinterAsDefault $True -ClientPrinterRedirected $True
pause
echo "Show RDP in Portal"
Invoke-Command -ComputerName $rdg -Credential $domaincred -ScriptBlock {
 Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\CentralPublishedResources\PublishedFarms\SAP\RemoteDesktops\SAP" ShowInPortal -Value 1 –Force
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\CentralPublishedResources\PublishedFarms\SAP\RemoteDesktops\SAP" Name -Value Server –Force
} >> C:\log.txt
#https://github.com/citrixguyblog/PowerShellRDSDeployment/blob/master/Install_RDSFarm.ps1
#https://docs.microsoft.com/en-us/powershell/module/remotedesktop/?view=windowsserver2016-ps
#http://woshub.com/remote-desktop-session-time-limit/
#http://woshub.com/rdp-connection-logs-forensics-windows/
```

## win_rds_ssl_update

Bookstack > iSystems > Windows > Change RDS SSL Certificate

## win_rds_login.aspx

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts\\win_rds_login.aspx'

## win_check_dns_zabbix_tailscale

```powershell
$DnsServerCheck = 'DNS','Zabbix Agent 2','Tailscale';$DnsServerCheck | ForEach-Object { Get-Service -Name "$_" | select -property displayname,name,status,starttype };
# perixx: https://login.tailscale.com/admin/machines/100.115.60.117
# bchb:   https://login.tailscale.com/admin/machines/100.64.96.31
#
```

## win_google_services

```powershell
Write-Output 'Setting Google Services to Manual' ; 
$GoogleServices = 'GoogleChromeElevationService', 'Google Update', 'GoogleUpdater' ; 
$GoogleServices | ForEach-Object { Get-Service -DisplayName "*$_*" | ForEach-Object { Set-Service $_.Name -StartupType Manual } } ;
```

```schtasks
program: powershell.exe
argument: -NoProfile -ExecutionPolicy Bypass -Command "& { $GoogleServices = 'GoogleChromeElevationService', 'Google Update', 'GoogleUpdater'; $GoogleServices | ForEach-Object { Get-Service -DisplayName "*$_*" | ForEach-Object { Set-Service -Name $_.Name -StartupType Manual } } }"
```

```xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-11-23T00:04:43.5550005</Date>
    <Author>SPT-PRODUCTION\m.esser</Author>
    <Description>Google Services should start up Manual. Otherwise you see an alert in the Server Manager.</Description>
    <URI>\GoogleManualStartup</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Repetition>
        <Interval>PT3H</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <Enabled>true</Enabled>
      <Delay>PT30S</Delay>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -Command "&amp; { $GoogleServices = 'GoogleChromeElevationService', 'Google Update', 'GoogleUpdater'; $GoogleServices | ForEach-Object { Get-Service -DisplayName "*$_*" | ForEach-Object { Set-Service -Name $_.Name -StartupType Manual } } }"</Arguments>
    </Exec>
  </Actions>
</Task>
```

## win_b1_install

Bookstack > iSystems > Windows > Install Programms > Install SAP Client

## win_b1_java64

```text
https://help.sap.com/doc/4e7c047f2c9e4cbe97800ffaf7b68f8e/10.0/en-US/B1_for_SAP_HANA_Admin_Guide.pdf
page 183
Installed the 64-bit Java 8 and appended the directory ´$JAVA_HOME/bin´ to the system variable ´PATH´
```

## win_b1_sld_ssl

```batch
:: 2046101 - Cannot Change Certificate and Database User Password for System Landscape Directory
:: 2354423 - How to Update Browser Access SSL Certificate
:: 2530520 - SAP Business One SLD and Browser Access require a valid SSL certificate
set  "certificate=c:\mpressed.pfx"
echo move "%certificate%" "C:\Program Files (x86)\SAP\SAP Business One ServerTools\Common\tomcat"
echo "C:\Program Files (x86)\SAP\SAP Business One ServerTools\System Landscape Directory\tools\update_https_certificate.bat"
echo "do not enter quotation marks when batch asks you for the paths..."
echo "C:\Program Files (x86)\SAP\SAP Business One ServerTools\Common\tomcat"
echo "C:\Program Files (x86)\SAP\SAP Business One ServerTools\Common\tomcat\mpressed.pfx"
echo "pw:sapB1iP"
#now Update SLD External Mapping
echo "net stop B1ServerTools & net stop B1ServerTools64 & net start B1ServerTools & net start B1ServerTools64"
```

## win_b1if

```cmd
::Make Sure the Old and new certificate have the same Passwords!!!!
::CONFIGS
:: C:\Program Files\sap\SAP Business One Integration\IntegrationServer\Tomcat\webapps\B1iXcellerator\xcellerator.cfg
:: > xcl.http.localOnly=false
:: C:\Program Files\sap\SAP Business One Integration\IntegrationServer\Tomcat\conf\server.xml
::SETTINGS
netsh advfirewall firewall add rule name=SAP-B1I protocol=TCP dir=in localport=8080,8443 action=allow
::UPDATE
set "bin=C:\Program Files\sap\SAP Business One Integration\sapjre_64\bin"
set "b1i=C:\Program Files\sap\SAP Business One Integration\IntegrationServer\Tomcat\webapps\B1iXcellerator"
set "pfx=c:\Users\administrator\Downloads\iSystems[rds.e25.privatcloud.biz].pfx"
set "pwd=s"
set "tomcat=tomcat7"
set "tomcat=tomcat8"
set "tomcat=tomcat9"
set "tomcat=tomcat10"
cd "%bin%"
keytool -list -v -keystore "%b1i%\.keystore" -storepass "%pwd%"
::keytool -delete -alias tomcat -keystore "%b1i%\.keystore" -storepass "%pwd%"
set "alias=tomcat_backup"
keytool -changealias -alias "tomcat" -destalias "%alias%" -keystore "%b1i%\.keystore" -storepass "%pwd%"
keytool -importkeystore -srckeystore "%pfx%" -srcstoretype PKCS12 -destkeystore "%b1i%\.keystore" -deststoretype JKS -deststorepass "%pwd%" -srcstorepass "%pwd%"
keytool -list -v -keystore "%b1i%\.keystore" -storepass "%pwd%"
set "alias=te-0fa2d450-cf7b-49e1-9481-8de969564474"
keytool -changealias -alias "%alias%" -destalias "tomcat" -keystore "%b1i%\.keystore" -storepass "%pwd%"
net stop SAPB1iDIProxy_Monitor && net stop SAPB1iDIProxy && net stop SAPB1iEventSender && net stop %tomcat%
net start %tomcat% && net start SAPB1iEventSender && net start SAPB1iDIProxy && net start SAPB1iDIProxy_Monitor
```

```powershell
# Check Services
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy_Monitor"} 
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy"}         
Get-Service | Where-Object {$_.Name -like "SAPB1iEventSender"}     
Get-Service | Where-Object {$_.Name -like "tomcat*"}               
# Stop Services
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy_Monitor"} | Stop-Service -Force
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy"}         | Stop-Service -Force
Get-Service | Where-Object {$_.Name -like "SAPB1iEventSender"}     | Stop-Service -Force
Get-Service | Where-Object {$_.Name -like "tomcat*"}               | Stop-Service -Force
# Disable Services
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy_Monitor"} | Set-Service -StartupType Disabled
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy"}         | Set-Service -StartupType Disabled
Get-Service | Where-Object {$_.Name -like "SAPB1iEventSender"}     | Set-Service -StartupType Disabled
Get-Service | Where-Object {$_.Name -like "tomcat*"}               | Set-Service -StartupType Disabled
# Enable Services
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy_Monitor"} | Set-Service -StartupType Automatic
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy"}         | Set-Service -StartupType Automatic
Get-Service | Where-Object {$_.Name -like "SAPB1iEventSender"}     | Set-Service -StartupType Automatic
Get-Service | Where-Object {$_.Name -like "tomcat*"}               | Set-Service -StartupType Automatic
# Start Services
Get-Service | Where-Object {$_.Name -like "tomcat*"}               | Start-Service
Get-Service | Where-Object {$_.Name -like "SAPB1iEventSender"}     | Start-Service
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy"}         | Start-Service
Get-Service | Where-Object {$_.Name -like "SAPB1iDIProxy_Monitor"} | Start-Service
```

## win_b1_sso

```powershell
# if you have more than one dc, obviously you want to "replicateDcs" now ...
$Domain="RZ.TOBOL.DE";$username="sapsso";$password="secret";$Firstname="SAP";$Lastname="SSO";
New-ADuser -SamAccountname $username -userPrincipalname "$username@$Domain" -name "$Firstname $Lastname" -Givenname $Firstname -Surname $Lastname -Enabled $True -ChangepasswordAtLogon $False -Displayname "$Firstname $Lastname" -Accountpassword (convertto-securestring $password -AsPlainText -Force) -passwordNeverExpires $true
setspn -U -A $username/$Domain $username
# ... and "replicateDcs" now again
```

```shell
# open rdp to sld server, then open browser and login to ControlCenter from there, review settings
# just double check host/dns/name resolution on sld now before you go into reconfigure via setup
cat /etc/hosts; cat /etc/resolv.conf; nslookup rz.tobol.de;
# start reconfigure
/usr/sap/SAPBusinessOne/setup;
# in the next step, make sure you enter fqdn in UPPERCASE ! if you enter lowercase, you will get "authentication failed"
# > reconfigure > use domain auth,fqdn=RZ.TOBOL.DE,domain-controller=10.2.41.3,domain-user-name=sapsso,password=secret
# go back to ControlCenter in your browser and review settings again
# in ControlCenter > security > enable/update sso in order to check if the connection establishes (green light), then disable it again
# update partner that sso is ready but must be activated by them
```

## win_certs_expired

```powershell
cd c:\tools
$now = [DateTime]::Now;
$certPath = "Cert:\CurrentUser\My";
foreach($cert in Get-ChildItem -Path $certPath){
  if($cert.NotAfter -lt $now){
    Write-Host "Found a certificate:" -ForegroundColor Cyan;
    Write-Host $cert.Subject
    Write-Host "Do you want to delete it [d] export it [e] or skip [s]?" -ForegroundColor Cyan -NoNewline;
    $confirm = Read-Host;
    if($confirm -eq "d"){
      Remove-Item "$($certPath)\$($cert.Thumbprint)" -Force;
    }
    if($confirm -eq "e"){
      Export-Certificate -Cert "$($certPath)\$($cert.Thumbprint)" -FilePath ".\$($cert.Thumbprint).cer";
    }
  } 
}
```

## win_functions

```powershell
Install-Module -Name ADEssentials -AllowClobber -Force #Update-Module -Name ADEssentials #import-module adessentials #get-module adessentials | select -expandproperty exportedcommands #https://github.com/EvotecIT/ADEssentials
function sysUpdateReboot {Install-PackageProvider -Name NuGet -Force;Install-Module -Name PSWindowsUpdate -Force;Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File "c:\PSWindowsUpdate_$(get-date -f yyyy-MM-dd).log" -force;shutdown /r /t 1;}
function sysClean        {dism /online /cleanup-image /restorehealth;dism /online /cleanup-image /startcomponentcleanup /resetbase;sfc /scannow;echo y|chkdsk /x /f /r;echo j|chkdsk /x /f /r;shutdown /r /t 1;}
function replicateDcs    {(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess}
function replicateO365   {Start-ADSyncSyncCycle -PolicyType Delta;Start-Sleep 60;Start-ADSyncSyncCycle -PolicyType Initial;}
```

## win_sfc_scannow

```cmd
sfc /scannow
for /f %a in ('powershell -Command "Get-Date -format yyyyMMddTHHmmss"') do set datetime=%a
set "cbs=%windir%\logs\cbs"
set "cbs_details=cbs_details_%datetime%.txt"
findstr /c:"[SR]" "%cbs%\cbs.log" >"%cbs%\%cbs_details%"
explorer "%cbs%"
notepad "%cbs%\%cbs_details%"
:: https://www.sysnative.com/forums/threads/sfc-reporting-hash-mismatch-for-files-lserver_pkconfig-xml-tls_branding_config-xml.35419/
:: Download SFCFix.exe (by niemiro) and save this to your Desktop. https://www.sysnative.com/forums/downloads/sfcfix/
:: Download the file below, SFCFix.zip, and save this to your Desktop. Ensure that this file is named SFCFix.zip - do not rename it.
:: Save any open documents and close all open windows.
:: On your Desktop, you should see two files: SFCFix.exe and SFCFix.zip.
:: Drag the file SFCFix.zip onto the file SFCFix.exe and release it.
:: SFCFix will now process the script.
:: Upon completion, a file should be created on your Desktop: SFCFix.txt.
:: Attach this SFCFix.txt file into your next post for me to check please.
```

## win_reboots

```powershell
$today = Get-Date
$startDay = $today.AddDays(-5)
$eventIds=(6005,6006,6008,6009,1074,1076,12,13,43,109)
$systEvents=Get-WinEvent -LogName System 
$rebootEvents=$systEvents| Where-Object {$_.TimeCreated -gt $startDay} | Where-Object {$_.Id -in $eventIds}  
format-table TimeCreated,Id,Message -AutoSize -wrap -InputObject $rebootEvents
```

## win_reboots_updates

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Import-PackageProvider -Name NuGet
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSWindowsUpdate -Force
Import-Module -Name PSWindowsUpdate
$MicrosoftUpdateServiceId = "7971f918-a847-4430-9279-4a52d1efe18d"
If   ((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId)  { Write-Output "Confirmed that Microsoft Update Service is registered..." } Else { Add-WUServiceManager -ServiceID $MicrosoftUpdateServiceId -Confirm:$true }
If (!((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId)) { Throw "ERROR:  Microsoft Update Service is not registered." }
Get-WUSettings
#gpresult /h .\downloads\gpresult.html
```

```cmd
:: time
echo %date% %time%
:: dc german
schtasks /create /tn "update1" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Get-WUInstall -MicrosoftUpdate -AcceptAll -Download -Install -IgnoreReboot;shutdown /r /t 60;schtasks.exe /delete /f /tn update1\"" /sc once /st 00:59:00 /sd 31.03.2023 /ru system
:: other german
schtasks /create /tn "update1" /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Get-WUInstall -MicrosoftUpdate -AcceptAll -Download -Install -IgnoreReboot;shutdown /r /t 60;schtasks.exe /delete /f /tn update1\"" /sc once /st 02:59:00 /sd 31.03.2023 /ru system
```

## win_cleanup

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_reboot

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_update_setup

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_updates_cycle

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_updates_cycle.task

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_update_reboot

see 'Sharepoint:\\iSystems Consulting e.K\\iSystems Support - SAP\\EMEA\\Customers\\Support\\Microsoft\\Scripts'

## win_virtio_qemu_check

```powershell
# check vm config like so: root@pve018:~# cat /etc/pve/nodes/pve013/qemu-server/17222334.conf
# then check these on the windows vm like so: PS C:\Users\Administrator> 
choco list -localonly #returns no qemu installed
Get-WmiObject -Class Win32_Product
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall";foreach($obj in $InstalledSoftware){write-host $obj.GetValue('DisplayName') -NoNewline; write-host " - " -NoNewline; write-host $obj.GetValue('DisplayVersion')}
Get-WmiObject Win32_PnPSignedDriver | Select DeviceName,DriverVersion | Where {$_.DeviceName -like "*virtio*" -or $_.DeviceName -like "*qemu*"}
Get-Service | select -property displayname,name,status,starttype | Where {$_.displayname -like "*virtio*" -or $_.displayname -like "*qemu*" -or $_.displayname -like "*balloon*"}
# export drivers
New-Item -ItemType Directory -Force -Path "c:\tools\drivers\"
Export-WindowsDriver -Online -Destination "c:\tools\drivers\"
# import dirvers
Get-ChildItem "C:\tools\drivers\" -Recurse -Filter "*.inf" | ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }
```

## win_psexec

```cmd
psexec \\remoteipv4 [-u usr[-p pwd]] cmd [arguments]
net use \\remoteipv4\c$ /user:usr pwd
copy c:\sophos\sophossetup.exe \\remoteipv4\c$
psexec \\remoteipv4 -u usr -p pwd -i c:\sophossetup.exe --quiet
psexec \\remoteipv4 -u usr -p pwd -w c:\windows\system32 schtasks /create /tn Task1 /xml:%windir%\setup\scripts\task1.xml /ru usr /rp pwd
del \\remoteipv4\c$\sophossetup.exe
mstsc /v:remoteipv4 /user:usr pwd
psexec \\remoteipv4 -u usr -p pwd -i "C:\Program Files (x86)\Sophos\Management Communications System\Endpoint\Uninstall.exe"
```

## win_defender

```powershell
$currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath ; foreach ($exclusion in $currentExclusions) {
 Write-Host "Removing ExclusionPath: $exclusion"
 Remove-MpPreference -ExclusionPath $exclusion
}
Add-MpPreference -ExclusionPath (
"c:\program files (x86)\microsoft sql server",
"c:\program files (x86)\sap",
"c:\program files\microsoft sql server",
"c:\program files\sap",
"c:\programdata\sap",
"c:\windows\web",
"c:\windows\inf",
"c:\windows\system32\spool"
)
$currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess ; foreach ($exclusion in $currentExclusions) {
 Write-Host "Removing ExclusionProcess: $exclusion"
 Remove-MpPreference -ExclusionProcess $exclusion
}
Add-MpPreference -ExclusionProcess (
"agentconsole.exe",
"agentservice.exe",
"avatax.exe",
"b1browser.exe",
"b1clientagent.exe",
"blnsvr.exe",
"boy_usability.exe",
"cks.startup.exe",
"conhost.exe",
"conship.ui.exe",
"coresuite.exe",
"cscript.exe",
"csrss.exe",
"ctfmon.exe",
"dllhost.exe",
"dtw.exe",
"dwm.exe",
"explorer.exe",
"fontdrvhost.exe",
"httpd.exe",
"iashost.exe",
"inetinfo.exe",
"logonui.exe",
"lsass.exe",
"msdtc.exe",
"qemu-ga.exe",
"rdpclip.exe",
"rdpinput.exe",
"runtimebroker.exe",
"sap business one (x86).exe",
"sap business one.exe",
"sapb1idiproxy.exe",
"sapb1idiproxy_monitor.exe",
"sapb1ieventsender.exe",
"sapbouicom.exe",
"sbo.app.backend.exe",
"sbo.app.exe",
"sbo.bab.exe",
"sbo.prd.exe",
"sdxhelper.exe",
"searchui.exe",
"servermanager.exe",
"services.exe",
"shellexperiencehost.exe",
"sihost.exe",
"smartscreen.exe",
"smss.exe",
"spoolsv.exe",
"sqlbrowser.exe",
"sqlceip.exe",
"sqlservr.exe",
"sqlwriter.exe",
"svchost.exe",
"system idle process",
"system",
"tabtip.exe",
"tabtip32.exe",
"taskhostw.exe",
"taskmgr.exe",
"tomcat7.exe",
"tomcat8.exe",
"tssdis.exe",
"vmtoolsd.exe",
"w3wp.exe",
"wininit.exe",
"winlogon.exe",
"wmiprvse.exe",
"wsmprovhost.exe",
"zabbix_agent2.exe"
)
$currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionExtension ; foreach ($exclusion in $currentExclusions) {
 Write-Host "Removing ExclusionExtension: $exclusion"
 Remove-MpPreference -ExclusionExtension $exclusion
}
Add-MpPreference -ExclusionExtension (
".log",
".txt"
)

```

## win_ovftool

```cmd
set "ovftool=c:\tmp\ovftool.exe"
set  "ovadir=\\127.0.0.1\c$\tmp"
set  "ovaWin=%ovadir%\server2019std.ova"
set "ovaSles=%ovadir%\sles15.ova"
set "esxAddr=127.0.0.1"
set "esxUser=root"
set "esxPass=lala"
set "esxConn=vi://%esxUser%:%esxPass%@%esxAddr%"
set "esxData=ESXI-SSD-DATASTORE-NAME"
::import
echo "%ovftool%" -n=2k19 -dm=thick -ds="%esxData%"  "%ovaWin%" "%esxConn%"
echo "%ovftool%" -n=sles -dm=thick -ds="%esxData%" "%ovaSles%" "%esxConn%"
::export, in case needed
echo "%ovftool%" --noSSLVerify "%esxConn%/2k19" "%ovaWin%.bak"
```

## win_lgpo

```cmd
:: 'iSystems Consulting e.K\iSystems Support - SAP\EMEA\Customers\Support\Microsoft\Microsoft Security Compliance Toolkit 1.0.zip'
:: http://woshub.com/backupimport-local-group-policy-settings/#h2_8
:: https://www.der-windows-papst.de/wp-content/uploads/2019/06/Gruppenrichtlinien-%C3%BCbertragen-mit-LGPO.pdf
set "mgpo=c:\users\administrator\downloads\gpos"
set "lgpo=c:\windows\setup\scripts\sct\lgpo\lgpo_30\lgpo.exe"
if not exist "%mgpo%" mkdir "%mgpo%"
:: backup
"%lgpo%" /b "%mgpo%"
set "egpo={581011B4-50E9-4B10-9DC0-4E5199C9C1BA}"
set "ngpo=2k19"
rename "%mgpo%\%egpo%" "%ngpo%"
set "ngpo=%mgpo%\%ngpo%"
:: make readable for editing
"%lgpo%" /parse /q /m "%ngpo%\domainsysvol\gpo\machine\registry.pol">>"%ngpo%\domainsysvol\gpo\machine\registry.txt"
"%lgpo%" /parse /q /u "%ngpo%\domainsysvol\gpo\user\registry.pol"   >>"%ngpo%\domainsysvol\gpo\user\registry.txt"
:: note security and audit
dir "%ngpo%\domainsysvol\gpo\machine\microsoft\windows nt\secedit"
dir "%ngpo%\domainsysvol\gpo\machine\microsoft\windows nt\audit"
:: make it possible to restore again
"%lgpo%" /r "%ngpo%\domainsysvol\gpo\machine\registry.txt" /w "%ngpo%\domainsysvol\gpo\machine\registry.pol"
"%lgpo%" /r "%ngpo%\domainsysvol\gpo\user\registry.txt"    /w "%ngpo%\domainsysvol\gpo\user\registry.pol"
:: restore gpo only
"%lgpo%" /q /m "%ngpo%\domainsysvol\gpo\machine\registry.pol"
"%lgpo%" /q /u "%ngpo%\domainsysvol\gpo\user\registry.pol"
:: restore gpo, security and audit
"%lgpo%" /q /g "%mgpo%"
:: cleanup
rd /s /q "%ngpo%"
:: restore default gpo
rd /s /q "%windir%\system32\grouppolicy"
#https://woshub.com/update-group-policy-settings-windows/
#https://woshub.com/gpo-central-store-admx-templates/
#https://woshub.com/block-auto-update-windows-version/
```

## win_nfs

```cmd
netsh advfirewall firewall add rule name=NFS_TCP protocol=TCP dir=in localport=111,1039,1047,1048,2049 action=allow
netsh advfirewall firewall add rule name=NFS_UDP protocol=UDP dir=in localport=111,1039,1047,1048,2049 action=allow
```

```powershell
Import-Module ServerManager
Get-WindowsFeature *nfs*
Install-WindowsFeature FS-NFS-Service -IncludeAllSubFeature -IncludeManagementTools
Restart-Computer
Get-WindowsFeature | Where-Object { $_.Name -match 'NFS' }
Import-Module NFS
New-NfsShare -Name 'public' -Path 'C:\shared\public' -EnableUnmappedAccess $True -Authentication sys
Grant-NfsSharePermission -Name 'public' -ClientName '192.168.1.20' -ClientType 'host' -Permission 'readonly' -AllowRootAccess:$true
Grant-NfsSharePermission -Name 'public' -ClientName '192.168.1.21' -ClientType 'host' -Permission 'readonly' -AllowRootAccess:$true
Get-NfsShare
Get-NfsSharePermission -Name 'public'
```

## win_interface_dump_reset

```powershell
# export
mkdir c:\temp 
netsh -c interface dump > c:\\temp\\interface.txt
# import
netsh -f c:\\temp\\interface.txt
# clear
netsh interface ip reset
# removeGhosts.ps1 "X:\iSystems Consulting e.K\iSystems Support - SAP\EMEA\Customers\Support\Microsoft\removeGhosts.ps1"
. removeGhosts.ps1 -listGhostDevicesOnly
. removeGhosts.ps1
```

## win_esx_snapshot_error

```cmd
::error: Warning message from …: The guest OS has reported an error during quiescing. The error code was: 5 The error message was: VssSyncStart operation failed: IDispatch error #8451 (0x80042303)
::link: https://www.running-system.com/error-quiescing-vsssyncstart-operation-failed-idispatch-error-8451-0x80042303
::resolution1: Uninstalling VSS from vmware tools will correct this error (windows driver will be used)
msiexec /i c:\windows\installer\4d06daf2.msi
::resolution2: Deleting registry next keys will correct this error…
::[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\VSS\Providers\{564d7761-7265-2056-5353-2050726f7669}]
::[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet002\Services\VSS\Providers\{564d7761-7265-2056-5353-2050726f7669}]
::resolution3: cloning disk or vm may resolve the error
```

## win_rds_upd_vhd_fix_disk_identifiers

```powershell
# Disk X has the same disk Identifiers as one or more disks connected to the system #KB2983588
# Run this script as administrator and set the location of your vhd's
$path = "c:\rd\profiles\sap\"
# Function to change the Disk Identifier of a VHD
function Set-VhdDiskIdentifier {
    param(
        [string]$VhdPath
    )
    # Open the VHD file in read/write mode
    $fileStream = [System.IO.File]::Open($VhdPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
    try {
        # Go to offset 0x1C8
        $fileStream.Position = 0x1C8
        # Generate a new Disk Identifier
        $newIdentifier = New-Object byte[] 4
        $random = New-Object Random
        $random.NextBytes($newIdentifier)
        # Write the new Disk Identifier to the VHD
        $fileStream.Write($newIdentifier, 0, 4)
        Write-Host "New Disk Identifier set for $VhdPath."
    }
    finally {
        $fileStream.Close()
    }
}
# Main Logic
gci $path -Filter *.vhdx | ForEach-Object {
    if ($diskimage = Mount-DiskImage ($path + $_.Name) -PassThru -EA SilentlyContinue) {
        $driveletter = ($diskimage | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter + ":\"
        if (gci -hidden $driveletter -Filter *.BIN) {
            Clear-RecycleBin $driveletter -Confirm:$false
        }
        # Change the Disk Identifier for each VHDX file
        Set-VhdDiskIdentifier -VhdPath ($path + $_.Name)
        Dismount-DiskImage -ImagePath ($path + $_.Name)
    } else {
        $updSID = ($_.Name).TrimStart("UVHD-")
        $updSID = $updSID.TrimEnd(".vhdx")
        $objSID = New-Object System.Security.Principal.SecurityIdentifier $updSID
        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
        $SIDUsername = $objUser.Value
        Write-Host "The UPD: $($_.Name) ($SIDUsername) could not be opened, because it is already mounted..."
    }
}
```

## win_rds_upd_vhd_fix_disk_identifiers_pt2

```powershell
# Disk X has the same disk Identifiers as one or more disks connected to the system #KB2983588
# Run this script as administrator and set the location of your vhd's
$path = "c:\rd\profiles\sap\"

# Function to change the Disk Identifier of a VHD
function Set-VhdDiskIdentifier {
    param(
        [string]$VhdPath
    )
    try {
        Dismount-DiskImage -ImagePath $VhdPath -ErrorAction SilentlyContinue
        $fileStream = [System.IO.File]::Open($VhdPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
        $fileStream.Position = 0x1C8
        $newIdentifier = New-Object byte[] 4
        $random = New-Object Random
        $random.NextBytes($newIdentifier)
        $fileStream.Write($newIdentifier, 0, 4)
        Write-Host "New Disk Identifier set for $VhdPath."
    }
    catch {
        Write-Host "Failed to set Disk Identifier for $VhdPath. It might be in use by another process."
    }
    finally {
        if ($null -ne $fileStream) {
            $fileStream.Close()
        }
    }
}

# Main Logic
gci $path -Filter *.vhdx | ForEach-Object {
    if ($diskimage = Mount-DiskImage ($path + $_.Name) -PassThru -EA SilentlyContinue) {
        $driveletter = ($diskimage | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter
        if ($null -ne $driveletter) {
            $driveletter += ":\\"
            if (gci -hidden $driveletter -Filter *.BIN -ErrorAction SilentlyContinue) {
                Clear-RecycleBin $driveletter -Confirm:$false
            }
            Dismount-DiskImage -ImagePath ($path + $_.Name)
            Set-VhdDiskIdentifier -VhdPath ($path + $_.Name)
            Mount-DiskImage ($path + $_.Name)
        } else {
            Write-Host "Failed to obtain the drive letter for $($_.Name)."
        }
    } else {
        $updSID = ($_.Name).TrimStart("UVHD-").TrimEnd(".vhdx")
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier $updSID
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
            $SIDUsername = $objUser.Value
            Write-Host "The UPD: $($_.Name) ($SIDUsername) could not be opened, because it is already mounted..."
        }
        catch {
            Write-Host "The UPD: $($_.Name) could not be processed due to an invalid or missing SID."
        }
    }
}
```

## sles_hana_b1_versions

```text
SLES:15.2/15.3
HANA:https://files.jezz.systems/sap/SPS05rev56_2.7.26.ZIP
B1..:https://files.jezz.systems/sap/B1_10.0_FP2202HF1.ZIP
```

```text
SLES:15.4
HANA:https://files.jezz.systems/sap/SPS05rev59_2.7.26.ZIP
B1..:https://files.jezz.systems/sap/B1_10.0_FP2305HF1.ZIP
```

```text
SLES:15.4
HANA:https://files.jezz.systems/sap/SPS05rev59_2.17.22.ZIP
B1..:https://files.jezz.systems/sap/B1_10.0_FP2308.ZIP
```

## sles_updates

```shell
screen -dRR
systemctl status \
 sapb1edfbackend  \
 authentication   \
 webclient        \
 b1s50000         \
 b1s50001         \
 b1s50002         \
 b1s50003         \
 b1s50004         \
 sapb1servertools \
 sldagent         \
 sapinit          \
#sapconf
services="b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004 webclient sapb1edfbackend authentication sapb1servertools sapb1servertools-authentication sldagent sapinit"
installed_services="";for service in $services; do if systemctl is-active --quiet $service; then installed_services+=" $service"; fi; done; echo "$installed_services";
systemctl status $services | grep 'could not be found'
missing_services="webclient sapb1edfbackend authentication"
services="b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004 sapb1servertools sapb1servertools-authentication sldagent sapinit"
#sav-protect sav-rms
unitfile="'sapb1servertools\|sldagent\|sapb1edfbackend\|sapb1servertools\|webclient\|authentication\|sapb1servertools-authentication\|b1\|sap\|SAP'"
systemctl --type=service | grep $unitfile
systemctl status                $services
systemctl stop                  $services
systemctl disable               $services
systemctl enable                $services
systemctl start                 $services
systemctl reload-daemon
systemctl reset failed
$(lsof -ti:443);$(lsof -ti:7299);$(lsof -ti:40000);$(lsof -ti:50000-50010);$(lsof -ti:7299);$(lsof -ti:60010);$(lsof -ti:60000)
kill $(lsof -ti:443);kill $(lsof -ti:7299);kill $(lsof -ti:40000);kill $(lsof -ti:50000-50010);kill $(lsof -ti:7299);kill $(lsof -ti:60010);kill $(lsof -ti:60000)
snapper list #delete,create #snapper list-configs #https://www.simplified.guide/suse/snapper-remove-snapshots
snapper --config root list
snapper --config root delete 1-10
crontab -l
cat /etc/fstab #uuid should be used
cat /sys/kernel/mm/transparent_hugepage/enabled;echo never > /sys/kernel/mm/transparent_hugepage/enabled;grep -e AnonHugePages /proc/*/smaps | awk '{ if($2>4) print $0}' | awk -F "/" '{print $0; system("ps -fp " $3)}'
yast > system > boot loader > kernel parameters > transparent_hugepage=never
zypper lr -e repositories.bak;cat repositories.bak.repo | grep 'name\|enabled'
rpm -qa --queryformat '%{NAME}\n' > installed-software.bak #restore#zypper ar repositories.bak.repo#zypper install $(cat installed-software.bak)
vi /etc/zypp/zypp.conf #multiversion = provides:multiversion(kernel) #multiversion.kernels = latest,running
SUSEConnect -s
SUSEConnect --status-text
SUSEConnect --de-register
SUSEConnect --cleanup
rm -f /etc/SUSEConnect;rm -rf /etc/zypp/credentials.d/*;rm -rf /etc/zypp/repos.d/*;rm -f /etc/zypp/services.d/*
#settings
 slesRegmail="support_eu@isystems-integration.com"
 slesVersion="15.4";
 slesRegcode="3D3EDA3F88E5E94F";
#slesRegcode="3D3EDA3F88E5E94F" # Feb 02 2026 # SUSE Linux Enterprise Server - Restricted - Partner Program only Subscription 
#slesRegcode="010589DC7ABD8160" # Jan 27 2025 # SUSE Linux Enterprise Server for SAP Applications
#slesRegcode="4EC463523AFF52EC" # Jan 27 2025 # SUSE Linux Enterprise Server
#slesRegcode="D5672EC75D38F530" # Dec  3 2024 # SUSE Linux Enterprise Server for SAP Applications
#slesRegcode="23C3A7EF2FC89DA9" # Dec  3 2024 # SUSE Linux Enterprise Server
#all
SUSEConnect -r $slesRegcode -e "$slesRegmail"
SUSEConnect -r $slesRegcode -p SLES/$slesVersion/x86_64
#12 only
SUSEConnect -r $slesRegcode -p sle-module-web-scripting/12/x86_64
SUSEConnect -r $slesRegcode -p sle-module-legacy/12/x86_64
SUSEConnect -r $slesRegcode -p sle-sdk/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p PackageHub/$slesVersion/x86_64
#15 only
SUSEConnect -r $slesRegcode -p SLES/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-desktop-applications/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-web-scripting/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-legacy/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-development-tools/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-basesystem/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p PackageHub/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-python2/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-python3/$slesVersion/x86_64
SUSEConnect -r $slesRegcode -p sle-module-server-applications/$slesVersion/x86_64
#SUSEConnect -r $slesRegcode -p sle-module-python2/$slesVersion/x86_64 zypper in bc glibc-i18ndata python python-openssl python-pycrypto
zypper ar Tailscale
zypper nr Tailscale TailscaleRepo
zypper rr TailscaleRepo
zypper ref
zypper in -y zypper-migration-plugin
zypper in -y libicu60_2
zypper in -y libcap-progs
zypper in -y xmlstarlet
zypper in -y firewalld
#zypper in -y bc glibc-i18ndata python python-openssl python-pycrypto
zypper patch
zypper up
zypper migration
#SUSEConnect -d -p sle-module-python2/15.3/x86_64;#https://www.suse.com/support/kb/doc/?id=000020796
zypper purge-kernels
zypper clean -a
journalctl --vacuum-time=1d
snapper set-config SPACE_LIMIT=0.2 NUMBER_LIMIT=2-6 NUMBER_LIMIT_IMPORTANT=4
snapper cleanup number
#rm /tmp/* -rf
systemctl enable authentication b1s* webclient sapb1edfbackend sapb1servertools sldagent sapinit
#@reboot sleep 1   && systemctl stop  sldagent sapb1servertools b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004
#@reboot sleep 60  && systemctl stop  sldagent sapb1servertools b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004
#@reboot sleep 360 && systemctl start sldagent sapb1servertools && sleep 60 && systemctl start b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004
systemctl reboot
```

## sles_updates_prep

```shell
#script from klaus in here
zypper rr 1 # (bis alle repos weg sind)
/usr/sbin/SUSEConnect --de-register && sleep 1m
/usr/sbin/SUSEConnect --cleanup
rm -f /etc/SUSEConnect
rm -rf /etc/zypp/credentials.d/*
rm -rf /etc/zypp/repos.d/*
rm -f /etc/zypp/services.d/*
/usr/sbin/SUSEConnect -r 4EC463523AFF52EC -e k.joerissen@isystems-integration.com
zypper ref
SUSEConnect -p PackageHub/15.1/x86_64
SUSEConnect -p sle-module-python2/15.1/x86_64
SUSEConnect -p sle-module-legacy/15.1/x86_64
SUSEConnect -p sle-module-web-scripting/15.1/x86_64
SUSEConnect -p sle-module-development-tools/15.1/x86_64
SUSEConnect -p sle-module-desktop-applications/15.1/x86_64
zypper ref && zypper up
zypper up
```

## sles_space_checks

```shell
# btrfs snapshots can take quite some space but usually not needed: snapper list ; snapper remove x-y ( all snapshots after one with star )
# thorough cleanup of /tmp: by investigating all files.
# quick cleanup of /tmp: remove backups, export folders, or compressed zip/tar/gz files as no reason to keep them in /tmp
# recycle bin can have quite some files in it: du -sh ./.Trash-0/files/*; rm -rf ./.Trash-0/files/*;
# below some help.. modify as needed...
lsblk -o MOUNTPOINT,NAME,FSTYPE,FSSIZE,FSUSE% | grep /
df -h | grep "hana\|backup\|"
df -h | grep hana && df -h | grep backup && df -h | grep //
du -a    | sort -n -r | head -n 10
du -hs * | sort -rh   | head   -10
du -Sh | sort -rh | head -10
function chdisk() { du --max-depth=1 --threshold=100M --exclude /usr/sap,/hana,/backup --one-file-system -h $@ |sort -rh ; }
function chdisk() { du --max-depth=5 --threshold=250M                                  --one-file-system -h $@           ; }
function chfile() { find $@ -type f -size +250M -exec du -shx {} \; | sort -n ; }
```

## sles_grub_update

```shell
#GRUB
cat /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="splash=silent quiet crashkernel=207M,high crashkernel=72M,low transparent_hugepage=never mitigations=auto"
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## sles_pvscsi_vmware

```shell
# while machine is running:
# *) add vmware paravirtual controller, save changes
# *) add new disk, assign to vmware paravirtual controller, save changes
# while in sles:
# *) open yast > system > partitioner > check if new drive appears > abort
# *) open yast > system > boot loader > kernel parameters > add to command line: 'vmw_pvscsi.cmd_per_lun=1024 vmw_pvscsi.ring_pages=32' > save changes and exit yast
# *) update grub and mkinitrd: 'grub2-mkconfig -o /boot/grub2/grub.cfg;mkinitrd;'
# *) shutdown sles: 'systemctl stop sapb1servertools && systemctl stop sapinit && systemctl poweroff'
# while machine is turned off:
# *) remove new disk (from datastore) and save changes
# *) remove vmware paravirtual controller, switch lsi logic parallel to vmware paravirtual controller, save changes
# *) power on
# https://www.suse.com/support/kb/doc/?id=000019614
```

## sles_hana_rename

```shell
#https://blogs.sap.com/2016/03/12/hana-system-rename-hostname-through-hdblcmgui-command
find /hana/shared -type f -name "hdblcmgui"
find /usr/sap     -type f -name "hdblcmgui"
/hana/shared/SEC/hdblcm/hdblcmgui
```

## sles_hana_update

```shell
services="b1s b1s50000 b1s50001 b1s50002 b1s50003 b1s50004 webclient sapb1edfbackend sapb1servertools authentication sapb1servertools-authentication sldagent sapinit"
systemctl stop $services
systemctl status $services
echo "stop b1 services, leave hana services running"
sftp isystems@sftp.privatcloud.biz
cd /isystems/vmware/iso/sap
get SPS05rev56_2.7.26.ZIP
bye
rm -rf /usr/sap/SAPBusinessOne/B1_SHF/Hana_Components/*
unzip /hana/log/SPS05rev56_2.7.26.ZIP -d /usr/sap/SAPBusinessOne/B1_SHF/Hana_Components
chmod -R 777 /usr/sap/SAPBusinessOne/B1_SHF/Hana_Components
chown -R b1service0:b1service0 /usr/sap/SAPBusinessOne/B1_SHF/Hana_Components
rm /hana/log/SPS05rev56_2.7.26.ZIP
/hana/shared/NDB/hdblcm/hdblcm --action=print_component_list
/hana/shared/NDB/hdblcm/hdblcm --action=update_component_list
/hana/shared/NDB/hdblcm/hdblcm --action=update
/hana/shared/NDB/hdblcm/hdblcm --action=update_components
/hana/shared/NDB/hdblcm/hdblcm --action=check_installation
/hana/shared/NDB/hdblcm/hdblcm --sid=NDB --action=update --components=hdblcm
/usr/sap/hdbclient/install/hdbclientreg
/hana/shared/NDB/hdblcm/hdblcm --prepare_update
cd /usr/sap/SAPBusinessOne/B1_SHF/Hana_Components/SAP_HANA_DATABASE
./hdblcm
./hdblcm --ignore=check_signature_file
#./hdblcm --ignore=check_platform 
#1:n=Do you want to specify additional components location? [n]
#2:1=Update SAP HANA Database version 2.00.050.00.1592305219
#3:1=All components
#4:Enter System Database User Name [SYSTEM]
#5:Enter System Database User (SYSTEM) Password:Test1234
#6:Apply System Size Dependent Resource Limits? (SAP Note 3014176) [y]:y
#7:Has all customer specific tooling been migrated to Python 3? (y/n):
```

## sles_hana_b1system

```sql
-- SQL-Console of SYSTEMDB@NDB   // delete database
ALTER SYSTEM STOP DATABASE BO2;
DROP DATABASE BO2;

-- SQL-Console of SYSTEMDB@NDB   // create database
CREATE DATABASE BO2 ADD 'xsengine' ADD 'scriptserver' SYSTEM USER PASSWORD 9TMORD2q;
ALTER SYSTEM START DATABASE BO2;

-- SQL-Console of tenant B1SYSTEM@NDB as SYSTEM@NDB // create users and adjust rights
create user B1SYSTEM password Test1234 NO FORCE_FIRST_PASSWORD_CHANGE;
alter  user B1SYSTEM DISABLE PASSWORD LIFETIME;
grant CONTENT_ADMIN                                           to B1SYSTEM;
grant AFLPM_CREATOR_ERASER_EXECUTE                            to B1SYSTEM with admin option; -- fix PAL_ROLE
grant CREATE SCHEMA                                           to B1SYSTEM with admin option;
grant USER ADMIN                                              to B1SYSTEM with admin option;
grant ROLE ADMIN                                              to B1SYSTEM with admin option;
grant CATALOG READ                                            to B1SYSTEM with admin option;
grant IMPORT                                                  to B1SYSTEM;
grant EXPORT                                                  to B1SYSTEM;
grant INIFILE ADMIN                                           to B1SYSTEM;
grant LOG ADMIN                                               to B1SYSTEM;
grant BACKUP ADMIN                                            to B1SYSTEM;
grant CREATE ANY                          on SCHEMA SYSTEM    to B1SYSTEM;
grant SELECT                              on SCHEMA SYSTEM    to B1SYSTEM;
grant SELECT                              on SCHEMA _SYS_REPO to B1SYSTEM with grant option;
grant EXECUTE                             on SCHEMA _SYS_REPO to B1SYSTEM with grant option;
grant DELETE                              on SCHEMA _SYS_REPO to B1SYSTEM with grant option;

-- SQL-Console fix PAL_ROLE by Klaus 2022-06-17
-- as B1SYSTEM:
GRANT SELECT, INSERT, DELETE, UPDATE, EXECUTE, CREATE ANY, DROP ON SCHEMA SBOCOMMON TO SYSTEM WITH GRANT OPTION;
-- as SYSTEM
grant SELECT, INSERT, DELETE, UPDATE, EXECUTE, CREATE ANY, DROP ON SCHEMA SBOCOMMON TO B1SYSTEM WITH GRANT OPTION;
grant SELECT, INSERT, DELETE, UPDATE, EXECUTE ON SCHEMA COMMON TO B1SYSTEM WITH GRANT OPTION;
grant PAL_ROLE to B1SYSTEM;
grant EXECUTE on SYSTEM.aflpm_creator to B1SYSTEM WITH GRANT OPTION;
grant EXECUTE on SYSTEM.aflpm_creator to PAL_ROLE WITH GRANT OPTION;
grant EXECUTE on SYSTEM.aflpm_eraser to PAL_ROLE WITH GRANT OPTION;
grant EXECUTE on SYSTEM.aflpm_generator to PAL_ROLE WITH GRANT OPTION;

-- SQL-Console fix PAL_ROLE
grant AFL__SYS_AFL_AFLPAL_EXECUTE                             to B1SYSTEM with admin option;
grant AFL__SYS_AFL_AFLPAL_EXECUTE_WITH_GRANT_OPTION           to B1SYSTEM with admin option;
grant EXECUTE                       on SYSTEM.aflpm_generator to B1SYSTEM with grant option;
grant EXECUTE                       on SYSTEM.aflpm_eraser    to B1SYSTEM with grant option;
grant EXECUTE                       on SYSTEM.aflpm_creator   to B1SYSTEM with grant option;

-- SQL-Console other notes
--https://launchpad.support.sap.com/#/notes/1846194
  grant AFL__SYS_AFL_ERPA_EXECUTE         to B1SYSTEM;
  grant AFL__SYS_AFL_AFLPAL_EXECUTE       to B1SYSTEM;
  grant AFL__SYS_AFL_AFLBFL_EXECUTE       to B1SYSTEM;
--grant AFL__SYS_AFL_SOP_AREA_EXECUTE     to B1SYSTEM;
--grant AFL__SYS_AFL_POSDM_AREA_EXECUTE   to B1SYSTEM;
--grant AFL__SYS_AFL_UDFCORE_AREA_EXECUTE to B1SYSTEM;

-- SQL-Console check permissions
SELECT * FROM "PUBLIC"."EFFECTIVE_ROLES" where USER_NAME = 'B1SYSTEM';

-- SQ_-Console create users

CREATE USER MONITOR PASSWORD Mntrmhn951 NO FORCE_FIRST_PASSWORD_CHANGE;
ALTER  USER MONITOR DISABLE PASSWORD LIFETIME;
GRANT MONITORING TO MONITOR;

CREATE USER BCKH2 PASSWORD GugKVpk0 NO FORCE_FIRST_PASSWORD_CHANGE;
ALTER  USER BCKH2 DISABLE PASSWORD LIFETIME;
GRANT BACKUP ADMIN, CATALOG READ, MONITORING, LOG ADMIN, RESOURCE ADMIN TO BCKH2;

-- SQL by Dirk see below

--create the user 
CREATE USER B1SYSTEM PASSWORD YourPassword;

--grant roles
GRANT CONTENT_ADMIN TO B1SYSTEM ;
GRANT AFLPM_CREATOR_ERASER_EXECUTE TO B1SYSTEM;

--system privileges
GRANT CREATE SCHEMA TO B1SYSTEM WITH ADMIN OPTION;
GRANT USER ADMIN TO B1SYSTEM WITH ADMIN OPTION;
GRANT ROLE ADMIN TO B1SYSTEM WITH ADMIN OPTION;
GRANT CATALOG READ TO B1SYSTEM WITH ADMIN OPTION;
GRANT IMPORT TO B1SYSTEM;
GRANT EXPORT TO B1SYSTEM;
GRANT INIFILE ADMIN TO B1SYSTEM;
GRANT LOG ADMIN TO B1SYSTEM;

--grant objects
GRANT CREATE ANY, SELECT ON SCHEMA SYSTEM TO B1SYSTEM;
GRANT SELECT, EXECUTE, DELETE ON SCHEMA _SYS_REPO TO B1SYSTEM WITH GRANT OPTION;
```

## sles_hana_schema_restore

```sql
-- what is the source tenant name? what is the SYSTEM/B1SYSTEM password? any additional users? SYSTEM@SYSTEMDB:Test1234 & B1ADMIN@HDB:Test1234
-- what databases to export/import? SBOWIKPROD,SBOWIKT1
CREATE DATABASE HDB ADD 'xsengine' ADD 'scriptserver' SYSTEM USER PASSWORD Test1234;
ALTER SYSTEM STOP DATABASE HDB;
RECOVER DATA FOR HDB  USING FILE ('/backup/data/DB_NDB/COMPLETE_DATA_BACKUP') CLEAR LOG;
ALTER SYSTEM START DATABASE HDB;
-- 2356350 - Workaround for Exporting/Importing History Table OTQA Since SAP HANA 1.0 SPS 11 and HANA 2.0
-- as SYSTEM@HDB: ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_history_table_import_export') = 'true' with reconfigure;
```

## sles_fix_777_recursively

```shell
# get permissions of reference machine
permissions="/tmp/permissions_20221202_sles15"
#getfacl -p -R /.snapshots >  $permissions
#https://www.opensuse-forum.de/thread/64031-snapper-delete-findet-snapshots-nicht/?pageNo=5
getfacl -p -R /bin        >> $permissions
getfacl -p -R /boot       >> $permissions
getfacl -p -R /dev        >> $permissions
getfacl -p -R /etc        >> $permissions
getfacl -p -R /home       >> $permissions
getfacl -p -R /lib        >> $permissions
getfacl -p -R /lib64      >> $permissions
getfacl -p -R /opt        >> $permissions
getfacl -p -R /run        >> $permissions
getfacl -p -R /sbin       >> $permissions
getfacl -p -R /srv        >> $permissions
getfacl -p -R /hana       >> $permissions
getfacl -p -R /usr        >> $permissions
getfacl -p -R /backup     >> $permissions
rm                           $permissions
# copy to broken machine and restore
setfacl --restore=/tmp/permissions_backup_sles15
rm                /tmp/permissions_backup_sles15
# sles 15.3 example file is on
# sftp.privatcloud.biz:/isystems/backup/permissions_backup/permissions_backup_sles15
#Check after permissions
    #b1_shf is accessible
    #SLD is accessible
        #db is online?
        #and all the services are running
    #HANA is accesible
    #ssh is accesible
```

## sles_b1_reinstall

```shell
#2538555 - How to Perform Clean Reinstall of SAP Business One, version for SAP HANA Server Components
df -h; ls -lah /usr/sap/SAPBusinessOne/B1_SHF
systemctl stop b1s; systemctl stop sapb1servertools
kill $(lsof -ti:443);kill $(lsof -ti:7299);kill $(lsof -ti:40000);kill $(lsof -ti:40020);kill $(lsof -ti:50000-50009);kill $(lsof -ti:7299);kill $(lsof -ti:60010);kill $(lsof -ti:60000)
rpm -qa | grep B1
rpm -qa | grep B1 | xargs rpm -ev
rpm -ev B1BackupService-10.0014104-2.x86_64
drop schema SBOCOMMON,SLDDATA cascade #in what? B1SYSTEM, SYSTEM in both?
optional: drop schema RSP,B1iF
drop user COMMON cascade
cat /usr/sap/SAPBusinessOne/.installer.properties
mv /usr/sap/SAPBusinessOne /usr/sap/SAPBusinessOne_XX
rm -rf /etc/init.d/sapb1servertools
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
vim /etc/samba/smb.conf #remove sap shares
optional: update hana client @ Hana_Components\SAP_HANA_CLIENT\hdbinst
systemctl stop smb && systemctl start smb
# do you need to update sles before installing b1?
cd /usr/sap/SAPBusinessOne_/B1_SHF/10.0_SP2011HF0/Packages.Linux/ServerComponents
./install
#60000 is occupied
#restore B1_SHF files
```

## sles_openssl

```shell
openssl s_client -connect 192.168.191.210:40000 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
openssl s_client -connect 192.168.191.210:50000 < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
openssl s_client -connect 192.168.191.210:443   < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
openssl s_client -connect 192.168.191.211:8443  < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
openssl s_client -connect 192.168.191.212:443   < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
```

## sles_b1_ssl

```shell
#cd "X:\iSystems Consulting e.K\iSystems Support - SAP\EMEA\Customers\OSC\Atlas\rds\ssl"
openssl genrsa -out rds.at.privatcloud.biz.key 2048
openssl req -new -sha256 -key rds.at.privatcloud.biz.key -out rds.at.privatcloud.biz.csr -subj "/C=DE/ST=NRW/L=DUESSELDORF/O=iSystems GmbH/CN=rds.at.privatcloud.biz"
#psw>einzelzertifikate
cat root.crt           > bundle.crt
cat intermediate1.crt >> bundle.crt
openssl pkcs12 -export -out rds.at.privatcloud.biz.pfx -inkey rds.at.privatcloud.biz.key -in certificate.crt -certfile bundle.crt
#sapB1iP
openssl pkcs12 -in rds.at.privatcloud.biz.pfx -out rds.at.privatcloud.biz.crt -nokeys -clcerts
openssl x509 -inform pem -in rds.at.privatcloud.biz.crt -outform der -out rds.at.privatcloud.biz.cer
```

## sles_b1_sld_ssl

```shell
certificate="domain.privatcloud.biz"
echo "mv /usr/sap/SAPBusinessOne/B1_SHF/$certificate.pfx /usr/sap/SAPBusinessOne/Common/tomcat/cert"
echo "/usr/sap/SAPBusinessOne/ServerTools/SLD/tools/update_https_certificate.sh"
echo "/usr/sap/SAPBusinessOne/Common/tomcat"
echo "/usr/sap/SAPBusinessOne/Common/tomcat/cert/$certificate.pfx"
echo "pw:sapB1iP"
#now Update SLD External Mapping
echo "/etc/init.d/sapb1servertools stop && /etc/init.d/sapb1servertools start"
```

## sles_b1_sbomailer

```shell
#instead of          :\\10.2.70.10\b1_shf\Attachements\SAP Daten\sap\Dokumente für SAP
#use this path in B1 :\\10.2.70.10\B1_SHF\etc\attachments
#please mind lower- & capitalcase  B1_SHF
#do not use umlaute                                                            für
#do not use spaces in the path                         SAP Daten     Dokumente für SAP
# local folders on sld
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/word
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/excel
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/images
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/attachments/WBI_REF
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/attachments/WBI_BACASABLE
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/extensions
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/xml
#windows share convention
\\sld\B1_SHF\etc\word
\\sld\B1_SHF\etc\excel
\\sld\B1_SHF\etc\images
\\sld\B1_SHF\etc\attachments\WBI_REF
\\sld\B1_SHF\etc\attachments\WBI_BACASABLE
\\sld\B1_SHF\etc\extensions
\\sld\B1_SHF\etc\xml
#settings
chmod -R 777 /usr/sap/SAPBusinessOne/B1_SHF/etc
chown -R b1service0:b1service0 /usr/sap/SAPBusinessOne/B1_SHF/etc
mkdir -p /mnt/attachments/WBI_REF
mkdir -p /mnt/attachments/WBI_BACASABLE
chmod -R 777 /mnt/attachments
chown -R b1service0:b1service0 /mnt/attachments
cp /etc/fstab /etc/fstab.bak
 echo '//sld/B1_SHF/etc/attachments/WBI_REF        /mnt/attachments/WBI_REF       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab
#echo '//sld/B1_SHF/etc/attachments/WBI_REF        /mnt/attachments/WBI_REF       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
 echo '//sld/B1_SHF/etc/attachments/WBI_BACASABLE  /mnt/attachments/WBI_BACASABLE cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab
#echo '//sld/B1_SHF/etc/attachments/WBI_BACASABLE  /mnt/attachments/WBI_BACASABLE cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
cat /etc/fstab
mount -a -v
df -h | grep sld
@reboot sleep 30 && ( ls /mnt/attachments/WBI_REF ; ls /mnt/attachments/WBI_BACASABLE )
```

## sles_b1_sbomailer_extended

```shell
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/attachments/MERIDA
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/attachments/MERIDA_C
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/images/MERIDA
mkdir -p /usr/sap/SAPBusinessOne/B1_SHF/etc/images/MERIDA_C
chmod -R 777 /usr/sap/SAPBusinessOne/B1_SHF/etc
chown -R b1service0:b1service0 /usr/sap/SAPBusinessOne/B1_SHF/etc
mkdir -p /mnt/attachments/MERIDA
mkdir -p /mnt/attachments/MERIDA_C
chmod -R 777 /mnt/attachments
chown -R b1service0:b1service0 /mnt/attachments
echo '//sld/B1_SHF/etc/attachments/MERIDA    /mnt/attachments/MERIDA   cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
echo '//sld/B1_SHF/etc/attachments/MERIDA_C  /mnt/attachments/MERIDA_C cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
cat /etc/fstab
mount -a -v 
df -h | grep sld
mkdir -p /mnt/images/MERIDA
mkdir -p /mnt/images/MERIDA_C
chmod -R 777 /mnt/images
chown -R b1service0:b1service0 /mnt/images
echo '//sld/B1_SHF/etc/images/MERIDA         /mnt/images/MERIDA        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
echo '//sld/B1_SHF/etc/images/MERIDA_C       /mnt/images/MERIDA_C      cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,_netdev,noauto,x-systemd.automount 0 0'>>/etc/fstab
cat /etc/fstab
mount -a -v 
df -h | grep sld
crontab -l
@reboot sleep 30 && ( ls /mnt/attachments/MERIDA ; ls /mnt/attachments/MERIDA_C ; ls /mnt/images/MERIDA ; ls /mnt/images/MERIDA_C )
```

## service_layer_mem
```shell
zypper in smem;
for i in 1 2 3 4; do echo Port: 5000$i; smem -P lb-member-5000$i| grep -v python2; echo -e "\n"; done 
```

## service_layer_crontab
```shell
45  1-23/2 * * * sleep 1 && ( systemctl stop b1s50001 ; systemctl start b1s50001 ; sync ; echo 1 > /proc/sys/vm/drop_caches ) &
46  1-23/2 * * * sleep 1 && ( systemctl stop b1s50002 ; systemctl start b1s50002 ; sync ; echo 1 > /proc/sys/vm/drop_caches ) &
47  1-23/2 * * * sleep 1 && ( systemctl stop b1s50003 ; systemctl start b1s50003 ; sync ; echo 1 > /proc/sys/vm/drop_caches ) &
48  1-23/2 * * * sleep 1 && ( systemctl stop b1s50004 ; systemctl start b1s50004 ; sync ; echo 1 > /proc/sys/vm/drop_caches ) &
```

## sles_b1if_cleanup

```text
1) Stop Event Sender and all other data entries (http, web service...) which could be sent to B1i
2) Wait until Queue Monitor in B1i is totally empty
3) Once Queue Monitor empty, run: "TRUNCATE TABLE DBQITEMS;TRUNCATE TABLE DBQSTREAMS;"
4) Perform a Full Backup of the instance
5) Restart the HANA Instance
6) Execute the "ALTER SYSTEM RECLAIM DATAVOLUME 120 DEFRAGMENT;" statement on the instance
7) Execute the "ALTER SYSTEM RECLAIM LOG;" statement on the instance
8) Run size of tables on disk check, repeat 3-7 if required

# notes
--df -h | grep "hana\|backup\|"
--df -h | grep hana && df -h | grep backup && df -h | grep //
alter system reclaim datavolume 120 defragment;
alter system reclaim log;
alter system reclaim column lob space;
alter system reclaim row lob space;
alter system reclaim datavolume 120 defragment;
alter system reclaim log;
--2696420 - How to Manually Reclaim LOB space on SAP HANA
--2950474 - DB table growth in SAP HANA related to Packed LOB's
--HANA_Tables_LargestTables_2.00.040+
--HANA_Disks_DiskUsage_2.00.040+
--CALL CHECK_TABLE_CONSISTENCY('REPAIR_HYBRID_LOB_OVERHEAD', 'IFSERV', 'DBQITEMS');
```

## sles_ansible

```shell
# UPDATE
#Klaus Joerissen sunday, 9th june, 2019
#- ansible Server updated
#- backup in /home/20190608-ansible.tgz
#- neues Verzeichnis für die hosts-Datei: /home/ansible/customers_std
#- neue Version trägt sich sich selbst dort ein
#- neue Musterkonfiguration: SLES124-01a.conf
#Klaus Joerissen
#Start mit 00-scripts/01-createVM-ESXi-std-hanab1.sh, das alte 00.. besteht nur noch aus Kompatibilitätsgründen
# KURZ
ssh root@192.168.191.100 -p 60022
cd /home/ansible
# host und config anschauen von spielwiese
/home/ansible/hosts
/home/ansible/autoinst/configs/nizza-b1.conf
# installieren
/home/ansible/00-scripts/00-createVM-ESXi-std-hanab1.sh spielwiese

# LANG
# From: Klaus Joerißen <info@kj-dv.de> 
# Sent: Thursday, October 11, 2018 01:02
# To: Michael Esser <m.esser@isystems-integration.com>; Jan Rzadkowski <j.rzadkowski@isystems-integration.com>
# Cc: Steffen Kamphoff <s.kamphoff@isystems-integration.com>
# Subject: Installation Hana-Server
#  
# Hallo Ihr beiden,
# ich habe den Fehler gefunden und das Installationsscript auf dem Server in MG gestartet. Morgen früh werde ich kurz das Ergebnis kontrollieren und hoffen, dass alles i.O. ist.
#  
# Leider hat mein Windoofrechner die Datei zum Ablauf nicht richtig abgespeichert, daher hier nur eine kurze Zusammenfassung
#  
# 1. Zugang
# ansible Server: 192.168.189.100
# Port: 60022
#  
# 2. Screen
# screen -dRR
# - neues Fenster erstellen: Strg+a, c
# - Fenster vor: Strg+a, n
# - Fenster zurück: Strg+a, p
#  
# 3. Host-Datei anpassen
# /home/ansible/hosts
#  
# 4. Config-Datei erstellen
# - /home/ansible/autoinst/configs/Articruz.conf kopieren und an das neue Zielsystem anpassen
#  
# 5. auf dem Ziel-ESXi das Volume B1H des ansible Servers einbinden
#  
# 6. Installation im Verzeichnis /home/ansible starten mit
# 00-scripts/00-createVM-ESXi-std-hanab1.sh NAME_DER_CONFIGDATEI
#  
# während die Installation läuft, könnt Ihr 
# - mit screen einen neuen Tab aufmachen und den nächsten Server fertigstellen....
# - in einer Browserkonsole des ESXi den Installationsablauf verfolgen
# - und natürlich Kaffee trinken  
#  
# Wenn es Probleme gibt, schickt mir am besten eine Nachricht.
# Wenn es nach der Installation des SLES Grundsystems nach dem Neustart zu einem Fehler, handelt es sich zu 98% um ein Problem in der Konfiguration des Workdefenders.
#  
# Viel Erfolg
# Klaus
# 
# WINDOWS:
# - aus dem ISO-Verzeichnis die entsprechende tgz auf den ESXi kopieren und dort entpacken
mkdir /vmfs/volumes/5be2ff5b-4d3fd5d2-8a39-7cd30ae54ee0/W2K16EN
tar -xf /vmfs/volumes/3dad8eb7-c2ea8976/ISO/W2K16EN.tgz -C /vmfs/volumes/5be2ff5b-4d3fd5d2-8a39-7cd30ae54ee0/W2K16EN
# - Verzeichnis umbenennen
# - VM registrieren und starten
# - manuell die IP von DHCP auf statisch ändern
# - auf ansible-Server Hosts in hostdatei aufnehmen
# - auf ansible-Server in groups_var die Gruppendatei kopieren
# - yml-Dateien für die VMs erstellen (=kopieren und anpassen
# - ansible laufen lassen:
#   ansible-playbook pb-W"K....yml
```

## esxi_vcenter_upgrade_vmware_tools

(you can use these parameters to suppress rebooting the guest when doing automatic upgrades)[https://www.iamonit.de/vmware-tools-upgrade-without-reboot-windows/]

```text
/s /v "/qn REBOOT=ReallySuppress"
```

## esxi_ovftool

```shell
ls -lah /vmfs/volumes/ISO/template/ova/*2019*_English_*.ova
ovftool -n=NAMEVM -dm=thick -ds=NAMEDATASTORE "/vmfs/volumes/ISO/template/ova/NAMEOVA.ova" "vi://user:password@127.0.0.1"
```

## esxi_ovftool_install

```shell
ls -lah /vmfs/volumes
datastore="/vmfs/volumes/62b06be1-865775eb-0dcd-e43d1a61f9cc"
cd $datastore
#ovftoolLink="https://files.jezz.systems/etc/ovftool6.tar"
 ovftoolLink="https://files.jezz.systems/etc/ovftool7.tar"
esxcli network firewall ruleset set -e true -r httpClient
wget --no-check-certificate $ovftoolLink
esxcli network firewall ruleset set -e false -r httpClient
mkdir $datastore/ovftool
tar -xvf $datastore/ovftool*.tar -C $datastore/ovftool
chmod -R 777 ./ovftool
chmod +x ./ovftool/ovftool
      alias ovftool=$datastore/ovftool/ovftool
echo "alias ovftool=$datastore/ovftool/ovftool">>/etc/profile.local
rm $datastore/ovftool*.tar
```

## esxi_kickstart

```shell
#https://www.virten.net/2017/02/vcenter-service-appliance-6-5-tips-and-tricks/
#VMware-ESXi-6.5.0.update02-9298722-LNV-20180919.iso
accepteula
rootpw Tarantu95
install --ignoressd --firstdisk=usb --overwritevmfs --novmfsondisk
network --bootproto=static --device=vmnic0 --ip=192.168.192.3 --netmask=255.255.255.240 --gateway=192.168.192.1 --nameserver=9.9.9.9 --hostname=esxi.devnet.local
keyboard German
reboot
#%pre
#%post
%firstboot --interpreter=busybox
vim-cmd hostsvc/enable_ssh
vim-cmd hostsvc/start_ssh
vim-cmd hostsvc/enable_esx_shell
vim-cmd hostsvc/start_esx_shell
esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
esxcli network ip set --ipv6-enabled=0
esxcli system hostname set --fqdn=esxi.devnet.local
esxcli network ip dns search add --domain=devnet.local
esxcli network ip dns server add --server 1.1.1.1

#NTP
cat > /etc/ntp.conf << __NTP_CONFIG__
restrict default kod nomodify notrap noquerynopeer
restrict 127.0.0.1
server 0.europe.pool.ntp.org
server 1.europe.pool.ntp.org
server 2.europe.pool.ntp.org
server 3.europe.pool.ntp.org
__NTP_CONFIG__
/sbin/chkconfig ntpd on

#TRIAL
#rm -r /etc/vmware/license.cfg && cp /etc/vmware/.#license.cfg /etc/vmware/license.cfg && /etc/init.d/vpxa restart

#SSH
#/home/ansible/files/00-all_keys.txt
cat > /etc/ssh/keys-root/authorized_keys << __ALLE-KEYS__
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiak2aW6hwqeTs4/+oA/y09AXCjjc4EEKTmOaU0AIXY1OMD/syVz4rHV8VLohcE6tmzjzXZDmDuFSY7XnoBrBJR/ZEfCbQFCpaOQ1VZ7Z/BtRagPkjsZxUpeQ6+VQz8VmsCfxI4nhg19OOk2gBv0/hQD1HGmE2Rcu0JL2l4maZJUnCcCYhsb7j+m9B/jissncI59XjBGUSfIgixId0uUbcpW/Ze67HdhcTaImlra5zC+RPdJJSLfrlyRP+G1sDHNaS/fJXk7oLIOHpQo0zifDUkcWcKlWR201WG8pIjmUsoaBuGO69y/KIqR3fJoWArDD3uKzAqkmC2PoZYa5OWhBd root@HCC-02 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxo9UZTTksrYaTU8UVHIa6wb5+kpywel5j2kSpkYG9ibb+6zOE+VzchRAm03Gtw7Y5CT9VAQdHpCvaZJn2flxb73vU0gO/acKSRIhINz/QO33bYQnN5gX7D53Vy7TlY259/kHfOvIUGq3BF+lYF4wHrOhEbVMwjCJrH2NQfmmsfPtS6prGJba+dh0FV4K4jkX6fD9vxLST7ulbrssUxF9PcGRVmI0FOYVI2YWBZMaJp1QVLo/vwEQbDH4PCMiMOtBX5C6ot7dUgu2H+nmEeu0LWaQh+JYP3jR7yOfFLD6mkVoAkZDLkljEMJxhC21TZpbtgTf9CeTWEVj0qnIxsxml root@HCC-RZL3-01 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDClquILDs6oqokrkNS4WjKt3mh0rBuXM6VOpjKT5WV3cqiogZ8AP7tHQAIYjEPdkqDi9i7nSLEHsYV8t+Lc7W5A5DBeiSG27Fhf5H/RVbXY1TMmoMpnqAHbFVRiOY1rv9gp7j9Vu7uOYSKnVQnH7dra1N4HdBaGo/uuM3mPZCaOgqLl3RBATb0dU8mTW/eznrb69rYK3gw9U1/u0v6SopPLLBMkYQSx/jadr/L7gAIRa9yu+5sngt4jewAsqC4puU7xunjJndKGnWseYcyOzmYub2p5ce7Gia/j1RbPOF3++vwpiZAfi4clny+Ra8fwlgb9TLU+CS3bVBlBUIlfZjd klaus@Lenovo-P310 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7c2DfsgOCNSrX8GwwudGGMbmSyigGnv6bM4yCXhbE2wnPhBdF02N2JZxa1URgbaT69Q/U+Gnv7GwC0ZnJUixPcz7eNj3/U9uHstwk7FSxBfAot+M8svSE7kSLoFxf3l99QdbHneNa67K4g2pukbwtjmypChGp7X0f/gixa8VmSvGbIrwAYhZyAvXCPYPY+HFnvVz0z2KR4taq2t5gbBdpW/F/ppV4KpNDZDgkFaFSQ1EKFPWGrsetbwE6vWaPwm+JcH08CgL8fbv9JvMJmPCtkOtluIwsPV6eSLpv81v9digDYmbgYufBmrbmaplHhUaps3iA59tZReH+WVOgQHMf root@Lenovo-P310 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz2BbQyhA75M+goDLoQeQqhqQkyoYduweOxxndza8dPhCoWIF2tZFie0SPae8TFOspQ0OMHrwxCNyWsUomSxYmRi7u24+gAcV19/ZN3USlGObJ1tscx1QIucUJ2iikNuAo8pu5PpHvRBvqQ13ZZvRXidLTRK60UkQMOPhCviNIRLn9kh5iOI6NxAbaiojPaMdyr5SS0ExUX0PBXpdFcYeLXfBNA4RMyNBC3vWGalEMcbTvQ+KtMY55oSg+69+jhGPccuY2MmwNdP1aFpBxhSuyIu/wa/lD//zHSraY0QgxuTFzw1oTWlvXApeFNT3WJydrpc1TnEvJ6EZiMooDhjet klaus@X349m 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsDPj4VCKj8Aab8QGDdsL2YEL+eBiKiTzBHFgRfxxd485GtVvfYEM7ElnEVEkjFU1rP6VZcSP/k/13vlkfaMHCs1ep2dmYon7UvXiKd6LTEz1thgDL2OdRVDluL5lTPxCF5LM/wQEbrI31cRs/H2g1GE3TUcC2uYtPnoN6ZDAwdqze2sIFqF/HJPOnStGaQk89IFonvetYSBwxLdqzQ9UE4yHA5vC2nplJ5+Lzifn0wdaYikyMMFgU6iHxeJLwYO9IFVzLtuy/hV11NNCczJhZ78B883aPe6Uz7vVH7PrzFYpRhRMfD/v585wHAaD2ifa4QTGZ2v8EP+Bfdx1RkRxp root@X349m 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfZuhHrytwVj8SbzDWG+aUhxqyyP1szL1jHUqxmH8SIawLrl3aEpwXFFRxn+NeMlKktuHFBzmp07IQJspYQCE15nqJeUkB8LlMKeV7AyfKrPCDUICo1F6CweEaGduR0LKlyIBlI6uzwvdX7xJ8IvvFXXy1SSXJweecxHxkQvtSFS5uC4ba1VJqPoPTLms1+YyTLB1IFrM18qcu4vJsPrILsq2/x1773THQ2uFVfROwwi0S7HbjwKkeZDuqGtwDcn8LZ+tCsO83tSVyRheImIdDNSatQLJu7fFXp8w6w5H/RvLL5K8ihcwGs35xJ90jh6eOPLhbPxiKgrXVXVAgLK2F root@HMC-01 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBejZNhe/b5G5osjHujDF/I+l27RBKEK4pso73M4JtyBFD0XpsloifA4b0/AF2p9fjV0pf79rfWmRaAeZl+mKALuaGnUc17CjI0omw977pQLhOVXYQDAC4yhUbk63FaIwyQ49WXKTnzbPC2h+LSWK9aOKBejSdibnM2hYMvnSZg69ckFySTNsto6vC4dYGyy/zttERTyLczE2dsSZy2kdytwurB724EiE6vuBHDYgwp796Mjp4FTDXOg9NPEvqBPhlLDPQ3YaV2pZhzn579O2vxM4XUtXqcx5NckgFgdBUnQupFQVMDlyvlf3GAUl7kt1S8dDNeWrRSpxWFaQWeEXx root@dctpa-hcc-01 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiCpHdqyjOlGLAjEpYqhH+Hdrd71e6gRxJN3h1DWgubK0ygP2oltEaO5isFnsw31K4oQJly86XaxiWpBDGYuDawiUTWS4HpLMBJROqiUo3sGGis6/1hxJdsA5aBo99mnVedqLWSOzaGf3gEBMMpaUlI6IlHrQYbAB8IEd8AklqGb8eOv/0eGqPdBzTbcWQF93O/2RDux09aMfDcNaCT3i0pVGKE9eG4n/KTdp7FkwRwEPIhCwc3+Y8KX7B4PzIGlGIQ+wLUG94ebTtItgV2C65g/iXSM6Njg8nBs+whlO+zxpU4i0wy4KWDdt9GfMJedLgfLClLR9K0I3dSheT339H skamphoff@saskia.local 
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAyh9JmipuyW5kk4LsvtxD5aiwYXQYdWAXMgKGJcOHm5XGP4R62nwjvCPS0JuXMQRyvayy9EjKfnZ4BzF0zacDMNwOgZDubMxy0bHt0XKyO1lpKVQJBWBUeAZtzfMceo/NYPX/WC6FlBFI9p5NIsTCU4BkTaLJt3si7z865hkxxzBvv4KpebyWbdCqRcGbohwbgwZQvmWZSiwfBnlfR0vQWleZVDv8HIHrfKxnuYYzeO0LSNcDn4flknVNZhB3ClDjXAZBpqpjST3nvoUOdtvBzEYSutZ9TiEBzXhuHmHKLrwlpX5s448xXsECXDBuK7Tn5W/z6y0cX0z6BtBz1gyrWQ== rsa-key-20181010-michael-notebook 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDAj5HEdPDycwWXFkOb0A+eS2unzh7ruONNsqqLmDBrxwD25wD7K1bx8gF7HM5bVNzleoWoR5w4vLMwS5bnLAUXwkQ8VevEWruaaFThQpUj9QOIedjVo77j9aEcXaw0X6V/gjX/zSsX6fV+H4M992Y/4GSgrAlP0r5REmc8t6mAidHqe25D1fTgBy2jCYksJmetT7Gy+HCBUp00aJo1BHbqMLvclklfZB6nrEQCxlWjDK9CPfGTxVfF/IA6y1o61QanHQ1i1G2Kf7nZNVpRsv+hnIh8KuKdwz8WRgJp1Nwv8UBINE9VfJOEI7FWPq6/sJxeSXNR3IbjoNJxXcsxDSB root@HCC-MG-01 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIEJTbMPJbwO4mrllHoshZSEz3TSqkVlAI0d/N1+Jxrwt3E3z98w9kMMc7XkINtN9THBTkmXi2MJorABzLtk6wiDivTfBHTp27BaGkeBYfa9XM6c6I4LSYouiTG3TcGRhd0imtQnTvosGXYJOerrlVcZlBpOz9XEcmjD4Fgfy3n/jRJHkWGgt07f8P+SBEIkeDIsf8DJQ9Bm5Ap04A0JKlJ7NenmBieQNJ0ZKCrfN5L2AdQ1fONBpiet0WnSGqUZnbL7MonwMhLdFusSEbj3eSGOmPxWM9cl9DX2KRqxDwWZfcumBomX01nxyelx9mIPgsFJDRCl43NN+TTUumG/E7 root@dcdus-hcc03
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsF9dX9iBJWCgp5NSQFuX0k9+hx69xeRV0h5qVjc4fHJ4Ur61t9ltz2kQIjX9R0HYu1KMoweVBjwNr1cAFIk18XotP5KdR/Xdbpyo1ghcQB5u1HLtdkMCeO0HXNPc02o6ZQ0SGnXXKGI/4umL4iEDaq82yyhRa548BjA+Iio+FJ6kzf/88NkUGoc5UNFTUG7lpQcqyGnlv83jKfH85Psr0j3lyVVHqLT6U++yKurD0LUD7tuhvP29qhSjyuioFtsBotj7haaeQyg4HnTIazGNP/Jz0WCOSyTuNrvj1GlIQK4XzvHglbZi15zMbm3loXA7ryMqIAO2YdwCDKYS9KpccTEf2EWtal1dPBz/m3n8VyeUv7J8HXReVM7+OfM3gNiutf5A4XB7eTLXFwP1AL1Krh2cG/SUVwARcmLGE2PLA+N3xfZ3iQTfONrFaKjB9Y+g7PSh9+Whtf8xX/ytdRo98uUjyejJQgZITIUHQyB2uFpkDe/0Ku8Sjv0RX5ubw+GE= root@hcc-mg-03
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIEJTbMPJbwO4mrllHoshZSEz3TSqkVlAI0d/N1+Jxrwt3E3z98w9kMMc7XkINtN9THBTkmXi2MJorABzLtk6wiDivTfBHTp27BaGkeBYfa9XM6c6I4LSYouiTG3TcGRhd0imtQnTvosGXYJOerrlVcZlBpOz9XEcmjD4Fgfy3n/jRJHkWGgt07f8P+SBEIkeDIsf8DJQ9Bm5Ap04A0JKlJ7NenmBieQNJ0ZKCrfN5L2AdQ1fONBpiet0WnSGqUZnbL7MonwMhLdFusSEbj3eSGOmPxWM9cl9DX2KRqxDwWZfcumBomX01nxyelx9mIPgsFJDRCl43NN+TTUumG/E7 root@dcdus-hcc03
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4EhIIhIf0hyGjDOQMTVWYdcUHqrklNKVX5ldGEg7OJ0SuwWJbZJeAcqgkGVAh7GRchgHC3RrIurITcOQO6Tdpj8Fy7K48oN8AlMd3yAACchuDeXY8ADSSd4mfcsRjdoepif8JMoVATE2fRvyrqHD+KYwppv+zcvb+Dp6kCxDuuwx/3gsUiBlOUQRcQAeK51OQvdxAicxewS95qYFoqVfMNm04zf436XNEyWHo2Fpn/DGzn3m/onBSu5zjcG4xc2LA3yBFmrr0Ba2+1Z0MmZRiCo7JEbK4AjGW68+L8s0h4wyrIh/o0g8NWacFq4pJBtzUh3w+XSJCEP104lOvDMM3 isystems\stuecking@Samuel-L13
__ALLE-KEYS__

#USB
#chkconfig usbarbitrator off
#/etc/init.d/usbarbitrator stop

#PARTITION
#esxcli storage core path list
#ls /dev/disks
#disk=/dev/disks/vmhba33:C0:T0:L0
#partedUtil mklabel $disk gpt
#eval expr $(partedUtil getptbl $disk | tail -1 | awk '{print $1 " \\* " $2 " \\* " $3}') - 1
#partedUtil setptbl $disk gpt "1 2048 30025484 AA31E02A400F11DB9590000C2911D1B8 0"
#vmkfstools -C vmfs6 -S USB $disk:1

#SCRATCH
#cat /etc/vmware/locker.conf
#cd /vmfs/volumes/5c8773b0-d809b8e8-4caf-7cd30a5f9e70/
#mkdir -p esxi/scratch;cd esxi/scratch
#vim-cmd hostsvc/advopt/view ScratchConfig.ConfiguredScratchLocation
#vim-cmd hostsvc/advopt/update ScratchConfig.ConfiguredScratchLocation string /vmfs/volumes/5c8773b0-d809b8e8-4caf-7cd30a5f9e70/esxi/scratch
#vim-cmd hostsvc/advopt/view ScratchConfig.ConfiguredScratchLocation

# fix sel fulness ipmi
#localcli hardware ipmi sel clear && /etc/init.d/sfcbd-watchdog restart && services.sh restart &tail -f /var/log/jumpstart-stdout.log

# fix 503 service unavailable
# what actually works (you have to wait up to 2hrs):
services.sh restart &tail -f /var/log/jumpstart-stdout.log
# what might help (not in order, just fyi)
cat /etc/vmware/rhttpproxy/endpoints.conf
action=status ;/etc/init.d/hostd $action;/etc/init.d/vpxa $action;/etc/init.d/rhttpproxy $action;
action=stop   ;/etc/init.d/hostd $action;/etc/init.d/vpxa $action;/etc/init.d/rhttpproxy $action;
action=start  ;/etc/init.d/hostd $action;/etc/init.d/vpxa $action;/etc/init.d/rhttpproxy $action;
action=restart;/etc/init.d/hostd $action;/etc/init.d/vpxa $action;/etc/init.d/rhttpproxy $action;
#https://www.edwardsd.co.uk/work/2022/03/esx-7-0-2-503-service-unavailable/

#Klaus Joerissen [Mar 7, 2019 9:58:25 AM] 
#192.168.189.100:/B1H/install/HANA/SPS12rev122.22.tgz
#192.168.189.100:/B1H/install/B1/9.3/SP10HF0.tgz
#192.168.189.100:/B1H/ISO/SLE-12-SP4-STD-isystems.iso
#das sollte erst mal reichen
#echo "starting"
#source=/vmfs/volumes/B1H
#destin=/vmfs/volumes/USB
#cp $source/ISO/SLE-12-SP4-STD-isystems.iso $destin/ISO
#cp $source/install/HANA/SPS12rev122.22.tgz $destin/install/HANA
#cp $source/install/B1/9.3/SP10HF0.tgz $destin/install/B1/9.3
#echo "finished"
#esxcli network vswitch standard add --vswitch-name=vSwitch0 --ports=24
#esxcli network vswitch standard uplink add --uplink-name=vmnic0 --vswitch-name=vSwitch0
#esxcli network vswitch standard uplink add --uplink-name=vmnic1 --vswitch-name=vSwitch0
#esxcli network vswitch standard uplink add --uplink-name=vmnic2 --vswitch-name=vSwitch0
#esxcli network vswitch standard uplink add --uplink-name=vmnic3 --vswitch-name=vSwitch0
#esxcli network vswitch standard policy failover set --active-uplinks=vmnic0,vmnic1,vmnic2,vmnic3 --vswitch-name=vSwitch0
#esxcli network vswitch standard portgroup policy failover set --portgroup-name="Management Network" --active-uplinks=vmnic0,vmnic1,vmnic2,vmnic3
#esxcli network vswitch standard portgroup add --portgroup-name=hv100-prod0 --vswitch-name=vSwitch0
#esxcli network vswitch standard portgroup remove --portgroup-name="VM Network" --vswitch-name=vSwitch0
#vim-cmd vimsvc/task_cancel ''
#vim-cmd vimsvc/task_list
reboot
```

## esxi_update

- [ ] download offline bundle
- [ ] copy offline bundle to esxi
- [ ] ssh esxi `esxcli software vib update -d "path to file"`
- [ ] start the upgrade
- [ ] check the upgrade

## esxi_help

```shell
#https://michael.lustfield.net/misc/completely-automated-esxi-deployment
#http://www.vstellar.com/2017/08/08/system-swap-scratch-configuration-in-vsphere-6/
#https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.esxi.upgrade.doc/GUID-61A14EBB-5CF3-43EE-87EF-DB8EC6D83698.html
#https://docs.vmware.com/en/VMware-vSphere/6.0/vsphere-esxi-vcenter-server-602-installation-setup-guide.pdf
#https://www.virten.net/2014/12/unattended-esxi-installations-from-an-usb-flash-drive/
#https://www.virten.net/2014/12/howto-create-a-bootable-esxi-installer-usb-flash-drive/
#https://www.rudimartinsen.com/2018/06/09/customizing-esxi-installation-with-kickstart-files-and-pxe-boot/
#https://www.virtuallyghetto.com/2014/10/how-to-automate-vm-deployment-from-large-usb-keys-using-esxi-kickstart.html
#https://www.virtuallyghetto.com/2012/05/how-to-deploy-ovfova-in-esxi-shell.html
#https://www.tech-coffee.net/deploy-esxi-6-5-from-usb-stick-and-unattended-file/
#https://jimangel.io/post/scripted-esxi-6.7-install-to-usb/
#https://github.com/pbatard/rufus/releases/download/v3.4/rufus-3.4p.exe
#Now we have to configure the boot the load the ks.cfg automatically for the deployment.
#Open the USB stick and edit Boot.cfg. 
#Replace the following line kernelopt=runweasel by kernelopt=ks=usb:/ks.cfg
#Unplug the USB Stick and plug it on the server. You can boot the USB key to run the installer.
#https://calvin.me/reset-esxi-evaluation-license/
#rm -r /etc/vmware/license.cfg & cp /etc/vmware/.#license.cfg /etc/vmware/license.cfg & /etc/init.d/vpxa restart
#crontab.guru
#Accept VMware License agreement
accepteula
# Set the root password
rootpw Tarantu95
# Install ESXi on the first disk (Local first, then remote then USB)
#install --firstdisk --overwritevmfs
# Install ESXi on the first (USB) disk, ignore any SSD and do not create a VMFS
install --ignoressd --firstdisk=usb --overwritevmfs --novmfsondisk
# Following will create a VMFS on the second local drive
#partition datastoreM2 --onfirstdisk=local
# Set the keyboard
keyboard German
# Set the network
network --bootproto=dhcp
# reboot the host after installation is completed
reboot
# run the following command only on the firstboot
%firstboot --interpreter=busybox
# enable & start remote ESXi Shell (SSH)
vim-cmd hostsvc/enable_ssh
vim-cmd hostsvc/start_ssh
# enable & start ESXi Shell (TSM)
vim-cmd hostsvc/enable_esx_shell
vim-cmd hostsvc/start_esx_shell
# supress ESXi Shell shell warning - Thanks to Duncan (http://www.yellow-bricks.com/2011/07/21/esxi-5-suppressing-the-localremote-shell-warning/)
esxcli system settings advanced set -o /UserVars/SuppressShellWarning -i 1
# Get Network adapter information
NetName="vmk0"
# Get the IP address assigned by DHCP
IPAddress=$(localcli network ip interface ipv4 get | grep "${NetName}" | awk '{print $2}')
#Get the netmask assigned by DHCP
NetMask=$(localcli network ip interface ipv4 get | grep "${NetName}" | awk '{print $3}')
# Get the gateway provided by DHCP
Gateway=$(localcli network ip interface ipv4 get | grep "${NetName}" | awk '{print $6}')
DNS="9.9.9.9"
#VlanID="50"
# Get the hostname assigned thanks to reverse lookup zone
#HostName=$(hostname -s)
HostName=esxi
SuffixDNS="devnet.local"
FQDN="${HostName}.${SuffixDNS}"
# set static IP + default route + DNS
esxcli network ip interface ipv4 set --interface-name=vmk0 --ipv4=${IPAddress} --netmask=${NetMask} --type=static --gateway=${Gateway}
esxcli network ip dns server add --server ${DNS}
# DCTPA2 Vlan
ID=209
esxcli network vswitch standard list;esxcli network vswitch standard portgroup list;
esxcfg-vswitch --add-pg=Vlan$ID vSwitch0;esxcfg-vswitch -v $ID -p Vlan$ID vSwitch0;
/etc/init.d/hostd restart;/etc/init.d/vpxa restart;
# Set VLAN ID
#esxcli network vswitch standard portgroup set --portgroup-name "Management Network" --vlan-id 50
#Disable ipv6
esxcli network ip set --ipv6-enabled=0
# set suffix and FQDN host configuration
esxcli system hostname set --fqdn=${FQDN}
esxcli network ip dns search add --domain=${SuffixDNS}
# NTP Configuration (thanks to http://www.virtuallyghetto.com)
cat > /etc/ntp.conf << __NTP_CONFIG__
restrict default kod nomodify notrap noquerynopeer
restrict 127.0.0.1
server 0.europe.pool.ntp.org
server 1.europe.pool.ntp.org
server 2.europe.pool.ntp.org
server 3.europe.pool.ntp.org
__NTP_CONFIG__
/sbin/chkconfig ntpd on
# rename local datastore to something more meaningful
#vim-cmd hostsvc/datastore/rename datastore1 "Local - $(hostname -s)"
# restart a last time
reboot
# A sample post-install script
#%post --interpreter=python --ignorefailure=true
#import time
#stampFile = open('/finished.stamp', mode='w')
#stampFile.write( time.asctime() )
# SEL Fulness
            #reset xcc event logs then: 
localcli hardware ipmi sel clear && /etc/init.d/sfcbd-watchdog restart && services.sh restart
# MOVE DISKS
#vmkfstools –i <sourcedisk> -d thin <targetdisk>
source=
destination=
vm=
disk=
#esxcli storage core path list
#ls /dev/disks
    #consolidate vm first
#afterwards remove disk from inventory
}
vmkfstools -i "/vmfs/volumes/$source/$vm/$disk" -d thin "/vmfs/volumes/$destination/$vm/$disk"
find "/vmfs/volumes/$source/$vm" -maxdepth 1 -type f -print0 | grep -v ".vmdk" | while read file; do cp "$file" "/vmfs/volumes/$destination/$vm"; done
find "/vmfs/volumes/$source/$vm" -maxdepth 1 -type f -print0 | grep [0123456789][0123456789][0123456789][0123456789][0123456789][0123456789] | grep ".vmdk" | while read file; do cp "$file" "/vmfs/volumes/$destination/$vm"; done
#add disk to inventory, answer that you copied, then remove source
#rm -rf "/vmfs/volumes/$source/$vm"
#https://serverfault.com/questions/372526/move-vmware-esxi-vm-to-new-datastore-preserve-thin-provisioning
#VMIDsvim-cmd vmsvc/getallvms
#vim-cmd /vmsvc/unregister <Vmid>
```