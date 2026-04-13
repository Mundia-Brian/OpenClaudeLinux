# 🚀 OpenClaudeLinux
### *AI Agents + Linux Desktop on Android (Termux) — 2 GB RAM Minimum*

Run a full Linux desktop, Claude Code, Ollama LLMs, and OpenClaw AI agent natively on Android via Termux — no root, no Shizuku, no proot required.

---

## 📋 Requirements

| Item | Minimum |
|------|---------|
| Android | 8.0+ |
| RAM | 2 GB (LXQt auto-selected) |
| Storage | 4 GB free |
| App | [Termux (F-Droid)](https://f-droid.org/en/packages/com.termux/) |
| App | [Termux:X11](https://github.com/termux/termux-x11/releases) |

> ⚠️ Install both apps from the links above. **Do not use the Play Store version of Termux** — it is outdated.

---

## 🛠️ Features

- **Native Termux** — runs directly in Termux, no proot/chroot overhead
- **Auto RAM detection** — selects LXQt on 2 GB, allows XFCE4/MATE/KDE on higher RAM
- **GPU acceleration** — auto-detects Adreno (Turnip) or falls back to Zink/Mesa
- **X11 re-display fix** — stale lock files cleaned on every start/stop cycle
- **Claude Code** — Anthropic's terminal AI, wired to local Ollama backend
- **Ollama** — local LLM inference; lightweight models recommended for low-end devices
- **OpenClaw** — autonomous AI agent with web dashboard
- **PulseAudio** — audio support inside the desktop session
- **Optional extras** — Firefox, VLC, Wine/Box64 for high-RAM devices
- **Telegram remote control** — optional OpenClaw Telegram bot for device control

---

## 🚀 Quick Install (Recommended)

### Step 1: Prepare Termux

```bash
termux-setup-storage
pkg install git -y
```

### Step 2: Clone & Run Setup

```bash
git clone https://github.com/Mundia-Brian/OpenClaudeLinux.git
cd OpenClaudeLinux
chmod +x setup.sh
bash setup.sh
```

The setup script will:
1. **Detect your RAM** and recommend a desktop environment
2. **Ask you to choose features** (Ollama, Claude Code, OpenClaw)
3. **Optionally install extras** (Firefox, VLC, Wine)
4. **Generate start-linux.sh and stop-linux.sh** scripts

### Step 3: Start the Desktop

The setup script auto-selects **LXQt** on 2 GB RAM devices. Override with:

```bash
bash setup.sh --auto --de xfce4
```

```bash
./start-linux.sh
```

Then **open the Termux:X11 app** to see your desktop.

---

## 🖥️ Start / Stop Desktop

```bash
./start-linux.sh    # launches X11 + desktop, then open Termux:X11 app
./stop-linux.sh     # cleanly stops everything and removes X11 lock files
```

> ⚠️ Always use `./stop-linux.sh` to stop — never just close Termux:X11. Closing without stopping leaves stale `/tmp/.X0-lock` files that prevent X11 from restarting.

---

## 🤖 Ollama — Local LLMs

```bash
ollama serve &
```

**Recommended models by RAM:**

| RAM | Model | Pull command |
|-----|-------|-------------|
| 2 GB | TinyLlama 1.1B | `ollama pull tinyllama` |
| 2–3 GB | Phi-3 Mini | `ollama pull phi3:mini` |
| 3–4 GB | Gemma 2B | `ollama pull gemma:2b` |
| 4+ GB | Nemotron Mini | `ollama pull nemotron-mini` |

---

## 🧠 Claude Code

```bash
claude --model <model-name>
```

Claude Code is pre-configured to use your local Ollama instance. The env vars in `~/.bashrc`:

```bash
export ANTHROPIC_BASE_URL="http://localhost:11434/v1"
export ANTHROPIC_API_KEY="ollama"
```

> ⚠️ The `/v1` suffix is required — Ollama's OpenAI-compatible endpoint lives at `/v1`, not `/`.

---

## 🦾 OpenClaw AI Agent

### Install (if skipped during setup)

```bash
curl -sL https://raw.githubusercontent.com/Mundia-Brian/OpenClaudeLinux/main/openclaw.sh | bash
```

### Start OpenClaw

```bash
source ~/.bashrc
openclaw onboard       # first-time setup
openclaw gateway       # start the agent gateway
```

**Dashboard:** `http://127.0.0.1:18789`

**Get your gateway token:**
```bash
cat ~/.openclaw/openclaw.json
```

---

## 📱 OpenClaw Telegram Remote Control (Optional)

OpenClaw supports Telegram bot integration for remote device control. To enable:

### 1. Create a Telegram Bot

- Open Telegram and search for `@BotFather`
- Send `/newbot` and follow the prompts
- Copy your **Bot Token** (format: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

### 2. Run Telegram Setup Script

```bash
bash telegram-bot.sh
```

This will:
- Prompt for your Bot Token
- Ask for your Telegram User ID
- Configure OpenClaw automatically

### 3. Get Your Telegram User ID

- Send any message to your bot
- Visit: `https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates`
- Find your `"id"` in the response

### 4. Restart OpenClaw

```bash
openclaw gateway
```

Now you can control OpenClaw remotely via Telegram!

---

## 🔧 Advanced Setup Options

### Auto Mode (Non-Interactive)

```bash
bash setup.sh --auto --de xfce4
```

### Skip Features

```bash
# Desktop mode
bash setup.sh --no-ollama         # skip Ollama
bash setup.sh --no-claude         # skip Claude Code
bash setup.sh --no-openclaw       # skip OpenClaw
bash setup.sh --distro-extras     # install Firefox, Wine
bash setup.sh --telegram          # enable Telegram bot
bash setup.sh --whatsapp          # enable WhatsApp bot
bash setup.sh --mobile            # force mobile mode (no desktop)

# Mobile mode
bash setup-mobile.sh --no-ollama  # skip Ollama
bash setup-mobile.sh --whatsapp   # enable WhatsApp
bash setup-mobile.sh --telegram   # enable Telegram
```

### Minimal Install (2 GB RAM)

```bash
# Desktop mode
bash setup.sh --auto --de lxqt --no-ollama --no-openclaw

# Mobile mode (even lighter)
bash setup-mobile.sh --no-ollama --no-openclaw
```

### Full Install (6+ GB RAM)

```bash
bash setup.sh --auto --de xfce4 --distro-extras
```

---

## 🔧 Manual Linux Desktop Install (Alternative)

If you prefer the full interactive desktop installer from the community:

```bash
termux-setup-storage
curl -O https://raw.githubusercontent.com/orailnoor/termux-linux-setup/main/termux-linux-setup.sh
chmod +x termux-linux-setup.sh
./termux-linux-setup.sh
```

Then use this repo's `start-linux.sh` / `stop-linux.sh` for reliable X11 re-display.

---

## 🐛 Troubleshooting

### X11 won't start / blank screen

```bash
./stop-linux.sh          # clears stale locks
./start-linux.sh         # restart
```

### `termux-x11` command not found

```bash
pkg install x11-repo -y && pkg install termux-x11-nightly -y
```

### Audio not working

```bash
pulseaudio --kill && pulseaudio --start --exit-idle-time=-1
```

### Claude Code can't connect to Ollama

```bash
ollama serve &           # make sure Ollama is running
curl http://localhost:11434/v1/models   # verify endpoint
```

### Desktop environment won't start

Ensure dbus is running:
```bash
dbus-launch bash
```

### Out of memory / OOM kills

- Use `tinyllama` or `phi3:mini` instead of larger models
- Close other Android apps before starting the desktop
- Use `--no-ollama` flag during setup to skip Ollama entirely

### X11 display shows but desktop is blank

Check GPU config is loaded:
```bash
source ~/.config/linux-gpu.sh
echo $GALLIUM_DRIVER
```

Should output: `zink`

---

## 📚 Architecture

- **Termux** — native Android shell (Alpine-based package system)
- **Desktop** — XFCE4/LXQt/MATE/KDE running natively in Termux
- **X11** — Termux:X11 app provides display server
- **GPU** — Zink (software) or Turnip (Adreno hardware acceleration)
- **Audio** — PulseAudio over TCP
- **AI** — Ollama (local LLMs) + Claude Code + OpenClaw

---

## 🤝 Contributing

Issues and PRs welcome! This is a community fork of [AbuZar-Ansarii/OpenClaudeLinux](https://github.com/AbuZar-Ansarii/OpenClaudeLinux).

---

## 📄 License

MIT — See LICENSE file

---

## 🙏 Credits

- **Original repo:** [AbuZar-Ansarii/OpenClaudeLinux](https://github.com/AbuZar-Ansarii/OpenClaudeLinux)
- **Desktop setup reference:** [orailnoor/termux-linux-setup](https://github.com/orailnoor/termux-linux-setup)
- **Ollama:** [ollama.ai](https://ollama.ai)
- **Claude Code:** [Anthropic](https://anthropic.com)
- **OpenClaw:** [OpenClaw Hub](https://myopenclawhub.com)
