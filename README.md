# coding-process

> AI 编程工作流编排工具 —— 用自然语言驱动开发任务

coding-process 是一个跨平台 AI 编程流程编排工具，支持 **Claude Code**、**OpenCode** 和 **Codex**。
作为 [Superpowers](https://github.com/obra/superpowers) 的调度器，让你用 `/flow 自然语言描述` 执行各种开发任务。

## 前置依赖

使用前必须先安装 [Superpowers](https://github.com/obra/superpowers)，它提供了所有 skills。

| 平台 | 安装 Superpowers |
|------|------------------|
| **Claude Code** | `/plugin install superpowers@claude-plugins-official` |
| **OpenCode** | 通过 `opencode.json` 自动注册 |
| **Codex** | 已内置（`.codex/skills/` 目录） |

## 安装

在你的项目根目录下执行，选择对应的平台：

### Claude Code

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
mkdir -p .claude/commands
cp /tmp/coding-process/.claude/commands/flow.md .claude/commands/
rm -rf /tmp/coding-process
```

### OpenCode

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
mkdir -p .opencode/commands
cp /tmp/coding-process/.opencode/commands/flow.md .opencode/commands/
cp /tmp/coding-process/opencode.json ./opencode.json
rm -rf /tmp/coding-process
```

重启 OpenCode 使 Superpowers 插件生效。

### Codex

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
mkdir -p .codex/skills/flow
cp /tmp/coding-process/.codex/skills/flow/SKILL.md .codex/skills/flow/
rm -rf /tmp/coding-process
```

### 安装后验证

| 平台 | 验证方式 |
|------|----------|
| **Claude Code** | 输入 `/flow`，显示场景菜单则成功 |
| **OpenCode** | 输入 `/flow`，显示场景菜单则成功 |
| **Codex** | 输入 `/flow`，显示场景菜单则成功 |

如果提示找不到命令，请检查对应目录下的文件是否存在。

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
your-project/
├── .claude/commands/flow.md       # Claude Code
├── .opencode/commands/flow.md     # OpenCode
├── .codex/skills/flow/SKILL.md    # Codex
└── opencode.json                  # OpenCode 配置
```

根据你使用的平台，只需复制对应的文件。

## 卸载

删除对应平台的文件即可：

```bash
# Claude Code
rm -rf .claude/

# OpenCode
rm -rf .opencode/ opencode.json

# Codex
rm -rf .codex/

# 全部删除
rm -rf .claude/ .opencode/ .codex/ opencode.json
```

## 许可证

[MIT](LICENSE)
