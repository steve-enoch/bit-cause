;; Title: BitCause
;; 
;; Summary: Decentralized Philanthropic Hub with Milestone-Driven Transparency
;; 
;; Description: BitCause revolutionizes charitable giving by creating a trustless
;; ecosystem where donors can track their contributions with complete transparency.
;; Built on Stacks blockchain with Bitcoin's security, this platform eliminates
;; traditional charity overhead concerns through smart contract automation and
;; milestone-based fund releases. Every donation is immutably recorded, every
;; expenditure is verified, and every impact is measurable - creating the world's
;; first fully transparent charitable platform where trust is built into the code,
;; not dependent on institutions.

;; CONSTANTS AND ERROR CODES

;; Contract ownership
(define-data-var contract-owner principal tx-sender)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; Role hierarchy definitions
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; DATA STRUCTURES

;; User access control mapping
(define-map roles
    { user: principal }
    { role: uint }
)

;; Charitable organization/cause registry
(define-map beneficiaries
    { id: uint }
    {
        name: (string-utf8 50),
        description: (string-utf8 255),
        target-amount: uint,
        received-amount: uint,
        status: (string-ascii 20),
    }
)

;; Immutable donation ledger
(define-map donations
    { id: uint }
    {
        donor: principal,
        beneficiary-id: uint,
        amount: uint,
        timestamp: uint,
    }
)

;; Fund allocation and milestone tracking
(define-map utilization
    { id: uint }
    {
        beneficiary-id: uint,
        milestone: uint,
        description: (string-utf8 255),
        amount: uint,
        status: (string-ascii 20),
    }
)

;; STATE VARIABLES

;; Global ID counters
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; UTILITY FUNCTIONS

;; Verify user authorization level
(define-private (is-authorized
        (user principal)
        (required-role uint)
    )
    (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
        (>= (get role role-data) required-role)
    )
)

;; Calculate current milestone count for beneficiary
(define-private (get-last-milestone (beneficiary-id uint))
    (var-get utilization-count)
)

;; ACCESS CONTROL MANAGEMENT

;; Grant role permissions to users
(define-public (set-role
        (user principal)
        (new-role uint)
    )
    (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
        (if (and
                (is-eq tx-sender (var-get contract-owner))
                (<= new-role ROLE-BENEFICIARY)
                (not (is-eq user tx-sender))
                (or
                    (is-eq new-role ROLE-ADMIN)
                    (is-eq new-role ROLE-MODERATOR)
                    (is-eq new-role ROLE-BENEFICIARY)
                )
            )
            (ok (map-set roles { user: user } { role: new-role }))
            ERR-NOT-AUTHORIZED
        )
    )
)

;; Revoke user permissions
(define-public (remove-role (user principal))
    (if (and
            (is-eq tx-sender (var-get contract-owner))
            (is-some (map-get? roles { user: user }))
            (not (is-eq user tx-sender))
        )
        (ok (map-delete roles { user: user }))
        ERR-NOT-AUTHORIZED
    )
)

;; BENEFICIARY REGISTRY

;; Onboard new charitable causes
(define-public (register-beneficiary
        (name (string-utf8 50))
        (description (string-utf8 255))
        (target-amount uint)
    )
    (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
        (if (and
                (is-authorized tx-sender ROLE-MODERATOR)
                (> (len name) u0)
                (> (len description) u0)
                (> target-amount u0)
            )
            (begin
                (map-set beneficiaries { id: beneficiary-id } {
                    name: name,
                    description: description,
                    target-amount: target-amount,
                    received-amount: u0,
                    status: "active",
                })
                (var-set beneficiary-count beneficiary-id)
                (ok beneficiary-id)
            )
            ERR-INVALID-INPUT
        )
    )
)

;; Retrieve beneficiary details
(define-read-only (get-beneficiary (id uint))
    (match (map-get? beneficiaries { id: id })
        beneficiary (ok beneficiary)
        ERR-BENEFICIARY-NOT-FOUND
    )
)

;; DONATION PROCESSING

;; Process charitable contributions
(define-public (donate
        (beneficiary-id uint)
        (amount uint)
    )
    (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
        (if (and
                (> amount u0)
                (< beneficiary-id (+ (var-get beneficiary-count) u1))
                (is-some (map-get? beneficiaries { id: beneficiary-id }))
            )
            (match (stx-transfer? amount tx-sender (as-contract tx-sender))
                success (begin
                    (map-set beneficiaries { id: beneficiary-id }
                        (merge beneficiary { received-amount: (+ (get received-amount beneficiary) amount) })
                    )
                    (map-set donations { id: (+ (var-get donation-count) u1) } {
                        donor: tx-sender,
                        beneficiary-id: beneficiary-id,
                        amount: amount,
                        timestamp: stacks-block-height,
                    })
                    (var-set donation-count (+ (var-get donation-count) u1))
                    (ok true)
                )
                error
                ERR-INSUFFICIENT-FUNDS
            )
            ERR-INVALID-INPUT
        )
    )
)

;; Query donation transaction details
(define-read-only (get-donation-by-id (donation-id uint))
    (match (map-get? donations { id: donation-id })
        donation (ok donation)
        ERR-NOT-FOUND
    )
)

;; Get total donation transaction count
(define-read-only (get-donation-count)
    (ok (var-get donation-count))
)

;; FUND UTILIZATION TRACKING

;; Create fund allocation milestones
(define-public (add-utilization
        (beneficiary-id uint)
        (description (string-utf8 255))
        (amount uint)
    )
    (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
        (if (and
                (is-authorized tx-sender ROLE-ADMIN)
                (> (len description) u0)
                (> amount u0)
                (< beneficiary-id (+ (var-get beneficiary-count) u1))
            )
            (let (
                    (milestone (+ (get-last-milestone beneficiary-id) u1))
                    (utilization-id (+ (var-get utilization-count) u1))
                )
                (begin
                    (map-set utilization { id: utilization-id } {
                        beneficiary-id: beneficiary-id,
                        milestone: milestone,
                        description: description,
                        amount: amount,
                        status: "pending",
                    })
                    (var-set utilization-count utilization-id)
                    (ok milestone)
                )
            )
            ERR-INVALID-INPUT
        )
    )
)