# PROJECT_SPEC.md — Rajab Alkahef Personal Website

> Hand this file to Claude Code. Keep it in the repo root so it stays in context for the whole build. Build incrementally in the order under **Build Order**, and run `npm run build` + `tsc --noEmit` after each phase before moving on.

---

## 1. Role & Objective

You are a senior Next.js engineer. Build a **production-grade personal website + portfolio** for a software engineer specializing in **mobile apps and websites**. It doubles as a personal brand hub: portfolio, services, digital products, and a content/resources funnel that converts social-media traffic into leads and downloads.

Quality bar: clean architecture, strict typing, fully responsive, accessible, fast (LCP < 2.5s), and visually modern. No placeholder lorem-ipsum sprinkled everywhere — use realistic seed content so the site looks real on first run.

---

## 2. Tech Stack (pin these)

- **Next.js 15** — App Router, React Server Components, Server Actions, Turbopack
- **TypeScript** — `strict: true`, no `any`
- **Tailwind CSS v4** — CSS-first config via `@theme` in `globals.css`
- **shadcn/ui** — for primitives (button, card, dialog, input, sheet, tabs, accordion, carousel)
- **Velite** — typed, Zod-validated MDX content collections (projects, services, resources, products, testimonials). Chosen over a CMS because the owner is a developer who version-controls content; over hardcoded data because it gives type safety + MDX long-form. Keep a clean abstraction so swapping to Sanity later is low-effort.
- **motion** (Framer Motion) — subtle scroll/entrance animations only
- **lucide-react** — icons
- **Resend + React Email** — contact form + lead-capture emails
- **next/og** — dynamic Open Graph images per project/resource/product/service
- **Zod** — all schema + form validation
- **Deploy target:** Vercel

---

## 3. Brand & Design System

