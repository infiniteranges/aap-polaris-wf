# AAP Polaris Workflows - Deployment Guide

## Prerequisites

1. **Ansible Automation Platform (AAP) 2.4+** installed and accessible
2. **AAP API access** (for automation) or **AAP UI access** (for manual setup)
3. **Execution node** with:
   - Terraform installed (for Terraform workflows)
   - Terragrunt installed (for Terragrunt workflows)
   - Python 3.9+ with `ansible` and `requests` libraries
4. **Credentials configured**:
   - AWS credentials (for Terraform/Terragrunt)
   - TFC API token (for TFC workflows)
   - Git credentials (if using private repositories)

---

## Step 1: Import Playbooks and Roles to AAP

### Option A: Manual Import via AAP UI

1. **Access AAP UI**: Navigate to your AAP instance
2. **Import Project**:
   - Go to **Resources → Projects**
   - Click **Add**
   - Name: `polaris-workflows`
   - SCM Type: `Git`
   - SCM URL: `git@github.com:infiniteranges/aap-polaris-wf.git`
   - SCM Branch: `main`
   - Click **Save**

3. **Sync Project**:
   - Click **Sync** button on the project
   - Wait for sync to complete

### Option B: Import via AAP API

```bash
# Set AAP credentials
export AAP_URL="https://your-aap-instance.com"
export AAP_USERNAME="admin"
export AAP_PASSWORD="your-password"

# Create project
curl -X POST "${AAP_URL}/api/v2/projects/" \
  -u "${AAP_USERNAME}:${AAP_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "polaris-workflows",
    "scm_type": "git",
    "scm_url": "git@github.com:infiniteranges/aap-polaris-wf.git",
    "scm_branch": "main"
  }'

# Sync project
PROJECT_ID=$(curl -s -u "${AAP_USERNAME}:${AAP_PASSWORD}" \
  "${AAP_URL}/api/v2/projects/?name=polaris-workflows" | jq -r '.results[0].id')

curl -X POST "${AAP_URL}/api/v2/projects/${PROJECT_ID}/update/" \
  -u "${AAP_USERNAME}:${AAP_PASSWORD}"
```

---

## Step 2: Create Job Templates

### Create Job Templates for Terraform Workflow

#### 2.1: Clone Repository Job Template

1. Go to **Resources → Templates**
2. Click **Add → Add job template**
3. Configure:
   - **Name**: `terraform-clone-repo`
   - **Job Type**: `Run`
   - **Inventory**: Select your execution node inventory
   - **Project**: `polaris-workflows`
   - **Playbook**: `playbooks/terraform.yml`
   - **Limit**: `localhost`
   - **Verbosity**: `1`
   - **Options**: 
     - ✅ Enable fact cache
     - ✅ Use fact cache
   - **Extra Variables**: Leave empty (will be passed from workflow)
4. Click **Save**

#### 2.2: Terraform Plan Job Template

1. Create new job template
2. Configure:
   - **Name**: `terraform-plan`
   - **Job Type**: `Run`
   - **Inventory**: Select your execution node inventory
   - **Project**: `polaris-workflows`
   - **Playbook**: `playbooks/terraform.yml`
   - **Limit**: `localhost`
   - **Credentials**: Add AWS credentials (or cloud provider credentials)
   - **Extra Variables**: Leave empty
3. Click **Save**

#### 2.3: Terraform Apply Job Template

1. Create new job template
2. Configure:
   - **Name**: `terraform-apply`
   - **Job Type**: `Run`
   - **Inventory**: Select your execution node inventory
   - **Project**: `polaris-workflows`
   - **Playbook**: `playbooks/terraform.yml`
   - **Limit**: `localhost`
   - **Credentials**: Add AWS credentials
   - **Extra Variables**: Leave empty
3. Click **Save**

#### 2.4: Callback Job Templates

Create callback job templates:
- `terraform-plan-callback`
- `terraform-apply-callback`

Each should:
- Use `playbooks/terraform.yml` playbook
- Run on `localhost`
- No credentials needed

---

