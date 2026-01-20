# AAP Workflow Template: Terragrunt - Plan → Approval → Apply

## Overview

This workflow template executes Terragrunt plan, waits for approval, and then executes apply.

## Workflow Structure

Same structure as `terraform-with-approval.md`, but uses Terragrunt roles.

```
┌─────────────────────────────────────────┐
│ Job Template 1: Clone Repository        │
│   - Playbook: clone_repo role          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Terragrunt Plan         │
│   - Playbook: terragrunt_plan role     │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 3: Send Plan Callback      │
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
│ Job Template 4: Terragrunt Apply       │
│   - Playbook: terragrunt_apply role   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Apply Callback    │
│   - Playbook: callback_notify role     │
└─────────────────────────────────────────┘
```

## Required Extra Variables

Same as `terragrunt-basic.md`, plus approval node configuration.

## Job Template Configuration

Same as `terraform-with-approval.md`, but with Terragrunt job templates:
- `terragrunt-approval-clone-repo`
- `terragrunt-approval-plan`
- `terragrunt-approval-plan-callback`
- Approval Node
- `terragrunt-approval-decision-callback`
- `terragrunt-approval-apply`
- `terragrunt-approval-apply-callback`

## Testing

Same testing approach as `terraform-with-approval.md`, but verify Terragrunt commands execute.

## Notes

- Terragrunt approval workflows mirror Terraform approval workflows
- Same approval node configuration
- Same callback contract
