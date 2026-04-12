#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🛑 stop-linux.sh — Stop Linux session and clean up X11/PulseAudio
# =========================================================================
# Ensures no stale locks remain so start-linux.sh can re-display on X11
# =========================================================================

DISPLAY_NUM=":1"

info() { echo "ℹ️  $*"; }

info "Stopping proot-distro sessions..."
pkill -f "proot-distro login" 2>/dev/null
pkill -f "proot"              2>/dev/null
sleep 1

info "Stopping desktop environment processes..."
pkill -f "startxfce4"  2>/dev/null
pkill -f "xfce4-session" 2>/dev/null
pkill -f "openbox"     2>/dev/null
pkill -f "xterm"       2>/dev/null
sleep 1

info "Stopping Termux X11..."
pkill -f "termux-x11"  2>/dev/null
pkill -f "Xwayland"    2>/dev/null
sleep 1

info "Stopping PulseAudio..."
pulseaudio --kill 2>/dev/null

# ── Remove stale X11 lock/socket files ────────────────────────────────────
# This is the critical step — without this, X11 refuses to bind on restart
info "Removing stale X11 lock files..."
rm -f /tmp/.X${DISPLAY_NUM#:}-lock
rm -f /tmp/.X11-unix/X${DISPLAY_NUM#:}

echo ""
echo "✅ Linux session stopped cleanly."
echo "   Run ./start-linux.sh to restart."
