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

## Deploy

Deploys to Vercel as-is. Set the environment variables above in the project
settings; the home page is statically generated with hourly revalidation and the
contact form runs as a single serverless function.
