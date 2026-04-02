# Spray Connect Tools — 설치

## 사전 준비

설치 전 아래 항목을 확인하세요:

- **GitHub 계정**: 관리자에게 `indentcorp/spray-connect-tools` 저장소 접근 권한 요청 필요
- **Google 계정**: 운영 시트에 접근 가능한 계정 필요
- **Google 로그인 정책**: 회사 Google Workspace 정책상 외부 앱 로그인/동의가 막혀 있지 않아야 함
- **운영 시트 권한**: 설치 중 로그인할 Google 계정이 실제 운영 시트에 열람 권한 이상을 가지고 있어야 함
- **네트워크 환경**: 설치 중 패키지/브라우저 다운로드가 있으므로 사내망/백신이 npm, GitHub, Google 로그인을 막지 않아야 함
- **소요 시간**: 약 15-20분 (약 400MB+ 다운로드)

### 무엇이 자동이고, 무엇이 사전 준비인지

- **자동 처리**: Git / Node.js / GitHub CLI 설치, 프로젝트 다운로드, npm install, `gws` 설치, `tsx` 설치, Playwright 설치, `sct-ship install`, `sct-ship init`
- **사용자가 직접 해야 하는 것**: GitHub 브라우저 로그인, Google 브라우저 로그인
- **관리자가 미리 준비해야 하는 것**: GitHub 저장소 접근 권한, 운영 시트 접근 권한, Google Workspace 로그인/동의 정책 허용 여부

> `gws` 설치 자체는 스크립트가 자동으로 수행합니다.
> 다만 `sct-ship init` 단계에서 Google 로그인 창이 뜰 때, **로그인만 하면 끝나는지**는 해당 계정의 시트 권한과 회사 Google 정책에 따라 달라집니다.
> 즉, 기술적으로는 자동이지만 권한/정책은 사전 준비가 필요합니다.

## macOS

```bash
curl -fsSL https://raw.githubusercontent.com/indentcorp/spray-connect-tools-install-wizard/main/bootstrap.sh -o /tmp/sct-bootstrap.sh && bash /tmp/sct-bootstrap.sh
```

## Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/indentcorp/spray-connect-tools-install-wizard/main/bootstrap.ps1 | iex
```

## 진행 순서

스크립트가 자동으로 처리합니다:
1. 개발 도구 설치 (Git, Node.js, GitHub CLI)
2. GitHub 로그인 (브라우저 팝업)
3. 프로젝트 다운로드
4. 의존성 설치 (ship-tracker, addr-check, addr-reply: npm)
5. 환경 설치 (`gws`, `tsx`, Playwright, opencode)
6. Google 로그인 및 프로필 설정

### 설치 중 멈춘 것처럼 보일 수 있는 단계

- **GitHub 로그인**: 브라우저 인증 완료 전까지 대기
- **Google 로그인**: 브라우저 인증/동의 완료 전까지 대기
- **Playwright 설치**: 다운로드 용량이 커서 수 분 걸릴 수 있음

위 단계는 오류가 아니라 **사용자 입력 또는 다운로드 대기 상태**일 수 있습니다.
