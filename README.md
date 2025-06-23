# BitCause

**Decentralized Philanthropic Hub with Milestone-Driven Transparency**

BitCause revolutionizes charitable giving by creating a trustless ecosystem where donors can track their contributions with complete transparency. Built on Stacks blockchain with Bitcoin's security, this platform eliminates traditional charity overhead concerns through smart contract automation and milestone-based fund releases.

## Overview

BitCause addresses the fundamental trust issues in traditional charitable organizations by leveraging blockchain technology to create an immutable, transparent donation platform. Every donation is recorded on-chain, every expenditure is verified through milestone approvals, and every impact is measurable through our decentralized governance system.

## Key Features

- **🔒 Bitcoin-Secured Transparency**: Built on Stacks Layer 2 with Bitcoin settlement
- **📊 Milestone-Based Releases**: Funds released only upon verified milestone completion
- **🏛️ Decentralized Governance**: Role-based access control with admin oversight
- **📈 Real-Time Tracking**: Complete donation and utilization visibility
- **💡 Zero Intermediaries**: Direct donor-to-cause connections
- **🔍 Immutable Audit Trail**: Every transaction permanently recorded

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        BitCause Platform                    │
├─────────────────────────────────────────────────────────────┤
│  Frontend Layer                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Donor     │  │ Beneficiary │  │    Admin    │        │
│  │ Dashboard   │  │   Portal    │  │   Console   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
├─────────────────────────────────────────────────────────────┤
│  Smart Contract Layer (Stacks Blockchain)                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │               BitCause Core Contract                    ││
│  │  ┌───────────┐ ┌───────────┐ ┌─────────────────────┐   ││
│  │  │   Role    │ │ Donation  │ │    Utilization      │   ││
│  │  │Management │ │Processing │ │   Management        │   ││
│  │  └───────────┘ └───────────┘ └─────────────────────┘   ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  Stacks Layer 2 Network                                    │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Transaction Processing & State Management              ││
│  │  - STX Token Transfers                                  ││
│  │  - Smart Contract Execution                             ││
│  │  - Event Logging                                        ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  Bitcoin Settlement Layer                                   │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  Final Settlement & Security                            ││
│  │  - Block Finality                                       ││
│  │  - Network Security                                     ││
│  │  - Immutable Record Keeping                             ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Contract Architecture

### Core Components

#### 1. Access Control System

- **Role-based permissions** with three tiers: Admin, Moderator, Beneficiary
- **Hierarchical authorization** ensuring proper governance
- **Owner-controlled role assignment** preventing unauthorized access

#### 2. Beneficiary Management

- **Cause registration** with detailed descriptions and funding targets
- **Status tracking** for active/inactive campaigns
- **Progress monitoring** with real-time funding updates

#### 3. Donation Processing

- **Direct STX transfers** to contract escrow
- **Immutable transaction records** with timestamps
- **Automatic balance updates** for beneficiaries

#### 4. Fund Utilization Control

- **Milestone-based releases** requiring admin approval
- **Detailed utilization tracking** with descriptions
- **Status management** for pending/approved expenditures

### Data Structures

```clarity
;; Role Management
(define-map roles { user: principal } { role: uint })

;; Beneficiary Registry
(define-map beneficiaries { id: uint } {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20)
})

;; Donation Ledger
(define-map donations { id: uint } {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint
})

;; Utilization Tracker
(define-map utilization { id: uint } {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20)
})
```

## Data Flow

### 1. Donation Flow

```
Donor → donate() → STX Transfer → Contract Escrow → Update Beneficiary Balance → Record Transaction
```

### 2. Utilization Flow

```
Admin → add-utilization() → Create Milestone → approve-utilization() → Release Approval → Fund Access
```

### 3. Governance Flow

```
Owner → set-role() → Assign Permissions → User Actions → Role-Based Access Control → Function Execution
```

## Getting Started

### Prerequisites

- Stacks wallet (Hiro, Xverse, etc.)
- STX tokens for donations and transactions
- Node.js (for local development)

### Contract Deployment

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-org/bitcause
   cd bitcause
   ```

2. **Install Clarinet**

   ```bash
   npm install -g @hirosystems/clarinet-cli
   ```

3. **Deploy to testnet**

   ```bash
   clarinet deployments generate --testnet
   clarinet deployments apply --testnet
   ```

### Basic Usage

#### For Donors

```clarity
;; Make a donation
(contract-call? .bitcause donate u1 u1000000) ;; 1 STX to beneficiary #1
```

#### For Admins

```clarity
;; Register a new cause
(contract-call? .bitcause register-beneficiary 
    u"Clean Water Initiative" 
    u"Providing clean water access to rural communities" 
    u10000000000) ;; 10,000 STX target

;; Approve fund utilization
(contract-call? .bitcause approve-utilization u1 u1)
```

## Security Features

- **Multi-signature governance** through role-based access
- **Fund lock mechanisms** preventing unauthorized withdrawals
- **Immutable audit trails** for complete transparency
- **Bitcoin finality** ensuring transaction permanence

## Roadmap

- [ ] Multi-token support (BTC, other Stacks tokens)
- [ ] Advanced milestone verification system
- [ ] Integration with real-world impact metrics
- [ ] Mobile application development
- [ ] Cross-chain bridge implementation

## Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request
