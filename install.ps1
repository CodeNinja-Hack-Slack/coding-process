# coding-process 项目级安装脚本 (Windows PowerShell)
# 用法：在项目根目录执行
#   irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/void-frost-craft/coding-process.git"
$TEMP_DIR = Join-Path $env:TEMP "coding-process-$(Get-Random)"
$PROJECT_DIR = Get-Location
$CLAUDE_DIR = Join-Path $PROJECT_DIR ".claude"
$COMMANDS_DIR = Join-Path $CLAUDE_DIR "commands"
$CODING_PROCESS_DIR = Join-Path $PROJECT_DIR ".coding-process"

Write-Host "📦 正在安装 coding-process（项目级）..." -ForegroundColor Cyan
Write-Host "📁 安装位置：$PROJECT_DIR" -ForegroundColor Gray
Write-Host ""

# ============================================================
# 1. 检查必需依赖
# ============================================================
Write-Host "🔍 检查必需依赖..." -ForegroundColor Yellow
Write-Host ""

$hasError = $false

# 检查 git
try {
    $null = Get-Command git -ErrorAction Stop
    $gitVersion = git --version 2>$null
    Write-Host "  ✅ git  ($gitVersion)" -ForegroundColor Green
} catch {
    Write-Host "  ❌ git  未安装" -ForegroundColor Red
    Write-Host "     请访问 https://git-scm.com/ 下载安装" -ForegroundColor Gray
    $hasError = $true
}

# 检查 Node.js
try {
    $null = Get-Command node -ErrorAction Stop
    $nodeVersion = node --version 2>$null
    Write-Host "  ✅ Node.js  ($nodeVersion)" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Node.js  未安装" -ForegroundColor Red
    Write-Host "     请访问 https://nodejs.org/ 下载安装" -ForegroundColor Gray
    $hasError = $true
}

# 检查 npm
try {
    $null = Get-Command npm -ErrorAction Stop
    $npmVersion = npm --version 2>$null
    Write-Host "  ✅ npm  ($npmVersion)" -ForegroundColor Green
} catch {
    Write-Host "  ❌ npm  未安装" -ForegroundColor Red
    Write-Host "     通常随 Node.js 一起安装，请重新安装 Node.js" -ForegroundColor Gray
    $hasError = $true
}

# 检查 Claude Code
try {
    $null = Get-Command claude -ErrorAction Stop
    Write-Host "  ✅ Claude Code" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Claude Code  未检测到（可能需要安装）" -ForegroundColor Yellow
    Write-Host "     请访问 https://claude.ai/code 下载安装" -ForegroundColor Gray
}

Write-Host ""

if ($hasError) {
    Write-Host "❌ 缺少必需依赖，请安装后重新运行" -ForegroundColor Red
    exit 1
}

# ============================================================
# 2. 检查可选依赖
# ============================================================
Write-Host "🔍 检查可选依赖..." -ForegroundColor Yellow
Write-Host ""

# 定义 settings.json 路径
$settingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"

# 检查 Superpowers 插件（通过 enabledPlugins 和缓存检测）
$hasSuperpowers = $false
$superpowersVersion = $null

# 方式1：检查 enabledPlugins
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.enabledPlugins -and $settings.enabledPlugins.'superpowers@claude-plugins-official') {
            $hasSuperpowers = $true
        }
    } catch {
        # JSON 解析失败，忽略
    }
}

# 方式2：检查插件缓存获取版本
$cachePath = Join-Path $env:USERPROFILE ".claude\plugins\cache\claude-plugins-official\superpowers"
if (Test-Path $cachePath) {
    # 获取最新版本目录
    $versionDirs = Get-ChildItem -Path $cachePath -Directory | Sort-Object { [version]$_.Name } -ErrorAction SilentlyContinue
    if ($versionDirs) {
        $latestVersion = $versionDirs[-1].Name
        $superpowersVersion = $latestVersion
        $hasSuperpowers = $true
    }
}

if ($hasSuperpowers) {
    if ($superpowersVersion) {
        Write-Host "  ✅ Superpowers 插件  (v$superpowersVersion)" -ForegroundColor Green
    } else {
        Write-Host "  ✅ Superpowers 插件  (已安装)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  Superpowers 插件  未安装（可选）" -ForegroundColor Yellow
    Write-Host "     用途：执行纪律 Skills（TDD、Code Review 等）" -ForegroundColor Gray
    Write-Host "     安装：在 Claude Code 中执行 /plugin install superpowers@claude-plugins-official" -ForegroundColor Gray
}

# 检查 CodeGraph MCP（通过 npm 全局包和 permissions 检测）
$hasCodeGraph = $false
$codegraphVersion = $null

# 方式1：检查 npm 全局安装
try {
    $npmList = npm list -g @colbymchenry/codegraph 2>$null
    if ($npmList -match "@colbymchenry/codegraph@(\d+\.\d+\.\d+)") {
        $codegraphVersion = $matches[1]
        $hasCodeGraph = $true
    }
} catch {
    # npm 命令失败，忽略
}

# 方式2：检查 settings.json 中的 MCP permissions
if (-not $hasCodeGraph -and (Test-Path $settingsPath)) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.permissions -and $settings.permissions.allow) {
            $hasCodegraphPermission = $settings.permissions.allow | Where-Object { $_ -match "mcp__codegraph__" }
            if ($hasCodegraphPermission) {
                $hasCodeGraph = $true
            }
        }
    } catch {
        # JSON 解析失败，忽略
    }
}

