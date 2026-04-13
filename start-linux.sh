#!/usr/bin/env bash
# =========================================================================
# 🚀 start-linux.sh — Start Linux desktop with X11
# =========================================================================
# Runs on desktop Linux and Termux (proot)
# Compatible with: XFCE, LXQt, MATE, KDE
# =========================================================================

# Detect if running in Termux
if [[ -d "/data/data/com.termux/files/usr" ]]; then
    IS_TERMUX=1
    TERMUX_PREFIX="/data/data/com.termux/files/usr"
else
    IS_TERMUX=0
    TERMUX_PREFIX=""
fi

DISPLAY_NUM=":0"

die()  { echo "❌ $*" >&2; exit 1; }
info() { echo "ℹ️  $*"; }
warn() { echo "⚠️  $*"; }

# ── Auto-detect installed desktop environment ─────────────────────────────
# Prefer xfce4-session for proper session handling, fallback to startxfce4
if   command -v xfce4-session &>/dev/null; then 
    DE_EXEC="xfce4-session" 
    DE_KILL="pkill -9 xfce4-session; pkill -9 plank"
elif command -v startxfce4    &>/dev/null; then 
    DE_EXEC="startxfce4" 
    DE_KILL="pkill -9 xfce4-session; pkill -9 plank"
elif command -v startlxqt     &>/dev/null; then DE_EXEC="startlxqt";       DE_KILL="pkill -9 lxqt-session; pkill -9 openbox"
elif command -v mate-session  &>/dev/null; then DE_EXEC="mate-session";    DE_KILL="pkill -9 mate-session"
elif command -v startplasma-x11 &>/dev/null; then DE_EXEC="startplasma-x11"; DE_KILL="pkill -9 startplasma-x11; pkill -9 kwin_x11"
elif command -v openbox       &>/dev/null; then DE_EXEC="openbox-session"; DE_KILL="pkill -9 openbox"
elif command -v xterm         &>/dev/null; then DE_EXEC="xterm";           DE_KILL="pkill -9 xterm"
else
    die "No desktop environment found. Run: bash setup.sh"
fi

info "Desktop: ${DE_EXEC}"

# ── Dependency check ──────────────────────────────────────────────────────
if [[ $IS_TERMUX -eq 1 ]]; then
    command -v termux-x11  &>/dev/null || die "termux-x11 not found. Run: pkg install termux-x11-nightly"
    command -v pulseaudio  &>/dev/null || die "pulseaudio not found. Run: pkg install pulseaudio"
fi

# ── Clean up stale session ────────────────────────────────────────────────
info "Cleaning up previous session..."
pkill -9 -f "termux.x11"  2>/dev/null
pkill -9 -f "termux-x11"  2>/dev/null
eval "$DE_KILL"            2>/dev/null
sleep 1

# Ensure XDG directories exist for XFCE
if [[ "${DE_EXEC}" == "xfce4-session" ]]; then
    export XDG_SESSION_TYPE="x11"
    export XDG_SESSION_CLASS="user"
    export XDG_CURRENT_DESKTOP="XFCE"
    export XDG_SESSION_DESKTOP="xfce"
    export DESKTOP_SESSION="xfce"
fi

# Remove stale X11 lock/socket files — this is the root cause of re-display failure
rm -f "/tmp/.X${DISPLAY_NUM#:}-lock"
rm -f "/tmp/.X11-unix/X${DISPLAY_NUM#:}"

# ── PulseAudio ────────────────────────────────────────────────────────────
info "Starting audio..."
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
pulseaudio --start --exit-idle-time=-1 2>/dev/null
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null || true
export PULSE_SERVER="127.0.0.1"

# ── GPU environment ───────────────────────────────────────────────────────
# shellcheck source=/dev/null
source ~/.config/linux-gpu.sh 2>/dev/null || true
# Fallback GPU vars if linux-gpu.sh missing (e.g. manual install)
export MESA_NO_ERROR="${MESA_NO_ERROR:-1}"

# Set XDG paths conditionally based on environment
if [[ $IS_TERMUX -eq 1 ]]; then
    export XDG_DATA_DIRS="/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS:-}"
    export XDG_CONFIG_DIRS="/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS:-}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/data/data/com.termux/files/usr/tmp/runtime-$(id -u)}"
else
    export XDG_DATA_DIRS="/usr/share:${XDG_DATA_DIRS:-}"
    export XDG_CONFIG_DIRS="/etc/xdg:${XDG_CONFIG_DIRS:-}"
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"
fi

