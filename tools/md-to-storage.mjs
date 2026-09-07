#!/usr/bin/env node
// Convert a Markdown proposal into Confluence storage format (XHTML).
//
// This is deliberately NOT a general-purpose Markdown converter. It supports
// exactly the subset docs/proposal.md uses, and throws on anything else rather
// than silently dropping content. A converter that quietly skips what it does
// not understand produces a Confluence page missing a paragraph nobody notices
// for a month — so unknown syntax is a hard error, with the line number.
//
// Supported:
//   #, ##, ###, ####      headings (a leading # is consumed as the page title)
//   paragraphs            **bold**, _italic_, `code`, [text](url)
//
// Link targets must be http, https, mailto, or a relative path. Any other
// scheme is a hard error rather than something to escape and hope about.
//   - item                bullet list
//   1. item               numbered list
//   | a | b |             table, first row is the header
//   > [!NOTE]             admonition -> Confluence panel macro
//   ```cart-grid          the cart position schematic (see below)
//   <!-- toc -->          table-of-contents macro
//   ---                   horizontal rule
//
// Admonition mapping, chosen so the source renders correctly on GitHub too:
//   [!NOTE] -> info    [!TIP] -> tip    [!IMPORTANT] -> note
//   [!WARNING] -> warning    [!CAUTION] -> warning
//
// The cart-grid block renders the position-map schematic: one cell per crate
// position, coloured by strek, with `!` marking a crate over 10kg. It exists
// because a Markdown table cannot carry cell background colours, and because
// keeping the grid as data means the schematic is edited as data.
//
//   ```cart-grid
//   5  5  5! 5  5  5
//   5! 6  6! 7  7  7
//   ```
//
// Usage:  node tools/md-to-storage.mjs <file.md>
// Writes JSON to stdout: { "title": ..., "body": ... }

import { readFileSync } from 'node:fs';

const STREK_COLOURS = ['#4c9aff', '#79f2c0', '#deebff', '#ffe380', '#ffbdad', '#c0b6f2'];
const ORIENTATION_COLOUR = '#dfe1e6';

const ADMONITIONS = {
  NOTE: 'info',
  TIP: 'tip',
  IMPORTANT: 'note',
  WARNING: 'warning',
  CAUTION: 'warning',
};

const file = process.argv[2];
if (!file) {
  console.error('usage: node tools/md-to-storage.mjs <file.md>');
  process.exit(2);
}

const fail = (lineNo, msg) => {
  console.error(`${file}:${lineNo}: ${msg}`);
  process.exit(1);
};

// Escapes for both text and attribute contexts. Quotes matter: link targets are
// interpolated into href="..." below, and storage format is XHTML, so a stray
// quote does not just break the attribute -- it can inject markup into the page.
const escapeHtml = (s) =>
  s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

// Link targets: anything carrying a URL scheme must use one we trust. Relative
// paths and anchors have no scheme and are always fine. Rejecting rather than
// escaping an odd scheme is deliberate -- there is no legitimate reason for the
// proposal to contain javascript: or data:, and a Markdown converter should not
// be the component deciding which exotic schemes are safe.
const SCHEME = /^([a-z][a-z0-9+.-]*):/i;
const ALLOWED_SCHEMES = new Set(['http', 'https', 'mailto']);

const linkIsSafe = (href) => {
  const m = SCHEME.exec(href);
  // A Windows-style "C:" or a stray "foo:bar" is not a relative path we want.
  return m ? ALLOWED_SCHEMES.has(m[1].toLowerCase()) : true;
};

