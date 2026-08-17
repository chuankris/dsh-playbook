#!/usr/bin/env bash
# dsh-playbook 一键部署：把 preset 和 host-patch 装到 ~/.dsh，并检查依赖。
set -euo pipefail

DSH_HOME="${DSH_HOME:-$HOME/.dsh}"
PLAYBOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m[!]\033[0m %s\n' "$*"; }
fail()  { printf '\033[31m[X]\033[0m %s\n' "$*"; }

echo "== dsh-playbook 部署开始 =="

# 1. 安装 preset
echo "-- 安装辩论模式 preset --"
mkdir -p "$DSH_HOME/.agent-presets/debate"
cp -f "$PLAYBOOK_DIR/presets/debate/agent.cordis.yml" "$DSH_HOME/.agent-presets/debate/"
cp -f "$PLAYBOOK_DIR/presets/debate/preset.yml" "$DSH_HOME/.agent-presets/debate/"
info "preset -> $DSH_HOME/.agent-presets/debate/"

# 2. 安装 host patch
echo "-- 安装 host patch --"
if [ -f "$DSH_HOME/cordis.patch.yml" ]; then
  cp -f "$DSH_HOME/cordis.patch.yml" "$DSH_HOME/cordis.patch.yml.bak.$(date +%s)"
  warn "已备份旧 cordis.patch.yml"
fi
cp -f "$PLAYBOOK_DIR/host-patch/cordis.patch.yml" "$DSH_HOME/cordis.patch.yml"
info "host patch -> $DSH_HOME/cordis.patch.yml"

# 3. 检查依赖
echo "-- 检查依赖 --"
check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    info "$1: $(command -v "$1")"
  else
    fail "$1: 未找到"
  fi
}
check_cmd dsh
check_cmd codex
check_cmd claude
check_cmd ffmpeg
check_cmd node

# 4. 检查 API Key
echo "-- 检查 DeepSeek API Key --"
if [ -f "$DSH_HOME/.credentials.yaml" ] && grep -q "DEEPSEEK_API_KEY" "$DSH_HOME/.credentials.yaml"; then
  info "DEEPSEEK_API_KEY 已配置"
else
  fail "DEEPSEEK_API_KEY 未配置"
  echo "  请在 $DSH_HOME/.credentials.yaml 中添加："
  echo "  DEEPSEEK_API_KEY: sk-xxx"
fi

echo "== 部署完成 =="
echo "启动：dsh web  （在 Web UI 中选择「辩论模式」preset）"
