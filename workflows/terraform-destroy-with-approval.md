# AAP Workflow Template: Terraform - Destroy (With Approval)

## Overview

This workflow template executes Terraform destroy operation after approval.

## Workflow Structure

```
┌─────────────────────────────────────────┐
│ Job Template 1: Clone Repository        │
│   - Playbook: clone_repo role          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 2: Send Waiting Callback    │
│   - Playbook: callback_notify role      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Approval Node                            │
│   - Type: Workflow Approval             │
│   - Timeout: 3600 seconds               │
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
│ Job Template 3: Initialize Terraform    │
│   - Command: terraform init             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 4: Terraform Destroy       │
│   - Command: terraform destroy          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ Job Template 5: Send Destroy Callback  │
│   - Playbook: callback_notify role      │
└─────────────────────────────────────────┘
```

## Required Extra Variables

Same as `terraform-destroy.md` workflow.

## Job Template Configuration

### Job Template 1: Clone Repository
- **Name**: `terraform-destroy-approval-clone-repo`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (clone section)
- **Inventory**: Localhost

### Job Template 2: Send Waiting Callback
- **Name**: `terraform-destroy-approval-waiting-callback`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (waiting callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 1

### Approval Node
- **Type**: Workflow Approval
- **Name**: `terraform-destroy-approval-node`
- **Timeout**: 3600 seconds
- **Dependencies**: Job Template 2

### Job Template 3: Send Approval Callback
- **Name**: `terraform-destroy-approval-decision-callback`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (approval callback section)
- **Inventory**: Localhost
- **Dependencies**: Approval Node

### Job Template 4: Initialize Terraform
- **Name**: `terraform-destroy-approval-init`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (init section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Approval Node (on approved only)

### Job Template 5: Terraform Destroy
- **Name**: `terraform-destroy-approval-execute`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (destroy section)
- **Inventory**: Localhost
- **Credentials**: AWS credentials
- **Dependencies**: Job Template 4

### Job Template 6: Send Destroy Callback
- **Name**: `terraform-destroy-approval-callback`
- **Playbook**: `playbooks/terraform-destroy-with-approval.yml` (destroy callback section)
- **Inventory**: Localhost
- **Dependencies**: Job Template 5

## Testing

### Manual Test Steps

1. Launch workflow with existing deployment
2. Monitor execution in AAP UI
3. Workflow pauses at approval node
4. Approve or deny
5. Verify destroy executes or stops accordingly

### Expected Behavior

- Approval required before destroy
- Denied approval stops workflow
- Approved approval proceeds with destroy
