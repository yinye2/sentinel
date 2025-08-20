;; Magnetosphere Monitor - Space Weather Data Collection Contract
(define-map sensor-stations
  { station-id: (string-ascii 50) }
  {
    station-name: (string-utf8 100),
    geographic-coordinates: (string-utf8 100),
    measurement-category: (string-ascii 50),
    most-recent-update: uint
  }
)

(define-map telemetry-records
  { record-id: uint }
  {
    station-id: (string-ascii 50),
    capture-timestamp: uint,
    data-fingerprint: (buff 32),
    measurement-type: (string-ascii 50)
  }
)

(define-data-var telemetry-count uint u0)

(define-public (register-sensor-station 
  (id (string-ascii 50)) 
  (station-name (string-utf8 100)) 
  (geographic-coordinates (string-utf8 100)) 
  (measurement-category (string-ascii 50)))
  (ok (map-set sensor-stations
    { station-id: id }
    {
      station-name: station-name,
      geographic-coordinates: geographic-coordinates,
      measurement-category: measurement-category,
      most-recent-update: u0
    }
  ))
)

(define-public (submit-telemetry-data 
  (station-id (string-ascii 50)) 
  (data-fingerprint (buff 32)) 
  (measurement-type (string-ascii 50)))
  (let
    (
      (new-record-id (+ (var-get telemetry-count) u1))
    )
    (map-set telemetry-records
      { record-id: new-record-id }
      {
        station-id: station-id,
        capture-timestamp: block-height,
        data-fingerprint: data-fingerprint,
        measurement-type: measurement-type
      }
    )
    (map-set sensor-stations
      { station-id: station-id }
      (merge (unwrap! (map-get? sensor-stations { station-id: station-id }) (err u404))
        { most-recent-update: block-height }
      )
    )
    (var-set telemetry-count new-record-id)
    (ok new-record-id)
  )
)

(define-read-only (get-sensor-station-info (id (string-ascii 50)))
  (ok (map-get? sensor-stations { station-id: id }))
)

(define-read-only (get-telemetry-record (record-id uint))
  (ok (map-get? telemetry-records { record-id: record-id }))
)

(define-read-only (get-telemetry-count)
  (ok (var-get telemetry-count))
)