
---

# 🏗️ AWS DataSync + EFS + S3 Backup Automation (Terraform Project)

## 🚀 Overview

This project demonstrates a **modular and automated AWS backup architecture** built entirely with **Terraform**.
It allows EC2 instances in an **Auto Scaling Group (ASG)** to share data via **EFS**, automatically replicate that data to **S3** using **AWS DataSync**, and send **real-time alerts** via **SNS + CloudWatch/EventBridge**.

The architecture is designed for **scalability, resilience, and cost efficiency**, following Infrastructure-as-Code (IaC) best practices.

---

## 🧩 Architecture Summary

```markdown
![Figure 01 – System Architecture Overview](images/figure01_architecture.png)  
*Figure 01 – EC2 instances share data through EFS, which is backed up to versioned S3 using DataSync. EventBridge and SNS provide monitoring and alerts.*
```

---

## 🧱 Project Structure

| Folder                    | Description                                                                            |
| ------------------------- | -------------------------------------------------------------------------------------- |
| **1.permanent_infra/**    | Core infrastructure: VPC, subnets, security groups, and EFS (**must run first**).      |
| **2.transient_infra/**    | Deploys EC2 instances that automatically mount the shared EFS.                         |
| **3.making_it_scalable/** | Introduces Auto Scaling Group (ASG) with Launch Templates for elasticity.              |
| **4.archiving/**          | Implements **DataSync** for EFS → S3 backups, **CloudWatch logs**, and **SNS alerts**. |
| **images/**               | Architecture and result screenshots (Figures 01–18).                                   |

---

## 📊 Folder Dependency Diagram

```
      1.permanent_infra
             │
  ┌──────────┴───────────┐
  │          │           │
2.transient_infra 3.making_it_scalable 4.archiving
  (optional)        (optional)       (optional)
```

> 💡 **Note:** All other modules depend on outputs from `1.permanent_infra/` (VPC, subnets, SG, EFS).
> Once `1.permanent_infra/` is deployed, `2.transient_infra`, `3.making_it_scalable`, and `4.archiving` can be run **in any order**.

---

## 🧰 Prerequisites

Before deploying:

1. **AWS CLI** installed and configured:

   ```bash
   aws --version
   aws sts get-caller-identity
   ```
2. **Terraform CLI (v1.5+)**:

   ```bash
   terraform -version
   ```
3. **IAM permissions** for: EC2, EFS, S3, DataSync, SNS, CloudWatch, EventBridge.
4. **Basic AWS knowledge**: VPCs, subnets, IAM, EC2, EFS, S3.

---

## ⚙️ Deployment Flow

1. **Deploy core infrastructure first**:

```bash
cd 1.permanent_infra
terraform init && terraform apply -auto-approve
```

2. **Optional modules (can run independently, in any order)**:

```bash
cd ../2.transient_infra
terraform init && terraform apply -auto-approve

cd ../3.making_it_scalable
terraform init && terraform apply -auto-approve

cd ../4.archiving
terraform init && terraform apply -auto-approve
```

> Each module uses outputs from `1.permanent_infra/` via `terraform_remote_state`.

---

## 🧩 Features

* **Modular Design** — Each folder is an independent Terraform layer.
* **Persistent Storage** — Shared EFS ensures data survives instance termination.
* **Scalability** — ASG automatically adjusts EC2 capacity based on CPU load.
* **Automated Backups** — DataSync replicates files from EFS to versioned S3.
* **Monitoring & Alerts** — CloudWatch + EventBridge + SNS provide real-time notifications.
* **Cost Efficiency** — S3 lifecycle policies transition old data to Glacier.

---

## 📈 Results

* Auto Scaling verified under load.
* EFS consistently mounted across all EC2 instances.
* S3 versioning and lifecycle rules confirmed.
* DataSync successfully executed file transfers.
* SNS alerts received upon backup completion or failure.

---

## 📄 Example Image References

| #  | Description               | Filename                                           |
| -- | ------------------------- | -------------------------------------------------- |
| 1  | Architecture Overview     | `images/figure01_architecture_overview.png`        |
| 2  | VPC/Subnet Module Code    | `images/figure02_vpc_subnet_module.png`            |
| 3  | Auto Scaling Architecture | `images/figure03_autoscaling_efs_architecture.png` |
| 7  | S3 Versioning & Lifecycle | `images/figure07_s3_versioning_lifecycle.png`      |
| 15 | EventBridge Pattern Test  | `images/figure15_eventbridge_pattern_test.png`     |
| 16 | SNS Alert Email           | `images/figure16_sns_alert_email.png`              |

---

## 🧩 Key Business Value

* **Resilience:** Data persists even as EC2s scale in/out.
* **Automation:** Zero manual intervention for backups or scaling.
* **Security:** Data transfers over private VPC paths and HTTPS.
* **Visibility:** CloudWatch logs and SNS alerts enable proactive monitoring.
* **Compliance:** Versioned S3 storage ensures recoverable audit history.

---

## 👤 Author

**Eric Gamor**
Terraform | AWS | Cloud Automation

---

✅ **End of Root README**
*This README guides deployment and usage of a scalable, automated AWS backup architecture with Terraform.*

---

