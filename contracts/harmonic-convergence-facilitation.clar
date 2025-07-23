;; Harmonic Convergence Facilitation Contract
;; Organizes global meditation and frequency alignment events

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-PARAMETERS (err u501))
(define-constant ERR-EVENT-NOT-FOUND (err u502))
(define-constant ERR-INSUFFICIENT-PARTICIPANTS (err u503))
(define-constant ERR-EVENT-ACTIVE (err u504))

;; Data Variables
(define-data-var convergence-counter uint u0)
(define-data-var global-alignment-score uint u0)
(define-data-var total-convergence-energy uint u0)

;; Data Maps
(define-map convergence-events
  { event-id: uint }
  {
    facilitator: principal,
    event-name: (string-ascii 100),
    alignment-frequency: uint,
    global-coordinates: (string-ascii 50),
    start-timestamp: uint,
    duration-hours: uint,
    participant-threshold: uint,
    current-participants: uint,
    convergence-status: uint,
    collective-energy: uint,
    planetary-impact: uint
  }
)

(define-map event-registrations
  { event-id: uint, participant: principal }
  {
    meditation-level: uint,
    energy-commitment: uint,
    location-coordinates: (string-ascii 50),
    participation-confirmed: bool,
    energy-contributed: uint
  }
)

(define-map facilitator-credentials
  { facilitator: principal }
  {
    events-facilitated: uint,
    total-participants-reached: uint,
    convergence-success-rate: uint,
    global-impact-score: uint,
    spiritual-authority: uint,
    active-status: bool
  }
)

(define-map global-alignment-records
  { alignment-date: uint }
  {
    simultaneous-events: uint,
    total-global-participants: uint,
    peak-alignment-frequency: uint,
    planetary-resonance: uint,
    consciousness-elevation: uint
  }
)

;; Public Functions

;; Register as convergence facilitator
(define-public (register-facilitator (spiritual-authority uint))
  (begin
    (asserts! (and (>= spiritual-authority u1) (<= spiritual-authority u100)) ERR-INVALID-PARAMETERS)
    (map-set facilitator-credentials
      { facilitator: tx-sender }
      {
        events-facilitated: u0,
        total-participants-reached: u0,
        convergence-success-rate: u100,
        global-impact-score: u0,
        spiritual-authority: spiritual-authority,
        active-status: true
      }
    )
    (ok true)
  )
)

;; Create convergence event
(define-public (create-convergence-event
  (event-name (string-ascii 100))
  (alignment-frequency uint)
  (global-coordinates (string-ascii 50))
  (start-timestamp uint)
  (duration-hours uint)
  (participant-threshold uint))
  (let
    (
      (event-id (+ (var-get convergence-counter) u1))
      (facilitator-data (unwrap! (map-get? facilitator-credentials { facilitator: tx-sender }) ERR-NOT-AUTHORIZED))
    )
    (asserts! (get active-status facilitator-data) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= alignment-frequency u1) (<= alignment-frequency u1000)) ERR-INVALID-PARAMETERS)
    (asserts! (> start-timestamp block-height) ERR-INVALID-PARAMETERS)
    (asserts! (and (> duration-hours u0) (<= duration-hours u72)) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= participant-threshold u10) (<= participant-threshold u100000)) ERR-INVALID-PARAMETERS)

    (map-set convergence-events
      { event-id: event-id }
      {
        facilitator: tx-sender,
        event-name: event-name,
        alignment-frequency: alignment-frequency,
        global-coordinates: global-coordinates,
        start-timestamp: start-timestamp,
        duration-hours: duration-hours,
        participant-threshold: participant-threshold,
        current-participants: u0,
        convergence-status: u0,
        collective-energy: u0,
        planetary-impact: u0
      }
    )

    (map-set facilitator-credentials
      { facilitator: tx-sender }
      (merge facilitator-data { events-facilitated: (+ (get events-facilitated facilitator-data) u1) })
    )

    (var-set convergence-counter event-id)
    (ok event-id)
  )
)

