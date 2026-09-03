#!/usr/bin/env bash
# Read UI flows from the Armscanner designs file and summarise their layout.
#
# Deliberately frugal with API calls: Figma's rate limit is cost-based and can
# take *days* to clear on a low-tier seat, so this makes exactly two requests —
# one for the page list, one for the selected pages' frames.
#
#   ./tools/figma-flow.sh                 # list pages, so you can pick
#   ./tools/figma-flow.sh Picking         # summarise pages matching a pattern
#   ./tools/figma-flow.sh 'Picking|System states'
#
# Output is a layout summary: frame sizes, the component instances each screen
# uses, and its on-screen text. See docs/figma-access.md for token setup.

set -uo pipefail

. "$(cd "$(dirname "$0")" && pwd)/figma-lib.sh"

figma_require_deps
figma_resolve_token || { echo "No Figma token. See docs/figma-access.md." >&2; exit 2; }

DESIGNS_KEY="${FIGMA_DESIGNS_KEY:-XMc8Glk3X9V3xh1uEiYoRe}"

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# The file endpoint with depth=1 returns the document and its page names only —
# about 13 KB for this file. It is the correct way to list pages. Note that
# node 0:1 is the *first page*, not the document root, so /nodes cannot be used
# for this. Without a depth parameter the same endpoint returns 33 MB and
# exhausts the rate limit for hours.
figma_api "files/$DESIGNS_KEY?depth=1" "$TMP/doc.json" || { echo "Could not list pages." >&2; exit 1; }
node -e '
const j = require(process.argv[1]);
if (!j.document || !j.document.children) { console.error("  Unexpected payload: no document.children"); process.exit(1); }
' "$TMP/doc.json" || exit 1

PATTERN="${1:-}"

if [ -z "$PATTERN" ]; then
  node -e '
  const j = require(process.argv[1]);
  console.log(j.name + "  (lastModified " + j.lastModified + ")");
  for (const p of j.document.children || []) console.log("  " + p.id + "  " + p.name);
  ' "$TMP/doc.json"
  exit 0
fi

IDS=$(PATTERN="$PATTERN" node -e '
const j = require(process.argv[1]);
const re = new RegExp(process.env.PATTERN, "i");
const hits = (j.document.children || []).filter(p => re.test(p.name));
if (!hits.length) { console.error("No page matches: " + process.env.PATTERN); process.exit(1); }
console.log(hits.map(p => p.id).join(","));
' "$TMP/doc.json") || exit 1

echo "Reading pages: $IDS" >&2
figma_api "files/$DESIGNS_KEY/nodes?ids=$IDS&depth=8" "$TMP/pages.json" || {
  echo "Could not read those pages — the budget ran out between the two calls." >&2
  exit 1
}

node "$(cd "$(dirname "$0")" && pwd)/figma-flow.mjs" "$TMP/pages.json"
