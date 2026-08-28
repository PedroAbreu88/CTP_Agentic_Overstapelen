// Summarises Figma pages as screen layouts: frame size, the component
// instances each screen uses, and its on-screen text.
//
// The point is to answer "what is on a screen and roughly where", not to dump
// geometry. Raw coordinates rot on the next design edit; the arrangement and
// the component vocabulary are what survive.

import { readFileSync } from "node:fs";

const payload = JSON.parse(readFileSync(process.argv[2], "utf8"));

// An API error payload has no `nodes`, so without this check the script would
// report "no device-sized frames found" and misdiagnose a rate limit as a
// design-file problem.
if (payload.status && payload.status !== 200) {
  console.error(`API error ${payload.status}: ${payload.err || "(no message)"}`);
  process.exit(1);
}
if (!payload.nodes || typeof payload.nodes !== "object") {
  console.error("Unexpected payload: no `nodes` object. Not a /v1/files/:key/nodes response?");
  process.exit(1);
}

// Screens are the frames sized like the device. Everything larger is a
// container or an annotation canvas; everything much smaller is a detail.
const DEVICE_SIZES = [
  { w: 534, h: 320, label: "800x480 @1.5" },
  { w: 640, h: 360, label: "1280x720 @2" },
];

const near = (a, b, tol = 8) => Math.abs(a - b) <= tol;

const deviceLabel = (box) => {
  if (!box) return null;
  for (const d of DEVICE_SIZES) {
    if (near(box.width, d.w) && near(box.height, d.h)) return d.label;
  }
  return null;
};

const collectScreens = (node, page, out) => {
  const box = node.absoluteBoundingBox;
  if ((node.type === "FRAME" || node.type === "COMPONENT") && deviceLabel(box)) {
    out.push({ page, node });
    return; // do not descend into a screen looking for more screens
  }
  for (const c of node.children || []) collectScreens(c, page, out);
};

// Region is a coarse vertical band. Precise pixels are noise; "is this at the
// top, in the body, or on the bottom action bar" is the thing worth knowing.
const region = (childBox, screenBox) => {
  if (!childBox || !screenBox) return "?";
  const rel = (childBox.y - screenBox.y) / screenBox.height;
  const relBottom = (childBox.y + childBox.height - screenBox.y) / screenBox.height;
  if (relBottom <= 0.22) return "top";
  if (rel >= 0.75) return "bottom";
  return "body";
};

const describe = (screen) => {
  const box = screen.absoluteBoundingBox;
  const instances = [];
  const texts = [];

  const walk = (n, depth) => {
    if (n.type === "INSTANCE") {
      instances.push({
        name: n.name,
        region: region(n.absoluteBoundingBox, box),
        w: n.absoluteBoundingBox ? Math.round(n.absoluteBoundingBox.width) : null,
        h: n.absoluteBoundingBox ? Math.round(n.absoluteBoundingBox.height) : null,
      });
      return; // an instance's internals belong to its component, not this screen
    }
    if (n.type === "TEXT" && n.characters) {
      const t = n.characters.replace(/\s+/g, " ").trim();
      if (t) texts.push(t);
    }
    for (const c of n.children || []) walk(c, depth + 1);
  };

  for (const c of screen.children || []) walk(c, 0);
  return { instances, texts };
};

const screens = [];
for (const key of Object.keys(payload.nodes || {})) {
  const doc = payload.nodes[key].document;
  collectScreens(doc, doc.name, screens);
}

if (!screens.length) {
  console.error("No device-sized frames found on those pages.");
  process.exit(1);
}

const byPage = new Map();
for (const s of screens) {
  if (!byPage.has(s.page)) byPage.set(s.page, []);
  byPage.get(s.page).push(s.node);
}

for (const [page, list] of byPage) {
  console.log(`\n## ${page.trim()}  (${list.length} screens)`);
  for (const screen of list) {
    const box = screen.absoluteBoundingBox;
    const { instances, texts } = describe(screen);
    console.log(`\n### ${screen.name}  [${Math.round(box.width)}x${Math.round(box.height)}]`);

    for (const r of ["top", "body", "bottom"]) {
      const inRegion = instances.filter((i) => i.region === r);
      if (!inRegion.length) continue;
      const counted = new Map();
      for (const i of inRegion) {
        const k = `${i.name} [${i.w}x${i.h}]`;
        counted.set(k, (counted.get(k) || 0) + 1);
      }
      const rendered = [...counted.entries()].map(([k, n]) => (n > 1 ? `${k} x${n}` : k));
      console.log(`  ${r}: ${rendered.join(", ")}`);
    }

    if (texts.length) {
      const unique = [...new Set(texts)].slice(0, 12);
      console.log(`  text: ${unique.map((t) => JSON.stringify(t)).join(", ")}`);
    }
  }
}
