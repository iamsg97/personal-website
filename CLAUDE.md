# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A terminal-themed personal portfolio for Suvadeep Ghoshal. **Next.js 16 (App Router) + TypeScript**, styled entirely with **CSS Modules + CSS custom properties** — deliberately no UI/CSS framework (the terminal aesthetic is the point). Package manager is npm.

> Note: this replaced an earlier React 19 + Vite + TanStack Router + Tailwind/shadcn SPA. That version still exists on the `main` and `feat/re-design` branches if you need to reference it.

## Commands

```bash
npm run dev            # dev server on :3000 (Turbopack)
npm run build          # production build: typecheck + static generation
npm start              # serve the production build
npm run lint           # eslint (eslint-config-next, flat config)
npm run format         # prettier --write .
npm run format:check   # prettier --check .
```

There is no test suite. Verification is done by building and driving the running app.

## Architecture

**Rendering model — static-first.** The home page (`app/page.tsx`) is a React Server Component that statically generates with **hourly ISR** (driven by the GitHub fetch's `revalidate: 3600`). The only server-runtime code is the contact route handler. Client Components are limited to the three things that need interactivity: `Nav`, `ThemeToggle`, `ContactForm` (all marked `"use client"`).

**Single-page composition.** `app/page.tsx` stacks section components from `components/sections/` (`Hero`, `About`, `Experience`, `Projects`, `Stack`, `Uses`, `Contact`). Every section except `Hero` is wrapped by `components/Section.tsx`, which renders a terminal-style prompt heading (`suvadeep@web:~ $ <command>`) and frames the body. **`lib/sections.ts` is the source of truth** for section `id`, nav `label`, and heading `command` — the `Nav` scroll-spy, keyboard nav, and each section's heading all read from it, so add/reorder sections there.

**Content is data, not markup.** All copy lives in typed modules under `content/` (`profile.ts`, `experience.ts`, `projects.ts`, `skills.ts`, `uses.ts`). Components are presentational and map over these. Edit content in `content/`, not in components.

**Theming.** Dark/light is driven by `data-theme` on `<html>`. An inline script in `app/layout.tsx` sets it **before first paint** (reads `localStorage.theme`, falls back to `prefers-color-scheme`) to avoid a flash. `ThemeToggle` uses **`useSyncExternalStore`** (not `useState`+effect — the ESLint config forbids `setState` in effects) reading `document.documentElement.dataset.theme`, and dispatches a `themechange` event so the store updates. All colors are CSS variables defined once in `app/globals.css` under `:root` (dark) and `:root[data-theme="light"]`.

**GitHub integration.** `lib/github.ts` fetches public non-fork repos for `iamsg97`, ranked by stars then recency, with `next: { revalidate: 3600 }`. It returns `[]` on any failure, and `components/GithubRepos.tsx` (async RSC, wrapped in `<Suspense>` inside `Projects`) degrades to a link. Optional `GITHUB_TOKEN` raises the rate limit.

**Contact flow.** `ContactForm` (client) POSTs JSON to `app/api/contact/route.ts`, which validates with **Zod**, checks a honeypot (`website` field), applies a best-effort in-memory rate limit, and sends via **Resend**. When `RESEND_API_KEY` is unset the route returns `{ fallback: true }` and the client renders a `mailto:` link — so the site is fully functional with zero configuration.

**Dynamic OG/icon.** `app/opengraph-image.tsx` and `app/icon.tsx` generate images via `next/og` (Satori). Satori constraints: every `div` with more than one child needs explicit `display: flex`, and `display` only accepts `flex`/`block`/`none`/`contents`/`-webkit-box` — no `inline-block`.

## Conventions

- **Path alias:** `@/*` → repo root (see `tsconfig.json`). Prefer it for cross-directory imports.
- **Styling:** one `*.module.css` next to each component; consume the shared CSS variables — don't hardcode colors. Global helpers (`.wrap`, `.cursor`, `.skip`) live in `app/globals.css`.
- **Prettier:** 2-space, double quotes, semicolons, trailing commas, 100 print width (`.prettierrc`).
- **Accessibility:** monospace prose is capped at `--measure` (74ch); `prefers-reduced-motion` disables the cursor blink and smooth scroll; keep skip-link and focus-visible styles intact.
