#!/bin/bash
set -euo pipefail

REPO_ORG="indentcorp"
REPO_NAME="icarus-solar-tracking"
REPO_DIR="$HOME/${REPO_NAME}"

echo "🚀 Icarus Solar Tracking 설치를 시작합니다..."

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

# 6. Bun
if ! command -v bun &>/dev/null; then
  echo "📦 Bun 설치 중..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# 7. Clone (idempotent)
if [ -d "$REPO_DIR/.git" ]; then
  echo "📁 이미 다운로드됨, 업데이트 중..."
  git -C "$REPO_DIR" pull --ff-only
else
  echo "📥 프로젝트 다운로드 중..."
  gh repo clone "${REPO_ORG}/${REPO_NAME}" "$REPO_DIR"
fi

# 8. Install + Init
cd "$REPO_DIR"
bun install
echo ""
bun run src/cli.ts install && bun run src/cli.ts init
