#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🚀 start-linux.sh — Start native Termux Linux desktop with X11
# =========================================================================
# Runs NATIVELY in Termux — no proot-distro required.
# Compatible with: termux-linux-setup (github.com/orailnoor/termux-linux-setup)
# Fixes: X11 not re-displaying after stop-linux.sh
# =========================================================================

DISPLAY_NUM=":0"

die()  { echo "❌ $*" >&2; exit 1; }
info() { echo "ℹ️  $*"; }
warn() { echo "⚠️  $*"; }

# ── Auto-detect installed desktop environment ─────────────────────────────
if   command -v xfce4-session &>/dev/null; then DE_EXEC="xfce4-session";   DE_KILL="pkill -9 xfce4-session; pkill -9 plank"
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
command -v termux-x11  &>/dev/null || die "termux-x11 not found. Run: pkg install termux-x11-nightly"
command -v pulseaudio  &>/dev/null || die "pulseaudio not found. Run: pkg install pulseaudio"

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

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/data/data/com.termux/files/usr/tmp/runtime-$(id -u)}"
mkdir -p "${XDG_RUNTIME_DIR}" 2>/dev/null || true
chmod 700 "${XDG_RUNTIME_DIR}" 2>/dev/null || true

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
export XDG_DATA_DIRS="/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS:-}"
export XDG_CONFIG_DIRS="/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS:-}"

if [[ "${GALLIUM_DRIVER:-}" == "zink" ]]; then
    if ! command -v vulkaninfo &>/dev/null || ! vulkaninfo --summary >/dev/null 2>&1; then
        warn "Vulkan unavailable; disabling zink and falling back to software rendering"
        unset GALLIUM_DRIVER MESA_LOADER_DRIVER_OVERRIDE ZINK_DESCRIPTORS TU_DEBUG MESA_VK_WSI_PRESENT_MODE
        export LIBGL_ALWAYS_SOFTWARE=1
    fi
fi

# ── Start Termux X11 ──────────────────────────────────────────────────────
info "Starting X11 display ${DISPLAY_NUM}..."
termux-x11 "${DISPLAY_NUM}" -ac &
X11_PID=$!
sleep 3

kill -0 "$X11_PID" 2>/dev/null || die "termux-x11 failed to start. Open the Termux:X11 app first, then retry."

# Best-effort: foreground Termux:X11 app to complete connection
am start -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true

# Wait for X socket availability before launching DE
for _ in 1 2 3 4 5; do
    [[ -S "/tmp/.X11-unix/X${DISPLAY_NUM#:}" ]] && break
    sleep 1
done

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
if command -v dbus-launch &>/dev/null; then
    eval "$(dbus-launch --sh-syntax --exit-with-session 2>/dev/null)"
fi

exec ${DE_EXEC}
