#!/usr/bin/env bash
# Read UI flows from the Armscanner designs file and summarise their layout.
#
# Deliberately frugal with API calls: Figma's rate limit is cost-based and
# recovers over minutes, so this makes exactly two requests — one for the page
# list, one for the selected pages' frames.
#
#   ./tools/figma-flow.sh                 # list pages, so you can pick
#   ./tools/figma-flow.sh Picking         # summarise pages matching a pattern
#   ./tools/figma-flow.sh 'Picking|System states'
#
# Output is a layout summary: frame sizes, the component instances each screen
# uses, and its on-screen text. See docs/figma-access.md for token setup.

set -uo pipefail

for dep in curl node; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 3; }
done

DESIGNS_KEY="${FIGMA_DESIGNS_KEY:-XMc8Glk3X9V3xh1uEiYoRe}"

resolve_token() {
  if [ -n "${FIGMA_TOKEN:-}" ]; then TOKEN="$FIGMA_TOKEN"; return 0; fi
  if TOKEN=$(security find-generic-password -s figma -w 2>/dev/null) && [ -n "$TOKEN" ]; then return 0; fi
  if [ -s "$HOME/.figma-token" ]; then TOKEN=$(tr -d '[:space:]' < "$HOME/.figma-token"); return 0; fi
  return 1
}
resolve_token || { echo "No Figma token. See docs/figma-access.md." >&2; exit 2; }

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

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# The document node yields every page id in one request. /v1/files/:key without
# depth would also work but is enormously more expensive — 33 MB for this file.
api "files/$DESIGNS_KEY/nodes?ids=0:1&depth=1" > "$TMP/doc.json" || exit 1
node -e '
const j = require(process.argv[1]);
if (j.status && j.status !== 200) { console.error("  API " + j.status + ": " + (j.err || "")); process.exit(1); }
' "$TMP/doc.json" || {
  echo "Could not list pages. If this was a 429, Figma's limit is cost-based —" >&2
  echo "expect to wait several minutes, not seconds." >&2
  exit 1
}

PATTERN="${1:-}"

if [ -z "$PATTERN" ]; then
  node -e '
  const j = require(process.argv[1]);
  const d = j.nodes[Object.keys(j.nodes)[0]].document;
  console.log("Pages in " + (d.name || "document") + ":");
  for (const p of d.children || []) console.log("  " + p.id + "  " + p.name);
  ' "$TMP/doc.json"
  exit 0
fi

IDS=$(PATTERN="$PATTERN" node -e '
const j = require(process.argv[1]);
const d = j.nodes[Object.keys(j.nodes)[0]].document;
const re = new RegExp(process.env.PATTERN, "i");
const hits = (d.children || []).filter(p => re.test(p.name));
if (!hits.length) { console.error("No page matches: " + process.env.PATTERN); process.exit(1); }
console.log(hits.map(p => p.id).join(","));
' "$TMP/doc.json") || exit 1

echo "Reading pages: $IDS" >&2
api "files/$DESIGNS_KEY/nodes?ids=$IDS&depth=8" > "$TMP/pages.json" || exit 1

node "$(cd "$(dirname "$0")" && pwd)/figma-flow.mjs" "$TMP/pages.json"