mkdir -p "${XDG_RUNTIME_DIR}" 2>/dev/null || true
chmod 700 "${XDG_RUNTIME_DIR}" 2>/dev/null || true

if [[ "${GALLIUM_DRIVER:-}" == "zink" ]]; then
    if ! command -v vulkaninfo &>/dev/null || ! vulkaninfo --summary >/dev/null 2>&1; then
        warn "Vulkan unavailable; disabling zink and falling back to software rendering"
        unset GALLIUM_DRIVER MESA_LOADER_DRIVER_OVERRIDE ZINK_DESCRIPTORS TU_DEBUG MESA_VK_WSI_PRESENT_MODE
        export LIBGL_ALWAYS_SOFTWARE=1
    fi
fi

# ── Start X11 ───────────────────────────────────────────────────────────
if [[ $IS_TERMUX -eq 1 ]]; then
    # Start Termux X11 in background
    info "Starting X11 display ${DISPLAY_NUM}..."
    termux-x11 "${DISPLAY_NUM}" -ac &
    X11_PID=$!
    sleep 3
    
    kill -0 "$X11_PID" 2>/dev/null || die "termux-x11 failed to start. Open the Termux:X11 app first, then retry."
    
    # Best-effort: foreground Termux:X11 app to complete connection
    am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
fi

# Wait for X socket availability before launching DE
info "Waiting for X server to be ready..."
for i in 1 2 3 4 5 6 7 8 9 10; do
    if [[ -S "/tmp/.X11-unix/X${DISPLAY_NUM#:}" ]]; then
        # Verify X is responding
        if command -v xdpyinfo &>/dev/null; then
            xdpyinfo -display "${DISPLAY_NUM}" >/dev/null 2>&1 && break
        else
            # If xdpyinfo not available, just check socket age
            [[ -S "/tmp/.X11-unix/X${DISPLAY_NUM#:}" ]] && sleep 1 && break
        fi
    fi
    sleep 1
done

# Final verification
if [[ -S "/tmp/.X11-unix/X${DISPLAY_NUM#:}" ]]; then
    info "X server is ready on ${DISPLAY_NUM}"
else
    warn "X socket not found - starting without X11, will use existing display if available"
fi

export DISPLAY="${DISPLAY_NUM}"

# Persist DISPLAY in bashrc so proot/subshells inherit it
grep -q "^export DISPLAY=" ~/.bashrc 2>/dev/null && \
    sed -i "s|^export DISPLAY=.*|export DISPLAY=${DISPLAY_NUM}|" ~/.bashrc || \
    echo "export DISPLAY=${DISPLAY_NUM}" >> ~/.bashrc

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Open the Termux:X11 app to see your desktop!"
echo "  DE: ${DE_EXEC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Launch desktop ────────────────────────────────────────────────────────
info "Launching desktop environment: ${DE_EXEC}"

# Force software rendering for better compatibility on mobile/devices
export GALLIUM_DRIVER="llvmpipe" 2>/dev/null || true
export LIBGL_ALWAYS_SOFTWARE=1 2>/dev/null || true
export MESA_NO_ERROR=1

# For XFCE, try multiple launch methods
if [[ "${DE_EXEC}" == "xfce4-session" || "${DE_EXEC}" == "startxfce4" ]]; then
    # Try starting with xfwm4 directly if session manager fails
    if ! command -v xfwm4 &>/dev/null; then
        warn "xfwm4 not found, XFCE may not display correctly"
    fi
    
    # Start xfce4-panel in background if it doesn't start automatically
    (sleep 5; pgrep -x xfce4-panel >/dev/null || xfce4-panel --daemon 2>/dev/null) &
    
    # Start desktop manager if not running
    (sleep 3; pgrep -x xfdesktop >/dev/null || xfdesktop 2>/dev/null) &
fi

# Start DBus if available
if command -v dbus-launch &>/dev/null; then
    eval "$(dbus-launch --sh-syntax --exit-with-session 2>/dev/null)" || true
fi

# Launch the desktop environment
exec ${DE_EXEC}

# If exec fails (shouldn't happen), try fallback
warn "Desktop launch completed, but may have exited early"

# Final fallback: start xterm at minimum
if command -v xterm &>/dev/null; then
    info "Starting fallback terminal..."
    exec xterm
fi
