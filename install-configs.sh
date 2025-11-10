#!/usr/bin/env bash

# ============================================
# AI Configurations Installer
# ============================================
# Installa configurazioni AI nelle location standard
# Usage: ./install-configs.sh [--all|--claude|--copilot|--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/ai-configurations"
DRY_RUN=false

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# FUNCTIONS
# ============================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if [[ "$DRY_RUN" == "false" ]]; then
            cp "$file" "$backup"
            log_success "Backup creato: $backup"
        else
            log_info "[DRY-RUN] Backup: $file → $backup"
        fi
    fi
}

install_claude_vscode() {
    log_info "Installazione Claude VS Code config..."
    
    local source="$CONFIG_DIR/claude-vscode.json"
    local dest="$HOME/.config/claude/claude_desktop_config.json"
    
    if [[ ! -f "$source" ]]; then
        log_error "File sorgente non trovato: $source"
        return 1
    fi
    
    # Crea directory se non esiste
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$(dirname "$dest")"
    else
        log_info "[DRY-RUN] mkdir -p $(dirname "$dest")"
    fi
    
    # Backup del file esistente
    backup_file "$dest"
    
    # Copia il file
    if [[ "$DRY_RUN" == "false" ]]; then
        cp "$source" "$dest"
        log_success "Installato: $dest"
    else
        log_info "[DRY-RUN] cp $source → $dest"
    fi
}

install_claude_cli() {
    log_info "Installazione Claude CLI config..."
    
    local source="$CONFIG_DIR/claude-cli-config.json"
    local dest="$HOME/.config/claude/config.json"
    
    if [[ ! -f "$source" ]]; then
        log_error "File sorgente non trovato: $source"
        return 1
    fi
    
    # Crea directory se non esiste
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$(dirname "$dest")"
    else
        log_info "[DRY-RUN] mkdir -p $(dirname "$dest")"
    fi
    
    # Backup del file esistente
    backup_file "$dest"
    
    # Copia il file
    if [[ "$DRY_RUN" == "false" ]]; then
        cp "$source" "$dest"
        log_success "Installato: $dest"
    else
        log_info "[DRY-RUN] cp $source → $dest"
    fi
}

install_github_copilot() {
    log_info "Installazione GitHub Copilot config..."
    
    local source="$CONFIG_DIR/github-copilot-vscode.json"
    
    if [[ ! -f "$source" ]]; then
        log_error "File sorgente non trovato: $source"
        return 1
    fi
    
    log_warning "GitHub Copilot richiede configurazione manuale in VS Code"
    echo ""
    echo "Per configurare GitHub Copilot:"
    echo "1. Apri VS Code"
    echo "2. Cmd+Shift+P → 'Preferences: Open User Settings (JSON)'"
    echo "3. Copia il contenuto da: $source"
    echo "4. Incolla nelle tue settings (mergia con esistenti)"
    echo ""
    echo "Oppure usa questo comando per vedere il contenuto:"
    echo "  cat $source"
    echo ""
}

install_warp() {
    log_info "Configurazione Warp..."
    
    echo ""
    echo "Warp ha 2 tipi di configurazioni:"
    echo ""
    echo "1. Project Rules (WARP.md):"
    echo "   ✅ Già presente nel repository: $CONFIG_DIR/WARP.md"
    echo "   → Warp lo legge automaticamente quando lavori in questo progetto"
    echo ""
    echo "2. Global Rules (warp-global-rules.md):"
    echo "   📋 File generato: $CONFIG_DIR/warp-global-rules.md"
    echo "   → Apri Warp → Settings → AI → Knowledge → Manage Rules → Global"
    echo "   → Copia/incolla le regole dal file"
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Installa configurazioni AI nelle location standard del sistema.

OPTIONS:
    --all           Installa tutte le configurazioni (default)
    --claude        Installa solo configurazioni Claude (VS Code + CLI)
    --copilot       Mostra istruzioni per GitHub Copilot
    --warp          Mostra istruzioni per Warp
    --dry-run       Mostra cosa verrebbe fatto senza eseguire
    --help          Mostra questo messaggio

EXAMPLES:
    $0 --all                 # Installa tutto
    $0 --claude              # Solo Claude
    $0 --dry-run --all       # Test senza modificare file
    
LOCATIONS:
    Claude VS Code: ~/.config/claude/claude_desktop_config.json
    Claude CLI:     ~/.config/claude/config.json
    GitHub Copilot: VS Code User Settings (manuale)
    Warp:           Project WARP.md + Global Rules (UI)

EOF
}

# ============================================
# MAIN
# ============================================

# Parse arguments
INSTALL_ALL=true
INSTALL_CLAUDE=false
INSTALL_COPILOT=false
INSTALL_WARP=false

if [[ $# -eq 0 ]]; then
    INSTALL_ALL=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            INSTALL_ALL=true
            shift
            ;;
        --claude)
            INSTALL_ALL=false
            INSTALL_CLAUDE=true
            shift
            ;;
        --copilot)
            INSTALL_ALL=false
            INSTALL_COPILOT=true
            shift
            ;;
        --warp)
            INSTALL_ALL=false
            INSTALL_WARP=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "Opzione sconosciuta: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Print header
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         AI Configurations Installer                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "DRY-RUN MODE: Nessun file verrà modificato"
    echo ""
fi

# Verifica che la directory delle configurazioni esista
if [[ ! -d "$CONFIG_DIR" ]]; then
    log_error "Directory configurazioni non trovata: $CONFIG_DIR"
    exit 1
fi

# Install configurations
if [[ "$INSTALL_ALL" == "true" ]] || [[ "$INSTALL_CLAUDE" == "true" ]]; then
    install_claude_vscode
    echo ""
    install_claude_cli
    echo ""
fi

if [[ "$INSTALL_ALL" == "true" ]] || [[ "$INSTALL_COPILOT" == "true" ]]; then
    install_github_copilot
fi

if [[ "$INSTALL_ALL" == "true" ]] || [[ "$INSTALL_WARP" == "true" ]]; then
    install_warp
fi

# Final message
echo "════════════════════════════════════════════════════════════"
if [[ "$DRY_RUN" == "true" ]]; then
    log_info "DRY-RUN completato. Riesegui senza --dry-run per applicare"
else
    log_success "Installazione completata!"
fi
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📝 Next steps:"
echo "1. Riavvia VS Code per applicare le configurazioni Claude"
echo "2. Configura GitHub Copilot manualmente (vedi istruzioni sopra)"
echo "3. Aggiungi Warp Global Rules dalla UI"
echo ""
