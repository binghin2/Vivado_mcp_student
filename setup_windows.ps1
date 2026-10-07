# Vivado MCP 설치 스크립트 (Windows)
# setup.bat 을 더블클릭하면 이 스크립트가 실행됩니다.
# 직접 실행: powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1 [-VivadoBin "<bin 폴더>"] [-SkipVivadoTest]

param(
    [string]$VivadoBin = "",
    [switch]$SkipVivadoTest
)

$repo = $PSScriptRoot
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Step($n, $msg) { Write-Host ""; Write-Host "[$n/6] $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Skip($msg) { Write-Host "  [건너뜀] $msg" -ForegroundColor Yellow }
function Fail($msg) {
    Write-Host "  [실패] $msg" -ForegroundColor Red
    Write-Host ""
    Write-Host "  README.md 의 '문제가 생겼을 때' 항목을 확인하세요." -ForegroundColor Yellow
    exit 1
}
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}

Refresh-Path

# ---------------------------------------------------------------------------
Step 1 "Python 확인"
$pyVer = $null
try { $pyVer = & python -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null } catch {}
if ($LASTEXITCODE -ne 0 -or -not $pyVer) {
    Fail "Python 이 설치되어 있지 않습니다. README 의 STEP 1 을 따라 Python 을 설치한 뒤, 창을 모두 닫고 다시 실행하세요."
}
if ([version]$pyVer -lt [version]"3.10") {
    Fail "Python $pyVer 은(는) 너무 오래된 버전입니다. 3.10 이상을 설치하세요."
}
Ok "Python $pyVer"

# ---------------------------------------------------------------------------
Step 2 "Vivado 찾기"
if (-not $VivadoBin) {
    $patterns = @(
        "C:\AMDDesignTools\*\Vivado\bin", "D:\AMDDesignTools\*\Vivado\bin",
        "C:\Xilinx\Vivado\*\bin",         "D:\Xilinx\Vivado\*\bin",
        "C:\Xilinx\*\Vivado\bin",         "D:\Xilinx\*\Vivado\bin"
    )
    $found = foreach ($p in $patterns) {
        Resolve-Path $p -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path $_.Path "vivado.bat") } |
            ForEach-Object { $_.Path }
    }
    $VivadoBin = $found | Sort-Object -Descending | Select-Object -First 1
}
if (-not $VivadoBin) {
    Write-Host "  Vivado 를 자동으로 찾지 못했습니다."
    Write-Host "  vivado.bat 파일이 들어 있는 bin 폴더 경로를 입력하세요."
    Write-Host "  (예: C:\Xilinx\Vivado\2023.2\bin)"
    $VivadoBin = (Read-Host "  경로").Trim().Trim('"')
}
if (-not (Test-Path (Join-Path $VivadoBin "vivado.bat"))) {
    Fail "이 폴더에 vivado.bat 이 없습니다: $VivadoBin"
}
Ok $VivadoBin

# ---------------------------------------------------------------------------
Step 3 "Vivado 를 PATH 에 등록"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$VivadoBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$VivadoBin", "User")
    Ok "등록 완료"
} else {
    Ok "이미 등록되어 있음"
}
Refresh-Path

# ---------------------------------------------------------------------------
Step 4 "vivado_mcp 설치 (1~2분 걸릴 수 있습니다)"
& python -m pip install --disable-pip-version-check --no-warn-script-location -q -e "$repo"
if ($LASTEXITCODE -ne 0) { Fail "pip 설치 중 오류가 났습니다. 인터넷 연결을 확인하세요." }
Push-Location $HOME
& python -c "import vivado_mcp, winpty, mcp" 2>$null
$importOk = ($LASTEXITCODE -eq 0)
Pop-Location
if (-not $importOk) { Fail "설치는 끝났지만 불러오기에 실패했습니다." }
Ok "설치 완료"

