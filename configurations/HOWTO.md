# 📝 Come Modificare base-config.json

> Guida pratica per aggiornare le configurazioni AI

## 🎛️ Modifiche Comuni

### 1. Cambiare Temperature (Precisione vs Creatività)

**Posizione**: `ai_parameters.temperature`

```json
{
  "ai_parameters": {
    "temperature": 0.3  // ← Modifica qui
  }
}
```

**Valori consigliati**:
- `0.1-0.3`: Massima precisione (coding, fix bug)
- `0.4-0.6`: Bilanciato (refactoring, design)
- `0.7-0.9`: Creativo (brainstorming, architettura)

---

### 2. Aggiungere una Nuova Tecnologia

**Posizione**: `tech_stack.<categoria>`

```json
{
  "tech_stack": {
    "frontend": [
      "React",
      "Next.js",
      "Svelte"  // ← Aggiungi qui
    ]
  }
}
```

---

### 3. Modificare Limiti di Codice

**Posizione**: `coding_standards.general`

```json
{
  "coding_standards": {
    "general": {
      "max_function_length": 25,  // ← Modifica qui
      "max_method_length": 25     // ← Modifica qui
    }
  }
}
```

---

### 4. Aggiungere un Design Pattern

**Posizione**: `coding_standards.patterns.required`

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

---

### 5. Modificare Threshold Test Coverage

**Posizione**: `quality_requirements.testing.coverage_threshold`

```json
{
  "quality_requirements": {
    "testing": {
      "coverage_threshold": 80  // ← Modifica qui (es: 90)
    }
  }
}
```

---

### 6. Aggiungere Best Practice per Tecnologia

**Posizione**: `best_practices.<tecnologia>`

```json
{
  "best_practices": {
    "react": [
      "Use functional components with hooks",
      "Use Context API for global state"  // ← Aggiungi qui
    ]
  }
}
```

---

### 7. Aggiungere File Pattern da Escludere

**Posizione**: `file_patterns.exclude`

```json
{
  "file_patterns": {
    "exclude": [
      "**/node_modules/**",
      "**/.turbo/**"  // ← Aggiungi qui
    ]
  }
}
```

---

### 8. Modificare Istruzioni Custom Template

**Posizione**: `custom_instructions_template`

```json
{
  "custom_instructions_template": [
    "Sono un full-stack developer specializzato in:",
    "- Frontend: React, Vue, Angular",  // ← Modifica qui
    "- Backend: Node.js, Python, Go"    // ← Aggiungi tecnologie
  ]
}
```

---

## 🔄 Dopo le Modifiche

```bash
# 1. Salva base-config.json
# 2. Rigenera configurazioni
node sync-configs.js

# 3. Verifica i file generati
cat configurations/claude-vscode.json
cat configurations/github-copilot-vscode.json
cat configurations/INSTRUCTIONS.md

# 4. Commit
git add . && git commit -m "Update AI config: <descrizione modifiche>"
```

---

## 📋 Checklist Pre-Commit

Prima di committare modifiche a `base-config.json`:

- [ ] JSON valido (controlla sintassi)
- [ ] Eseguito `node sync-configs.js`
- [ ] Verificato file generati
- [ ] Testato con un copilot
- [ ] Commit message descrittivo

---

## 💡 Tips

1. **Testa incrementalmente**: Modifica un parametro alla volta
2. **Documenta**: Aggiungi commenti nei commit sui cambiamenti
3. **Backup**: Prima di modifiche importanti, crea un branch
4. **Valida JSON**: Usa `jq . configurations/base-config.json` per validare

---

## 🆘 Troubleshooting

**Errore: "Unexpected token"**
```bash
# Valida JSON
jq . configurations/base-config.json
```

**Lo script non genera file**
```bash
# Controlla permessi
ls -la sync-configs.js
chmod +x sync-configs.js
```

**Le modifiche non si applicano**
```bash
# Assicurati di aver rigenerato
node sync-configs.js
# E ricaricato VS Code
```
