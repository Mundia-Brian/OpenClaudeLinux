#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 📱 OpenClaw Telegram Bot Setup
# =========================================================================
# Configures OpenClaw for Telegram remote control
# =========================================================================

echo ""
echo "📱 OpenClaw Telegram Bot Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if OpenClaw is installed
if ! command -v openclaw &>/dev/null && [[ ! -d "$HOME/.openclaw/repo" ]]; then
    echo "❌ OpenClaw is not installed. Run setup.sh first."
    exit 1
fi

# Get Bot Token
echo "Step 1/3: Get your Telegram Bot Token"
echo ""
echo "To create a bot:"
echo "  1. Open Telegram and search for @BotFather"
echo "  2. Send /newbot and follow the prompts"
echo "  3. Copy your Bot Token (format: 123456:ABC-DEF...)"
echo ""
read -p "Enter your Bot Token: " BOT_TOKEN

if [[ -z "$BOT_TOKEN" ]]; then
    echo "❌ Bot Token cannot be empty"
    exit 1
fi

# Get User ID
echo ""
echo "Step 2/3: Get your Telegram User ID"
echo ""
echo "To find your User ID:"
echo "  1. Send any message to your bot"
echo "  2. Visit: https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"
echo "  3. Find your 'id' in the response"
echo ""
read -p "Enter your Telegram User ID: " USER_ID

if [[ -z "$USER_ID" ]]; then
    echo "❌ User ID cannot be empty"
    exit 1
fi

# Configure OpenClaw
echo ""
echo "Step 3/3: Configuring OpenClaw..."
echo ""

OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"

if [[ ! -f "$OPENCLAW_CONFIG" ]]; then
    echo "❌ OpenClaw config not found. Run 'openclaw onboard' first."
    exit 1
fi

# Backup existing config
cp "$OPENCLAW_CONFIG" "${OPENCLAW_CONFIG}.backup"

# Update config with Telegram settings
# This is a simplified approach - adjust based on actual OpenClaw config structure
cat > "$OPENCLAW_CONFIG" << EOF
{
  "telegram": {
    "bot_token": "${BOT_TOKEN}",
    "user_id": "${USER_ID}",
    "enabled": true
  }
}
EOF

echo "✅ Telegram bot configured!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Next steps:"
echo "  1. openclaw gateway"
echo "  2. Send /start to your bot in Telegram"
echo ""
echo "Your config backup: ${OPENCLAW_CONFIG}.backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
