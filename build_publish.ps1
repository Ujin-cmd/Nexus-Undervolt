$ErrorActionPreference = "Stop"

# Auto-detect version from module.prop
$VersionObj = Get-Content module.prop | Select-String "version=(.*)" -CaseSensitive
$VersionStr = "v3.0"
if ($VersionObj.Matches.Groups[1].Value) {
    $VersionStr = "v" + $VersionObj.Matches.Groups[1].Value.Trim()
}

$ZipName = "Nexus_Undervolt_$VersionStr.zip"

Write-Host "[1/5] Cleaning up old builds..." -ForegroundColor Cyan
if (Test-Path $ZipName) { Remove-Item $ZipName -Force }

Write-Host "[2/5] Compressing module payload into $ZipName..." -ForegroundColor Cyan
# Copy everything into a temp staging folder so we can zip the folder contents cleanly
$StagingDir = Join-Path $env:TEMP "NexusBuildStaging"
if (Test-Path $StagingDir) { Remove-Item $StagingDir -Recurse -Force }
New-Item -ItemType Directory -Path $StagingDir | Out-Null

$ItemsToProcess = Get-ChildItem -Exclude .git, update.json, changelog.md, *.ps1, *.zip, .gitignore
foreach ($Item in $ItemsToProcess) {
    Copy-Item -Path $Item.FullName -Destination $StagingDir -Recurse -Force
}

# Compress the contents of the staging directory
Compress-Archive -Path "$StagingDir\*" -DestinationPath $ZipName -Force

# Cleanup staging
Remove-Item $StagingDir -Recurse -Force

Write-Host "[3/5] Staging and Committing source code to Git..." -ForegroundColor Cyan
git add .
git commit -m "release: Nexus Build $VersionStr"

Write-Host "[4/5] Tagging current release as $VersionStr..." -ForegroundColor Cyan
git tag -f $VersionStr

Write-Host "[5/5] Pushing matrix to GitHub via SSH..." -ForegroundColor Cyan
# Git branch -m main handles default master->main rename just in case
git branch -m main
git push origin main
git push origin $VersionStr -f

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " BUILD SUCCESSFUL. SECURE UPLINK ESTABLISHED. " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Go to https://github.com/Ujin-cmd/Nexus-Undervolt/releases"
Write-Host "2. Draft a new release -> Select tag $VersionStr"
Write-Host "3. Upload the generated file: $ZipName"
Write-Host "4. Publish Release. OTA update will trigger automatically for existing users."