;; Register for convergence event
(define-public (register-for-convergence
  (event-id uint)
  (meditation-level uint)
  (energy-commitment uint)
  (location-coordinates (string-ascii 50)))
  (let
    (
      (event-data (unwrap! (map-get? convergence-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
    )
    (asserts! (is-eq (get convergence-status event-data) u0) ERR-EVENT-ACTIVE)
    (asserts! (and (>= meditation-level u1) (<= meditation-level u10)) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= energy-commitment u1) (<= energy-commitment u1000)) ERR-INVALID-PARAMETERS)

    (map-set event-registrations
      { event-id: event-id, participant: tx-sender }
      {
        meditation-level: meditation-level,
        energy-commitment: energy-commitment,
        location-coordinates: location-coordinates,
        participation-confirmed: false,
        energy-contributed: u0
      }
    )

    (map-set convergence-events
      { event-id: event-id }
      (merge event-data { current-participants: (+ (get current-participants event-data) u1) })
    )

    (ok true)
  )
)

;; Confirm participation and energy contribution
(define-public (confirm-participation (event-id uint) (energy-contributed uint))
  (let
    (
      (registration-data (unwrap! (map-get? event-registrations { event-id: event-id, participant: tx-sender }) ERR-NOT-AUTHORIZED))
      (event-data (unwrap! (map-get? convergence-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
    )
    (asserts! (and (>= block-height (get start-timestamp event-data))
                   (<= block-height (+ (get start-timestamp event-data) (* (get duration-hours event-data) u6)))) ERR-INVALID-PARAMETERS)
    (asserts! (<= energy-contributed (get energy-commitment registration-data)) ERR-INVALID-PARAMETERS)

    (map-set event-registrations
      { event-id: event-id, participant: tx-sender }
      (merge registration-data {
        participation-confirmed: true,
        energy-contributed: energy-contributed
      })
    )

    (map-set convergence-events
      { event-id: event-id }
      (merge event-data { collective-energy: (+ (get collective-energy event-data) energy-contributed) })
    )

    (ok true)
  )
)

;; Activate convergence event
(define-public (activate-convergence (event-id uint))
  (let
    (
      (event-data (unwrap! (map-get? convergence-events { event-id: event-id }) ERR-EVENT-NOT-FOUND))
      (facilitator-data (unwrap! (map-get? facilitator-credentials { facilitator: tx-sender }) ERR-NOT-AUTHORIZED))
    )
    (asserts! (is-eq (get facilitator event-data) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (>= (get current-participants event-data) (get participant-threshold event-data)) ERR-INSUFFICIENT-PARTICIPANTS)
    (asserts! (is-eq (get convergence-status event-data) u0) ERR-EVENT-ACTIVE)

    (let
      (
        (planetary-impact (* (get current-participants event-data) (get alignment-frequency event-data)))
      )
      (map-set convergence-events
        { event-id: event-id }
        (merge event-data {
          convergence-status: u1,
          planetary-impact: planetary-impact
        })
      )

      (map-set facilitator-credentials
        { facilitator: tx-sender }
        (merge facilitator-data {
          total-participants-reached: (+ (get total-participants-reached facilitator-data) (get current-participants event-data)),
          global-impact-score: (+ (get global-impact-score facilitator-data) planetary-impact)
        })
      )

      (var-set global-alignment-score (+ (var-get global-alignment-score) planetary-impact))
      (var-set total-convergence-energy (+ (var-get total-convergence-energy) (get collective-energy event-data)))

      (ok planetary-impact)
    )
  )
)

;; Record global alignment data
(define-public (record-global-alignment
  (alignment-date uint)
  (simultaneous-events uint)
  (peak-alignment-frequency uint)
  (consciousness-elevation uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (and (> simultaneous-events u0) (<= simultaneous-events u1000)) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= peak-alignment-frequency u1) (<= peak-alignment-frequency u1000)) ERR-INVALID-PARAMETERS)
    (asserts! (and (>= consciousness-elevation u1) (<= consciousness-elevation u100)) ERR-INVALID-PARAMETERS)

    (map-set global-alignment-records
      { alignment-date: alignment-date }
      {
        simultaneous-events: simultaneous-events,
        total-global-participants: (var-get total-convergence-energy),
        peak-alignment-frequency: peak-alignment-frequency,
        planetary-resonance: (* simultaneous-events peak-alignment-frequency),
        consciousness-elevation: consciousness-elevation
      }
    )
    (ok true)
  )
)

;; Read-only Functions

(define-read-only (get-convergence-event (event-id uint))
  (map-get? convergence-events { event-id: event-id })
)

(define-read-only (get-event-registration (event-id uint) (participant principal))
  (map-get? event-registrations { event-id: event-id, participant: participant })
)

(define-read-only (get-facilitator-credentials (facilitator principal))
  (map-get? facilitator-credentials { facilitator: facilitator })
)

(define-read-only (get-global-alignment-record (alignment-date uint))
  (map-get? global-alignment-records { alignment-date: alignment-date })
)

(define-read-only (get-total-convergence-events)
  (var-get convergence-counter)
)

(define-read-only (get-global-alignment-score)
  (var-get global-alignment-score)
)

(define-read-only (get-total-convergence-energy)
  (var-get total-convergence-energy)
)

(define-read-only (calculate-planetary-consciousness-level)
  (let
    (
      (total-events (var-get convergence-counter))
      (total-alignment (var-get global-alignment-score))
      (total-energy (var-get total-convergence-energy))
    )
    (if (> total-events u0)
      (some (/ (+ total-alignment total-energy) (* total-events u100)))
      none
    )
  )
)
