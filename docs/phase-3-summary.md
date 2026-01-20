# Phase 3: AAP Terragrunt - Implementation Summary

**Date**: 2026-01-20  
**Status**: ✅ Complete

---

## Implementation Overview

Phase 3 implements Terragrunt execution via AAP workflows, mirroring Terraform workflows but using Terragrunt commands.

---

## Components Implemented

### 1. Ansible Roles

#### ✅ `roles/terragrunt_plan/`
- **Purpose**: Execute terragrunt plan
- **Features**:
  - Terragrunt binary validation
  - Terragrunt config file detection (terragrunt.hcl)
  - Variable file generation
  - Plan output capture
  - Working directory support (for nested Terragrunt configs)
  - Status determination (success/failed)

#### ✅ `roles/terragrunt_apply/`
- **Purpose**: Execute terragrunt apply
- **Features**:
  - Plan file validation
  - Apply execution with auto-approve
  - Output capture (JSON format)
  - Working directory support
  - Status determination

### 2. Playbooks

#### ✅ `playbooks/terragrunt.yml`
- **Purpose**: Main Terragrunt execution playbook (auto-approve)
- **Flow**:
  1. Clone repository
  2. Execute terragrunt plan
  3. Send plan success/failed callback
  4. Execute terragrunt apply (if plan succeeded)
  5. Send apply success/failed callback

#### ✅ `playbooks/terragrunt-with-approval.yml`
- **Purpose**: Terragrunt execution with approval gating
- **Flow**:
  1. Clone repository
  2. Execute terragrunt plan
  3. Send plan callback (with `waiting_approval` status)
  4. Approval node (AAP workflow)
  5. Validate approval decision
  6. Send approval granted/denied callback
  7. Execute terragrunt apply (only if approved)
  8. Send apply callback

### 3. Workflow Documentation

#### ✅ `workflows/terragrunt-basic.md`
- Documents workflow template: "Terragrunt - Plan + Apply (Auto-Approve)"
- Includes job template configuration
- Documents `use_terragrunt` flag
- Documents `terragrunt_working_dir` variable

#### ✅ `workflows/terragrunt-with-approval.md`
- Documents workflow template: "Terragrunt - Plan → Approval → Apply"
- Includes approval node configuration
- Mirrors Terraform approval workflow structure

---

## Key Differences from Terraform Workflows

1. **Binary**: Uses `terragrunt` instead of `terraform`
2. **Config File**: Looks for `terragrunt.hcl` instead of `terraform.tf`
3. **Working Directory**: Supports `terragrunt_working_dir` for nested configs
4. **Flag**: Uses `use_terragrunt: true` to indicate Terragrunt execution
5. **Environment**: Includes `TERRAGRUNT_LOG` environment variable

---

## Required AAP Workflow Templates

### Template 1: Terragrunt - Plan + Apply (Auto-Approve)

**Job Templates (in order)**:
1. `terragrunt-clone-repo` → Clone repository
2. `terragrunt-plan` → Execute terragrunt plan
3. `terragrunt-plan-callback` → Send plan callback
4. `terragrunt-apply` → Execute terragrunt apply
5. `terragrunt-apply-callback` → Send apply callback

### Template 2: Terragrunt - Plan → Approval → Apply

**Job Templates (in order)**:
1. `terragrunt-approval-clone-repo` → Clone repository
2. `terragrunt-approval-plan` → Execute terragrunt plan
3. `terragrunt-approval-plan-callback` → Send plan callback
4. **Approval Node** → Wait for approval
5. `terragrunt-approval-decision-callback` → Send approval callback
6. `terragrunt-approval-apply` → Execute terragrunt apply (only if approved)
7. `terragrunt-approval-apply-callback` → Send apply callback

---

## Required Extra Variables

```yaml
# Repository configuration
tfc_pattern_repo_name: "org/repo"
tfc_pattern_version: "v1.0.0"

# Workspace configuration
tfc_workspace_name: "workspace-name"
tfc_cloud_provider: "aws"

# Operation
tfc_operation: "create|update"

# Terragrunt-specific
use_terragrunt: true  # Required flag
terragrunt_working_dir: "."  # Optional: subdirectory with terragrunt.hcl

# Terraform variables (passed to Terragrunt)
tfc_variables:
  key: "value"

# Callback configuration
orchestration_callback_url: "https://orchestration-service/api/orchestration/callbacks"
```

---

## Validation Status

✅ Terragrunt plan role implemented  
✅ Terragrunt apply role implemented  
✅ Terragrunt playbook implemented  
✅ Terragrunt with approval playbook implemented  
✅ Workflow documentation created  
✅ Callback contract maintained (same as Terraform)  

---

## Key Design Decisions

1. **Mirror Terraform structure**: Terragrunt workflows mirror Terraform workflows for consistency
2. **Reuse existing roles**: `clone_repo`, `callback_notify`, `approval_wait` are reused
3. **Working directory support**: Supports nested Terragrunt configs via `terragrunt_working_dir`
4. **Flag-based detection**: `use_terragrunt: true` indicates Terragrunt execution
5. **Same callback contract**: Uses identical callback structure as Terraform workflows

---

## Next Phase

**Phase 4: AAP → Terraform Cloud (TFC)**
- Implement TFC workspace role
- Implement TFC plan role
- Implement TFC apply role
- Create TFC playbooks (with and without approval)
- Create workflow documentation

---

## Notes

- Terragrunt workflows are structurally identical to Terraform workflows
- Only difference is the execution binary and config file detection
- All Phase 1 and Phase 2 roles are reused
- Callback contract remains consistent across all orchestration types
