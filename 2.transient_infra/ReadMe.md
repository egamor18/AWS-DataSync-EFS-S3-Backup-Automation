
---

# 🖥️ AWS EC2 Deployment with EFS Integration (Terraform)

This Terraform configuration provisions **multiple EC2 instances** that automatically mount an existing **EFS file system** from a previously deployed infrastructure stack.
It references that stack using **Terraform remote state**, ensuring a modular, layered, and reusable cloud design.

---

## 📋 Overview

### 🔧 Components Created

| Component                  | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| **EC2 Instances**          | Deploys multiple Amazon Linux 2 instances (type: `t3.micro` by default). |
| **Remote State Reference** | Imports outputs from a previously created VPC/EFS infrastructure.        |
| **User Data Script**       | Automatically mounts the shared EFS file system at boot.                 |
| **AMI Lookup**             | Dynamically fetches the latest Amazon Linux 2 AMI.                       |

---

## 🧰 Prerequisites

Before deployment, ensure that:

* The **permanent infrastructure stack** (VPC, Security Group, EFS) has been deployed.
* The state file is available at:

  ```
  ../1.permanent_infra/terraform.tfstate
  ```
* You have:

  ```bash
  terraform -version   # Terraform >= 1.5
  aws sts get-caller-identity   # Valid AWS credentials
  ```

---

## ⚙️ Variables

Defined in `variables.tf`:

| Variable         | Type     | Description                                 | Example                  |
| ---------------- | -------- | ------------------------------------------- | ------------------------ |
| `aws_region`     | `string` | AWS region to deploy resources              | `"eu-central-1"`         |
| `number_of_ec2s` | `number` | Number of EC2 instances to launch           | `2`                      |
| `ec2_user_data`  | `string` | Path to user data script (for mounting EFS) | `"scripts/user_data.sh"` |

### Example `terraform.tfvars`

```hcl
aws_region     = "eu-central-1"
number_of_ec2s = 2
ec2_user_data  = "scripts/user_data.sh"
```

---

## 🚀 Deployment Steps

1. **Navigate to directory**

   ```bash
   cd 2.transient_infra
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Preview resources**

   ```bash
   terraform plan
   ```

4. **Apply changes**

   ```bash
   terraform apply
   ```

5. **Verify deployment**

   ```bash
   aws ec2 describe-instances --filters "Name=tag:Name,Values=web-*"
   ```

6. **Clean up**

   ```bash
   terraform destroy
   ```

---

## 📜 EC2 User Data Script

This script runs automatically on each EC2 instance to install EFS tools and mount the shared file system.

```bash
#!/bin/bash
set -xe

yum update -y
yum install -y amazon-efs-utils nfs-utils
mkdir -p /mnt/efs
mount -t efs ${efs_id}:/ /mnt/efs
echo "${efs_id}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
```

> 💡 **Tip:**
> The `${efs_id}` variable is passed from Terraform using the `templatefile()` function.
> This ensures each instance automatically connects to the correct EFS file system.

---


## 🧠 Notes

* Ensure your **security group** allows inbound NFS (TCP 2049) from EC2 to EFS.
* Use **private subnets** for production workloads.
* Add IAM roles for least-privilege access instead of relying on SSH.
* Manage secrets with **AWS Systems Manager Parameter Store** or **Secrets Manager**.

---

**Author:** *Eric Gamor*
**Region:** `eu-central-1`
**Terraform Version:** `>= 1.5`
**AWS Provider:** `>= 5.0`

---
