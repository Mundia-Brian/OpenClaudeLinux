#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🚀 OpenClaudeLinux — Master Setup Script
# RAM-aware interactive installer for 2 GB - 8 GB+ devices
# Usage: bash setup.sh [--auto] [--de lxqt|xfce4|mate|kde] [--no-ollama] [--no-claude] [--no-openclaw]
# =========================================================================


# ── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ── Defaults ──────────────────────────────────────────────────────────────
AUTO_MODE=0
DE=""
SKIP_OLLAMA=0
SKIP_CLAUDE=0
SKIP_OPENCLAW=0
INSTALL_EXTRAS=0
INSTALL_WHATSAPP=0
INSTALL_TELEGRAM=0
USAGE_MODE="desktop"
SKIP_DESKTOP=0
DISPLAY_NUM=":0"

# ── Arg parsing ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --auto)        AUTO_MODE=1;     shift ;;
        --de)          DE="$2";         shift 2 ;;
        --no-ollama)   SKIP_OLLAMA=1;   shift ;;
        --no-claude)   SKIP_CLAUDE=1;   shift ;;
        --no-openclaw) SKIP_OPENCLAW=1; shift ;;
        --distro-extras) INSTALL_EXTRAS=1; shift ;;
        --whatsapp)    INSTALL_WHATSAPP=1; shift ;;
        --telegram)    INSTALL_TELEGRAM=1; shift ;;
        --mobile)      USAGE_MODE="mobile"; SKIP_DESKTOP=1; shift ;;
        --desktop)     USAGE_MODE="desktop"; SKIP_DESKTOP=0; shift ;;
        *) echo "Unknown: $1"; shift ;;
    esac
done

# ── Helpers ───────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

# ── RAM detection ─────────────────────────────────────────────────────────
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))

# ── RAM tier classification ───────────────────────────────────────────────
if   [[ $TOTAL_RAM_MB -lt 2048 ]]; then RAM_TIER="ultra-low";  RAM_COLOR="${RED}"
elif [[ $TOTAL_RAM_MB -lt 3072 ]]; then RAM_TIER="low";        RAM_COLOR="${YELLOW}"
elif [[ $TOTAL_RAM_MB -lt 4096 ]]; then RAM_TIER="medium";     RAM_COLOR="${CYAN}"
elif [[ $TOTAL_RAM_MB -lt 6144 ]]; then RAM_TIER="high";       RAM_COLOR="${GREEN}"
else                                     RAM_TIER="ultra-high"; RAM_COLOR="${PURPLE}"
fi

# ── Banner ────────────────────────────────────────────────────────────────
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}           🚀 OpenClaudeLinux Setup Wizard${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Device RAM:${NC} ${RAM_COLOR}${TOTAL_RAM_MB} MB (${TOTAL_RAM_GB} GB)${NC} — Tier: ${RAM_COLOR}${RAM_TIER}${NC}"
echo ""

# ── Interactive mode: Desktop Environment selection ───────────────────────
if [[ $AUTO_MODE -eq 0 && -z "$DE" ]]; then
    echo -e "${CYAN}━━━ Step 1/2: Choose Desktop Environment ━━━${NC}"
    echo ""
    
    case "$RAM_TIER" in
        ultra-low)
            echo -e "${RED}⚠️  WARNING: Less than 2 GB RAM detected!${NC}"
            echo -e "${YELLOW}   Only LXQt is recommended. Other DEs may crash.${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} LXQt       ${GREEN}(RECOMMENDED)${NC} — Ultra lightweight"
            echo -e "  ${GRAY}2) XFCE4      (NOT RECOMMENDED) — May cause OOM${NC}"
            echo -e "  ${GRAY}3) MATE       (NOT RECOMMENDED) — May cause OOM${NC}"
            echo -e "  ${GRAY}4) KDE Plasma (NOT RECOMMENDED) — Will crash${NC}"
            ;;
        low)
            echo -e "${YELLOW}⚠️  2-3 GB RAM: LXQt or XFCE4 recommended${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} LXQt       ${GREEN}(RECOMMENDED)${NC} — Ultra lightweight"
            echo -e "  ${WHITE}2)${NC} XFCE4      ${GREEN}(RECOMMENDED)${NC} — Fast, customizable"
            echo -e "  ${GRAY}3) MATE       (Risky) — May lag${NC}"
            echo -e "  ${GRAY}4) KDE Plasma (NOT RECOMMENDED) — Too heavy${NC}"
            ;;
        medium)
            echo -e "${CYAN}✓ 3-4 GB RAM: All DEs except KDE supported${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} LXQt       — Ultra lightweight"
            echo -e "  ${WHITE}2)${NC} XFCE4      ${GREEN}(RECOMMENDED)${NC} — Best balance"
            echo -e "  ${WHITE}3)${NC} MATE       — Classic UI"
            echo -e "  ${GRAY}4) KDE Plasma (Risky) — Heavy${NC}"
            ;;
        high|ultra-high)
            echo -e "${GREEN}✓ ${TOTAL_RAM_GB}+ GB RAM: All DEs fully supported${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} LXQt       — Ultra lightweight"
            echo -e "  ${WHITE}2)${NC} XFCE4      ${GREEN}(RECOMMENDED)${NC} — Fast & customizable"
            echo -e "  ${WHITE}3)${NC} MATE       — Classic UI"
            echo -e "  ${WHITE}4)${NC} KDE Plasma — Modern, Windows 11 style"
            ;;
    esac
    
    echo ""
    read -p "Enter choice (1-4) [default: 1]: " DE_CHOICE
    DE_CHOICE=${DE_CHOICE:-1}
    
    case "$DE_CHOICE" in
        1) DE="lxqt" ;;
        2) DE="xfce4" ;;
        3) DE="mate" ;;
        4) DE="kde" ;;
        *) warn "Invalid choice, defaulting to LXQt"; DE="lxqt" ;;
    esac
