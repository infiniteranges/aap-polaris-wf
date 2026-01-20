# Phase 1: AAP Terraform (No Approval) - Testing Guide

## Prerequisites

1. AAP instance accessible
2. Terraform installed on AAP execution node
3. Git repository accessible
4. AWS credentials configured (or target cloud provider)
5. Orchestration service running and accessible

## Test Scenario 1: Terraform Plan + Apply (Success Path)

### Setup

1. **Prepare test repository**:
   ```bash
   # Use a simple Terraform module for testing
   # Example: terraform-aws-modules/terraform-aws-vpc
   ```

2. **Configure AAP Workflow Template**:
   - Create workflow: "Terraform - Plan + Apply (Auto-Approve)"
   - Add job templates as documented in `workflows/terraform-basic.md`
   - Configure extra_vars as prompt on launch

3. **Prepare test variables**:
   ```yaml
   tfc_pattern_repo_name: "terraform-aws-modules/terraform-aws-vpc"
   tfc_pattern_version: "v5.0.0"
   tfc_workspace_name: "test-vpc-{{ ansible_date_time.epoch }}"
   tfc_cloud_provider: "aws"
   tfc_operation: "create"
   tfc_variables:
     name: "test-vpc"
     cidr: "10.0.0.0/16"
     aws_region: "us-east-1"
   orchestration_callback_url: "https://sc-demo-orch.r53.infiniteranges.com/api/orchestration/callbacks"
   ```

### Execution Steps

1. Launch workflow from AAP UI
2. Provide test variables
3. Monitor workflow execution
4. Check orchestration service logs for callbacks

### Expected Logs

**AAP Workflow Execution:**
```
=== Terraform Execution Started ===
Operation: create
Repository: terraform-aws-modules/terraform-aws-vpc
Version: v5.0.0
Workspace: test-vpc-1705756800

TASK [clone_repo : Clone repository] ***
Repository cloned successfully
URL: terraform-aws-modules/terraform-aws-vpc
Version: v5.0.0
Destination: /tmp/workspaces/test-vpc-1705756800

TASK [terraform_plan : Execute terraform plan] ***
Terraform plan completed
Status: success
Return code: 0
Plan file: /tmp/workspaces/test-vpc-1705756800/tfplan

TASK [callback_notify : Send callback to orchestration service] ***
Callback sent successfully to https://.../api/orchestration/callbacks/plan_success

TASK [terraform_apply : Execute terraform apply] ***
Terraform apply completed
Status: success
Return code: 0
Outputs captured: True

TASK [callback_notify : Send callback to orchestration service] ***
Callback sent successfully to https://.../api/orchestration/callbacks/apply_success
```

**Orchestration Service Callbacks:**
```
POST /api/orchestration/callbacks/plan_success
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "success",
  "planOutput": "Plan: 5 to add, 0 to change, 0 to destroy..."
}

POST /api/orchestration/callbacks/apply_success
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "apply",
  "status": "success",
  "outputs": {
    "vpc_id": "vpc-12345678"
  }
}
```

### Validation

✅ Repository cloned successfully  
✅ Terraform plan executed and captured  
✅ Plan callback received by orchestration service  
✅ Terraform apply executed successfully  
✅ Outputs captured and stored  
✅ Apply callback received by orchestration service  

---

## Test Scenario 2: Terraform Plan Failure

### Setup

Use invalid Terraform configuration or missing variables.

### Execution Steps

1. Launch workflow with invalid configuration
2. Monitor workflow execution
3. Check for failure callback

### Expected Behavior

- Plan phase fails
- Callback sent to `plan_failed` endpoint
- Apply phase skipped
- Workflow stops

### Expected Callback

```json
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "plan",
  "status": "failed",
  "error": "Error: Missing required argument: cidr"
}
```

---

## Test Scenario 3: Terraform Destroy

### Setup

Use existing deployment that was created in Test 1.

### Execution Steps

1. Launch destroy workflow
2. Provide workspace name from Test 1
3. Monitor execution

### Expected Behavior

- Repository cloned
- Terraform initialized
- Destroy executed
- Callback sent

### Validation

✅ Infrastructure destroyed  
✅ Destroy callback received  

---

## Test Scenario 4: Callback Failure Injection

### Setup

Point callback URL to invalid endpoint.

### Execution Steps

1. Launch workflow with invalid `orchestration_callback_url`
2. Monitor callback retry behavior

### Expected Behavior

- Callback attempts retry (3 times with 5s delay)
- Workflow continues (ignore_errors: true)
- Warning logged in AAP

---

## Manual Verification Checklist

- [ ] Workflow executes all job templates in order
- [ ] Plan output is captured correctly
- [ ] Apply outputs are captured correctly
- [ ] Callbacks are sent with correct payload structure
- [ ] Orchestration service receives and processes callbacks
- [ ] Failure scenarios trigger appropriate callbacks
- [ ] Destroy workflow works independently

---

## Troubleshooting

### Issue: Terraform binary not found
**Solution**: Install Terraform on AAP execution node or use execution environment with Terraform

### Issue: Callback not received
**Solution**: 
- Verify `orchestration_callback_url` is correct
- Check network connectivity from AAP to orchestration service
- Verify orchestration service callback endpoints are accessible

### Issue: Plan file not found during apply
**Solution**: Ensure plan phase completes successfully before apply phase runs

### Issue: Git clone fails
**Solution**: 
- Verify repository URL is correct
- Check Git credentials if private repository
- Verify network access to Git repository
