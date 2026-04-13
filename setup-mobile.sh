#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🚀 OpenClaudeLinux — Mobile-Only Setup
# Lightweight installer for Termux without desktop environment
# Usage: bash setup-mobile.sh [--no-ollama] [--no-claude] [--no-openclaw] [--whatsapp] [--telegram]
# =========================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# Defaults
SKIP_OLLAMA=0
SKIP_CLAUDE=0
SKIP_OPENCLAW=0
INSTALL_WHATSAPP=0
INSTALL_TELEGRAM=0

# Arg parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-ollama)   SKIP_OLLAMA=1;   shift ;;
        --no-claude)   SKIP_CLAUDE=1;   shift ;;
        --no-openclaw) SKIP_OPENCLAW=1; shift ;;
        --whatsapp)    INSTALL_WHATSAPP=1; shift ;;
        --telegram)    INSTALL_TELEGRAM=1; shift ;;
        *) echo "Unknown: $1"; shift ;;
    esac
done

# Helpers
info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

# RAM detection
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

# Banner
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}      🚀 OpenClaudeLinux Mobile-Only Setup${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Device RAM:${NC} ${CYAN}${TOTAL_RAM_MB} MB (${TOTAL_RAM_GB} GB)${NC}"
echo -e "  ${WHITE}Mode:${NC}       ${CYAN}Mobile (No Desktop)${NC}"
echo ""
echo -e "${YELLOW}This installer skips desktop environment for lightweight usage${NC}"
echo ""

# Interactive feature selection if not in auto mode
if [[ $SKIP_OLLAMA -eq 0 && $SKIP_OPENCLAW -eq 0 ]]; then
    echo -e "${CYAN}━━━ Choose Features ━━━${NC}"
    echo ""
    echo -e "${WHITE}What would you like to install?${NC}"
    echo ""
    echo -e "  ${WHITE}1)${NC} Minimal      — Claude Code only"
    echo -e "  ${WHITE}2)${NC} Standard     ${GREEN}(RECOMMENDED)${NC} — Claude + Ollama"
    echo -e "  ${WHITE}3)${NC} Full         — All features (Claude + Ollama + OpenClaw)"
    echo ""
    read -p "Enter choice (1-3) [default: 2]: " FEAT_CHOICE
    FEAT_CHOICE=${FEAT_CHOICE:-2}
    
    case "$FEAT_CHOICE" in
        1) SKIP_OLLAMA=1; SKIP_OPENCLAW=1 ;;
        2) SKIP_OPENCLAW=1 ;;
        3) ;; # all enabled
        *) SKIP_OPENCLAW=1 ;;
    esac
    
    # Remote control options (only if OpenClaw enabled)
    if [[ $SKIP_OPENCLAW -eq 0 ]]; then
        echo ""
        echo -e "${CYAN}━━━ Optional: Remote Control ━━━${NC}"
        echo ""
        echo -e "Enable remote control for OpenClaw?"
        echo ""
        echo -e "  ${WHITE}1)${NC} None        — No remote control"
        echo -e "  ${WHITE}2)${NC} Telegram    — Telegram bot integration"
        echo -e "  ${WHITE}3)${NC} WhatsApp    — WhatsApp bot integration"
        echo -e "  ${WHITE}4)${NC} Both        — Telegram + WhatsApp"
        echo ""
        read -p "Enter choice (1-4) [default: 1]: " REMOTE_CHOICE
        REMOTE_CHOICE=${REMOTE_CHOICE:-1}
        case "$REMOTE_CHOICE" in
            1) ;; # none
            2) INSTALL_TELEGRAM=1 ;;
            3) INSTALL_WHATSAPP=1 ;;
            4) INSTALL_TELEGRAM=1; INSTALL_WHATSAPP=1 ;;
            *) ;;
        esac
    fi
    
    echo ""
    read -p "Press Enter to start installation..."
fi

