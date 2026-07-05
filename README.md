# coding-process

> 不用记 skill 名字，用自然语言描述任务就行

作为 [Superpowers](https://github.com/obra/superpowers) 的调度器，你不需要记住 `subagent-driven-development` 或 `dispatching-parallel-agents` 这些名字，只需用 `/flow 自然语言描述` 你的任务，AI 会自动选择合适的 skills 并按序执行。

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
| Codex | 通过插件市场安装 |
| Trae | 通过插件市场安装 |
| Trae CN | 通过插件市场安装 |

## 安装

在你的项目根目录下执行，选择对应的平台：

### Claude Code

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/claude/.claude ./
rm -rf /tmp/coding-process
```

Windows (PowerShell):
```powershell
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git $env:TEMP\coding-process
Copy-Item -Recurse $env:TEMP\coding-process\claude\.claude .\
Remove-Item -Recurse -Force $env:TEMP\coding-process
```

### OpenCode

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/opencode/.opencode ./
cp /tmp/coding-process/opencode/opencode.json ./
rm -rf /tmp/coding-process
```

Windows (PowerShell):
```powershell
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git $env:TEMP\coding-process
Copy-Item -Recurse $env:TEMP\coding-process\opencode\.opencode .\
Copy-Item $env:TEMP\coding-process\opencode\opencode.json .\
Remove-Item -Recurse -Force $env:TEMP\coding-process
```

### Codex

```bash
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git /tmp/coding-process
cp -r /tmp/coding-process/codex/.codex ./
rm -rf /tmp/coding-process
```

Windows (PowerShell):
```powershell
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git $env:TEMP\coding-process
Copy-Item -Recurse $env:TEMP\coding-process\codex\.codex .\
Remove-Item -Recurse -Force $env:TEMP\coding-process
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

Windows (PowerShell):
```powershell
git clone https://github.com/CodeNinja-Hack-Slack/coding-process.git $env:TEMP\coding-process

# Trae
Copy-Item -Recurse $env:TEMP\coding-process\trae\.trae .\

# 或 Trae CN
Copy-Item -Recurse $env:TEMP\coding-process\trae-cn\.trae-cn .\

Remove-Item -Recurse -Force $env:TEMP\coding-process
```

### 安装后验证

输入 `/flow 你的任务描述`，AI 能识别并开始执行则安装成功。

## 使用方法

```
/flow 用户登录功能                # AI 自动选择 skills 并执行
/flow 修复登录接口 500 错误        # AI 选择调试 → 修复 → 验证
/flow 改一下超时配置              # 简单修改，轻量流程
/flow 审查用户模块代码            # 只做代码审查
/flow 重构这个函数                # AI 选择分析 → 重构 → 验证
/flow tdd 写支付模块              # AI 使用测试驱动开发
/flow 理解这个模块的架构          # 只读分析，不修改文件
```

AI 会根据你的描述自动选择合适的 skills 直接执行。Superpowers 的各 skill 本身会在需要时与你交互确认（如 brainstorming 阶段会确认方案）。

## 工作原理

1. 你用自然语言描述任务
2. AI 根据 skill 目录和决策规则，选择需要的 skills 并排列顺序
3. 按序执行每个 skill

### 可用 Skills

| Skill | 用途 |
|-------|------|
| brainstorming | 需求梳理与方案设计 |
| writing-plans | 制定实施计划 |
| using-git-worktrees | 创建隔离工作分支 |
| subagent-driven-development | 子代理驱动开发（默认） |
| test-driven-development | 测试驱动开发 |
| executing-plans | 批量执行计划（带人工检查点） |
| dispatching-parallel-agents | 并行子代理开发 |
| systematic-debugging | 系统化调试定位 |
| verification-before-completion | 完成前验证 |
| requesting-code-review | 请求代码审查 |
| receiving-code-review | 处理审查反馈 |
| finishing-a-development-branch | 分支收尾 |

### 决策规则

- 只读任务只用 `brainstorming`，不修改文件
- 涉及代码修改时，必须先用 `using-git-worktrees` 创建分支
- 涉及代码修改时，必须包含 `verification-before-completion`
- 修 bug 先用 `systematic-debugging` 定位根因
- 复杂任务先 `brainstorming` → `writing-plans`，再开发
- 开发方式三选一：`subagent-driven-development`（默认）、`test-driven-development`（要求 TDD）、`dispatching-parallel-agents`（可并行）
- 简单任务不需要完整流程，只选真正需要的 skills

## 项目结构

```
coding-process/
├── src/                            # 源文件（单一来源）
│   └── flow.md
├── scripts/                        # 构建脚本
│   └── build.ps1
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

| 类型 | 目录格式 | Frontmatter | 代表平台 |
|------|----------|-------------|----------|
| Commands 类 | `.<平台>/commands/<命令名>.md` | `description` | Claude Code |
| Commands 类 | `.<平台>/commands/<命令名>.md` | `description` + `agent` | OpenCode |
| Skills 类 | `.<平台>/skills/<技能名>/SKILL.md` | `name` + `description` | Codex、Trae |

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

### 第四步：更新构建脚本和 README

1. 在 `scripts/build.ps1` 中添加新平台的生成逻辑
2. 在 README 中添加新平台的安装命令和项目结构
3. 运行构建脚本验证

### 注意事项

1. **Superpowers 依赖**：新平台必须能加载 Superpowers skills，否则 `/flow` 无法执行
2. **变量语法**：不同平台传递用户输入的变量语法可能不同：
   - Claude Code: `$ARGUMENTS`
   - Codex: `$ARGUMENTS`
   - 其他平台：查阅文档确认
3. **frontmatter**：各平台使用不同的 frontmatter 字段：
   - Claude Code: `description`
   - OpenCode: `description` + `agent`
   - Codex/Trae/Trae CN: `name` + `description`
   具体格式参考构建脚本 `scripts/build.ps1`
4. **测试**：安装后务必测试 `/flow` 是否能正常工作
5. **维护源文件**：所有平台文件由 `src/flow.md` 通过 `scripts/build.ps1` 生成，修改时只改 `src/flow.md`，然后运行构建脚本同步所有平台

## 卸载

删除对应平台的文件即可。

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| `/flow` 没有反应 | 检查 Superpowers 是否已安装（见前置依赖部分） |
| AI 选择的 skills 不合适 | 在对话中告诉 AI 需要调整，或更详细地描述任务 |
| 修改源文件后各平台版本不一致 | 运行构建脚本：`pwsh scripts/build.ps1` |
| Windows 下安装命令不兼容 | 使用上方 PowerShell 命令安装 |

## 许可证

[MIT](LICENSE)
