#!/usr/bin/env bash
# Regenerate docs/design-system.md from the Armscanner Figma library.
#
# The extract is committed so that agents and people can read the design
# system without a Figma token and without an API call. This script exists so
# the extract can be rebuilt when the library changes, rather than being
# hand-maintained and drifting.
#
#   ./tools/figma-extract.sh            # rewrite docs/design-system.md
#   ./tools/figma-extract.sh --check    # exit 1 if the library has moved on
#
# Token resolution and failure modes: see docs/figma-access.md.

set -uo pipefail

# Fail loudly on a missing dependency rather than part-way through with a
# generic shell error. Matches tools/figma-read.sh and the documented exit
# codes in docs/figma-access.md.
for dep in curl node; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 3; }
done

LIBRARY_KEY="nsgOZTtYiHjPOxrt1ImVHv"
DESIGNS_KEY="XMc8Glk3X9V3xh1uEiYoRe"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/docs/design-system.md"

resolve_token() {
  if [ -n "${FIGMA_TOKEN:-}" ]; then TOKEN="$FIGMA_TOKEN"; return 0; fi
  if TOKEN=$(security find-generic-password -s figma -w 2>/dev/null) && [ -n "$TOKEN" ]; then return 0; fi
  if [ -s "$HOME/.figma-token" ]; then TOKEN=$(tr -d '[:space:]' < "$HOME/.figma-token"); return 0; fi
  return 1
}

resolve_token || { echo "No Figma token. See docs/figma-access.md." >&2; exit 2; }

# -sS keeps curl quiet on success but still reports transport failures. Without
# -S a DNS or TLS problem yields an empty body, which then surfaces as a Node
# stack trace rather than a usable message.
api() {
  local out status
  out=$(curl -sS -H "X-Figma-Token: $TOKEN" "https://api.figma.com/v1/$1")
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "curl failed (exit $status) — network, DNS or TLS problem, not an API error" >&2
    return 1
  fi
  printf '%s' "$out"
}

# Figma rate-limits aggressively. Fetch each endpoint once, reuse from disk.
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

fetch() { # fetch <path> <outfile>
  api "$1" > "$2" || return 1
  if node -e 'const j=require(process.argv[1]); if(j.status&&j.status!==200){console.error("  API "+j.status+": "+(j.err||""));process.exit(1)}' "$2" 2>&1; then
    return 0
  fi
  return 1
}

echo "Fetching library metadata..."
fetch "files/$LIBRARY_KEY?depth=1" "$TMP/meta.json" || {
  echo "Could not read the library. If this was a 429, Figma's limit is" >&2
  echo "cost-based and can take hours to clear once exhausted." >&2
  exit 1
}

LAST_MODIFIED=$(node -e 'console.log(require(process.argv[1]).lastModified)' "$TMP/meta.json")

if [ "${1:-}" = "--check" ]; then
  recorded=$(grep -m1 '^| Library last modified' "$OUT" 2>/dev/null | sed 's/.*| `\(.*\)` |.*/\1/')
  echo "recorded: ${recorded:-<none>}"
  echo "live:     $LAST_MODIFIED"
  [ "$recorded" = "$LAST_MODIFIED" ] && { echo "Extract is current."; exit 0; }
  echo "Extract is STALE — re-run without --check."; exit 1
fi

echo "Fetching components..."
fetch "files/$LIBRARY_KEY/components" "$TMP/components.json" || exit 1
echo "Fetching styles..."
fetch "files/$LIBRARY_KEY/styles" "$TMP/styles.json" || exit 1

echo "Writing $OUT"
LAST_MODIFIED="$LAST_MODIFIED" LIBRARY_KEY="$LIBRARY_KEY" DESIGNS_KEY="$DESIGNS_KEY" \
  node "$ROOT/tools/figma-extract.mjs" "$TMP/components.json" "$TMP/styles.json" > "$OUT"

echo "Done. $(wc -l < "$OUT") lines."
