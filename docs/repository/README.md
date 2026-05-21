# Repository Structure

This document describes the recommended repository structure for managing reusable Terraform infrastructure modules and customer deployments in OVHcloud.


## Repository Overview

```text
terraform-kkk-ovhcloud/
├── .github/
├── docs/
├── modules/
├── templates/
├── customers/
├── scripts/
└── README.md
```

The repository is divided into logical layers:

| Folder     |  Purpose |
| ------     | ------ | 
| [.github/](github.md) | 	CI/CD automation |
| [docs/](docs.md)     | Documentation and standards |
| [modules/](./modules.md) | Reusable Terraform modules |
| [templates/](./templates.md) | Customer deployment templates |
| [customers/](./customers.md) | Actual customer deployments |
| scripts/ | Helper and bootstrap scripts |

