# AAP Workflow Template: Terraform - Destroy

## Overview

This workflow template executes Terraform destroy operation to tear down infrastructure.

## Workflow Structure

```
┌─────────────────────────────────────────┐
│ Job Template 1: Clone Repository        │
│   - Playbook: clone_repo role          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Initialize Terraform    │
│   - Command: terraform init            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 3: Terraform Destroy      │
│   - Command: terraform destroy          │
│   - Auto-approve enabled               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Send Destroy Callback  │
│   - Playbook: callback_notify role      │
│   - Endpoint: apply_success/failed       │
└─────────────────────────────────────────┘
```

## Required Extra Variables

```yaml
tfc_pattern_repo_name: "terraform-aws-modules/terraform-aws-vpc"
tfc_pattern_version: "v5.0.0"
tfc_workspace_name: "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b"
tfc_cloud_provider: "aws"
tfc_operation: "destroy"
tfc_variables:
  aws_region: "us-east-1"
orchestration_callback_url: "https://sc-demo-orch.r53.infiniteranges.com/api/orchestration/callbacks"
```

## Job Template Configuration

### Job Template 1: Clone Repository
- **Name**: `terraform-destroy-clone-repo`
- **Playbook**: `playbooks/terraform-destroy.yml` (clone section)
- **Inventory**: Localhost

### Job Template 2: Initialize Terraform
- **Name**: `terraform-destroy-init`
- **Playbook**: `playbooks/terraform-destroy.yml` (init section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 1

### Job Template 3: Terraform Destroy
- **Name**: `terraform-destroy-execute`
- **Playbook**: `playbooks/terraform-destroy.yml` (destroy section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 2

### Job Template 4: Send Destroy Callback
- **Name**: `terraform-destroy-callback`
- **Playbook**: `playbooks/terraform-destroy.yml` (callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 3

## Workflow Template Configuration

1. Create workflow job template in AAP
2. Add job templates in order: Clone → Init → Destroy → Callback
3. Configure success/failure paths
4. Set extra_vars as prompt on launch

## Testing

### Manual Test Steps

1. Launch workflow with existing deployment workspace
2. Monitor execution in AAP UI
3. Verify infrastructure is destroyed
4. Verify callback received

### Expected Callback

**Destroy Success Callback:**
```json
{
  "deploymentId": "terraform-aws-vpc-corp-us-east-1-dev-550e8400e29b",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1235,
  "phase": "destroy",
  "status": "success",
  "outputs": {},
  "error": null
}
```

## Notes

- Destroy operation does not require a plan file
- Uses `-auto-approve` flag to avoid interactive prompts
- Callback uses `apply_success`/`apply_failed` endpoints for consistency
