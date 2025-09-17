;; TeachShare - Educational Content Marketplace with Automatic Royalty Distribution
;; A decentralized marketplace where teachers can monetize educational materials

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-invalid-price (err u105))
(define-constant err-invalid-input (err u106))

;; Data Variables
(define-data-var platform-fee-percentage uint u5) ;; 5% platform fee
(define-data-var next-content-id uint u1)

;; Data Maps
(define-map educational-content
  { content-id: uint }
  {
    teacher: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    price: uint,
    royalty-percentage: uint,
    total-sales: uint,
    is-active: bool
  }
)

(define-map content-purchases
  { buyer: principal, content-id: uint }
  { purchased-at: uint, price-paid: uint }
)

(define-map teacher-earnings
  { teacher: principal }
  { total-earned: uint, total-withdrawn: uint }
)

;; Read-only functions
(define-read-only (get-content-details (content-id uint))
  (map-get? educational-content { content-id: content-id })
)

(define-read-only (get-purchase-details (buyer principal) (content-id uint))
  (map-get? content-purchases { buyer: buyer, content-id: content-id })
)

(define-read-only (get-teacher-earnings (teacher principal))
  (default-to 
    { total-earned: u0, total-withdrawn: u0 }
    (map-get? teacher-earnings { teacher: teacher })
  )
)

(define-read-only (has-purchased-content (buyer principal) (content-id uint))
  (is-some (map-get? content-purchases { buyer: buyer, content-id: content-id }))
)

(define-read-only (get-platform-fee-percentage)
  (var-get platform-fee-percentage)
)

(define-read-only (get-next-content-id)
  (var-get next-content-id)
)

;; Private functions
(define-private (calculate-platform-fee (price uint))
  (/ (* price (var-get platform-fee-percentage)) u100)
)

(define-private (calculate-teacher-payout (price uint))
  (- price (calculate-platform-fee price))
)

;; Public functions
(define-public (create-educational-content 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (price uint)
  (royalty-percentage uint))
  (let
    (
      (content-id (var-get next-content-id))
      (validated-title (unwrap! (as-max-len? title u100) err-invalid-input))
      (validated-description (unwrap! (as-max-len? description u500) err-invalid-input))
    )
    (asserts! (> price u0) err-invalid-price)
    (asserts! (<= royalty-percentage u100) err-invalid-price)
    (asserts! (> (len validated-title) u0) err-invalid-input)
    (asserts! (> (len validated-description) u0) err-invalid-input)

    (map-set educational-content
      { content-id: content-id }
      {
        teacher: tx-sender,
        title: validated-title,
        description: validated-description,
        price: price,
        royalty-percentage: royalty-percentage,
        total-sales: u0,
        is-active: true
      }
    )

    (var-set next-content-id (+ content-id u1))
    (ok content-id)
  )
)

(define-public (purchase-content (content-id uint))
  (let
    (
      (content-details (unwrap! (get-content-details content-id) err-not-found))
      (price (get price content-details))
      (teacher (get teacher content-details))
      (platform-fee (calculate-platform-fee price))
      (payout-amount (calculate-teacher-payout price))
      (current-earnings (get-teacher-earnings teacher))
    )
    (asserts! (get is-active content-details) err-not-found)
    (asserts! (not (has-purchased-content tx-sender content-id)) err-already-exists)

    ;; Transfer STX from buyer to contract
    (try! (stx-transfer? price tx-sender (as-contract tx-sender)))

    ;; Record the purchase
    (map-set content-purchases
      { buyer: tx-sender, content-id: content-id }
      { purchased-at: block-height, price-paid: price }
    )

    ;; Update content sales count
    (map-set educational-content
      { content-id: content-id }
      (merge content-details { total-sales: (+ (get total-sales content-details) u1) })
    )

    ;; Update teacher earnings
    (map-set teacher-earnings
      { teacher: teacher }
      {
        total-earned: (+ (get total-earned current-earnings) payout-amount),
        total-withdrawn: (get total-withdrawn current-earnings)
      }
    )

    (ok true)
  )
)

(define-public (withdraw-earnings)
  (let
    (
      (earnings-data (get-teacher-earnings tx-sender))
      (available-amount (- (get total-earned earnings-data) (get total-withdrawn earnings-data)))
    )
    (asserts! (> available-amount u0) err-insufficient-funds)

    ;; Transfer earnings to teacher
    (try! (as-contract (stx-transfer? available-amount tx-sender tx-sender)))

    ;; Update withdrawn amount
    (map-set teacher-earnings
      { teacher: tx-sender }
      {
        total-earned: (get total-earned earnings-data),
        total-withdrawn: (get total-earned earnings-data)
      }
    )

    (ok available-amount)
  )
)

(define-public (deactivate-content (content-id uint))
  (let
    (
      (content-details (unwrap! (get-content-details content-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get teacher content-details)) err-unauthorized)

    (map-set educational-content
      { content-id: content-id }
      (merge content-details { is-active: false })
    )

    (ok true)
  )
)

(define-public (update-platform-fee (new-fee-percentage uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee-percentage u20) err-invalid-price) ;; Max 20% fee
    (var-set platform-fee-percentage new-fee-percentage)
    (ok true)
  )
)

(define-public (withdraw-platform-fees)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let
      (
        (contract-balance (stx-get-balance (as-contract tx-sender)))
      )
      (try! (as-contract (stx-transfer? contract-balance tx-sender contract-owner)))
      (ok contract-balance)
    )
  )
)