# createTestCert.ps1
# Creates a self-signed code signing certificate for PoC testing.
# Run this script AS ADMINISTRATOR.
#
# WARNING: Self-signed certs are for development/PoC only.
#          For production, use an organizational certificate.

param(
    [string]$CertName = "PAD Custom Action PoC",
    [string]$PfxOutputPath = "$PSScriptRoot\..\HelloWorldCert.pfx",
    [string]$PfxPassword = "HelloWorld123!"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Creating Self-Signed Code Signing Certificate ===" -ForegroundColor Cyan

# Create the certificate in CurrentUser\My
$cert = New-SelfSignedCertificate `
    -Subject "CN=$CertName" `
    -Type CodeSigningCert `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(1)

Write-Host "Certificate created: $($cert.Thumbprint)" -ForegroundColor Green

# Export to PFX
$securePassword = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $PfxOutputPath -Password $securePassword | Out-Null
Write-Host "Exported to: $PfxOutputPath" -ForegroundColor Green

# Install into Trusted Root CA (requires admin for LocalMachine, or use CurrentUser)
$rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "CurrentUser")
$rootStore.Open("ReadWrite")
$rootStore.Add($cert)
$rootStore.Close()
Write-Host "Installed into CurrentUser Trusted Root CA store" -ForegroundColor Green

# Also add to Trusted Publisher for signtool
$publisherStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPublisher", "CurrentUser")
$publisherStore.Open("ReadWrite")
$publisherStore.Add($cert)
$publisherStore.Close()
Write-Host "Installed into CurrentUser Trusted Publisher store" -ForegroundColor Green

Write-Host ""
Write-Host "=== Certificate Setup Complete ===" -ForegroundColor Cyan
Write-Host "Thumbprint : $($cert.Thumbprint)"
Write-Host "PFX File   : $PfxOutputPath"
Write-Host "PFX Password: $PfxPassword"
Write-Host ""
Write-Host "Next step: Run signAndPackage.ps1 to sign and package the module." -ForegroundColor Yellow
