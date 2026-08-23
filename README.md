# TravelEase Contact Form — Serverless AWS Solution

A serverless contact form system built for TravelEase Inc., a fictional travel agency transitioning from a basic `mailto:` link to a professional, reliable customer inquiry pipeline. Built entirely with Infrastructure as Code (Terraform) on AWS.

**Live demo:** _add your S3 website URL here after deployment_
**Architecture diagram:** see `/docs/architecture-diagram.png`

---

## The Problem

TravelEase's website used a `mailto:` link for customer inquiries. That approach had real business consequences:

- No confirmation that an inquiry was received — a customer asking about a $5,000 vacation package at 9 PM had no reason to wait around, and might book with a competitor instead.
- No reference number, no way to follow up.
- Inquiries could be missed entirely (misconfigured email clients, spam filters).
- Staff manually copied inquiries into spreadsheets, with no standardized format and no way to track response times.
- No spam protection, no data validation, no backup of communication history.

## The Solution

A fully serverless, pay-per-use architecture that replaces the `mailto:` link with a validated, spam-protected contact form backed by managed AWS services — no servers to provision or patch, and cost that scales to zero when there's no traffic.

## Architecture

```
User (browser)
   │
   ▼
Amazon S3 (static site: HTML/CSS/JS)
   │  user fills out form
   ▼
Honeypot field + Google reCAPTCHA (client-side spam checks)
   │
   ▼
Amazon API Gateway  ── POST /submit ── AWS_PROXY integration
   │
   ▼
AWS Lambda (Node.js)
   ├── validates all fields
   ├── generates a unique reference number (UUID)
   ├── writes the submission to DynamoDB
   └── sends two emails via Amazon SES
        │
        ├──▶ Amazon DynamoDB   (submission storage)
        └──▶ Amazon SES        ├─ confirmation email → customer
                                └─ notification email → business
```

Full diagram: `/docs/architecture-diagram.png`

## Why Serverless

Every compute and data component in this stack — S3, Lambda, API Gateway, DynamoDB, SES — is pay-per-use with no idle infrastructure to provision, patch, or pay for around the clock. This was a deliberate architectural choice, not a default: an earlier draft of this design used EC2, an Application Load Balancer, NAT Gateways, and DocumentDB inside a VPC — a perfectly valid pattern for some workloads, but the wrong fit here, since it introduces fixed hourly costs and operational overhead for a workload that's bursty and low-volume (a contact form doesn't need 24/7 compute).

## Tech Stack

| Layer | Service | Purpose |
|---|---|---|
| Frontend hosting | Amazon S3 (static website hosting) | Serves `index.html`, `style.css`, `script.js` |
| API layer | Amazon API Gateway (REST API, Lambda proxy integration) | Public HTTPS endpoint, CORS, request routing |
| Compute | AWS Lambda (Node.js 20.x) | Validation, business logic, orchestration |
| Storage | Amazon DynamoDB (on-demand / pay-per-request) | Stores each submission with a unique ID |
| Email | Amazon SES | Sends customer confirmation + business notification |
| IAM | Least-privilege execution role | Scoped `dynamodb:PutItem` (single table ARN), `ses:SendEmail`, CloudWatch Logs actions |
| IaC | Terraform | All 22 resources defined as code, zero manual console resource creation |

## Security & Spam Protection

- **Honeypot field** — a form field hidden from real users via off-screen CSS positioning, but visible to bots that parse raw HTML. If it's filled in on submit, Lambda silently drops the request without writing to the database or sending email.
- **Google reCAPTCHA** — a second, independent layer of bot detection at the client.
- **Least-privilege IAM** — the Lambda execution role can write to exactly one DynamoDB table (scoped by ARN), send email via SES, and write its own logs — nothing broader.
- **S3 bucket policy** — scoped to `s3:GetObject` only; no write or delete access is granted publicly.
- **CORS** — API Gateway is configured with a full OPTIONS preflight handler (mock integration) alongside the POST method, so only the intended origin's requests are accepted by the browser.

## Repository Structure

```
travelease-contact/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── infrastructure/
│   ├── provider.tf
│   ├── s3.tf
│   ├── dynamodb.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── lambda_permission.tf
│   ├── api_gateway.tf
│   ├── deployment_stage.tf
│   ├── ses.tf
│   ├── archive.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── backend.tf
├── lambda/
│   ├── index.js
│   └── package.json
└── docs/
    └── architecture-diagram.png
```

## Deployment

**Prerequisites**
- AWS account with an IAM user configured for CLI access (`aws configure`)
- Terraform installed
- Two SES-verified email addresses (sender + a recipient stand-in, since new AWS accounts start in SES sandbox mode)

**Steps**

```bash
# 1. Clone and enter the infrastructure directory
git clone https://github.com/fatemehfeizipour/travelease-contact.git
cd travelease-contact/infrastructure

# 2. Initialize Terraform
terraform init

# 3. Review the plan
terraform plan

# 4. Deploy (creates 22 AWS resources)
terraform apply

# 5. Note the outputs
#    - gateway_url → your API Gateway invoke URL
#    - s3_url      → your static website endpoint
```

```bash
# 6. Install Lambda dependencies before Terraform packages the function
cd ../lambda
npm install

# 7. Re-apply so the zip includes node_modules
cd ../infrastructure
terraform apply
```

**Connect frontend to backend**

Open `frontend/script.js` and set:
```js
const API_URL = "<your gateway_url output>/submit";
```

Then upload the three frontend files to your S3 bucket (via console, CLI, or a small `aws s3 sync` command) and visit the `s3_url` output.

## What I Learned

- Designing a request flow end-to-end before writing any code — tracing exactly what happens from form submission to email delivery — made every infrastructure decision (dependency order, IAM scope, integration type) fall out naturally instead of feeling arbitrary.
- The difference between identity-based IAM policies ("what can I do") and resource-based policies ("who can call me") — and why AWS requires an explicit `aws_lambda_permission` grant even after API Gateway and Lambda already reference each other.
- CORS preflight requests are a separate, silent requirement — a working POST integration is not enough on its own; the browser's OPTIONS preflight has to be handled explicitly via a mock integration.
- Least-privilege IAM in practice means splitting a policy into multiple statements when different actions need different resource scopes, since a single statement applies its resource list to every action in it.

## Author

Fatemeh Feyzipour — [LinkedIn](https://www.linkedin.com/in/fatemeh-feyzipour) · [GitHub](https://github.com/fatemehfeizipour)
