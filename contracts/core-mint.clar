;; CoreMint NFT Contract
(define-non-fungible-token coremint-nft uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-token-exists (err u102))
(define-constant err-invalid-fee (err u103))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var minting-fee uint u1000000) ;; 1 STX
(define-data-var paused bool false)

;; Data Maps
(define-map token-metadata uint (string-utf8 256))
(define-map token-creators uint principal)

;; Public Functions
(define-public (mint-nft (metadata-uri (string-utf8 256)) (recipient principal))
  (let (
    (token-id (+ (var-get last-token-id) u1))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get paused)) (err u104))
    (asserts! (>= (stx-get-balance tx-sender) (var-get minting-fee)) err-invalid-fee)
    
    (try! (stx-transfer? (var-get minting-fee) tx-sender contract-owner))
    (try! (nft-mint? coremint-nft token-id recipient))
    (map-set token-metadata token-id metadata-uri)
    (map-set token-creators token-id tx-sender)
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer-nft (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (nft-transfer? coremint-nft token-id sender recipient)
  )
)

;; Read Only Functions
(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id))
)

(define-read-only (get-token-creator (token-id uint))
  (ok (map-get? token-creators token-id))
)

(define-read-only (get-minting-fee)
  (ok (var-get minting-fee))
)

;; Admin Functions
(define-public (set-minting-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set minting-fee new-fee)
    (ok new-fee)
  )
)

(define-public (toggle-pause)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set paused (not (var-get paused)))
    (ok (var-get paused))
  )
)
