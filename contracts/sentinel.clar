;; Sentinel - Space Weather Alert System Contract
(define-map space-weather-events
  { event-id: uint }
  {
    phenomenon-type: (string-ascii 50),
    intensity-level: uint,
    detection-timestamp: uint,
    event-description: (string-utf8 500),
    monitoring-status: (string-ascii 20)
  }
)

(define-map observer-subscriptions
  { observer: principal }
  { minimum-intensity: uint }
)

(define-data-var total-events uint u0)

(define-public (register-space-weather-event 
  (phenomenon-type (string-ascii 50)) 
  (intensity-level uint) 
  (event-description (string-utf8 500)))
  (let
    (
      (new-event-id (+ (var-get total-events) u1))
    )
    (map-set space-weather-events
      { event-id: new-event-id }
      {
        phenomenon-type: phenomenon-type,
        intensity-level: intensity-level,
        detection-timestamp: block-height,
        event-description: event-description,
        monitoring-status: "active"
      }
    )
    (var-set total-events new-event-id)
    (ok new-event-id)
  )
)

(define-public (update-monitoring-status 
  (event-id uint) 
  (new-status (string-ascii 20)))
  (let
    (
      (weather-event (unwrap! (map-get? space-weather-events { event-id: event-id }) (err u404)))
    )
    (ok (map-set space-weather-events
      { event-id: event-id }
      (merge weather-event { monitoring-status: new-status })
    ))
  )
)

(define-public (subscribe-to-alerts (minimum-intensity uint))
  (ok (map-set observer-subscriptions
    { observer: tx-sender }
    { minimum-intensity: minimum-intensity }
  ))
)

(define-public (unsubscribe-from-alerts)
  (ok (map-delete observer-subscriptions { observer: tx-sender }))
)

(define-read-only (get-space-weather-event (event-id uint))
  (ok (map-get? space-weather-events { event-id: event-id }))
)

(define-read-only (get-observer-subscription (observer principal))
  (ok (map-get? observer-subscriptions { observer: observer }))
)

(define-read-only (get-total-event-count)
  (ok (var-get total-events))
)