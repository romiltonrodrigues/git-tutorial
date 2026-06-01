#	✅ 🔽 SCRIPT 2 — Baixar ou Atualizar Projeto  ->  GitHub → LOCAL (CLONE / PULL)
#	SCRIPT : git_pull.ps1

param (
    [string]$RepoUrl = "https://github.com/romiltonrodrigues/git-tutorial.git",
    [string]$Branch = "main"
)

function Write-Log {
    param([string]$msg)
    Write-Host "[PULL] $msg" -ForegroundColor Cyan
}

# Verifica Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git não instalado!" -ForegroundColor Red
    exit
}

# Se não existe repo → CLONE
if (-not (Test-Path ".git")) {
    Write-Log "Clonando repositório..."
    git clone $RepoUrl
    Write-Log "✅ Clone concluído!"
}
else {
    # Se já existe → PULL
    Write-Log "Atualizando repositório..."
    git pull origin $Branch
    Write-Log "✅ Pull concluído!"
}