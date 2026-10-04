# tf-vcs-workflow

Terraform HCP VCS-driven workflow project using two separate workspaces for networking and compute, with OPA policy enforcement.

## Architecture

```
tf-vcs-workflow/
├── networking/       # HCP Workspace: tf-vcs-networking
├── compute/          # HCP Workspace: tf-vcs-compute
└── opa-policies/     # OPA policy set: tf-vcs-policy-set
    └── policies/
```

## Workspaces

### tf-vcs-networking
Provisions the core network infrastructure:
- VPC (`10.0.0.0/16`)
- Dashboard public subnet (`10.0.10.0/24`)
- Counting private subnet (`10.0.20.0/24`)
- Internet Gateway
- NAT Gateway + Elastic IP
- Route tables for public and private subnets

### tf-vcs-compute
Provisions compute resources — reads VPC and subnet IDs from the networking workspace via `terraform_remote_state`:
- Dashboard EC2 instance (public subnet)
- Counting EC2 instance (private subnet)
- Dashboard security group (ports 22, 80, 9009)
- Counting security group (ports 22, 9009 from dashboard SG only)
- SSH key pair (ED25519)
- Elastic IP for dashboard instance

## OPA Policies

Policies are enforced on every plan via the `tf-vcs-policy-set` policy set.

| Policy | Enforcement | Rule |
|---|---|---|
| `enforce-instance-type` | Mandatory | Only `t3.micro` allowed |
| `enforce-tags` | Advisory | EC2 instances must have `Name` and `Department` tags |
| `enforce-region` | Advisory | Only `eu-west-2` region allowed |
| `deny-unrestricted-ssh` | Advisory | No `0.0.0.0/0` on port 22 in security groups |

## HCP Terraform Setup

### Prerequisites
- HCP Terraform organization: `CloudIX`
- VCS connection to `PAZ-9/tf-vcs-workflow`
- AWS credentials set as environment variables in each workspace

### Workspace Variables (both workspaces)

| Key | Category |
|---|---|
| `AWS_ACCESS_KEY_ID` | Environment |
| `AWS_SECRET_ACCESS_KEY` | Environment (sensitive) |
| `AWS_DEFAULT_REGION` | Environment |

### Run Order
1. Apply `tf-vcs-networking` first
2. Enable remote state sharing on `tf-vcs-networking` → add `tf-vcs-compute`
3. Apply `tf-vcs-compute`

## Region
`eu-west-2` (London)
