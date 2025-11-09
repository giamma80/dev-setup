# 📋 Istruzioni Custom per AI Copilots

> Da copiare manualmente nelle impostazioni di ciascun copilot
> **Auto-generato da base-config.json**

---

## 🎯 Istruzioni Complete

```markdown
Sono un full-stack developer specializzato in:
- Frontend: React, React Native, Next.js, TypeScript, iOS
- Backend: Node.js, Python, FastAPI, NestJS
- Database: Supabase, PostgreSQL
- Infrastructure: Docker, Vercel, Render
- Automation: n8n
- VCS: GitHub, GitLab

REGOLE FONDAMENTALI:
1. Funzioni/metodi max 25 righe
2. Sempre applicare design patterns (DI, Strategy, CQRS, Business Delegate)
3. Evitare antipattern e code smell
4. Massimo riuso del codice
5. Sempre creare unit test (coverage >80%)
6. Sempre applicare linting (ESLint, Pylint, Black)
7. Documentazione in italiano, codice in inglese
8. Sicurezza e performance come priorità

STILE DI CODICE:
- TypeScript preferito per JavaScript
- Async/await invece di promises
- Functional programming quando appropriato
- Composition over inheritance
- Immutabilità e pure functions
- Type hints per Python

OUTPUT RICHIESTO:
- Codice production-ready
- Unit test inclusi
- Documentazione JSDoc/Docstring
- Best practices applicate
- Performance ottimizzate
```

---

## 🔧 Come Applicare

### Claude Code (VS Code)
1. Apri Settings (Cmd+,)
2. Cerca "Claude Custom Instructions"
3. Incolla le istruzioni sopra
4. Imposta temperature: 0.3

### GitHub Copilot (VS Code)
1. Apri Command Palette (Cmd+Shift+P)
2. Cerca "GitHub Copilot: Edit Instructions"
3. Incolla la versione compatta delle istruzioni
4. Salva

### Warp AI
1. Apri Warp
2. Usa `Ctrl+Shift+R` per AI
3. Nelle impostazioni AI, aggiungi context personalizzato

---

## 📊 Parametri AI

- **Temperature**: 0.3
- **Creativity**: balanced
- **Verbosity**: concise
- **Mode**: coding

---

## 🛠️ Tech Stack

### Frontend
- React
- React Native
- Next.js
- TypeScript
- Expo
- React Navigation
- React Query/TanStack Query
- Zustand/Redux Toolkit

### Backend
- Node.js
- Express
- Fastify
- Python
- FastAPI
- Flask
- NestJS

### Mobile
- React Native
- Expo
- iOS Native (Swift)
- React Native Paper
- Reanimated

### Database
- Supabase
- PostgreSQL
- MongoDB
- Redis

### Infrastructure
- Docker
- Docker Compose
- Vercel
- Render
- GitHub Actions
- GitLab CI/CD

---

## 📏 Coding Standards

### General
- Max function length: 25 lines
- Max method length: 25 lines
- Prefer code reuse: true
- Single responsibility: true

### Required Patterns
- Dependency Injection
- Strategy Pattern
- Factory Pattern
- Repository Pattern
- CQRS (Command Query Responsibility Segregation)
- Business Delegate Pattern

### Antipatterns to Avoid
- God Objects
- Long Methods (>25 lines)
- Long Parameter Lists (>4 params)
- Duplicate Code
- Magic Numbers
- Nested Conditionals (>3 levels)
- Tight Coupling
- Global State
- Callback Hell

---

**Ultima sincronizzazione**: 2025-11-09T20:43:50.942Z
