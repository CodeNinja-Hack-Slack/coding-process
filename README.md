# coding-process

> AI 编程工作流编排工具 —— 用自然语言驱动 Superpowers skills

coding-process 是一个 Claude Code slash command 插件，让你用 `/flow 自然语言描述` 来执行各种开发任务，自动调用 Superpowers skills。

**核心价值**：不用记 Superpowers 繁琐的 skill 命令，说清楚想做什么就行。

## 功能特性

- 🧠 **自然语言驱动**：说"修复登录 bug"，AI 自动选择合适的流程
- 🎯 **7 种工作流场景**：覆盖新功能、修 bug、快速修改、审查、重构、TDD、并行开发
- 🔍 **CodeGraph 集成**：代码搜索、调用链追踪、影响分析
- 🔗 **Superpowers 集成**：自动调用 TDD、子代理开发、代码审查等 skills
- 📦 **极简架构**：一个命令文件 + 一个配置文件

## 前置依赖

| 依赖 | 用途 | 安装方式 |
|------|------|----------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | AI 编程助手 | `npm install -g @anthropic-ai/claude-code` |
| [Superpowers](https://github.com/obra/superpowers) | 开发方法论 skills | `/plugin install superpowers@claude-plugins-official` |
| [CodeGraph MCP](https://github.com/aspect-build/aspect-code-graph-mcp) | 代码上下文分析 | Claude Code MCP 配置 |

### 安装 Superpowers

在 Claude Code 中执行：

```
/plugin install superpowers@claude-plugins-official
```

### 配置 CodeGraph MCP

在 Claude Code 设置中添加 MCP server：

```json
{
  "mcpServers": {
    "codegraph": {
      "command": "npx",
      "args": ["-y", "@aspect-build/code-graph-mcp"]
    }
  }
}
```

## 安装

### 方式一：使用安装脚本（推荐）

先进入你的项目根目录，然后执行安装命令：

macOS / Linux：

```bash
cd your-project
curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash
```

Windows PowerShell：

```powershell
cd your-project
irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex
```

### 方式二：手动安装

```bash
# 1. 克隆仓库
git clone https://github.com/void-frost-craft/coding-process.git /tmp/coding-process

# 2. 进入你的项目目录
cd /path/to/your/project

# 3. 创建目录
mkdir -p .claude/commands .coding-process

# 4. 复制文件
cp /tmp/coding-process/.claude/commands/flow.md .claude/commands/
cp /tmp/coding-process/.coding-process/modes.yaml .coding-process/

# 5. 清理
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

## CodeGraph 集成

CodeGraph 提供代码上下文分析，帮助 AI 更准确地理解项目：

| 阶段 | CodeGraph 工具 | 用途 |
|------|---------------|------|
| 探索 | `codegraph_files` + `codegraph_search` | 获取项目结构和相关符号 |
| 构建 | `codegraph_callees` + `codegraph_callers` | 分析函数调用关系 |
| 审查 | `codegraph_trace` | 追踪完整调用路径 |

## 项目结构

```
your-project/
├── .claude/
│   └── commands/
│       └── flow.md          # /flow 命令（调度器）
└── .coding-process/
    └── modes.yaml           # 场景配置（7 种工作流）
```

## 自定义场景

编辑 `.coding-process/modes.yaml` 即可自定义工作流场景：

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
        codegraph: true
        description: 理解代码结构
      - name: BUILDING
        skill: subagent-driven-development
        codegraph: true
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
# 删除项目配置
rm -rf .coding-process/

# 删除命令文件
rm .claude/commands/flow.md
```

## 许可证

[MIT](LICENSE)
