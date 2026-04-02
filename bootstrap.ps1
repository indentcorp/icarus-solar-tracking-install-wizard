& {
  $ErrorActionPreference = "Stop"

  $REPO_ORG = "indentcorp"
  $REPO_NAME = "spray-connect-tools"
  $REPO_DIR = Join-Path $HOME $REPO_NAME

  function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $registered = "$machine;$user".Split(";", [StringSplitOptions]::RemoveEmptyEntries)
    $current = $env:Path.Split(";", [StringSplitOptions]::RemoveEmptyEntries)
    $sessionOnly = $current | Where-Object { $registered -notcontains $_ }
    $env:Path = ($registered + $sessionOnly) -join ";"
  }

  try {
    Write-Host "🚀 Spray Connect Tools 설치를 시작합니다..." -ForegroundColor Cyan

    # 0. ExecutionPolicy — 자동 설정 시도
    $policy = Get-ExecutionPolicy -Scope CurrentUser
    if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
      try {
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
        Write-Host "✓ ExecutionPolicy 설정 완료" -ForegroundColor Green
      } catch {
        throw "ExecutionPolicy 설정에 실패했습니다. (Group Policy 제한) 관리자에게 문의하세요."
      }
    }

    # Windows 버전 체크 (winget requires 21H2+)
    $build = [System.Environment]::OSVersion.Version.Build
    if ($build -lt 19044) {
      throw "Windows 10 21H2 이상이 필요합니다. (현재 Build: $build)"
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
      throw "winget이 설치되어 있지 않습니다. Microsoft Store의 앱 설치 관리자 또는 https://aka.ms/getwinget 에서 먼저 설치하세요."
    }

    # 1. Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
      Write-Host "📦 Git 설치 중..."
      winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
      if ($LASTEXITCODE -ne 0) {
        throw "Git 설치에 실패했습니다. 관리자 권한 및 네트워크 상태를 확인하세요. (exit code: $LASTEXITCODE)"
      }
      Refresh-Path
    }

    # 2. Node.js (npm/npx 포함)
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
      Write-Host "📦 Node.js 설치 중..."
      winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
      if ($LASTEXITCODE -ne 0) {
        throw "Node.js 설치에 실패했습니다. 관리자 권한 및 네트워크 상태를 확인하세요. (exit code: $LASTEXITCODE)"
      }
      Refresh-Path
    }

    # 3. gh
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
      Write-Host "📦 GitHub CLI 설치 중..."
      winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
      if ($LASTEXITCODE -ne 0) {
        throw "GitHub CLI 설치에 실패했습니다. 관리자 권한 및 네트워크 상태를 확인하세요. (exit code: $LASTEXITCODE)"
      }
      Refresh-Path
    }

    # 4. GitHub 인증
    gh auth status 2>$null
    $authOk = ($LASTEXITCODE -eq 0)
    if (-not $authOk) {
      Write-Host "🔑 GitHub 인증이 필요합니다. 브라우저가 열립니다..."
      gh auth login --web -p https -h github.com
      if ($LASTEXITCODE -ne 0) {
        throw "GitHub 인증에 실패했습니다. 브라우저 인증을 완료한 뒤 다시 시도하세요."
      }
    }
    gh auth setup-git
    if ($LASTEXITCODE -ne 0) {
      throw "git 인증 설정에 실패했습니다. gh auth setup-git 실행 권한을 확인하세요."
    }

    # 5. Clone (idempotent)
    $gitDir = Join-Path $REPO_DIR ".git"
    if (Test-Path $gitDir) {
      Write-Host "📁 이미 다운로드됨, 업데이트 중..."
      git -C $REPO_DIR pull --ff-only
      if ($LASTEXITCODE -ne 0) {
        throw "업데이트에 실패했습니다. 로컬 변경사항이 있는지 확인하세요."
      }
    } else {
      Write-Host "📥 프로젝트 다운로드 중..."
      gh repo clone "${REPO_ORG}/${REPO_NAME}" $REPO_DIR
      if ($LASTEXITCODE -ne 0 -or -not (Test-Path $REPO_DIR)) {
        throw "레포지토리 클론에 실패했습니다. GitHub 접근 권한을 확인하고 다시 시도하세요."
      }
    }

    # 6. Install dependencies
    Set-Location (Join-Path $REPO_DIR "ship-tracker")
    npm install
    if ($LASTEXITCODE -ne 0) {
      throw "ship-tracker 의존성 설치에 실패했습니다. (exit code: $LASTEXITCODE)"
    }

    Set-Location (Join-Path $REPO_DIR "addr-check")
    npm install
    if ($LASTEXITCODE -ne 0) {
      throw "addr-check 의존성 설치에 실패했습니다. (exit code: $LASTEXITCODE)"
    }

    Set-Location (Join-Path $REPO_DIR "addr-reply")
    npm install
    if ($LASTEXITCODE -ne 0) {
      throw "addr-reply 의존성 설치에 실패했습니다. (exit code: $LASTEXITCODE)"
    }

    # 7. Setup
    Set-Location (Join-Path $REPO_DIR "ship-tracker")
    Write-Host ""
    npx tsx src/cli.ts install
    if ($LASTEXITCODE -ne 0) {
      throw "설치 명령 실행에 실패했습니다. (exit code: $LASTEXITCODE)"
    }

    npx tsx src/cli.ts init
    if ($LASTEXITCODE -ne 0) {
      throw "초기화 명령 실행에 실패했습니다. (exit code: $LASTEXITCODE)"
    }

    Write-Host ""
    Write-Host "✅ 설치가 완료되었습니다!" -ForegroundColor Green
    Write-Host "   터미널을 재시작한 후 다음 명령어로 확인하세요:" -ForegroundColor Cyan
    Write-Host "   cd '$REPO_DIR\ship-tracker' && npx tsx src/cli.ts run --help" -ForegroundColor White
    Write-Host "   📁 프로젝트 위치: $REPO_DIR" -ForegroundColor White
    Write-Host "   새 터미널을 열고: cd '$REPO_DIR'" -ForegroundColor White
  } catch {
    Write-Host ""
    Write-Host "❌ 오류가 발생했습니다: $_" -ForegroundColor Red
    Write-Host "   위의 오류 메시지를 확인하고, 관리자에게 문의하세요." -ForegroundColor Yellow
  } finally {
    Write-Host ""
    Read-Host "Enter 키를 눌러 창을 닫으세요"
  }
}
