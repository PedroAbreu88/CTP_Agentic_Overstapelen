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

# Fail loudly on a missing dependency rather than part-way through with
# confusing output.
for dep in curl node; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 3; }
done

# -sS keeps curl quiet on success but still reports transport failures. Without
# -S a DNS or TLS problem produces an empty body and an empty status code, which
# is very hard to tell apart from a valid-but-empty response.
api() {
  local body status
  body=$(curl -sS -w '\n%{http_code}' -H "X-Figma-Token: $TOKEN" "https://api.figma.com/v1/$1")
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "curl failed (exit $status) — network, DNS or TLS problem, not an API error" >&2
    return 1
  fi
  printf '%s' "$body"
}

resolve_token() {
  if [ -n "${FIGMA_TOKEN:-}" ]; then TOKEN="$FIGMA_TOKEN"; SRC="\$FIGMA_TOKEN"; return 0; fi
  if TOKEN=$(security find-generic-password -s figma -w 2>/dev/null) && [ -n "$TOKEN" ]; then
    SRC="macOS Keychain (service 'figma')"; return 0
  fi
  if [ -s "$HOME/.figma-token" ]; then
    TOKEN=$(tr -d '[:space:]' < "$HOME/.figma-token"); SRC="~/.figma-token"; return 0
  fi
  return 1
}

if ! resolve_token; then
  cat >&2 <<'MSG'
No Figma token found. Provide one, then re-run. In preference order:

  security add-generic-password -s figma -a "$USER" -w   # prompts; nothing hits shell history
  printf '%s' '<token>' > ~/.figma-token && chmod 600 ~/.figma-token
  export FIGMA_TOKEN='<token>'

Create a token at https://www.figma.com/developers/api#access-tokens
For the Dev Mode MCP server later, the token needs file_read scope at minimum.
MSG
  exit 2
fi

echo "Token source: $SRC"
echo

echo "== GET /v1/me =="
body=$(api me) || exit 1; code=$(printf '%s' "$body" | tail -n1); body=$(printf '%s' "$body" | sed '$d')
echo "HTTP $code"
case "$code" in
  200) printf '%s' "$body" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const u=JSON.parse(s);console.log("  authenticated as:",u.email||u.handle||u.id);console.log("  handle:",u.handle);})' ;;
  403) echo "  403 — token rejected. Either expired, or missing the required scope." ;;
  *)   printf '  %s\n' "$(printf '%s' "$body" | head -c 400)" ;;
esac

[ "$code" = "200" ] || exit 1
[ $# -ge 1 ] || { echo; echo "Token works. Pass a file key to read a file:  $0 <file-key>"; exit 0; }

echo
echo "== GET /v1/files/$1?depth=1 =="
body=$(api "files/$1?depth=1") || exit 1; code=$(printf '%s' "$body" | tail -n1); body=$(printf '%s' "$body" | sed '$d')
echo "HTTP $code"
if [ "$code" = "200" ]; then
  printf '%s' "$body" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const f=JSON.parse(s);
    console.log("  name:         ",f.name);
    console.log("  lastModified: ",f.lastModified);
    console.log("  editorType:   ",f.editorType);
    const pages=(f.document&&f.document.children)||[];
    console.log("  pages ("+pages.length+"):");
    for(const p of pages.slice(0,25)) console.log("    -",p.name);
  })'
else
  printf '  %s\n' "$(printf '%s' "$body" | head -c 400)"
  case "$code" in
    429) echo "  Rate limited. Figma's limit is cost-based and recovery takes"
         echo "  minutes, not seconds — see docs/figma-access.md." ;;
    404) echo "  Wrong file key — check for a copied URL fragment or a branch key." ;;
    403) echo "  Token is valid but cannot see this file." ;;
  esac
  exit 1
fi

# The reusable material: published components and styles. These are the parts
# worth turning into a committed inventory, rather than re-read every session.
echo
echo "== GET /v1/files/$1/components =="
body=$(api "files/$1/components") || exit 1; code=$(printf '%s' "$body" | tail -n1); body=$(printf '%s' "$body" | sed '$d')
echo "HTTP $code"
if [ "$code" = "200" ]; then
  printf '%s' "$body" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const r=JSON.parse(s);
    const c=(r.meta&&r.meta.components)||[];
    console.log("  components ("+c.length+"):");
    const bySet={};
    for(const x of c){const k=(x.containing_frame&&x.containing_frame.name)||"(no frame)";(bySet[k]=bySet[k]||[]).push(x.name);}
    for(const k of Object.keys(bySet).slice(0,20)){
      console.log("    "+k+" ("+bySet[k].length+")");
      for(const n of bySet[k].slice(0,8)) console.log("      -",n);
    }
  })'
else
  echo "  (components unavailable — only published library components are listed here)"
fi

echo
echo "== GET /v1/files/$1/styles =="
body=$(api "files/$1/styles") || exit 1; code=$(printf '%s' "$body" | tail -n1); body=$(printf '%s' "$body" | sed '$d')
echo "HTTP $code"
if [ "$code" = "200" ]; then
  printf '%s' "$body" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const r=JSON.parse(s);
    const st=(r.meta&&r.meta.styles)||[];
    const byType={};
    for(const x of st){(byType[x.style_type]=byType[x.style_type]||[]).push(x.name);}
    console.log("  styles ("+st.length+"):");
    for(const t of Object.keys(byType)){
      console.log("    "+t+" ("+byType[t].length+")");
      for(const n of byType[t].slice(0,10)) console.log("      -",n);
    }
  })'
else
  echo "  (styles unavailable)"
fi

echo
echo "Note: design variables (/v1/files/:key/variables/local) need an Enterprise"
echo "plan. If that 403s, tokens must come from published styles instead."
