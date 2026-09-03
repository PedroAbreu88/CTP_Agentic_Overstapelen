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

. "$(cd "$(dirname "$0")" && pwd)/figma-lib.sh"

figma_require_deps
figma_resolve_token || { echo "No Figma token. See docs/figma-access.md." >&2; exit 2; }

LIBRARY_KEY="nsgOZTtYiHjPOxrt1ImVHv"
DESIGNS_KEY="XMc8Glk3X9V3xh1uEiYoRe"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/docs/design-system.md"

# Figma rate-limits aggressively. Fetch each endpoint once, reuse from disk.
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

echo "Fetching library metadata..."
figma_api "files/$LIBRARY_KEY?depth=1" "$TMP/meta.json" || {
  echo "Could not read the library." >&2
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
figma_api "files/$LIBRARY_KEY/components" "$TMP/components.json" || exit 1
echo "Fetching styles..."
figma_api "files/$LIBRARY_KEY/styles" "$TMP/styles.json" || exit 1

echo "Writing $OUT"
LAST_MODIFIED="$LAST_MODIFIED" LIBRARY_KEY="$LIBRARY_KEY" DESIGNS_KEY="$DESIGNS_KEY" \
  node "$ROOT/tools/figma-extract.mjs" "$TMP/components.json" "$TMP/styles.json" > "$OUT"

echo "Done. $(wc -l < "$OUT") lines."
