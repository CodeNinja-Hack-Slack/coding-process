# coding-process

> AI 编程工作流编排工具 —— 用自然语言驱动开发任务

coding-process 是一个跨平台 AI 编程流程编排工具，支持 **Claude Code** 和 **OpenCode**。

让你用 `/flow 自然语言描述` 来执行各种开发任务，自动调用 [Superpowers](https://github.com/obra/superpowers) 的 skills。

**核心价值**：不用记复杂的开发流程，说清楚想做什么就行。

## 前置依赖

| 平台 | 依赖 | 安装方式 |
|------|------|----------|
| **Claude Code** | [Claude Code](https://claude.ai/code) + [Superpowers](https://github.com/obra/superpowers) | `claude` + `/plugin install superpowers@claude-plugins-official` |
| **OpenCode** | [OpenCode](https://opencode.ai) + [Superpowers](https://github.com/obra/superpowers) | `opencode` + 在 `opencode.json` 中添加 `"plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]` |

> **注意**：Superpowers 是必需依赖，提供了所有 skills。skills 由 Superpowers 插件全局提供，**不需要**存放在项目中。

## 安装

### 方式一：使用安装脚本（推荐）

先进入你的项目根目录，然后执行安装命令：

macOS / Linux：

```bash
cd your-project

# 安装两个平台版本
curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash

# 或仅安装 OpenCode 版本
curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash -s -- --opencode

# 或仅安装 Claude Code 版本
curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash -s -- --claude
```

Windows PowerShell：

```powershell
cd your-project

# 安装两个平台版本
irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex

# 或仅安装 OpenCode 版本
irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex -ArgumentList "--opencode"

# 或仅安装 Claude Code 版本
irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex -ArgumentList "--claude"
```

### 方式二：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/void-frost-craft/coding-process.git /tmp/coding-process

# 2. 进入你的项目目录
cd /path/to/your/project

# ========== Claude Code 版本 ==========
mkdir -p .claude/commands .claude/modes
cp /tmp/coding-process/.claude/commands/flow.md .claude/commands/
cp /tmp/coding-process/.coding-process/modes.yaml .claude/modes/modes.yaml

# ========== OpenCode 版本 ==========
mkdir -p .opencode/commands .opencode/modes
cp /tmp/coding-process/.opencode/commands/flow.md .opencode/commands/
cp /tmp/coding-process/.opencode/modes/modes.yaml .opencode/modes/

# 必需：OpenCode 项目配置（注册 Superpowers 插件和 /flow 命令）
cp /tmp/coding-process/opencode.json ./opencode.json

# 3. 清理
rm -rf /tmp/coding-process
```

## 使用方法

### 基本用法

```
/flow 用户登录功能              # 新功能
/flow 修复登录接口 500 错误      # 修 bug
/flow 改一下超时配置            # 快速修改
/flow 审查用户模块代码          # 代码审查
/flow 重构这个函数              # 重构
/flow tdd 写支付模块            # TDD 开发
/flow 并行开发用户管理模块      # 并行开发
```

### 无参数调用

```
/flow
```

显示场景选择菜单：

```
📋 请选择工作流场景：

1. 新功能 — 开发完整功能
2. 修 bug — 修复问题
3. 快速修改 — 小改动、配置调整
4. 代码审查 — 审查现有代码
5. 重构 — 优化代码结构
6. TDD 开发 — 测试驱动开发
7. 并行开发 — 并行执行多个任务

请输入序号或描述：
```

## 7 种工作流场景

| 场景 | 触发词 | 流程 |
|------|--------|------|
| **新功能** | 功能、feature、添加、创建 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review → finishing |
| **修 bug** | bug、修复、fix、问题、异常 | systematic-debugging → subagent-driven-development → verification-before-completion |
| **快速修改** | 改、typo、配置、调整 | subagent-driven-development → finishing |
| **代码审查** | review、审查、检查 | requesting-code-review |
| **重构** | refactor、重构、优化 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review |
| **TDD 开发** | tdd、测试驱动 | brainstorming → test-driven-development → requesting-code-review → finishing |
| **并行开发** | 并行、parallel、同时 | brainstorming → dispatching-parallel-agents → requesting-code-review → finishing |

> **💡 AI 智能识别**：使用 `/flow 任务描述` 时，AI 会分析你的自然语言，自动选择最合适的场景。不需要记触发词，说清楚想做什么就行。

## 项目结构

### Claude Code 版本

```
your-project/
├── .claude/
│   ├── commands/
│   │   └── flow.md          # /flow 命令（调度器）
│   ├── modes/
│   │   └── modes.yaml       # 场景配置（7 种工作流）
│   └── skills/              # （可选，由 Superpowers 插件全局提供）
```

### OpenCode 版本

```
your-project/
├── .opencode/
│   ├── commands/
│   │   └── flow.md          # /flow 命令（调度器）
│   ├── skills/              # （可选，由 Superpowers 插件全局提供）
│   └── modes/
│       └── modes.yaml       # 场景配置（7 种工作流）
└── opencode.json            # OpenCode 项目配置（必需，注册 Superpowers 插件）
```

> **注意**：skills 目录不需要手动创建或复制，Superpowers 插件会自动加载。

## 自定义场景

编辑对应平台的 modes.yaml 即可自定义工作流场景：

```yaml
modes:
  testing:
    name: 测试模式
    description: 为现有代码添加测试
    triggers:
      keywords: [测试, test, 单元测试]
    stages:
      - name: EXPLORING
        skill: brainstorming
        description: 理解代码结构
      - name: BUILDING
        skill: subagent-driven-development
        description: 编写测试
      - name: VERIFYING
        skill: verification-before-completion
        description: 验证测试
```

## 特殊命令

| 命令 | 作用 |
|------|------|
| `/flow stop` | 终止当前流程 |
| `/flow status` | 显示当前执行状态 |

## 卸载

```bash
# 删除 Claude Code 版本
rm -rf .claude/

# 删除 OpenCode 版本
rm -rf .opencode/
rm opencode.json
```

## 许可证

[MIT](LICENSE)
