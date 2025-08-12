;; Simple leaderboard contract
;; Owner sets an authorized caller (main game contract principal) who may record wins.
(define-data-var owner (optional principal) none)
(define-data-var authorized (optional principal) none)
;; Renamed map from 'wins' to 'player-wins' to avoid function name conflicts
(define-map player-wins
  {player: principal}
  {wins: uint}
)

(define-public (init-owner)
  (if (is-none (var-get owner))
      (begin
        (var-set owner (some tx-sender))
        (ok true)
      )
      (err u100)
  )
)

(define-public (set-authorized (who principal))
  (match (var-get owner)
    o
    (if (is-eq tx-sender o)
        (begin
          (var-set authorized (some who))
          (ok true)
        )
        (err u101)
    )
    (err u103) ;; owner not set
  )
)

(define-public (record-win (player principal))
  (match (var-get authorized)
    auth
    (if (is-eq tx-sender auth)
        (let ((existing (map-get? player-wins {player: player})))
          (if (is-some existing)
              (let ((curr (get wins (unwrap-panic existing))))
                (map-set player-wins {player: player} {wins: (+ curr u1)})
                (ok true)
              )
              (begin
                (map-set player-wins {player: player} {wins: u1})
                (ok true)
              )
          )
        )
        (err u101) ;; not authorized caller
    )
    (err u103) ;; no authorized caller set
  )
)

(define-read-only (get-wins (player principal))
  (match (map-get? player-wins {player: player})
    r (ok (get wins r))
    (ok u0)
  )
)
