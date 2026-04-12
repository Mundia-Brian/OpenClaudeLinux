# 🚀 OpenClaudeLinux (Android Running Linux, Openclaw, Claude Code, Ollama)
### *The Ultimate AI Agent & Linux for Android (Termux)*
*OpenClaudeLinux* is a specialized environment setup for Android users to run powerful AI tools and autonomous agents natively. This project bypasses the need for root or Shizuku, providing a streamlined, non-interactive installation for the most popular open-source AI frameworks.

---
## 🛠️ Features
- **Claude Code Ready:** Optimized environment for Anthropic's official terminal-based AI.
- **OpenClaw Integration:** Full setup for the open-source autonomous agent.
- **Native Ollama:** Run Large Language Models (LLMs) locally on your phone.
- **Termux-Optimized:** Includes critical DNS and network fixes specifically for Node.js and Python on Android.
- **X11 Re-display Fix:** `start-linux.sh` cleans stale X11 locks so the display always restores after `stop-linux.sh`.

---
## Requirements
- Android phone with minimum 6 GB RAM
- [Termux](https://f-droid.org/en/packages/com.termux/)
- [Termux:X11](https://github.com/termux/termux-x11/releases)

---
## Linux Installation

```bash
termux-setup-storage
pkg install proot-distro termux-x11 pulseaudio -y
proot-distro install ubuntu
```

---
## Start / Stop Linux with X11

```bash
# Clone this repo first
pkg install git -y
git clone https://github.com/AbuZar-Ansarii/OpenClaudeLinux.git
cd OpenClaudeLinux
chmod +x start-linux.sh stop-linux.sh
```

**Start Linux (launches X11 + proot Ubuntu):**
```bash
./start-linux.sh
```

**Stop Linux (cleanly kills X11 and removes stale locks):**
```bash
./stop-linux.sh
```

> ⚠️ Always use `./stop-linux.sh` before closing Termux:X11 to prevent stale lock files that block X11 from restarting.

---
## Install and Setup Ollama

```bash
pkg install ollama -y
ollama serve &
```

---
## Install Claude Code

```bash
pkg update -y && pkg upgrade -y
pkg install git nodejs npm -y
npm install -g @anthropic-ai/claude-code
```

Add Ollama config to `~/.bashrc` (note: use `/v1` suffix for OpenAI-compatible endpoint):
```bash
echo -e '\n# Claude Code with Ollama Config\nexport ANTHROPIC_BASE_URL="http://localhost:11434/v1"\nexport ANTHROPIC_API_KEY="ollama"' >> ~/.bashrc && source ~/.bashrc
```

> ⚠️ Use `ANTHROPIC_API_KEY` (not `ANTHROPIC_AUTH_TOKEN`) and append `/v1` to the Ollama base URL for OpenAI-compatible routing.

---
## Run Claude Code

```bash
claude --model nemotron-mini
```

---
## OpenClaw Installation

```bash
curl -sL https://raw.githubusercontent.com/AbuZar-Ansarii/OpenClaudeLinux/main/openclaw.sh | bash
```

## Onboarding
```bash
openclaw onboard
```

## Start Gateway
```bash
openclaw gateway
```

## Get Gateway Token
```bash
cat ~/.openclaw/openclaw.json
```

## OpenClaw Dashboard
```
http://127.0.0.1:18789
```
