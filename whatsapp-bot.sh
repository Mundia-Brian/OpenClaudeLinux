#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 📱 OpenClaw WhatsApp Bot Setup
# =========================================================================
# Configures OpenClaw for WhatsApp remote control
# Supports both desktop (distro) and mobile usage
# =========================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
die()     { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

clear
echo ""
echo -e "${CYAN}📱 OpenClaw WhatsApp Bot Setup${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if OpenClaw is installed
if ! command -v openclaw &>/dev/null && [[ ! -d "$HOME/.openclaw/repo" ]]; then
    die "OpenClaw is not installed. Run setup.sh first."
fi

# Determine usage mode
echo -e "${WHITE}Step 1/4: Choose Usage Mode${NC}"
echo ""
echo "How will you use OpenClaw with WhatsApp?"
echo ""
echo -e "  ${WHITE}1)${NC} Desktop/Distro  — Running on Linux desktop (XFCE/KDE/etc)"
echo -e "  ${WHITE}2)${NC} Mobile          — Running directly in Termux (no desktop)"
echo ""
read -p "Enter choice (1-2) [default: 2]: " MODE_CHOICE
MODE_CHOICE=${MODE_CHOICE:-2}

case "$MODE_CHOICE" in
    1) USAGE_MODE="desktop" ;;
    2) USAGE_MODE="mobile" ;;
    *) warn "Invalid choice, defaulting to mobile"; USAGE_MODE="mobile" ;;
esac

success "Selected: ${USAGE_MODE} mode"
echo ""

# Choose WhatsApp library
echo -e "${WHITE}Step 2/4: Choose WhatsApp Library${NC}"
echo ""
echo "Select WhatsApp integration method:"
echo ""
echo -e "  ${WHITE}1)${NC} whatsapp-web.js  ${GREEN}(RECOMMENDED)${NC} — Full-featured, stable"
echo -e "  ${WHITE}2)${NC} Baileys          — Lightweight, multi-device"
echo -e "  ${WHITE}3)${NC} venom-bot        — Easy setup, QR code"
echo ""
read -p "Enter choice (1-3) [default: 1]: " LIB_CHOICE
LIB_CHOICE=${LIB_CHOICE:-1}

case "$LIB_CHOICE" in
    1) WA_LIB="whatsapp-web.js" ;;
    2) WA_LIB="baileys" ;;
    3) WA_LIB="venom-bot" ;;
    *) warn "Invalid choice, defaulting to whatsapp-web.js"; WA_LIB="whatsapp-web.js" ;;
esac

success "Selected: ${WA_LIB}"
echo ""

# Install dependencies
echo -e "${WHITE}Step 3/4: Installing Dependencies${NC}"
echo ""

info "Checking Node.js..."
if ! command -v node &>/dev/null; then
    die "Node.js not found. Run setup.sh first."
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [[ $NODE_VERSION -lt 16 ]]; then
    warn "Node.js version $NODE_VERSION detected. Recommended: 16+"
fi

# Install WhatsApp library
info "Installing ${WA_LIB}..."

case "$WA_LIB" in
    whatsapp-web.js)
        npm install -g whatsapp-web.js qrcode-terminal 2>/dev/null || die "Failed to install whatsapp-web.js"
        ;;
    baileys)
        npm install -g @whiskeysockets/baileys qrcode-terminal 2>/dev/null || die "Failed to install Baileys"
        ;;
    venom-bot)
        npm install -g venom-bot 2>/dev/null || die "Failed to install venom-bot"
        ;;
esac

success "${WA_LIB} installed"

# Install additional dependencies based on mode
if [[ "$USAGE_MODE" == "desktop" ]]; then
    info "Installing desktop dependencies..."
    pkg install -y chromium 2>/dev/null || warn "Chromium install failed (optional)"
fi

echo ""

# Create WhatsApp bot script
echo -e "${WHITE}Step 4/4: Creating WhatsApp Bot Script${NC}"
echo ""

OPENCLAW_DIR="$HOME/.openclaw"
WA_BOT_DIR="$OPENCLAW_DIR/whatsapp-bot"
mkdir -p "$WA_BOT_DIR"

