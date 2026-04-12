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
- **Wine/Box64** — Windows app compatibility (via termux-linux-setup)

---

## 🚀 Quick Install (Recommended)

Clone this repo and run the single setup script — it handles everything:

```bash
termux-setup-storage
pkg install git -y
git clone https://github.com/Mundia-Brian/OpenClaudeLinux.git
cd OpenClaudeLinux
chmod +x setup.sh
bash setup.sh
```

The setup script auto-selects **LXQt** on 2 GB RAM devices. Override with:

```bash
bash setup.sh --de xfce4          # XFCE4 (needs 3+ GB)
bash setup.sh --de lxqt           # LXQt  (2 GB minimum, default)
bash setup.sh --no-ollama         # skip Ollama (saves ~500 MB)
bash setup.sh --no-openclaw       # skip OpenClaw
bash setup.sh --de lxqt --no-ollama --no-openclaw   # minimal install
```

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

Install standalone (if skipped during setup):

```bash
curl -sL https://raw.githubusercontent.com/AbuZar-Ansarii/OpenClaudeLinux/main/openclaw.sh | bash
```

```bash
source ~/.bashrc
openclaw onboard       # first-time setup
openclaw gateway       # start the agent gateway
```

Dashboard: `http://127.0.0.1:18789`

Get your gateway token:
```bash
cat ~/.openclaw/openclaw.json
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

**X11 won't start / blank screen:**
```bash
./stop-linux.sh          # clears stale locks
./start-linux.sh         # restart
```

**`termux-x11` command not found:**
```bash
pkg install x11-repo -y && pkg install termux-x11-nightly -y
```

**Audio not working:**
```bash
pulseaudio --kill && pulseaudio --start --exit-idle-time=-1
```

**Claude Code can't connect to Ollama:**
```bash
ollama serve &           # make sure Ollama is running
curl http://localhost:11434/v1/models   # verify endpoint
```

**Out of memory / OOM kills:**
- Use `tinyllama` or `phi3:mini` instead of larger models
- Close other Android apps before starting the desktop
- Use `--no-ollama` flag during setup to skip Ollama entirely
