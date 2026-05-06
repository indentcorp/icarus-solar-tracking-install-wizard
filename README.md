# Moon — 설치

## 사전 준비

설치 전 아래 항목을 확인하세요:

- **GitHub 계정**: 관리자에게 `indentcorp/moon` 저장소 접근 권한 요청 필요
- **네트워크 환경**: 설치 중 패키지/브라우저 다운로드가 있으므로 사내망/백신이 npm, GitHub을 막지 않아야 함
- **소요 시간**: 약 15-20분 (약 400MB+ 다운로드)

### 무엇이 자동이고, 무엇이 사전 준비인지

- **자동 처리**: Git / Node.js / GitHub CLI 설치, 프로젝트 다운로드, npm install, `gws` 설치, `tsx` 설치, Playwright 설치, `moon install`
- **사용자가 직접 해야 하는 것**: GitHub 브라우저 로그인
- **관리자가 미리 준비해야 하는 것**: GitHub 저장소 접근 권한, 운영 시트 접근 권한

## macOS

```bash
curl -fsSL https://raw.githubusercontent.com/indentcorp/spray-connect-tools-install-wizard/main/bootstrap.sh -o /tmp/moon-bootstrap.sh && bash /tmp/moon-bootstrap.sh
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
4. 저장소 루트 및 내부 패키지 의존성 설치
5. 저장소 루트 기준 `moon install` 실행

### 설치 중 멈춘 것처럼 보일 수 있는 단계

- **GitHub 로그인**: 브라우저 인증 완료 전까지 대기
- **Playwright 설치**: 다운로드 용량이 커서 수 분 걸릴 수 있음

위 단계는 오류가 아니라 **사용자 입력 또는 다운로드 대기 상태**일 수 있습니다.
