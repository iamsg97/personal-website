# suvadeep-portfolio

A terminal-themed personal portfolio — text-first, monospace, keyboard-friendly.
Built with **Next.js (App Router) + TypeScript** and hand-written CSS Modules
(no UI framework). Content is drawn from my résumé, and the projects section
pulls live repos from GitHub.

## Stack

- **Next.js 16** (App Router, React Server Components) + **TypeScript** (strict)
- **CSS Modules** + CSS custom-property theming (dark / light) — no CSS framework
- **JetBrains Mono** via `next/font`
- **Resend** + **Zod** for the contact form
- Live GitHub data via the REST API with hourly ISR

## Getting started

```bash
npm install
cp .env.example .env.local   # fill in as needed (all optional for local dev)
npm run dev                  # http://localhost:3000
```

The site runs fully without any environment variables — the contact form falls
back to a `mailto:` link and the GitHub section uses the unauthenticated API.

## Scripts

| Command                | What it does                          |
| ---------------------- | ------------------------------------- |
| `npm run dev`          | Start the dev server on :3000         |
| `npm run build`        | Production build (typecheck + static) |
| `npm start`            | Serve the production build            |
| `npm run lint`         | ESLint                                |
| `npm run format`       | Prettier write                        |
| `npm run format:check` | Prettier check                        |
| `./scripts/version.sh <major\|minor\|patch>` | Bump the release version, commit, and tag |
| `./scripts/version.sh build`                 | Print a build-metadata version for the current commit (used by CD) |

## Environment

| Variable               | Purpose                                                            |
| ---------------------- | ------------------------------------------------------------------ |
| `RESEND_API_KEY`       | Enables the contact form to send email. Unset → `mailto:` fallback |
| `CONTACT_TO_EMAIL`     | Where contact submissions are delivered                            |
| `CONTACT_FROM_EMAIL`   | Verified Resend sender address                                     |
| `GITHUB_TOKEN`         | Optional — raises the GitHub API rate limit for the repos section  |
| `NEXT_PUBLIC_SITE_URL` | Canonical URL used for metadata / OG / sitemap                     |

## Editing content

Content lives under [`content/`](./content) — edit those, not the components:

- **`resume.mdx`** — the growing source of truth for **experience, projects,
  tech stack, and certifications** (YAML frontmatter). Add a project / skill
  group / cert here and the site updates. Certifications use `done: true`
  (earned → green ✓) or `done: false` (in progress → yellow clock).
- `profile.ts` — name, tagline, about, aspirations (with inline links), socials
- `uses.ts` — the dotfiles / terminal setup
- `lib/sections.ts` — section order + terminal-style headings

## CI/CD

- **CI** (`.github/workflows/ci.yml`): every PR into `main` runs format check,
  lint, `next build`, and a Docker image build. All must pass before merge —
  enforced by branch protection on `main`.
- **CD** (`.github/workflows/cd.yml`): every push to `main` builds the Docker
  image, pushes it to ECR, and rolls out a new ECS task revision.

## Deploy

The production target is **AWS (ECS on EC2)** — see
[`docs/AWS_HOSTING.md`](./docs/AWS_HOSTING.md) for the full runbook
(architecture, first-time setup, cost, troubleshooting, teardown). The
infrastructure is defined in [`terraform/`](./terraform).

The app also runs unmodified on Vercel if you'd rather not manage the AWS
side: set the environment variables above in the project settings; the home
page is statically generated with hourly revalidation and the contact form
runs as a single serverless function.
