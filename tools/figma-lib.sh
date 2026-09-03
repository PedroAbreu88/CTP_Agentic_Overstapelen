#!/usr/bin/env bash
# Shared Figma REST helpers. Sourced by the other tools/figma-*.sh scripts.
#
# The reason this file exists: Figma tells you exactly how long you are blocked
# for, in the `retry-after` response header, and none of our scripts were
# reading it. We spent several sessions guessing "minutes" while the server was
# reporting days. Never diagnose a Figma 429 from the response body alone.

set -uo pipefail

figma_require_deps() {
  for dep in curl node; do
    command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 3; }
  done
}

figma_resolve_token() {
  if [ -n "${FIGMA_TOKEN:-}" ]; then TOKEN="$FIGMA_TOKEN"; TOKEN_SRC="\$FIGMA_TOKEN"; return 0; fi
  if TOKEN=$(security find-generic-password -s figma -w 2>/dev/null) && [ -n "$TOKEN" ]; then
    TOKEN_SRC="macOS Keychain (service 'figma')"; return 0
  fi
  if [ -s "$HOME/.figma-token" ]; then
    TOKEN=$(tr -d '[:space:]' < "$HOME/.figma-token"); TOKEN_SRC="~/.figma-token"; return 0
  fi
  return 1
}

# Turns the rate-limit headers into a usable answer: how long, and why.
# Figma exposes retry-after in seconds, along with the plan tier and the rate
# limit tier actually applied — which are not the same thing.
figma_explain_429() {
  local hdrfile="$1"
  local retry tier limit_type
  retry=$(grep -i '^retry-after:' "$hdrfile" | tr -d '\r' | awk '{print $2}')
  tier=$(grep -i '^x-figma-plan-tier:' "$hdrfile" | tr -d '\r' | awk '{print $2}')
  limit_type=$(grep -i '^x-figma-rate-limit-type:' "$hdrfile" | tr -d '\r' | awk '{print $2}')

  echo "  Rate limited by Figma." >&2
  if [ -n "$retry" ]; then
    RETRY_AFTER="$retry" node -e '
      const s = Number(process.env.RETRY_AFTER);
      const until = new Date(Date.now() + s * 1000);
      const h = s / 3600;
      const pretty = h >= 48 ? (s / 86400).toFixed(1) + " days"
                   : h >= 1  ? h.toFixed(1) + " hours"
                   : s >= 60 ? Math.round(s / 60) + " minutes"
                             : s + " seconds";
      console.error("  retry-after: " + s + "s (" + pretty + ") — clears about " + until.toISOString());
    '
  else
    echo "  (no retry-after header returned)" >&2
  fi
  [ -n "$tier" ] && echo "  plan tier: $tier" >&2
  if [ "$limit_type" = "low" ]; then
    echo "  rate limit tier: low — this is a *seat* restriction, not the org plan." >&2
    echo "  A Dev or Full seat gets per-minute limits instead. See docs/figma-access.md." >&2
  elif [ -n "$limit_type" ]; then
    echo "  rate limit tier: $limit_type" >&2
  fi
}

# figma_api <path> <body-outfile>
# Writes the response body to the outfile. Returns non-zero on transport
# failure or an API error, explaining a 429 properly.
figma_api() {
  local path="$1" out="$2" hdr code
  hdr=$(mktemp)
  code=$(curl -sS -D "$hdr" -o "$out" -w '%{http_code}' \
    -H "X-Figma-Token: $TOKEN" "https://api.figma.com/v1/$path")
  local curl_status=$?

  if [ "$curl_status" -ne 0 ]; then
    echo "curl failed (exit $curl_status) — network, DNS or TLS problem, not an API error" >&2
    rm -f "$hdr"; return 1
  fi

  if [ "$code" = "429" ]; then
    figma_explain_429 "$hdr"
    rm -f "$hdr"; return 1
  fi

  if [ "$code" != "200" ]; then
    echo "  API $code" >&2
    case "$code" in
      403) echo "  Token rejected, or it cannot see this file." >&2 ;;
      404) echo "  Wrong file key — check for a copied URL fragment or a branch key." >&2 ;;
    esac
    head -c 300 "$out" >&2; echo >&2
    rm -f "$hdr"; return 1
  fi

  rm -f "$hdr"; return 0
}
