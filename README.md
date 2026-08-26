# Walkthrough Video Script — TravelEase Contact Form

Assumes: infrastructure already deployed (`terraform apply` already run), frontend already uploaded to S3 and connected to the live API URL. This script is for a post-deployment explainer + live demo, not a recording of the deploy process itself.

**Target length:** 7–10 minutes

---

## 1. Cold open — the problem (30–45 sec)

*(Show: nothing yet, or a simple slide/text with the problem statement)*

> "This is TravelEase — a fictional travel agency whose website used a plain mailto link for customer inquiries. That sounds harmless, but it has real costs: no confirmation that an inquiry was received, no reference number, no spam protection, and no record on the business side beyond whatever staff manually copied into a spreadsheet. A customer inquiring about a $5,000 vacation package at 9 PM has no reason to wait for a reply that might never come.

> I rebuilt this as a fully serverless contact form on AWS, deployed entirely with Terraform. Let me walk you through it."

## 2. Architecture diagram (60–90 sec)

*(Show: the architecture diagram)*

> "Here's the full flow. A visitor loads the site from an S3 bucket configured for static website hosting — plain HTML, CSS, and JavaScript, no servers involved. When they submit the form, two client-side spam checks run first — a honeypot field and Google reCAPTCHA — before anything is sent.

> The request hits API Gateway, which forwards it to a Lambda function using proxy integration. Lambda validates every field, generates a unique reference number, writes the submission to DynamoDB, and sends two emails through SES — a confirmation to the customer with their reference number, and a detailed notification to the business with every field they submitted.

> Every piece of this is pay-per-use — no idle EC2 instances, no provisioned database capacity sitting there unused. I actually started with a different design — a VPC-based architecture with EC2 and a load balancer — before realizing it didn't fit the brief's requirement for serverless, cost-efficient infrastructure. I'll touch on that decision in a minute."

## 3. Live demo (90–120 sec)

*(Show: the actual live website, screen-recorded)*

> "Let's see it working. Here's the live form." *(fill out the form with realistic sample data on screen)*

> "I'll submit this." *(click submit, show the loading state, then the success message)*

> "Notice it returns a reference number immediately — that's the piece the old mailto link never gave anyone."

*(Cut to email inbox)*

> "Here's the confirmation email that just landed — sent via SES, includes the same reference number." *(scroll to show it)*

> "And here's the business notification — same submission, but with every field included, so nothing has to be manually re-typed into a spreadsheet."

*(Cut to DynamoDB console, or AWS CLI query)*

> "And here's that same submission sitting in DynamoDB, with the reference number as the primary key."

## 4. Infrastructure as code (90–120 sec)

*(Show: VS Code, infrastructure/ folder)*

> "All of this — 22 AWS resources — is defined in Terraform, organized by service: S3, DynamoDB, IAM, Lambda, API Gateway, SES."

*(Open iam.tf)*

> "One thing I want to highlight: least-privilege IAM. The Lambda execution role can write to exactly one DynamoDB table — scoped by ARN, not a wildcard — and send email through SES. I actually ran into a real bug while building this: I originally put the DynamoDB write permission and the SES/logging permissions in a single policy statement. Turns out a single statement applies every resource in its list to every action in it — so a wildcarded resource for SES was silently un-scoping my tightly-scoped DynamoDB permission too. Splitting it into two separate statements fixed it."

*(Open api_gateway.tf, scroll to the OPTIONS-related resources)*

> "Another one — CORS preflight. A working POST integration on its own isn't enough, because browsers send an automatic OPTIONS request first for cross-origin POSTs like this one. Without an OPTIONS method handled by API Gateway directly — via a mock integration, no Lambda call needed — that preflight fails before the real request is ever sent."

## 5. Resilience and monitoring (60–75 sec)

*(Show: index.js, scroll to the DynamoDB write and the two SES try/catch blocks)*

> "One deliberate detail here: the DynamoDB write has no error handling — if it fails, the function crashes and the customer correctly sees an error, because their submission genuinely wasn't saved. But each SES call has its own separate try/catch. That's not one shared block around both emails — two independent ones. If the customer's confirmation email fails, the business notification still gets sent regardless, and the customer still sees success, because their data was already safely stored before either email was attempted. Email failures get logged to CloudWatch instead of surfaced to the customer."

*(Show: monitoring.tf or the CloudWatch console)*

> "On top of that, there's a CloudWatch alarm on this Lambda's error count — set to fire on a single error within five minutes, since this is low-traffic enough that any failure is worth knowing about right away. It routes to an SNS topic, which also receives SES's own bounce, complaint, and delivery events — so if an email actually fails to deliver, that surfaces as a notification too, not just a Lambda-level error. The submissions table also has point-in-time recovery enabled."

## 6. Why serverless — the design decision (45–60 sec)

*(Show: side-by-side or verbal comparison, optionally the earlier VPC diagram if you kept it)*

> "Worth mentioning — my first architecture draft for this reused a pattern from an earlier project: VPC, public and private subnets, an Application Load Balancer, NAT Gateway, EC2, DocumentDB. It's a legitimate pattern, just the wrong one here. None of that satisfies 'serverless, no idle servers, pay only for what you use' — EC2 instances and NAT Gateways cost money whether anyone submits the form or not. Going back through the brief's actual requirements line by line is what caught it before I built the wrong thing."

## 7. Close (20–30 sec)

> "That's the full build — S3, API Gateway, Lambda, DynamoDB, and SES, entirely serverless, entirely defined in Terraform. Source code and a full write-up are linked below. Thanks for watching."

---

## Recording checklist

- [ ] Deployment fully applied and stable (no `terraform apply` errors)
- [ ] SNS email subscription confirmed (check inbox for the confirmation link — subscription stays "pending" until clicked)
- [ ] Frontend uploaded to S3, `script.js` pointing at the real API URL
- [ ] Test submission works end-to-end (confirmation email, business email, DynamoDB entry) — verified once *before* recording, using non-final test data
- [ ] Have DynamoDB console (or a CLI query) ready to switch to
- [ ] Have both test inboxes (sender alias / customer alias) open and visible
- [ ] Screen resolution/zoom level checked so code and console are readable in the recording
- [ ] Close unrelated tabs/notifications before recording