fi

# ── Auto mode: RAM-based defaults ─────────────────────────────────────────
if [[ -z "$DE" ]]; then
    case "$RAM_TIER" in
        ultra-low) DE="lxqt"; SKIP_OLLAMA=1; SKIP_OPENCLAW=1 ;;
        low)       DE="lxqt" ;;
        medium)    DE="xfce4" ;;
        *)         DE="xfce4" ;;
    esac
fi

# ── Interactive mode: Feature selection ───────────────────────────────────
if [[ $AUTO_MODE -eq 0 ]]; then
    echo ""
    echo -e "${CYAN}━━━ Step 2/2: Choose Features ━━━${NC}"
    echo ""
    
    case "$RAM_TIER" in
        ultra-low)
            echo -e "${RED}⚠️  Ultra-low RAM: Ollama & OpenClaw NOT recommended${NC}"
            echo ""
            echo -e "  ${WHITE}Ollama:${NC}    ${GRAY}Disabled (needs 2+ GB)${NC}"
            echo -e "  ${WHITE}Claude:${NC}    ${GREEN}Enabled${NC} (lightweight)"
            echo -e "  ${WHITE}OpenClaw:${NC}  ${GRAY}Disabled (needs 2+ GB)${NC}"
            SKIP_OLLAMA=1
            SKIP_OPENCLAW=1
            ;;
        low)
            echo -e "${YELLOW}Recommended for 2-3 GB RAM:${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} Minimal    — Claude Code only"
            echo -e "  ${WHITE}2)${NC} Standard   ${GREEN}(RECOMMENDED)${NC} — Claude + Ollama (tiny models)"
            echo -e "  ${WHITE}3)${NC} Full       — All features (may lag)"
            echo ""
            read -p "Enter choice (1-3) [default: 2]: " FEAT_CHOICE
            FEAT_CHOICE=${FEAT_CHOICE:-2}
            case "$FEAT_CHOICE" in
                1) SKIP_OLLAMA=1; SKIP_OPENCLAW=1 ;;
                2) SKIP_OPENCLAW=1 ;;
                3) ;; # all enabled
                *) SKIP_OPENCLAW=1 ;;
            esac
            ;;
        medium)
            echo -e "${CYAN}Recommended for 3-4 GB RAM:${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} Minimal    — Claude Code only"
            echo -e "  ${WHITE}2)${NC} Standard   ${GREEN}(RECOMMENDED)${NC} — Claude + Ollama"
            echo -e "  ${WHITE}3)${NC} Full       — All features + extras"
            echo ""
            read -p "Enter choice (1-3) [default: 2]: " FEAT_CHOICE
            FEAT_CHOICE=${FEAT_CHOICE:-2}
            case "$FEAT_CHOICE" in
                1) SKIP_OLLAMA=1; SKIP_OPENCLAW=1 ;;
                2) ;; # claude + ollama
                3) INSTALL_EXTRAS=1 ;;
                *) ;;
            esac
            ;;
        high|ultra-high)
            echo -e "${GREEN}Recommended for ${TOTAL_RAM_GB}+ GB RAM:${NC}"
            echo ""
            echo -e "  ${WHITE}1)${NC} Minimal    — Claude Code only"
            echo -e "  ${WHITE}2)${NC} Standard   — Claude + Ollama"
            echo -e "  ${WHITE}3)${NC} Full       ${GREEN}(RECOMMENDED)${NC} — All features + extras"
            echo ""
            read -p "Enter choice (1-3) [default: 3]: " FEAT_CHOICE
            FEAT_CHOICE=${FEAT_CHOICE:-3}
            case "$FEAT_CHOICE" in
                1) SKIP_OLLAMA=1; SKIP_OPENCLAW=1 ;;
                2) ;; # claude + ollama
                3) INSTALL_EXTRAS=1 ;;
                *) INSTALL_EXTRAS=1 ;;
            esac
            ;;
    esac
    
    echo ""
    read -p "Press Enter to start installation..."
