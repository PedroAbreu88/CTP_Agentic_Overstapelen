// Turns the Figma components/styles API payloads into docs/design-system.md.
// Invoked by tools/figma-extract.sh, which supplies the fetched JSON.

import { readFileSync } from "node:fs";

const [componentsPath, stylesPath] = process.argv.slice(2);
const components = JSON.parse(readFileSync(componentsPath, "utf8")).meta.components;
const styles = JSON.parse(readFileSync(stylesPath, "utf8")).meta.styles;

const LAST_MODIFIED = process.env.LAST_MODIFIED;
const LIBRARY_KEY = process.env.LIBRARY_KEY;
const DESIGNS_KEY = process.env.DESIGNS_KEY;

// Components are variants; the component *set* is the reusable unit a designer
// or developer actually picks. Group by set so the inventory reads as a
// vocabulary rather than a list of 643 permutations.
const sets = new Map();
for (const c of components) {
  const frame = c.containing_frame || {};
  const setName = frame.containingStateGroup?.name || frame.name || "(ungrouped)";
  const page = frame.pageName || "(no page)";
  const key = `${page}\u0000${setName}`;
  if (!sets.has(key)) sets.set(key, { page, name: setName, variants: [], description: "" });
  const entry = sets.get(key);
  entry.variants.push(c.name);
  if (!entry.description && c.description) entry.description = c.description.replace(/\s+/g, " ").trim();
}

// Provenance is encoded in the name suffix, and it matters: the library blends
// three sources, and "which family is current" is not obvious from the name.
const provenance = (name) => {
  if (/\[OLD\]/i.test(name)) return "deprecated";
  if (/-\s*Pantry\s*$|\bPantry\b/i.test(name)) return "Pantry";
  if (/-\s*Nadine\s*$|\bNadine\b/i.test(name)) return "Nadine";
  return "Armscanner";
};

// Designers mark library pages with ✅ / ❌. Confirmed with the team: ❌ means
// no longer applicable — those components must not be proposed.
const pageMark = (page) =>
  /✅/.test(page) ? "approved" : /❌/.test(page) ? "retired" : "unmarked";

const byPage = new Map();
for (const s of sets.values()) {
  if (!byPage.has(s.page)) byPage.set(s.page, []);
  byPage.get(s.page).push(s);
}

const counts = { deprecated: 0, Pantry: 0, Nadine: 0, Armscanner: 0 };
for (const s of sets.values()) counts[provenance(s.name)]++;

const out = [];
const p = (line = "") => out.push(line);

p("# Armscanner design system");
p();
p("Generated inventory of the published Figma library. **Do not edit by hand** —");
p("regenerate with `./tools/figma-extract.sh`, which rewrites this file.");
p();
p("This exists so agents and people can work in the existing design vocabulary");
p("without a Figma token and without an API call. It records *what exists and what");
p("it is called*. It does not record why a pattern was chosen — that reasoning");
p("lives with the design team, not in the file.");
p();
p("## Source");
p();
p("| | |");
p("| --- | --- |");
p(`| Library file | [Armscanner - Library](https://www.figma.com/design/${LIBRARY_KEY}/) (\`${LIBRARY_KEY}\`) |`);
p(`| Designs file | [Armscanner - UI designs](https://www.figma.com/design/${DESIGNS_KEY}/) (\`${DESIGNS_KEY}\`) |`);
p(`| Library last modified | \`${LAST_MODIFIED}\` |`);
p(`| Published components | ${components.length} in ${sets.size} sets |`);
p(`| Published styles | ${styles.length} |`);
p();
p("`Library last modified` is the staleness check. Run");
p("`./tools/figma-extract.sh --check` to compare it against the live file; a");
p("mismatch means this document describes a library that has moved on.");
p();
p("The **library** defines components. The **designs** file consumes them — it");
p("holds ~6,800 instances and almost no local components, so read the library for");
p("the vocabulary and the designs file for how flows use it.");
p();

p("## Reading the names");
p();
p("Component names carry their origin as a suffix, and the library deliberately");
p("blends three sources. This is the single most important thing to get right,");
p("because picking a deprecated variant produces confident, wrong work.");
p();
p("| Family | Sets | Meaning |");
p("| --- | --- | --- |");
p(`| \`- Pantry\` | ${counts.Pantry} | From the Ahold Delhaize Pantry design system. |`);
p(`| \`- Nadine\` | ${counts.Nadine} | From the Nadine system. Often the newer of a duplicated pair. |`);
p(`| unsuffixed | ${counts.Armscanner} | Armscanner-specific, built for this device class. |`);
p(`| \`[OLD]\` | ${counts.deprecated} | **Deprecated. Do not use.** |`);
p();
p("Where a set appears twice under different families, that is a live migration,");
p("not a mistake. Prefer the family used by the flow you are extending, and say");
p("which you picked and why. If in doubt, ask design rather than guessing.");
p();

