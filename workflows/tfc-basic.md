# AAP Workflow Template: Terraform Cloud - Plan + Apply (Auto-Approve)

## Overview

This workflow template executes Terraform Cloud plan and apply phases automatically without requiring approval. All execution happens via TFC API, not local Terraform.

## Workflow Structure

```
┌─────────────────────────────────────────┐
│ Job Template 1: Create/Get TFC Workspace│
│   - Playbook: tfc_workspace role        │
│   - Creates workspace if needed        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Create TFC Plan Run     │
│   - Playbook: tfc_plan role            │
│   - Polls TFC API for plan completion  │
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
│ Job Template 4: Create TFC Apply Run    │
│   - Playbook: tfc_apply role           │
│   - Polls TFC API for apply completion │
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
tfc_organization: "my-org"
tfc_workspace_name: "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b"
tfc_api_token: "your-tfc-api-token"
tfc_base_url: "https://app.terraform.io"  # Optional, defaults to app.terraform.io
tfc_cloud_provider: "aws"
tfc_operation: "create"
use_tfc: true  # Flag to indicate TFC execution
tfc_variables:
  resource_name: "corp"
  aws_account_id: "123456789012"
  aws_region: "us-east-1"
  environment: "dev"
orchestration_callback_url: "https://sc-demo-orch.r53.infiniteranges.com/api/orchestration/callbacks"
```

## Job Template Configuration

### Job Template 1: Create/Get TFC Workspace
- **Name**: `tfc-workspace`
- **Playbook**: `playbooks/tfc.yml` (workspace section)
- **Inventory**: Localhost
- **Credentials**: TFC API token (or pass via extra_vars)

### Job Template 2: Create TFC Plan Run
- **Name**: `tfc-plan`
- **Playbook**: `playbooks/tfc.yml` (plan section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 1

### Job Template 3: Send Plan Callback
- **Name**: `tfc-plan-callback`
- **Playbook**: `playbooks/tfc.yml` (plan callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 2 (on success)

### Job Template 4: Create TFC Apply Run
- **Name**: `tfc-apply`
- **Playbook**: `playbooks/tfc.yml` (apply section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 3

### Job Template 5: Send Apply Callback
- **Name**: `tfc-apply-callback`
- **Playbook**: `playbooks/tfc.yml` (apply callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 4 (on success)

## Workflow Template Configuration

1. Create workflow job template in AAP
2. Add job templates in order: Workspace → Plan → Plan Callback → Apply → Apply Callback
3. Configure success/failure paths
4. Set extra_vars as prompt on launch

## Testing

### Manual Test Steps

1. Launch workflow with test variables
2. Ensure `use_tfc: true` is set
3. Monitor execution in AAP UI
4. Verify TFC workspace created/accessed
5. Verify TFC plan run created and monitored
6. Verify TFC apply run created and monitored
7. Check callbacks received

### Expected Behavior

- TFC workspace created or retrieved
- TFC plan run created
- Plan status polled until completion
- Callback sent: `plan_success`
- TFC apply run created
- Apply status polled until completion
- Outputs retrieved from TFC
- Callback sent: `apply_success`

### Expected Callbacks

**Plan Success:**
```json
{
  "deploymentId": "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "success",
  "planOutput": "{...}",
  "terraformRunId": "run-abc123"
}
```

**Apply Success:**
```json
{
  "deploymentId": "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "apply",
  "status": "success",
  "outputs": {
    "vpc_id": "vpc-12345678"
  },
  "terraformRunId": "run-abc123"
}
```

## Notes

- All execution happens via TFC API (no local Terraform)
- AAP polls TFC API for run status
- Workspace is created automatically if it doesn't exist
- Variables are set on workspace
- Outputs are retrieved from TFC state version
