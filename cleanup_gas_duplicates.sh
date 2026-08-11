#!/bin/bash
set -e

GAS_REPOS=(
  "kazuto-AIcode/kazuto-gas-01"
  "ao-AIcode/ao-gas-01"
  "mio-AIcode/mio-001-gas"
)

# ルート直下から削除する、旧・重複ファイル名
OLD_FILES=(
  "通常運用ガイド_A4_GAS.pdf"
  "通常運用ガイド_生徒用_GAS.html"
  "通常運用ガイド_生徒用_GAS.md"
  "通常運用ガイド_生徒用_GAS_A4.pdf"
)

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

cleanup_repo () {
  local REPO=$1
  echo "=== $REPO ==="
  local DIR="$WORKDIR/$(echo $REPO | tr '/' '_')"
  git clone --depth 1 "https://x-access-token:${GH_TOKEN}@github.com/${REPO}.git" "$DIR" || { echo "  clone失敗: $REPO"; return; }
  cd "$DIR"
  git config user.email "programake2020@users.noreply.github.com"
  git config user.name "programake2020"

  local REMOVED=0
  for f in "${OLD_FILES[@]}"; do
    if [ -f "$f" ]; then
      git rm -q "$f"
      echo "  削除: $f"
      REMOVED=1
    fi
  done

  if [ "$REMOVED" = "1" ]; then
    git commit -m "docs: ルート直下の旧・重複した運用ガイドファイルを削除(docsフォルダに一本化)"
    git push
    echo "  更新完了"
  else
    echo "  削除対象なし"
  fi
  cd "$WORKDIR"
}

for repo in "${GAS_REPOS[@]}"; do
  cleanup_repo "$repo"
done

echo "重複ファイルの削除が完了しました。"
