# Quick Start Guide

## 5-Minute Setup

### Step 1: Clone Repository (if not already done)

```bash
git clone git@github.com:infiniteranges/aap-polaris-wf.git
cd aap-polaris-wf
```

### Step 2: Validate Setup

```bash
chmod +x scripts/validate-setup.sh
./scripts/validate-setup.sh
```

### Step 3: Import to AAP

#### Via AAP UI:
1. Go to **Resources → Projects**
2. Click **Add**
3. Configure:
   - Name: `polaris-workflows`
   - SCM Type: `Git`
   - SCM URL: `git@github.com:infiniteranges/aap-polaris-wf.git`
   - SCM Branch: `main`
4. Click **Save** and **Sync**

#### Via API:
```bash
# Set your AAP credentials
export AAP_URL="https://your-aap-instance.com"
export AAP_USERNAME="admin"
export AAP_PASSWORD="your-password"

# Run import script (create this if needed)
./scripts/import-to-aap.sh
```

### Step 4: Create First Workflow Template

1. **Create Job Templates** (in AAP UI):
   - `terraform-clone-repo` → Playbook: `playbooks/terraform.yml`
   - `terraform-plan` → Playbook: `playbooks/terraform.yml`
   - `terraform-apply` → Playbook: `playbooks/terraform.yml`

2. **Create Workflow Template**:
   - Name: `terraform-basic-test`
   - Add job templates in order: Clone → Plan → Apply
   - Connect with success paths

3. **Configure Variables** (Prompt on launch):
   ```yaml
   tfc_pattern_repo_name: ""
   tfc_pattern_version: ""
   tfc_workspace_name: ""
   tfc_cloud_provider: "aws"
   tfc_operation: "create"
   tfc_variables: {}
   orchestration_callback_url: ""
   ```

### Step 5: Test Workflow

1. Launch workflow
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
   orchestration_callback_url: "http://localhost:3000/api/orchestration/callbacks"
   ```
3. Monitor execution
4. Verify callbacks (if orchestration service is running)

### Step 6: Test Callback Endpoint

```bash
chmod +x scripts/test-callback.sh
./scripts/test-callback.sh http://localhost:3000/api/orchestration/callbacks plan_success
```

---

## Common Workflows

### Terraform - Basic
- **Workflow**: `terraform-plan-apply-auto`
- **Use Case**: Quick infrastructure provisioning without approval

### Terraform - With Approval
- **Workflow**: `terraform-plan-approval-apply`
- **Use Case**: Production deployments requiring approval

### Terragrunt - Basic
- **Workflow**: `terragrunt-plan-apply-auto`
- **Use Case**: Terragrunt-based infrastructure

### Terraform Cloud - Basic
- **Workflow**: `tfc-plan-apply-auto`
- **Use Case**: TFC-managed infrastructure

---

## Troubleshooting

### Playbook not found
- Ensure project is synced in AAP
- Check playbook path is correct

### Terraform not found
- Install Terraform on execution node
- Or use execution environment with Terraform pre-installed

### Callbacks not working
- Verify `orchestration_callback_url` is correct
- Test callback endpoint: `./scripts/test-callback.sh`
- Check network connectivity

---

## Next Steps

1. **Read Full Documentation**: See `DEPLOYMENT-GUIDE.md`
2. **Configure Credentials**: Set up AWS, TFC, Git credentials in AAP
3. **Create All Workflows**: Follow workflow documentation in `workflows/` directory
4. **Integrate**: Connect to your orchestration service

---

## Support

- **Documentation**: See `docs/` directory
- **Workflow Examples**: See `workflows/` directory
- **Phase Summaries**: See `docs/phase-*-summary.md`
