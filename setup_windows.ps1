# Vivado MCP setup script for Windows
# Usage (PowerShell, inside the repo folder):
#   powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
#   powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1 -VivadoBin "D:\Xilinx\2025.2\Vivado\bin"

param(
    [string]$VivadoBin = "C:\AMDDesignTools\2026.1\Vivado\bin"
)

$repo = $PSScriptRoot

# 1. Vivado PATH
Write-Host "[1/4] Registering Vivado in user PATH..." -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $VivadoBin "vivado.bat"))) {
    Write-Host "  vivado.bat not found in: $VivadoBin" -ForegroundColor Red
    Write-Host "  Re-run with -VivadoBin <your Vivado bin folder>" -ForegroundColor Red
    exit 1
}
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$VivadoBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$VivadoBin", "User")
    Write-Host "  Added: $VivadoBin"
} else {
    Write-Host "  Already registered"
}
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

# 2. Python package (mcp, pywinpty are installed as dependencies)
Write-Host "[2/4] Installing vivado_mcp Python package..." -ForegroundColor Cyan
python -m pip install -e "$repo"
if ($LASTEXITCODE -ne 0) {
    Write-Host "  pip install failed. Check that Python 3.10+ is installed." -ForegroundColor Red
    exit 1
}

# 3. Import check (run outside the repo folder)
Write-Host "[3/4] Checking installation..." -ForegroundColor Cyan
Push-Location $HOME
python -c "import vivado_mcp, winpty, mcp; print('  OK')"
$importOk = ($LASTEXITCODE -eq 0)
Pop-Location
if (-not $importOk) {
    Write-Host "  Import check failed." -ForegroundColor Red
    exit 1
}

# 4. Register MCP server in Claude Code
Write-Host "[4/4] Registering MCP server in Claude Code..." -ForegroundColor Cyan
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  'claude' command not found. Install Claude Code, then run:" -ForegroundColor Yellow
    Write-Host "  claude mcp add --scope user vivado -- python -m vivado_mcp"
    exit 1
}
claude mcp remove --scope user vivado 2>$null | Out-Null
claude mcp add --scope user vivado -- python -m vivado_mcp

Write-Host ""
Write-Host "Done. Open a NEW terminal and run 'claude', then type /mcp to check 'vivado'." -ForegroundColor Green
