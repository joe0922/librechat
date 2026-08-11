#!/bin/bash
set -e

GAS_REPOS=(
  "kazuto-AIcode/kazuto-gas-01"
  "ao-AIcode/ao-gas-01"
  "mio-AIcode/mio-001-gas"
)

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

git clone --depth 1 https://x-access-token:${GH_TOKEN}@github.com/programake2020/gas-opencode-groq-template.git gas-template
GAS_MD="$WORKDIR/gas-template/docs/02-daily-use.md"
GAS_PDF="$WORKDIR/gas-template/docs/通常運用ガイド_A4_GAS.pdf"
GAS_HTML="$WORKDIR/gas-template/docs/通常運用ガイド_生徒用_GAS.html"

update_repo () {
  local REPO=$1
  local PDF_NAME=$(basename "$GAS_PDF")
  local HTML_NAME=$(basename "$GAS_HTML")

  echo "=== $REPO ==="
  local DIR="$WORKDIR/$(echo $REPO | tr '/' '_')"
  git clone --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git" "$DIR" || { echo "  clone失敗: $REPO"; return; }
  mkdir -p "$DIR/docs"
  cp "$GAS_MD" "$DIR/docs/02-daily-use.md"
  cp "$GAS_PDF" "$DIR/docs/$PDF_NAME"
  cp "$GAS_HTML" "$DIR/docs/$HTML_NAME"

  cd "$DIR"
  git config user.email "programake2020@users.noreply.github.com"
  git config user.name "programake2020"
  git add docs/02-daily-use.md "docs/$PDF_NAME" "docs/$HTML_NAME"
  if git diff --cached --quiet; then
    echo "  変更なし"
  else
    git commit -m "docs: 通常運用ガイドをLibreChat/Claude Code CLI版に更新"
    git push
    echo "  更新完了"
  fi
  cd "$WORKDIR"
}

echo "### GAS版 ###"
for repo in "${GAS_REPOS[@]}"; do
  update_repo "$repo"
done

echo "GAS版3件の処理が完了しました。"
