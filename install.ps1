# coding-process 项目级安装脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenCode 双平台
# 注意：需要先安装 Superpowers 插件
# 用法：
#   irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex
#   irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex -ArgumentList "--opencode"
#   irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex -ArgumentList "--claude"

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/void-frost-craft/coding-process.git"
$TEMP_DIR = Join-Path $env:TEMP "coding-process-$(Get-Random)"
$PROJECT_DIR = Get-Location

# 解析参数
$INSTALL_OPENCODE = $false
$INSTALL_CLAUDE = $false

foreach ($arg in $args) {
    switch ($arg) {
        "--opencode" { $INSTALL_OPENCODE = $true }
        "--claude" { $INSTALL_CLAUDE = $true }
        default {
            $INSTALL_OPENCODE = $true
            $INSTALL_CLAUDE = $true
        }
    }
}

# 如果只指定了一个，另一个也安装
if ($INSTALL_OPENCODE -or $INSTALL_CLAUDE) {
    $INSTALL_OPENCODE = $true
    $INSTALL_CLAUDE = $true
}

Write-Host "📦 正在安装 coding-process（项目级）..." -ForegroundColor Cyan
Write-Host "📁 安装位置：$PROJECT_DIR" -ForegroundColor Gray
Write-Host "📋 安装平台：Claude Code=$INSTALL_CLAUDE, OpenCode=$INSTALL_OPENCODE" -ForegroundColor Gray
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

# 检查 Claude Code（可选）
if ($INSTALL_CLAUDE) {
    try {
        $null = Get-Command claude -ErrorAction Stop
        Write-Host "  ✅ Claude Code" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Claude Code  未检测到（可选）" -ForegroundColor Yellow
        Write-Host "     请访问 https://claude.ai/code 下载安装" -ForegroundColor Gray
    }
}

# 检查 OpenCode（可选）
if ($INSTALL_OPENCODE) {
    try {
        $null = Get-Command opencode -ErrorAction Stop
        $opcVersion = opencode --version 2>$null
        Write-Host "  ✅ OpenCode  ($opcVersion)" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  OpenCode  未检测到（可选）" -ForegroundColor Yellow
        Write-Host "     请访问 https://opencode.ai 下载安装" -ForegroundColor Gray
    }
}

Write-Host ""

if ($hasError) {
    Write-Host "❌ 缺少必需依赖，请安装后重新运行" -ForegroundColor Red
    exit 1
}

# ============================================================
# 2. 检查 Superpowers（必需依赖）
# ============================================================
Write-Host "🔍 检查 Superpowers..." -ForegroundColor Yellow
Write-Host ""

$hasSuperpowers = $false

# 检查 Claude Code 的 Superpowers
if ($INSTALL_CLAUDE) {
    # 检查插件目录
    $pluginDir = Join-Path $env:USERPROFILE ".claude\plugins"
    if (Test-Path $pluginDir) {
        $superpowersDirs = Get-ChildItem -Path $pluginDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*superpowers*" }
        if ($superpowersDirs) {
            $hasSuperpowers = $true
            Write-Host "  ✅ Superpowers 插件  (Claude Code)" -ForegroundColor Green
        }
    }
    
    # 检查 settings.json
    $settingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (Test-Path $settingsPath) {
        try {
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
            if ($settings.enabledPlugins.'superpowers@claude-plugins-official') {
                $hasSuperpowers = $true
                Write-Host "  ✅ Superpowers 插件  (Claude Code)" -ForegroundColor Green
            }
        } catch {
            # JSON 解析失败，忽略
        }
    }
}

# 检查 OpenCode 的 Superpowers
if ($INSTALL_OPENCODE) {
    # 检查项目级 opencode.json
    $projectConfig = Join-Path $PROJECT_DIR "opencode.json"
    if (Test-Path $projectConfig) {
        try {
            $config = Get-Content $projectConfig -Raw | ConvertFrom-Json
            if ($config.plugin -and ($config.plugin -match "superpowers")) {
                $hasSuperpowers = $true
                Write-Host "  ✅ Superpowers 插件  (OpenCode)" -ForegroundColor Green
            }
        } catch {
            # JSON 解析失败，忽略
        }
    }
    
    # 检查全局 opencode.json
    $globalConfig = Join-Path $env:USERPROFILE ".config\opencode\opencode.json"
    if (Test-Path $globalConfig) {
        try {
            $config = Get-Content $globalConfig -Raw | ConvertFrom-Json
            if ($config.plugin -and ($config.plugin -match "superpowers")) {
                $hasSuperpowers = $true
                Write-Host "  ✅ Superpowers 插件  (OpenCode)" -ForegroundColor Green
            }
        } catch {
            # JSON 解析失败，忽略
        }
    }
}

