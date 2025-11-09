# 🛠️ Development Environment Setup

> Automated setup scripts for Mac development environment

---

## 📋 Script Disponibili

### `mac-dev-setup.sh`

Script automatizzato per configurare un ambiente di sviluppo completo su macOS.

**Versione**: 1.1.3  
**Ultima modifica**: 2025-11-09

#### 🎯 Cosa Installa

**Package Managers & Core Tools**:
- Homebrew (package manager)
- Oh My Zsh (shell framework)

**Programming Languages & Runtimes**:
- Node.js (via nvm) - LTS version
- Python (via pyenv) - 3.11.x
- Go (latest)

**Version Managers**:
- nvm (Node Version Manager)
- pyenv (Python Version Manager)

**Containerization**:
- Docker (via Colima - lightweight alternative to Docker Desktop)
- Docker Compose

**Development Tools**:
- Git (version control)
- jq (JSON processor)
- htop (system monitoring)
- wget, curl (download utilities)

**Optional Tools** (commented out):
- AWS CLI
- Google Cloud SDK
- Azure CLI
- Terraform

---

## 🚀 Utilizzo

### Quick Start

```bash
cd ~/scripts/dev-configurations

# Dry-run (mostra cosa verrà fatto senza installare)
./mac-dev-setup.sh --dry-run

# Installazione completa
./mac-dev-setup.sh
```

### Opzioni

```bash
./mac-dev-setup.sh [OPZIONI]

Opzioni:
  --dry-run         Modalità simulazione (nessuna installazione)
  -h, --help        Mostra questo messaggio di aiuto
```

---

## 📝 Log e Report

Lo script genera automaticamente:

### 1. **setup_YYYYMMDD_HHMMSS.log**
Log completo dell'esecuzione con timestamp

```
📍 Posizione: ~/scripts/dev-configurations/
📄 Formato: setup_20251109_220000.log
```

### 2. **setup-report.json**
Report strutturato in JSON con:
- Timestamp inizio/fine
- Durata totale
- Sistema operativo e versione
- Lista tool installati con successo/fallimento
- Eventuali errori

```json
{
  "timestamp": "2025-11-09T22:00:00+01:00",
  "duration": "320",
  "os": "macOS 14.0",
  "tools_installed": ["homebrew", "nvm", "node", "python", "docker"],
  "failed": [],
  "errors": []
}
```

---

## 🔧 Personalizzazione

### Modificare Versioni

```bash
# Apri lo script
vim mac-dev-setup.sh

# Modifica le variabili all'inizio del file:
NODE_VERSION="--lts"          # Cambia versione Node
PYTHON_VERSION="3.11"         # Cambia versione Python
GO_VERSION="1.21"             # Cambia versione Go
```

### Abilitare Tool Opzionali

Rimuovi il commento `#` davanti ai tool che vuoi installare:

```bash
# Esempio: abilitare AWS CLI
# Trova nel file:
# install_aws_cli

# Rimuovi il #:
install_aws_cli
```

### Aggiungere Nuovi Tool

Aggiungi una nuova funzione nel formato:

```bash
install_my_tool() {
    echo "📦 Installando My Tool..."
    if command_exists mytool; then
        echo "✅ My Tool già installato"
        return 0
    fi
    
    brew install mytool || {
        echo "❌ Errore installazione My Tool"
        return 1
    }
    
    echo "✅ My Tool installato con successo"
}
```

Poi chiamala nella sezione `main()`.

---

## 🐛 Troubleshooting

### Problema: Homebrew non trovato dopo installazione

```bash
# Aggiungi manualmente al PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Problema: nvm command not found

```bash
# Carica nvm manualmente
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Aggiungi al .zshrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
```

### Problema: pyenv non imposta versione Python

```bash
# Verifica installazione
pyenv versions

# Imposta versione globale manualmente
pyenv global 3.11.x

# Aggiungi al PATH se necessario
echo 'export PATH="$HOME/.pyenv/shims:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Problema: Docker/Colima non parte

```bash
# Verifica status
colima status

# Riavvia Colima
colima stop
colima start

# Se persiste, reinstalla
brew uninstall colima docker docker-compose
# Poi riesegui lo script
```

### Problema: Script fallisce a metà

```bash
# Controlla il log
cat setup_*.log | tail -50

# Riprova dalla funzione fallita
# Commenta le funzioni già completate con successo
vim mac-dev-setup.sh
```

---

## 📊 Requisiti Sistema

- **OS**: macOS 10.15 (Catalina) o successivo
- **Architettura**: Intel (x86_64) o Apple Silicon (arm64)
- **Spazio Disco**: ~5 GB liberi
- **RAM**: 8 GB minimo (16 GB consigliato)
- **Connessione**: Internet attiva per download

---

## 🔐 Sicurezza

Lo script:
- ✅ Non richiede `sudo` permanente (chiede solo quando necessario)
- ✅ Verifica integrità Homebrew tramite firma ufficiale
- ✅ Usa repository ufficiali per tutti i tool
- ✅ Non scarica da fonti non verificate
- ✅ Genera log completi per audit
- ❌ Non richiede mai password o API key

**Verifica lo script prima di eseguirlo**:
```bash
cat mac-dev-setup.sh | less
```

---

## 🔄 Aggiornamenti

Per aggiornare gli script:

```bash
cd ~/scripts
git pull origin main
```

---

## 🤝 Contribuire

1. Testa le modifiche in `--dry-run`
2. Verifica che il log sia pulito
3. Commit con conventional commits:
   ```bash
   git commit -m "feat: add terraform installation"
   git commit -m "fix: pyenv loading before use"
   ```

---

## 📚 Risorse

- [Homebrew Documentation](https://docs.brew.sh/)
- [nvm GitHub](https://github.com/nvm-sh/nvm)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Colima GitHub](https://github.com/abiosoft/colima)

---

**Maintainer**: [@giamma80](https://github.com/giamma80)  
**Repository**: [dev-setup](https://github.com/giamma80/dev-setup)
