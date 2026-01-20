# AAP Workflow Template: Terraform - Plan + Apply (Auto-Approve)

## Overview

This workflow template executes Terraform plan and apply phases automatically without requiring approval.

## Workflow Structure

```
┌─────────────────────────────────────────┐
│ Job Template 1: Clone Repository        │
│   - Playbook: clone_repo role          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Terraform Plan          │
│   - Playbook: terraform_plan role       │
│   - Captures plan output                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 3: Send Plan Callback      │
│   - Playbook: callback_notify role      │
│   - Endpoint: plan_success              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Terraform Apply        │
│   - Playbook: terraform_apply role      │
│   - Uses plan file from previous step   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Apply Callback    │
│   - Playbook: callback_notify role      │
│   - Endpoint: apply_success              │
└─────────────────────────────────────────┘
```

## Required Extra Variables

```yaml
tfc_pattern_repo_name: "terraform-aws-modules/terraform-aws-vpc"
tfc_pattern_version: "v5.0.0"
tfc_workspace_name: "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b"
tfc_cloud_provider: "aws"
tfc_operation: "create"
tfc_variables:
  resource_name: "corp"
  aws_account_id: "123456789012"
  aws_region: "us-east-1"
  environment: "dev"
orchestration_callback_url: "https://sc-demo-orch.r53.infiniteranges.com/api/orchestration/callbacks"
```

## Job Template Configuration

### Job Template 1: Clone Repository
- **Name**: `terraform-clone-repo`
- **Playbook**: `playbooks/terraform.yml` (run only clone_repo tasks)
- **Inventory**: Localhost
- **Credentials**: Git credentials (if private repo)

### Job Template 2: Terraform Plan
- **Name**: `terraform-plan`
- **Playbook**: `playbooks/terraform.yml` (run only terraform_plan tasks)
- **Inventory**: Localhost
- **Credentials**: AWS credentials (or cloud provider credentials)
- **Dependencies**: Job Template 1

### Job Template 3: Send Plan Callback
- **Name**: `terraform-plan-callback`
- **Playbook**: `playbooks/terraform.yml` (run only callback_notify tasks)
- **Inventory**: Localhost
- **Dependencies**: Job Template 2 (on success)

### Job Template 4: Terraform Apply
- **Name**: `terraform-apply`
- **Playbook**: `playbooks/terraform.yml` (run only terraform_apply tasks)
- **Inventory**: Localhost
- **Credentials**: AWS credentials (or cloud provider credentials)
- **Dependencies**: Job Template 3

### Job Template 5: Send Apply Callback
- **Name**: `terraform-apply-callback`
- **Playbook**: `playbooks/terraform.yml` (run only callback_notify tasks)
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
2. Monitor execution in AAP UI
3. Verify callbacks received in orchestration service
4. Check Terraform state/outputs

### Expected Callbacks

**Plan Success Callback:**
```json
{
  "deploymentId": "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "success",
  "planOutput": "Plan: 5 to add, 2 to change, 0 to destroy...",
  "error": null
}
```

**Apply Success Callback:**
```json
{
  "deploymentId": "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "apply",
  "status": "success",
  "outputs": {
    "vpc_id": "vpc-12345678",
    "subnet_ids": ["subnet-123", "subnet-456"]
  },
  "error": null
}
```

## Failure Scenarios

- **Plan Failure**: Callback sent to `plan_failed` endpoint, workflow stops
- **Apply Failure**: Callback sent to `apply_failed` endpoint, workflow stops
- **Callback Failure**: Logged but does not stop workflow (ignore_errors: true)
