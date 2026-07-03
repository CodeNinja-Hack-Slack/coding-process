#!/bin/bash
# coding-process 项目级安装脚本
# 支持 Claude Code 和 OpenCode 双平台
# 注意：需要先安装 Superpowers 插件
# 用法：
#   curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash
#   curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash -s -- --opencode
#   curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash -s -- --claude

set -e

REPO_URL="https://github.com/void-frost-craft/coding-process.git"
TEMP_DIR=$(mktemp -d)
PROJECT_DIR=$(pwd)

# 解析参数
INSTALL_OPENCODE=false
INSTALL_CLAUDE=false

for arg in "$@"; do
    case $arg in
        --opencode)
            INSTALL_OPENCODE=true
            ;;
        --claude)
            INSTALL_CLAUDE=true
            ;;
        *)
            # 默认安装两个版本
            INSTALL_OPENCODE=true
            INSTALL_CLAUDE=true
            ;;
    esac
done

# 如果只指定了一个，另一个也安装
if [ "$INSTALL_OPENCODE" = true ] || [ "$INSTALL_CLAUDE" = true ]; then
    INSTALL_OPENCODE=true
    INSTALL_CLAUDE=true
fi

echo "📦 正在安装 coding-process（项目级）..."
echo "📁 安装位置：$PROJECT_DIR"
echo "📋 安装平台：Claude Code=$INSTALL_CLAUDE, OpenCode=$INSTALL_OPENCODE"
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

# 检查 Claude Code（可选）
if [ "$INSTALL_CLAUDE" = true ]; then
    if command -v claude &> /dev/null; then
        echo "  ✅ Claude Code"
    else
        echo "  ⚠️  Claude Code  未检测到（可选，如需使用 Claude Code 版本请安装）"
        echo "     请访问 https://claude.ai/code 下载安装"
    fi
fi

# 检查 OpenCode（可选）
if [ "$INSTALL_OPENCODE" = true ]; then
    if command -v opencode &> /dev/null; then
        OPC_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
        echo "  ✅ OpenCode  ($OPC_VERSION)"
    else
        echo "  ⚠️  OpenCode  未检测到（可选，如需使用 OpenCode 版本请安装）"
        echo "     请访问 https://opencode.ai 下载安装"
        echo "     或执行：curl -fsSL https://opencode.ai/install | bash"
    fi
fi

echo ""

if [ "$HAS_ERROR" = true ]; then
    echo "❌ 缺少必需依赖，请安装后重新运行"
    exit 1
fi

# ============================================================
# 2. 检查 Superpowers（必需依赖）
# ============================================================
echo "🔍 检查 Superpowers..."
echo ""

HAS_SUPERPOWERS=false

# 检查 Claude Code 的 Superpowers
if [ "$INSTALL_CLAUDE" = true ]; then
    # 检查 ~/.claude/plugins/ 目录
    if [ -d "$HOME/.claude/plugins" ]; then
        if find "$HOME/.claude/plugins" -type d -name "*superpowers*" 2>/dev/null | grep -q .; then
            HAS_SUPERPOWERS=true
            echo "  ✅ Superpowers 插件  (Claude Code)"
        fi
    fi
    
    # 检查 settings.json
    SETTINGS_PATH="$HOME/.claude/settings.json"
    if [ -f "$SETTINGS_PATH" ]; then
        if grep -q '"superpowers@claude-plugins-official".*true' "$SETTINGS_PATH" 2>/dev/null; then
            HAS_SUPERPOWERS=true
            echo "  ✅ Superpowers 插件  (Claude Code)"
        fi
    fi
fi

# 检查 OpenCode 的 Superpowers
if [ "$INSTALL_OPENCODE" = true ]; then
    # 检查项目级 opencode.json
    if [ -f "$PROJECT_DIR/opencode.json" ]; then
        if grep -q '"superpowers' "$PROJECT_DIR/opencode.json" 2>/dev/null; then
            HAS_SUPERPOWERS=true
            echo "  ✅ Superpowers 插件  (OpenCode)"
        fi
    fi
    
    # 检查全局 opencode.json
    GLOBAL_OPC="$HOME/.config/opencode/opencode.json"
    if [ -f "$GLOBAL_OPC" ]; then
        if grep -q '"superpowers' "$GLOBAL_OPC" 2>/dev/null; then
            HAS_SUPERPOWERS=true
            echo "  ✅ Superpowers 插件  (OpenCode)"
        fi
    fi
fi