if (-not $hasSuperpowers) {
    Write-Host "  ⚠️  Superpowers 插件  未检测到（必需依赖）" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "     请先安装 Superpowers：" -ForegroundColor Gray
    Write-Host ""
    
    if ($INSTALL_CLAUDE) {
        Write-Host "     Claude Code:" -ForegroundColor Gray
        Write-Host "     /plugin install superpowers@claude-plugins-official" -ForegroundColor White
        Write-Host ""
    }
    
    if ($INSTALL_OPENCODE) {
        Write-Host "     OpenCode:" -ForegroundColor Gray
        Write-Host "     在 opencode.json 中添加：" -ForegroundColor Gray
        Write-Host '     {
       "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
     }' -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "     安装后请重新运行此脚本" -ForegroundColor Gray
    Write-Host ""
    
    $response = Read-Host "是否继续安装？(y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "❌ 安装已取消" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# ============================================================
# 3. 克隆仓库
# ============================================================
Write-Host "📥 下载 coding-process..." -ForegroundColor Yellow
try {
    git clone --depth 1 $REPO_URL $TEMP_DIR 2>$null | Out-Null
} catch {
    Write-Host "❌ 下载失败，请检查网络连接" -ForegroundColor Red
    if (Test-Path $TEMP_DIR) { Remove-Item -Recurse -Force $TEMP_DIR }
    exit 1
}

# ============================================================
# 4. 创建目录并复制文件（项目级安装）
# ============================================================

# 安装 Claude Code 版本
if ($INSTALL_CLAUDE) {
    Write-Host ""
    Write-Host "📦 安装 Claude Code 版本..." -ForegroundColor Cyan
    
    # 创建目录
    $claudeDirs = @(
        "$PROJECT_DIR\.claude\commands",
        "$PROJECT_DIR\.claude\modes"
    )
    foreach ($dir in $claudeDirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # 复制 flow.md
    $sourceFlow = Join-Path $TEMP_DIR ".claude\commands\flow.md"
    $destFlow = Join-Path $PROJECT_DIR ".claude\commands\flow.md"
    if (Test-Path $sourceFlow) {
        Copy-Item $sourceFlow $destFlow -Force
        Write-Host "📂 安装 /flow 命令到 .claude/commands/" -ForegroundColor Yellow
    }
    
    # 复制 modes.yaml
    $sourceModes = Join-Path $TEMP_DIR ".coding-process\modes.yaml"
    $destModes = Join-Path $PROJECT_DIR ".claude\modes\modes.yaml"
    if (Test-Path $sourceModes) {
        Copy-Item $sourceModes $destModes -Force
        Write-Host "📂 安装场景配置到 .claude/modes/" -ForegroundColor Yellow
    }
}

# 安装 OpenCode 版本
if ($INSTALL_OPENCODE) {
    Write-Host ""
    Write-Host "📦 安装 OpenCode 版本..." -ForegroundColor Cyan
    
    # 创建目录
    $opencodeDirs = @(
        "$PROJECT_DIR\.opencode\commands",
        "$PROJECT_DIR\.opencode\modes"
    )
    foreach ($dir in $opencodeDirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # 复制 flow.md
    $sourceFlow = Join-Path $TEMP_DIR ".opencode\commands\flow.md"
    $destFlow = Join-Path $PROJECT_DIR ".opencode\commands\flow.md"
    if (Test-Path $sourceFlow) {
        Copy-Item $sourceFlow $destFlow -Force
        Write-Host "📂 安装 /flow 命令到 .opencode/commands/" -ForegroundColor Yellow
    }
    
    # 复制 modes.yaml
    $sourceModes = Join-Path $TEMP_DIR ".opencode\modes\modes.yaml"
    $destModes = Join-Path $PROJECT_DIR ".opencode\modes\modes.yaml"
    if (Test-Path $sourceModes) {
        Copy-Item $sourceModes $destModes -Force
        Write-Host "📂 安装场景配置到 .opencode/modes/" -ForegroundColor Yellow
    }
    
    # 复制 opencode.json（必需：注册 Superpowers 插件和 /flow 命令）
    $sourceConfig = Join-Path $TEMP_DIR "opencode.json"
    $destConfig = Join-Path $PROJECT_DIR "opencode.json"
    if (Test-Path $sourceConfig) {
        if (!(Test-Path $destConfig)) {
            Copy-Item $sourceConfig $destConfig -Force
            Write-Host "📂 创建 opencode.json..." -ForegroundColor Yellow
        } else {
            Write-Host "⚠️  opencode.json 已存在，跳过（请手动合并配置）" -ForegroundColor Yellow
        }
    }
}

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

if ($INSTALL_CLAUDE) {
    Write-Host "  Claude Code 版本：" -ForegroundColor White
    Write-Host "  ├── .claude\" -ForegroundColor Gray
    Write-Host "  │   ├── commands\" -ForegroundColor Gray
    Write-Host "  │   │   └── flow.md              # /flow 命令（调度器）" -ForegroundColor White
    Write-Host "  │   ├── modes/" -ForegroundColor Gray
    Write-Host "  │   │   └── modes.yaml           # 场景配置（7 种工作流）" -ForegroundColor White
    Write-Host "  │   └── skills/                  # （由 Superpowers 插件全局提供）" -ForegroundColor Gray
    Write-Host ""
}

if ($INSTALL_OPENCODE) {
    Write-Host "  OpenCode 版本：" -ForegroundColor White
    Write-Host "  ├── .opencode\" -ForegroundColor Gray
    Write-Host "  │   ├── commands\" -ForegroundColor Gray
    Write-Host "  │   │   └── flow.md              # /flow 命令（调度器）" -ForegroundColor White
    Write-Host "  │   ├── skills/                  # （由 Superpowers 插件全局提供）" -ForegroundColor Gray
    Write-Host "  │   └── modes/" -ForegroundColor Gray
    Write-Host "  │       └── modes.yaml           # 场景配置（7 种工作流）" -ForegroundColor White
    Write-Host "  └── opencode.json                # OpenCode 项目配置（必需，注册 Superpowers 插件）" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "接下来执行：" -ForegroundColor Cyan
Write-Host ""

if ($INSTALL_CLAUDE) {
    Write-Host "  # Claude Code" -ForegroundColor Gray
    Write-Host "  cd $PROJECT_DIR" -ForegroundColor White
    Write-Host "  claude" -ForegroundColor White
    Write-Host "  /flow                    # 开始使用" -ForegroundColor Gray
    Write-Host ""
}

if ($INSTALL_OPENCODE) {
    Write-Host "  # OpenCode" -ForegroundColor Gray
    Write-Host "  cd $PROJECT_DIR" -ForegroundColor White
    Write-Host "  opencode" -ForegroundColor White
    Write-Host "  /flow                    # 开始使用" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
