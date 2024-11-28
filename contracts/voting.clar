;; Decentralized Voting System Smart Contract

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_ALREADY_VOTED (err u101))
(define-constant ERR_INVALID_VOTE (err u102))
(define-constant ERR_VOTING_CLOSED (err u103))
(define-constant ERR_REGISTRATION_CLOSED (err u104))
(define-constant ERR_NOT_REGISTERED (err u105))
(define-constant ERR_INVALID_TIME (err u106))
(define-constant ERR_INVALID_PROPOSAL (err u107))
(define-constant ERR_PROPOSAL_EXPIRED (err u108))
(define-constant ERR_INSUFFICIENT_STAKE (err u109))
(define-constant ERR_EMERGENCY_STOPPED (err u110))
(define-constant ERR_INVALID_QUORUM (err u111))
(define-constant MINIMUM_STAKE u1000000)
(define-constant QUORUM_PERCENTAGE u51)

;; Define data variables
(define-data-var voting-open bool true)
(define-data-var total-votes uint u0)
(define-data-var registration-open bool true)
(define-data-var voting-start-time uint u0)
(define-data-var voting-end-time uint u0)
(define-data-var minimum-votes uint u1)
(define-data-var emergency-stop bool false)
(define-data-var proposal-count uint u0)
(define-data-var quorum-votes uint u0)
(define-data-var current-round uint u1)

;; Define data maps
(define-map votes principal uint)
(define-map candidates
  uint
  {name: (string-utf8 50), vote-count: uint}
)
(define-map registered-voters principal bool)
(define-map voter-registry
    principal
    {
        registered-at: uint,
        voter-id: (string-utf8 50),
        weight: uint  ;; For weighted voting if needed
    }
)
(define-map proposals 
    uint 
    {
        title: (string-utf8 100),
        description: (string-utf8 500),
        proposer: principal,
        created-at: uint,
        expires-at: uint,
        status: (string-utf8 20),
        required-stake: uint,
        vote-count-yes: uint,
        vote-count-no: uint,
        executed: bool
    }
)

(define-map vote-records
    {voter: principal, proposal-id: uint}
    {
        vote: bool,  ;; true for yes, false for no
        weight: uint,
        timestamp: uint,
        delegate: (optional principal)
    }
)

(define-map delegations
    principal  ;; delegator
    {
        delegate: principal,
        expires-at: uint,
        restrictions: (list 10 uint)  ;; proposal IDs that can't be delegated
    }
)

;; Read-only functions

(define-read-only (get-vote-count (candidate-id uint))
  (match (map-get? candidates candidate-id)
    candidate (ok (get vote-count candidate))
    (err u404) ;; Candidate not found
  )
)

(define-read-only (get-total-votes)
  (ok (var-get total-votes))
)

(define-read-only (has-voted (voter principal))
  (is-some (map-get? votes voter))
)

(define-read-only (is-voting-open)
  (ok (var-get voting-open))
)

(define-read-only (get-candidate (candidate-id uint))
  (ok (map-get? candidates candidate-id))
)

(define-read-only (get-voter-info (voter principal))
    (ok (map-get? voter-registry voter))
)

(define-read-only (is-registered (voter principal))
    (default-to false (map-get? registered-voters voter))
)

(define-read-only (get-proposal (proposal-id uint))
    (ok (map-get? proposals proposal-id))
)

(define-read-only (get-delegation-info (delegator principal))
    (ok (map-get? delegations delegator))
)

(define-read-only (get-vote-record (voter principal) (proposal-id uint))
    (ok (map-get? vote-records {voter: voter, proposal-id: proposal-id}))
)

(define-read-only (calculate-quorum (proposal-id uint))
    (let (
        (proposal (unwrap! (map-get? proposals proposal-id) ERR_INVALID_PROPOSAL))
        (total-votes (+ (get vote-count-yes proposal) (get vote-count-no proposal)))
        (required-votes (/ (* (var-get total-votes) QUORUM_PERCENTAGE) u100))
    )
    (ok {
        total-votes: total-votes,
        required-votes: required-votes,
        has-quorum: (>= total-votes required-votes)
    }))
)

;; Public functions

(define-public (add-candidate (id uint) (name (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set candidates id {name: name, vote-count: u0}))
  )
)

(define-public (vote (candidate-id uint))
  (let 
    (
      (voter tx-sender)
    )
    (asserts! (var-get voting-open) ERR_VOTING_CLOSED)
    (asserts! (is-none (map-get? votes voter)) ERR_ALREADY_VOTED)
    (match (map-get? candidates candidate-id)
      candidate
        (begin
          (map-set votes voter candidate-id)
          (map-set candidates candidate-id 
            (merge candidate {vote-count: (+ (get vote-count candidate) u1)})
          )
          (var-set total-votes (+ (var-get total-votes) u1))
          (ok true)
        )
      ERR_INVALID_VOTE
    )
  )
)

(define-public (close-voting)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set voting-open false)
    (ok true)
  )
)

(define-public (reopen-voting)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set voting-open true)
    (ok true)
  )
)

;; Contract initialization
(begin
  (map-set candidates u1 {name: "Candidate 1", vote-count: u0})
  (map-set candidates u2 {name: "Candidate 2", vote-count: u0})
  (map-set candidates u3 {name: "Candidate 3", vote-count: u0})
)
