# Phase 2: AAP Terraform (With Approval) - Testing Guide

## Prerequisites

Same as Phase 1, plus:
- AAP user with approval permissions
- Understanding of AAP approval node workflow

## Test Scenario 1: Approval Granted Path

### Setup

1. Configure workflow template with approval node
2. Prepare test variables (same as Phase 1)

### Execution Steps

1. Launch workflow from AAP UI
2. Provide test variables
3. Monitor workflow execution
4. **Workflow pauses at approval node**
5. **Approve in AAP UI**
6. Monitor workflow continues
7. Check callbacks received

### Expected Behavior

- Plan executes successfully
- Callback sent: `waiting_approval`
- Workflow pauses at approval node
- User approves in AAP UI
- Callback sent: `approval_granted`
- Apply executes
- Callback sent: `apply_success`

### Expected Callbacks

**1. Plan Success (Waiting for Approval):**
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

**2. Approval Granted:**
```json
{
  "deploymentId": "test-vpc-1705756800",
  "executionId": "1705756800",
  "aapWorkflowJobId": 1234,
  "phase": "approval",
  "status": "success"
}
```

**3. Apply Success:**
```json
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

✅ Plan executes successfully  
✅ Callback sent with `waiting_approval` status  
✅ Workflow pauses at approval node  
✅ Approval granted in AAP UI  
✅ Callback sent: `approval_granted`  
✅ Apply executes after approval  
✅ Callback sent: `apply_success`  

---

## Test Scenario 2: Approval Denied Path

### Execution Steps

1. Launch workflow
2. Monitor execution
3. **Deny approval in AAP UI**
4. Monitor workflow stops
5. Check callbacks received

### Expected Behavior

- Plan executes successfully
- Callback sent: `waiting_approval`
- Workflow pauses at approval node
- User denies in AAP UI
- Callback sent: `approval_denied`
- Workflow stops
- Apply is **skipped**

### Expected Callback

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

### Validation

✅ Plan executes successfully  
✅ Callback sent: `waiting_approval`  
✅ Approval denied in AAP UI  
✅ Callback sent: `approval_denied`  
✅ Workflow stops  
✅ Apply is skipped  

---

## Test Scenario 3: Approval Timeout

### Setup

Configure approval node with short timeout (e.g., 60 seconds) for testing.

### Execution Steps

1. Launch workflow
2. Monitor execution
3. **Do not approve or deny**
4. Wait for timeout
5. Monitor workflow stops
6. Check callbacks received

### Expected Behavior

- Plan executes successfully
- Callback sent: `waiting_approval`
- Workflow pauses at approval node
- Timeout expires
- Workflow stops
- Callback sent: `approval_denied` (with timeout indication)

### Validation

✅ Plan executes successfully  
✅ Callback sent: `waiting_approval`  
✅ Timeout expires  
✅ Workflow stops  
✅ Callback sent: `approval_denied`  

---

## Test Scenario 4: Destroy with Approval

### Execution Steps

1. Launch destroy workflow with approval
2. Monitor execution
3. **Approve in AAP UI**
4. Monitor destroy executes
5. Check callbacks received

### Expected Behavior

- Repository cloned
- Callback sent: `waiting_approval`
- Workflow pauses at approval node
- User approves
- Callback sent: `approval_granted`
- Destroy executes
- Callback sent: `apply_success`

### Validation

✅ Destroy workflow pauses for approval  
✅ Approval granted  
✅ Destroy executes  
✅ Callback sent: `apply_success`  

---

## Manual Verification Checklist

- [ ] Approval node appears in workflow execution
- [ ] Workflow pauses at approval node
- [ ] Approval granted path works correctly
- [ ] Approval denied path works correctly
- [ ] Timeout behavior works correctly
- [ ] Callbacks sent with correct status
- [ ] Apply only runs after approval
- [ ] Destroy workflow requires approval

---

## Troubleshooting

### Issue: Approval node not appearing
**Solution**: Verify approval node is configured in workflow template and connected correctly

### Issue: Approval decision not passed to playbook
**Solution**: Verify `ansible_awx_workflow_approval_status` variable is available (AAP provides this automatically)

### Issue: Apply runs without approval
**Solution**: Check workflow template connections - apply should only run on approval node success path

### Issue: Callback not sent after approval
**Solution**: Verify approval callback tasks run after approval node completes
