# Icarus Solar Tracking — 설치

## macOS

```bash
curl -fsSL https://raw.githubusercontent.com/indentcorp/icarus-solar-tracking-install-wizard/main/bootstrap.sh -o /tmp/ist-bootstrap.sh && bash /tmp/ist-bootstrap.sh
```

## Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/indentcorp/icarus-solar-tracking-install-wizard/main/bootstrap.ps1 | iex
```

## 진행 순서

스크립트가 자동으로 처리합니다:
1. 개발 도구 설치 (Git, GitHub CLI, Bun)
2. GitHub 로그인 (브라우저 팝업)
3. 프로젝트 다운로드
4. IST 환경 설치 (`ist install`)
5. 프로젝트 프로필 설정 (`ist init`)
