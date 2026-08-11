#!/bin/bash
set -e

FLUTTER_REPOS=(
  "junya2067/junya-flutter-01"
  "ao-AIcode/ao-flutter-01"
  "kazuto-AIcode/kazuto-001-app"
  "ryuto-AIcode/ryuto-001-app"
  "toki-AIcode/toki-001-app"
  "hikaru-AIcode/hikaru-001-app"
  "yo-AIcode/yo-001-app"
  "ousei-AIcode/ousei-001-app"
  "mio-AIcode/mio-001-app"
  "yoshitake108/miyu-01"
)

# ルート直下にあれば削除する、旧・重複ファイル名の候補
OLD_ROOT_FILES=(
  "通常運用ガイド_A4.pdf"
  "通常運用ガイド.html"
  "通常運用ガイド_生徒用.html"
  "通常運用ガイド_生徒用.md"
  "通常運用ガイド_生徒用_A4.pdf"
)

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

git clone --depth 1 https://x-access-token:${GH_TOKEN}@github.com/programake2020/flutter-firebase-opencode-groq-template.git flutter-template
FLUTTER_MD="$WORKDIR/flutter-template/docs/02-daily-use.md"
FLUTTER_PDF="$WORKDIR/flutter-template/docs/通常運用ガイド_A4.pdf"
FLUTTER_HTML="$WORKDIR/flutter-template/docs/通常運用ガイド.html"

update_repo () {
  local REPO=$1
  local PDF_NAME=$(basename "$FLUTTER_PDF")
  local HTML_NAME=$(basename "$FLUTTER_HTML")

  echo "=== $REPO ==="
  local DIR="$WORKDIR/$(echo $REPO | tr '/' '_')"
  git clone --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git" "$DIR" || { echo "  clone失敗: $REPO"; return; }
  cd "$DIR"
  git config user.email "programake2020@users.noreply.github.com"
  git config user.name "programake2020"

  mkdir -p docs
  cp "$FLUTTER_MD" "docs/02-daily-use.md"
  cp "$FLUTTER_PDF" "docs/$PDF_NAME"
  cp "$FLUTTER_HTML" "docs/$HTML_NAME"
  git add docs/02-daily-use.md "docs/$PDF_NAME" "docs/$HTML_NAME"

  # ルート直下の旧・重複ファイルを削除
  for f in "${OLD_ROOT_FILES[@]}"; do
    if [ -f "$f" ]; then
      git rm -q "$f"
      echo "  ルートの重複を削除: $f"
    fi
  done

  if git diff --cached --quiet; then
    echo "  変更なし"
  else
    git commit -m "docs: 通常運用ガイドをLibreChat/Claude Code CLI版に更新(重複整理含む)"
    git push
    echo "  更新完了"
  fi
  cd "$WORKDIR"
}

echo "### Flutter版 ###"
for repo in "${FLUTTER_REPOS[@]}"; do
  update_repo "$repo"
done

echo "Flutter版10件の処理が完了しました。"
