#!/usr/bin/env bash
set -euo pipefail

log() { printf "%s\n" "$*"; }
hr() { printf "%s\n" "----------------------------------------"; }

# 1) Pre-flight
hr; log "Pre-flight checks"
if ! ls *.html >/dev/null 2>&1; then
  log "ERROR: No .html files found in the current directory."
  log "cd into your project root (where prototype.html lives) and re-run."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  log "ERROR: git not found. Install with: brew install git"
  exit 1
fi
if ! git --version >/dev/null 2>&1; then
  log "ERROR: git is blocked by Xcode license or not fully installed."
  log "Run: sudo xcodebuild -license   (or: xcode-select --install)"
  exit 1
fi

if command -v gh >/dev/null 2>&1; then
  GH_AVAILABLE=1
  log "GitHub CLI: found"
else
  GH_AVAILABLE=0
  log "GitHub CLI: not found (will continue and skip auto-create)"
fi

REPO_NAME="$(basename "$PWD")"

# 2) Git setup
hr; log "Git setup"
if [ ! -d .git ]; then
  log "Initializing git repo (main)"
  git init -b main >/dev/null 2>&1 || git init >/dev/null 2>&1
  git checkout -B main >/dev/null 2>&1 || true
else
  log ".git already exists"
fi

if [ ! -f .gitignore ]; then
  log "Creating .gitignore"
  cat > .gitignore <<'GITIGNORE'
.DS_Store
node_modules
dist
.env
GITIGNORE
else
  log ".gitignore exists"
fi

if [ ! -f README.md ]; then
  log "Creating README.md"
  printf "# %s\n\nDeployed via GitHub Pages.\n" "$REPO_NAME" > README.md
else
  log "README.md exists"
fi

if [ ! -f index.html ]; then
  log "Creating placeholder index.html (no overwrite)"
  cat > index.html <<'HTML'
<!doctype html>
<html lang="en"><head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Hello</title>
</head><body>
  <h1>Hello from GitHub Pages</h1>
</body></html>
HTML
else
  log "index.html exists (left unchanged)"
fi

# .nojekyll avoids Jekyll processing on Pages
touch .nojekyll

# 3) Remote / GitHub repo
hr; log "Remote setup"
HAS_ORIGIN=0
if git remote get-url origin >/dev/null 2>&1; then
  HAS_ORIGIN=1
  ORIGIN_URL="$(git remote get-url origin)"
  log "origin already set: $ORIGIN_URL"
else
  if [ "$GH_AVAILABLE" -eq 1 ]; then
    log "Creating GitHub repo via gh (public)…"
    if gh repo create "$REPO_NAME" --public --source=. --remote=origin --push >/dev/null 2>&1; then
      log "GitHub repo created and pushed via gh."
      HAS_ORIGIN=1
    else
      log "gh repo create failed (not authenticated or network)."
      log "Create a blank repo on GitHub named: $REPO_NAME"
      log "Then run:"
      log "git remote add origin https://github.com/<YOUR-USERNAME>/$REPO_NAME.git"
    fi
  else
    log "gh not available."
    log "Create a blank repo on GitHub named: $REPO_NAME, then run:"
    log "git remote add origin https://github.com/<YOUR-USERNAME>/$REPO_NAME.git"
  fi
fi

# 4) Commit & push
hr; log "Commit & push"
git add -A

HAS_COMMITS=0
if git rev-parse --verify HEAD >/dev/null 2>&1; then HAS_COMMITS=1; fi

if ! git diff --cached --quiet; then
  if [ "$HAS_COMMITS" -eq 0 ]; then
    git commit -m "Initial commit" >/dev/null 2>&1 || true
  else
    git commit -m "Update" >/dev/null 2>&1 || true
  fi
else
  log "Nothing to commit."
fi

if git remote get-url origin >/dev/null 2>&1; then
  if ! git push -u origin main >/dev/null 2>&1; then
    log "Push failed. Hint: gh auth login (or set a GitHub PAT) then re-run git push."
  else
    log "Pushed to origin/main."
  fi
fi

# 5) Helpful scripts (package.json)
hr; log "Helper script"
if [ ! -f package.json ]; then
  cat > package.json <<JSON
{
  "name": "$REPO_NAME",
  "private": true,
  "scripts": {
    "deploy": "git add . && git commit -m \"update\" || true && git push"
  }
}
JSON
  log "Created package.json with deploy script."
else
  log "package.json exists (left unchanged)."
fi

# 6) Output links
hr; log "Links & next steps"
REPO_URL=""
if git remote get-url origin >/dev/null 2>&1; then
  RAW_URL="$(git remote get-url origin)"
  if printf "%s" "$RAW_URL" | grep -q '^git@github.com:'; then
    REPO_URL="https://github.com/$(printf "%s" "$RAW_URL" | sed -E 's#git@github.com:([^/]+)/([^/]+)\.git#\1/\2#')"
  else
    REPO_URL="$(printf "%s" "$RAW_URL" | sed -E 's#\.git$##')"
  fi
  log "Repo: $REPO_URL"
  if [ -n "$REPO_URL" ]; then
    USER="$(printf "%s" "$REPO_URL" | sed -E 's#https://github.com/([^/]+)/.*#\1#')"
    NAME="$(printf "%s" "$REPO_URL" | sed -E 's#.*/([^/]+)$#\1#')"
    log "Pages settings: https://github.com/$USER/$NAME/settings/pages"
    log "Site (after Pages is enabled): https://$USER.github.io/$NAME/"
  fi
else
  log "origin not set; set it to get repo/pages links."
fi

hr
cat <<'NEXT'
1. Open the Pages settings link printed above.
2. Under “Build and deployment,” set Source = Deploy from a branch.
3. Set Branch = main and Folder = /(root), then Save.
4. Wait ~30 seconds, then visit: https://<user>.github.io/<repo>/ on your phone.
5. For quick updates from Cursor next time, run: npm run deploy (it will commit and push).
6. (Optional) Mobile editing:
• iPhone: clone the repo in Working Copy, edit in Kodex or Textastic, then commit & push.
• Android: clone in Acode (supports Git), edit, commit & push.
7. Refresh your Pages URL on your phone to see changes.
NEXT

