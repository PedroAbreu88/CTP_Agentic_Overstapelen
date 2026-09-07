#!/usr/bin/env bash
# Publish a Markdown document in this repository to a Confluence page.
#
# The repository is the source of truth. The Confluence page is a rendering of
# it, and gets a banner saying so. Editing the page in a browser is not
# supported -- this script detects it and refuses to overwrite, because
# silently clobbering someone's browser edit is a good way to lose work and a
# better way to lose trust in the tool.
#
# Resolves a token from, in order:
#   1. $CONFLUENCE_TOKEN
#   2. macOS Keychain, generic password with service name "confluence-api-token"
#   3. ~/.confluence-token  (untracked, outside any repository)
#
# The Atlassian account email is resolved from $CONFLUENCE_EMAIL, or from
# `git config user.email`. Note this must be the address on the Atlassian
# account, not the SSO address -- see docs/confluence-access.md.
#
# Usage:
#   ./tools/confluence-publish.sh --check              # convert and diff only
#   ./tools/confluence-publish.sh                      # publish docs/proposal.md
#   ./tools/confluence-publish.sh --force              # publish over a browser edit
#   ./tools/confluence-publish.sh --file docs/x.md --page 123456
#
# The token is never printed and never passed as a command-line argument.

set -uo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
BASE="https://confluence-aholddelhaize.atlassian.net/wiki"

FILE="$REPO_ROOT/docs/proposal.md"
PAGE_ID="151013721984"
CHECK_ONLY=0
FORCE=0

# Every version this tool creates is stamped with this prefix. A current
# version whose message lacks it means someone edited the page directly.
STAMP="Published from"

while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK_ONLY=1; shift ;;
    --force) FORCE=1; shift ;;
    --file)  FILE="$2"; shift 2 ;;
    --page)  PAGE_ID="$2"; shift 2 ;;
    -h|--help) sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

for dep in curl node; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 3; }
done

[ -f "$FILE" ] || { echo "No such file: $FILE" >&2; exit 2; }

resolve_token() {
  if [ -n "${CONFLUENCE_TOKEN:-}" ]; then TOKEN="$CONFLUENCE_TOKEN"; TOKEN_SRC="\$CONFLUENCE_TOKEN"; return 0; fi
  if TOKEN=$(security find-generic-password -s confluence-api-token -w 2>/dev/null) && [ -n "$TOKEN" ]; then
    TOKEN_SRC="macOS Keychain (service 'confluence-api-token')"; return 0
  fi
  if [ -s "$HOME/.confluence-token" ]; then
    TOKEN=$(tr -d '[:space:]' < "$HOME/.confluence-token"); TOKEN_SRC="~/.confluence-token"; return 0
  fi
  return 1
}

resolve_token || {
  cat >&2 <<'MSG'
No Confluence token found. Provide one, then re-run. In preference order:

  security add-generic-password -s confluence-api-token -a "$USER" -w   # prompts
  printf '%s' '<token>' > ~/.confluence-token && chmod 600 ~/.confluence-token
  export CONFLUENCE_TOKEN='<token>'

Create a token at https://id.atlassian.com/manage-profile/security/api-tokens
See docs/confluence-access.md for the gotchas -- especially that a truncated
token fails as a 403 that looks exactly like a permissions problem.
MSG
  exit 2
}

# A classic Atlassian token is 192 characters. A short one is a truncated paste,
# and it fails as a 403 on every request including with invalid credentials,
# which is a genuinely confusing way to lose an afternoon.
if [ "${#TOKEN}" -lt 100 ]; then
  echo "Token from $TOKEN_SRC is ${#TOKEN} characters, expected ~192. Truncated paste?" >&2
  exit 2
fi

EMAIL="${CONFLUENCE_EMAIL:-$(git -C "$REPO_ROOT" config user.email 2>/dev/null)}"
[ -n "$EMAIL" ] || { echo "Set \$CONFLUENCE_EMAIL or git config user.email" >&2; exit 2; }
case "$EMAIL" in
  *@emea.royalahold.net)
    echo "Warning: $EMAIL is the SSO address, which the API rejects with a 403." >&2
    echo "Use the Atlassian account address instead. See docs/confluence-access.md." >&2 ;;
esac

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

echo "Source:  ${FILE#"$REPO_ROOT"/}"
echo "Page:    $PAGE_ID"
echo "Auth:    $EMAIL via $TOKEN_SRC"
echo

node "$REPO_ROOT/tools/md-to-storage.mjs" "$FILE" > "$TMP/converted.json" || exit 1

CODE=$(curl -s -u "$EMAIL:$TOKEN" -H "Accept: application/json" \
  "$BASE/api/v2/pages/$PAGE_ID?body-format=storage" \
  -o "$TMP/current.json" -w '%{http_code}')

