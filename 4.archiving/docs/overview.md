

---

## 🧩 **AWS DataSync Backup and Monitoring System**

---

### **Executive Summary**

Many companies run their web servers on Amazon EC2 instances that collect and process valuable operational data. However, as organizations adopt elastic and auto-scaling architectures, maintaining consistent access to these data becomes a challenge. EC2 instances can be dynamically created or terminated based on workload demand, which often leads to data loss risks or inconsistent storage management if not properly architected.

This project demonstrates an automated and scalable solution to this problem using **Infrastructure as Code (IaC)** with **Terraform** and several **AWS managed services**. The system integrates Amazon **Elastic File System (EFS)** as shared storage across all EC2 instances, ensuring that critical application data remains persistent regardless of instance lifecycle. A **DataSync workflow** automatically replicates this data to **Amazon S3**, providing versioned backups and long-term archiving.

To enhance operational visibility, **Amazon CloudWatch** captures logs for every transfer, and **Amazon SNS** with **EventBridge** sends email notifications on task success or failure. **Auto Scaling Groups (ASG)** were incorporated to ensure scalability and elasticity of compute resources, while EFS maintained continuous data consistency. Together, these components provide a resilient, automated, and auditable data management pipeline—addressing real-world business challenges related to **data durability**, **backup reliability**, and **disaster recovery readiness** in dynamic cloud environments.

---

### **Step-by-Step Summary**

#### **1️⃣ Infrastructure Backbone**

* Created the core **network architecture**, consisting of:

  * **VPC** with appropriate **subnets** (public/private)
  * **Security Groups** for EC2 and EFS communication
  * **Elastic File System (EFS)** for shared storage among EC2s
* This formed the foundation for subsequent scalable and monitored operations.

---

#### **2️⃣ EFS Auto-Mount Testing**

* Configured **EC2 instances** to automatically **mount the EFS** upon startup.
* Verified mount points via system logs and by listing `/mnt/efs` (or equivalent).
* Ensured persistence of mount configurations using `/etc/fstab` or EC2 user-data scripts.

---

#### **3️⃣ Auto Scaling Group (ASG) Integration**

* Integrated **Auto Scaling Group (ASG)** to automatically launch or terminate EC2 instances.
* Verified that newly launched instances could:

  * Mount the EFS automatically.
  * Access and share files seamlessly.
* This ensured horizontal scalability and resilience.

---

#### **4️⃣ Data Verification**

* Validated data consistency between EC2 and EFS.

  * Files written to EFS from one EC2 were immediately visible from others.
* Confirmed correct IAM roles, security groups, and NFS mount permissions.

---

#### **5️⃣ Versioning and DataSync Integration**

* Introduced **Amazon S3** for versioned backup storage.
* Created a **DataSync task** to:

  * Transfer data from EFS → S3.
  * Preserve metadata and structure.
* Scheduled the DataSync task using **cron expressions** to automate periodic synchronization.

---

#### **6️⃣ Notification System**

* Implemented **Amazon SNS** for **email notifications** upon DataSync completion.
* Configured **EventBridge** rules to capture **DataSync Task Execution State Change** events.
* Used an **input transformer** to send human-readable messages:

  ```
  DataSync Task Notification:
  Task ARN: <task_arn>
  Region: <region>
  Time: <time>
  State: <state>
  ```
* Verified notification delivery through successful test and live event alerts.

---

#### **7️⃣ CloudWatch Logging and Troubleshooting**

* Enabled detailed **CloudWatch logs** for DataSync execution.
* Logs include:

  * File verification and transfer details.
  * Task completion status (e.g., SUCCESS or FAILED).
* These logs support **monitoring, troubleshooting, and auditability** of data transfers.

---

### **✅ Final Outcome**

I achieved a **complete automated pipeline** with these capabilities:

* Scalable EC2 infrastructure with shared EFS.
* Automatic, versioned EFS → S3 backups.
* Event-driven monitoring and alerting.
* Centralized logging via CloudWatch.
* Fully automated setup and updates through Terraform.

---

### **🧠 Technologies Used**

| AWS Service            | Purpose                                   |
| ---------------------- | ----------------------------------------- |
| **VPC / Subnets / SG** | Core networking & security                |
| **EFS**                | Shared file storage for EC2               |
| **EC2 + ASG**          | Scalable compute layer                    |
| **S3**                 | Backup storage with versioning            |
| **DataSync**           | Automated EFS → S3 transfer               |
| **CloudWatch**         | Monitoring and logging                    |
| **SNS**                | Email alerts for task results             |
| **EventBridge**        | Triggers notifications on task completion |
| **Terraform**          | Infrastructure-as-Code management         |

---
The details about each step is documentated in :