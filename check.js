const fs = require('fs');
const parser = require('@babel/parser');

const code = fs.readFileSync('apps/web/app/(dashboard)/reports/page.tsx', 'utf8');

try {
  parser.parse(code, {
    sourceType: 'module',
    plugins: ['jsx', 'typescript']
  });
  console.log("No syntax errors found!");
} catch (e) {
  console.error(e.message);
  console.log("Line:", e.loc?.line, "Col:", e.loc?.column);
}
