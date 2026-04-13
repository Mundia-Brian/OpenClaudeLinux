# 🚀 OpenClaudeLinux - Quick Reference Card

## 📥 Installation

```bash
# Standard install (interactive)
bash setup.sh

# Auto install with extras
bash setup.sh --auto --de xfce4 --distro-extras

# Minimal 2GB install
bash setup.sh --auto --de lxqt --no-ollama --no-openclaw
```

## 🎮 Desktop Control

```bash
./start-linux.sh    # Start desktop (then open Termux:X11 app)
./stop-linux.sh     # Stop desktop (always use this, never just close app)
```

## 🆕 New Features (This Update)

### Desktop Shortcuts
After install with `--distro-extras`, find on desktop:
- 🦊 Firefox.desktop
- 🎬 VLC.desktop
- 🍷 Wine_Config.desktop
- 💻 Terminal.desktop (adapts to your DE)

### Plank Dock (XFCE/MATE)
- Auto-starts on login
- macOS-style dock at bottom of screen
- Config: `~/.config/autostart/plank.desktop`

### Telegram Bot
```bash
bash telegram-bot.sh    # Setup OpenClaw remote control
```

## 🔧 What Was Fixed

| Issue | Solution |
|-------|----------|
| `--distro-extras` flag not working | ✅ Now parsed correctly |
| MATE install failing | ✅ Fixed package names |
| KDE install failing | ✅ Fixed package names |
| Wine not working | ✅ Added symlinks + wowbox64 |
| GPU config not loading | ✅ Fixed filename consistency |
| No desktop shortcuts | ✅ Auto-created with extras |
| Plank not auto-starting | ✅ Added autostart config |
| KDE crashing on start | ✅ Added plasmashell workaround |

## 📦 Desktop Environments

| DE | RAM | Features | Best For |
|----|-----|----------|----------|
| LXQt | 2GB+ | Ultra lightweight | Low-end devices |
| XFCE4 | 2GB+ | Fast + Plank dock | Balanced performance |
| MATE | 3GB+ | Classic + Plank dock | Traditional UI |
| KDE | 4GB+ | Modern + effects | High-end devices |

## 🤖 AI Features

### Ollama (Local LLMs)
```bash
ollama serve &
ollama pull tinyllama      # 2-3 GB RAM
ollama pull phi3:mini      # 3-4 GB RAM
ollama pull nemotron-mini  # 4+ GB RAM
```

### Claude Code
```bash
claude --model <model>     # Uses local Ollama
```

### OpenClaw
```bash
openclaw onboard           # First-time setup
openclaw gateway           # Start agent
# Dashboard: http://127.0.0.1:18789
```

## 🧪 Validation

```bash
bash validate.sh           # Run 20 automated checks
```

Expected output: `✅ 20 passed | ❌ 0 failed`

## 📁 Config Files

| File | Purpose |
|------|---------|
| `~/.config/linux-gpu.sh` | GPU acceleration settings |
| `~/.config/autostart/plank.desktop` | Plank dock autostart |
| `~/.config/plasma-workspace/env/xdg_fix.sh` | KDE app paths |
| `~/Desktop/*.desktop` | Desktop shortcuts |
| `~/.bashrc` | Environment variables |

## 🐛 Troubleshooting

### X11 won't start
```bash
./stop-linux.sh && ./start-linux.sh
```

### Desktop shortcuts not appearing
```bash
chmod +x ~/Desktop/*.desktop
```

### Plank not auto-starting
```bash
cat ~/.config/autostart/plank.desktop  # Should exist for XFCE/MATE
```

### Wine not working
```bash
which wine                              # Should show /data/data/com.termux/.../wine
wine --version                          # Should show Hangover version
```

### GPU not accelerating
```bash
source ~/.config/linux-gpu.sh
echo $GALLIUM_DRIVER                    # Should output: zink
```

## 📚 Documentation

- `README.md` - Full user guide
- `IMPROVEMENTS.md` - Detailed changelog
- `SUMMARY.md` - Executive summary
- `validate.sh` - Automated testing

## 🔗 Links

- **Repo**: github.com/Mundia-Brian/OpenClaudeLinux
- **Termux**: f-droid.org/packages/com.termux
- **Termux:X11**: github.com/termux/termux-x11/releases
- **Ollama**: ollama.ai
- **OpenClaw**: myopenclawhub.com

## ⚡ Quick Tips

1. Always use `./stop-linux.sh` before closing Termux:X11
2. Run `source ~/.bashrc` after install to load env vars
3. Use `--distro-extras` for full desktop experience
4. Check RAM with `free -h` before choosing DE
5. Desktop shortcuts only created with `--distro-extras`

---

**Last Updated**: 2024-04-12  
**Version**: Post-improvements  
**Status**: Production Ready ✅
