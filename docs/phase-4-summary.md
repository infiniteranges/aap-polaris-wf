# Phase 4: AAP → Terraform Cloud (TFC) - Implementation Summary

**Date**: 2026-01-20  
**Status**: ✅ Complete

---

## Implementation Overview

Phase 4 implements Terraform Cloud execution via AAP workflows. All Terraform execution happens via TFC API, not local Terraform commands.

---

## Components Implemented

### 1. Ansible Roles

#### ✅ `roles/tfc_workspace/`
- **Purpose**: Create or get Terraform Cloud workspace via API
- **Features**:
  - Workspace creation if it doesn't exist
  - Workspace retrieval if it exists
  - Workspace variable configuration
  - VCS integration support (optional)
  - Execution mode configuration
  - Auto-apply configuration

#### ✅ `roles/tfc_plan/`
- **Purpose**: Create and monitor Terraform Cloud plan run
- **Features**:
  - Plan run creation via TFC API
  - Polling for plan completion
  - Plan output retrieval (JSON)
  - Status determination (finished, errored, canceled)
  - Configurable polling interval and timeout

#### ✅ `roles/tfc_apply/`
- **Purpose**: Create and monitor Terraform Cloud apply run
- **Features**:
  - Apply run creation via TFC API
  - Polling for apply completion
  - Output retrieval from TFC state version
  - Status determination
  - Configurable polling interval and timeout

### 2. Playbooks

#### ✅ `playbooks/tfc.yml`
- **Purpose**: Main TFC execution playbook (auto-approve)
- **Flow**:
  1. Create/get TFC workspace
  2. Create and monitor TFC plan run
  3. Send plan success/failed callback
  4. Create and monitor TFC apply run (if plan succeeded)
  5. Send apply success/failed callback

#### ✅ `playbooks/tfc-with-approval.yml`
- **Purpose**: TFC execution with approval gating
- **Flow**:
  1. Create/get TFC workspace
  2. Create and monitor TFC plan run
  3. Send plan callback (with `waiting_approval` status)
  4. Approval node (AAP workflow)
  5. Validate approval decision
  6. Send approval granted/denied callback
  7. Create and monitor TFC apply run (only if approved)
  8. Send apply callback

### 3. Workflow Documentation

#### ✅ `workflows/tfc-basic.md`
- Documents workflow template: "Terraform Cloud - Plan + Apply (Auto-Approve)"
- Includes job template configuration
- Documents TFC API integration
- Documents polling behavior

#### ✅ `workflows/tfc-with-approval.md`
- Documents workflow template: "Terraform Cloud - Plan → Approval → Apply"
- Includes approval node configuration
- Mirrors Terraform approval workflow structure

---

## Key Differences from Terraform/Terragrunt Workflows

1. **No local execution**: All execution happens via TFC API
2. **No repository cloning**: TFC handles repository access (if VCS configured)
3. **API-based**: Uses TFC REST API for all operations
4. **Polling**: AAP polls TFC API for run status (no callbacks from TFC)
5. **Workspace management**: Workspace created/configured automatically
6. **Output retrieval**: Outputs retrieved from TFC state version API

---

## Required AAP Workflow Templates

### Template 1: Terraform Cloud - Plan + Apply (Auto-Approve)

**Job Templates (in order)**:
1. `tfc-workspace` → Create/get TFC workspace
2. `tfc-plan` → Create and monitor TFC plan run
3. `tfc-plan-callback` → Send plan callback
4. `tfc-apply` → Create and monitor TFC apply run
5. `tfc-apply-callback` → Send apply callback

### Template 2: Terraform Cloud - Plan → Approval → Apply

**Job Templates (in order)**:
1. `tfc-approval-workspace` → Create/get TFC workspace
2. `tfc-approval-plan` → Create and monitor TFC plan run
3. `tfc-approval-plan-callback` → Send plan callback
4. **Approval Node** → Wait for approval
5. `tfc-approval-decision-callback` → Send approval callback
6. `tfc-approval-apply` → Create and monitor TFC apply run (only if approved)
7. `tfc-approval-apply-callback` → Send apply callback

---

## Required Extra Variables

```yaml
# Terraform Cloud configuration
tfc_organization: "my-org"
tfc_workspace_name: "workspace-name"
tfc_api_token: "your-tfc-api-token"
tfc_base_url: "https://app.terraform.io"  # Optional

# Operation
tfc_operation: "create|update|destroy"

# TFC-specific
use_tfc: true  # Required flag

# Workspace variables
tfc_variables:
  key: "value"

# Callback configuration
orchestration_callback_url: "https://orchestration-service/api/orchestration/callbacks"
```

---

## TFC API Integration Details

### Workspace API
- `GET /api/v2/organizations/{org}/workspaces/{name}` - Check if workspace exists
- `POST /api/v2/organizations/{org}/workspaces` - Create workspace
- `POST /api/v2/workspaces/{id}/vars` - Set workspace variables

### Run API
- `POST /api/v2/runs` - Create run
- `GET /api/v2/runs/{id}` - Get run status
- `GET /api/v2/plans/{id}` - Get plan status
- `GET /api/v2/plans/{id}/json-output` - Get plan output
- `GET /api/v2/applies/{id}` - Get apply status

### Outputs API
- `GET /api/v2/workspaces/{id}/current-state-version/outputs` - Get outputs

---

## Polling Configuration

- **Default interval**: 5 seconds
- **Default timeout**: 3600 seconds (1 hour)
- **Max polls**: 720 (3600 / 5)
- **Configurable**: Via `tfc_poll_interval` and `tfc_poll_timeout` variables

---

## Validation Status

✅ TFC workspace role implemented  
✅ TFC plan role implemented  
✅ TFC apply role implemented  
✅ TFC playbook implemented  
✅ TFC with approval playbook implemented  
✅ Workflow documentation created  
✅ Callback contract maintained (same as Terraform/Terragrunt)  

---

## Key Design Decisions

1. **API-only execution**: No local Terraform/Terragrunt execution
2. **Polling-based**: AAP polls TFC API (TFC doesn't support webhooks for runs)
3. **Workspace auto-creation**: Workspace created if it doesn't exist
4. **Variable management**: Variables set on workspace, not passed to runs
5. **Output retrieval**: Outputs retrieved from state version API after apply

---

## All Phases Complete

✅ **Phase 1**: AAP Terraform (No Approval)  
✅ **Phase 2**: AAP Terraform (With Approval)  
✅ **Phase 3**: AAP Terragrunt  
✅ **Phase 4**: AAP → Terraform Cloud (TFC)  

---

## Summary

All orchestration types are now implemented:
- **Terraform**: Local execution via AAP
- **Terragrunt**: Local execution via AAP
- **Terraform Cloud**: API-based execution via AAP

All workflows support:
- Auto-approve execution
- Approval-gated execution
- Consistent callback contract
- Error handling
- Output capture

---

## Notes

- TFC workflows are structurally similar to Terraform workflows
- Main difference is API-based execution vs local execution
- All Phase 1, 2, and 3 roles are reused where applicable
- Callback contract remains consistent across all orchestration types
- AAP is the primary orchestration engine for all execution types
