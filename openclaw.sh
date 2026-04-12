#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 🤖 OpenClaw Termux Installer
# =========================================================================
# Usage: curl -sL <url> | bash
# Runs natively in Termux. No proot, no Shizuku required.
# =========================================================================

export LANG=C
export LC_ALL=C

echo ""
echo "🤖 OpenClaw Termux Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ── Step 1/3: Update & install dependencies ───────────────────────────────
echo "📦 Step 1/3: Updating packages and installing dependencies..."

# Termux uses pkg, not apt — no Dpkg::Options flags
pkg update -y 2>/dev/null || echo "⚠️  pkg update had warnings (continuing...)"
pkg upgrade -y 2>/dev/null || echo "⚠️  pkg upgrade had warnings (continuing...)"

pkg install -y curl nodejs npm git cmake make clang binutils openssl which 2>/dev/null || \
    echo "⚠️  Some packages may have failed, checking essentials..."

# Verify essentials
MISSING=""
for cmd in curl node git; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING="$MISSING $cmd"
done

if [ -n "$MISSING" ]; then
    echo "❌ ERROR: Missing critical commands:$MISSING"
    exit 1
fi

echo "✅ Dependencies installed"

# ── Step 2/3: Fix Node.js IPv4 DNS (critical for Termux) ─────────────────
echo ""
echo "🔧 Step 2/3: Applying network fixes..."

if ! grep -q "NODE_OPTIONS" ~/.bashrc 2>/dev/null; then
    echo 'export NODE_OPTIONS="--dns-result-order=ipv4first"' >> ~/.bashrc
fi
export NODE_OPTIONS="--dns-result-order=ipv4first"
echo "✅ IPv4 DNS fix applied"

# ── Step 3/3: Install OpenClaw ────────────────────────────────────────────
echo ""

if command -v openclaw &>/dev/null || [ -d "$HOME/.openclaw/repo" ]; then
    echo "✅ Step 3/3: OpenClaw is already installed!"
else
    echo "📦 Step 3/3: Installing OpenClaw. This may take a moment..."
    INSTALL_SCRIPT="$(curl -sSL https://myopenclawhub.com/install)" || {
        echo "❌ Failed to fetch OpenClaw installer"
        exit 1
    }
    bash -c "$INSTALL_SCRIPT" < /dev/tty
    # shellcheck source=/dev/null
    source ~/.bashrc 2>/dev/null
fi

# ── Done ──────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 INSTALLATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "  1. source ~/.bashrc"
echo "  2. openclaw onboard"
echo "  3. openclaw gateway"
echo "  Dashboard: http://127.0.0.1:18789"
echo ""
