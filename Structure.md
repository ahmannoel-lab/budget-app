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

---

## Complete Page Inventory

### Entry & Navigation
- **splash.html** — App launch screen with "Get Started" and "I already have an account" CTAs
- **index.html** — Homepage that redirects to auth-login.html
- **prototype.html** — Main Overview/Home page (the core app experience with profile, balance, stories, wishlist/discover tabs)

### Authentication Flow
- **auth-login.html** — Login page (glassmorphism design, OAuth options)
- **auth-signup.html** — Sign up form (name, email, password, confirm password)
- **auth-forgot.html** — Password reset page (email input)

### Onboarding Flow (3 Steps)
- **onboarding-welcome.html** — Slide 1 with hero image and centered text
- **onboarding-preferences.html** — Slide 2 (French placeholder content)
- **onboarding-finish.html** — Slide 3 (French placeholder content)
- **onboarding.html** — Wrapper page for swipeable onboarding slides

### Budget Setup Flow (3 Steps)
- **budget-setup-categories.html** — Select categories (Experiences, Shopping, Necessities, Savings, Subscriptions)
- **budget-setup-targets.html** — Set daily spending targets for each category
- **budget-setup-review.html** — Review summary before finishing setup

### Bank Connection Flow
- **add-bank.html** — Alternative bank linking page (older version)
- **connect-bank.html** — Main bank connection page (choose provider: Chase, BofA, Citi, Wells)
- **connect-bank-success.html** — Success state with links to Overview or Discover
- **connect-bank-error.html** — Error state with retry option

### Core App Pages
- **discover.html** — Category exploration (Travel, Fashion, Tech, Dining) with pure CSS :target routing
- **product.html** — Shared product detail page with hero image, metadata, wishlist actions

---

## Authentication — Design & Features

### Pages
1. **Login** (`auth-login.html`)
   - Fields: Username/Email, Password
   - "Remember me" checkbox
   - "Forgot?" link → auth-forgot.html
   - OAuth buttons: Facebook, Google, Apple
   - "Sign Up" link → auth-signup.html

2. **Sign Up** (`auth-signup.html`)
   - Fields: Name, Email, Password, Confirm Password
   - OAuth buttons: Facebook, Google, Apple
   - "Log In" link → auth-login.html

3. **Forgot Password** (`auth-forgot.html`)
   - Single email input field
   - "Back" → auth-login.html
   - "Send Reset Link" → auth-login.html (demo only)

### Visual Design
- **Glassmorphism**: Background image with blur + frosted glass overlay
- **Background**: Editorial fashion/lifestyle photos from Unsplash
- **Colors**: White text on translucent overlay
- **Layout**: Centered on 430x932px phone frame
- **Shadow**: Deep shadow for depth (0 80px 120px rgba(0,0,0,.25))

