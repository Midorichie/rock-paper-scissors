(define-data-var player1 (optional principal) none)
(define-data-var player2 (optional principal) none)
(define-data-var player1-move (optional uint) none)
(define-data-var player2-move (optional uint) none)

;; 1 = rock, 2 = paper, 3 = scissors

(define-public (register-player)
  (begin
    (if (is-none (var-get player1))
      (begin
        (var-set player1 (some tx-sender))
        (ok "Registered as Player 1"))
      (if (is-none (var-get player2))
        (begin
          (var-set player2 (some tx-sender))
          (ok "Registered as Player 2"))
        (err "Game already has two players")
      )
    )
  )
)

(define-public (make-move (move uint))
  (begin
    (if (or (< move u1) (> move u3))
      (err "Invalid move")
      (if (is-eq (some tx-sender) (var-get player1))
        (begin
          (var-set player1-move (some move))
          (ok "Player 1 move set"))
        (if (is-eq (some tx-sender) (var-get player2))
          (begin
            (var-set player2-move (some move))
            (ok "Player 2 move set"))
          (err "You are not a registered player")
        )
      )
    )
  )
)

(define-private (determine-winner (move1 uint) (move2 uint))
  (if (is-eq move1 move2)
    0
    (if (or (and (is-eq move1 u1) (is-eq move2 u3))
            (and (is-eq move1 u2) (is-eq move2 u1))
            (and (is-eq move1 u3) (is-eq move2 u2)))
      1
      2
    )
  )
)

(define-public (reveal-winner)
  (begin
    (if (or (is-none (var-get player1-move)) (is-none (var-get player2-move)))
      (err "Both players must make a move first")
      (let
        (
          (p1-move (unwrap! (var-get player1-move) (err "No move for player 1")))
          (p2-move (unwrap! (var-get player2-move) (err "No move for player 2")))
        )
        (ok (determine-winner p1-move p2-move))
      )
    )
  )
)
