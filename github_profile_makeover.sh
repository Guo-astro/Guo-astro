#!/usr/bin/env bash
# github_profile_makeover.sh — v0.0.1 — one‑stop GitHub CLI script to automate the "stunning profile" checklist
# -----------------------------------------------------------------------------
# ⚠️  Prerequisites
#   1. GitHub CLI (`gh`) ≥ v2.5 installed & authenticated (`gh auth login`)
#   2. jq & git available in PATH
#   3. Run from any folder on a machine that has push rights to your account
#
# Usage (dry‑run by default):
#   ./github_profile_makeover.sh            # shows what would happen
#   ./github_profile_makeover.sh --apply    # actually performs the changes
# -----------------------------------------------------------------------------

set -euo pipefail

# -------- Configurable variables --------------------------------------------
# Adjust these repo names to match what you want pinned & preserved
PINNED_REPOS=(
  "browser-use-webui-multimodel"
  "mini-llm-rl"
  "copilot-x"
  "react-shadcn-scheduler"
  "react-json-graph"
  "multi-tenant-hub"
  "flutter_flavorizor_extended"
)

# We'll append the username later once we know it
PROTECTED_REPOS=("${PINNED_REPOS[@]}")

# README template for the profile repo ---------------------------------------
read -r -d '' PROFILE_README_TEMPLATE <<'EOF' || true
<h1 align="center">Hi, I'm <USERNAME> 👋</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white"/>
  <img src="https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white"/>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=cplusplus&logoColor=white"/>
</p>

### 🚀 About Me
- 🔭 I'm building **Copilot-style tooling for internal DevOps**
- 🌱 Currently diving deep into *LLM evaluation* and *LangChain*
- 💬 Ask me about **prompt engineering**, **react‑shadcn**, or **katsu‑sando recipes**

