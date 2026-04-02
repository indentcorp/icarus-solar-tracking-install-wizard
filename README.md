# Spray Connect Tools — 설치

## 사전 준비

설치 전 아래 항목을 확인하세요:

- **GitHub 계정**: 관리자에게 저장소 접근 권한 요청 필요
- **Google 계정**: Google Sheets 접근용 (관리자에게 확인)
- **소요 시간**: 약 15-20분 (약 400MB+ 다운로드)

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
1. 개발 도구 설치 (Git, Node.js, bun, GitHub CLI)
2. GitHub 로그인 (브라우저 팝업)
3. 프로젝트 다운로드
4. 의존성 설치 (ship-tracker: npm, addr-check/addr-reply: bun)
5. 환경 설치 및 프로필 설정
