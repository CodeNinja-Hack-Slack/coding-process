#!/bin/bash
# coding-process 项目级安装脚本
# 用法：在项目根目录执行
#   curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash

set -e

REPO_URL="https://github.com/void-frost-craft/coding-process.git"
TEMP_DIR=$(mktemp -d)
PROJECT_DIR=$(pwd)
CLAUDE_DIR="$PROJECT_DIR/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
CODING_PROCESS_DIR="$PROJECT_DIR/.coding-process"

echo "📦 正在安装 coding-process（项目级）..."
echo "📁 安装位置：$PROJECT_DIR"
echo ""

# ============================================================
# 1. 检查必需依赖
# ============================================================
echo "🔍 检查必需依赖..."
echo ""

HAS_ERROR=false

# 检查 git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>/dev/null || echo "unknown")
    echo "  ✅ git  ($GIT_VERSION)"
else
    echo "  ❌ git  未安装"
    echo "     请访问 https://git-scm.com/ 下载安装"
    HAS_ERROR=true
fi

# 检查 Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    echo "  ✅ Node.js  ($NODE_VERSION)"
else
    echo "  ❌ Node.js  未安装"
    echo "     请访问 https://nodejs.org/ 下载安装"
    HAS_ERROR=true
fi

# 检查 npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version 2>/dev/null || echo "unknown")
    echo "  ✅ npm  ($NPM_VERSION)"
else
    echo "  ❌ npm  未安装"
    echo "     通常随 Node.js 一起安装，请重新安装 Node.js"
    HAS_ERROR=true
fi

# 检查 Claude Code
if command -v claude &> /dev/null; then
    echo "  ✅ Claude Code"
else
    echo "  ⚠️  Claude Code  未检测到（可能需要安装）"
    echo "     请访问 https://claude.ai/code 下载安装"
fi

echo ""

if [ "$HAS_ERROR" = true ]; then
    echo "❌ 缺少必需依赖，请安装后重新运行"
    exit 1
fi

# ============================================================
# 2. 检查可选依赖
# ============================================================
echo "🔍 检查可选依赖..."
echo ""

# 定义 settings.json 路径
SETTINGS_PATH="$HOME/.claude/settings.json"

# 检查 Superpowers 插件（通过 enabledPlugins 和缓存检测）
HAS_SUPERPOWERS=false
SUPERPOWERS_VERSION=""

# 方式1：检查 enabledPlugins
if [ -f "$SETTINGS_PATH" ]; then
    if grep -q '"superpowers@claude-plugins-official".*true' "$SETTINGS_PATH" 2>/dev/null; then
        HAS_SUPERPOWERS=true
    fi
fi

# 方式2：检查插件缓存获取版本
CACHE_PATH="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
if [ -d "$CACHE_PATH" ]; then
    # 获取最新版本目录
    LATEST_VERSION=$(ls -1v "$CACHE_PATH" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -1)
    if [ -n "$LATEST_VERSION" ]; then
        SUPERPOWERS_VERSION="$LATEST_VERSION"
        HAS_SUPERPOWERS=true
    fi
fi

if [ "$HAS_SUPERPOWERS" = true ]; then
    if [ -n "$SUPERPOWERS_VERSION" ]; then
        echo "  ✅ Superpowers 插件  (v$SUPERPOWERS_VERSION)"
    else
        echo "  ✅ Superpowers 插件  (已安装)"
    fi
else
    echo "  ⚠️  Superpowers 插件  未安装（可选）"
    echo "     用途：执行纪律 Skills（TDD、Code Review 等）"
    echo "     安装：在 Claude Code 中执行 /plugin install superpowers@claude-plugins-official"
fi

# 检查 CodeGraph MCP（通过 npm 全局包和 permissions 检测）
HAS_CODEGRAPH=false
CODEGRAPH_VERSION=""

# 方式1：检查 npm 全局安装
NPM_LIST=$(npm list -g @colbymchenry/codegraph 2>/dev/null)
if echo "$NPM_LIST" | grep -qE "@colbymchenry/codegraph@[0-9]+\.[0-9]+\.[0-9]+"; then
    CODEGRAPH_VERSION=$(echo "$NPM_LIST" | grep -oE "@colbymchenry/codegraph@[0-9]+\.[0-9]+\.[0-9]+" | head -1 | cut -d'@' -f3)
    HAS_CODEGRAPH=true
