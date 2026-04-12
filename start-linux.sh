#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🚀 start-linux.sh — Start Linux (proot-distro) with Termux X11
# =========================================================================
# Fixes: X11 display not re-appearing after stop-linux.sh
# Usage: ./start-linux.sh [distro]   default distro: ubuntu
# =========================================================================

DISTRO="${1:-ubuntu}"
DISPLAY_NUM=":1"
PULSE_PORT=4713

# ── Helpers ───────────────────────────────────────────────────────────────
die() { echo "❌ $*" >&2; exit 1; }
info() { echo "ℹ️  $*"; }

# ── Verify dependencies ───────────────────────────────────────────────────
for cmd in proot-distro termux-x11 pulseaudio; do
    command -v "$cmd" &>/dev/null || die "Missing: $cmd — run: pkg install $cmd"
done

# ── Kill any stale X11 / lock files from previous session ─────────────────
info "Cleaning up previous X11 session..."
pkill -f "termux-x11" 2>/dev/null
pkill -f "Xwayland"   2>/dev/null
pkill -f "Xvfb"       2>/dev/null
sleep 1

# Remove stale X11 lock/socket files so X can bind cleanly
rm -f /tmp/.X${DISPLAY_NUM#:}-lock
rm -f /tmp/.X11-unix/X${DISPLAY_NUM#:}

# ── Start PulseAudio ──────────────────────────────────────────────────────
info "Starting PulseAudio..."
pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1 2>/dev/null
export PULSE_SERVER="tcp:127.0.0.1:${PULSE_PORT}"

# ── Start Termux X11 ──────────────────────────────────────────────────────
info "Starting Termux X11 display ${DISPLAY_NUM}..."
termux-x11 "${DISPLAY_NUM}" &
X11_PID=$!
sleep 2

# Verify X11 actually started
if ! kill -0 "$X11_PID" 2>/dev/null; then
    die "termux-x11 failed to start. Check Termux:X11 app is installed and open."
fi

export DISPLAY="${DISPLAY_NUM}"
info "DISPLAY=${DISPLAY} ✅"

# ── Persist DISPLAY for this shell and proot sessions ─────────────────────
grep -q "^export DISPLAY=" ~/.bashrc 2>/dev/null && \
    sed -i "s|^export DISPLAY=.*|export DISPLAY=${DISPLAY_NUM}|" ~/.bashrc || \
    echo "export DISPLAY=${DISPLAY_NUM}" >> ~/.bashrc

# ── Launch Linux via proot-distro ─────────────────────────────────────────
info "Launching ${DISTRO} via proot-distro..."
proot-distro login "$DISTRO" --shared-tmp -- /bin/bash -c "
    export DISPLAY=${DISPLAY_NUM}
    export PULSE_SERVER=tcp:127.0.0.1:${PULSE_PORT}
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p \$XDG_RUNTIME_DIR && chmod 700 \$XDG_RUNTIME_DIR

    # Start a desktop environment if available, else open a terminal
    if command -v startxfce4 &>/dev/null; then
        startxfce4 &
    elif command -v openbox &>/dev/null; then
        openbox-session &
    elif command -v xterm &>/dev/null; then
        xterm &
    fi

    exec bash --login
"
