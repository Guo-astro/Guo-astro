# GitHub Profile Makeover 🪄

A one-stop GitHub CLI script to automate your "stunning profile" checklist and showcase your packages beautifully.

## ✨ Features

- 🎯 **Auto-generate** professional profile README with your tech stack
- 📌 **Pin repositories** automatically 
- 🏷️ **Add topics** to repositories for better discoverability
- 🗂️ **Archive stale repos** (0 stars) to keep your profile clean
- 📊 **GitHub Metrics** workflow for beautiful stats
- 🔗 **Package showcase** with direct links to pub.dev, NPM, PyPI, Crates.io

## 🚀 Quick Start

### Prerequisites

1. **GitHub CLI** (`gh`) ≥ v2.5 installed & authenticated
   ```bash
   # Install GitHub CLI
   brew install gh
   
   # Authenticate
   gh auth login
   ```

2. **Required tools** in PATH: `jq`, `git`
   ```bash
   # Install jq
   brew install jq
   ```

### Usage

```bash
# Clone or download the script
curl -O https://raw.githubusercontent.com/Guo-astro/myghprofile/main/github_profile_makeover.sh
chmod +x github_profile_makeover.sh

# Dry run (shows what would happen)
./github_profile_makeover.sh

# Apply changes
./github_profile_makeover.sh --apply
```

## 📋 What It Does

### 1. Profile Repository Setup
- Creates `USERNAME/USERNAME` repository if it doesn't exist
- Generates professional README with:
  - Tech stack badges (Python, TypeScript, Rust, Flutter, C++)
  - About Me section with your current focus
  - Package showcase with direct links
  - Social media links
  - GitHub stats

### 2. Repository Management
- Pins your featured repositories
- Archives repositories with 0 stars (keeps your profile clean)
- Adds relevant topics for better discoverability

### 3. Automation
- Sets up GitHub Metrics workflow for beautiful stats
- Runs nightly to keep your profile fresh

## 🎨 Customization

### Configure Your Pinned Repositories
Edit the `PINNED_REPOS` array in the script:

```bash
PINNED_REPOS=(
  "browser-use-webui-multimodel"
  "mini-llm-rl"
  "copilot-x"
  "react-shadcn-scheduler"
  "react-json-graph"
  "multi-tenant-hub"
  "flutter_flavorizor_extended"
)
```

### Update Your Package Links
The script automatically includes:
- 🐦 **Flutter**: flutter_flavorizr_extended
- 📡 **Dart**: network_usage  
- 🐍 **Python**: tfp_causalimpact_customized
- 📄 **NPM**: react-pdf-transformer
- 🦀 **Rust**: chaum_pedersen_auth

### Modify Your Profile Content
Edit the `PROFILE_README_TEMPLATE` section to customize:
- Personal introduction
- Current focus areas
- Social media links
- Featured content

## 🔄 Release Management

### Simple Release Steps

1. **Make your changes** to the script
2. **Test thoroughly** with dry run mode
3. **Create a release**:
   ```bash
   # For bug fixes
   ./release.sh patch    # 1.0.0 -> 1.0.1
   
   # For new features  
   ./release.sh minor    # 1.0.0 -> 1.1.0
   
   # For breaking changes
   ./release.sh major    # 1.0.0 -> 2.0.0
   ```

The release script will:
- ✅ Check for uncommitted changes
- 📝 Update version in script header
- 🏷️ Create and push git tag
- 📤 Push to remote repository
- 🎉 Show next steps

### Manual Release Process
If you prefer manual releases:

```bash
# 1. Update version in script header
# 2. Commit changes
git add .
git commit -m "chore: release v1.0.1"

# 3. Create tag
git tag -a v1.0.1 -m "Release v1.0.1"

# 4. Push
git push origin main --tags
```

## 🛡️ Safety Features

- **Dry run by default** - shows what would happen without making changes
- **Protected repositories** - won't archive pinned repos or profile repo
- **Confirmation prompts** for destructive actions
- **Error handling** with clear messages

## 📸 Example Profile

Your generated profile will include:

```markdown
# Hi, I'm YourUsername 👋

� Python • 📘 TypeScript • 🦀 Rust • 🐦 Flutter • ⚡ C++

### 🚀 About Me
- 🔭 I'm building Copilot-style tooling for internal DevOps
- 🌱 Currently diving deep into LLM evaluation and LangChain
- 💬 Ask me about prompt engineering, react-shadcn, or katsu-sando recipes

### 📦 My Packages
- 🐦 Flutter: flutter_flavorizr_extended
- 📡 Dart: network_usage
- 🐍 Python: tfp_causalimpact_customized
- 📄 NPM: react-pdf-transformer
- 🦀 Rust: chaum_pedersen_auth

### 🔗 Connect with me
🌐 Blog • 🐦 Twitter • 💼 LinkedIn
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Test with dry run mode
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## � Acknowledgments

- GitHub CLI team for the awesome API
- [lowlighter/metrics](https://github.com/lowlighter/metrics) for beautiful GitHub metrics
- The open source community for inspiration

---

*"Imagination is more important than knowledge. Knowledge is limited, imagination embraces the entire world." – Albert Einstein*
