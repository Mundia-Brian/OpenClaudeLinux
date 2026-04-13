#!/bin/bash
# =========================================================================
# 🧪 OpenClaudeLinux - Validation Script
# =========================================================================
# Verifies all improvements and fixes are correctly implemented
# =========================================================================

echo "🧪 OpenClaudeLinux Validation Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASS=0
FAIL=0

check() {
    if eval "$2" &>/dev/null; then
        echo "✅ $1"
        ((PASS++))
    else
        echo "❌ $1"
        ((FAIL++))
    fi
}

echo "📋 Checking setup.sh..."
check "Flag --distro-extras exists" "grep -q 'distro-extras' setup.sh"
check "MATE uses correct package" "grep -q 'pkg install -y mate mate-terminal mate-tweak' setup.sh"
check "KDE uses correct packages" "grep -q 'plasma-desktop konsole dolphin' setup.sh"
check "Wine includes wowbox64" "grep -q 'hangover-wowbox64' setup.sh"
check "Wine symlinks created" "grep -q 'ln -sf.*wine.*bin/wine' setup.sh"
check "Desktop shortcuts section exists" "grep -q 'Desktop shortcuts' setup.sh"
check "Plank autostart section exists" "grep -q 'Plank autostart' setup.sh"
check "KDE plasmashell workaround" "grep -q 'sleep 5.*plasmashell' setup.sh"
check "GPU config named linux-gpu.sh" "grep -q 'linux-gpu.sh' setup.sh"
check "No set -euo pipefail" "! grep -q 'set -euo pipefail' setup.sh"
check "No unused BLUE variable" "! grep -q \"BLUE='\" setup.sh || grep -q 'echo.*BLUE' setup.sh"
check "TERM_CMD variable defined" "grep -q 'TERM_CMD=' setup.sh"
check "Step 9/9 in final step" "grep -q 'Step 9/9' setup.sh"

echo ""
echo "📋 Checking start-linux.sh..."
check "Sources linux-gpu.sh" "grep -q 'source.*linux-gpu.sh' start-linux.sh"
check "No reference to ocl-gpu.sh" "! grep -q 'ocl-gpu.sh' start-linux.sh"

echo ""
echo "📋 Checking telegram-bot.sh..."
check "Telegram script exists" "test -f telegram-bot.sh"
check "Telegram script executable" "test -x telegram-bot.sh"
check "Bot token prompt exists" "grep -q 'Bot Token' telegram-bot.sh"

echo ""
echo "📋 Checking documentation..."
check "IMPROVEMENTS.md exists" "test -f IMPROVEMENTS.md"
check "README mentions telegram-bot.sh" "grep -q 'telegram-bot.sh' README.md"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: ✅ $PASS passed | ❌ $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -eq 0 ]; then
    echo "🎉 All validations passed!"
    exit 0
else
    echo "⚠️  Some validations failed. Review above."
    exit 1
fi
