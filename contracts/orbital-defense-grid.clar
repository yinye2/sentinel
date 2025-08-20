;; Orbital Defense Grid - Space Weather Infrastructure Protection Contract
(define-map protected-assets
  { asset-id: (string-ascii 50) }
  {
    asset-designation: (string-utf8 100),
    asset-category: (string-ascii 50),
    orbital-position: (string-utf8 100),
    radiation-tolerance: uint
  }
)

(define-map protective-protocols
  { protocol-id: uint }
  {
    asset-id: (string-ascii 50),
    triggering-event-id: uint,
    protocol-type: (string-ascii 50),
    activation-timestamp: uint,
    execution-status: (string-ascii 20)
  }
)

(define-data-var protocol-sequence uint u0)

(define-public (register-protected-asset 
  (id (string-ascii 50)) 
  (asset-designation (string-utf8 100)) 
  (asset-category (string-ascii 50)) 
  (orbital-position (string-utf8 100)) 
  (radiation-tolerance uint))
  (ok (map-set protected-assets
    { asset-id: id }
    {
      asset-designation: asset-designation,
      asset-category: asset-category,
      orbital-position: orbital-position,
      radiation-tolerance: radiation-tolerance
    }
  ))
)

(define-public (activate-protective-protocol 
  (asset-id (string-ascii 50)) 
  (triggering-event-id uint) 
  (protocol-type (string-ascii 50)))
  (let
    (
      (new-protocol-id (+ (var-get protocol-sequence) u1))
    )
    (asserts! (is-some (map-get? protected-assets { asset-id: asset-id })) (err u404))
    (map-set protective-protocols
      { protocol-id: new-protocol-id }
      {
        asset-id: asset-id,
        triggering-event-id: triggering-event-id,
        protocol-type: protocol-type,
        activation-timestamp: block-height,
        execution-status: "initiated"
      }
    )
    (var-set protocol-sequence new-protocol-id)
    (ok new-protocol-id)
  )
)

(define-public (update-protocol-status 
  (protocol-id uint) 
  (new-status (string-ascii 20)))
  (let
    (
      (protocol (unwrap! (map-get? protective-protocols { protocol-id: protocol-id }) (err u404)))
    )
    (ok (map-set protective-protocols
      { protocol-id: protocol-id }
      (merge protocol { execution-status: new-status })
    ))
  )
)

(define-read-only (get-protected-asset (id (string-ascii 50)))
  (ok (map-get? protected-assets { asset-id: id }))
)

(define-read-only (get-protective-protocol (protocol-id uint))
  (ok (map-get? protective-protocols { protocol-id: protocol-id }))
)

(define-read-only (get-protocol-sequence-count)
  (ok (var-get protocol-sequence))
)