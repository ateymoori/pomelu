// Builds assets/bot_screen/screen.html: screen.js and noVNC bundled into one
// inline module script (the page imports nothing, so no web view has to load
// a module from the app's files), plus the notices of what it bundles.
//
//   cd tool/bot_screen && npm ci && node build.mjs

import { build } from 'esbuild';
import { readFile, writeFile } from 'node:fs/promises';

const here = (path) => new URL(path, import.meta.url);
const out = (path) => new URL(`../../assets/bot_screen/${path}`, import.meta.url);
const novnc = (path) => here(`node_modules/@novnc/novnc/${path}`);

const bundle = await build({
  entryPoints: [here('screen.js').pathname],
  bundle: true,
  minify: true,
  format: 'esm',
  target: ['chrome100', 'safari15'],
  legalComments: 'none',
  write: false,
});
const script = bundle.outputFiles[0].text.replaceAll('</script', '<\\/script');
const page = (await readFile(here('screen.html'), 'utf8')).replace('/*SCREEN_JS*/', () => script);
await writeFile(out('screen.html'), page);

const notices = [
  await readFile(novnc('LICENSE.txt'), 'utf8'),
  await readFile(novnc('docs/LICENSE.MPL-2.0'), 'utf8'),
  await readFile(novnc('docs/LICENSE.BSD-3-Clause'), 'utf8'),
  await readFile(novnc('docs/LICENSE.BSD-2-Clause'), 'utf8'),
];
await writeFile(out('noVNC-LICENSE.txt'), notices.join('\n\n'));
await writeFile(out('pako-LICENSE.txt'), await readFile(novnc('vendor/pako/LICENSE'), 'utf8'));

console.log(`assets/bot_screen/screen.html: ${(page.length / 1024).toFixed(0)} KiB`);
