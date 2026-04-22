# ejecutar lo de abajo en el PowerShell ICE como administrador
#change:
$dcusr      = "administrator"                   #admin User on DC
$dcpw       = "k88SG1l8kzWq"                #admin User Password on DC
$rnb        = "ghzmatra"                        		#Domain Name
$fqdn       = "ghzmatra.privatcloud.biz"        		#Fully Qualified Domain Name
$dcip       = "10.2.90.131"                    #IP from Domain Controller
$rdsip      = "10.2.90.133"                    #IP from RDS Server
$rdstcp     = "21049"                           #RDS Port
$tdc        = "dc.$fqdn"                        #DNS Server Name
$rdb        = "rds.$fqdn"                       #Connection Broker Name
$rdg        = "rds.$fqdn"                       #Gateway Server Name
$rds        = "rds.$fqdn"                       #Session Host Server Name
$rdw        = "rds.$fqdn"                       #Web Access Server Name
$rdl        = "rds.$fqdn"                       #License Server Name
$rdc        = "SAP"                             #Collection Name
$rdspw      = "sapB1iP";$rdspw = ConvertTo-SecureString -String "$rdspw" -AsPlainText -Force #Cert Password
$rdspfx     = 'c:\ghzmatra.privatcloud.biz.pfx' #PFX file path
$rdscer     = 'c:\ghzmatra.privatcloud.biz.cer' #CER file path
$langen        = "1"                            #1=en 0=de Windows Installation Language
#keep:
$dcpass     = ConvertTo-SecureString -AsPlainText $dcpw -Force #dont change $dcpass and $domaincred
$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass




echo "Install RDWeb HTML5"
Invoke-Command -ComputerName $rdg -Credential $domaincred -ScriptBlock {
 Import-Module RemoteDesktop
 Install-Module -Name RDWebClientManagement;Install-RDWebClientPackage;Get-RDWebClientPackage
 Import-RDWebClientBrokerCert $using:rdscer;Publish-RDWebClientPackage -Type Production -Latest
 netsh advfirewall firewall add rule name=RDG protocol=TCP dir=in localport=$using:rdstcp action=allow
} >> C:\log.txt