# signAndPackage.ps1
# All-in-one script: signs all DLLs, packages into .cab, signs the .cab.
# Run from the project root directory.

param(
    [string]$PfxPath = "$PSScriptRoot\..\HelloWorldCert.pfx",
    [string]$PfxPassword = "HelloWorld123!",
    [string]$BuildConfig = "Release",
    [string]$CabName = "Modules.HelloWorld.cab"
)

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$binDir = Join-Path $projectRoot "bin\$BuildConfig\net472"
$outputDir = Join-Path $projectRoot "output"
$signtool = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"

# Verify prerequisites
if (-not (Test-Path $PfxPath)) {
    Write-Host "ERROR: PFX file not found at $PfxPath" -ForegroundColor Red
    Write-Host "Run createTestCert.ps1 first." -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $binDir)) {
    Write-Host "ERROR: Build output not found at $binDir" -ForegroundColor Red
    Write-Host "Run 'dotnet build -c $BuildConfig' first." -ForegroundColor Yellow
    exit 1
}
if (-not (Test-Path $signtool)) {
    Write-Host "ERROR: signtool.exe not found at expected path." -ForegroundColor Red
    exit 1
}

# Create output directory
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# Step 1: Sign all DLLs
Write-Host ""
Write-Host "=== Step 1: Signing DLLs ===" -ForegroundColor Cyan
$dlls = Get-ChildItem $binDir -Filter "*.dll" |
    Where-Object { $_.Name -ne "Microsoft.PowerPlatform.PowerAutomate.Desktop.Actions.SDK.dll" }

foreach ($dll in $dlls) {
    Write-Host "  Signing: $($dll.Name)" -ForegroundColor White
    & $signtool sign /f $PfxPath /p $PfxPassword /fd SHA256 /t http://timestamp.digicert.com $dll.FullName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  WARNING: Timestamping failed, signing without timestamp..." -ForegroundColor Yellow
        & $signtool sign /f $PfxPath /p $PfxPassword /fd SHA256 $dll.FullName
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Failed to sign $($dll.Name)" -ForegroundColor Red
            exit 1
        }
    }
}
Write-Host "All DLLs signed successfully." -ForegroundColor Green

# Step 2: Package into .cab
Write-Host ""
Write-Host "=== Step 2: Creating Cabinet File ===" -ForegroundColor Cyan
& "$PSScriptRoot\makeCabFile.ps1" -SourceDir "$binDir\" -CabOutputDir $outputDir -CabFilename $CabName

# Step 3: Sign the .cab
Write-Host ""
Write-Host "=== Step 3: Signing Cabinet File ===" -ForegroundColor Cyan
$cabPath = Join-Path $outputDir $CabName
& $signtool sign /f $PfxPath /p $PfxPassword /fd SHA256 /t http://timestamp.digicert.com $cabPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARNING: Timestamping failed, signing without timestamp..." -ForegroundColor Yellow
    & $signtool sign /f $PfxPath /p $PfxPassword /fd SHA256 $cabPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to sign cab file" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== All Done! ===" -ForegroundColor Green
Write-Host "Output: $cabPath" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Go to https://make.powerautomate.com" -ForegroundColor White
Write-Host "  2. Navigate to Data > Custom actions" -ForegroundColor White
Write-Host "  3. Click 'Upload custom action'" -ForegroundColor White
Write-Host "  4. Upload: $cabPath" -ForegroundColor White
Write-Host "  5. Open Power Automate Desktop, go to Assets Library > Custom Actions" -ForegroundColor White
Write-Host "  6. Include 'Hello World' and use it in a flow!" -ForegroundColor White
