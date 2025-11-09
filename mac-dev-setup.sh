#!/bin/bash

# Mac Development Environment Setup Script
# Versione: 1.1.2
# Requisiti: macOS 12+, Xcode CLI Tools, 10GB spazio
# Testato: macOS 12-15 (Intel & Apple Silicon)
# Repository: https://github.com/yourusername/mac-dev-setup

set -euo pipefail

# Versione e configurazione
SCRIPT_VERSION="1.1.4"
PYTHON_VERSION="3.12.7"
NODE_VERSION="--lts"
MIN_MACOS_MAJOR=12
MIN_SPACE_GB=10

# Costanti
LOCKFILE="/tmp/mac-dev-setup.${USER}.lock"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE="/tmp/mac-dev-setup-${BACKUP_TIMESTAMP}.log"
REPORT_FILE="/tmp/mac-dev-setup-${BACKUP_TIMESTAMP}.json"

# Array per gestione risorse (con dummy per set -u)
TEMP_FILES=("")
TEMP_DIRS=("")
FAILED_COMPONENTS=("")

# Flag modalità
DRY_RUN=false
VERBOSE=false
NON_INTERACTIVE=false
PLAIN_OUTPUT=false
CI_MODE=false

# Parse argomenti
for arg in "$@"; do
    case $arg in
        --dry-run) DRY_RUN=true ;;
        --verbose) VERBOSE=true ;;
        --yes|-y) NON_INTERACTIVE=true ;;
        --plain) PLAIN_OUTPUT=true ;;
        --ci) CI_MODE=true; NON_INTERACTIVE=true; PLAIN_OUTPUT=true ;;
        --help|-h)
            cat << 'EOF'
Mac Development Environment Setup Script

USAGE:
    ./mac-dev-setup.sh [OPTIONS]

OPTIONS:
    --dry-run       Mostra operazioni senza eseguirle
    --verbose       Log dettagliato + file log
    --yes, -y       Modalità non interattiva
    --plain         Output senza colori/emoji
    --ci            Modalità CI (--yes --plain + conserva log)
    --help, -h      Mostra questo help

REQUISITI:
    - macOS 12+ (Monterey o successivo)
    - Xcode Command Line Tools: xcode-select --install
    - Connessione internet stabile
    - 10GB spazio libero minimo

COMPONENTI:
    - Homebrew (package manager)
    - Python 3.12.7 (via pyenv)
    - Node.js LTS (via nvm)
    - Docker (via Colima)
    - React Native tools (watchman, cocoapods)
    - Dev tools (git, wget, jq, tree)

ESEMPI:
    ./mac-dev-setup.sh                    # Interattivo
    ./mac-dev-setup.sh --dry-run          # Test
    ./mac-dev-setup.sh --verbose          # Debug
    ./mac-dev-setup.sh --ci               # CI/CD

EXIT CODES:
    0 - Successo completo
    1 - Errore critico
    2 - Successo parziale (alcuni componenti falliti)

STEP MANUALI:
    1. Xcode: xcode-select --install (prima di eseguire)
    2. Android Studio SDK: completa setup dopo installazione

SICUREZZA:
    - Script remoti (Homebrew, uv) richiedono conferma
    - Per CI: usa checksum verification se richiesto

Report JSON: /tmp/mac-dev-setup-*.json
Log file: /tmp/mac-dev-setup-*.log
EOF
            exit 0
            ;;
    esac
done

# Setup logging
if [[ "$VERBOSE" == true ]]; then
    exec > >(tee -a "$LOGFILE") 2>&1
fi

# Colori
if [[ "$PLAIN_OUTPUT" == true ]]; then
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
else
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
    BLUE='\033[0;34m' NC='\033[0m'
fi

# Logging functions
log_info() {
    [[ "$PLAIN_OUTPUT" == true ]] && printf "[INFO] %s\n" "$1" || printf "${BLUE}ℹ️  %s${NC}\n" "$1"
}

log_success() {
    [[ "$PLAIN_OUTPUT" == true ]] && printf "[SUCCESS] %s\n" "$1" || printf "${GREEN}✅ %s${NC}\n" "$1"
}

