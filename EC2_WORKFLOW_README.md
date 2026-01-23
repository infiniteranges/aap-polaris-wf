# EC2 Workflow Setup

## Playbook Location

The EC2-specific playbook is located at:
- `playbooks/terraform-ec2-create-config.yml`

## AAP Configuration

- **Workflow ID**: 78
- **Workflow Name**: EC2 Instance Provisioning - Terraform
- **Job Template 74**: Uses this playbook
- **AAP Project**: 44 (polaris-workflows)

## Workflow Structure

1. terraform-clone-repo (Template 45)
2. terraform-install (Template 73)
3. terraform-create-config (Template 74) - Uses `terraform-ec2-create-config.yml`
4. terraform-plan (Template 46)
5. terraform-apply (Template 47)
6. terraform-apply-callback (Template 49)

## Usage

Once this playbook is committed and pushed to the git repository:
1. Sync AAP project 44
2. Launch workflow 78 with EC2 variables
3. Workflow will properly map EC2 variables to Terraform module

## Variable Mapping

The playbook maps:
- `instance_name` → `name`
- `instance_type` → `instance_type`
- `key_name` → `key_name`
- `subnet_id` → `subnet_id`
- `volume_size` → `root_block_device[0].volume_size`
- `volume_type` → `root_block_device[0].volume_type`
