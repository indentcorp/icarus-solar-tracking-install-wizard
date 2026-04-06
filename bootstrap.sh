#!/bin/bash
# spray-connect-tools bootstrap installer
set -euo pipefail

REPO_ORG="indentcorp"
REPO_NAME="spray-connect-tools"
REPO_DIR="$HOME/${REPO_NAME}"

echo "🚀 Spray Connect Tools 설치를 시작합니다..."

# 1. Xcode CLT (git 포함) — poll until done
if ! xcode-select -p &>/dev/null; then
  echo "⏳ Xcode Command Line Tools 설치 중... (팝업에서 '설치' 클릭)"
  xcode-select --install &>/dev/null || true
  until xcode-select -p &>/dev/null; do sleep 5; done
  echo "✅ Xcode CLT 설치 완료"
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "📦 Homebrew 설치 중..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. Node.js
if ! command -v node &>/dev/null; then
  echo "📦 Node.js 설치 중..."
  brew install node
fi
node --version

# 4. gh (GitHub CLI)
if ! command -v gh &>/dev/null; then
  echo "📦 GitHub CLI 설치 중..."
  brew install gh
fi

# 5. GitHub 인증
if ! gh auth status &>/dev/null; then
  echo "🔑 GitHub 인증이 필요합니다. 브라우저가 열립니다..."
  gh auth login --web -p https -h github.com
fi
gh auth setup-git

# 6. Clone (idempotent)
if [ -d "$REPO_DIR/.git" ]; then
  echo "📁 이미 다운로드됨, 업데이트 중..."
  git -C "$REPO_DIR" pull --ff-only
else
  echo "📥 프로젝트 다운로드 중..."
  gh repo clone "${REPO_ORG}/${REPO_NAME}" "$REPO_DIR"
fi

# 7. Install dependencies
cd "$REPO_DIR"
npm install

cd "$REPO_DIR/ship-tracker"
npm install

cd "$REPO_DIR/addr-check" && npm install
cd "$REPO_DIR/addr-reply" && npm install

# 8. Setup
cd "$REPO_DIR"
echo ""
npx tsx sct/src/cli.ts install
echo ""
echo "✅ 설치가 완료되었습니다!"
echo "📁 프로젝트 위치: $REPO_DIR"
echo "다음 단계: 에이전트에게 '브랜드 프로필 만들어줘'를 요청해 sct-init 스킬로 브랜드 프로필 생성을 진행하세요."
