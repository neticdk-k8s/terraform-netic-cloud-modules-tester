# .github

Contains GitHub Actions workflows for CI/CD automation.

```text
.github/
└── workflows/
    ├── validate.yml
    ├── plan.yml
    └── apply.yml
```

## Purpose

Automates:

- Terraform validation
- Terraform plan generation
- Security scanning
- Infrastructure deployment
- Recommended Workflow Design

### validate.yml

Runs on all pull requests.

Should execute:

terraform fmt
terraform validate
tflint
tfsec

### plan.yml

Runs Terraform plan during pull requests.

Purpose:

Detect infrastructure changes
Review changes before merge
Store plan artifacts

### apply.yml

Runs after merge to main.

Should include:

Environment protection
Manual approval for production
Remote state locking