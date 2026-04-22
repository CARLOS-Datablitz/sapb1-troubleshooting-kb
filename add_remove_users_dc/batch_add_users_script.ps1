## win_ad_users

```powershell:
ramotraining.nubeprivada.biz   -----> Crtl + H staufklebstoffe x <Customer>


================= Se corre solo lo de abajo ========================

$dcip		= "10.2.94.99"
$rdd        = "iconic.privatcloud.biz"
$rnb        = "iconic"
$dcusr      = "administrator"
$dcpw       = "a3HDLEf0ehYf96Pe";$dcpass = ConvertTo-SecureString -AsPlainText $dcpw -Force;$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\$dcusr,$dcpass
Invoke-Command -ComputerName $dcip -Credential $domainCred -ScriptBlock {

 $Username="user05"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="05"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user06"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="06"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user07"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="07"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 $Username="user08"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   ;$Lastname="08"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true -DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -PasswordNeverExpires $false
 
}