log_warning() {
    [[ "$PLAIN_OUTPUT" == true ]] && printf "[WARNING] %s\n" "$1" || printf "${YELLOW}⚠️  %s${NC}\n" "$1"
}

log_error() {
    [[ "$PLAIN_OUTPUT" == true ]] && printf "[ERROR] %s\n" "$1" >&2 || printf "${RED}❌ %s${NC}\n" "$1" >&2
}

log_verbose() {
    [[ "$VERBOSE" == true ]] && printf "  → %s\n" "$1"
}

# JSON escape completo
json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\t'/\\t}"
    str="${str//$'\r'/\\r}"
    printf "%s" "$str"
}

# Cleanup con preservazione exit code
cleanup() {
    local original_exit=$?
    
    # Temp files (skip empty string)
    for f in "${TEMP_FILES[@]}"; do
        [[ -n "$f" && -f "$f" ]] && rm -f "$f" 2>/dev/null || true
    done
    
    # Temp dirs (skip empty string)
    for d in "${TEMP_DIRS[@]}"; do
        [[ -n "$d" && -d "$d" ]] && rm -rf "$d" 2>/dev/null || true
    done
    
    # Lock: rimuovi solo se appartiene a questo processo
    if [[ -d "$LOCKFILE" && -f "${LOCKFILE}/pid" ]]; then
        local lock_pid
        lock_pid=$(cat "${LOCKFILE}/pid" 2>/dev/null || echo "")
        if [[ "$lock_pid" == "$$" ]]; then
            rm -rf "$LOCKFILE" 2>/dev/null || log_verbose "Impossibile rimuovere lock"
        fi
    fi
    
    # Report JSON
    if [[ "$VERBOSE" == true || "$CI_MODE" == true ]]; then
        generate_report "$original_exit"
    fi
    
    # Pulizia log (conserva in CI o su errore)
    if [[ $original_exit -eq 0 && "$VERBOSE" == false && "$CI_MODE" == false && -f "$LOGFILE" ]]; then
        rm -f "$LOGFILE" 2>/dev/null || true
    fi
    
    exit $original_exit
}

# Trap con preservazione exit code originale
trap cleanup EXIT
trap 'rc=$?; log_error "Errore linea $LINENO"; exit $rc' ERR

# Lock portabile con check PID e comando (anti-recycling)
acquire_lock() {
    local max_wait=30
    local waited=0
    
    while [[ $waited -lt $max_wait ]]; do
        # Tentativo atomico
        if mkdir "$LOCKFILE" 2>/dev/null; then
            echo $$ > "${LOCKFILE}/pid"
            # Salva anche il comando per verifiche future
            ps -p $$ -o command= 2>/dev/null > "${LOCKFILE}/command" || echo "bash" > "${LOCKFILE}/command"
            log_verbose "Lock acquisito (PID $$)"
            return 0
        fi
        
        # Check lock stale
        if [[ -f "${LOCKFILE}/pid" ]]; then
            local lock_pid
            lock_pid=$(cat "${LOCKFILE}/pid" 2>/dev/null || echo "")
            
            if [[ -n "$lock_pid" ]]; then
                # Verifica se processo è vivo
                if ! kill -0 "$lock_pid" 2>/dev/null; then
                    log_warning "Lock stale (PID $lock_pid morto), rimuovo"
                    rm -rf "$LOCKFILE" 2>/dev/null || true
                    continue
                else
                    # Processo vivo ma potrebbe essere PID riciclato
                    # Verifica comando se possibile
                    if [[ -f "${LOCKFILE}/command" ]]; then
                        local lock_cmd
                        lock_cmd=$(cat "${LOCKFILE}/command" 2>/dev/null || echo "")
                        local current_cmd
                        current_cmd=$(ps -p "$lock_pid" -o command= 2>/dev/null || echo "")
                        
                        if [[ -n "$lock_cmd" && -n "$current_cmd" && "$current_cmd" != *"$SCRIPT_VERSION"* ]]; then
                            log_warning "Lock con PID riciclato rilevato, rimuovo"
                            rm -rf "$LOCKFILE" 2>/dev/null || true
                            continue
                        fi
                    fi
                    log_verbose "Processo $lock_pid attivo, attendo..."
                fi
            fi
        fi
        
        sleep 1
        waited=$((waited + 1))
    done
    
    log_error "Lock timeout (${max_wait}s)"
    log_error "Se il lock è stale, rimuovi: rm -rf $LOCKFILE"
    return 1
}

