# customers

Contains real customer deployments.

## Example

```text
customers/
├── customer-a/
└── customer-b/
```

## Purpose

This is the deployment layer.

Contains:

- Environment configuration
- Terraform state configuration
- Customer-specific variables
- Deployment composition

## Recommended Structure

```text
customer-a/
├── prod/
├── test/
└── dev/
```

## Environment Isolation

Each workload should have its own Terraform state.

Example:

- prod/networking
- prod/kubernetes
- prod/monitoring

Why Separate States

Benefits:

- Smaller blast radius
- Faster Terraform plans
- Reduced state locking
- Easier RBAC separation
- Safer deployments
