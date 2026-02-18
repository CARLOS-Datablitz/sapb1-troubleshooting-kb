# ===== RDS CALs Per User (RDS) =====
# Ejecutar como Administrador en el servidor de licencias RDS

$keyPacks = Get-WmiObject -Class Win32_TSLicenseKeyPack -Namespace "root\cimv2" |
            Where-Object { $_.KeyPackType -eq 2 -and $_.ProductVersionID -eq 6 }

$total     = ($keyPacks | Measure-Object -Property TotalLicenses     -Sum).Sum
$issued    = ($keyPacks | Measure-Object -Property IssuedLicenses    -Sum).Sum
$available = ($keyPacks | Measure-Object -Property AvailableLicenses -Sum).Sum

Write-Host "===== RDS CALs Per User (RDS) =====" -ForegroundColor Cyan
Write-Host "Total instaladas : $total"            -ForegroundColor White
Write-Host "En uso (Issued)  : $issued"           -ForegroundColor Yellow
Write-Host "Disponibles      : $available"        -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