if ($hasCodeGraph) {
    if ($codegraphVersion) {
        Write-Host "  ✅ CodeGraph MCP  (v$codegraphVersion)" -ForegroundColor Green
    } else {
        Write-Host "  ✅ CodeGraph MCP  (已安装)" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  CodeGraph MCP  未安装（可选）" -ForegroundColor Yellow
    Write-Host "     用途：代码结构分析、影响评估" -ForegroundColor Gray
    Write-Host "     安装：npm install -g @colbymchenry/codegraph" -ForegroundColor Gray
}

Write-Host ""

# ============================================================
# 3. 克隆仓库
# ============================================================
Write-Host "📥 下载 coding-process..." -ForegroundColor Yellow
try {
    git clone --depth 1 $REPO_URL $TEMP_DIR 2>$null
} catch {
    Write-Host "❌ 下载失败，请检查网络连接" -ForegroundColor Red
    if (Test-Path $TEMP_DIR) { Remove-Item -Recurse -Force $TEMP_DIR }
    exit 1
}

# ============================================================
# 4. 创建目录并复制文件（项目级安装）
# ============================================================

# 创建 .claude/commands 目录
if (!(Test-Path $COMMANDS_DIR)) {
    New-Item -ItemType Directory -Path $COMMANDS_DIR -Force | Out-Null
    Write-Host "📂 创建目录：.claude\commands\" -ForegroundColor Gray
}

# 创建 .coding-process 目录
if (!(Test-Path $CODING_PROCESS_DIR)) {
    New-Item -ItemType Directory -Path $CODING_PROCESS_DIR -Force | Out-Null
    Write-Host "📂 创建目录：.coding-process\" -ForegroundColor Gray
}

# 复制 flow.md（命令入口）
Copy-Item "$TEMP_DIR\.claude\commands\flow.md" "$COMMANDS_DIR\flow.md" -Force
Write-Host "📂 安装 /flow 命令到项目..." -ForegroundColor Yellow

# 复制配置文件到 .coding-process（按需加载，不占 token）
$source = Join-Path $TEMP_DIR ".coding-process\modes.yaml"
$dest = Join-Path $CODING_PROCESS_DIR "modes.yaml"
if (Test-Path $source) {
    Copy-Item $source $dest -Force
}
Write-Host "📂 复制配置文件到 .coding-process/..." -ForegroundColor Yellow

# ============================================================
# 5. 清理
# ============================================================
Remove-Item -Recurse -Force $TEMP_DIR

# ============================================================
# 6. 输出结果
# ============================================================
Write-Host ""
Write-Host "✅ 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "项目目录结构：" -ForegroundColor Cyan
Write-Host ""
Write-Host "  $PROJECT_DIR" -ForegroundColor White
Write-Host "  ├── .claude\" -ForegroundColor Gray
Write-Host "  │   └── commands\" -ForegroundColor Gray
Write-Host "  │       └── flow.md              # /flow 命令（调度器）" -ForegroundColor White
Write-Host "  └── .coding-process\" -ForegroundColor Gray
Write-Host "      └── modes.yaml               # 场景配置（7 种工作流）" -ForegroundColor White
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "接下来执行：" -ForegroundColor Cyan
Write-Host ""
Write-Host "  cd $PROJECT_DIR" -ForegroundColor White
Write-Host "  claude" -ForegroundColor White
Write-Host "  /flow init               # 首次运行，初始化项目配置" -ForegroundColor Gray
Write-Host "  /flow                    # 开始使用" -ForegroundColor Gray
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# 依赖状态汇总
Write-Host "📋 依赖状态汇总：" -ForegroundColor Cyan
Write-Host ""
Write-Host "  必需依赖：" -ForegroundColor White
Write-Host "    ✅ git              ($gitVersion)" -ForegroundColor Green
Write-Host "    ✅ Node.js          (v$nodeVersion)" -ForegroundColor Green
Write-Host "    ✅ npm              (v$npmVersion)" -ForegroundColor Green
Write-Host ""
Write-Host "  可选依赖：" -ForegroundColor White

if ($hasSuperpowers) {
    if ($superpowersVersion) {
        Write-Host "    ✅ Superpowers 插件  (v$superpowersVersion)" -ForegroundColor Green
    } else {
        Write-Host "    ✅ Superpowers 插件  (已安装)" -ForegroundColor Green
    }
} else {
    Write-Host "    ⚠️  Superpowers 插件  未安装  → /plugin install superpowers@claude-plugins-official" -ForegroundColor Yellow
}

if ($hasCodeGraph) {
    if ($codegraphVersion) {
        Write-Host "    ✅ CodeGraph MCP     (v$codegraphVersion)" -ForegroundColor Green
    } else {
        Write-Host "    ✅ CodeGraph MCP     (已配置)" -ForegroundColor Green
    }
} else {
    Write-Host "    ⚠️  CodeGraph MCP     未配置  → 配置 MCP 服务器" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