### OAuth Providers
- **Facebook**: Blue circular button (#1877F2)
- **Google**: White circular button with "G" logo
- **Apple**: Black circular button with Apple icon

---

## Onboarding — Content & Structure

### Current State
- **Language**: French placeholder text ("organiser", "met en place ton évènement...")
- **Structure**: 3 slides with progress dots at bottom
- **Interaction**: Intended to be swipeable (not yet implemented)
- **Background**: Hero image from "Stock money photos/" folder
- **Visual**: Text overlay on darkened background

### Navigation
- Slide 1 (welcome) → Slide 2 (preferences) → Slide 3 (finish) → Budget Setup

### Design Notes
- Top-centered hero text over full-screen image
- Progress dots (3 total, one active per slide)
- Gradient overlay for text legibility

---

## Design System

### Color Tokens

#### Backgrounds
- `--bg-primary: #0C0C0D` — Main app background
- `--bg-elevated: #141416` — Elevated surfaces
- `--bg-surface: #1B1C1E` — Card/surface background
- `--glass-tint: rgba(20, 20, 22, 0.55)` — Glassmorphism overlay

#### Text
- `--text-high: #F2F2F2` — Primary text
- `--text-medium: #CFCFD2` — Secondary text
- `--text-low: #9A9AA0` — Tertiary/disabled text

#### Accents
- `--accent-warm-gold: #D5B06F` — Primary accent (buttons, highlights)
- `--accent-desert-sand: #C7A487` — Secondary accent
- `--accent-amber: #FFBF66` — Warm highlight
- `--accent-sage: #A0B5A5` — Muted green
- `--accent-teal: #56B3B4` — Muted blue
- `--accent-error: #FF6B6B` — Error red
- `--accent-success: #4CC38A` — Success green

#### Borders
- `--border-subtle: rgba(255, 255, 255, 0.06)` — Subtle borders
- `--border-strong: rgba(255, 255, 255, 0.12)` — Strong borders

#### Shadows
- `--shadow-s: 0 2px 8px rgba(0, 0, 0, 0.25)` — Small shadow
- `--shadow-m: 0 8px 24px rgba(0, 0, 0, 0.35)` — Medium shadow
- `--shadow-l: 0 18px 48px rgba(0, 0, 0, 0.45)` — Large shadow

#### Radii
- `--radius-lg: 20px` — Large radius
- `--radius-xl: 24px` — Extra large radius
- `--radius-pill: 999px` — Pill shape

#### Focus
- `--focus-ring: 0 0 0 2px rgba(213, 176, 111, 0.75)` — Focus ring (warm gold)

### Typography
- **Font Family**: "SF Pro", "Inter", "Helvetica Neue", Arial, sans-serif
- **Font Weight**: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
- **Sizes**: 10px–32px (contextual)
- **Letter Spacing**: -0.5px (large headings), 0.08em–0.12em (small caps)

### Phone Frame
- **Width**: 430px
- **Height**: 932px (iPhone 14/15 Pro dimensions)
- **Border Radius**: 32px
- **Shadow**: 0 80px 120px rgba(0,0,0,.25)
- **Padding**: 24px internal content padding

### Visual Patterns

#### Glassmorphism
```css
background: linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,.35) 100%), rgba(20,20,22,.55);
backdrop-filter: saturate(1.2) blur(18px);
border: 1px solid rgba(255,255,255,.12);
```

#### Card/Surface
```css
background: linear-gradient(180deg, rgba(255,200,150,.12) 0%, rgba(0,0,0,.35) 100%), var(--bg-surface);
border: 1px solid rgba(255,255,255,.06);
border-radius: 24px;
box-shadow: 0 8px 24px rgba(0,0,0,.35);
```

---

## Technical Implementation

### Routing Approach
1. **Homepage**: `index.html` → redirects to `auth-login.html`
2. **Overview**: `prototype.html` is the main app home page
3. **Discover**: Uses pure CSS `:target` selectors for category switching
4. **Product**: Shared detail page accessed from Overview or Discover

### Pure CSS Routing (Discover)
```css
#show-travel:target ~ .category-grid { display: none; }
#show-travel:target ~ .feeds #cat-travel { display: block; }
```
- No JavaScript required for category/feed switching
- URL anchors drive state: `#show-travel`, `#show-fashion`, etc.
- "Back" links reset to `#categories`

### JavaScript Functionality
- **Tab Switching** (prototype.html): Toggles between Wishlist and Discover cards
- **Event Listeners**: Basic click handlers for tab navigation
- **DOM Manipulation**: Adds/removes `.active` and `.show-discover` classes

### Asset Management
- **External Images**: Unsplash URLs (e.g., `https://images.unsplash.com/photo-...`)
- **Local Images**: `Stock money photos/` folder + `SampleLogo.png`
- **Relative Paths**: All assets use relative paths for GitHub Pages compatibility
- **Placeholder Content**: French text in onboarding (to be replaced)

### GitHub Pages Compatibility
- All file paths are relative (no absolute paths)
- No backend, database, or server-side logic
- Static HTML/CSS/JS only
- Live-server for local development: `live-server --host=0.0.0.0 --port=8080`

---

## Bank Connection — Flow Clarification

### Two Pages Exist
1. **add-bank.html** — Older/alternative version
   - "Back" → onboarding.html
   - "Continue" → connect-bank.html

2. **connect-bank.html** — Current main page
   - "Back" → budget-setup-review.html
   - "Connect" → connect-bank-success.html
   - "Simulate Error" → connect-bank-error.html

### Success/Error States
- **Success** (`connect-bank-success.html`)
  - "Go to Overview" → prototype.html
  - "Explore Discover" → discover.html

- **Error** (`connect-bank-error.html`)
  - "Try again" → connect-bank.html
  - "Go to Overview" → prototype.html

### Design Notes
- Bank provider tiles: Chase, BofA, Citi, Wells
- Demo only — no real bank integration
- Simulated error state for testing flow

---

## Overview Page — Complete Structure

### File
`prototype.html` — This is the main home page, NOT index.html

### Sections (Top to Bottom)
1. **Top Header**: Logo (SampleLogo.png) + Settings icon
2. **Profile Section**: Avatar + Name ("Marvin McKinney") + Member since date
3. **Balance Section**: Three columns (Liquid, Credit, Savings)
4. **Stories Section**: 4 circular thumbnails with gradient rings (Transactions, Week in Review, Upcoming, Add transactions)
5. **Tabs**: Wishlist (active) / Discover
6. **Card Stack**: 4 stacked cards per tab (8 total)
   - Wishlist: The Oberoi, Aman Tokyo, Sartiano's, Beach Vacation
   - Discover: Tokyo Experience, Paris Hotel, NYC Dining, Mountain Retreat
7. **Bottom Navigation**: Star (Overview) / Plane (Discover) + Home indicator

### Interaction
- Tabs toggle between Wishlist and Discover card sets
- JavaScript adds `.show-discover` class to swap card visibility
- Cards link to `product.html` via "View Details"

---

## Assets & Resources

### Images
- **Unsplash**: Editorial travel, fashion, tech photos
- **Local Folder**: `Stock money photos/` (background images)
- **Logo**: `SampleLogo.png` (appears in prototype.html header)

### Untracked/New Files (per git status)
- `SampleLogo.png`
- `Stock money photos/` folder
- `gh_auth_setup.sh` (git auth script)

---

## Development Notes

### Current Status
- **Homepage**: auth-login.html (set as entry point)
- **Asset Paths**: Fixed for GitHub Pages compatibility
- **Recent Changes**: Multiple pages modified (auth, onboarding, prototype)

### Testing
- **Local**: `http://127.0.0.1:8080/`
- **Mobile**: Use Mac's local IP via `ipconfig getifaddr en0`
- **Live Server**: Auto-reloads on file changes

### Git History
- `d45c889` — Make auth-login the homepage and fix asset paths
- `cab19e1` — Initial commit
