# AAP Polaris Workflows

Ansible Automation Platform (AAP) workflows, playbooks, and roles for Polaris orchestration.

## Architecture

All Terraform, Terragrunt, and Terraform Cloud execution happens **exclusively via AAP workflows**.

- **AAP is the primary orchestration engine**
- **No direct Terraform/TFC calls from backend services**
- **All executions support callbacks**
- **Approval via AAP workflow approval nodes**

## Repository Structure

```
aap-polaris-wf/
├── playbooks/          # Main playbooks
├── roles/              # Reusable Ansible roles
├── workflows/          # Workflow template documentation
└── docs/               # Additional documentation
```

## Implementation Phases

- [ ] Phase 0: Repository Baseline (Current)
- [ ] Phase 1: AAP Terraform (No Approval)
- [ ] Phase 2: AAP Terraform (With Approval)
- [ ] Phase 3: AAP Terragrunt
- [ ] Phase 4: AAP → Terraform Cloud (TFC)

## Requirements

- Ansible Automation Platform (AAP) 2.4+
- Ansible 2.14+
- Python 3.9+
