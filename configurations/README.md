# 🤖 AI Copilot Configurations

> Configurazioni centralizzate e ottimizzate per sviluppo full-stack professionale

## 🎯 Specializzazioni

- **Frontend**: React, React Native, Next.js, TypeScript
- **Mobile**: React Native, Expo, iOS (Swift)
- **Backend**: Node.js, Python (FastAPI, Flask), NestJS
- **Database**: Supabase, PostgreSQL, MongoDB, Redis
- **Infrastructure**: Docker, Vercel, Render
- **DevOps**: GitHub Actions, GitLab CI/CD
- **Automation**: n8n workflows

---

## 📁 Struttura File

### 1. **base-config.json** ⭐
**Configurazione centralizzata e fonte di verità**

Contiene:
- 🎛️ Parametri AI (temperature: 0.3, creativity, verbosity, mode)
- 🛠️ Tech stack completo
- 📏 Coding standards (max 25 righe/funzione, no duplicati)
- 🎨 Design patterns (DI, Strategy, CQRS, Business Delegate)
- 🚫 Antipatterns da evitare
- ✅ Quality requirements (linting, testing ≥80%, documentation)
- 🔒 Security best practices
- ⚡ Performance considerations
- 📚 Best practices per ogni tecnologia

### 2. **INSTRUCTIONS.md** 📋
**Istruzioni complete da copiare nei copilot**

Formato markdown ready-to-copy per:
- Claude Code custom instructions
- GitHub Copilot chat instructions
- Warp AI context

### 3. **claude-vscode.json**
Configurazione Claude Code per VS Code
- Extends base-config.json
- Temperature 0.3
- Context window avanzato
- Custom instructions dettagliate
- File patterns ottimizzati

### 4. **github-copilot-vscode.json**
Settings GitHub Copilot per VS Code
- Temperature 0.3
- Chat in italiano
- Editor settings ottimizzati
- Linting e formatting automatici

### 5. **warp-config.md**
Guida completa Warp Terminal
- 40+ workflows predefiniti
- Comandi per tutto lo stack
- Alias shell produttivi
- Warp AI prompts

---

## 🚀 Quick Start

### 1. Modifica la Configurazione Base (UNICO FILE DA MODIFICARE)
```bash
cd ~/scripts
vim configurations/base-config.json
```

**base-config.json** è la **fonte di verità unica**. Contiene:
- Parametri AI (temperature, creativity, verbosity)
- Tech stack completo
- Coding standards e regole
- Design patterns
- Best practices per ogni tecnologia

### 2. Sincronizza le Configurazioni (AUTOMATICO)
```bash
node sync-configs.js
```

Questo script **genera automaticamente**:
- ✅ `configurations/INSTRUCTIONS.md` (istruzioni copy-paste)
- ✅ `configurations/claude-vscode.json` (config Claude Code)
- ✅ `configurations/github-copilot-vscode.json` (config GitHub Copilot)

### 3. Applica le Configurazioni nei Copilot

#### Claude Code (VS Code)
```bash
# Le istruzioni sono già nel file generato
cat configurations/claude-vscode.json
# Copia nel tuo settings.json di VS Code
```

#### GitHub Copilot (VS Code)
```bash
# Le istruzioni sono già nel file generato
cat configurations/github-copilot-vscode.json
# Copia nel tuo settings.json di VS Code
```

#### Warp Terminal
```bash
# Leggi e applica workflows
cat configurations/warp-config.md
```

---

## 🔄 Workflow di Aggiornamento

```bash
# 1. Modifica SOLO base-config.json
vim configurations/base-config.json

# 2. Rigenera tutto automaticamente
node sync-configs.js

# 3. Commit e push
git add . && git commit -m "Update AI configurations" && git push
```

**Importante**: NON modificare manualmente:
- ❌ `claude-vscode.json`
- ❌ `github-copilot-vscode.json`
- ❌ `INSTRUCTIONS.md`

Questi file sono **auto-generati** da `base-config.json`.

---

## 📖 Regole Fondamentali

### 🎯 Parametri AI
- **Temperature**: 0.3 (precisione su velocità)
- **Modalità**: CODING (non filosofico)
- **Verbosità**: Concisa
- **Creatività**: Bilanciata e pragmatica

### ⚠️ Regole Assolute

1. **MAX 25 righe** per funzione/metodo (NON NEGOZIABILE)
2. **Design Patterns** sempre:
   - Dependency Injection
   - Strategy Pattern  
   - CQRS
   - Business Delegate
   - Repository Pattern
3. **ZERO tolleranza**:
   - God Objects
   - Codice duplicato
   - Magic numbers
   - Nested conditionals >3 livelli
   - Funzioni >4 parametri
4. **Testing obbligatorio**: Coverage ≥80%
5. **Linting attivo**: ESLint, Prettier, Pylint, Black

### 💎 Best Practices per Stack

- **React/RN**: Functional components, hooks, custom hooks, memoization
- **Node.js**: DI, middleware, Zod validation, Pino logging
- **Python**: PEP 8, type hints, Pydantic, dataclasses
- **Supabase**: RLS sempre, stored procedures, indexes
- **Docker**: Multi-stage, non-root, health checks
- **n8n**: Error workflows, credentials, retry logic

---

## 📝 Manutenzione

Per aggiornare le configurazioni:

```bash
cd ~/scripts/configurations
git pull
```

Per contribuire miglioramenti:
1. Modifica i file
2. Testa le configurazioni
3. Commit e push

---

## 🔗 Risorse

- [Claude Code Docs](https://claude.ai/docs)
- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [Warp Docs](https://docs.warp.dev/)
- [VS Code Settings Reference](https://code.visualstudio.com/docs/getstarted/settings)
