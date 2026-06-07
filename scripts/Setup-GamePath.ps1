# Setup-GamePath.ps1 — run automatically on first workspace open
# Creates gamelibs.props if it doesn't exist yet.

$propsFile = Join-Path $PSScriptRoot "..\gamelibs.props"
$propsFile = [System.IO.Path]::GetFullPath($propsFile)

if (Test-Path $propsFile) {
    Write-Host "✅ gamelibs.props already configured." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Per Aspera — Extended Commands : First-time setup          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "gamelibs.props not found. Let's create it." -ForegroundColor Yellow
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor White
Write-Host "  • Per Aspera installed via Steam"
Write-Host "  • BepInEx 6 installed (launch game once to generate interop DLLs)"
Write-Host "  • Per Aspera SDK installed as a BepInEx plugin"
Write-Host ""

# Try to auto-detect Steam install
$commonPaths = @(
    "C:\Program Files (x86)\Steam\steamapps\common\Per Aspera",
    "D:\SteamLibrary\steamapps\common\Per Aspera",
    "E:\SteamLibrary\steamapps\common\Per Aspera",
    "F:\SteamLibrary\steamapps\common\Per Aspera"
)
$detected = $commonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($detected) {
    Write-Host "Detected game at: $detected" -ForegroundColor Green
    $confirm = Read-Host "Use this path? [Y/n]"
    if ($confirm -eq '' -or $confirm -match '^[Yy]') {
        $gamePath = $detected
    }
}

if (-not $gamePath) {
    $gamePath = Read-Host "Enter your Per Aspera game path"
}

if (-not (Test-Path $gamePath)) {
    Write-Host "⚠️  Path not found: $gamePath" -ForegroundColor Red
    Write-Host "   gamelibs.props was NOT created. Edit it manually from gamelibs.props.example." -ForegroundColor Yellow
    exit 1
}

$content = @"
<Project>
  <PropertyGroup>
    <PerAsperaGamePath>$gamePath</PerAsperaGamePath>
  </PropertyGroup>
</Project>
"@

Set-Content -Path $propsFile -Value $content -Encoding UTF8
Write-Host ""
Write-Host "✅ gamelibs.props created!" -ForegroundColor Green
Write-Host "   Game path : $gamePath"
Write-Host ""
Write-Host "You can now build with: dotnet build CommandActions.slnx -c Release" -ForegroundColor Cyan
