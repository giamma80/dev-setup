# Warp Terminal - Configurazione Ottimizzata

> Workflows e configurazioni per sviluppo full-stack: Git, Docker, Node, Python, AWS, Vercel, Render

## 📋 Come Importare i Workflows

1. Apri **Warp**
2. Vai a `Settings` → `Workflows`
3. Click su `+` per creare nuovo workflow
4. Copia/incolla i comandi da questa guida

---

## 🔧 Workflows Essenziali

### 🌿 Git Workflows

**Git Status Quick**
```bash
git status -sb
```

**Git Smart Commit & Push**
```bash
git add -A && git commit -m "{{MESSAGE}}" && git push
```

**Git Undo Last Commit**
```bash
git reset --soft HEAD~1
```

**Git Branch Cleanup**
```bash
git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
```

**Git Pull Rebase**
```bash
git pull --rebase origin $(git branch --show-current)
```

---

### 🐳 Docker Workflows

**Docker Clean All**
```bash
docker system prune -af --volumes
```

**Docker Stop All**
```bash
docker stop $(docker ps -aq)
```

**Docker Logs Follow**
```bash
docker logs -f {{CONTAINER_NAME}}
```

**Docker Container Shell**
```bash
docker exec -it {{CONTAINER_NAME}} /bin/bash
```

**Docker Compose Rebuild**
```bash
docker-compose down && docker-compose build --no-cache && docker-compose up -d
```

---

### 📦 Node/NPM Workflows

**NPM Fresh Install**
```bash
rm -rf node_modules package-lock.json && npm install
```

**NPM Update All**
```bash
npm outdated && npm update
```

**NPM Audit Fix**
```bash
npm audit fix --force
```

**Yarn Fresh Install**
```bash
rm -rf node_modules yarn.lock && yarn install
```

---

### 🐍 Python Workflows

**Python Create Virtual Environment**
```bash
python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip
```

**Python Install Requirements**
```bash
pip install -r requirements.txt
```

**Python Freeze Requirements**
```bash
pip freeze > requirements.txt
```

**Python Clean Cache**
```bash
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null; find . -type f -name '*.pyc' -delete
```

---

### ☁️ AWS Workflows

**AWS Profile List**
```bash
cat ~/.aws/config | grep profile
```

**AWS Profile Switch**
```bash
export AWS_PROFILE={{PROFILE_NAME}}
```

**AWS S3 Sync**
```bash
aws s3 sync {{LOCAL_PATH}} s3://{{BUCKET}}/{{REMOTE_PATH}} --delete
```

**AWS Lambda Logs**
```bash
aws logs tail /aws/lambda/{{FUNCTION_NAME}} --follow
```

**AWS EC2 List**
```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table
```

---

### 🚀 Vercel Workflows

**Vercel Deploy Preview**
```bash
vercel
```

**Vercel Deploy Production**
```bash
vercel --prod
```

**Vercel Logs**
```bash
vercel logs {{DEPLOYMENT_URL}}
```

**Vercel Env Pull**
```bash
vercel env pull .env.local
```

---

### 🐙 GitHub Workflows

**GitHub Create PR**
```bash
gh pr create --fill
```

**GitHub PR List**
```bash
gh pr list
```

**GitHub Create Issue**
```bash
gh issue create --title "{{TITLE}}" --body "{{BODY}}"
```

**GitHub Repo View**
```bash
gh repo view --web
```

---

### 🛠️ Utility Workflows

**Kill Process on Port**
```bash
lsof -ti:{{PORT}} | xargs kill -9
```

**Find Large Files (>100MB)**
```bash
find . -type f -size +100M -exec ls -lh {} \;
```

**Disk Usage (Top 10)**
```bash
du -sh * | sort -rh | head -10
```

---

## 🎯 Alias Consigliati

Aggiungi questi al tuo `~/.zshrc`:

```bash
# Git
alias gs='git status -sb'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull --rebase'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Docker
alias dps='docker ps'
alias dimg='docker images'
alias dclean='docker system prune -af'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'

# Node
alias ni='npm install'
alias nrd='npm run dev'
alias nrs='npm run start'
alias nrb='npm run build'
alias nrt='npm run test'

# Python
alias py='python3'
alias venv='python3 -m venv venv && source venv/bin/activate'
alias pip='pip3'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias scripts='cd ~/scripts'
alias projects='cd ~/projects'

# Utilities
alias ll='ls -lah'
alias grep='grep --color=auto'
alias ports='lsof -i -P | grep LISTEN'
```

---

## 💡 Warp AI Prompts Utili

Usa `Ctrl+Shift+R` per aprire Warp AI e prova questi prompt:

- "Show git history for last 10 commits"
- "Explain this docker compose file"
- "Create AWS CLI command to list S3 buckets"
- "Generate GitHub Actions workflow for Node.js"
- "Find memory leaks in this Python code"
- "Optimize this SQL query"
- "Create Dockerfile for Node.js app"
- "Debug this bash script"
- "Convert this curl command to Python requests"

---

## ⚙️ Configurazione Warp

### Tema Consigliato
`Settings > Appearance > Theme` → **Dracula** o **Tokyo Night**

### Font
`Settings > Editor` → **Fira Code** o **JetBrains Mono** (con ligature)

### Features da Abilitare
- ✅ Warp AI
- ✅ Command Completions
- ✅ Workflows
- ✅ Cloud Sync (Warp Drive)

---

## 📚 Risorse

- [Warp Docs](https://docs.warp.dev/)
- [Warp Workflows Guide](https://docs.warp.dev/features/workflows)
- [Warp AI Guide](https://docs.warp.dev/features/ai)
