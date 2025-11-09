
---

# 🏗️ AWS VPC + Security Groups + EFS Infrastructure (Terraform)

This Terraform configuration deploys a **basic AWS network and shared storage architecture** designed for web applications that need a common file system accessible by multiple EC2 instances.
It sets up a **VPC**, **security groups**, and a **highly available EFS file system** with mount targets in two Availability Zones.

---

## 📋 Overview

### 🔧 Components Created

| Component             | Description                                                                                        |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| **VPC**               | A custom Virtual Private Cloud with two public subnets across AZs in `eu-central-1`.               |
| **Security Group**    | Allows SSH (22), HTTPS (443), and NFS (2049) traffic between EC2 instances and EFS within the VPC. |
| **EFS File System**   | A shared file system automatically transitioning data to Infrequent Access after 30 days.          |
| **EFS Mount Targets** | Two mount targets (one per AZ) providing low-latency access to the EFS from EC2 instances.         |

---

## 🧰 Prerequisites

Before deploying, make sure you have:

* **Terraform v1.5+**
* **AWS CLI** configured with valid credentials
* **IAM permissions** to create VPC, EFS, and Security Group resources

Verify setup:

```bash
aws sts get-caller-identity
terraform -version
```

---

## 🚀 Deployment Steps
**First make sure `1.permanent_infra/` is up and running**

1. **Initialize Terraform**

   ```bash
   terraform init
   ```

2. **Review the plan**

   ```bash
   terraform plan
   ```

3. **Apply the configuration**

   ```bash
   terraform apply
   ```

4. **Clean up resources**

   ```bash
   terraform destroy
   ```

---

## 🧠 Notes

* This configuration uses **public subnets** for simplicity.
  For production environments, consider using **private subnets** with a NAT Gateway or VPC endpoints.
* The **EFS lifecycle policy** automatically transitions files to **Infrequent Access** after 30 days to reduce storage cost.
* Update security group CIDR ranges as needed — avoid using `0.0.0.0/0` in production.

---

## 📈 Next Steps

**See 2.transient_infra**

---

**Author:** *Eric Gamor*
**Region:** `eu-central-1`
**Terraform Version:** `>= 1.5`
**AWS Provider:** `>= 5.0`

---
