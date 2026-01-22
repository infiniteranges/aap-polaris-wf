# AAP Playbooks

Main playbooks for Polaris orchestration workflows.

## Playbook Structure

### Terraform Playbooks

The Terraform execution has been split into separate playbooks that can be used as individual job templates in AAP workflows, allowing each step to appear as a separate workflow node:

#### Basic Terraform Workflow (No Approval)
1. **terraform-clone-repo.yml** - Clones the Terraform module repository
2. **terraform-install.yml** - Installs Terraform if not present
3. **terraform-create-config.yml** - Creates the main.tf configuration file
4. **terraform-plan.yml** - Executes terraform plan and sends callbacks
5. **terraform-apply.yml** - Executes terraform apply and sends callbacks

#### Terraform Workflow with Approval
1. **terraform-clone-repo.yml** - Clones the Terraform module repository
2. **terraform-install.yml** - Installs Terraform if not present
3. **terraform-create-config.yml** - Creates the main.tf configuration file
4. **terraform-plan.yml** - Executes terraform plan
5. **terraform-plan-callback.yml** - Sends callback indicating waiting for approval
6. **[AAP Approval Node]** - Manual approval step (configured in AAP workflow)
7. **terraform-approval-check.yml** - Validates approval decision and sends callbacks
8. **terraform-apply.yml** - Executes terraform apply (only if approved)

### Terraform Destroy Playbooks

- `terraform-destroy.yml` - Terraform destroy execution
- `terraform-destroy-with-approval.yml` - Terraform destroy with approval

### Terragrunt Playbooks

- `terragrunt.yml` - Terragrunt execution playbook
- `terragrunt-with-approval.yml` - Terragrunt execution with approval

### Terraform Cloud Playbooks

- `tfc.yml` - Terraform Cloud execution playbook
- `tfc-with-approval.yml` - Terraform Cloud execution with approval

## Using Modular Playbooks in AAP Workflow

**Note:** The Terraform playbooks now use a modular structure. Each step is a separate playbook that should be configured as individual job templates in AAP.

### Required Job Templates

1. **Job Template: terraform-clone-repo**
   - Playbook: `terraform-clone-repo.yml`
   - Inventory: localhost

2. **Job Template: terraform-install**
   - Playbook: `terraform-install.yml`
   - Inventory: localhost

3. **Job Template: terraform-create-config**
   - Playbook: `terraform-create-config.yml`
   - Inventory: localhost

4. **Job Template: terraform-plan**
   - Playbook: `terraform-plan.yml`
   - Inventory: localhost

5. **Job Template: terraform-plan-callback** (for approval workflows only)
   - Playbook: `terraform-plan-callback.yml`
   - Inventory: localhost

6. **Job Template: terraform-approval-check** (for approval workflows only)
   - Playbook: `terraform-approval-check.yml`
   - Inventory: localhost

7. **Job Template: terraform-apply**
   - Playbook: `terraform-apply.yml`
   - Inventory: localhost

### Workflow Configuration

Create a workflow template that chains these job templates together in sequence. This allows each step to appear as a separate node in the workflow execution, making it easier to track progress and debug issues.

See `WORKFLOW-SETUP.md` for detailed instructions on setting up the workflow templates.

## Benefits of Modular Structure

- **Better Visibility**: Each step appears as a separate workflow node
- **Easier Debugging**: Can see exactly which step failed
- **Better Logging**: Logs are separated by step
- **Flexibility**: Can easily add/remove steps or reorder them
- **Parallel Execution**: Some steps could potentially run in parallel
