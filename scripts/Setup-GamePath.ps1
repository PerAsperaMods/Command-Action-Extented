# Setup-GamePath.ps1 — run automatically on first workspace open
# Guides contributors through: game path → BepInEx → SDK → gamelibs.props

$propsFile = Join-Path $PSScriptRoot "..\gamelibs.props"
$propsFile = [System.IO.Path]::GetFullPath($propsFile)

function Write-Step { param($n, $text) Write-Host "  [$n] $text" -ForegroundColor Cyan }
function Write-Ok   { param($text)      Write-Host "  ✅ $text" -ForegroundColor Green }
function Write-Warn { param($text)      Write-Host "  ⚠️  $text" -ForegroundColor Yellow }
function Write-Err  { param($text)      Write-Host "  ❌ $text" -ForegroundColor Red }
function Open-Url   { param($url)       Start-Process $url }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Per Aspera Extended Commands — Setup                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ─── Already configured? ─────────────────────────────────────────────────────
if (Test-Path $propsFile) {
    $existing = ([xml](Get-Content $propsFile)).Project.PropertyGroup.PerAsperaGamePath
    Write-Ok "gamelibs.props already configured (game: $existing)"
    Write-Host ""

    # Still run checks so contributor knows if something is missing
    $gamePath = $existing
}
else {
    # ─── STEP 1: Find the game ────────────────────────────────────────────────
    Write-Step "1/3" "Locating Per Aspera..."
    Write-Host ""

    $commonPaths = @(
        "C:\Program Files (x86)\Steam\steamapps\common\Per Aspera",
        "C:\Program Files\Steam\steamapps\common\Per Aspera",
        "D:\SteamLibrary\steamapps\common\Per Aspera",
        "E:\SteamLibrary\steamapps\common\Per Aspera",
        "F:\SteamLibrary\steamapps\common\Per Aspera"
    )
    $detected = $commonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($detected) {
        Write-Ok "Detected: $detected"
        $confirm = Read-Host "  Use this path? [Y/n]"
        if ($confirm -eq '' -or $confirm -match '^[Yy]') {
            $gamePath = $detected
        }
    }

    if (-not $gamePath) {
        Write-Host ""
        Write-Host "  Enter the full path to your Per Aspera installation folder:" -ForegroundColor White
        Write-Host "  (e.g. D:\SteamLibrary\steamapps\common\Per Aspera)" -ForegroundColor Gray
        $gamePath = Read-Host "  Path"
    }

    if (-not (Test-Path $gamePath)) {
        Write-Err "Path not found: $gamePath"
        Write-Host "  Please verify the game is installed and try again." -ForegroundColor Gray
        exit 1
    }

    Write-Ok "Game folder found."
    Write-Host ""
}

# ─── STEP 2: Check BepInEx ───────────────────────────────────────────────────
Write-Step "2/3" "Checking BepInEx installation..."
Write-Host ""

$bepinexCore    = Join-Path $gamePath "BepInEx\core\BepInEx.Core.dll"
$bepinexPatcher = Join-Path $gamePath "winhttp.dll"   # BepInEx doorstop patcher
$bepinexInterop = Join-Path $gamePath "BepInEx\interop"

$bepinexOk = (Test-Path $bepinexCore) -and (Test-Path $bepinexPatcher)

if ($bepinexOk) {
    $interopGenerated = (Test-Path $bepinexInterop) -and ((Get-ChildItem $bepinexInterop -Filter "*.dll" -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0)
    Write-Ok "BepInEx 6 is installed."

    if (-not $interopGenerated) {
        Write-Warn "Interop DLLs not generated yet."
        Write-Host "  → Launch Per Aspera once with BepInEx installed, then come back." -ForegroundColor Yellow
        Write-Host "    BepInEx generates the interop DLLs on first game launch." -ForegroundColor Gray
        Write-Host ""
        $continue = Read-Host "  Have you launched the game already? [y/N]"
        if ($continue -notmatch '^[Yy]') {
            Write-Host "  Setup paused. Re-open this workspace after launching the game." -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Ok "Interop DLLs found ($(((Get-ChildItem $bepinexInterop -Filter '*.dll').Count)) DLLs)."
    }
}
else {
    Write-Err "BepInEx 6 is NOT installed."
    Write-Host ""
    Write-Host "  BepInEx 6 (IL2CPP, win-x64) is required. To install:" -ForegroundColor White
    Write-Host ""
    Write-Host "    1. Go to the BepInEx 6 builds page (opening in browser...)" -ForegroundColor Gray
    Write-Host "       https://builds.bepinex.dev/projects/bepinex_be" -ForegroundColor DarkGray
    Write-Host "    2. Download: BepInEx_Unity.IL2CPP-win-x64-6.0.0-be.xxx.zip" -ForegroundColor Gray
    Write-Host "    3. Extract the ZIP into your game folder:" -ForegroundColor Gray
    Write-Host "       $gamePath" -ForegroundColor DarkGray
    Write-Host "    4. Launch Per Aspera once so BepInEx generates interop DLLs" -ForegroundColor Gray
    Write-Host "    5. Re-open this workspace" -ForegroundColor Gray
    Write-Host ""
    Open-Url "https://builds.bepinex.dev/projects/bepinex_be"
    Write-Host "  Setup cannot continue without BepInEx. Exiting." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ─── STEP 3: Check Per Aspera SDK ────────────────────────────────────────────
Write-Step "3/3" "Checking Per Aspera SDK..."
Write-Host ""

$sdkPaths = @(
    (Join-Path $gamePath "BepInEx\plugins\Common\PerAspera.Core.dll"),
    (Join-Path $gamePath "BepInEx\plugins\SDK\PerAspera.Core.dll")
)
$sdkFound = $sdkPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($sdkFound) {
    $sdkDir = Split-Path $sdkFound
    Write-Ok "SDK found at: $sdkDir"
}
else {
    Write-Err "Per Aspera SDK is NOT installed."
    Write-Host ""
    Write-Host "  The Per Aspera Mod SDK is required. To install:" -ForegroundColor White
    Write-Host ""
    Write-Host "    1. Go to the SDK releases page (opening in browser...)" -ForegroundColor Gray
    Write-Host "       https://github.com/PerAsperaMods/ModPeraspera/releases" -ForegroundColor DarkGray
    Write-Host "    2. Download the latest SDK release ZIP" -ForegroundColor Gray
    Write-Host "    3. Extract into your BepInEx plugins folder:" -ForegroundColor Gray
    Write-Host "       $(Join-Path $gamePath 'BepInEx\plugins\')" -ForegroundColor DarkGray
    Write-Host "    4. Re-open this workspace" -ForegroundColor Gray
    Write-Host ""
    Open-Url "https://github.com/PerAsperaMods/ModPeraspera/releases"
    Write-Host "  Setup cannot continue without the SDK. Exiting." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ─── Write gamelibs.props (if not already done) ──────────────────────────────
if (-not (Test-Path $propsFile)) {
    $content = @"
<Project>
  <PropertyGroup>
    <PerAsperaGamePath>$gamePath</PerAsperaGamePath>
  </PropertyGroup>
</Project>
"@
    Set-Content -Path $propsFile -Value $content -Encoding UTF8
    Write-Ok "gamelibs.props created!"
    Write-Host ""
}

# ─── All good ────────────────────────────────────────────────────────────────
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   All set! You can now build the project.                    ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Build:  dotnet build CommandActions.slnx -c Release" -ForegroundColor Cyan
Write-Host "          (or press Ctrl+Shift+B in VSCode)" -ForegroundColor Gray
Write-Host ""
