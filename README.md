# aws-secure-static-site

A secure static website hosted on AWS, deployed entirely through Terraform.
No console clicks — every resource defined as code.

🌐 **Live site:** https://d36vtc5t02nquj.cloudfront.net

---

## What I Built

As a Economics student working towards my cloud certifications i wanted to get the grasp of using tools with hands on experience so, this is my first real AWS project. I wanted to go beyond tutorials and build something properly — secured from the ground up and deployed through Infrastructure as Code.

Every resource in this project was created by Terraform. no buttons in the AWS console was clicked to build the infrastructure.

---

## Architecture

**Traffic flow:**

User → CloudFront (HTTPS) → S3 (private) → Website served
**Traffic flow:**
## Screenshots

### block Public accsess 
![Screenshot 1](./architecture/Image%2025-05-2026%20at%2017.26.jpeg)

### CloudFront & S3 Configuration
![Screenshot 2](./architecture/Image%2025-05-2026%20at%2017.27.jpeg)

### CloudFront & S3 Configuration


## AWS Services Used

| Service | Purpose | Security Decision |
|---|---|---|
| S3 | Store website files | Bucket is completely private — no public access whatsoever |
| CloudFront | Deliver site globally with HTTPS | Only way to access S3 — acts as security shield |
| ACM | Free SSL certificate | Forces HTTPS — HTTP redirects automatically |
| IAM / Bucket Policy | Access control | Only this specific CloudFront can read from S3 |
| S3 Versioning | File recovery | Older file versions are preserved automatically |
| S3 Encryption | Data protection | AES256 encryption on all stored files |
| S3 Logging | Audit trail | Every bucket access is recorded |

---

## Security Decisions Explained

**Why is the S3 bucket private?**
S3 buckets left public are one of the most common causes of cloud breaches. A misconfigured public S3 bucket exposed 106 million Capital One customer records in 2019. This bucket cannot be accessed directly from the internet under any circumstances. Verified — direct S3 URL returns Access Denied.

**Why CloudFront in front of S3?**
CloudFront acts as a secure proxy. Only requests from this specific CloudFront distribution — verified by Origin Access Control — are allowed to read from S3. Even if someone finds the bucket name they cannot access the files.

**Why force HTTPS?**
Any request over HTTP is automatically redirected to HTTPS. All traffic between users and CloudFront is encrypted in transit. No unencrypted connections are possible.

**Why AES256 encryption on S3?**
Data at rest should always be encrypted. Even if someone gained access to AWS storage infrastructure your files would be unreadable without the encryption key.

**Why Origin Access Control instead of Origin Access Identity?**
OAC is AWS's modern replacement for OAI and is now the recommended best practice. Using current standards rather than legacy methods matters.

---

## Terraform Structure

- providers.tf — AWS provider and region configuration
- variables.tf — Reusable variables for region, bucket name, project name
- main.tf — All 9 AWS resources defined as code
- outputs.tf — CloudFront URL and resource IDs printed after deploy
  
## How to Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## How to Destroy

```bash
terraform destroy
```

Always destroy when done to avoid unnecessary AWS charges.

---

## What I Learned

- How S3, CloudFront, ACM, and IAM work together as a secure architecture
- Why public S3 buckets are dangerous and how Origin Access Control prevents direct access
- How to write Terraform code that deploys real cloud infrastructure automatically
- The principle of least privilege applied to an S3 bucket policy
- Why CloudFront SSL certificates must live in us-east-1 regardless of your region
- How git and GitHub work for version controlling infrastructure code

---

## Tools Used
Terraform · AWS S3 · AWS CloudFront · AWS ACM · AWS IAM · AWS CLI · Git · GitHub
