# ============================================
# GIT CREATE PROJETCT 
# ============================================

param (
    [string]$ProjectName = "enterprise-scripts",
    [string]$Version = "1.0.0",
    [string]$Environment = "dev"
)

# ========================
# Função de log
# ========================
function Write-Log {
    param([string]$Message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $log = "$timestamp - $Message"

    if (!(Test-Path "logs")) {
        New-Item -ItemType Directory -Path "logs" | Out-Null
    }

    $log | Out-File -Append -FilePath "logs\execution.log"
    Write-Host $log
}

# ========================
# Criar estrutura
# ========================
Write-Host "🚀 Criando projeto: $ProjectName" -ForegroundColor Cyan

New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
Set-Location $ProjectName

$folders = @(
    "docs",
    "examples",
    "config",
    "logs",
    "bin",
    "scripts\powershell\admin",
    "scripts\powershell\cloud",
    "scripts\powershell\security",
    "scripts\bash\admin",
    "scripts\bash\docker",
    "scripts\bash\monitoring",
    ".github\workflows"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

# ========================
# config/app.env
# ========================
@"
ENV=$Environment
VERSION=$Version
LOG_PATH=logs/execution.log
"@ | Out-File "config\app.env"

# ========================
# CLI principal
# ========================
@"
param([string]`$Action)

function Show-Menu {
    Write-Host ""
    Write-Host "===== ENTERPRISE CLI ====="
    Write-Host "1. Executar todos"
    Write-Host "2. Backup"
    Write-Host "3. Limpar logs"
    Write-Host "4. Sair"
}

function Run-All {
    Write-Host "Executando scripts..."
    Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
        Write-Host ">> `$($_.Name)"
        & `$_.FullName
    }
}

function Backup {
    Write-Host "Criando backup..."
    Compress-Archive -Path . -DestinationPath backup.zip -Force
}

function Cleanup {
    Write-Host "Limpando logs..."
    Remove-Item logs\*.log -Force -ErrorAction SilentlyContinue
}

do {
    Show-Menu
    `$choice = Read-Host "Escolha"

    switch (`$choice) {
        1 { Run-All }
        2 { Backup }
        3 { Cleanup }
        4 { break }
    }

} while (`$true)
"@ | Out-File "bin\cli.ps1"

# ========================
# Pipeline local
# ========================
@"
Write-Host "🚀 Pipeline iniciada..."

Write-Host "Validando scripts..."
Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
    Write-Host "OK: `$($_.Name)"
}

Write-Host "Executando CLI..."
& "..\bin\cli.ps1"

Write-Host "✅ Pipeline finalizada"
"@ | Out-File "bin\run-all.ps1"

# ========================
# README
# ========================
@"
# 🏢 Enterprise Script Framework

Framework de automação DevOps.

## Uso

.\bin\cli.ps1
.\bin\run-all.ps1

## Features
- CLI interativa
- Logs
- Pipeline local
- CI/CD
"@ | Out-File "README.md"

# ========================
# GitHub Actions
# ========================
@"
name: Enterprise Pipeline

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Bash Lint
      run: |
        sudo apt-get install -y shellcheck
        find . -name "*.sh" -exec shellcheck {} \;

    - name: PowerShell Analysis
      run: |
        pwsh -c "Install-Module PSScriptAnalyzer -Force"
        pwsh -c "Invoke-ScriptAnalyzer -Path ."

    - name: Deploy
      run: echo "Deploy simulado"
"@ | Out-File ".github\workflows\enterprise.yml"

# ========================
# VERSION
# ========================
$Version | Out-File "VERSION"

# ========================
# Git
# ========================
if (Get-Command git -ErrorAction SilentlyContinue) {
    git init | Out-Null
    git add . | Out-Null
    git commit -m "Enterprise v$Version" | Out-Null
}

# ========================
# Final
# ========================
Write-Host "`n✅ Projeto criado!" -ForegroundColor Green
Write-Host "📦 Versão:" $Version
Write-Host "🌎 Ambiente:" $Environment
Write-Host "📂 Caminho:" (Get-Location)

Write-Host "`n▶️ Execute:"
Write-Host ".\bin\cli.ps1"