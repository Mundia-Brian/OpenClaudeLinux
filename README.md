# 🚀 OpenClaudeLinux (Android Running Linux, Openclaw, Claude Code, Ollama)
### *The Ultimate AI Agent & Linux for Android (Termux)*
*OpenClaudeLinux* is a specialized environment setup for Android users to run powerful AI tools and autonomous agents natively. This project bypasses the need for root or Shizuku, providing a streamlined, non-interactive installation for the most popular open-source AI frameworks.

---
## 🛠️ Features
- **Claude Code Ready:** Optimized environment for Anthropic's official terminal-based AI.
- **OpenClaw Integration:** Full setup for the open-source autonomous agent.
- **Native Ollama:** Run Large Language Models (LLMs) locally on your phone.
- **Termux-Optimized:** Includes critical DNS and network fixes specifically for Node.js and Python on Android.

---
## Requirement
**Android Phone with minimum 6gb RAM** 
**Termux App - https://fdroid.org/en/packages/com.termux/**
**Termux X11 App - https://github.com/termux/termux-x11/releases**


## Linux Installation 

```
termux-setup-storage
curl -O https://raw.githubusercontent.com/orailnoor/termux-linux-setup/main/termux-linux-setup.sh && chmod +x termux-linux-setup.sh && ./termux-linux-setup.sh
```
---
## Install and setup Ollama
```
pkg install ollama
ollama serve
```
---

## Update packages and install Claude code
```
pkg update && apt upgrade -y
pkg install git nodejs npm
npm install -g @anthropic-ai/claude-code
echo -e '\n# Claude Code with Ollama Config\nexport ANTHROPIC_BASE_URL="http://localhost:11434"\nexport ANTHROPIC_AUTH_TOKEN="ollama"' >> ~/.bashrc && source ~/.bashrc
```
---

## Run Claude code
```
claude --model nemotron-3-super:cloud
```
---

## Openclaw Installation 
```
curl -sL https://raw.githubusercontent.com/AbuZar-Ansarii/OpenClaudeLinux/main/openclaw.sh | bash
```
## Onboarding
```
openclaw onboard
```
## Start gateway 
```
openclaw gateway 
```
## Get gateway token
```
cat ~/.openclaw/openclaw.json
```

## Openclaw dashboard 
```
http://127.0.0.1:18789
```
