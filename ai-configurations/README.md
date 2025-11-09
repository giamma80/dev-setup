# 🤖 AI Copilot Configurations

> Sistema centralizzato di configurazioni AI per sviluppo full-stack professionale

[![Tech Stack](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=black)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)](https://nodejs.org/)

---

## 📑 Indice

1. [Quick Start](#-quick-start)
2. [Struttura File](#-struttura-file)
3. [Setup AI Copilots](#-setup-ai-copilots)
4. [Come Modificare Configurazioni](#-come-modificare-configurazioni)
5. [Regole e Best Practices](#-regole-e-best-practices)
6. [Tech Stack](#-tech-stack)
7. [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Start

### 1. Modifica la Configurazione Base
```bash
cd ~/scripts/ai-configurations
vim base-config.json  # ← UNICO FILE DA MODIFICARE
```

### 2. Rigenera Tutto Automaticamente
```bash
cd ~/scripts
node sync-configs.js
```

### 3. Applica nei Copilot
Segui le istruzioni in [Setup AI Copilots](#-setup-ai-copilots)

---

## 📁 Struttura File

### 📄 File Principali

| File | Descrizione | Modificabile |
|------|-------------|--------------|
| **`base-config.json`** ⭐ | Single source of truth - configurazione centralizzata | ✅ SÌ |
| `claude-vscode.json` | Config Claude per VS Code | ❌ Auto-generato |
| `claude-cli-config.json` | Config Claude CLI (terminale) | ❌ Auto-generato |
| `github-copilot-vscode.json` | Config GitHub Copilot per VS Code | ❌ Auto-generato |
| `INSTRUCTIONS.md` | Istruzioni copy-paste per AI | ❌ Auto-generato |
| `warp-config.md` | Workflows Warp Terminal | ✅ Manuale |

### 🎯 base-config.json - Cosa Contiene

```json
{
  "ai_parameters": {
    "temperature": 0.3,           // Precisione vs creatività
    "creativity_level": "balanced",
    "verbosity": "concise",
    "optimization_mode": "coding"
  },
  
  "tech_stack": {
    "frontend": { /* React, Next.js, UI libs */ },
    "backend": { /* Node, Python, constraints */ },
    "mobile": { /* React Native, UI libs */ },
    "python_advanced": { /* ML, async, ORM */ }
  },
  
  "coding_standards": {
    "max_function_length": 25,    // Linee massime per funzione
    "patterns": { /* DI, Strategy, CQRS */ }
  },
  
  "golden_rules": [ /* KISS, YAGNI, Measure First */ ],
  "warnings": [ /* Security, Performance, Accessibility */ ],
  "compatibility": { /* Node 18+, Python 3.10+ */ }
}
```

---

## �️ Setup AI Copilots

### 1️⃣ Claude Code (VS Code Extension)

1. **Installa estensione**: `Claude Dev` in VS Code
2. **Copia configurazione**:
   ```bash
   # Apri il file generato
   cat ai-configurations/claude-vscode.json
   ```
3. **Applica in VS Code**:
   - `Cmd+,` → Settings
   - Cerca "Claude"
   - Incolla le custom instructions
   - Imposta temperature: `0.3`

### 2️⃣ Claude Code (CLI Terminal)

1. **Installa Claude CLI**:
   ```bash
   # Installazione (se disponibile)
   npm install -g @anthropic-ai/claude-cli
   # oppure
   brew install claude-cli
   ```

2. **Setup configurazione**:
   ```bash
   # Crea directory config
   mkdir -p ~/.config/claude
   
   # Copia config generata
   cp ~/scripts/ai-ai-configurations/claude-cli-config.json ~/.config/claude/config.json
   ```

3. **Setup API Key**:
   ```bash
   # Metodo 1: Environment variable
   export ANTHROPIC_API_KEY="your-api-key"
   
   # Metodo 2: Config file
   echo '{"api_key": "your-api-key"}' > ~/.config/claude/credentials.json
   ```

4. **Test**:
   ```bash
   claude chat
   claude ask "Come ottimizzare questa query?"
   ```

### 3️⃣ GitHub Copilot (VS Code)

1. **Apri file generato**:
   ```bash
   cat ai-configurations/github-copilot-vscode.json
   ```
2. **Applica in VS Code**:
   - `Cmd+,` → Settings
   - Cerca "GitHub Copilot"
   - Copia le impostazioni nel tuo `settings.json`

### 4️⃣ Warp Terminal

1. **Leggi workflows**:
   ```bash
   cat ai-configurations/warp-config.md
   ```
2. **Applica workflows** manualmente (non auto-generato)

---

## � Come Modificare Configurazioni

### Modifiche Comuni

#### 1. Cambiare Temperature (Precisione vs Creatività)
```json
{
  "ai_parameters": {
    "temperature": 0.3  // ← 0.1-0.3: preciso | 0.4-0.6: bilanciato | 0.7-0.9: creativo
  }
}
```

#### 2. Aggiungere Libreria con Meta-campi
```json
{
  "tech_stack": {
    "frontend": {
      "ui_libraries": {
        "design_systems": [
          {
            "name": "Chakra UI",
            "priority": "prefer",              // must | prefer | avoid
            "rationale": "API semplice, a11y", // Perché consigliata
            "constraints": "React 18+"         // Requisiti versione
          }
        ]
      }
    }
  }
}
```

#### 3. Modificare Limiti Codice
```json
{
  "coding_standards": {
    "general": {
      "max_function_length": 25,  // ← Modifica qui (default: 25)
      "max_method_length": 25
    }
  }
}
```

#### 4. Aggiungere Design Pattern
```json
{
  "coding_standards": {
    "patterns": {
      "required": [
        "Dependency Injection",
        "Observer Pattern"  // ← Aggiungi qui
      ]
    }
  }
}
```

#### 5. Aggiungere Golden Rule
```json
{
  "golden_rules": [
    {
      "rule": "Test First",
      "rationale": "TDD previene bug",
      "priority": "prefer",
      "example": "Scrivi test prima dell'implementazione"
    }
  ]
}
```

#### 6. Aggiungere Warning
```json
{
  "warnings": [
    {
      "category": "performance",
      "warning": "Evita N+1 queries",
      "rationale": "Performance degradation",
      "mitigation": "Usa JOIN o eager loading"
    }
  ]
}
```

### Workflow Completo
```bash
# 1. Modifica base-config.json
vim ai-configurations/base-config.json

# 2. Rigenera configurazioni
node sync-configs.js

# 3. Verifica output
cat ai-configurations/claude-vscode.json
cat ai-configurations/INSTRUCTIONS.md

# 4. Commit
git add . && git commit -m "feat: add new library XYZ to tech stack"
git push
```

### ⚠️ Checklist Pre-Commit
- [ ] JSON valido: `jq . ai-configurations/base-config.json`
- [ ] Rigenerato: `node sync-configs.js`
- [ ] File generati verificati
- [ ] Commit message descrittivo

---

## 📖 Regole e Best Practices

### 🎯 Parametri AI
- **Temperature**: `0.3` (precisione > creatività)
- **Mode**: `CODING` (pragmatico, non filosofico)
- **Verbosity**: `CONCISE` (risposte brevi e mirate)
- **Language**: Codice in inglese, spiegazioni in italiano

### ⚠️ Regole Assolute (NON NEGOZIABILI)

1. **MAX 25 righe** per funzione/metodo
2. **Design Patterns obbligatori**:
   - Dependency Injection (sempre)
   - Strategy Pattern (algoritmi variabili)
   - CQRS (separazione comando/query)
   - Business Delegate (separazione logica)
   - Repository Pattern (astrazione dati)
3. **ZERO tolleranza**:
   - God Objects
   - Codice duplicato
   - Magic numbers
   - Nested conditionals >3 livelli
   - Funzioni >4 parametri
   - Callback hell
4. **Testing obbligatorio**: Coverage ≥80%
5. **Linting sempre attivo**: Fail su errori, warning ok

### 🎯 Golden Rules

| Rule | Priority | Rationale |
|------|----------|-----------|
| **KISS** | must | Keep It Simple - no complessità inutile |
| **YAGNI** | must | You Aren't Gonna Need It - no feature speculative |
| **Measure Before Optimize** | must | Profila prima di ottimizzare |
| **Fail Fast, Recover Gracefully** | must | Errori evidenti in dev, rollback in prod |
| **Single Source of Truth** | must | Config centralizzata, no duplicazione |
| **API First** | prefer | Contratti prima dell'implementazione |
| **Automate Quality Gates** | must | Lint/test devono bloccare merge |
| **Small PRs** | prefer | Max 400 righe, atomic commits |
| **Security by Design** | must | Threat modeling, input validation |
| **Observability by Default** | must | Metrics, traces, logs, runbooks |

### 💎 Best Practices per Tecnologia

<details>
<summary><strong>React / React Native</strong></summary>

- Solo functional components + hooks
- useMemo/useCallback per performance
- Custom hooks per logica riusabile
- Error boundaries sempre
- TypeScript strict mode
- FlatList per liste lunghe (RN)
- Reanimated per animazioni (RN)
</details>

<details>
<summary><strong>Node.js / Express / Fastify</strong></summary>

- Dependency injection (tsyringe, InversifyJS)
- Middleware per error handling
- Validation (Zod, Joi) sempre
- Logging strutturato (Pino, Winston)
- Rate limiting su API
- Health checks endpoint
</details>

<details>
<summary><strong>Python / FastAPI / Flask</strong></summary>

- PEP 8 strict
- Type hints completi
- Pydantic per validazione
- Context managers per risorse
- Dataclasses per strutture dati
- FastAPI preferred su Flask
</details>

<details>
<summary><strong>Supabase / PostgreSQL</strong></summary>

- Row Level Security (RLS) sempre
- Stored procedures per logica complessa
- Indexes ottimizzati
- Edge Functions per serverless
- Connection pooling
</details>

<details>
<summary><strong>Docker</strong></summary>

- Multi-stage builds
- Non-root user
- .dockerignore completo
- Health checks
- Layer optimization
- Specific image tags (no :latest)
</details>

### ⚠️ Warnings - Cose da NON Fare

| Categoria | Warning | Mitigation |
|-----------|---------|------------|
| **Security** | Mai `curl \| sh` | Verifica checksum/signature |
| **Dependencies** | Pinna con lockfile | Commit package-lock.json, poetry.lock |
| **Secrets** | MAI commit .env | Usa secret manager (Vault, GitHub Secrets) |
| **Database** | RLS & least-privilege | Test privilege escalation |
| **API** | Rate limiting sempre | express-rate-limit, FastAPI Slowapi |
| **Performance** | Bundle size budgets | Lighthouse CI, webpack-bundle-analyzer |
| **Accessibility** | WCAG compliance | axe-core, eslint-plugin-jsx-a11y |
| **Privacy** | No PII in logs | Anonimizza dati sensibili |

---

## �️ Tech Stack

### Frontend
- **Core**: React 18+, Next.js, TypeScript 5+
- **Design Systems**: Chakra UI [prefer], Mantine [prefer], Ant Design [must]
- **Headless**: Radix UI [must], Headless UI [prefer]
- **Styling**: Tailwind CSS [must], Emotion [prefer]
- **Forms**: React Hook Form [must], Zod [must], ~~Formik [avoid]~~
- **Charts**: Recharts [prefer], Visx [must]
- **Animation**: Framer Motion [must]

### Mobile
- **Core**: React Native 0.70+, Expo
- **UI**: React Native Paper [must], NativeBase [prefer]
- **Gestures**: react-native-gesture-handler [must], Reanimated [must]
- **Performance**: react-native-fast-image [must], MMKV [prefer]

### Backend
- **Node.js**: 18.0.0+ (rec: 22.x LTS)
- **Python**: 3.10+ (rec: 3.12)
- **Frameworks**: Express, Fastify, FastAPI, NestJS
- **Python Advanced**: SQLModel, HTTPX, Strawberry GraphQL

### Database & Infrastructure
- **Database**: Supabase, PostgreSQL, MongoDB, Redis
- **Infra**: Docker, Vercel, Render
- **DevOps**: GitHub Actions, GitLab CI/CD
- **Automation**: n8n workflows

### ML / AI / Data
- **ML**: PyTorch, Transformers (Hugging Face)
- **LLM**: LangChain, sentence-transformers
- **Data**: Polars [prefer], Dask [prefer]
- **Orchestration**: Prefect [prefer], Dagster [prefer]

### Observability
- **Logging**: structlog [must], Pino
- **Monitoring**: OpenTelemetry [must], Sentry [must]
- **Testing**: pytest [must], Jest, Vitest

---

## 🐛 Troubleshooting

### Errore: `sync-configs.js` fallisce

```bash
# Valida JSON
jq . ai-configurations/base-config.json

# Se errore di sintassi, correggi base-config.json
# Poi rigenera
node sync-configs.js
```

### Le modifiche non si applicano in VS Code

```bash
# Rigenera
node sync-configs.js

# Ricarica VS Code
# Cmd+Shift+P → "Developer: Reload Window"
```

### Claude CLI non trova config

```bash
# Verifica path
ls -la ~/.config/claude/config.json

# Se non esiste, copia
mkdir -p ~/.config/claude
cp ai-configurations/claude-cli-config.json ~/.config/claude/config.json
```

### API Key Claude non valida

```bash
# Test connessione
claude test-connection

# Verifica env var
echo $ANTHROPIC_API_KEY

# O aggiungi in credentials.json
echo '{"api_key": "sk-ant-..."}' > ~/.config/claude/credentials.json
```

---

## 🔗 Risorse

- 📚 [Claude Sonnet 4.5 Best Practices](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- 🤖 [GitHub Copilot Docs](https://docs.github.com/copilot)
- ⚡ [Warp Terminal Docs](https://docs.warp.dev/)
- 🔧 [VS Code Settings Reference](https://code.visualstudio.com/docs/getstarted/settings)

---

## 📊 Change Log

- **v1.2.0** (2025-11-09): Meta-campi (priority/rationale/constraints), golden rules, warnings
- **v1.1.0** (2025-11-09): Claude Sonnet 4.5 upgrade con best practices ufficiali
- **v1.0.0** (2025-11-08): Configurazione centralizzata con sync-configs.js

---

**Auto-generato da `base-config.json` | Ultima sync: `node sync-configs.js`**
