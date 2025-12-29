function PKIServ {
 $certificatePath                   = 'C:\Users\e.fernandez\iSystems GmbH\iSystems Support - SAP\Customers\+++Internal\Support\Microsoft\Pki'
#$certificatePath                   = 'X:\sync\onedrive\iSystems Consulting e.K\iSystems Support - SAP\EMEA\Customers\Support\Microsoft\Pki'
 $newCertificateName                = 'boyumtest.nubeprivada.biz'
 $newCertificatePassword            = 'sapB1iP'
 $dnsNames                          = 'localhost', 'sld', 'sl', 'dc', 'b1i', 'rds', 'adm'
 $ipAddresses                       = '127.0.0.1', '10.3.92.58', '10.3.92.59', '10.3.92.51', '10.3.92.52', '10.3.92.53', '66.129.98.246'
 $certificateYears                  = '2'
 $rootCertificateName               = 'iSystems[CA]'
 $rootCertificateThumbprint         = '189CDA9829C536A51B67F3687A98B4064B310EBE'
 $intermediateCertificateName       = 'iSystems[IN]'
 $intermediateCertificateThumbprint = 'E7A486F3A0CE1B04369A6E6CCD079E0BE019F2BE'
 $newCertificateWildcard            = '*.' + $newCertificateName
 $textExtension                     = "2.5.29.17={text}DNS=$($newCertificateWildcard -join '&DNS=')&DNS=$($newCertificateName -join '&DNS=')&$($dnsNames -join '&DNS=')&IPAddress=$($ipAddresses -join '&IPAddress=')"
 $rootCertificate                   = Get-ChildItem -Path cert:\LocalMachine\My | where {$_.Thumbprint -eq $rootCertificateThumbprint}
 $intermediateCertificate           = Get-ChildItem -Path cert:\LocalMachine\My | where {$_.Thumbprint -eq $intermediateCertificateThumbprint}
 $params = @{
  Signer            = $intermediateCertificate
  KeyLength         = 2048
  KeyAlgorithm      = 'RSA'
  HashAlgorithm     = 'SHA256'
  KeyExportPolicy   = 'Exportable'
  NotAfter          = (Get-Date).AddYears($certificateYears)
  Subject           = '*.' + $newCertificateName
  TextExtension     = $textExtension
  CertStoreLocation = 'Cert:\LocalMachine\My'
 }
 $newCertificate = New-SelfSignedCertificate @params
 $certificateName = "iSystems[$newCertificateName]"
 Export-PfxCertificate -Cert $newCertificate -FilePath "$certificatePath\$certificateName.pfx" -Password (ConvertTo-SecureString -AsPlainText $newCertificatePassword -Force)
 Export-Certificate -Cert $newCertificate -FilePath "$certificatePath\$certificateName.cer"
}
PKIServ


