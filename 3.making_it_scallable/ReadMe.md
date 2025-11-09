
---

# ⚙️ AWS Auto Scaling with Launch Template (Terraform)

This stage introduces **scalability** into the infrastructure by deploying an **Auto Scaling Group (ASG)** that automatically adjusts the number of EC2 instances based on workload.
Each EC2 instance launches using a **Launch Template** and automatically mounts the shared **EFS file system** created in the earlier phase.

---

## 📦 Folder: `3.making_it_scallable/`

This layer builds upon the base infrastructure provisioned in `1.permanent_infra/` and the EC2 configuration from `2.ec2_instances/`.

---

## 🧰 Overview

| Component                    | Description                                                                                           |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| **Launch Template**          | Defines EC2 configuration including AMI, instance type, user data, and security group.                |
| **Auto Scaling Group (ASG)** | Manages a fleet of EC2 instances that scale automatically based on CPU utilization.                   |
| **Scaling Policy**           | Uses a target-tracking policy to maintain 50% average CPU utilization.                                |
| **Remote State Reference**   | Reuses outputs (VPC ID, subnets, EFS ID, and security group) from the permanent infrastructure stack. |

---

## ⚙️ Configuration Details

### 1️⃣ **Launch Template**

The `aws_launch_template` resource defines:

* **AMI** dynamically fetched using the `aws_ami` data source.
* **Instance type** from a variable (`t3.micro` or as configured).
* **Security group** and **EFS mount automation** passed in through user data.
* Tags each instance with a friendly name (`web-asg`).

User data is passed in using:

```hcl
user_data = base64encode(templatefile(var.ec2_user_data, {
  efs_id = local.efs_id
}))
```

This ensures each EC2 instance mounts the correct EFS file system at boot.

---

### 2️⃣ **Auto Scaling Group (ASG)**

The `aws_autoscaling_group` manages the scaling behavior:

* Launches EC2 instances across subnets referenced from the remote state.
* Automatically replaces unhealthy instances.
* Scales **between `min_ec2` and `max_ec2`** as defined in variables.
* Uses **`health_check_type = "EC2"`** for direct instance monitoring.

---

### 3️⃣ **Target Tracking Scaling Policy**

The `aws_autoscaling_policy` automatically adjusts capacity to maintain a **target average CPU utilization** of **50%**.

This provides elasticity under varying load conditions without manual intervention.

---

## 📄 Variables

| Variable         | Type     | Description                               |
| ---------------- | -------- | ----------------------------------------- |
| `aws_region`     | `string` | AWS region for deployment                 |
| `instance_type`  | `string` | EC2 instance type (e.g., `"t3.micro"`)    |
| `ec2_user_data`  | `string` | Path to user data script for mounting EFS |
| `min_ec2`        | `number` | Minimum number of EC2 instances           |
| `max_ec2`        | `number` | Maximum number of EC2 instances           |
| `number_of_ec2s` | `number` | Desired capacity on initial deployment    |

---

## 🚀 Deployment Steps

1. **Navigate to the folder**

   ```bash
   cd 3.making_it_scallable
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Plan the deployment**

   ```bash
   terraform plan
   ```

4. **Apply the configuration**

   ```bash
   terraform apply
   ```

5. **Verify the Auto Scaling Group**

   ```bash
   aws autoscaling describe-auto-scaling-groups \
     --query "AutoScalingGroups[*].{Name:AutoScalingGroupName,Size:DesiredCapacity}"
   ```

6. **Simulate load** (optional)

   * Install CPU stress tools on EC2s:

     ```bash
     sudo amazon-linux-extras install epel -y
     sudo yum install stress -y
     stress --cpu 2 --timeout 300
     ```
   * Observe automatic scaling activity in the AWS Console.

---

## 🧠 Key Takeaways

* This setup **decouples compute scaling** from the rest of the infrastructure.
* All EC2 instances **share the same EFS** mount, maintaining persistent data.
* The ASG automatically adjusts instance count based on real-time **CPU utilization**.
* The architecture ensures **resilience**, **elasticity**, and **cost optimization**.

---
