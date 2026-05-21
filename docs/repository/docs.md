# docs/

Contains platform documentation and governance standards.

Example:

```text
docs/
├── architecture/
├── onboarding/
└── standards/
└── repository/
```

## Purpose

Central location for:

Architecture decisions
Naming standards
Security standards
Operational procedures
Customer onboarding

## docs/architecture/

Documents platform design.

Examples:

landing-zone.md
networking.md
identity.md

Should explain:

Network topology
Connectivity
Security boundaries
Kubernetes architecture
Shared services


## docs/standards/

Defines operational standards.

Examples:

tagging.md
security.md

Should define:

Resource naming
Tagging strategy
RBAC standards
Terraform coding conventions

## docs/onboarding/

Step-by-step onboarding procedures.

Example:

new-customer.md

Should explain:

How to create a new customer deployment
Required variables
Backend configuration
CI/CD setup
