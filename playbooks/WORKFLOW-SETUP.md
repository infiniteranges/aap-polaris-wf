# Modular Terraform Workflow Setup Guide

This guide explains how to set up AAP workflows using the modular playbooks, where each step appears as a separate workflow node.

## Overview

The Terraform execution has been split into separate playbooks:
- `terraform-clone-repo.yml` - Clone repository
- `terraform-install.yml` - Install Terraform
- `terraform-create-config.yml` - Create main.tf
- `terraform-plan.yml` - Execute terraform plan
- `terraform-plan-callback.yml` - Send plan callback (for approval workflows)
- `terraform-approval-check.yml` - Validate approval (for approval workflows)
- `terraform-apply.yml` - Execute terraform apply

## Step 1: Create Job Templates in AAP

Create the following job templates in AAP:

### 1. terraform-clone-repo
- **Name**: `terraform-clone-repo`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-clone-repo.yml`
- **Variables**: Same as current terraform workflow (tfc_pattern_repo_name, tfc_pattern_version, tfc_workspace_name, etc.)

### 2. terraform-install
- **Name**: `terraform-install`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-install.yml`
- **Variables**: Same as current terraform workflow

### 3. terraform-create-config
- **Name**: `terraform-create-config`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-create-config.yml`
- **Variables**: Same as current terraform workflow

### 4. terraform-plan
- **Name**: `terraform-plan`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-plan.yml`
- **Variables**: Same as current terraform workflow

### 5. terraform-plan-callback (for approval workflows)
- **Name**: `terraform-plan-callback`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-plan-callback.yml`
- **Variables**: Same as current terraform workflow

### 6. terraform-approval-check (for approval workflows)
- **Name**: `terraform-approval-check`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-approval-check.yml`
- **Variables**: Same as current terraform workflow

### 7. terraform-apply
- **Name**: `terraform-apply`
- **Job Type**: Run
- **Inventory**: localhost
- **Playbook**: `terraform-apply.yml`
- **Variables**: Same as current terraform workflow

## Step 2: Create Workflow Template (Basic - No Approval)

Create a workflow template with the following nodes in order:

1. **terraform-clone-repo** (Job Template)
2. **terraform-install** (Job Template)
3. **terraform-create-config** (Job Template)
4. **terraform-plan** (Job Template)
5. **terraform-apply** (Job Template)

**Success Path**: All nodes should connect in sequence (each node's success connects to the next).

**Failure Path**: Any node failure should stop the workflow.

## Step 3: Create Workflow Template (With Approval)

Create a workflow template with the following nodes in order:

1. **terraform-clone-repo** (Job Template)
2. **terraform-install** (Job Template)
3. **terraform-create-config** (Job Template)
4. **terraform-plan** (Job Template)
5. **terraform-plan-callback** (Job Template)
6. **[Approval Node]** (Workflow Approval - configured in AAP)
7. **terraform-approval-check** (Job Template)
8. **terraform-apply** (Job Template)

**Success Path**: 
- Clone → Install → Create Config → Plan → Plan Callback → Approval → Approval Check → Apply

**Failure Path**: 
- If plan fails, stop at terraform-plan
- If approval is denied, stop at terraform-approval-check
- If apply fails, stop at terraform-apply

## Benefits

- **Better Visibility**: Each step appears as a separate node in the workflow execution
- **Easier Debugging**: Can see exactly which step failed
- **Better Logging**: Logs are separated by step
- **Flexibility**: Can easily add/remove steps or reorder them
- **Progress Tracking**: Can see progress through each step in real-time

## State Management

The playbooks use JSON files to pass state between workflow nodes:
- `/tmp/workspaces/{workspace_name}/.plan_status.json` - Contains plan status and output

This allows subsequent nodes to know the results of previous steps.
