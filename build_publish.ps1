$ErrorActionPreference = "Stop"

# Auto-detect version from module.prop
$VersionObj = Get-Content module.prop | Select-String "version=(.*)" -CaseSensitive
$VersionStr = "v3.0"
if ($VersionObj.Matches.Groups[1].Value) {
    $VersionStr = "v" + $VersionObj.Matches.Groups[1].Value.Trim()
}

$ZipName = "Nexus_Undervolt_$VersionStr.zip"

Write-Host "[1/6] Cleaning up old builds..." -ForegroundColor Cyan
if (Test-Path $ZipName) { Remove-Item $ZipName -Force }

Write-Host "[2/6] Ensuring LF line endings for Android compatibility..." -ForegroundColor Cyan
$LinuxFiles = Get-ChildItem -Recurse -Include *.sh, *.prop, update-binary, updater-script
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
foreach ($f in $LinuxFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName).Replace("`r`n", "`n")
    [System.IO.File]::WriteAllText($f.FullName, $content, $Utf8NoBom)
}

Write-Host "[3/6] Compressing module payload into $ZipName..." -ForegroundColor Cyan
# IMPORTANT: Magisk requires files at the root of the ZIP.
# We explicitly get items and compress them.
$ItemsToZip = Get-ChildItem -Exclude .git, update.json, changelog.md, *.ps1, *.zip, .gitignore, README.md
Compress-Archive -Path $ItemsToZip -DestinationPath $ZipName -Force

Write-Host "[4/6] Staging and Committing source code to Git..." -ForegroundColor Cyan
if (Test-Path .git) {
    & git add .
    & git commit -m "release: Nexus Build $VersionStr (Fixed LF/Paths)"
    
    Write-Host "[5/6] Tagging current release as $VersionStr..." -ForegroundColor Cyan
    & git tag -f $VersionStr

    Write-Host "[6/6] Pushing to GitHub..." -ForegroundColor Cyan
    & git branch -m main
    & git push origin main --force
    & git push origin $VersionStr --force
} else {
    Write-Host "[!] Git not initialized in this folder. Skipping push." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " BUILD SUCCESSFUL. SECURE UPLINK ESTABLISHED. " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "The module archive is ready: $ZipName"
Write-Host "Please re-flash this ZIP in Magisk app."
