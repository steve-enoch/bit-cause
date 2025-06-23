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