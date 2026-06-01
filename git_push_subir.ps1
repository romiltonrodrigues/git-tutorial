# 	✅ 🔼 SCRIPT 1 — Subir Projeto ->  LOCAL → GitHub (PUSH)
# 	Script: git_push.ps1

param (
    [string]$RepoUrl = "https://github.com/romiltonrodrigues/git-tutorial.git",
    [string]$Branch = "main"
)

function Write-Log {
    param([string]$msg)
    Write-Host "[PUSH] $msg" -ForegroundColor Green
}

# Verifica Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git não instalado!" -ForegroundColor Red
    exit
}

# Inicializa Git se necessário
if (-not (Test-Path ".git")) {
    Write-Log "Inicializando repositório..."
    git init
}

# Adiciona remote se não existir
if (-not (git remote | Select-String "origin")) {
    Write-Log "Adicionando remote origin..."
    git remote add origin $RepoUrl
}

# Push
Write-Log "Adicionando arquivos..."
git add .

Write-Log "Criando commit..."
git commit -m "Atualização $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 2>$null

Write-Log "Enviando para GitHub..."
git branch -M $Branch
git push -u origin $Branch

Write-Log "✅ Push concluído!"
