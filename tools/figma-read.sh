#!/usr/bin/env bash
# Read the Armscanner UI designs from the Figma REST API.
#
# Resolves a token from, in order:
#   1. $FIGMA_TOKEN
#   2. macOS Keychain, generic password with service name "figma"
#   3. ~/.figma-token  (untracked, outside any repository)
#
# The token is never printed, never passed as a command-line argument, and
# never written anywhere. Usage:
#
#   ./tools/figma-read.sh                 # validate the token only
#   ./tools/figma-read.sh <file-key>      # read pages, components and styles
#
# The Armscanner UI designs:
#   ./tools/figma-read.sh XMc8Glk3X9V3xh1uEiYoRe
#
# A Figma file key is the segment after /design/ or /file/ in its URL:
#   https://figma.com/design/<file-key>/Some-Name
#
# See docs/figma-access.md for token setup and known failure modes.

set -uo pipefail

. "$(cd "$(dirname "$0")" && pwd)/figma-lib.sh"

figma_require_deps
figma_resolve_token || {
  cat >&2 <<'MSG'
No Figma token found. Provide one, then re-run. In preference order:

  security add-generic-password -s figma -a "$USER" -w   # prompts; nothing hits shell history
  printf '%s' '<token>' > ~/.figma-token && chmod 600 ~/.figma-token
  export FIGMA_TOKEN='<token>'

Create a token at https://www.figma.com/developers/api#access-tokens
The token needs file_read scope at minimum.
MSG
  exit 2
}
SRC="$TOKEN_SRC"

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

echo "Token source: $SRC"
echo

echo "== GET /v1/me =="
figma_api "me" "$TMP/me.json" || exit 1
node -e 'const u=require(process.argv[1]);
  console.log("  authenticated as:", u.email||u.handle||u.id);
  console.log("  handle:", u.handle);' "$TMP/me.json"

[ $# -ge 1 ] || { echo; echo "Token works. Pass a file key to read a file:  $0 <file-key>"; exit 0; }

echo
echo "== GET /v1/files/$1?depth=1 =="
figma_api "files/$1?depth=1" "$TMP/file.json" || exit 1
node -e 'const f=require(process.argv[1]);
  console.log("  name:         ", f.name);
  console.log("  lastModified: ", f.lastModified);
  console.log("  editorType:   ", f.editorType);
  const pages=(f.document&&f.document.children)||[];
  console.log("  pages ("+pages.length+"):");
  for(const p of pages) console.log("    -", p.name);' "$TMP/file.json"

# The reusable material: published components and styles. Note that a designs
# file which *consumes* a library returns zero here — that is not an error, the
# components are defined in the library file. See docs/figma-access.md.
echo
echo "== GET /v1/files/$1/components =="
if figma_api "files/$1/components" "$TMP/components.json"; then
  node -e 'const r=require(process.argv[1]);
    const c=(r.meta&&r.meta.components)||[];
    console.log("  components ("+c.length+"):");
    const bySet={};
    for(const x of c){const k=(x.containing_frame&&x.containing_frame.name)||"(no frame)";(bySet[k]=bySet[k]||[]).push(x.name);}
    for(const k of Object.keys(bySet).slice(0,20)){
      console.log("    "+k+" ("+bySet[k].length+")");
      for(const n of bySet[k].slice(0,8)) console.log("      -", n);
    }' "$TMP/components.json"
fi

echo
echo "== GET /v1/files/$1/styles =="
if figma_api "files/$1/styles" "$TMP/styles.json"; then
  node -e 'const r=require(process.argv[1]);
    const st=(r.meta&&r.meta.styles)||[];
    const byType={};
    for(const x of st){(byType[x.style_type]=byType[x.style_type]||[]).push(x.name);}
    console.log("  styles ("+st.length+"):");
    for(const t of Object.keys(byType)){
      console.log("    "+t+" ("+byType[t].length+")");
      for(const n of byType[t].slice(0,10)) console.log("      -", n);
    }' "$TMP/styles.json"
fi

echo
echo "Note: design variables (/v1/files/:key/variables/local) need an Enterprise"
echo "plan *and* a Dev or Full seat. If that 403s, derive tokens from published styles."
