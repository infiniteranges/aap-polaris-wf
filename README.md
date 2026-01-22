# AAP Polaris Workflows

Ansible Automation Platform (AAP) workflows, playbooks, and roles for Polaris orchestration.

## 🎯 Overview

All Terraform, Terragrunt, and Terraform Cloud execution happens **exclusively via AAP workflows**.

- **AAP is the primary orchestration engine**
- **No direct Terraform/TFC calls from backend services**
- **All executions support callbacks**
- **Approval via AAP workflow approval nodes**

---

## 🚀 Quick Start

### 1. Validate Setup

```bash
./scripts/validate-setup.sh
```

### 2. Import to AAP

```bash
export AAP_URL="https://your-aap-instance.com"
export AAP_USERNAME="admin"
export AAP_PASSWORD="your-password"
./scripts/import-to-aap.sh
```

### 3. Create Workflow Templates

Follow the [Quick Start Guide](docs/QUICK-START.md) or [Deployment Guide](docs/DEPLOYMENT-GUIDE.md).

---

## 📁 Repository Structure

```
aap-polaris-wf/
├── playbooks/          # Main AAP playbooks
│   ├── terraform.yml
│   ├── terraform-with-approval.yml
│   ├── terragrunt.yml
│   ├── terragrunt-with-approval.yml
│   ├── tfc.yml
│   └── tfc-with-approval.yml
│
├── roles/              # Reusable Ansible roles
│   ├── callback_notify/
│   ├── clone_repo/
│   ├── terraform_plan/
│   ├── terraform_apply/
│   ├── terragrunt_plan/
│   ├── terragrunt_apply/
│   ├── approval_wait/
│   ├── tfc_workspace/
│   ├── tfc_plan/
│   └── tfc_apply/
│
├── workflows/          # Workflow template documentation
│   ├── terraform-basic.md
│   ├── terraform-with-approval.md
│   ├── terragrunt-basic.md
│   ├── terragrunt-with-approval.md
│   ├── tfc-basic.md
│   └── tfc-with-approval.md
│
├── scripts/            # Utility scripts
│   ├── validate-setup.sh
│   ├── import-to-aap.sh
│   └── test-callback.sh
│
└── docs/               # Documentation
    ├── QUICK-START.md
    ├── DEPLOYMENT-GUIDE.md
    ├── INTEGRATION-GUIDE.md
    ├── phase-1-summary.md
    ├── phase-2-summary.md
    ├── phase-3-summary.md
    ├── phase-4-summary.md
    └── IMPLEMENTATION-COMPLETE.md
```

---

## 🧩 Orchestration Types

### 1. Terraform (Local Execution)
- ✅ Plan + Apply (auto-approve)
- ✅ Plan → Approval → Apply
- ✅ Destroy (auto-approve)
- ✅ Destroy (with approval)

### 2. Terragrunt (Local Execution)
- ✅ Plan + Apply (auto-approve)
- ✅ Plan → Approval → Apply

### 3. Terraform Cloud (API Execution)
- ✅ Plan + Apply (auto-approve)
- ✅ Plan → Approval → Apply

---

## 📚 Documentation

- **[Quick Start Guide](docs/QUICK-START.md)** - Get started in 5 minutes
- **[Deployment Guide](docs/DEPLOYMENT-GUIDE.md)** - Complete deployment instructions
- **[Integration Guide](docs/INTEGRATION-GUIDE.md)** - Integrate with orchestration service
- **[Workflow Documentation](workflows/)** - Detailed workflow template docs
- **[Phase Summaries](docs/)** - Implementation details for each phase

---

## 🔧 Requirements

- Ansible Automation Platform (AAP) 2.4+
- Ansible 2.14+
- Python 3.9+
- Terraform (for Terraform workflows)
- Terragrunt (for Terragrunt workflows)
- TFC API token (for TFC workflows)

---

## 🧪 Testing

### Validate Setup

```bash
./scripts/validate-setup.sh
```

### Test Callback Endpoint

```bash
./scripts/test-callback.sh \
  http://localhost:3000/api/orchestration/callbacks \
  plan_success
```

---

## 📡 Callback Contract

All workflows send callbacks to the orchestration service with this structure:

```json
{
  "deploymentId": "string",
  "executionId": "string",
  "aapWorkflowJobId": 1234,
  "phase": "plan|apply|approval|destroy",
  "status": "success|failed|waiting_approval",
  "outputs": {},
  "error": "string|null",
  "planOutput": "string|null",
  "terraformRunId": "string|null",
  "timestamp": "2026-01-20T12:00:00Z"
}
```

See [Integration Guide](docs/INTEGRATION-GUIDE.md) for details.

---

## 🛠️ Scripts

- **`validate-setup.sh`** - Validate local setup and dependencies
- **`import-to-aap.sh`** - Import project to AAP via API
- **`test-callback.sh`** - Test callback endpoint

---

## 📋 Implementation Status

✅ **Phase 0**: Repository Baseline  
✅ **Phase 1**: AAP Terraform (No Approval)  
✅ **Phase 2**: AAP Terraform (With Approval)  
✅ **Phase 3**: AAP Terragrunt  
✅ **Phase 4**: AAP → Terraform Cloud (TFC)  

**Status: COMPLETE** 🎉

---

## 🔗 Links

- [Quick Start](docs/QUICK-START.md)
- [Deployment Guide](docs/DEPLOYMENT-GUIDE.md)
- [Integration Guide](docs/INTEGRATION-GUIDE.md)
- [Implementation Complete](docs/IMPLEMENTATION-COMPLETE.md)

---

## 📝 License

MIT

---

## 🤝 Support

For questions or issues:
- See documentation in `docs/` directory
- See workflow examples in `workflows/` directory
- See phase summaries for implementation details
