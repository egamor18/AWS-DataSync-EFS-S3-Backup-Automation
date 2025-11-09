
---

## 🧠 What an **EFS Mount Target** Is

Amazon **EFS (Elastic File System)** is a *network file system*, meaning it’s accessible over NFS (port 2049) — not attached to an EC2 instance like an EBS volume.

However, **EFS needs a network endpoint inside each Availability Zone (AZ)** to allow EC2 instances to connect to it efficiently.

That endpoint is called a **mount target**.
Each mount target:

* Lives in **one subnet** (and thus one AZ).
* Gets its own **network interface (ENI)** and **private IP**.
* Allows EC2 instances in the *same AZ* to mount the EFS without cross-AZ traffic.

---

## 📦 Why Two Mount Targets

In your configuration:

```hcl
resource "aws_efs_mount_target" "efs_a" {
  file_system_id  = aws_efs_file_system.web_data.id
  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.ec2_sg.id]
}

resource "aws_efs_mount_target" "efs_b" {
  file_system_id  = aws_efs_file_system.web_data.id
  subnet_id       = module.vpc.public_subnets[1]
  security_groups = [aws_security_group.ec2_sg.id]
}
```

You created:

* **`efs_a`** → Mount target in `eu-central-1a`
* **`efs_b`** → Mount target in `eu-central-1b`

This matches your two public subnets from:

```hcl
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
```

So:

* EC2 instances in AZ **1a** can connect to **efs_a** (local endpoint)
* EC2 instances in AZ **1b** can connect to **efs_b**

Without these, your EC2s would have to connect *cross-AZ*, which is slower, sometimes unreliable, and not supported in all configurations.

---

## ⚙️ Security Group on Mount Target

The security group:

```hcl
security_groups = [aws_security_group.ec2_sg.id]
```

ensures that EC2 instances (also using `ec2_sg`) can communicate over **NFS (port 2049)** with the EFS mount target.

This is how the network-level permission is granted for the EFS connection.

---

## ✅ Summary

| Concept            | Purpose                                                          |
| ------------------ | ---------------------------------------------------------------- |
| **Mount Target**   | The network endpoint EFS creates per AZ to allow EC2s to connect |
| **Why Two?**       | Because you have two Availability Zones (1a and 1b)              |
| **Security Group** | Allows inbound NFS traffic from EC2s                             |
| **Effect**         | Makes EFS accessible locally to all EC2s in all AZs              |

---
