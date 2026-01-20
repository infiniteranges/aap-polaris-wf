# Ansible Roles

Reusable Ansible roles for Polaris orchestration.

## Planned Roles

### Repository Management
- `clone_repo/` - Clone Git repository and checkout version

### Terraform Execution
- `terraform_plan/` - Execute terraform plan
- `terraform_apply/` - Execute terraform apply

### Terragrunt Execution
- `terragrunt_plan/` - Execute terragrunt plan
- `terragrunt_apply/` - Execute terragrunt apply

### Terraform Cloud Execution
- `tfc_workspace/` - Create/get TFC workspace
- `tfc_plan/` - Create and monitor TFC plan run
- `tfc_apply/` - Create and monitor TFC apply run

### Workflow Support
- `approval_wait/` - Wait for approval (used by approval nodes)
- `callback_notify/` - Send callback to orchestration service