fi

# 方式2：检查 settings.json 中的 MCP permissions
if [ "$HAS_CODEGRAPH" = false ] && [ -f "$SETTINGS_PATH" ]; then
    if grep -q "mcp__codegraph__" "$SETTINGS_PATH" 2>/dev/null; then
        HAS_CODEGRAPH=true
    fi
fi

if [ "$HAS_CODEGRAPH" = true ]; then
    if [ -n "$CODEGRAPH_VERSION" ]; then
        echo "  ✅ CodeGraph MCP  (v$CODEGRAPH_VERSION)"
    else
        echo "  ✅ CodeGraph MCP  (已安装)"
    fi
else
    echo "  ⚠️  CodeGraph MCP  未安装（可选）"
    echo "     用途：代码结构分析、影响评估"
    echo "     安装：npm install -g @colbymchenry/codegraph"
fi

echo ""

# ============================================================
# 3. 克隆仓库
# ============================================================
echo "📥 下载 coding-process..."
if ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null; then
    echo "❌ 下载失败，请检查网络连接"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# ============================================================
# 4. 创建目录并复制文件（项目级安装）
# ============================================================

# 创建 .claude/commands 目录
mkdir -p "$COMMANDS_DIR"
echo "📂 创建目录：.claude/commands/"

# 创建 .coding-process 目录
mkdir -p "$CODING_PROCESS_DIR"
echo "📂 创建目录：.coding-process/"

# 复制 flow.md（命令入口）
cp "$TEMP_DIR/.claude/commands/flow.md" "$COMMANDS_DIR/flow.md"
echo "📂 安装 /flow 命令到项目..."

# 复制配置文件到 .coding-process（按需加载，不占 token）
if [ -f "$TEMP_DIR/.coding-process/modes.yaml" ]; then
    cp "$TEMP_DIR/.coding-process/modes.yaml" "$CODING_PROCESS_DIR/modes.yaml"
fi
echo "📂 复制配置文件到 .coding-process/..."

# ============================================================
# 5. 清理
# ============================================================
rm -rf "$TEMP_DIR"

# ============================================================
# 6. 输出结果
# ============================================================
echo ""
echo "✅ 安装完成！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "项目目录结构："
echo ""
echo "  $PROJECT_DIR"
echo "  ├── .claude/"
echo "  │   └── commands/"
echo "  │       └── flow.md              # /flow 命令（调度器）"
echo "  └── .coding-process/"
echo "      └── modes.yaml               # 场景配置（7 种工作流）"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "接下来执行："
echo ""
echo "  cd $PROJECT_DIR"
echo "  claude"
echo "  /flow init               # 首次运行，初始化项目配置"
echo "  /flow                    # 开始使用"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 依赖状态汇总
echo "📋 依赖状态汇总："
echo ""
echo "  必需依赖："
echo "    ✅ git              ($GIT_VERSION)"
echo "    ✅ Node.js          ($NODE_VERSION)"
echo "    ✅ npm              ($NPM_VERSION)"
echo ""
echo "  可选依赖："

if [ "$HAS_SUPERPOWERS" = true ]; then
    if [ -n "$SUPERPOWERS_VERSION" ]; then
        echo "    ✅ Superpowers 插件  (v$SUPERPOWERS_VERSION)"
    else
        echo "    ✅ Superpowers 插件  (已安装)"
    fi
else
    echo "    ⚠️  Superpowers 插件  未安装  → /plugin install superpowers@claude-plugins-official"
fi

if [ "$HAS_CODEGRAPH" = true ]; then
    if [ -n "$CODEGRAPH_VERSION" ]; then
        echo "    ✅ CodeGraph MCP     (v$CODEGRAPH_VERSION)"
    else
        echo "    ✅ CodeGraph MCP     (已配置)"
    fi
else
    echo "    ⚠️  CodeGraph MCP     未配置  → 配置 MCP 服务器"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