if [ "$CODE" != "200" ]; then
  echo "GET page $PAGE_ID returned HTTP $CODE" >&2
  case "$CODE" in
    403) echo "  Wrong username, or a malformed token. Retry with a deliberately bogus" >&2
         echo "  token: an identical response means the credential is not being read." >&2 ;;
    404) echo "  Wrong page ID, or the account cannot see it. Confluence hides pages" >&2
         echo "  rather than returning 403." >&2 ;;
  esac
  exit 1
fi

node - "$TMP/current.json" "$TMP/converted.json" "$TMP/put.json" "$CHECK_ONLY" "$FORCE" "$STAMP" <<'NODE'
const fs = require('node:fs');
const [, , currentPath, convertedPath, outPath, checkOnly, force, stamp] = process.argv;

const current = JSON.parse(fs.readFileSync(currentPath, 'utf8'));
const { title, body } = JSON.parse(fs.readFileSync(convertedPath, 'utf8'));

const version = current.version || {};
const liveBody = ((current.body || {}).storage || {}).value || '';
const message = version.message || '';

const banner =
  '<ac:structured-macro ac:name="info" ac:schema-version="1"><ac:rich-text-body>\n' +
  '<p><strong>Generated page.</strong> This is published from <code>docs/proposal.md</code> in ' +
  '<a href="https://github.com/PedroAbreu88/CTP_Agentic_Overstapelen">PedroAbreu88/CTP_Agentic_Overstapelen</a> ' +
  'and any edit made here will be overwritten. Change the Markdown, raise a pull request, ' +
  'and re-run <code>./tools/confluence-publish.sh</code>. Comments on this page are safe ' +
  'and are the right way to give feedback.</p>\n' +
  '</ac:rich-text-body></ac:structured-macro>';

const next = banner + '\n\n' + body;

// Confluence rewrites what you PUT: it injects an ac:macro-id into every macro,
// reflows whitespace, and normalises character entities in *both* directions --
// it decoded our literal warning sign but encoded our literal em dash. So a byte
// comparison always differs, and the tool would bump the page version on every
// run, making the history useless and the browser-edit guard below meaningless.
// Compare a form with entities decoded on both sides instead.
const ENTITIES = {
  amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: '\u00a0',
  mdash: '\u2014', ndash: '\u2013', hellip: '\u2026', rarr: '\u2192',
  lsquo: '\u2018', rsquo: '\u2019', ldquo: '\u201c', rdquo: '\u201d',
};

const normalise = (s) =>
  s
    .replace(/\s*ac:macro-id="[^"]*"/g, '')
    .replace(/&#(\d+);/g, (_, n) => String.fromCodePoint(Number(n)))
    .replace(/&#x([0-9a-f]+);/gi, (_, h) => String.fromCodePoint(parseInt(h, 16)))
    .replace(/&([a-z]+);/gi, (m, n) => (n.toLowerCase() in ENTITIES ? ENTITIES[n.toLowerCase()] : m))
    .replace(/\s+/g, ' ')
    .trim();

if (normalise(liveBody) === normalise(next)) {
  console.log(`Page already matches docs/proposal.md at version ${version.number}. Nothing to do.`);
  process.exit(3);
}

// Refuse to clobber an edit this tool did not make.
const everPublished = message.startsWith(stamp);
if (!everPublished && force !== '1') {
  console.error(`Refusing to publish over version ${version.number}, which this tool did not create.`);
  console.error(`  version message: ${message || '(none)'}`);
  console.error('  Someone may have edited the page in a browser. Reconcile it into');
  console.error('  docs/proposal.md first, or re-run with --force to overwrite.');
  process.exit(1);
}

console.log(`Live version ${version.number}: ${liveBody.length} chars`);
console.log(`Converted:              ${next.length} chars  (title: ${title})`);

if (checkOnly === '1') {
  console.log('\n--check: not publishing.');
  process.exit(3);
}

fs.writeFileSync(outPath, JSON.stringify({
  id: current.id,
  status: 'current',
  title,
  body: { representation: 'storage', value: next },
  version: {
    number: version.number + 1,
    message: `${stamp} docs/proposal.md`,
  },
}));
NODE

RC=$?
[ "$RC" -eq 3 ] && exit 0
[ "$RC" -ne 0 ] && exit "$RC"

CODE=$(curl -s -u "$EMAIL:$TOKEN" -X PUT \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  --data @"$TMP/put.json" \
  "$BASE/api/v2/pages/$PAGE_ID" \
  -o "$TMP/resp.json" -w '%{http_code}')

if [ "$CODE" != "200" ]; then
  echo "PUT returned HTTP $CODE" >&2
  node -e 'try{const r=require(process.argv[1]);console.error("  "+JSON.stringify(r.errors||r))}catch(e){}' "$TMP/resp.json" >&2
  exit 1
fi

node -e '
  const r = require(process.argv[1]);
  console.log(`\nPublished version ${r.version.number}: ${r.title}`);
  console.log(`  ${process.argv[2]}/spaces/CTPBOFAFFL/pages/${r.id}`);
' "$TMP/resp.json" "$BASE"