## Step 3: Create Workflow Templates

### 3.1: Terraform - Plan + Apply (Auto-Approve)

1. Go to **Resources → Templates**
2. Click **Add → Add workflow template**
3. Configure:
   - **Name**: `terraform-plan-apply-auto`
   - **Inventory**: Select your execution node inventory
   - **Project**: `polaris-workflows`
4. Click **Save**

5. **Build Workflow**:
   - Click **Visualizer** tab
   - Add job templates in order:
     1. `terraform-clone-repo` (Start node)
     2. `terraform-plan` (depends on: clone-repo, on success)
     3. `terraform-plan-callback` (depends on: plan, on success)
     4. `terraform-apply` (depends on: plan-callback, on success)
     5. `terraform-apply-callback` (depends on: apply, on success)
   - Connect nodes with success paths
   - Click **Save**

6. **Configure Extra Variables**:
   - Go to **Variables** tab
   - Add variables as **Prompt on launch**:
     ```yaml
     tfc_pattern_repo_name: ""
     tfc_pattern_version: ""
     tfc_workspace_name: ""
     tfc_cloud_provider: ""
     tfc_operation: "create"
     tfc_variables: {}
     orchestration_callback_url: ""
     ```

### 3.2: Terraform - Plan → Approval → Apply

1. Create workflow template: `terraform-plan-approval-apply`
2. Build workflow:
   1. `terraform-clone-repo` (Start)
   2. `terraform-plan` (on success)
   3. `terraform-plan-callback` (on success)
   4. **Approval Node** (on success)
      - Name: `terraform-approval-node`
      - Timeout: `3600` seconds
      - Can Approve: Select users/groups
   5. `terraform-approval-decision-callback` (on approved/denied)
   6. `terraform-apply` (on approved only)
   7. `terraform-apply-callback` (on success/failure)

### 3.3: Terragrunt Workflows

Repeat steps 3.1 and 3.2 using:
- Playbook: `playbooks/terragrunt.yml`
- Job template names: `terragrunt-*`
- Add `use_terragrunt: true` to extra variables

### 3.4: TFC Workflows

Repeat steps 3.1 and 3.2 using:
- Playbook: `playbooks/tfc.yml`
- Job template names: `tfc-*`
- Add `use_tfc: true` to extra variables
- Add `tfc_organization` and `tfc_api_token` to extra variables

---

## Step 4: Configure Credentials

### 4.1: AWS Credentials

1. Go to **Resources → Credentials**
2. Click **Add → Add credential**
3. Configure:
   - **Name**: `aws-terraform-credentials`
   - **Credential Type**: `Amazon Web Services`
   - **Access Key ID**: Your AWS access key
   - **Secret Access Key**: Your AWS secret key
   - **Session Token**: (Optional, for temporary credentials)
4. Click **Save**

### 4.2: TFC API Token

1. Create credential:
   - **Name**: `tfc-api-token`
   - **Credential Type**: `Generic`
   - **Input Configuration**:
     - Add field: `tfc_api_token` (Type: String, Secret: Yes)
   - **Injector Configuration**:
     - Add: `tfc_api_token: "{{ tfc_api_token }}"`

### 4.3: Git Credentials (if needed)

1. Create credential:
   - **Name**: `git-credentials`
   - **Credential Type**: `Source Control`
   - Configure Git username/password or SSH key

---

## Step 5: Configure Execution Environment

### 5.1: Verify Execution Node Setup

On your AAP execution node, verify:

```bash
# Check Terraform
terraform version

# Check Terragrunt
terragrunt version

# Check Python/Ansible
python3 --version
ansible --version

# Check required Python libraries
pip3 list | grep -E "(ansible|requests)"
```

### 5.2: Install Missing Dependencies

```bash
# Install Terraform (if missing)
# Follow: https://developer.hashicorp.com/terraform/downloads

# Install Terragrunt (if missing)
# Follow: https://terragrunt.gruntwork.io/docs/getting-started/install/

# Install Python dependencies
pip3 install ansible requests
```

---

## Step 6: Test Workflows