fi

# ── Installation summary ──────────────────────────────────────────────────
clear
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  Installation Plan${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  RAM:       ${RAM_COLOR}${TOTAL_RAM_MB} MB${NC}"
echo -e "  Desktop:   ${WHITE}${DE}${NC}"
echo -e "  Ollama:    $( [[ $SKIP_OLLAMA -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  Claude:    $( [[ $SKIP_CLAUDE -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  OpenClaw:  $( [[ $SKIP_OPENCLAW -eq 0 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo -e "  Extras:    $( [[ $INSTALL_EXTRAS -eq 1 ]] && echo -e "${GREEN}Yes${NC}" || echo -e "${GRAY}No${NC}" )"
echo ""

# ── Step 1: Termux base ───────────────────────────────────────────────────
info "Step 1/7: Updating Termux packages..."
pkg update -y 2>/dev/null || warn "pkg update warnings"
pkg upgrade -y 2>/dev/null || warn "pkg upgrade warnings"
pkg install -y x11-repo tur-repo 2>/dev/null || warn "repo warnings"
pkg update -y 2>/dev/null

pkg install -y termux-x11-nightly xorg-xrandr pulseaudio git curl wget nodejs npm python openssl which 2>/dev/null || warn "base pkg warnings"
success "Base packages installed"

# ── Step 2: Desktop Environment ───────────────────────────────────────────
info "Step 2/7: Installing ${DE} desktop..."

case "$DE" in
    lxqt)
        pkg install -y lxqt qterminal pcmanfm-qt featherpad 2>/dev/null || warn "LXQt warnings"
        DE_EXEC="startlxqt"
        DE_KILL="pkill -9 lxqt-session 2>/dev/null; pkill -9 openbox 2>/dev/null"
        TERM_CMD="qterminal"
        ;;
    xfce4)
        pkg install -y xfce4 xfce4-terminal xfce4-whiskermenu-plugin thunar mousepad 2>/dev/null || warn "XFCE4 warnings"
        pkg install -y plank-reloaded 2>/dev/null || warn "Plank skipped"
        DE_EXEC="startxfce4"
        DE_KILL="pkill -9 xfce4-session 2>/dev/null; pkill -9 plank 2>/dev/null"
        TERM_CMD="xfce4-terminal"
        ;;
    mate)
        pkg install -y mate mate-terminal mate-tweak 2>/dev/null || warn "MATE warnings"
        pkg install -y plank-reloaded 2>/dev/null || warn "Plank skipped"
        DE_EXEC="mate-session"
        DE_KILL="pkill -9 mate-session 2>/dev/null; pkill -9 plank 2>/dev/null"
        TERM_CMD="mate-terminal"
        ;;
    kde)
        [[ $TOTAL_RAM_MB -lt 4096 ]] && warn "KDE on <4GB RAM may crash!"
        pkg install -y plasma-desktop konsole dolphin 2>/dev/null || die "KDE install failed"
        DE_EXEC="(sleep 5 && pkill -9 plasmashell && plasmashell) > /dev/null 2>&1 &\nexec startplasma-x11"
        DE_KILL="pkill -9 startplasma-x11 2>/dev/null; pkill -9 kwin_x11 2>/dev/null"
        TERM_CMD="konsole"
        ;;
    *) die "Unknown DE: $DE" ;;
esac

success "${DE} installed"

# ── Step 3: GPU acceleration ──────────────────────────────────────────────
info "Step 3/7: Installing GPU acceleration..."
pkg install -y mesa-zink vulkan-loader-android 2>/dev/null || warn "GPU warnings"

GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
if echo "$GPU_VENDOR" | grep -qi "adreno"; then
    pkg install -y mesa-vulkan-icd-freedreno 2>/dev/null || warn "Turnip skipped"
    GPU_DRIVER="freedreno"
    success "Adreno GPU: Turnip enabled"