Pull the palette from the brand logo: a deep navy field with a cyan→blue gradient chevron mark and white wordmark. **Default to dark theme** (it's the brand); ship a light-mode toggle but optimize dark first.

### Color tokens (define as CSS variables in `globals.css` `@theme`)
```
--background:      #0A1628   /* deep navy */
--surface:         #0F2038   /* card / elevated */
--surface-2:       #14294A
--border:          #1E3354
--primary:         #1E7CE8   /* brand blue */
--accent:          #22CFF0   /* brand cyan */
--foreground:      #FFFFFF
--muted-foreground: #9CB0CC  /* tagline gray-blue */
--brand-gradient:  linear-gradient(135deg, #22CFF0 0%, #1E7CE8 100%)
```
- Use `--brand-gradient` for the logo mark, primary CTAs, and gradient text on key headings.
- Background should feel alive: subtle radial glow + faint dot/grid texture behind the hero, not a flat fill.

### Typography
- Headings: **Sora** (geometric, modern-tech feel, matches the rounded wordmark)
- Body: **Inter**
- Load via `next/font`. Use gradient text only on hero + section accents, never body.

### Visual language
- Modern, clean, spacious. Rounded-2xl cards, soft borders (`--border`), subtle inner glow on hover.
- Light glassmorphism on the navbar (backdrop-blur).
- Tasteful gradient glows behind featured sections.
- Animations: fade-up on scroll, stagger on grids, hover lift on cards. Respect `prefers-reduced-motion`.
- Tagline to reuse: **"Smart Tech, Smarter Solutions"**.

---

## 4. Information Architecture (routes)

```
/                      Home
/about                 About + work experience timeline
/projects              Projects grid (filter: mobile / web)
/projects/[slug]       Project detail (description + screenshot gallery)
/services              Services list
/services/[slug]       Service detail (overview, process, client reviews)
/products              Digital products grid
/products/[slug]       Product detail (gallery, features, buy CTA)
/resources             Resource articles list
/resources/[slug]      Resource article + download (optional email gate)
/contact               Contact form + info
```
Plus: `sitemap.ts`, `robots.ts`, dynamic OG route, 404, loading + error boundaries.

---

## 5. Content Model (Velite collections + Zod schemas)

Author content as MDX in `/content/<collection>/`. Each schema:

**projects**: `title, slug, summary, category('mobile'|'web'), role, year, techStack: string[], cover, screenshots: string[], links: { live?, github?, appStore?, playStore? }, featured: boolean, order`, MDX body.

**services**: `title, slug, icon (lucide name), summary, features: string[], process: { step, title, desc }[], pricing?: { plan, price, items[] }[], featured, order`, MDX body. Client reviews are pulled from `testimonials` where `serviceSlug === this.slug`.

**products**: `title, slug, summary, cover, gallery: string[], price, currency, features: string[], buyUrl (external store / future Stripe), featured, order`, MDX body.

**resources**: `title, slug, excerpt, cover, category, publishedAt, downloadUrl, emailGate: boolean (default true), fileType, fileSize`, MDX article body.

**testimonials**: `name, role, company, avatar, quote, rating(1–5), serviceSlug?, featured`.

Keep all content access behind a thin `lib/content.ts` (e.g. `getProjects()`, `getProjectBySlug()`, `getReviewsForService(slug)`), so pages never import Velite output directly.

---

## 6. Page Requirements

**Home** — hero (name, tagline, gradient mark, two CTAs: "View Work" / "Hire Me"); about teaser; featured projects (3); services overview grid; testimonials carousel; featured products + resources; contact CTA band.

**About** — bio, photo, skills grouped by domain (mobile / web / tooling), vertical **work-experience timeline** (company, role, dates, highlights), downloadable CV button.

**Projects** — responsive card grid with category filter (mobile/web) using a client component over server-fetched data. Cards: cover, title, stack chips, category badge.

**Project detail** — title, summary, meta (role, year, stack), external links, MDX description, and a **screenshot gallery** (lightbox via shadcn dialog or a carousel; phone-frame mockups for mobile projects look sharp). Prev/next project nav.

**Services** — grid of service cards (icon, title, summary). Each links to detail.

**Service detail** — overview (MDX), feature list, numbered **process** steps, optional pricing tiers, and a **client reviews** section filtered by `serviceSlug`. End with a "Request this service" CTA → contact form pre-filled with service name (query param).

**Products** — grid of digital products (cover, title, price). 

**Product detail** — gallery, description (MDX), feature list, price, **buy CTA** (external link now; structure code so a Stripe/Lemon Squeezy checkout can drop in later without refactor).

**Resources** — blog-style list/grid of resource articles (cover, category, excerpt, date). This is the **social-funnel landing layer**.

**Resource detail** — full MDX article explaining the resource, then a **download CTA**. If `emailGate` is true, gate the download behind a name+email form (server action → store lead + send the download link via Resend). If false, direct download. This is the core lead-capture mechanic — make it smooth and obvious.

**Contact** — validated form (name, email, subject, message; optional `service` prefill). Server Action → Zod validate → Resend email to owner + auto-reply to sender. Show success/error states. Include direct contact links (email, LinkedIn, GitHub) and social icons.

---

## 7. Reusable Components

`Navbar` (sticky, blur, active link, mobile sheet), `Footer` (nav + socials + tagline), `Container`, `SectionHeading` (eyebrow + gradient title), `ProjectCard`, `ServiceCard`, `ProductCard`, `ResourceCard`, `TestimonialCard` + `TestimonialCarousel`, `Timeline`, `Gallery/Lightbox`, `TechChip`, `CTABand`, `GradientGlow` (decorative bg), `ThemeToggle`, `MDXComponents` (styled headings, code blocks, callouts), `LeadCaptureForm`, `ContactForm`.

---

## 8. SEO, Performance, Quality

- Per-route `generateMetadata` (title, description, canonical, OG/Twitter). Root `metadataBase`.
- **Dynamic OG images** via `next/og` for project/service/product/resource detail pages (title + brand gradient).
- JSON-LD: `Person` (site-wide), `Service`, `Product`, `Article` (resources).
- `sitemap.ts` + `robots.ts` generated from content collections.
- `next/image` everywhere, explicit sizes, lazy below the fold.
- Server Components by default; mark client components only where interactivity demands it (filters, carousel, forms, theme toggle).
- A11y: semantic landmarks, focus states, keyboard-navigable dialog/carousel, alt text, color contrast AA on dark bg.

---

## 9. Project Structure

```
app/
  (marketing)/            # public pages share a layout
    page.tsx              # home
    about/page.tsx
    projects/page.tsx
    projects/[slug]/page.tsx
    services/page.tsx
    services/[slug]/page.tsx
    products/page.tsx
    products/[slug]/page.tsx
    resources/page.tsx
    resources/[slug]/page.tsx
    contact/page.tsx
  api/og/route.tsx
  actions/                # server actions (contact, lead-capture)
  sitemap.ts  robots.ts  layout.tsx  globals.css
components/  ui/ (shadcn) + custom components
content/     projects/ services/ products/ resources/ testimonials/
lib/         content.ts  seo.ts  utils.ts  validations.ts (zod)
public/      images, screenshots, downloadable files
velite.config.ts
```

---

## 10. Conventions

- TypeScript strict, no `any`, inferred Velite types end-to-end.
- Tailwind tokens only — no raw hex in components, reference the CSS variables.
- Small, composable components; colocate; no premature abstraction.
- Env vars (`RESEND_API_KEY`, `CONTACT_TO_EMAIL`, `NEXT_PUBLIC_SITE_URL`) in `.env.example`.
- Add a short `README.md`: setup, content authoring guide, deploy steps.

---

## 11. Build Order

1. Scaffold Next 15 + TS + Tailwind v4 + shadcn + fonts + theme tokens + `globals.css` design system.
2. Velite config + all schemas + 2–3 seed MDX entries per collection + `lib/content.ts`.
3. Layout: Navbar + Footer + Container + GradientGlow + theme toggle.
4. Home page (all sections, wired to content).
5. Projects list + detail (gallery/lightbox, filter).
6. Services list + detail (process + reviews-by-slug).
7. Resources list + detail (email-gated download via server action + Resend).
8. Products list + detail (buy CTA, Stripe-ready structure).
9. About + Contact (server action + Resend).
10. SEO: metadata, dynamic OG, JSON-LD, sitemap, robots.
11. Polish: animations, responsive QA, a11y, Lighthouse pass.

Confirm the stack choices, then start at step 1. Ask only if a decision is genuinely blocking — otherwise make the senior-engineer call and note it.