p("## Page marks — ✅ and ❌");
p();
p("Designers annotate library pages with tick and cross emoji.");
p();
p("**❌ means no longer applicable. Do not propose anything on a ❌ page.**");
p("Confirmed with the team — this is a hard rule, equivalent to `[OLD]`.");
p();
const marked = { approved: [], retired: [] };
for (const page of byPage.keys()) {
  const m = pageMark(page);
  if (m !== "unmarked") marked[m].push(page.trim());
}
p("| Mark | Meaning | Pages |");
p("| --- | --- | --- |");
p(`| ❌ | **Retired — do not use** | ${marked.retired.length ? marked.retired.map((x) => `\`${x}\``).join(", ") : "—"} |`);
p(`| ✅ | Reviewed and approved | ${marked.approved.length ? marked.approved.map((x) => `\`${x}\``).join(", ") : "—"} |`);
p(`| none | ${byPage.size - marked.approved.length - marked.retired.length} pages | Usable, but not explicitly reviewed. |`);
p();
p("Note the asymmetry: ❌ is a confirmed prohibition, but the absence of a ✅ is");
p("**not** an endorsement — most pages carry no mark at all. Treat unmarked");
p("components as usable while remembering they have not been through the same");
p("review as the ticked ones.");
p();

p("### What replaced the retired components");
p();
p("The retirements follow a consistent logic, and it is worth understanding");
p("rather than memorising: **standalone form controls are out; list-item and");
p("numpad equivalents are in.** On an arm scanner a bare checkbox is a small");
p("target needing precise aim, while a full-width list row is a large one — and");
p("free text entry is impractical with gloves, so numeric entry goes through a");
p("numpad.");
p();
p("| Retired | Use instead |");
p("| --- | --- |");
p("| `Input / Checkbox`, `Input / Radio` | `List Item / Checkbox`, `List Item / Radio` |");
p("| `Inputfield`, `Number input`, `Input - Text - Nadine`, `Inputfield Listitem I` | `Numpad`, `Numpad - Pantry`, `Numpad / Inputfield` |");
p("| `Divider` | No direct replacement identified — separation appears to be handled inside list-item components. Confirm with design. |");
p();

p("## Deprecated — do not use");
p();
const dep = [...sets.values()].filter((s) => provenance(s.name) === "deprecated");
if (dep.length === 0) {
  p("None currently marked `[OLD]`.");
} else {
  for (const s of dep.sort((a, b) => a.name.localeCompare(b.name))) {
    p(`- \`${s.name}\` — ${s.variants.length} variants`);
  }
}
p();

p("## Component sets");
p();
p("Grouped by library page. Variant names are the axes you choose along");
p("(`State=`, `Type=`, `Platform=`, `Size=` and so on).");
p();

for (const page of [...byPage.keys()].sort()) {
  const list = byPage.get(page).sort((a, b) => a.name.localeCompare(b.name));
  const mark = pageMark(page);
  const note = mark === "retired" ? " — ❌ RETIRED, do not propose" : "";
  p(`### ${page.trim()}${note}`);
  p();
  for (const s of list) {
    const fam = provenance(s.name);
    const retired = mark === "retired";
    const tag = retired
      ? " **[RETIRED]**"
      : fam === "deprecated"
        ? " **[DEPRECATED]**"
        : fam === "Armscanner"
          ? ""
          : ` _(${fam})_`;
    p(`- **${s.name}**${tag} — ${s.variants.length} variant${s.variants.length === 1 ? "" : "s"}`);
    if (s.description) p(`  - ${s.description}`);
    const sample = [...new Set(s.variants)].slice(0, 6);
    if (sample.length && sample[0] !== s.name) {
      p(`  - \`${sample.join("\`, \`")}\`${s.variants.length > 6 ? " …" : ""}`);
    }
  }
  p();
}

p("## Styles");
p();
p("Semantic tokens. Prefer these names over raw values — a hex code in a design");
p("proposal is a defect, because it cannot follow the system when it changes.");
p();

const byType = new Map();
for (const s of styles) {
  if (!byType.has(s.style_type)) byType.set(s.style_type, []);
  byType.get(s.style_type).push(s.name);
}

const typeLabel = { FILL: "Colour (FILL)", TEXT: "Typography (TEXT)", EFFECT: "Effects", GRID: "Layout grids" };

for (const [type, names] of [...byType.entries()].sort()) {
  const unique = [...new Set(names)].sort();
  p(`### ${typeLabel[type] || type} — ${unique.length}`);
  p();
  // Group by the first path segment so the semantic families are visible.
  const groups = new Map();
  for (const n of unique) {
    const g = n.split("/")[0].trim() || "(root)";
    if (!groups.has(g)) groups.set(g, []);
    groups.get(g).push(n);
  }
  for (const [g, items] of [...groups.entries()].sort()) {
    p(`**${g}**`);
    p();
    for (const i of items) p(`- \`${i}\``);
    p();
  }
}

p("## What this file does not tell you");
p();
p("- **Why** a component exists or when it was chosen over another. Ask design.");
p("- **Pixel geometry.** Sizes, spacing and layout live in the Figma frames.");
p("- **Whether a component is right for overstapelen.** The library serves");
p("  several flows across Armscanner and Wallscanner; not everything applies.");
p("- **How a component behaves.** Variant axes hint at states, but interaction");
p("  detail is in the designs file and in the flows.");
p();

process.stdout.write(out.join("\n") + "\n");