# Create bot script based on library choice
case "$WA_LIB" in
    whatsapp-web.js)
        cat > "$WA_BOT_DIR/bot.js" << 'WAEOF'
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const { exec } = require('child_process');

console.log('🤖 OpenClaw WhatsApp Bot Starting...');

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--disable-gpu'
        ]
    }
});

client.on('qr', (qr) => {
    console.log('📱 Scan this QR code with WhatsApp:');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('✅ WhatsApp Bot is ready!');
    console.log('📱 Send commands to your WhatsApp number');
});

client.on('message', async (msg) => {
    const command = msg.body.toLowerCase().trim();
    
    // OpenClaw commands
    if (command.startsWith('/openclaw')) {
        const args = command.split(' ').slice(1).join(' ');
        exec(`openclaw ${args}`, (error, stdout, stderr) => {
            if (error) {
                msg.reply(`❌ Error: ${error.message}`);
                return;
            }
            msg.reply(`✅ Output:\n${stdout || stderr}`);
        });
    }
    
    // System commands
    else if (command === '/status') {
        exec('uptime && free -h', (error, stdout) => {
            msg.reply(`📊 System Status:\n${stdout}`);
        });
    }
    
    else if (command === '/help') {
        msg.reply(`🤖 OpenClaw WhatsApp Bot Commands:

/openclaw <command> - Run OpenClaw command
/status - System status
/help - Show this help

Examples:
/openclaw gateway
/openclaw onboard
/status`);
    }
});

client.on('authenticated', () => {
    console.log('✅ Authenticated successfully');
});

client.on('auth_failure', () => {
    console.error('❌ Authentication failed');
});

client.initialize();
WAEOF
        ;;
        
    baileys)
        cat > "$WA_BOT_DIR/bot.js" << 'BAILEYEOF'
const { default: makeWASocket, DisconnectReason, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const { exec } = require('child_process');

console.log('🤖 OpenClaw WhatsApp Bot Starting (Baileys)...');

async function startBot() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info');
    
    const sock = makeWASocket({
        auth: state,
        printQRInTerminal: true
    });
    
    sock.ev.on('creds.update', saveCreds);
    
    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect } = update;
        if (connection === 'close') {
            const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
            if (shouldReconnect) {
                startBot();
            }
        } else if (connection === 'open') {
            console.log('✅ WhatsApp Bot is ready!');
        }
    });
    
    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || msg.key.fromMe) return;
        
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text || '';
        const command = text.toLowerCase().trim();
        
        if (command.startsWith('/openclaw')) {
            const args = command.split(' ').slice(1).join(' ');
            exec(`openclaw ${args}`, async (error, stdout, stderr) => {
                const response = error ? `❌ Error: ${error.message}` : `✅ Output:\n${stdout || stderr}`;
                await sock.sendMessage(msg.key.remoteJid, { text: response });
            });
        }
        else if (command === '/status') {
            exec('uptime && free -h', async (error, stdout) => {
                await sock.sendMessage(msg.key.remoteJid, { text: `📊 System Status:\n${stdout}` });
            });
        }
        else if (command === '/help') {
            await sock.sendMessage(msg.key.remoteJid, { 
                text: `🤖 OpenClaw WhatsApp Bot Commands:

/openclaw <command> - Run OpenClaw command
/status - System status
/help - Show this help` 
            });
        }
    });
}

startBot();
BAILEYEOF
        ;;
        
    venom-bot)
        cat > "$WA_BOT_DIR/bot.js" << 'VENOMEOF'
const venom = require('venom-bot');
const { exec } = require('child_process');

console.log('🤖 OpenClaw WhatsApp Bot Starting (Venom)...');

venom
    .create({
        session: 'openclaw-session',
        multidevice: true,
        headless: true
    })
    .then((client) => start(client))
    .catch((error) => console.error('❌ Error:', error));