else
    GPU_DRIVER="zink"
    success "Non-Adreno: Zink enabled"
fi

mkdir -p ~/.config

# KDE needs special XDG injection
if [[ "$DE" == "kde" ]]; then
    mkdir -p ~/.config/plasma-workspace/env
    cat > ~/.config/plasma-workspace/env/xdg_fix.sh << 'KDEEOF'
#!/data/data/com.termux/files/usr/bin/bash
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}
KDEEOF
    chmod +x ~/.config/plasma-workspace/env/xdg_fix.sh
fi

cat > ~/.config/linux-gpu.sh << 'GPUEOF'
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS:-}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS:-}
GPUEOF

if [[ "$DE" == "kde" ]]; then
    echo "export KWIN_COMPOSE=O2ES" >> ~/.config/linux-gpu.sh
else
    cat >> ~/.config/linux-gpu.sh << 'XDGEOF'
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS:-}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS:-}
XDGEOF
fi

# ── Step 4: Ollama ────────────────────────────────────────────────────────
if [[ $SKIP_OLLAMA -eq 0 ]]; then
    info "Step 4/7: Installing Ollama..."
    pkg install -y ollama 2>/dev/null || warn "Ollama pkg failed"
    if ! command -v ollama &>/dev/null; then
        curl -fsSL https://ollama.com/install.sh | sh 2>/dev/null || warn "Ollama manual install failed"
    fi
    if command -v ollama &>/dev/null; then
        success "Ollama installed"
    fi
else
    info "Step 4/7: Ollama skipped"
fi

# ── Step 5: Claude Code ───────────────────────────────────────────────────
if [[ $SKIP_CLAUDE -eq 0 ]]; then
    info "Step 5/7: Installing Claude Code..."
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
    info "Step 5/7: Claude skipped"
fi

# ── Step 6: OpenClaw ──────────────────────────────────────────────────────
if [[ $SKIP_OPENCLAW -eq 0 ]]; then
    info "Step 6/7: Installing OpenClaw..."
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
    info "Step 6/7: OpenClaw skipped"
fi

# ── Step 6.5: Extras (Firefox, VLC, Wine) ─────────────────────────────────
if [[ $INSTALL_EXTRAS -eq 1 ]]; then
    info "Installing extras (Firefox, VLC, Wine)..."
    pkg install -y firefox vlc 2>/dev/null || warn "Firefox/VLC warnings"
    pkg remove wine-stable -y 2>/dev/null || true
    pkg install -y hangover-wine hangover-wowbox64 2>/dev/null || warn "Wine skipped"

    # Create Wine symlinks
    if command -v wine &>/dev/null; then
        ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/wine /data/data/com.termux/files/usr/bin/wine 2>/dev/null || true
        ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/winecfg /data/data/com.termux/files/usr/bin/winecfg 2>/dev/null || true
    fi
    success "Extras installed"
fi

# ── Step 7: Desktop shortcuts ────────────────────────────────────────
if [[ $INSTALL_EXTRAS -eq 1 && $SKIP_DESKTOP -eq 0 ]]; then
    info "Creating desktop shortcuts..."
    mkdir -p ~/Desktop
    
    # Firefox
    cat > ~/Desktop/Firefox.desktop << 'FFEOF'
[Desktop Entry]
Name=Firefox
Exec=firefox
Icon=firefox
Type=Application
FFEOF
    
    # VLC
    cat > ~/Desktop/VLC.desktop << 'VLCEOF'
[Desktop Entry]
Name=VLC Media Player
Exec=vlc
Icon=vlc
Type=Application
VLCEOF
    
    # Wine Config
    if command -v wine &>/dev/null; then
        cat > ~/Desktop/Wine_Config.desktop << 'WINEEOF'
[Desktop Entry]
Name=Wine Config (Windows)
Exec=wine winecfg
Icon=wine
Type=Application
WINEEOF
    fi
    
    # Terminal (dynamic per DE)
    cat > ~/Desktop/Terminal.desktop << TERMEOF
