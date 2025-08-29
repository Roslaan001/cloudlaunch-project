# CloudLaunch Project – AWS Infrastructure Setup

This repository documents the setup and configuration of AWS resources for the **CloudLaunch Project**.  
The work is divided into:

- **Task 1** → 3 S3 buckets + Static Website Hosting + IAM User  
- **Task 2** → VPC Design with Subnets, IGW, and Route Tables  

---

## Task 1: Static Website Hosting Using S3 + IAM User with Limited Permissions

### Objective

- Create three S3 buckets with different access levels.
- Host a static website on S3.
- Manage private and visible-only buckets.
- Restrict IAM user access with a custom policy.

### Steps Performed

1. **S3 Buckets Created:**
   - **cloudlaunch-site-bucket-roslaan-001**
     - Hosts a basic static website (HTML/CSS/JS).
     - Static website hosting enabled.
     - Public read-only access.
     - [Optional] Configured with CloudFront for HTTPS and caching.
   - **cloudlaunch-private-bucket-roslaan-001**
     - Private bucket.
     - Accessible only to `cloudlaunch-user` with **GetObject** and **PutObject** permissions.
     - **No DeleteObject allowed**.
   - **cloudlaunch-visible-only-bucket-roslaan-001**
     - Not publicly accessible.
     - `cloudlaunch-user` can **ListBucket** but cannot access contents.

2. **IAM User:**
   - User: **cloudlaunch-user**
   - Permissions:
     - `ListBucket` on all three buckets.
     - `GetObject` on **cloudlaunch-site-bucket-roslaan-001**.
     - `GetObject` + `PutObject` on **cloudlaunch-private-bucket-roslaan-001**.
     - **No DeleteObject** permissions anywhere.
     - No content access to **cloudlaunch-visible-only-bucket-roslaan-001**.

### Outputs

- **S3 Static Website URL:**  
  `cloudlaunch-site-bucket-roslaan-001.s3-website-us-east-1.amazonaws.com`

- **CloudFront URL (Optional):**  
  `d3jlzkx1inqjre.cloudfront.net`

- **IAM Policy JSON (attached to `cloudlaunch-user`):**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::cloudlaunch-site-bucket-roslaan-001",
        "arn:aws:s3:::cloudlaunch-private-bucket-roslaan-001",
        "arn:aws:s3:::cloudlaunch-visible-only-bucket-roslaan-001"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::cloudlaunch-site-bucket-roslaan-001/*"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::cloudlaunch-private-bucket-roslaan-001/*"
    }
  ]
}
```

## Task 2: VPC Design for CloudLaunch Environment

## 🎯 Objective

Design and configure a secure, logically separated VPC for future application and database deployment.

---

## 🛠️ Steps Performed

### VPC

- **Name:** `cloudlaunch-vpc`  
- **CIDR Block:** `10.0.0.0/16`  

---

### Subnets

1. **Public Subnet**
   - CIDR: `10.0.1.0/24`  
   - Purpose: Internet-facing services such as load balancers.  

2. **Application Subnet**
   - CIDR: `10.0.2.0/24`  
   - Purpose: Private subnet for application servers.  

3. **Database Subnet**
   - CIDR: `10.0.3.0/28`  
   - Purpose: Private subnet for RDS/DB services.  

---

### Internet Gateway (IGW)

- **Resource Name:** `cloudlaunch-igw`  
- **Attached To:** `cloudlaunch-vpc`  
- **Purpose:** Allows resources in the public subnet to communicate with the internet.  

---

### Route Tables

1. **cloudlaunch-public-rt**
   - Associated with the **Public Subnet**.  
   - Route: `0.0.0.0/0 → cloudlaunch-igw`.  

2. **cloudlaunch-app-rt**
   - Associated with the **Application Subnet**.  
   - No internet route (kept private).  

3. **cloudlaunch-db-rt**
   - Associated with the **Database Subnet**.  
   - No internet route (kept private).  

---

### Security Groups

1. **cloudlaunch-app-sg**
   - **Inbound:** Allows HTTP (port 80) from within the VPC (`10.0.0.0/16`).  
   - **Outbound:** Allows all traffic.  

2. **cloudlaunch-db-sg**
   - **Inbound:** Allows MySQL (port 3306) only from the **Application Subnet**.  
   - **Outbound:** Allows all traffic.  

---

### IAM Permissions for VPC

- The IAM user **`cloudlaunch-user`** was granted **read-only access** to:
  - VPC  
  - Subnets  
  - Route Tables  
  - Security Groups 


  ![Image of VPC and its component, s3 buckets and cloudfront distribution](/images/Screenshot%202025-08-29%20102930.png) 

  ![Image of VPC and its component, s3 buckets and cloudfront distribution](/images/Screenshot%202025-08-29%20102947.png)

  ![Image of VPC and its component, s3 buckets and cloudfront distribution](/images/Screenshot%202025-08-29%20103046.png) 

  ![Image of VPC and its component, s3 buckets and cloudfront distribution](/images/Screenshot%202025-08-29%20103102.png) 

  ![Image of VPC and its component, s3 buckets and cloudfront distribution](/images/Screenshot%202025-08-29%20103143.png) 

---
> N.B: Some/ all of these resources might be taken down soon as my AWS account is no longer a free tier account. Thanks