# Timeout portabile con process group termination
portable_timeout() {
    local timeout_seconds=$1
    shift
    
    # Prova gtimeout (coreutils)
    if command -v gtimeout &>/dev/null; then
        gtimeout "$timeout_seconds" "$@"
        return $?
    fi
    
    # Fallback bash con process group
    # NOTA: Usa setsid se disponibile per creare process group
    if command -v setsid &>/dev/null; then
        (
            setsid "$@" &
            local cmd_pid=$!
            local count=0
            
            while kill -0 "$cmd_pid" 2>/dev/null && [[ $count -lt $timeout_seconds ]]; do
                sleep 1
                count=$((count + 1))
            done
            
            if kill -0 "$cmd_pid" 2>/dev/null; then
                log_verbose "Timeout, termino process group"
                # Termina process group (negativo = group)
                kill -TERM -"$cmd_pid" 2>/dev/null || kill -TERM "$cmd_pid" 2>/dev/null || true
                sleep 2
                kill -9 -"$cmd_pid" 2>/dev/null || kill -9 "$cmd_pid" 2>/dev/null || true
                return 124
            fi
            
            wait "$cmd_pid"
            return $?
        )
    else
        # Fallback senza setsid (meno robusto)
        (
            "$@" &
            local cmd_pid=$!
            local count=0
            
            while kill -0 "$cmd_pid" 2>/dev/null && [[ $count -lt $timeout_seconds ]]; do
                sleep 1
                count=$((count + 1))
            done
            
            if kill -0 "$cmd_pid" 2>/dev/null; then
                log_verbose "Timeout, termino PID $cmd_pid (warning: figli potrebbero sopravvivere)"
                kill -TERM "$cmd_pid" 2>/dev/null || true
                sleep 2
                kill -9 "$cmd_pid" 2>/dev/null || true
                return 124
            fi
            
            wait "$cmd_pid"
            return $?
        )
    fi
}

# Esecuzione condizionale
# NOTA: Non supporta redirezioni/pipes complesse inline
execute() {
    if [[ "$DRY_RUN" == true ]]; then
        printf "[DRY-RUN] %s\n" "$*"
        return 0
    fi
    "$@"
}

# Gestione fallimenti
mark_failed() {
    FAILED_COMPONENTS+=("$1")
    log_warning "$1 fallito"
}

# Verifica comando
require_command() {
    local cmd="$1"
    local msg="${2:-}"
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Comando richiesto: $cmd"
        [[ -n "$msg" ]] && log_info "$msg"
        return 1
    fi
}

