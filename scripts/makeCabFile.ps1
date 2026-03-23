# makeCabFile.ps1
# Packages DLLs into a .cab file for Power Automate Desktop custom actions.
# Excludes the SDK DLL (Microsoft.PowerPlatform.PowerAutomate.Desktop.Actions.SDK.dll).

param(
    [Parameter(Mandatory)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$SourceDir,

    [Parameter(Mandatory)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$CabOutputDir,

    [Parameter(Mandatory)]
    [string]$CabFilename
)

$ErrorActionPreference = "Stop"

$ddf = ".OPTION EXPLICIT
.Set CabinetName1=$CabFilename
.Set DiskDirectory1=$CabOutputDir
.Set CompressionType=LZX
.Set Cabinet=on
.Set Compress=on
.Set CabinetFileCountThreshold=0
.Set FolderFileCountThreshold=0
.Set FolderSizeThreshold=0
.Set MaxCabinetSize=0
.Set MaxDiskFileCount=0
.Set MaxDiskSize=0
"

$ddfPath = Join-Path $env:TEMP "customModule.ddf"
$sourceDirLength = $SourceDir.Length

$dllEntries = Get-ChildItem $SourceDir -Filter "*.dll" |
    Where-Object {
        (-not $_.PSIsContainer) -and
        ($_.Name -ne "Microsoft.PowerPlatform.PowerAutomate.Desktop.Actions.SDK.dll")
    } |
    Select-Object -ExpandProperty FullName |
    ForEach-Object {
        '"' + $_ + '" "' + $_.Substring($sourceDirLength) + '"'
    }

$ddf += ($dllEntries -join "`r`n")
$ddf | Out-File -Encoding UTF8 $ddfPath

Write-Host "Creating cabinet file: $CabFilename" -ForegroundColor Cyan
makecab.exe /F $ddfPath
Remove-Item $ddfPath -ErrorAction SilentlyContinue

$cabPath = Join-Path $CabOutputDir $CabFilename
if (Test-Path $cabPath) {
    Write-Host "Cabinet created: $cabPath" -ForegroundColor Green
} else {
    Write-Host "ERROR: Cabinet file was not created!" -ForegroundColor Red
    exit 1
}
