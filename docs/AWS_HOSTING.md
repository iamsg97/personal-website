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
                        suvadeepghoshal.dev -> ALB (HTTPS :443, HTTP :80 redirects) <--- internet
```

- **VPC**: a dedicated VPC with 2 public subnets (no NAT gateway — keeps cost down).
- **ECS cluster**: EC2 launch type, one `t3.micro` instance in an Auto Scaling
  Group (min=max=desired=1), managed by an ECS capacity provider.
- **ALB**: internet-facing. HTTPS on 443 (ACM cert for `suvadeepghoshal.dev` +
  `www.suvadeepghoshal.dev`, `ELBSecurityPolicy-TLS13-1-2-2021-06`); HTTP on 80
  redirects (301) to HTTPS.
- **DNS**: `suvadeepghoshal.dev` is registered and managed at **Spaceship**,
  not Route 53 — the ACM validation and the final ALB-pointing records were
  added there manually (Terraform can't touch DNS it doesn't host).
  `www.suvadeepghoshal.dev` is the canonical URL (`CNAME` to the ALB); the
  apex domain has no DNS record pointing at AWS at all — it 301-redirects to
  `www` via Spaceship's own URL-forwarding feature, entirely outside this
  Terraform stack.
- **ECR**: private repository for the built image.
- **GitHub Actions deploys via OIDC** — no long-lived AWS access keys are
  stored anywhere.
- **Secrets**: `RESEND_API_KEY` is read from SSM Parameter Store (SecureString)
  at container start, not baked into the task definition.
- **`NEXT_PUBLIC_SITE_URL`**: Next.js inlines `NEXT_PUBLIC_*` vars at _build_
  time, so this is passed as a Docker `--build-arg` in the CD workflow (from
  the `SITE_URL` repo variable), not as an ECS runtime environment variable —
  setting it on the running task would silently do nothing.

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
gh variable set SITE_URL --body "$(terraform output -raw site_url)"
```

`SITE_URL` isn't read by any deploy logic — it's only used to link the repo's
**Environments** tab (Settings → Environments → `production`) to the live
site.

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

This builds the Docker image (passing `SITE_URL` as the `NEXT_PUBLIC_SITE_URL`
build-arg — see the note above), pushes it to ECR tagged with
`scripts/version.sh build`'s output (e.g. `1.0.0-build.42.a1b2c3d` — ECR is
immutable-tag, so there's no floating `latest`), registers a new ECS task
definition revision pointing at that image, and updates the service. The
action waits for the deployment to stabilize.

### 6. Point the domain at the ALB and issue the certificate

`terraform apply` requests an ACM certificate for `var.domain_name` (default
`suvadeepghoshal.dev`) and its `www` subdomain, but can't validate it or
create DNS records automatically since the domain isn't hosted in Route 53.

1. `terraform output certificate_validation_records` — add each as a `CNAME`
   at your DNS provider.
2. Wait for propagation (`node -e "require('dns').resolveCname('<name>', console.log)"`
   or any DNS checker), then confirm ACM shows `ISSUED`:
   ```bash
   aws acm describe-certificate --certificate-arn <arn> --query Certificate.Status
   ```
3. `terraform apply` again — `aws_acm_certificate_validation` (in `terraform/acm.tf`)
   completes once the CNAMEs are visible, which unblocks the HTTPS listener
   (`terraform/alb.tf`) that references it.
4. Add the final DNS records pointing the real domain at the ALB
   (`terraform output alb_dns_name`):
   - `www` → `CNAME` to the ALB hostname (works everywhere). This is the
     canonical URL.
   - Apex (`@`) → most registrars don't allow a `CNAME` at the root. Use an
     `ALIAS`/`ANAME` record if your provider supports one; otherwise use its
     domain-forwarding feature to redirect the apex to `https://www.<domain>`
     (this is what's configured for `suvadeepghoshal.dev` at Spaceship — a
     301 redirect, not a DNS record, since Spaceship doesn't offer `ALIAS`).

### 7. Verify

```bash
curl -I "https://www.suvadeepghoshal.dev"
```

You should get a `200` over HTTPS, and both `http://www...` and the apex
`suvadeepghoshal.dev` should redirect to it. If not, see
[Troubleshooting](#troubleshooting).

## Ongoing deploys

Every push to `main` (after a PR passes CI and is merged) triggers `cd.yml`
automatically — no manual steps needed after the first-time setup above. Each
run shows up under the repo's **Environments** tab (job-level `environment:
production`), linking back to `SITE_URL`.

Pushing a version tag (`./scripts/version.sh major|minor|patch` followed by
`git push --follow-tags`) triggers `.github/workflows/release.yml`, which
creates a GitHub Release with auto-generated notes from the commits since the
previous tag.

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
- **ACM certificate stuck in `PENDING_VALIDATION`**: the CNAME records aren't
  visible yet — check with `aws acm describe-certificate ... --query
Certificate.DomainValidationOptions`, and confirm the records resolve via a
  public resolver (Spaceship's own nameservers can be slower to propagate
  than the rest of the internet).
- **Browser shows a certificate mismatch**: you're hitting the ALB's own
  `*.elb.amazonaws.com` hostname directly — the cert is only valid for
  `suvadeepghoshal.dev` / `www.suvadeepghoshal.dev`. Always test against the
  real domain (or `--resolve domain:443:<alb-ip>` if DNS hasn't been switched
  yet).

## Tearing it down

This stops billing for all of the above:

```bash
cd terraform
terraform destroy
```

Note this deletes the ECR repository and everything in it — make sure any
image you care about is also tagged/stored elsewhere first if needed.
