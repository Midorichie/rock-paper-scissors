// Node.js: make_commit.js
// Usage: node make_commit.js 0 my-secret-nonce
// Outputs hex sha256 and preimage used

const crypto = require('crypto');

const [,, move, nonce] = process.argv;
if (!move || !nonce) {
  console.error('Usage: node make_commit.js <move-number> <nonce>');
  process.exit(1);
}

const preimage = `${move}:${nonce}`; // pick format and match contract parser
const hash = crypto.createHash('sha256').update(preimage, 'utf8').digest('hex');
console.log('preimage:', preimage);
console.log('commit (hex):', hash);
console.log('commit (buff 32) hex literal for clarity:', hash);