function start(client) {
    console.log('✅ WhatsApp Bot is ready!');
    
    client.onMessage(async (message) => {
        const command = message.body.toLowerCase().trim();
        
        if (command.startsWith('/openclaw')) {
            const args = command.split(' ').slice(1).join(' ');
            exec(`openclaw ${args}`, async (error, stdout, stderr) => {
                const response = error ? `❌ Error: ${error.message}` : `✅ Output:\n${stdout || stderr}`;
                await client.sendText(message.from, response);
            });
        }
        else if (command === '/status') {
            exec('uptime && free -h', async (error, stdout) => {
                await client.sendText(message.from, `📊 System Status:\n${stdout}`);
            });
        }
        else if (command === '/help') {
            await client.sendText(message.from, `🤖 OpenClaw WhatsApp Bot Commands:

/openclaw <command> - Run OpenClaw command
/status - System status
/help - Show this help`);
        }
    });
}
VENOMEOF
        ;;
esac

chmod +x "$WA_BOT_DIR/bot.js"
success "Bot script created: $WA_BOT_DIR/bot.js"

# Create launcher script
cat > "$WA_BOT_DIR/start-whatsapp-bot.sh" << 'LAUNCHEOF'
#!/data/data/com.termux/files/usr/bin/bash
cd "$HOME/.openclaw/whatsapp-bot"
echo "🤖 Starting OpenClaw WhatsApp Bot..."
echo "📱 Scan the QR code with your WhatsApp app"
echo ""
node bot.js
LAUNCHEOF

chmod +x "$WA_BOT_DIR/start-whatsapp-bot.sh"
success "Launcher created: $WA_BOT_DIR/start-whatsapp-bot.sh"

# Create systemd-style service for desktop mode
if [[ "$USAGE_MODE" == "desktop" ]]; then
    cat > "$WA_BOT_DIR/whatsapp-bot.service" << SERVICEEOF
[Unit]
Description=OpenClaw WhatsApp Bot
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$WA_BOT_DIR
ExecStart=/usr/bin/node $WA_BOT_DIR/bot.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICEEOF
    success "Service file created (for desktop autostart)"
fi

# Create config file
cat > "$WA_BOT_DIR/config.json" << CONFIGEOF
{
  "mode": "${USAGE_MODE}",
  "library": "${WA_LIB}",
  "openclaw_integration": true,
  "allowed_commands": [
    "openclaw",
    "status",
    "help"
  ],
  "security": {
    "whitelist_enabled": false,
    "allowed_numbers": []
  }
}
CONFIGEOF

success "Config file created: $WA_BOT_DIR/config.json"

# Add to bashrc
if ! grep -q "openclaw-whatsapp" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'BASHEOF'

# OpenClaw WhatsApp Bot
alias whatsapp-bot='bash ~/.openclaw/whatsapp-bot/start-whatsapp-bot.sh'
BASHEOF
    success "Added 'whatsapp-bot' alias to ~/.bashrc"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 WHATSAPP BOT SETUP COMPLETE!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${WHITE}Configuration:${NC}"
echo "  Mode:     ${USAGE_MODE}"
echo "  Library:  ${WA_LIB}"
echo "  Location: $WA_BOT_DIR"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo "  1. source ~/.bashrc"
echo "  2. whatsapp-bot"
echo "  3. Scan QR code with WhatsApp"
echo "  4. Send /help to your bot"
echo ""
echo -e "${CYAN}Manual Start:${NC}"
echo "  bash $WA_BOT_DIR/start-whatsapp-bot.sh"
echo ""

if [[ "$USAGE_MODE" == "desktop" ]]; then
    echo -e "${CYAN}Desktop Autostart (optional):${NC}"
    echo "  Add to startup applications:"
    echo "  $WA_BOT_DIR/start-whatsapp-bot.sh"
    echo ""
fi

echo -e "${CYAN}Available Commands (send to bot):${NC}"
echo "  /openclaw gateway    - Start OpenClaw gateway"
echo "  /openclaw onboard    - Run OpenClaw onboarding"
echo "  /status              - Check system status"
echo "  /help                - Show help message"
echo ""
echo -e "${YELLOW}Security Note:${NC}"
echo "  Edit $WA_BOT_DIR/config.json to enable number whitelist"
echo ""
