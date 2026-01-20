# Phase 2: AAP Terraform (With Approval) - Implementation Summary

**Date**: 2026-01-20  
**Status**: ✅ Complete

---

## Implementation Overview

Phase 2 adds approval gating to Terraform workflows using AAP workflow approval nodes.

---

## Components Implemented

### 1. Ansible Roles

#### ✅ `roles/approval_wait/`
- **Purpose**: Validate AAP workflow approval node decision
- **Features**:
  - Validates approval status (approved, denied, pending, timed_out)
  - Fails workflow if denied or timed out
  - Uses AAP-provided variables: `ansible_awx_workflow_approval_status`
  - Provides clear error messages

### 2. Playbooks

#### ✅ `playbooks/terraform-with-approval.yml`
- **Purpose**: Terraform execution with approval gating
- **Flow**:
  1. Clone repository
  2. Execute terraform plan
  3. Send plan success callback (with `waiting_approval` status)
  4. **Approval node** (configured in AAP workflow)
  5. Validate approval decision
  6. Send approval granted/denied callback
  7. Execute terraform apply (only if approved)
  8. Send apply success/failed callback

#### ✅ `playbooks/terraform-destroy-with-approval.yml`
- **Purpose**: Terraform destroy with approval gating
- **Flow**:
  1. Clone repository
  2. Send waiting for approval callback
  3. **Approval node** (configured in AAP workflow)
  4. Validate approval decision
  5. Send approval granted/denied callback
  6. Execute terraform destroy (only if approved)
  7. Send destroy callback

### 3. Workflow Documentation

#### ✅ `workflows/terraform-with-approval.md`
- Documents workflow template: "Terraform - Plan → Approval → Apply"
- Includes approval node configuration
- Documents approval paths (approved, denied, timeout)
- Provides testing instructions

#### ✅ `workflows/terraform-destroy-with-approval.md`
- Documents workflow template: "Terraform - Destroy (With Approval)"
- Includes approval node configuration
- Provides testing instructions

### 4. Testing Documentation

#### ✅ `docs/phase-2-testing.md`
- Comprehensive testing guide for approval flows
- 4 test scenarios:
  1. Approval Granted Path
  2. Approval Denied Path
  3. Approval Timeout
  4. Destroy with Approval
- Expected callbacks for each scenario
- Troubleshooting guide

---

## Required AAP Workflow Templates

### Template 1: Terraform - Plan → Approval → Apply

**Job Templates (in order)**:
1. `terraform-approval-clone-repo` → Clone repository
2. `terraform-approval-plan` → Execute plan
3. `terraform-approval-plan-callback` → Send plan callback
4. **Approval Node** → Wait for approval (AAP workflow node)
5. `terraform-approval-decision-callback` → Send approval callback
6. `terraform-approval-apply` → Execute apply (only if approved)
7. `terraform-approval-apply-callback` → Send apply callback

**Dependencies**:
- Job 2 depends on Job 1 (success)
- Job 3 depends on Job 2 (success)
- Approval Node depends on Job 3 (success)
- Job 5 depends on Approval Node (approved or denied)
- Job 6 depends on Approval Node (approved only)
- Job 7 depends on Job 6 (success or failure)

### Template 2: Terraform - Destroy (With Approval)

**Job Templates (in order)**:
1. `terraform-destroy-approval-clone-repo` → Clone repository
2. `terraform-destroy-approval-waiting-callback` → Send waiting callback
3. **Approval Node** → Wait for approval
4. `terraform-destroy-approval-decision-callback` → Send approval callback
5. `terraform-destroy-approval-init` → Initialize Terraform (only if approved)
6. `terraform-destroy-approval-execute` → Execute destroy (only if approved)
7. `terraform-destroy-approval-callback` → Send destroy callback

---

## Approval Node Configuration

### In AAP Workflow Template

1. Add "Workflow Approval" node type
2. Configure:
   - **Name**: Descriptive name (e.g., `terraform-approval-node`)
   - **Timeout**: 3600 seconds (1 hour) default
   - **Can Approve**: Select users/groups with approval permissions
   - **Required**: Yes
3. Connect paths:
   - **Success path** (approved) → Continue to Apply
   - **Failure path** (denied/timeout) → Stop workflow, send denied callback

### AAP Variables Available

AAP automatically provides these variables after approval node:
- `ansible_awx_workflow_approval_status`: `approved`, `denied`, `pending`, `timed_out`
- `ansible_awx_workflow_approval_decision`: User decision
- `ansible_awx_workflow_approval_node_id`: Approval node ID

---

## Callback Contract Updates

### New Callback Endpoints

- `POST /api/orchestration/callbacks/approval_granted`
- `POST /api/orchestration/callbacks/approval_denied`

### Updated Callback Status

- `waiting_approval`: Plan completed, waiting for approval
- `success`: Approval granted or operation completed
- `failed`: Approval denied or operation failed

### Callback Examples

**Waiting for Approval:**
```json
{
  "phase": "plan",
  "status": "waiting_approval",
  "planOutput": "..."
}
```

**Approval Granted:**
```json
{
  "phase": "approval",
  "status": "success"
}
```

**Approval Denied:**
```json
{
  "phase": "approval",
  "status": "failed",
  "error": "Workflow approval was denied"
}
```

---

## Validation Status

✅ Approval wait role implemented  
✅ Terraform with approval playbook implemented  
✅ Destroy with approval playbook implemented  
✅ Workflow documentation created  
✅ Testing guide created  
✅ Approval node integration validated  

---

## Key Design Decisions

1. **Approval node in workflow template**: Approval is handled by AAP workflow node, not playbook logic
2. **Status validation**: Playbook validates approval decision using AAP-provided variables
3. **Conditional execution**: Apply/destroy only runs if approval status is 'approved'
4. **Callback timing**: Callbacks sent before and after approval node
5. **Error handling**: Denied/timeout approvals stop workflow execution

---

## Next Phase

**Phase 3: AAP Terragrunt**
- Implement Terragrunt plan role
- Implement Terragrunt apply role
- Create Terragrunt playbooks (with and without approval)
- Create workflow documentation

---

## Notes

- Approval node is configured in AAP UI, not in playbook code
- Playbook uses AAP-provided variables to determine approval status
- All Phase 1 roles are reused (no duplication)
- Approval workflows maintain same callback contract as Phase 1
