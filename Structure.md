# Home Screen Structure

## Layout Hierarchy
```
├── Status Bar
│   └── Time + System Icons
│
├── Header Stories (4 items)
│   ├── Transactions (thumb)
│   ├── Week in Review (thumb)
│   ├── Upcoming (thumb)
│   └── Add transactions (thumb)
│
├── Account Balance
│   ├── Amount ($482)
│   └── Label
│
├── Budget Feed (5 rows)
│   ├── Experiences
│   ├── Shopping
│   ├── Necessities
│   ├── Savings
│   └── Subscriptions
│   └── Each row: Avatar + LIVE pill + ticks + viewers + title
│
├── Navigation Tabs
│   ├── Wishlist (active)
│   └── Discover
│
├── Stacked Cards (4 cards)
│   ├── The Oberoi (back)
│   ├── Aman Tokyo
│   ├── Sartiano's
│   └── Beach Vacation (front)
│       ├── Header (Icon + Title + Status)
│       ├── Image (224px)
│       └── Actions (View Details + Arrow)
│
└── Bottom Navigation
    ├── Controls bar (2 items)
    └── Home Indicator
```

---

# Navigation Update — Two-Page App

## Constraints
- **Do not change the Overview (Home) page** layout, order, or content. It is already designed.
- Add only the sections below and the routing they reference.

## Primary Tabs
1. **Overview (Home)** — existing, unchanged  
   - Route: `/`
2. **Discover** — new  
   - Route: `/discover`
3. **Product Detail** — shared endpoint (navigated into from cards)  
   - Route: `/product/:id`
   - Not a tab; accessed from Overview or Discover

---

## Discover — Explore by Category (New)

### Purpose
An intentional exploration hub. Shows **categories only** on initial load. A product **feed appears only after a category is selected**.

### Routes
- Page: `/discover`
- Category feed (client state): `/discover?category={slug}`

### Initial State (Category Grid)
- **No product feed visible.**
- Components:
  - Page header (title + optional search icon)
  - **Category tiles** (cards with image, label, optional count)
- Interactions:
  - Tap category tile → **opens category feed** (see below)
  - Back nav returns to **category grid**, not Overview

### Category Feed (Within Discover)
- Trigger: selecting a category tile
- Components:
  - Category header (name, filter/sort)
  - **Scrollable product feed** (cards: image, name, short meta)
- Interactions:
  - Tap product card → **navigate to Product Detail** (`/product/:id`)
  - Back → returns to the **category grid** state

### Visual / UX Notes
- Dark-mode base with warm, editorial imagery.
- Category grid uses large, tactile tiles; feed reuses the same card style as Overview’s discovery preview.
- No infinite feed on initial `/discover`—**user must pick a category first**.

---

## Overview (Home) — Feed Behavior (Unchanged; Documented)

> **Do not edit the Overview layout.** This section documents how it connects to Discover and Product Detail.

### Existing Sections (for reference only)
- Top Summary (status + balance + trend)
- Category Wallet Cards (daily spend guidance)
- **Bottom Expandable Feed** (toggle between **Wishlist** and **Discovery Preview**)
- Floating “+” (Add Expense modal)

### Navigation from Overview
- Tap **Wishlist/Discovery Preview card** → **Product Detail** (`/product/:id`)
- Tap **“View All”** on Discovery Preview → **Discover** (`/discover`, category grid)

---

## Product Detail — Shared Endpoint (New)

### Purpose
A focused detail view for any item reached from Overview or Discover.

### Route
- `/product/:id`

### Components
- Hero image (editorial, warm)
- Title, meta (price/brand/source)
- Actions:
  - **Add to Wishlist** / **Remove from Wishlist**
  - Optional: “Track Progress” (hooks into budget/goal)
- Secondary info: description, gallery, related items (optional later)

### Navigation
- Enter from: Overview feed card OR Discover category feed
- Back returns to the **origin context** (preserve scroll position/state)

### Visual / UX Notes
- Dark, cinematic base; images supply color.
- Buttons use warm neutral accents (no neon).
- Maintain legibility via soft overlays on imagery.

---

## Routing Summary

- `/` → Overview (unchanged)
- `/discover` → Category grid (no feed)
- `/discover?category={slug}` → Category feed within Discover
- `/product/:id` → Product Detail (entered from Overview or Discover)


---

## Flows & Guards — Once‑Only Setup

### State Flags
- `isAuthenticated: boolean`
- `onboardingComplete: boolean`
- `budgetSetupComplete: boolean`
- `bankLinked: boolean`
- `pendingDestination: string | null` (where to return after gates)

### Gate Order (exact sequence)
1. Onboarding — once, before sign‑up
   - Routes: `/onboarding/welcome` → `/onboarding/preferences` → `/onboarding/finish`
   - On finish: set `onboardingComplete = true` → continue to Auth
2. Auth
   - Routes: `/auth/signup` (or `/auth/login` for returning users)
3. Budget Mapping — once, 3 steps
   - Routes: `/budget-setup/categories` → `/budget-setup/targets` → `/budget-setup/review`
   - On finish: set `budgetSetupComplete = true`
4. Bank Connection — once
   - Routes: `/connect-bank` → (`/connect-bank/success` | `/connect-bank/error`)
   - On success: set `bankLinked = true`
5. Landing
   - Go to `/` (Overview) or `pendingDestination` if it was set prior to gating

### Subsequent App Launches
- If all flags are true → route directly to `/`.
- Otherwise, jump to the first incomplete step in the same order (Onboarding → Auth → Budget → Bank), then return to the intended destination.

### Notes
- Each flow runs exactly once per user as part of initial setup. Users may revisit these areas later from Settings, but they are not re‑gated on normal launches.
