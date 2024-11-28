# Decentralized Voting System Smart Contract

## Overview

This repository contains a sophisticated Clarity smart contract implementing a decentralized voting system on the Stacks blockchain. The contract provides comprehensive voting functionality, including proposal creation, delegation, voter registration, and emergency controls.

## Features

### Core Voting Features
- Add candidates to the voting system
- Cast votes for candidates with weight-based voting
- Voter registration system with unique voter IDs
- Time-based voting periods
- Delegation system for vote transfers
- Proposal creation and management
- Quorum-based decision making
- Emergency stop mechanism

### Administrative Controls
- Contract owner privileges for system management
- Voting period controls (open/close)
- Registration period management
- Emergency stop functionality
- Proposal execution controls

### Data Tracking
- Individual and total vote counting
- Voter registration status
- Delegation records
- Proposal status monitoring
- Vote weight tracking
- Quorum calculations

## Contract Details

### Constants

- `CONTRACT_OWNER`: The principal who deployed the contract
- `MINIMUM_STAKE`: Required stake for proposal creation (1,000,000 uSTX)
- `QUORUM_PERCENTAGE`: Required percentage for proposal passage (51%)
- Comprehensive error codes for various scenarios (100-111)

### State Management

#### Data Variables
- Voting status controls (open/closed)
- Registration status
- Voting period timestamps
- Emergency stop flag
- Proposal tracking
- Vote counting

#### Data Maps
- `votes`: Tracks voter choices
- `candidates`: Stores candidate information
- `registered-voters`: Maintains voter registration status
- `voter-registry`: Detailed voter information
- `proposals`: Comprehensive proposal data
- `vote-records`: Detailed voting history
- `delegations`: Vote delegation tracking

### Core Functions

#### Read-Only Functions
- `get-vote-count`: Retrieves vote count for a specific candidate
- `get-voter-status`: Checks if a user has already voted
- `get-total-votes`: Returns the total number of votes cast
- `get-candidate-info`: Retrieves detailed candidate information
- `calculate-quorum`: Determines if a proposal has reached quorum

#### Public Functions

1. Candidate Management
- `add-candidate`: Adds new candidates to the voting system
- `remove-candidate`: Removes a candidate (owner only)

2. Voting System
- `vote`: Cast a vote for a specific candidate
- `close-voting`: Ends the voting period (owner only)
- `reopen-voting`: Restarts voting period (owner only)

3. Proposal Management
- `create-proposal`: Creates new voting proposals
- `vote-on-proposal`: Casts votes on specific proposals
- `execute-proposal`: Executes passed proposals

4. Vote Delegation
- `delegate-votes`: Transfers voting power to another address
- `revoke-delegation`: Cancels an active delegation

## Usage

### Basic Operations

1. Casting a vote:
```clarity
(contract-call? .voting-system vote u1)
```

2. Checking the vote count for a candidate:
```clarity
(contract-call? .voting-system get-vote-count u1)
```

3. Closing the voting (only contract owner):
```clarity
(contract-call? .voting-system close-voting)
```

### Security Considerations

- Only the contract owner can add candidates, close, and reopen voting
- Users can only vote once
- Voting is only allowed when the voting period is open
- Minimum stake requirements protect against spam proposals
- Time-locked voting periods ensure fair participation
- Emergency stop mechanism for critical situations

### Future Enhancements

Potential improvements to the contract could include:

1. Implementing a function to get all candidates
2. Adding a function to determine the winning candidate
3. Implementing time-based voting using block height
4. Allowing candidates to register themselves with a stake
5. Adding support for multiple simultaneous voting sessions
6. Implementing weighted voting based on token holdings
7. Adding delegate voting mechanisms
8. Creating a proposal template system