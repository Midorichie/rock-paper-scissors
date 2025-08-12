# Rock-Paper-Scissors (Commit-Reveal) — Phase 2

## What's new in Phase 2
- Fixed earlier parsing & syntax bugs.
- Best-of-N rounds (odd N; default example is 3).
- Commit-reveal per round with preimage verification.
- Timeout / forfeit mechanism.
- Leaderboard contract to record wins (authorized caller pattern).
- Improved security checks: only registered players may commit/reveal; preimage vs commit verified on-chain.

## Usage (quick)
1. `clarinet check` — ensure contracts compile.
2. Deploy both contracts (or use Clarinet test environment).
3. In `leaderboard`:
   - call `init-owner` with your key.
   - call `set-authorized <principal-of-game-contract>` to allow the game contract to record wins.
4. In `rock-paper-scissors`:
   - Player1: `create-game <id> <player2-principal> <rounds>`
   - Both players: `submit-commit <id> <commit>` where `commit = sha256(preimage)` and `preimage` = `[1 byte move][nonce bytes]`.
     - Move encoding: `1` = rock, `2` = paper, `3` = scissors. Example preimage in Node: `Buffer.concat([Buffer.from([1]), Buffer.from("secret123")])`
   - Both players: `reveal <id> <preimage>` — will return revealed move on success (or error if mismatch)
   - Off-chain: after both reveals, call `finalize-round <id>` (or if you prefer, call modified finalize-round that reads stored decoded moves; ask me to switch)
   - When match completes, call leaderboard via the authorized caller flow (or have the game contract call it if you set it as authorized).

## Security notes
- Preimage must be secret until reveal. Use a secure random nonce.
- Commits are `sha256(preimage)` stored as `(buff 32)`.
- Use odd N (3,5) for best-of behavior.
- For production, consider adding STX staking and clear event logs; I can add escrow safely in a follow-up.

## References
- Clarity `slice?` / buffer utilities. :contentReference[oaicite:2]{index=2}
- Clarity `stx-transfer?` (for future escrow work). :contentReference[oaicite:3]{index=3}