# Installation summary
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  Installation Plan${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Desktop:   ${GRAY}Skipped${NC}"
echo -e "  Ollama:    $( [[ $SKIP_OLLAMA -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  Claude:    $( [[ $SKIP_CLAUDE -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  OpenClaw:  $( [[ $SKIP_OPENCLAW -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  Telegram:  $( [[ $INSTALL_TELEGRAM -eq 1 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  WhatsApp:  $( [[ $INSTALL_WHATSAPP -eq 1 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo ""
read -p "Press Enter to start installation..."

# Step 1: Termux base
info "Step 1/4: Updating Termux packages..."
pkg update -y 2>/dev/null || warn "pkg update warnings"
pkg upgrade -y 2>/dev/null || warn "pkg upgrade warnings"
pkg install -y tur-repo 2>/dev/null || warn "repo warnings"
pkg update -y 2>/dev/null

pkg install -y git curl wget nodejs npm python openssl which 2>/dev/null || warn "base pkg warnings"
success "Base packages installed"

# Step 2: Ollama
if [[ $SKIP_OLLAMA -eq 0 ]]; then
    info "Step 2/4: Installing Ollama..."
    pkg install -y ollama 2>/dev/null || warn "Ollama pkg failed"
    if ! command -v ollama &>/dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh 2>/dev/null || warn "Ollama manual install failed"
    fi
    if command -v ollama &>/dev/null; then
        success "Ollama installed"
    fi
else
    info "Step 2/4: Ollama skipped"
fi

# Step 3: Claude Code
if [[ $SKIP_CLAUDE -eq 0 ]]; then
    info "Step 3/4: Installing Claude Code..."
    export NODE_OPTIONS="--dns-result-order=ipv4first"
    grep -q "NODE_OPTIONS" ~/.bashrc 2>/dev/null || echo 'export NODE_OPTIONS="--dns-result-order=ipv4first"' >> ~/.bashrc
    
    npm install -g @anthropic-ai/claude-code 2>/dev/null || die "Claude install failed"
    success "Claude Code installed"
    
    if [[ $SKIP_OLLAMA -eq 0 ]]; then
        if ! grep -q "ANTHROPIC_BASE_URL" ~/.bashrc 2>/dev/null; then
            cat >> ~/.bashrc << 'CLAUDEEOF'

# Claude Code + Ollama
export ANTHROPIC_BASE_URL="http://localhost:11434/v1"
export ANTHROPIC_API_KEY="ollama"
CLAUDEEOF
        fi
        success "Claude configured for Ollama"
    fi
else
    info "Step 3/4: Claude skipped"
fi

# Step 4: OpenClaw
if [[ $SKIP_OPENCLAW -eq 0 ]]; then
    info "Step 4/4: Installing OpenClaw..."
    if command -v openclaw &>/dev/null || [[ -d "$HOME/.openclaw/repo" ]]; then
        success "OpenClaw already installed"
    else
        INSTALL_SCRIPT="$(curl -sSL https://myopenclawhub.com/install)" || { warn "OpenClaw fetch failed"; SKIP_OPENCLAW=1; }
        if [[ $SKIP_OPENCLAW -eq 0 ]]; then
            bash -c "$INSTALL_SCRIPT" < /dev/tty
            source ~/.bashrc 2>/dev/null
            success "OpenClaw installed"
        fi
    fi
else
    info "Step 4/4: OpenClaw skipped"
fi

# Final summary
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  🎉 MOBILE SETUP COMPLETE!${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Mode:${NC}  Mobile (No Desktop)"
echo -e "  ${WHITE}RAM:${NC}   ${TOTAL_RAM_MB} MB"
echo ""

if [[ $SKIP_OLLAMA -eq 0 ]]; then
    echo -e "${CYAN}Ollama:${NC}"
    echo -e "  ${WHITE}ollama serve &${NC}"
    echo -e "  ${WHITE}ollama pull tinyllama${NC}  ${GRAY}(lightweight)${NC}"
    echo ""
fi

if [[ $SKIP_CLAUDE -eq 0 ]]; then
    echo -e "${CYAN}Claude Code:${NC}"
    echo -e "  ${WHITE}claude --model <model>${NC}"
    echo ""
fi

if [[ $SKIP_OPENCLAW -eq 0 ]]; then
    echo -e "${CYAN}OpenClaw:${NC}"
    echo -e "  ${WHITE}openclaw onboard${NC}"
    echo -e "  ${WHITE}openclaw gateway${NC}"
    echo -e "  Dashboard: ${WHITE}http://127.0.0.1:18789${NC}"
    echo ""
fi

if [[ $INSTALL_TELEGRAM -eq 1 ]]; then
    echo -e "${CYAN}Telegram Bot:${NC}"
    echo -e "  ${WHITE}bash telegram-bot.sh${NC}  — Setup Telegram integration"
    echo ""
fi

if [[ $INSTALL_WHATSAPP -eq 1 ]]; then
    echo -e "${CYAN}WhatsApp Bot:${NC}"
    echo -e "  ${WHITE}bash whatsapp-bot.sh${NC}  — Setup WhatsApp integration"
    echo -e "  ${GRAY}Choose 'Mobile' mode during setup${NC}"
    echo ""
fi

echo -e "  ${WHITE}source ~/.bashrc${NC}"
echo ""
