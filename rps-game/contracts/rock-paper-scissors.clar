(define-data-var game-counter uint u0)
(define-map games
  {id: uint}
  {
    player1: principal,
    player2: (optional principal),
    move1: (optional uint),
    move2: (optional uint),
    stake: uint,
    status: uint ;; 0 = pending, 1 = active, 2 = completed, 3 = forfeited
  }
)

(define-constant MOVE_ROCK u0)
(define-constant MOVE_PAPER u1)
(define-constant MOVE_SCISSORS u2)

(define-constant STATUS_PENDING u0)
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_COMPLETED u2)
(define-constant STATUS_FORFEITED u3)

(define-constant ERR_INVALID_MOVE (err u100))
(define-constant ERR_NOT_PLAYER (err u101))
(define-constant ERR_ALREADY_JOINED (err u102))
(define-constant ERR_GAME_NOT_PENDING (err u103))
(define-constant ERR_GAME_NOT_ACTIVE (err u104))
(define-constant ERR_MOVE_ALREADY_MADE (err u105))
(define-constant ERR_NOT_YOUR_TURN (err u106))

(define-public (create-game (stake uint) (move uint))
  (begin
    (if (not (is-valid-move? move))
      ERR_INVALID_MOVE
      (let (
          (game-id (+ (var-get game-counter) u1))
        )
        (var-set game-counter game-id)
        (map-set games {id: game-id}
          {
            player1: tx-sender,
            player2: none,
            move1: (some move),
            move2: none,
            stake: stake,
            status: STATUS_PENDING
          }
        )
        (ok game-id)
      )
    )
  )
)

(define-public (join-game (game-id uint) (move uint))
  (begin
    (if (not (is-valid-move? move))
      ERR_INVALID_MOVE
      (match (map-get? games {id: game-id})
        game-data
        (if (or (is-some (get player2 game-data)) (not (is-eq (get status game-data) STATUS_PENDING)))
          ERR_GAME_NOT_PENDING
          (begin
            (map-set games {id: game-id}
              {
                player1: (get player1 game-data),
                player2: (some tx-sender),
                move1: (get move1 game-data),
                move2: (some move),
                stake: (get stake game-data),
                status: STATUS_ACTIVE
              }
            )
            (ok true)
          )
        )
        (err u404)
      )
    )
  )
)

(define-public (reveal-result (game-id uint))
  (match (map-get? games {id: game-id})
    game-data
    (if (not (is-eq (get status game-data) STATUS_ACTIVE))
      ERR_GAME_NOT_ACTIVE
      (begin
        (let (
            (winner (determine-winner (unwrap-panic (get move1 game-data)) (unwrap-panic (get move2 game-data)) (get player1 game-data) (unwrap-panic (get player2 game-data))))
          )
          (map-set games {id: game-id}
            {
              player1: (get player1 game-data),
              player2: (get player2 game-data),
              move1: (get move1 game-data),
              move2: (get move2 game-data),
              stake: (get stake game-data),
              status: STATUS_COMPLETED
            }
          )
          (ok winner)
        )
      )
    )
    (err u404)
  )
)

(define-public (forfeit (game-id uint))
  (match (map-get? games {id: game-id})
    game-data
    (if (not (or (is-eq (get player1 game-data) tx-sender) (is-eq (unwrap-panic (get player2 game-data)) tx-sender)))
      ERR_NOT_PLAYER
      (begin
        (map-set games {id: game-id}
          {
            player1: (get player1 game-data),
            player2: (get player2 game-data),
            move1: (get move1 game-data),
            move2: (get move2 game-data),
            stake: (get stake game-data),
            status: STATUS_FORFEITED
          }
        )
        (ok true)
      )
    )
    (err u404)
  )
)

;; Helper to check valid moves
(define-private (is-valid-move? (move uint))
  (or (is-eq move MOVE_ROCK) (is-eq move MOVE_PAPER) (is-eq move MOVE_SCISSORS))
)

;; Helper to decide the winner
(define-private (determine-winner (move1 uint) (move2 uint) (player1 principal) (player2 principal))
  (if (is-eq move1 move2)
    none
    (if (or 
          (and (is-eq move1 MOVE_ROCK) (is-eq move2 MOVE_SCISSORS))
          (and (is-eq move1 MOVE_PAPER) (is-eq move2 MOVE_ROCK))
          (and (is-eq move1 MOVE_SCISSORS) (is-eq move2 MOVE_PAPER))
        )
      (some player1)
      (some player2)
    )
  )
)
