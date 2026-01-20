# AAP Workflow Template: Terraform Cloud - Plan → Approval → Apply

## Overview

This workflow template executes Terraform Cloud plan, waits for approval, and then executes apply.

## Workflow Structure

Same structure as `terraform-with-approval.md`, but uses TFC roles instead of Terraform roles.

```
┌─────────────────────────────────────────┐
│ Job Template 1: Create/Get TFC Workspace│
│   - Playbook: tfc_workspace role        │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Create TFC Plan Run      │
│   - Playbook: tfc_plan role             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 3: Send Plan Callback       │
│   - Playbook: callback_notify role      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Approval Node                            │
│   - Type: Workflow Approval             │
└──────────────┬──────────────────────────┘
               │
               ├─── Approved ──────────────┐
               │                           │
               └─── Denied ────────────────┘
               │                           │
               ▼                           ▼
    ┌──────────────────┐      ┌──────────────────┐
    │ Send Approval    │      │ Send Approval    │
    │ Granted Callback │      │ Denied Callback   │
    └────────┬─────────┘      └──────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Create TFC Apply Run    │
│   - Playbook: tfc_apply role            │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Apply Callback    │
│   - Playbook: callback_notify role     │
└─────────────────────────────────────────┘
```

## Required Extra Variables

Same as `tfc-basic.md`, plus approval node configuration.

## Job Template Configuration

Same as `terraform-with-approval.md`, but with TFC job templates:
- `tfc-approval-workspace`
- `tfc-approval-plan`
- `tfc-approval-plan-callback`
- Approval Node
- `tfc-approval-decision-callback`
- `tfc-approval-apply`
- `tfc-approval-apply-callback`

## Testing

Same testing approach as `terraform-with-approval.md`, but verify TFC API calls execute.

## Notes

- TFC approval workflows mirror Terraform approval workflows
- Same approval node configuration
- Same callback contract
- All execution via TFC API
