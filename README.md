# 🚀 Dev Setup Scripts

> Automated development environment setup and AI copilot configurations

[![macOS](https://img.shields.io/badge/macOS-14.0+-blue)](https://www.apple.com/macos/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/Python-3.10+-yellow)](https://www.python.org/)

---

## 📁 Repository Structure

```
~/scripts/
├── ai-configurations/          # AI Copilot configurations
│   ├── README.md              # Complete AI setup guide
│   ├── base-config.json       # Single source of truth (MODIFY THIS)
│   ├── claude-vscode.json     # Auto-generated
│   ├── claude-cli-config.json # Auto-generated
│   ├── github-copilot-vscode.json # Auto-generated
│   └── warp-config.md         # Warp Terminal workflows
│
├── dev-configurations/         # Development environment setup
│   ├── README.md              # Setup scripts documentation
│   └── mac-dev-setup.sh       # Automated Mac dev environment setup
│
├── sync-configs.js            # Auto-generates AI configs from base-config.json
└── .gitignore                 # Git exclusions
```

---

## 🎯 Quick Start

### 1️⃣ Setup Development Environment (First Time)

```bash
cd ~/scripts/dev-configurations

# Dry-run (see what will be installed)
./mac-dev-setup.sh --dry-run

# Full installation
./mac-dev-setup.sh
```

**Installs**:
- Homebrew, Oh My Zsh
- Node.js (nvm), Python (pyenv), Go
- Docker (Colima), Docker Compose
- Git, jq, htop, wget, curl

📖 **Full docs**: [`dev-configurations/README.md`](dev-configurations/README.md)

---

### 2️⃣ Configure AI Copilots

```bash
cd ~/scripts/ai-configurations

# 1. Edit base config (ONLY file you need to modify)
vim base-config.json

# 2. Regenerate all AI configs
cd ~/scripts
node sync-configs.js

# 3. Apply configs to your AI tools
# See ai-configurations/README.md for detailed instructions
```

**Generates configs for**:
- Claude Code (VS Code extension)
- Claude CLI (terminal tool)
- GitHub Copilot (VS Code)

📖 **Full docs**: [`ai-configurations/README.md`](ai-configurations/README.md)

---

## 🔧 Workflow

### Modify AI Configurations

```bash
# 1. Edit ONLY base-config.json
vim ai-configurations/base-config.json

# 2. Auto-generate all configs
node sync-configs.js

# 3. Commit changes
git add . && git commit -m "feat: update AI config" && git push
```

### Update Development Setup Script

```bash
# 1. Edit mac-dev-setup.sh
vim dev-configurations/mac-dev-setup.sh

# 2. Test with dry-run
./dev-configurations/mac-dev-setup.sh --dry-run

# 3. Commit changes
git add . && git commit -m "feat: add terraform to setup" && git push
```

---

## 📚 Documentation

| Topic | Location | Description |
|-------|----------|-------------|
| **AI Copilots** | [`ai-configurations/README.md`](ai-configurations/README.md) | Complete guide for Claude & GitHub Copilot setup |
| **Dev Environment** | [`dev-configurations/README.md`](dev-configurations/README.md) | Mac development environment automation |
| **Base Config** | [`ai-configurations/base-config.json`](ai-configurations/base-config.json) | Single source of truth for AI configs |

---

## 🎯 Features

### AI Configurations
- ✅ Centralized config (`base-config.json`)
- ✅ Auto-generation (`sync-configs.js`)
- ✅ Priority/rationale/constraints meta-fields
- ✅ Golden rules & warnings
- ✅ Tech stack with 50+ libraries
- ✅ Compatibility constraints (Node 18+, Python 3.10+)
- ✅ Separate configs for VS Code and CLI

### Dev Setup Script
- ✅ Automated installation
- ✅ Dry-run mode
- ✅ Detailed logging
- ✅ JSON report generation
- ✅ Idempotent (safe to re-run)
- ✅ Supports Intel & Apple Silicon

---

## 🛠️ Tech Stack

### Languages & Runtimes
- Node.js 18+ (via nvm)
- Python 3.10+ (via pyenv)
- Go 1.21+
- TypeScript 5+

### Frontend
- React 18+, Next.js, React Native
- Chakra UI, Radix UI, Tailwind CSS
- React Hook Form, Zod
- Framer Motion

### Backend
- Express, Fastify, NestJS
- FastAPI, Flask
- SQLModel, Pydantic

### Database & Infrastructure
- Supabase, PostgreSQL, Redis
- Docker, Colima
- Vercel, Render
- GitHub Actions, GitLab CI

### ML & AI
- PyTorch, Transformers (Hugging Face)
- LangChain, sentence-transformers
- Polars, Prefect, Dagster

---

## 🔄 Updates

Pull latest changes:

```bash
cd ~/scripts
git pull origin main
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly
4. Use conventional commits
5. Submit a pull request

**Commit Format**:
```bash
feat: add new feature
fix: fix bug
refactor: refactor code
docs: update documentation
```

---

## 📊 Change Log

### v1.2.0 (2025-11-09)
- Reorganized structure: `ai-configurations/` and `dev-configurations/`
- Added meta-fields (priority/rationale/constraints)
- Added golden rules and warnings
- Consolidated documentation into single READMEs

### v1.1.0 (2025-11-09)
- Upgraded to Claude Sonnet 4.5
- Added Claude CLI configuration
- Integrated official best practices

### v1.0.0 (2025-11-08)
- Initial centralized configuration system
- Mac dev setup script
- Auto-generation via sync-configs.js

---

## 📝 License

MIT

---

## 🔗 Links

- **Repository**: [github.com/giamma80/dev-setup](https://github.com/giamma80/dev-setup)
- **Issues**: [Report a bug or request feature](https://github.com/giamma80/dev-setup/issues)
- **Maintainer**: [@giamma80](https://github.com/giamma80)

---

**⚡ Quick Links**:
- [AI Configuration Guide](ai-configurations/README.md)
- [Dev Setup Guide](dev-configurations/README.md)
- [Base Config JSON](ai-configurations/base-config.json)
