$ErrorActionPreference = "Stop"

$REPO_ORG = "indentcorp"
$REPO_NAME = "icarus-solar-tracking"
$REPO_DIR = Join-Path $HOME $REPO_NAME

Write-Host "🚀 Icarus Solar Tracking 설치를 시작합니다..." -ForegroundColor Cyan

# 0. ExecutionPolicy — 자동 설정 시도
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
  try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "✓ ExecutionPolicy 설정 완료" -ForegroundColor Green
  } catch {
    Write-Host "ExecutionPolicy 설정 실패 (Group Policy에 의해 차단됨):" -ForegroundColor Red
    Write-Host "  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" -ForegroundColor Yellow
    exit 1
  }
}

# Windows 버전 체크 (winget requires 21H2+)
$build = [System.Environment]::OSVersion.Version.Build
if ($build -lt 19044) {
  Write-Host "Windows 10 21H2 이상이 필요합니다 (현재: Build $build)" -ForegroundColor Red
  exit 1
}

function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path","User") + ";" + [Environment]::GetEnvironmentVariable("Path","Machine")
}

# 1. Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Git 설치 중..."
  winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
  Refresh-Path
}

# 2. Node.js (npm/npx 포함)
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Node.js 설치 중..."
  winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
  Refresh-Path
}

# 3. gh
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Host "📦 GitHub CLI 설치 중..."
  winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
  Refresh-Path
}

# 4. GitHub 인증
$authOk = (gh auth status 2>&1) -match "Logged in"
if (-not $authOk) {
  Write-Host "🔑 GitHub 인증이 필요합니다. 브라우저가 열립니다..."
  gh auth login --web -p https -h github.com
}
gh auth setup-git

# 5. Bun
if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
  Write-Host "📦 Bun 설치 중..."
  irm bun.sh/install.ps1 | iex
  Refresh-Path
  $bunBin = Join-Path $env:USERPROFILE ".bun\bin"
  if ($env:PATH -notlike "*$bunBin*") {
    $env:PATH = "$bunBin;$env:PATH"
  }
}

# 6. Clone (idempotent)
$gitDir = Join-Path $REPO_DIR ".git"
if (Test-Path $gitDir) {
  Write-Host "📁 이미 다운로드됨, 업데이트 중..."
  git -C $REPO_DIR pull --ff-only
} else {
  Write-Host "📥 프로젝트 다운로드 중..."
  gh repo clone "${REPO_ORG}/${REPO_NAME}" $REPO_DIR
}

# 7. Install + Init
Set-Location $REPO_DIR
bun install
Write-Host ""
bun run src/cli.ts install
bun run src/cli.ts init
