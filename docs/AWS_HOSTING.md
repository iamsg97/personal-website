# Hosting on AWS (ECS on EC2)

This runs the site as a Docker container on a single EC2 instance managed by
ECS, behind an Application Load Balancer. Everything is defined in
[`terraform/`](../terraform); this doc is the runbook for going from "nothing"
to "live," and back.

## Architecture

```
GitHub Actions (CD) --push image--> ECR
                    --deploy------->  ECS Service ---> ECS Task (EC2, bridge network)
                                            |
                                            v
                                     ALB (HTTP :80) <--- internet
```

- **VPC**: a dedicated VPC with 2 public subnets (no NAT gateway — keeps cost down).
- **ECS cluster**: EC2 launch type, one `t3.micro` instance in an Auto Scaling
  Group (min=max=desired=1), managed by an ECS capacity provider.
- **ALB**: internet-facing, HTTP only for v1 (no domain yet — see
  [Adding a custom domain](#adding-a-custom-domain-later)).
- **ECR**: private repository for the built image.
- **GitHub Actions deploys via OIDC** — no long-lived AWS access keys are
  stored anywhere.
- **Secrets**: `RESEND_API_KEY` is read from SSM Parameter Store (SecureString)
  at container start, not baked into the task definition.

## Cost

Roughly (`ap-south-1`, on-demand pricing):

| Resource                  | ~Monthly cost                                         |
| ------------------------- | ----------------------------------------------------- |
| EC2 `t3.micro`            | ~$7.50 (free tier: $0 for 12 months on a new account) |
| Application Load Balancer | ~$16 + a few cents/GB processed                       |
| ECR storage               | ~$0.10/GB                                             |
| CloudWatch Logs           | pennies at this volume                                |

The ALB is the dominant cost for a low-traffic personal site. If that matters,
the documented alternative is to skip the ALB and point DNS straight at the
instance's Elastic IP — not covered here since you explicitly asked for an
ALB-fronted ECS setup, but flag it if you want that swapped in later.

## Prerequisites

- An AWS account and credentials with enough permissions to create VPCs, EC2,
  ECS, ECR, ALB, IAM roles, and SSM parameters (`AdministratorAccess` is the
  easy path for a personal account).
- `aws` CLI v2 and `terraform` >= 1.9 installed locally (or wherever you run
  this from).
- This repo's GitHub Actions token needs `repo` admin scope if you also want
  to manage branch protection (`gh auth status` to check).

## First-time setup

### 1. Configure AWS credentials

```bash
aws configure
# or, for SSO: aws configure sso
```

Verify:

```bash
aws sts get-caller-identity
```

### 2. Apply the Terraform stack

```bash
cd terraform
terraform init
terraform plan   # review what will be created
terraform apply
```

This creates the VPC, ECS cluster/EC2 instance, ALB, ECR repo, IAM roles
(including the GitHub OIDC deploy role), and a placeholder SSM parameter for
the Resend API key. The first `apply` also stands up an initial task
definition/service using a `:latest` tag that doesn't exist in ECR yet — the
service will sit with 0 running tasks until the first image is pushed by the
CD workflow (step 4). This is expected.

### 3. Set the real Resend API key

Terraform intentionally leaves this as `CHANGE_ME` so the secret never lives
in `.tf` files or state as a real value beyond the placeholder:

```bash
aws ssm put-parameter \
  --name "/suvadeep-portfolio/resend-api-key" \
  --type SecureString \
  --value "re_your_real_key" \
  --overwrite
```

The running task picks this up on its _next_ start (redeploy or let the CD
pipeline roll one out).

### 4. Wire up GitHub Actions

Grab the values Terraform just created:

```bash
terraform output
```

Set repo **variables** (`gh variable set`, not secrets — these aren't
sensitive):

```bash
gh variable set AWS_REGION --body "ap-south-1"
gh variable set ECR_REPOSITORY --body "suvadeep-portfolio"
gh variable set ECS_CLUSTER --body "suvadeep-portfolio"
gh variable set ECS_SERVICE --body "suvadeep-portfolio"
```

Set the one repo **secret** the CD workflow needs — the OIDC role ARN (not a
credential, but keeping it out of the diff/PR history is good hygiene):

```bash
gh secret set AWS_DEPLOY_ROLE_ARN --body "$(terraform output -raw github_actions_deploy_role_arn)"
```

### 5. First deploy

Merge to `main` (or run manually):

```bash
gh workflow run cd.yml
```

This builds the Docker image, pushes it to ECR tagged with
`scripts/version.sh build`'s output (e.g. `1.0.0-build.42.a1b2c3d`) and
`latest`, registers a new ECS task definition revision pointing at that image,
and updates the service. The action waits for the deployment to stabilize.

### 6. Verify

```bash
terraform output alb_dns_name
curl -I "$(terraform output -raw alb_dns_name)"
```

You should get a `200`. If not, see [Troubleshooting](#troubleshooting).

## Ongoing deploys

Every push to `main` (after a PR passes CI and is merged) triggers `cd.yml`
automatically — no manual steps needed after the first-time setup above.

## Adding a custom domain (later)

1. Buy/point a domain and create a Route 53 hosted zone (or use your existing
   registrar's DNS).
2. Request a public ACM certificate for the domain (`aws acm request-certificate`)
   and validate it (DNS validation, add the CNAME Terraform/ACM gives you).
3. Add an HTTPS listener (port 443) on the ALB referencing that certificate,
   and either redirect port 80 -> 443 or drop the HTTP listener.
4. Point an `A`/`ALIAS` (Route 53) or `CNAME` (elsewhere) record at the ALB's
   DNS name (`terraform output alb_dns_name`).

This isn't in the Terraform yet since there's no domain configured — ask and
it can be added as `terraform/dns.tf` + `terraform/acm.tf`.

## Troubleshooting

- **Service stuck with 0 running tasks**: check
  `aws ecs describe-services --cluster suvadeep-portfolio --services suvadeep-portfolio`
  for `events` — usually means the image tag in the task definition doesn't
  exist yet in ECR (run the CD workflow) or the EC2 instance hasn't
  registered with the cluster yet (check `aws ecs list-container-instances`).
- **ALB returns 502/503**: the target group has no healthy targets yet — give
  the task ~30-60s after a deploy, or check container logs:
  `aws logs tail /ecs/suvadeep-portfolio --follow`.
- **CD workflow fails to assume the AWS role**: confirm the `AWS_DEPLOY_ROLE_ARN`
  secret matches `terraform output github_actions_deploy_role_arn`, and that
  `github_repository` in `terraform/variables.tf` matches this repo exactly
  (`owner/repo`).

## Tearing it down

This stops billing for all of the above:

```bash
cd terraform
terraform destroy
```

Note this deletes the ECR repository and everything in it — make sure any
image you care about is also tagged/stored elsewhere first if needed.
