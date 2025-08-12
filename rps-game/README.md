# Rock-Paper-Scissors Game (Commit-Reveal) on Stacks Blockchain

## 📌 Overview
This is a two-player Rock-Paper-Scissors game implemented in **Clarity** using the **commit–reveal scheme** to prevent cheating.  
Players first commit to a hashed move, then later reveal their move with a secret nonce to prove it matches the commit.

---

## 🎯 Game Flow
1. **Create Game** – Player 1 creates a game with a unique `game-id`.
2. **Join Game** – Player 2 joins the game.
3. **Commit Phase** – Both players submit a `commit` (SHA256 hash of `"<move>:<nonce>"`).
4. **Reveal Phase** – Each player reveals their `preimage` and declared move.
5. **Winner Determination** – Once both players reveal, the contract determines the winner.

---

## 🔒 Commit–Reveal Scheme
- **Commit**: `sha256("<move>:<nonce>")`
  - Example: `sha256("0:random123")`
  - `0` = Rock, `1` = Paper, `2` = Scissors
  - `nonce` is a secret random string to prevent guessing.
- **Reveal**: Provide the preimage (`"<move>:<nonce>"`) to verify the commit.

---

## 🛠 Setup Instructions

### 1️⃣ Install Dependencies
Make sure you have:
- [Clarinet](https://docs.hiro.so/clarinet/getting-started) installed
- Node.js (for helper script)

```bash
clarinet --version
2️⃣ Initialize Project
bash
Copy
Edit
clarinet new rps-game
cd rps-game
3️⃣ Add Contract
Place the smart contract in:

bash
Copy
Edit
contracts/rock-paper-scissors.clar
4️⃣ Commit Helper Script
Use the helper script to generate commit hashes:

bash
Copy
Edit
node scripts/make_commit.js <move> <nonce>
Example:

bash
Copy
Edit
node scripts/make_commit.js 0 secret123
5️⃣ Testing
Run all tests:

bash
Copy
Edit
clarinet test
📂 Project Structure
bash
Copy
Edit
rps-game/
│
├─ Clarinet.toml                # Clarinet configuration
├─ README.md                     # Project documentation
├─ contracts/
│  └─ rock-paper-scissors.clar   # Smart contract
├─ scripts/
│  └─ make_commit.js             # Commit hash generator
├─ tests/
│  └─ rps_test.ts                # Clarinet tests
└─ .gitignore
⚠ Security Notes
Players must use a secure random nonce.

Preimage parsing in the contract should ensure the declared move matches the one in the preimage.

Consider adding timeouts & forfeits for non-reveals.
