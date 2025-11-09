# AI Copilot Configurations

Configurazioni ottimizzate per sviluppo full-stack con:
- **Frontend**: React, Next.js, TypeScript
- **Backend**: Node.js, Python, Docker
- **Cloud**: AWS, Vercel, Render
- **Tools**: Git, GitHub Actions, npm/pip

---

## 📁 File di Configurazione

### 1. **claude-vscode.json**
Configurazione per Claude Code in VS Code
- Modello: Claude Sonnet 4
- Contesto: Include file aperti, recenti e modifiche Git
- Istruzioni personalizzate per full-stack development
- File patterns per escludere node_modules, venv, ecc.

### 2. **github-copilot-vscode.json**
Settings ottimizzati per GitHub Copilot in VS Code
- Auto-completions abilitate
- Chat in italiano
- Suggerimenti per TypeScript, async/await, testing
- Editor settings (font, ligatures, formatting)
- Theme: GitHub Dark Default

### 3. **warp-config.md**
Guida completa per Warp Terminal
- 40+ workflows predefiniti
- Comandi Git, Docker, Node, Python, AWS, Vercel
- Alias shell consigliati
- Warp AI prompts utili
- Configurazione tema e font

---

## 🚀 Come Usare

### Claude Code (VS Code)
1. Installa l'estensione Claude Code
2. Apri `Settings` (Cmd+,)
3. Cerca "Claude"
4. Copia le impostazioni da `claude-vscode.json`

### GitHub Copilot (VS Code)
1. Apri `settings.json` (Cmd+Shift+P → "Preferences: Open User Settings (JSON)")
2. Copia le impostazioni da `github-copilot-vscode.json`
3. Riavvia VS Code

### Warp Terminal
1. Leggi `warp-config.md`
2. Crea workflows manualmente in Warp
3. Aggiungi alias a `~/.zshrc`

---

## 🎯 Istruzioni Comuni

Entrambi i copilot sono configurati con:

### Stack Tecnologico
- React, Next.js, TypeScript
- Node.js, Express, Python, FastAPI
- Docker, Docker Compose
- AWS, Vercel, Render
- PostgreSQL, MongoDB

### Preferenze Coding
- TypeScript quando possibile
- Async/await invece di promises
- Functional programming approach
- Test coverage (Jest/Pytest)
- Commenti in italiano, codice in inglese
- ESLint/Prettier/Black formatting

### Best Practices
- Security-first approach
- Performance optimization
- Error handling
- Logging e monitoring
- Clean code principles

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
