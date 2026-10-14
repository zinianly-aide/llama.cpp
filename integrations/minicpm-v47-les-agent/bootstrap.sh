#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM="${LES_OMNI_UPSTREAM_URL:-https://github.com/tc-mb/llama.cpp-omni.git}"
PIN="96bbf61710d44421ea54e63f5194f9b17c20d877"
EXPECTED_TREE="cfeba69a1d1ed55aa1e1988235bf3315bffabf33"
OUT="${1:-$PWD/llama.cpp-omni-les}"
if [[ -e "$OUT" ]]; then
  echo "Refusing to overwrite existing directory: $OUT" >&2
  exit 2
fi
command -v git >/dev/null || { echo "Git is required" >&2; exit 3; }
mkdir -p "$(dirname "$OUT")"
mkdir "$OUT"
git -C "$OUT" init --quiet
git -C "$OUT" remote add origin "$UPSTREAM"
# Fetch only the pinned commit, not thousands of unrelated default-branch commits.
git -C "$OUT" -c protocol.version=2 fetch --quiet --depth 1 --filter=blob:none origin "$PIN"
git -C "$OUT" checkout --quiet -b feat/minicpm-v47-les-agent "$PIN"
git -C "$OUT" -c user.name='LES Patch Import' -c user.email='les-patch-import@users.noreply.github.com' am "$SCRIPT_DIR"/patches/*.patch
TREE="$(git -C "$OUT" rev-parse 'HEAD^{tree}')"
if [[ "$TREE" != "$EXPECTED_TREE" ]]; then
  echo "Rebuilt tree differs: expected $EXPECTED_TREE, got $TREE" >&2
  exit 4
fi
echo "PASS: recreated pinned LES agent source at $OUT"
echo "Tree: $TREE"
