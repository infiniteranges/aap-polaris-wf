# AAP Workflow Template: Terragrunt - Plan + Apply (Auto-Approve)

## Overview

This workflow template executes Terragrunt plan and apply phases automatically without requiring approval.

## Workflow Structure

Same structure as `terraform-basic.md`, but uses Terragrunt roles instead of Terraform roles.

```
┌─────────────────────────────────────────┐
│ Job Template 1: Clone Repository        │
│   - Playbook: clone_repo role           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Terragrunt Plan        │
│   - Playbook: terragrunt_plan role     │
│   - Captures plan output                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 3: Send Plan Callback     │
│   - Playbook: callback_notify role     │
│   - Endpoint: plan_success             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Terragrunt Apply       │
│   - Playbook: terragrunt_apply role   │
│   - Uses plan file from previous step  │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Apply Callback    │
│   - Playbook: callback_notify role      │
│   - Endpoint: apply_success             │
└─────────────────────────────────────────┘
```

## Required Extra Variables

```yaml
tfc_pattern_repo_name: "terraform-aws-modules/terraform-aws-vpc"
tfc_pattern_version: "v5.0.0"
tfc_workspace_name: "terragrunt-vpc-corp-us-east-1-dev-550e8400e29b"
tfc_cloud_provider: "aws"
tfc_operation: "create"
use_terragrunt: true  # Flag to indicate Terragrunt execution
terragrunt_working_dir: "."  # Optional: subdirectory with terragrunt.hcl
tfc_variables:
  resource_name: "corp"
  aws_account_id: "123456789012"
  aws_region: "us-east-1"
  environment: "dev"
orchestration_callback_url: "https://sc-demo-orch.r53.infiniteranges.com/api/orchestration/callbacks"
```

## Job Template Configuration

### Job Template 1: Clone Repository
- **Name**: `terragrunt-clone-repo`
- **Playbook**: `playbooks/terragrunt.yml` (clone section)
- **Inventory**: Localhost

### Job Template 2: Terragrunt Plan
- **Name**: `terragrunt-plan`
- **Playbook**: `playbooks/terragrunt.yml` (plan section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 1

### Job Template 3: Send Plan Callback
- **Name**: `terragrunt-plan-callback`
- **Playbook**: `playbooks/terragrunt.yml` (plan callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 2 (on success)

### Job Template 4: Terragrunt Apply
- **Name**: `terragrunt-apply`
- **Playbook**: `playbooks/terragrunt.yml` (apply section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 3

### Job Template 5: Send Apply Callback
- **Name**: `terragrunt-apply-callback`
- **Playbook**: `playbooks/terragrunt.yml` (apply callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 4 (on success)

## Workflow Template Configuration

1. Create workflow job template in AAP
2. Add job templates in order: Clone → Plan → Plan Callback → Apply → Apply Callback
3. Configure success/failure paths
4. Set extra_vars as prompt on launch

## Testing

### Manual Test Steps

1. Launch workflow with test variables
2. Ensure `use_terragrunt: true` is set
3. Monitor execution in AAP UI
4. Verify Terragrunt commands execute (not Terraform)
5. Check callbacks received

### Expected Behavior

- Repository cloned
- Terragrunt plan executes
- Plan output captured
- Callback sent: `plan_success`
- Terragrunt apply executes
- Outputs captured
- Callback sent: `apply_success`

### Expected Callbacks

Same structure as Terraform workflows, but with Terragrunt execution context.

## Notes

- Terragrunt workflows are identical to Terraform workflows in structure
- Only difference is using `terragrunt_plan` and `terragrunt_apply` roles
- `use_terragrunt: true` flag indicates Terragrunt execution
- `terragrunt_working_dir` can specify subdirectory with `terragrunt.hcl`
