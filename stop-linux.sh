#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🛑 stop-linux.sh — Stop Termux desktop and clean X11 locks
# =========================================================================
# Always removes stale X11 lock files so start-linux.sh can re-display.
# =========================================================================

DISPLAY_NUM=":0"

info() { echo "ℹ️  $*"; }

info "Stopping desktop environment..."
pkill -9 xfce4-session   2>/dev/null
pkill -9 lxqt-session    2>/dev/null
pkill -9 mate-session    2>/dev/null
pkill -9 startplasma-x11 2>/dev/null
pkill -9 kwin_x11        2>/dev/null
pkill -9 openbox         2>/dev/null
pkill -9 plank           2>/dev/null
sleep 1

info "Stopping X11..."
# Note: process name is "termux.x11" (dot), not "termux-x11" (dash)
pkill -9 -f "termux.x11"  2>/dev/null
pkill -9 -f "termux-x11"  2>/dev/null
pkill -9 -f "dbus-daemon"  2>/dev/null
sleep 1

info "Stopping audio..."
pulseaudio --kill 2>/dev/null

# ── Remove stale X11 lock/socket files ────────────────────────────────────
# Critical: without this, X11 refuses to bind on next start-linux.sh call
info "Removing X11 lock files..."
rm -f "/tmp/.X${DISPLAY_NUM#:}-lock"
rm -f "/tmp/.X11-unix/X${DISPLAY_NUM#:}"

echo ""
echo "✅ Stopped cleanly. Run ./start-linux.sh to restart."