### 6.1: Test Terraform Workflow

1. Launch workflow: `terraform-plan-apply-auto`
2. Provide test variables:
   ```yaml
   tfc_pattern_repo_name: "terraform-aws-modules/terraform-aws-vpc"
   tfc_pattern_version: "v5.0.0"
   tfc_workspace_name: "test-vpc-$(date +%s)"
   tfc_cloud_provider: "aws"
   tfc_operation: "create"
   tfc_variables:
     name: "test-vpc"
     cidr: "10.0.0.0/16"
     aws_region: "us-east-1"
   orchestration_callback_url: "https://your-orchestration-service/api/orchestration/callbacks"
   ```
3. Monitor execution
4. Verify callbacks received

### 6.2: Test Approval Workflow

1. Launch workflow: `terraform-plan-approval-apply`
2. Provide same test variables
3. Monitor execution
4. **Approve** when workflow pauses at approval node
5. Verify workflow continues
6. Verify callbacks received

### 6.3: Test Terragrunt Workflow

1. Launch workflow: `terragrunt-plan-apply-auto`
2. Add `use_terragrunt: true` to variables
3. Monitor execution
4. Verify Terragrunt commands execute

### 6.4: Test TFC Workflow

1. Launch workflow: `tfc-plan-apply-auto`
2. Add TFC variables:
   ```yaml
   use_tfc: true
   tfc_organization: "your-org"
   tfc_api_token: "your-token"
   ```
3. Monitor execution
4. Verify TFC API calls
5. Verify callbacks received

---

## Step 7: Integration with Orchestration Service

### 7.1: Configure Callback Endpoints

Ensure your orchestration service has these endpoints:

- `POST /api/orchestration/callbacks/plan_success`
- `POST /api/orchestration/callbacks/plan_failed`
- `POST /api/orchestration/callbacks/apply_success`
- `POST /api/orchestration/callbacks/apply_failed`
- `POST /api/orchestration/callbacks/approval_granted`
- `POST /api/orchestration/callbacks/approval_denied`

### 7.2: Test Callback Integration

1. Launch a test workflow
2. Monitor orchestration service logs
3. Verify callbacks are received
4. Verify callback payload structure matches expected format

---

## Troubleshooting

### Issue: Role not found (e.g., "the role 'clone_repo' was not found")
**Solution**: 
- Ensure `ansible.cfg` exists in the project root with `roles_path = roles`
- Verify the project structure has `roles/` directory at the root level
- Sync the project again after adding `ansible.cfg`
- Verify the playbook path is correct (e.g., `playbooks/terraform.yml`)

### Issue: Playbook not found
**Solution**: Ensure project is synced and playbook path is correct

### Issue: Terraform/Terragrunt not found
**Solution**: Install on execution node or use execution environment with tools pre-installed

### Issue: Callbacks not received
**Solution**: 
- Verify `orchestration_callback_url` is correct
- Check network connectivity from AAP to orchestration service
- Verify orchestration service endpoints are accessible

### Issue: Approval node not appearing
**Solution**: Verify approval node is configured in workflow template and connected correctly

### Issue: TFC API errors
**Solution**: 
- Verify TFC API token is valid
- Check TFC organization name is correct
- Verify workspace permissions

---

## Validation Checklist

- [ ] All playbooks imported to AAP
- [ ] All roles available in AAP
- [ ] Job templates created for all workflows
- [ ] Workflow templates created
- [ ] Credentials configured (AWS, TFC, Git)
- [ ] Execution node has required tools
- [ ] Test workflow executes successfully
- [ ] Callbacks received by orchestration service
- [ ] Approval workflows work correctly

---

## Next Steps After Deployment

1. **Production Hardening**:
   - Set up proper credential management
   - Configure execution environments
   - Set up monitoring and alerting

2. **Documentation**:
   - Document organization-specific workflows
   - Create runbooks for common operations
   - Document troubleshooting procedures

3. **Integration**:
   - Integrate with CI/CD pipelines
   - Set up automated testing
   - Configure notification systems
