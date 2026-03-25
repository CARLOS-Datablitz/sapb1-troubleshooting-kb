## win_ad_users

```powershell:
ramotraining.nubeprivada.biz   -----> Crtl + H staufklebstoffe x <Customer>


================= Se corre solo lo de abajo ========================

$dcip		= "10.2.104.35"
$rdd        = "democarlos.nubeprivada.biz"
$rnb        = "DEMOCARLOS"
$dcusr      = "administrator"
$dcpw       = "Rxq9XvfmuaY4AZ6d";$dcpass = ConvertTo-SecureString -AsPlainText $dcpw -Force;$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass
Invoke-Command -ComputerName $dcip -Credential $domainCred -ScriptBlock {

 $Username="user01"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="01"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user02"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="02"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user03"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="03"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user04"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="04"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 
}



