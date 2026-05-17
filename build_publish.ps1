$ErrorActionPreference = "Stop"

Write-Host "[0/6] Incrementing version protocols..." -ForegroundColor Cyan

# 1. Parse and Increment module.prop
$PropContent = Get-Content module.prop
$NewVersion = ""
$NewVersionCode = 0

$UpdatedProp = foreach ($line in $PropContent) {
    if ($line -match "versionCode=(\d+)") {
        $NewVersionCode = [int]$matches[1] + 1
        "versionCode=$NewVersionCode"
    }
    elseif ($line -match "version=(\d+\.\d+)") {
        $parts = $matches[1].Split('.')
        $major = [int]$parts[0]
        $minor = [int]$parts[1] + 1
        $NewVersion = "$major.$minor"
        "version=$NewVersion"
    }
    else { $line }
}
$UpdatedProp | Set-Content module.prop

$VersionTag = "v$NewVersion"
$ZipName = "Nexus_Undervolt_$VersionTag.zip"
Write-Host "    -> New Version: $VersionTag (Code: $NewVersionCode)" -ForegroundColor Yellow

# 2. Update update.json
if (Test-Path update.json) {
    $Json = Get-Content update.json | ConvertFrom-Json
    $Json.version = $VersionTag
    $Json.versionCode = $NewVersionCode
    # Update URLs to match new version
    $Json.zipUrl = "https://github.com/Ujin-cmd/Nexus-Undervolt/releases/download/$VersionTag/$ZipName"
    $Json | ConvertTo-Json | Set-Content update.json
}

Write-Host "[1/6] Cleaning up old builds..." -ForegroundColor Cyan
Get-ChildItem Nexus_Undervolt_v*.zip | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "[2/6] Ensuring LF line endings for Android compatibility..." -ForegroundColor Cyan
$LinuxFiles = Get-ChildItem -Recurse -Include *.sh, *.prop, update-binary, updater-script
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
foreach ($f in $LinuxFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName).Replace("`r`n", "`n")
    [System.IO.File]::WriteAllText($f.FullName, $content, $Utf8NoBom)
}

Write-Host "[3/6] Compressing module payload into $ZipName..." -ForegroundColor Cyan
$ItemsToZip = Get-ChildItem -Exclude .git, update.json, changelog.md, *.ps1, *.zip, .gitignore, README.md, .gemini
Compress-Archive -Path $ItemsToZip -DestinationPath $ZipName -Force

Write-Host "[4/6] Staging and Committing source code to Git..." -ForegroundColor Cyan
if (Test-Path .git) {
    & git add .
    & git commit -m "release: Nexus Build $VersionTag"
    
    Write-Host "[5/6] Tagging current release as $VersionTag..." -ForegroundColor Cyan
    & git tag -f $VersionTag

    Write-Host "[6/6] Pushing to GitHub..." -ForegroundColor Cyan
    & git branch -m main
    & git push origin main --force
    & git push origin $VersionTag --force
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " BUILD SUCCESSFUL. VERSION BUMPED TO $VersionTag " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Create release $VersionTag on GitHub."
Write-Host "2. Upload: $ZipName"
Write-Host "3. Done! Magisk will now see the update."
