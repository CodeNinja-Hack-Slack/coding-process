# coding-process

> AI 编程工作流编排工具 —— 用自然语言驱动开发任务

coding-process 支持多种 AI 编程平台，作为 [Superpowers](https://github.com/obra/superpowers) 的调度器，让你用 `/flow 自然语言描述` 执行开发任务。

## 支持的平台

| 平台 | 状态 |
|------|------|
| Claude Code | ✓ 已适配 |
| OpenCode | ✓ 已适配 |
| Codex | ✓ 已适配 |
| Trae | ✓ 已适配 |
| Trae CN | ✓ 已适配 |

## 前置依赖

使用前必须先安装 [Superpowers](https://github.com/obra/superpowers)，它提供了所有 skills。

| 平台 | 安装方式 |
|------|----------|
| Claude Code | `/plugin install superpowers@claude-plugins-official` |
| OpenCode | 通过 `opencode.json` 自动注册 |
| Codex | 已内置 |
| Trae | 已内置 |
| Trae CN | 已内置 |

## 安装

在你的项目根目录下执行，选择对应的平台：

### Claude Code

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/claude/.claude ./
rm -rf /tmp/coding-process
```

### OpenCode

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/opencode/.opencode ./
cp /tmp/coding-process/opencode/opencode.json ./
rm -rf /tmp/coding-process
```

### Codex

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/codex/.codex ./
rm -rf /tmp/coding-process
```

### Trae / Trae CN

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process

# Trae
cp -r /tmp/coding-process/trae/.trae ./

# 或 Trae CN
cp -r /tmp/coding-process/trae-cn/.trae-cn ./

rm -rf /tmp/coding-process
```

### 安装后验证

输入 `/flow`，如果显示场景选择菜单则安装成功。

## 使用方法

```
/flow 用户登录功能              # 新功能
/flow 修复登录接口 500 错误      # 修 bug
/flow 改一下超时配置            # 快速修改
/flow 审查用户模块代码          # 代码审查
/flow 重构这个函数              # 重构
/flow tdd 写支付模块            # TDD 开发
/flow 并行开发用户管理模块      # 并行开发
/flow resume                    # 从上次中断处继续
/flow status                    # 查看当前进度
```

## 7 种工作流场景

| 场景 | 触发词 | 流程 |
|------|--------|------|
| **新功能** | 功能、feature、添加、创建 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review → verification → finishing |
| **修 bug** | bug、修复、fix、问题、异常 | systematic-debugging → subagent-driven-development → verification |
| **快速修改** | 改、typo、配置、调整 | subagent-driven-development → finishing |
| **代码审查** | review、审查、检查 | requesting-code-review |
| **重构** | refactor、重构、优化 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review → verification → finishing |
| **TDD 开发** | tdd、测试驱动 | brainstorming → test-driven-development → requesting-code-review → verification → finishing |
| **并行开发** | 并行、parallel、同时 | brainstorming → dispatching-parallel-agents → requesting-code-review → verification → finishing |

## 项目结构

```
coding-process/
├── claude/                        # Claude Code
│   └── .claude/commands/flow.md
├── opencode/                      # OpenCode
│   ├── .opencode/commands/flow.md
│   └── opencode.json
├── codex/                         # Codex
│   └── .codex/skills/flow/SKILL.md
├── trae/                          # Trae
│   └── .trae/skills/flow/SKILL.md
├── trae-cn/                       # Trae CN
│   └── .trae-cn/skills/flow/SKILL.md
├── LICENSE
└── README.md
```

## 新增平台适配指南

如果你想为新平台添加支持，按以下步骤操作。

### 第一步：确定平台的自定义命令目录

每个平台有自己的目录约定。常见模式：

| 类型 | 目录格式 | 代表平台 |
|------|----------|----------|
| Commands 类 | `.<平台>/commands/<命令名>.md` | Claude Code、OpenCode |
| Skills 类 | `.<平台>/skills/<技能名>/SKILL.md` | Codex、Trae |

**如何找到平台的目录：**

```bash
# 查看用户主目录下的隐藏目录
ls -la ~ | grep '^\.'

# 找到平台目录后，查看其结构
ls -la ~/.<平台名>/
```

例如要适配 Gemini CLI：

```bash
# 1. 查找 Gemini 相关目录
ls -la ~/.gemini/

# 2. 查看是否有 commands 或 skills 目录
ls -la ~/.gemini/commands/ 2>/dev/null || ls -la ~/.gemini/skills/ 2>/dev/null
```

### 第二步：确定文件格式

**Commands 类平台**（如 Claude Code）使用普通 markdown 文件：

```markdown
# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

你是流程调度器...
```

**Skills 类平台**（如 Codex、Trae）使用带 frontmatter 的 markdown 文件：

```markdown
---
name: flow
description: "AI 编程工作流编排"
---

# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

你是流程调度器...
```

### 第三步：创建适配文件

假设要为 **Gemini CLI** 添加支持，且发现它使用 skills 类目录 `.gemini/skills/`：

```bash
# 1. 创建目录结构
mkdir -p gemini/.gemini/skills/flow

# 2. 创建 SKILL.md（从现有 Codex 版本复制并修改）
cat > gemini/.gemini/skills/flow/SKILL.md << 'EOF'
---
name: flow
description: "AI 编程工作流编排 — 自然语言驱动开发任务"
---

# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

你是流程调度器，根据用户任务自动选择场景并调用 Superpowers skills。

...（完整内容参考 codex/.codex/skills/flow/SKILL.md）
EOF
```

### 第四步：更新 README

在 README 中添加：

1. 支持的平台表格中添加新平台
2. 安装部分添加新平台的安装命令
3. 项目结构中添加新平台目录

### 完整示例：适配一个新的 Skills 类平台

假设新平台叫 **AwesomeAI**，目录约定为 `.awesome/skills/<name>/SKILL.md`：

```
# 1. 创建目录
mkdir -p awesome/.awesome/skills/flow

# 2. 创建 SKILL.md
#    内容参考 codex/.codex/skills/flow/SKILL.md
#    保持 frontmatter 格式一致

# 3. 测试安装
cp -r awesome/.awesome ./

# 4. 验证
#    启动平台，输入 /flow，检查是否显示场景菜单
```

### 完整示例：适配一个新的 Commands 类平台

假设新平台叫 **SuperAI**，目录约定为 `.super/commands/<name>.md`：

```
# 1. 创建目录
mkdir -p super/.super/commands

# 2. 创建 flow.md
#    内容参考 claude/.claude/commands/flow.md
#    注意：$ARGUMENTS 是平台用于传递用户输入的变量，
#    如果平台使用其他变量名（如 {{input}}），需要替换

# 3. 测试安装
cp -r super/.super ./

# 4. 验证
#    启动平台，输入 /flow，检查是否正常工作
```

### 注意事项

1. **Superpowers 依赖**：新平台必须能加载 Superpowers skills，否则 `/flow` 无法执行
2. **变量语法**：不同平台传递用户输入的变量语法可能不同：
   - Claude Code: `$ARGUMENTS`
   - Codex: `$ARGUMENTS`
   - 其他平台：查阅文档确认
3. **frontmatter**：Skills 类平台通常需要 frontmatter（`---` 包裹的 YAML），Commands 类平台不需要
4. **测试**：安装后务必测试 `/flow` 是否能正常显示场景菜单

## 卸载

删除对应平台的文件即可。

## 许可证

[MIT](LICENSE)