// Inline formatting. Code spans are lifted out first so their contents are
// never treated as markup.
function inline(text, lineNo) {
  const code = [];
  let s = text.replace(/`([^`]+)`/g, (_, c) => {
    code.push(c);
    return `\u0000${code.length - 1}\u0000`;
  });

  s = escapeHtml(s);
  s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (_, t, href) => {
    // href is already escaped by escapeHtml above; decode only what we need to
    // test the scheme, so an encoded "javascript&#58;" cannot slip past.
    const probe = href.replace(/&amp;/g, '&').replace(/&#(\d+);/g, (_m, n) => String.fromCodePoint(Number(n)));
    if (!linkIsSafe(probe)) {
      fail(lineNo, `unsupported link scheme in "${probe}"; expected http, https, mailto, or a relative path`);
    }
    return `<a href="${href}">${t}</a>`;
  });
  s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  s = s.replace(/(^|[\s(])_([^_]+)_(?=[\s.,;:)!?]|$)/g, '$1<em>$2</em>');
  s = s.replace(/\s--\s/g, ' \u2014 ');

  if (/\*\*/.test(s)) fail(lineNo, 'unbalanced ** in: ' + text);

  return s.replace(/\u0000(\d+)\u0000/g, (_, i) => `<code>${escapeHtml(code[Number(i)])}</code>`);
}

function cartGrid(rows, lineNo) {
  if (rows.length === 0) fail(lineNo, 'empty cart-grid block; expected at least one row of cells');

  const streks = [];
  const grid = rows.map((r) => r.trim().split(/\s+/));
  const width = grid[0].length;

  for (const row of grid) {
    if (row.length !== width) fail(lineNo, `cart-grid rows must all be ${width} cells wide`);
    for (const cell of row) {
      if (!/^[A-Za-z0-9]+!?$/.test(cell)) fail(lineNo, `bad cart-grid cell: ${cell}`);
      const strek = cell.replace(/!$/, '');
      if (!streks.includes(strek)) streks.push(strek);
    }
  }
  if (streks.length > STREK_COLOURS.length) {
    fail(lineNo, `cart-grid has ${streks.length} streks but only ${STREK_COLOURS.length} colours`);
  }

  const colourOf = (strek) => STREK_COLOURS[streks.indexOf(strek)];
  const middle = Math.floor(grid.length / 2);

  const trs = grid.map((row, i) => {
    const tds = row
      .map((cell) => {
        const strek = cell.replace(/!$/, '');
        const heavy = cell.endsWith('!') ? ' <strong>\u26a0</strong>' : '';
        return `<td data-highlight-colour="${colourOf(strek)}" style="text-align: center;"><p><strong>${strek}</strong>${heavy}</p></td>`;
      })
      .join('');
    const end =
      i === middle
        ? `<td data-highlight-colour="${ORIENTATION_COLOUR}" style="text-align: center;"><p><em>handle<br />end</em></p></td>`
        : `<td data-highlight-colour="${ORIENTATION_COLOUR}"><p>\u00a0</p></td>`;
    return `<tr>${tds}${end}</tr>`;
  });

  return `<table data-layout="default"><tbody>\n${trs.join('\n')}\n</tbody></table>`;
}

const src = readFileSync(file, 'utf8').replace(/\r\n/g, '\n');
const lines = src.split('\n');

let title = null;
const out = [];
let i = 0;

const isBlank = (l) => l.trim() === '';

while (i < lines.length) {
  const line = lines[i];
  const lineNo = i + 1;

  if (isBlank(line)) {
    i += 1;
    continue;
  }

  if (line.trim() === '<!-- toc -->') {
    out.push('<ac:structured-macro ac:name="toc" ac:schema-version="1"><ac:parameter ac:name="maxLevel">2</ac:parameter></ac:structured-macro>');
    i += 1;
    continue;
  }

  if (/^-{3,}$/.test(line.trim())) {
    out.push('<hr />');
    i += 1;
    continue;
  }

  const heading = line.match(/^(#{1,4})\s+(.*)$/);
  if (heading) {
    const level = heading[1].length;
    if (level === 1) {
      if (title !== null) fail(lineNo, 'more than one level-1 heading; the first is the page title');
      title = heading[2].trim();
    } else {
      out.push(`<h${level}>${inline(heading[2].trim(), lineNo)}</h${level}>`);
    }
    i += 1;
    continue;
  }

  // Fenced block. Only cart-grid is understood.
  const fence = line.match(/^```(\S*)\s*$/);
  if (fence) {
    const lang = fence[1];
    const body = [];
    i += 1;
    while (i < lines.length && !/^```\s*$/.test(lines[i])) {
      body.push(lines[i]);
      i += 1;
    }
    if (i >= lines.length) fail(lineNo, 'unclosed fenced block');
    i += 1;
    if (lang !== 'cart-grid') fail(lineNo, `unsupported fenced block "${lang}"; only cart-grid is handled`);
    out.push(cartGrid(body.filter((l) => !isBlank(l)), lineNo));
    continue;
  }

  // Admonition: "> [!WARNING]" then subsequent "> " lines.
  if (line.startsWith('>')) {
    const marker = line.match(/^>\s*\[!([A-Z]+)\]\s*$/);
    if (!marker) fail(lineNo, 'blockquotes are only supported as GitHub alerts, e.g. "> [!NOTE]"');
    const macro = ADMONITIONS[marker[1]];
    if (!macro) fail(lineNo, `unknown alert type [!${marker[1]}]`);
    i += 1;
    const paras = [];
    let current = [];
    while (i < lines.length && lines[i].startsWith('>')) {
      const content = lines[i].replace(/^>\s?/, '');
      if (isBlank(content)) {
        if (current.length) paras.push(current.join(' '));
        current = [];
      } else {
        current.push(content.trim());
      }
      i += 1;
    }
    if (current.length) paras.push(current.join(' '));
    const inner = paras.map((p, n) => `<p>${inline(p, lineNo + n)}</p>`).join('\n');
    out.push(
      `<ac:structured-macro ac:name="${macro}" ac:schema-version="1"><ac:rich-text-body>\n${inner}\n</ac:rich-text-body></ac:structured-macro>`
    );
    continue;
  }

  // Table. First row is the header, second must be the separator.
  if (line.trim().startsWith('|')) {
    const cellsOf = (l) =>
      l.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
    const header = cellsOf(line);
    if (i + 1 >= lines.length || !/^\s*\|[\s:|-]+\|\s*$/.test(lines[i + 1])) {
      fail(lineNo, 'table header must be followed by a |---| separator row');
    }
    i += 2;
    const rows = [];
    while (i < lines.length && lines[i].trim().startsWith('|')) {
      rows.push(cellsOf(lines[i]));
      i += 1;
    }
    const th = header.map((c) => `<th><p>${inline(c, lineNo)}</p></th>`).join('');
    const trs = rows
      .map((r) => {
        if (r.length !== header.length) fail(lineNo, `table row has ${r.length} cells, header has ${header.length}`);
        return '<tr>' + r.map((c) => `<td><p>${inline(c, lineNo)}</p></td>`).join('') + '</tr>';
      })
      .join('\n');
    out.push(`<table data-layout="default"><tbody>\n<tr>${th}</tr>\n${trs}\n</tbody></table>`);
    continue;
  }

  // Lists. Flat only -- nesting is rejected rather than mangled.
  const bullet = line.match(/^(\s*)[-*]\s+(.*)$/);
  const numbered = line.match(/^(\s*)\d+[.)]\s+(.*)$/);
  if (bullet || numbered) {
    const ordered = Boolean(numbered);
    const items = [];
    while (i < lines.length) {
      const m = lines[i].match(ordered ? /^(\s*)\d+[.)]\s+(.*)$/ : /^(\s*)[-*]\s+(.*)$/);
      if (!m) break;
      if (m[1].length > 0) fail(i + 1, 'nested lists are not supported; flatten it or use a table');
      items.push(m[2].trim());
      i += 1;
    }
    const tag = ordered ? 'ol' : 'ul';
    const lis = items.map((t, n) => `<li><p>${inline(t, lineNo + n)}</p></li>`).join('\n');
    out.push(`<${tag}>\n${lis}\n</${tag}>`);
    continue;
  }

  if (line.startsWith('<')) fail(lineNo, 'raw HTML is not supported; add a converter rule instead');

  // Paragraph: consecutive non-blank lines that start no other block.
  const para = [];
  while (i < lines.length && !isBlank(lines[i])) {
    const l = lines[i];
    if (/^(#{1,4}\s|>|\||```|<!--)/.test(l) || /^(\s*)([-*]\s|\d+[.)]\s)/.test(l) || /^-{3,}$/.test(l.trim())) break;
    para.push(l.trim());
    i += 1;
  }
  if (para.length === 0) fail(lineNo, `could not parse line: ${line}`);
  out.push(`<p>${inline(para.join(' '), lineNo)}</p>`);
}

if (!title) fail(1, 'no level-1 heading found; the first "# Title" becomes the Confluence page title');

process.stdout.write(JSON.stringify({ title, body: out.join('\n\n') + '\n' }));
