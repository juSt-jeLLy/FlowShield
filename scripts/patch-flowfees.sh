#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

patch_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if ! rg -q "getTransactionIndex" "$file"; then
    return 0
  fi

  python - <<'PY' "$file"
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = "let txIndex = getTransactionIndex()"
new = "let txIndex: UInt32 = UInt32(getCurrentBlock().height)"
if old in text:
    path.write_text(text.replace(old, new))
PY

  echo "patched: ${file}"
}

# Patch any FlowFees.cdc files under both onchain imports trees.
while IFS= read -r file; do
  patch_file "$file"
done < <(rg -l "getTransactionIndex" "$ROOT/onchain/imports" "$ROOT/onchain-scheduled/imports" || true)

