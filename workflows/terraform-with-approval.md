# AAP Workflow Template: Terraform - Plan → Approval → Apply

## Overview

This workflow template executes Terraform plan, waits for approval, and then executes apply.

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
│ Approval Node                            │
│   - Type: Workflow Approval             │
│   - Timeout: 3600 seconds (1 hour)      │
│   - Required: Yes                       │
└──────────────┬──────────────────────────┘
               │
               ├─── Approved ──────────────┐
               │                           │
               └─── Denied ────────────────┘
               │                           │
               ▼                           ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ Send Approval    │      │ Send Approval    │
    │ Granted Callback  │      │ Denied Callback   │
    └────────┬─────────┘      └──────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Terraform Apply        │
│   - Playbook: terraform_apply role     │
│   - Only runs if approved              │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Apply Callback   │
│   - Playbook: callback_notify role     │
│   - Endpoint: apply_success/failed     │
└─────────────────────────────────────────┘
```

## Required Extra Variables

Same as `terraform-basic.md` workflow.

## Job Template Configuration

### Job Template 1: Clone Repository
- **Name**: `terraform-approval-clone-repo`
- **Playbook**: `playbooks/terraform-with-approval.yml` (clone section)
- **Inventory**: Localhost

### Job Template 2: Terraform Plan
- **Name**: `terraform-approval-plan`
- **Playbook**: `playbooks/terraform-with-approval.yml` (plan section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 1

### Job Template 3: Send Plan Callback
- **Name**: `terraform-approval-plan-callback`
- **Playbook**: `playbooks/terraform-with-approval.yml` (plan callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 2 (on success)

### Approval Node
- **Type**: Workflow Approval
- **Name**: `terraform-approval-node`
- **Timeout**: 3600 seconds (1 hour)
- **Can Approve**: Users with appropriate permissions
- **Dependencies**: Job Template 3 (on success)

### Job Template 4: Send Approval Callback
- **Name**: `terraform-approval-decision-callback`
- **Playbook**: `playbooks/terraform-with-approval.yml` (approval callback section)
- **Inventory**: Localhost
- **Dependencies**: Approval Node (on approved or denied)

### Job Template 5: Terraform Apply
- **Name**: `terraform-approval-apply`
- **Playbook**: `playbooks/terraform-with-approval.yml` (apply section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Approval Node (on approved only)

### Job Template 6: Send Apply Callback
- **Name**: `terraform-approval-apply-callback`
- **Playbook**: `playbooks/terraform-with-approval.yml` (apply callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 5 (on success or failure)

## Workflow Template Configuration

1. Create workflow job template in AAP
2. Add job templates in order: Clone → Plan → Plan Callback → **Approval Node** → Approval Callback → Apply → Apply Callback
3. Configure approval node:
   - Set timeout (default: 3600 seconds)
   - Configure who can approve
   - Set as required
4. Configure success/failure paths:
   - Approval approved → Continue to Apply
   - Approval denied → Stop workflow, send denied callback
   - Approval timed out → Stop workflow
5. Set extra_vars as prompt on launch

## Approval Node Configuration

In AAP UI:
1. Add "Workflow Approval" node type
2. Configure:
   - **Name**: `terraform-approval-node`
   - **Timeout**: 3600 (1 hour)
   - **Can Approve**: Select users/groups
   - **Required**: Yes
3. Connect:
   - Success path → Apply job template
   - Failure path → Approval denied callback

## Testing

### Manual Test Steps

1. Launch workflow with test variables
2. Monitor execution in AAP UI
3. Workflow should pause at approval node
4. Approve or deny in AAP UI
5. Verify workflow continues or stops accordingly
6. Check callbacks received

### Expected Behavior

**Approval Path:**
- Plan executes successfully
- Callback sent with `waiting_approval` status
- Workflow pauses at approval node
- User approves in AAP UI
- Callback sent: `approval_granted`
- Apply executes
- Callback sent: `apply_success`

**Denial Path:**
- Plan executes successfully
- Callback sent with `waiting_approval` status
- Workflow pauses at approval node
- User denies in AAP UI
- Callback sent: `approval_denied`
- Workflow stops
- Apply is skipped

**Timeout Path:**
- Plan executes successfully
- Callback sent with `waiting_approval` status
- Workflow pauses at approval node
- Timeout expires (1 hour)
- Workflow stops
- Callback sent: `approval_denied` (with timeout error)

### Expected Callbacks

**Waiting for Approval:**
```json
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "waiting_approval",
  "planOutput": "Plan: 5 to add, 0 to change, 0 to destroy..."
}
```

**Approval Granted:**
```json
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "approval",
  "status": "success"
}
```

**Approval Denied:**
```json
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "approval",
  "status": "failed",
  "error": "Workflow approval was denied"
}
```

## Notes

- Approval node is configured in AAP workflow template, not in playbook
- Playbook validates approval decision using `ansible_awx_workflow_approval_status` variable
- Apply phase only runs if approval status is 'approved'
- Denied approvals stop workflow execution