if [ "$HAS_SUPERPOWERS" = false ]; then
    echo "  ⚠️  Superpowers 插件  未检测到（必需依赖）"
    echo ""
    echo "     请先安装 Superpowers："
    echo ""
    
    if [ "$INSTALL_CLAUDE" = true ]; then
        echo "     Claude Code:"
        echo "     /plugin install superpowers@claude-plugins-official"
        echo ""
    fi
    
    if [ "$INSTALL_OPENCODE" = true ]; then
        echo "     OpenCode:"
        echo "     在 opencode.json 中添加："
        echo '     {
       "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
     }'
        echo ""
    fi
    
    echo "     安装后请重新运行此脚本"
    echo ""
    read -p "是否继续安装？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 安装已取消"
        exit 1
    fi
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

# 安装 Claude Code 版本
if [ "$INSTALL_CLAUDE" = true ]; then
    echo ""
    echo "📦 安装 Claude Code 版本..."
    
    # 创建目录
    mkdir -p "$PROJECT_DIR/.claude/commands"
    mkdir -p "$PROJECT_DIR/.claude/modes"
    
    # 复制 flow.md
    if [ -f "$TEMP_DIR/.claude/commands/flow.md" ]; then
        cp "$TEMP_DIR/.claude/commands/flow.md" "$PROJECT_DIR/.claude/commands/flow.md"
        echo "📂 安装 /flow 命令到 .claude/commands/"
    fi
    
    # 复制 modes.yaml
    if [ -f "$TEMP_DIR/.coding-process/modes.yaml" ]; then
        cp "$TEMP_DIR/.coding-process/modes.yaml" "$PROJECT_DIR/.claude/modes/modes.yaml"
        echo "📂 安装场景配置到 .claude/modes/"
    fi
fi

# 安装 OpenCode 版本
if [ "$INSTALL_OPENCODE" = true ]; then
    echo ""
    echo "📦 安装 OpenCode 版本..."
    
    # 创建目录
    mkdir -p "$PROJECT_DIR/.opencode/commands"
    mkdir -p "$PROJECT_DIR/.opencode/modes"
    
    # 复制 flow.md
    if [ -f "$TEMP_DIR/.opencode/commands/flow.md" ]; then
        cp "$TEMP_DIR/.opencode/commands/flow.md" "$PROJECT_DIR/.opencode/commands/flow.md"
        echo "📂 安装 /flow 命令到 .opencode/commands/"
    fi
    
    # 复制 modes.yaml
    if [ -f "$TEMP_DIR/.opencode/modes/modes.yaml" ]; then
        cp "$TEMP_DIR/.opencode/modes/modes.yaml" "$PROJECT_DIR/.opencode/modes/modes.yaml"
        echo "📂 安装场景配置到 .opencode/modes/"
    fi
    
    # 复制 opencode.json（必需：注册 Superpowers 插件和 /flow 命令）
    if [ -f "$TEMP_DIR/opencode.json" ]; then
        if [ ! -f "$PROJECT_DIR/opencode.json" ]; then
            cp "$TEMP_DIR/opencode.json" "$PROJECT_DIR/opencode.json"
            echo "📂 创建 opencode.json..."
        else
            echo "⚠️  opencode.json 已存在，跳过（请手动合并配置）"
        fi
    fi
fi

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

if [ "$INSTALL_CLAUDE" = true ]; then
    echo "  Claude Code 版本："
    echo "  ├── .claude/"
    echo "  │   ├── commands/"
    echo "  │   │   └── flow.md              # /flow 命令（调度器）"
    echo "  │   ├── modes/"
    echo "  │   │   └── modes.yaml           # 场景配置（7 种工作流）"
    echo "  │   └── skills/                  # （由 Superpowers 插件全局提供）"
    echo ""
fi

if [ "$INSTALL_OPENCODE" = true ]; then
    echo "  OpenCode 版本："
    echo "  ├── .opencode/"
    echo "  │   ├── commands/"
    echo "  │   │   └── flow.md              # /flow 命令（调度器）"
    echo "  │   ├── skills/                  # （由 Superpowers 插件全局提供）"
    echo "  │   └── modes/"
    echo "  │       └── modes.yaml           # 场景配置（7 种工作流）"
    echo "  └── opencode.json                # OpenCode 项目配置（必需，注册 Superpowers 插件）"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "接下来执行："
echo ""

if [ "$INSTALL_CLAUDE" = true ]; then
    echo "  # Claude Code"
    echo "  cd $PROJECT_DIR"
    echo "  claude"
    echo "  /flow                    # 开始使用"
    echo ""
fi

if [ "$INSTALL_OPENCODE" = true ]; then
    echo "  # OpenCode"
    echo "  cd $PROJECT_DIR"
    echo "  opencode"
    echo "  /flow                    # 开始使用"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