# Report JSON con atomic write
generate_report() {
    local exit_code="${1:-0}"
    local status="success"
    [[ $exit_code -ne 0 ]] && status="error"
    [[ ${#FAILED_COMPONENTS[@]} -gt 0 && $exit_code -eq 0 ]] && status="partial"
    
    # Raccogli versioni
    local python_ver="N/A" pyenv_ver="N/A" node_ver="N/A" npm_ver="N/A"
    local nvm_current="N/A" docker_ver="N/A" git_ver="N/A" brew_ver="N/A"
    
    # Usa python3 o pyenv shims
    if command -v python3 &>/dev/null; then
        python_ver=$(python3 --version 2>&1 | awk '{print $2}')
    elif [[ -x "${PYENV_ROOT:-}/shims/python" ]]; then
        python_ver=$("${PYENV_ROOT}/shims/python" --version 2>&1 | awk '{print $2}')
    fi
    
    command -v pyenv &>/dev/null && pyenv_ver=$(pyenv version-name 2>&1 || echo "N/A")
    command -v node &>/dev/null && node_ver=$(node --version 2>&1 | sed 's/^v//')
    command -v npm &>/dev/null && npm_ver=$(npm --version 2>&1)
    command -v docker &>/dev/null && docker_ver=$(docker --version 2>&1 | sed -E 's/Docker version ([^,]+).*/\1/')
    command -v git &>/dev/null && git_ver=$(git --version 2>&1 | awk '{print $3}')
    command -v brew &>/dev/null && brew_ver=$(brew --version 2>&1 | head -1 | awk '{print $2}')
    
    # NVM current
    export NVM_DIR="${HOME}/.nvm"
    if [[ -s "${NVM_DIR}/nvm.sh" ]]; then
        . "${NVM_DIR}/nvm.sh"
        nvm_current=$(nvm current 2>&1 | sed 's/^v//' || echo "N/A")
    fi
    
    # Failed components array (skip empty string)
    local failed_json=""
    if [[ ${#FAILED_COMPONENTS[@]} -gt 1 || ( ${#FAILED_COMPONENTS[@]} -eq 1 && -n "${FAILED_COMPONENTS[0]}" ) ]]; then
        for comp in "${FAILED_COMPONENTS[@]}"; do
            [[ -n "$comp" ]] || continue
            comp_escaped=$(json_escape "$comp")
            failed_json="${failed_json}\"${comp_escaped}\","
        done
        failed_json="${failed_json%,}"
    fi
    
    # Atomic write su temp
    local temp_report
    temp_report=$(mktemp)
    TEMP_FILES+=("$temp_report")
    
    {
        printf '{\n'
        printf '  "version": "%s",\n' "$SCRIPT_VERSION"
        printf '  "timestamp": "%s",\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        printf '  "status": "%s",\n' "$status"
        printf '  "exit_code": %d,\n' "$exit_code"
        printf '  "system": {\n'
        printf '    "macos": "%s",\n' "$(sw_vers -productVersion)"
        printf '    "arch": "%s",\n' "$(uname -m)"
        printf '    "user": "%s"\n' "$USER"
        printf '  },\n'
        printf '  "failed_components": [%s],\n' "$failed_json"
        printf '  "installed": {\n'
        printf '    "homebrew": "%s",\n' "$brew_ver"
        printf '    "python": "%s",\n' "$python_ver"
        printf '    "pyenv": "%s",\n' "$pyenv_ver"
        printf '    "node": "%s",\n' "$node_ver"
        printf '    "npm": "%s",\n' "$npm_ver"
        printf '    "nvm": "%s",\n' "$nvm_current"
        printf '    "docker": "%s",\n' "$docker_ver"
        printf '    "git": "%s"\n' "$git_ver"
        printf '  },\n'
        printf '  "logs": {\n'
        printf '    "logfile": "%s",\n' "$LOGFILE"
        printf '    "pyenv_log": "/tmp/pyenv-%s.log"\n' "$BACKUP_TIMESTAMP"
        printf '  }\n'
        printf '}\n'
    } > "$temp_report"
    
    # Atomic move
    mv "$temp_report" "$REPORT_FILE"
    [[ "$VERBOSE" == true ]] && log_verbose "Report: $REPORT_FILE"
}

# Banner
if [[ "$PLAIN_OUTPUT" == false ]]; then
    printf "\n🚀 Mac Dev Setup v%s\n📅 %s\n\n" "$SCRIPT_VERSION" "$(date)"
else
    printf "[INFO] Mac Dev Setup v%s - %s\n" "$SCRIPT_VERSION" "$(date)"
fi

# Verifica comandi base
for cmd in curl mkdir mktemp; do
    require_command "$cmd" || exit 1
done

# Acquisisci lock
acquire_lock || exit 1

# Prerequisiti
log_info "Prerequisiti..."

MACOS_VERSION=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)
ARCH=$(uname -m)
log_verbose "macOS $MACOS_VERSION ($ARCH)"

[[ $MACOS_MAJOR -lt $MIN_MACOS_MAJOR ]] && { log_error "macOS $MIN_MACOS_MAJOR+ richiesto"; exit 1; }

if ! xcode-select -p &>/dev/null; then
    log_error "Xcode Command Line Tools richiesti"
    printf "\nInstalla: xcode-select --install\n"
    printf "Poi riesegui questo script.\n\n"
    exit 1
fi

AVAILABLE_SPACE_KB=$(df -k / | tail -1 | awk '{print $4}')
AVAILABLE_SPACE_GB=$((AVAILABLE_SPACE_KB / 1024 / 1024))
log_verbose "Spazio: ${AVAILABLE_SPACE_GB}GB"
[[ $AVAILABLE_SPACE_GB -lt $MIN_SPACE_GB ]] && { log_error "Spazio insufficiente"; exit 1; }

if ! curl -sSf --connect-timeout 5 --retry 3 --retry-delay 2 --head https://github.com >/dev/null 2>&1; then
    log_error "Connessione internet non disponibile"
    exit 1
fi

log_success "Prerequisiti OK"
printf "\n"

# Helper functions
install_or_upgrade_brew_package() {
    local package="$1"
    command -v brew &>/dev/null || { mark_failed "brew-$package"; return 1; }
    
    if brew list "$package" &>/dev/null; then
        log_verbose "$package OK"
        brew outdated --quiet "$package" 2>/dev/null && {
            log_info "Upgrade $package..."
            execute brew upgrade "$package" || mark_failed "upgrade-$package"
        }
    else
        log_info "Install $package..."
        execute brew install "$package" || mark_failed "install-$package"
    fi
}

install_or_upgrade_brew_cask() {
    local cask="$1"
    command -v brew &>/dev/null || { mark_failed "brew-cask-$cask"; return 1; }
    
    if brew list --cask "$cask" &>/dev/null; then
        log_verbose "$cask OK"
        brew outdated --cask --quiet "$cask" 2>/dev/null && {
            log_info "Upgrade $cask..."
            execute brew upgrade --cask "$cask" 2>/dev/null || {
                log_warning "Provo reinstall..."
                execute brew reinstall --cask "$cask" || mark_failed "cask-$cask"
            }
        }
    else
        log_info "Install $cask..."
        execute brew install --cask "$cask" || mark_failed "cask-$cask"
    fi
}

# 1. Homebrew
log_info "Homebrew..."
if ! command -v brew &>/dev/null; then
    log_info "Installazione Homebrew..."
    log_warning "SICUREZZA: Questo scaricherà ed eseguirà script remoto"
    
    if [[ "$NON_INTERACTIVE" == false && "$DRY_RUN" == false ]]; then
        printf "Procedere? (y/n) "
        read -r -n 1 reply
        printf "\n"
        [[ ! $reply =~ ^[Yy]$ ]] && { log_error "Homebrew richiesto"; exit 1; }
    fi
    
    [[ "$DRY_RUN" == false ]] && {
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            log_error "Installazione Homebrew fallita"
            exit 1
        }
        
        # Setup PATH
        if [[ "$ARCH" == 'arm64' ]]; then
            BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
            [[ -f ~/.zprofile ]] && ! grep -qF "$BREW_SHELLENV" ~/.zprofile && printf "%s\n" "$BREW_SHELLENV" >> ~/.zprofile
            [[ ! -f ~/.zprofile ]] && printf "%s\n" "$BREW_SHELLENV" > ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    }
else
    log_success "Homebrew OK"
    execute brew update || mark_failed "brew-update"
fi

# Rileva prefix (gestisce Intel + Apple Silicon)
if command -v brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)
    log_verbose "Brew: $BREW_PREFIX"
    
    # Check entrambi i path per compatibilità Rosetta
    if [[ "$ARCH" == "arm64" && -d "/usr/local/bin" ]]; then
        log_verbose "Rosetta binaries disponibili in /usr/local"
    fi
else
    BREW_PREFIX="/usr/local"
fi
printf "\n"

# 2. Python build deps
log_info "Python build deps..."
BUILD_DEPS=(openssl readline sqlite xz zlib tcl-tk bzip2)
for dep in "${BUILD_DEPS[@]}"; do
    [[ -z "$dep" ]] && continue
    install_or_upgrade_brew_package "$dep" || true
done
printf "\n"

# 3. Version managers
log_info "Version managers..."
install_or_upgrade_brew_package "pyenv" || true
install_or_upgrade_brew_package "nvm" || true
printf "\n"

# 4. Dev tools
log_info "Dev tools..."
for tool in git wget tree jq; do
    [[ -z "$tool" ]] && continue
    install_or_upgrade_brew_package "$tool" || true
done
printf "\n"

# 5. Docker/Colima
log_info "Docker/Colima..."
for tool in docker docker-compose colima; do
    [[ -z "$tool" ]] && continue
    install_or_upgrade_brew_package "$tool" || true
done
printf "\n"

# 6. React Native
log_info "React Native..."
install_or_upgrade_brew_package "watchman" || true
install_or_upgrade_brew_cask "android-studio" || true
install_or_upgrade_brew_package "cocoapods" || true
printf "\n"

# 7. Shell config (file separato per clean management)
log_info "Shell config..."

# Path NVM
NVM_BREW_PATH=$(command -v brew &>/dev/null && brew list nvm &>/dev/null && brew --prefix nvm || echo "${BREW_PREFIX}/opt/nvm")
log_verbose "NVM: $NVM_BREW_PATH"

# Crea directory per config modulare
[[ ! -d ~/.zshrc.d && "$DRY_RUN" == false ]] && mkdir -p ~/.zshrc.d

# File config separato (più pulito)
DEV_ENV_FILE="${HOME}/.zshrc.d/dev-env.zsh"
MARKER="# Dev Environment Setup v${SCRIPT_VERSION} - ${BACKUP_TIMESTAMP}"

if [[ ! -f "$DEV_ENV_FILE" ]] || ! grep -qF "# Dev Environment Setup v${SCRIPT_VERSION}" "$DEV_ENV_FILE" 2>/dev/null; then
    TEMP_FILE=$(mktemp)
    TEMP_FILES+=("$TEMP_FILE")
    
    cat << EOF > "$TEMP_FILE"
$MARKER
# Pyenv
export PYENV_ROOT="\$HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
command -v pyenv &>/dev/null && eval "\$(pyenv init --path)" && eval "\$(pyenv init -)"

# NVM
export NVM_DIR="\$HOME/.nvm"
[ -s "${NVM_BREW_PATH}/nvm.sh" ] && . "${NVM_BREW_PATH}/nvm.sh"
[ -s "${NVM_BREW_PATH}/etc/bash_completion.d/nvm" ] && . "${NVM_BREW_PATH}/etc/bash_completion.d/nvm"

# Android
export ANDROID_HOME=\$HOME/Library/Android/sdk
export PATH=\$PATH:\$ANDROID_HOME/emulator:\$ANDROID_HOME/platform-tools
EOF

    [[ "$DRY_RUN" == false ]] && {
        mv "$TEMP_FILE" "$DEV_ENV_FILE"
        
        # Aggiungi source a .zshrc se non presente
        if [[ -f ~/.zshrc ]] && ! grep -qF "source ~/.zshrc.d/dev-env.zsh" ~/.zshrc; then
            printf "\n# Dev environment config\n[ -f ~/.zshrc.d/dev-env.zsh ] && source ~/.zshrc.d/dev-env.zsh\n" >> ~/.zshrc
        elif [[ ! -f ~/.zshrc ]]; then
            printf "# Dev environment config\n[ -f ~/.zshrc.d/dev-env.zsh ] && source ~/.zshrc.d/dev-env.zsh\n" > ~/.zshrc
        fi
        
        log_success "Config creata: ~/.zshrc.d/dev-env.zsh"
    }
else
    log_verbose "Config già presente"
fi

# Carica config nel processo corrente
[[ "$DRY_RUN" == false ]] && {
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    command -v pyenv &>/dev/null && eval "$(pyenv init --path)" && eval "$(pyenv init -)"
    
    export NVM_DIR="$HOME/.nvm"
    [[ -s "${NVM_BREW_PATH}/nvm.sh" ]] && . "${NVM_BREW_PATH}/nvm.sh"
}
printf "\n"

# 8. Python
log_info "Python ${PYTHON_VERSION}..."
if command -v pyenv &>/dev/null; then
    if pyenv versions --bare 2>/dev/null | grep -q "^${PYTHON_VERSION}$"; then
        log_success "Python OK"
    else
        log_info "Install Python ${PYTHON_VERSION}..."
        PYENV_LOG="/tmp/pyenv-${BACKUP_TIMESTAMP}.log"
        [[ "$DRY_RUN" == false ]] && {
            if ! pyenv install "$PYTHON_VERSION" 2>&1 | tee "$PYENV_LOG"; then
                log_error "Install fallito. Log: $PYENV_LOG"
                log_error "Possibili cause:"
                log_error "  - Build dependencies mancanti"
                log_error "  - Verifica: brew install openssl readline sqlite xz zlib"
                log_error "  - Log dettagliato: cat $PYENV_LOG"
                mark_failed "pyenv-install"
            fi
        }
    fi
    
    CURRENT=$(pyenv version-name 2>/dev/null || echo "")
    [[ "$CURRENT" != "$PYTHON_VERSION" ]] && {
        execute pyenv global "$PYTHON_VERSION"
        [[ "$DRY_RUN" == false ]] && printf "%s\n" "$PYTHON_VERSION" > ~/.python-version
    }
else
    mark_failed "pyenv"
fi
printf "\n"

# 9. Node.js
log_info "Node.js ${NODE_VERSION}..."
if [[ -s "${NVM_BREW_PATH}/nvm.sh" ]]; then
    if [[ "$DRY_RUN" == false ]]; then
        # Carica nvm
        export NVM_DIR="$HOME/.nvm"
        . "${NVM_BREW_PATH}/nvm.sh"
        
        nvm install "$NODE_VERSION" --latest-npm && {
            nvm use "$NODE_VERSION"
            nvm alias default "$NODE_VERSION" 2>/dev/null || true
            
            INSTALLED=$(node --version 2>/dev/null | sed 's/^v//')
            [[ -n "$INSTALLED" ]] && printf "%s\n" "$INSTALLED" > ~/.nvmrc
            log_success "Node $INSTALLED"
        } || mark_failed "nvm-install"
    else
        printf "[DRY-RUN] nvm install %s\n" "$NODE_VERSION"
    fi
else
    mark_failed "nvm"
fi
printf "\n"

# 10. uv
log_info "uv..."
if command -v uv &>/dev/null; then
    log_verbose "uv OK"
else
    log_warning "SICUREZZA: Script remoto uv"
    [[ "$NON_INTERACTIVE" == true && "$DRY_RUN" == false ]] && {
        curl -LsSf --retry 3 --retry-delay 2 https://astral.sh/uv/install.sh | sh || mark_failed "uv"
    }
    [[ "$NON_INTERACTIVE" == false && "$DRY_RUN" == false ]] && {
        printf "Installare uv? (y/n) "
        read -r -n 1 reply
        printf "\n"
        [[ $reply =~ ^[Yy]$ ]] && curl -LsSf --retry 3 https://astral.sh/uv/install.sh | sh || mark_failed "uv"
    }
fi
printf "\n"

# 11. React Native tools
log_info "React Native..."
if command -v npm &>/dev/null; then
    for pkg in react-native-cli expo-cli; do
        npm list -g "$pkg" --depth=0 --parseable &>/dev/null || {
            execute npm install -g "$pkg" --no-audit --no-fund || mark_failed "$pkg"
        }
    done
else
    mark_failed "npm-tools"
fi
printf "\n"

# 12. Colima (usa process group timeout)
log_info "Colima..."
if command -v colima &>/dev/null; then
    if colima status &>/dev/null; then
        log_success "Colima attivo"
    else
        log_info "Avvio Colima (process group aware)..."
        [[ "$DRY_RUN" == false ]] && {
            # Usa timeout con process group per gestire colima e figli
            if portable_timeout 120 colima start --cpu 4 --memory 8 2>/dev/null; then
                log_success "Colima avviato"
            else
                log_warning "Timeout, retry con config esistente..."
                portable_timeout 60 colima start || mark_failed "colima-start"
            fi
        }
    fi
    
    [[ "$DRY_RUN" == false ]] && command -v docker &>/dev/null && {
        docker ps &>/dev/null && log_success "Docker OK" || mark_failed "docker"
    }
else
    mark_failed "colima"
fi
printf "\n"

# 13. Warp
log_info "Warp..."
install_or_upgrade_brew_cask "warp"
printf "\n"

# 14. Cleanup
log_info "Cleanup..."
[[ "$DRY_RUN" == false ]] && {
    [[ "$VERBOSE" == true ]] && {
        brew cleanup --prune=all
        brew autoremove
    } || {
        brew cleanup --prune=all 2>/dev/null || true
        brew autoremove 2>/dev/null || true
    }
    
    command -v npm &>/dev/null && npm cache clean --force 2>/dev/null || true
    
    command -v pip &>/dev/null && {
        PIP_CACHE=$(pip cache dir 2>/dev/null || echo "")
        [[ -d "$PIP_CACHE" ]] && {
            [[ "$VERBOSE" == true ]] && pip cache purge || pip cache purge 2>/dev/null || rm -rf "$PIP_CACHE" 2>/dev/null || true
        }
    }
    
    command -v uv &>/dev/null && uv cache clean 2>/dev/null || true
}
log_success "Cleanup OK"
printf "\n"

# Report
printf "════════════════════════════════════════════════════════════\n"
[[ "$PLAIN_OUTPUT" == true ]] && printf "[SUCCESS] Setup OK\n" || printf "✨ Setup completato!\n"
printf "════════════════════════════════════════════════════════════\n\n"

printf "📦 Versioni:\n"
command -v python3 &>/dev/null && printf "  Python: %s\n" "$(python3 --version 2>&1 | awk '{print $2}')"
command -v pyenv &>/dev/null && printf "  pyenv: %s\n" "$(pyenv version-name 2>&1 || echo 'N/A')"
command -v node &>/dev/null && printf "  Node: %s\n" "$(node --version | sed 's/^v//')"
command -v docker &>/dev/null && printf "  Docker: %s\n" "$(docker --version | sed -E 's/Docker version ([^,]+).*/\1/')"
printf "\n"

[[ ${#FAILED_COMPONENTS[@]} -gt 1 || ( ${#FAILED_COMPONENTS[@]} -eq 1 && -n "${FAILED_COMPONENTS[0]}" ) ]] && {
    count=0
    for comp in "${FAILED_COMPONENTS[@]}"; do
        [[ -n "$comp" ]] && count=$((count + 1))
    done
    printf "⚠️  Falliti (%d):\n" "$count"
    for comp in "${FAILED_COMPONENTS[@]}"; do
        [[ -n "$comp" ]] && printf '  • %s\n' "$comp"
    done
    printf "\n"
}

printf "💾 Spazio: %sGB | 🏗️  Arch: %s\n" "$AVAILABLE_SPACE_GB" "$ARCH"
[[ "$VERBOSE" == true ]] && printf "📝 Log: %s\n" "$LOGFILE"
[[ "$CI_MODE" == true || "$VERBOSE" == true ]] && printf "📊 Report: %s\n" "$REPORT_FILE"

printf "\n📝 Next:\n"
printf "  1. Xcode dall'App Store\n"
printf "  2. Android Studio SDK\n"
printf "  3. exec zsh -l\n"
printf "  4. docker ps\n\n"

printf "📂 Config file: ~/.zshrc.d/dev-env.zsh\n"
printf "   (Per rollback: rm ~/.zshrc.d/dev-env.zsh)\n\n"

printf "════════════════════════════════════════════════════════════\n"
printf "💡 %s --dry-run --verbose\n" "$0"
printf "════════════════════════════════════════════════════════════\n"

# Exit con codice appropriato (controlla se ci sono fallimenti reali)
has_failures=false
for comp in "${FAILED_COMPONENTS[@]}"; do
    [[ -n "$comp" ]] && has_failures=true && break
done

[[ "$has_failures" == true ]] && exit 2 || exit 0