### 📦 My Packages
- 🐦 **Flutter**: [flutter_flavorizr_extended](https://pub.dev/packages/flutter_flavorizr_extended) - Extended flavorizr for Flutter projects
- 📡 **Dart**: [network_usage](https://pub.dev/packages/network_usage) - Network usage monitoring package
- 🐍 **Python**: [tfp_causalimpact_customized](https://pypi.org/project/tfp-causalimpact-customized/) - Customized TensorFlow Probability CausalImpact
- 📄 **NPM**: [react-pdf-transformer](https://www.npmjs.com/package/react-pdf-transformer) - React PDF transformation utilities

### 🌟 Featured
- 📰 **Featured Interview**: [My Story of a Deep-Tech Startup](https://cloud.google.com/blog/ja/topics/customers/optimind-the-appeal-of-gke-and-the-significance-of-certification/?hl=ja) - Google Cloud Blog

### 🔗 Connect with me
<p align="center">
  <a href="https://goastro.website/"><img src="https://img.shields.io/badge/Blog-FF5722?style=for-the-badge&logo=blogger&logoColor=white"/></a>
  <a href="https://x.com/dnangellight"><img src="https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white"/></a>
  <a href="https://www.linkedin.com/in/yansong-guo-454a20136/"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a>
</p>

### 📈 Stats
![GitHub Stats](https://github-readme-stats.vercel.app/api?username=<USERNAME>&show_icons=true)

---
*"Imagination is more important than knowledge. Knowledge is limited, imagination embraces the entire world." – Albert Einstein*
EOF

# ----------------------------------------------------------------------------
DRY_RUN=true
if [[ "${1:-}" == "--apply" ]]; then
  DRY_RUN=false
fi

info()  { printf "\e[34m[INFO]\e[0m %s\n" "$*"; }
warn()  { printf "\e[33m[WARN]\e[0m %s\n" "$*"; }
abort() { printf "\e[31m[ABORT]\e[0m %s\n" "$*"; exit 1; }
run()   { $DRY_RUN && info "(dry‑run) $*" || { info "$*"; eval "$*"; }; }

# -------- Determine GitHub username -----------------------------------------
GITHUB_USER=$(gh api user --jq '.login') || abort "GitHub CLI not authenticated. Run 'gh auth login' first."
info "GitHub user detected as $GITHUB_USER"

# After we know the username, protect the profile repo itself from archiving
PROTECTED_REPOS+=("$GITHUB_USER")

# -------- 1. Create / update profile repo -----------------------------------
if ! gh repo view "$GITHUB_USER/$GITHUB_USER" &>/dev/null; then
  info "Creating profile repository $GITHUB_USER/$GITHUB_USER"
  run "gh repo create \"$GITHUB_USER/$GITHUB_USER\" --public --description '🪄 Auto‑generated profile README' --confirm"
else
  info "Profile repository already exists"
fi

# Clone profile repo to a temp dir
TMPDIR=$(mktemp -d)
run "git clone --depth 1 \"https://github.com/$GITHUB_USER/$GITHUB_USER.git\" $TMPDIR/profile"

if ! $DRY_RUN; then
  cd "$TMPDIR/profile"
fi

# Generate README if missing --------------------------------------------------
if [[ ! -f README.md ]] && ! $DRY_RUN; then
  info "Generating profile README.md"
  sed "s/<USERNAME>/$GITHUB_USER/g" <<<"$PROFILE_README_TEMPLATE" > README.md
  run "git add README.md"
  run "git commit -m 'chore: add autogenerated profile README'"
  run "git push origin main"
elif [[ -f README.md ]] && ! $DRY_RUN; then
  info "Updating existing README.md with new template"
  sed "s/<USERNAME>/$GITHUB_USER/g" <<<"$PROFILE_README_TEMPLATE" > README.md
  run "git add README.md"
  run "git commit -m 'chore: update profile README with featured content and social links'"
  run "git push origin main"
elif $DRY_RUN; then
  info "(dry‑run) would generate/update README.md"
else
  info "README.md already present; skipping generation"
fi

# Add nightly metrics GitHub Action ------------------------------------------
METRICS_WORKFLOW=.github/workflows/metrics.yml
if [[ ! -f $METRICS_WORKFLOW ]] && ! $DRY_RUN; then
  info "Adding GitHub Metrics workflow"
  mkdir -p .github/workflows
  cat > $METRICS_WORKFLOW <<'YAML'
name: 📊 Metrics
on:
  schedule:
    - cron:  '0 23 * * *'
  workflow_dispatch:
jobs:
  github-metrics:
    runs-on: ubuntu-latest
    steps:
      - uses: lowlighter/metrics@latest
        with:
          token: ${{ secrets.METRICS_TOKEN || secrets.GITHUB_TOKEN }}
YAML
  run "git add $METRICS_WORKFLOW"
  run "git commit -m 'ci: add metrics workflow'"
  run "git push origin main"
elif $DRY_RUN; then
  info "(dry‑run) would add GitHub Metrics workflow if missing"
fi

if ! $DRY_RUN; then
  cd - >/dev/null
fi

# -------- 2. Pin repositories ------------------------------------------------
info "Pinning repositories"
pin_repo() {
  local repo=$1
  local owner=$GITHUB_USER
  local repoId
  repoId=$(gh api graphql -f query="query{repository(owner:\"$owner\",name:\"$repo\"){id}}" --jq '.data.repository.id') || return 1
  gh api graphql -f query="mutation($repoId:ID!){pinRepository(input:{repositoryId:$repoId}){clientMutationId}}" -F repoId="$repoId" &>/dev/null &&
  info "Pinned $repo" || warn "Failed to pin $repo (maybe already pinned)"
}

for repo in "${PINNED_REPOS[@]}"; do
  if gh repo view "$GITHUB_USER/$repo" &>/dev/null; then
    $DRY_RUN && info "(dry‑run) would pin $repo" || pin_repo "$repo"
  else
    warn "$repo does not exist under your account; skipping"
  fi
done

# -------- 3. Archive/privatize clutter --------------------------------------
info "Scanning for stale repos to archive (zero stars, not protected)"

# Use a more portable approach instead of readarray
ALL_REPOS=()
while IFS= read -r line; do
  ALL_REPOS+=("$line")
done < <(gh repo list "$GITHUB_USER" --json name,stargazerCount,visibility --jq '.[] | @base64')

for encoded in "${ALL_REPOS[@]:-}"; do
  _jq() { echo "$encoded" | base64 --decode | jq -r "$1"; }
  name=$(_jq '.name')
  stars=$(_jq '.stargazerCount')
  if [[ " ${PROTECTED_REPOS[*]} " =~ " $name " ]]; then
    continue
  fi
  if (( stars == 0 )); then
    info "Scheduling $name for archival (stars=0)"
    run "gh repo archive \"$GITHUB_USER/$name\" --confirm"
  fi
done

# -------- 5. Add topics to pinned repos -------------------------------------
for repo in "${PINNED_REPOS[@]}"; do
  run "gh repo edit \"$GITHUB_USER/$repo\" --add-topic llm --add-topic opensource"
done

info "Script finished."
$DRY_RUN && info "Run again with --apply to perform the changes." || info "All actions applied."