[Desktop Entry]
Name=Terminal
Exec=${TERM_CMD}
Icon=utilities-terminal
Type=Application
TERMEOF
    
    chmod +x ~/Desktop/*.desktop 2>/dev/null
    success "Desktop shortcuts created"
fi

# ── Step 8: Plank autostart (XFCE/MATE) ───────────────────────────────
if [[ $SKIP_DESKTOP -eq 0 && ( "$DE" == "xfce4" || "$DE" == "mate" ) ]]; then
    info "Configuring Plank dock autostart..."
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/plank.desktop << 'PLANKEOF'
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
PLANKEOF
    success "Plank autostart configured"
else
    rm -f ~/.config/autostart/plank.desktop 2>/dev/null || true
fi


# ── Step 7: Write start/stop scripts ──────────────────────────────────────
info "Step 9/9: Writing start-linux.sh and stop-linux.sh..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat > "${SCRIPT_DIR}/start-linux.sh" << STARTEOF
#!/data/data/com.termux/files/usr/bin/bash
# Generated by setup.sh | DE: ${DE}

DISPLAY_NUM="${DISPLAY_NUM}"
die()  { echo "❌ \$*" >&2; exit 1; }
info() { echo "ℹ️  \$*"; }

for cmd in termux-x11 pulseaudio ${DE_EXEC%% *}; do
    command -v "\$cmd" &>/dev/null || die "Missing: \$cmd"
done

info "Cleaning up previous session..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "termux-x11" 2>/dev/null
${DE_KILL}
pkill -9 -f "dbus-daemon" 2>/dev/null
sleep 1

rm -f /tmp/.X\${DISPLAY_NUM#:}-lock
rm -f /tmp/.X11-unix/X\${DISPLAY_NUM#:}

info "Starting audio..."
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null; sleep 0.5
pulseaudio --start --exit-idle-time=-1 2>/dev/null
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null || true
export PULSE_SERVER="127.0.0.1"

source ~/.config/linux-gpu.sh 2>/dev/null || true

info "Starting X11 display \${DISPLAY_NUM}..."
termux-x11 "\${DISPLAY_NUM}" -ac &
X11_PID=\$!
sleep 3

kill -0 "\$X11_PID" 2>/dev/null || die "termux-x11 failed. Open Termux:X11 app first."

export DISPLAY="\${DISPLAY_NUM}"
grep -q "^export DISPLAY=" ~/.bashrc 2>/dev/null && sed -i "s|^export DISPLAY=.*|export DISPLAY=\${DISPLAY_NUM}|" ~/.bashrc || echo "export DISPLAY=\${DISPLAY_NUM}" >> ~/.bashrc

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Open Termux:X11 app to see your desktop!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec ${DE_EXEC}
STARTEOF

chmod +x "${SCRIPT_DIR}/start-linux.sh"
success "start-linux.sh written"

cat > "${SCRIPT_DIR}/stop-linux.sh" << STOPEOF
#!/data/data/com.termux/files/usr/bin/bash

DISPLAY_NUM="${DISPLAY_NUM}"
info() { echo "ℹ️  \$*"; }

info "Stopping desktop..."
${DE_KILL}
sleep 1

info "Stopping X11..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "termux-x11" 2>/dev/null
pkill -9 -f "dbus-daemon" 2>/dev/null
sleep 1

info "Stopping audio..."
pulseaudio --kill 2>/dev/null

info "Removing X11 locks..."
rm -f /tmp/.X\${DISPLAY_NUM#:}-lock
rm -f /tmp/.X11-unix/X\${DISPLAY_NUM#:}

echo ""
echo "✅ Stopped. Run ./start-linux.sh to restart."
STOPEOF

chmod +x "${SCRIPT_DIR}/stop-linux.sh"
success "stop-linux.sh written"

# ── Final summary ─────────────────────────────────────────────────────────
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  🎉 SETUP COMPLETE!${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${WHITE}Desktop:${NC}  ${DE}"
echo -e "  ${WHITE}RAM:${NC}      ${TOTAL_RAM_MB} MB"
echo -e "  ${WHITE}GPU:${NC}      ${GPU_DRIVER}"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo -e "  ${WHITE}./start-linux.sh${NC}  — Launch desktop"
echo -e "  ${WHITE}./stop-linux.sh${NC}   — Stop desktop"
echo ""

if [[ $SKIP_OLLAMA -eq 0 ]]; then
    echo -e "${CYAN}Ollama:${NC}"
    echo -e "  ${WHITE}ollama serve &${NC}"
    case "$RAM_TIER" in
        low)       echo -e "  ${WHITE}ollama pull tinyllama${NC}  ${GRAY}(best for 2-3 GB)${NC}" ;;
        medium)    echo -e "  ${WHITE}ollama pull phi3:mini${NC}  ${GRAY}(best for 3-4 GB)${NC}" ;;
        *)         echo -e "  ${WHITE}ollama pull nemotron-mini${NC}  ${GRAY}(best for 4+ GB)${NC}" ;;
    esac
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
    echo ""
fi

echo -e "  ${WHITE}source ~/.bashrc${NC}"
echo ""