# ---------------------------------------------------------------------------
Step 5 "Vivado 실행 테스트 (30초~1분 걸릴 수 있습니다)"
if ($SkipVivadoTest) {
    Skip "-SkipVivadoTest 옵션"
} else {
    Push-Location $HOME
    $out = & python -c "from vivado_mcp.vivado_session import VivadoSession; s=VivadoSession(); r=s.start(); print('VIVADO_OK' if r.success else 'VIVADO_FAIL'); print(s.run_tcl('version').output if r.success else r.output); s.stop()" 2>&1
    Pop-Location
    if (($out | Out-String) -match "VIVADO_OK") {
        Ok "Vivado 가 정상적으로 실행됩니다."
    } else {
        Write-Host ($out | Out-String)
        Fail "Vivado 실행에 실패했습니다. Vivado 가 정상 설치되었는지 확인하세요."
    }
}

# ---------------------------------------------------------------------------
Step 6 "AI 도구에 등록 (Claude Code / Codex / Gemini)"

# Claude Code
if (Get-Command claude -ErrorAction SilentlyContinue) {
    & claude mcp remove --scope user vivado *> $null
    & claude mcp add --scope user vivado -- python -m vivado_mcp *> $null
    if ($LASTEXITCODE -eq 0) { Ok "Claude Code" } else { Write-Host "  [실패] Claude Code 등록 실패" -ForegroundColor Red }
} else {
    Skip "Claude Code (설치되어 있지 않음. 나중에 설치하면 setup.bat 을 다시 실행하세요)"
}

# Codex (CLI, 앱 공통: ~/.codex/config.toml)
$codexDir = Join-Path $HOME ".codex"
$codexCfg = Join-Path $codexDir "config.toml"
New-Item -ItemType Directory -Force $codexDir | Out-Null
$codexText = ""
if (Test-Path $codexCfg) { $codexText = [IO.File]::ReadAllText($codexCfg) }
if ($codexText -match '(?m)^\s*\[mcp_servers\.vivado\]') {
    Ok "Codex (이미 등록되어 있음)"
} else {
    if (Test-Path $codexCfg) { Copy-Item $codexCfg "$codexCfg.bak" -Force }
    $block = "`n[mcp_servers.vivado]`ncommand = `"python`"`nargs = [`"-m`", `"vivado_mcp`"]`nstartup_timeout_sec = 60`ntool_timeout_sec = 600`n"
    [IO.File]::AppendAllText($codexCfg, $block, $utf8NoBom)
    Ok "Codex"
}

# Gemini CLI (~/.gemini/settings.json)
$geminiDir = Join-Path $HOME ".gemini"
$geminiCfg = Join-Path $geminiDir "settings.json"
New-Item -ItemType Directory -Force $geminiDir | Out-Null
$geminiObj = $null
$geminiOk = $true
if (Test-Path $geminiCfg) {
    $raw = [IO.File]::ReadAllText($geminiCfg)
    if ($raw.Trim()) {
        try { $geminiObj = $raw | ConvertFrom-Json } catch { $geminiOk = $false }
    }
    if ($geminiOk) { Copy-Item $geminiCfg "$geminiCfg.bak" -Force }
}
if (-not $geminiOk) {
    Write-Host "  [실패] Gemini 설정 파일을 읽지 못했습니다: $geminiCfg" -ForegroundColor Red
    Write-Host "         README 의 'Gemini 수동 등록' 을 참고하세요."
} else {
    if (-not $geminiObj) { $geminiObj = New-Object PSObject }
    if (-not $geminiObj.PSObject.Properties["mcpServers"]) {
        $geminiObj | Add-Member -NotePropertyName mcpServers -NotePropertyValue (New-Object PSObject)
    }
    $server = [pscustomobject]@{ command = "python"; args = @("-m", "vivado_mcp"); timeout = 600000 }
    $geminiObj.mcpServers | Add-Member -NotePropertyName vivado -NotePropertyValue $server -Force
    [IO.File]::WriteAllText($geminiCfg, ($geminiObj | ConvertTo-Json -Depth 32), $utf8NoBom)
    Ok "Gemini"
}

# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " 설치 완료!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host " 1. 지금 열려 있는 PowerShell / 터미널 창을 전부 닫으세요."
Write-Host " 2. 새 PowerShell 을 열고 claude, codex, gemini 중 하나를 실행하세요."
Write-Host " 3. /mcp 를 입력해서 vivado 가 보이면 성공입니다."
Write-Host ""
