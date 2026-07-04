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

## 卸载

删除对应平台的文件即可。

## 许可证

[MIT](LICENSE)
