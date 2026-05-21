# modules/

Contains reusable Terraform modules.

```text
modules/
├── network/
├── kubernetes/
├── vm/
├── storage/
└── monitoring/
```

## Purpose

Provides reusable infrastructure building blocks.

Modules should contain:

Generic infrastructure logic
No customer-specific configuration
No environment-specific logic
Module Design Principles

Modules should:

Be small and focused
Have clear inputs and outputs
Avoid conditional environment logic
Be reusable across customers

### Good Example

```text
module "network" {
  source = "../../../modules/network"

  name       = "core-network"
  cidr_block = "10.0.0.0/16"
}
```
