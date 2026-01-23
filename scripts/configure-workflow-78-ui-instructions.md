# Configure Workflow 78 Node Dependencies in AAP UI

## Problem
All nodes are running in parallel from START, but they should run sequentially with proper dependencies.

## Solution
Configure node connections in AAP UI Visualizer.

## Steps

1. **Open Workflow Visualizer**
   - Go to: https://sc-awx.r53.infiniteranges.com/#/templates/workflow_job_template/78/visualizer

2. **Remove All Existing Connections**
   - Click on each node connection line from START
   - Delete all connections (they should all go from START currently)

3. **Create Sequential Connections**
   
   **Step 1:** Connect START → clone-repo
   - Click START node
   - Drag to clone-repo node
   - Select "On Success"
   
   **Step 2:** Connect clone-repo → install-terraform
   - Click clone-repo node
   - Drag to install-terraform node
   - Select "On Success"
   
   **Step 3:** Connect clone-repo → create-config
   - Click clone-repo node
   - Drag to create-config node
   - Select "On Success"
   
   **Step 4:** Connect install-terraform → terraform-plan
   - Click install-terraform node
   - Drag to terraform-plan node
   - Select "On Success"
   
   **Step 5:** Connect create-config → terraform-plan (CONVERGENCE)
   - Click create-config node
   - Drag to terraform-plan node
   - Select "On Success"
   - **IMPORTANT:** Right-click the terraform-plan node
   - Select "Convergence" → "All parents must converge"
   - This ensures plan waits for BOTH install AND config
   
   **Step 6:** Connect terraform-plan → terraform-apply
   - Click terraform-plan node
   - Drag to terraform-apply node
   - Select "On Success"
   
   **Step 7:** Connect terraform-apply → apply-callback
   - Click terraform-apply node
   - Drag to apply-callback node
   - Select "On Success"

4. **Save the Workflow**
   - Click "Save" button

## Expected Flow After Configuration

```
START
  ↓
clone-repo
  ↓
  ├─→ install-terraform
  └─→ create-config
       ↓ (both converge)
    terraform-plan
       ↓
    terraform-apply
       ↓
    apply-callback
```

## Verification

After configuration, launch a test workflow and verify:
- Only clone-repo runs first
- install and config run in parallel after clone completes
- plan runs only after BOTH install and config complete
- apply runs only after plan completes
- callback runs only after apply completes
