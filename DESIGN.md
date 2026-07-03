# coding-process 设计文档

> 版本：6.0
> 日期：2026-07-04
> 状态：Superpowers 调度器

---

## 1. 项目概述

### 1.1 项目定位

coding-process 是一个轻量级 AI 编程流程编排工具，作为 [Superpowers](https://github.com/obra/superpowers) 的调度器，支持 Claude Code 和 OpenCode。

**核心价值**：不用记 Superpowers 的复杂流程，用 `/flow 自然语言描述` 即可。

### 1.2 解决的问题

Superpowers 提供了 14+ 个 skills，覆盖完整的开发流程：
- brainstorming、writing-plans、subagent-driven-development
- systematic-debugging、test-driven-development
- requesting-code-review、finishing-a-development-branch
- ...

但直接使用 Superpowers 需要：
1. 记住每个 skill 的名称和用途
2. 手动判断应该使用哪个 skill
3. 手动管理阶段间的切换

coding-process 解决了这些问题：
1. **自然语言驱动**：说任务，AI 自动选择场景
2. **自动调度**：自动按顺序调用对应的 skill
3. **极简配置**：只保留场景定义，不包含任何 skills

### 1.3 依赖关系

| 组件 | 角色 | 说明 |
|------|------|------|
| **Superpowers** | 核心能力 | 提供所有 skills（14+ skills） |
| **coding-process** | 调度器 | 识别场景、调度 skills |
| **Claude Code / OpenCode** | 执行平台 | 运行 AI 和 skills |

### 1.4 核心设计原则

1. **Superpowers 优先** — 所有执行能力来自 Superpowers，本项目只做调度
2. **自然语言驱动** — 用户说任务，AI 自动选择场景
3. **双平台兼容** — 一套配置，Claude Code 和 OpenCode 都能用
4. **极简架构** — 调度器 + 配置文件，无冗余代码

---

## 2. 场景设计

### 2.1 七种核心场景

| 场景 | 触发词 | 流程 |
|------|--------|------|
| **新功能** | 功能、feature、添加、创建 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review → finishing |
| **修 bug** | bug、修复、fix、问题、异常 | systematic-debugging → subagent-driven-development → verification-before-completion |
| **快速修改** | 改、typo、配置、调整 | subagent-driven-development → finishing |
| **代码审查** | review、审查、检查 | requesting-code-review |
| **重构** | refactor、重构、优化 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review |
| **TDD 开发** | tdd、测试驱动 | brainstorming → test-driven-development → requesting-code-review → finishing |
| **并行开发** | 并行、parallel、同时 | brainstorming → dispatching-parallel-agents → requesting-code-review → finishing |

### 2.2 自然语言识别

AI 通过以下维度判断场景：

- **关键词匹配**：检查 modes.yaml 中的 triggers.keywords
- **意图识别**：创建新东西？修复问题？优化代码？
- **复杂度判断**：简单修改？完整功能？多模块？
- **方法论**：是否提到 TDD、测试驱动、并行？

### 2.3 自定义场景

用户可通过编辑对应平台的 modes.yaml 自定义场景：

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

---

## 3. 架构设计

### 3.1 分层架构

```
┌─────────────────────────────────────┐
│          User Input                  │
│     "/flow 修复登录 bug"             │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│      coding-process 调度器           │
│   - 解析自然语言                     │
│   - 识别场景                         │
│   - 读取 modes.yaml                  │
│   - 按序调用 Superpowers skills      │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│          Superpowers                 │
│   - brainstorming                    │
│   - systematic-debugging             │
│   - subagent-driven-development       │
│   - requesting-code-review           │
│   - verification-before-completion   │
│   - finishing-a-development-branch   │
│   - writing-plans                    │
│   - test-driven-development          │
│   - dispatching-parallel-agents      │
│   ...                                │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│     Claude Code / OpenCode           │
│       执行平台                        │
└─────────────────────────────────────┘
```

### 3.2 文件结构

#### Claude Code 版本

```
your-project/
├── .claude/
│   ├── commands/
│   │   └── flow.md          # /flow 命令（调度器）
│   ├── modes/
│   │   └── modes.yaml       # 场景配置（7 种工作流）
│   └── skills/              # （可选，由 Superpowers 插件全局提供）
```

#### OpenCode 版本

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

---

## 4. Superpowers 集成

### 4.1 安装方式

#### Claude Code

```bash
/plugin install superpowers@claude-plugins-official
```

#### OpenCode

在 `opencode.json` 中添加：

```json
{
  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
}
```

重启 OpenCode 后，Superpowers 的所有 skills 会自动注册。

### 4.2 Skills 列表

| Skill | 用途 | 阶段 |
|-------|------|------|
| **brainstorming** | 需求探索和设计 | EXPLORING / PROPOSING |
| **systematic-debugging** | 系统化调试，定位根因 | EXPLORING (bugfix) |
| **writing-plans** | 将需求拆分为实施计划 | PLANNING |
| **subagent-driven-development** | 通过子代理执行任务 | BUILDING |
| **requesting-code-review** | 代码审查 | REVIEWING |
| **verification-before-completion** | 完成前验证 | VERIFYING |
| **finishing-a-development-branch** | 完成开发分支 | FINISHING |
| **test-driven-development** | 测试驱动开发 | PLANNING / BUILDING (tdd) |
| **dispatching-parallel-agents** | 并行开发 | PLANNING / BUILDING (parallel) |

### 4.3 Skills 调用方式

#### OpenCode

使用 OpenCode 原生的 `skill` 工具：

```
Use the skill tool to load brainstorming
```

#### Claude Code

通过 Superpowers 插件的 skill 系统调用（Claude Code 自动处理）。

---

## 5. 命令参考

| 命令 | 说明 |
|------|------|
| `/flow` | 显示场景选择菜单 |
| `/flow <描述>` | 自然语言驱动，自动识别场景 |
| `/flow stop` | 终止当前流程 |
| `/flow status` | 显示当前执行状态 |

---

## 6. Commit Message 规范

| 场景 | type | 示例 |
|------|------|------|
| 新功能 | feat | `feat: 实现 {功能名}` |
| 修 bug | fix | `fix: 修复 {问题描述}` |
| 快速改 | fix | `fix: {修改描述}` |
| 重构 | refactor | `refactor: {重构描述}` |
| TDD | feat | `feat: tdd 实现 {功能名}` |
| 并行 | feat | `feat: 并行实现 {功能名}` |

---

## 7. 版本历史

### [6.0.0] - 2026-07-04

### 🎯 第六次迭代：依赖 Superpowers

### 变更
- **移除本地 skills**：`.claude/skills/` 和 `.opencode/skills/` 已删除
- **依赖 Superpowers**：所有 skills 由 Superpowers 插件提供（14+ skills）
- **精简架构**：只保留调度器（flow.md）和配置（modes.yaml）
- **安装脚本更新**：检测 Superpowers 安装，不再复制 skills
- **文档全面更新**：README、DESIGN、COMMANDS 反映新架构

### 设计理念
- **Superpowers 是核心**：coding-process 只是 Superpowers 的调度器
- **自然语言优先**：不需要记触发词，说清楚想做什么就行
- **极简架构**：一个命令文件 + 一个配置文件

---

## 8. 与独立 Skills 版本的区别

| 特性 | v5.0 (独立 skills) | v6.0 (Superpowers 调度器) |
|------|-------------------|--------------------------|
| Skills 来源 | 项目本地 `.opencode/skills/` | Superpowers 插件 |
| 依赖 | 无外部依赖 | 需要 Superpowers |
| 文件数量 | 多（包含 9 个 skill 文件） | 少（仅调度器和配置） |
| 维护成本 | 高（需要同步 Superpowers 更新） | 低（Superpowers 自动更新） |
| 功能完整性 | 中（简化版 skills） | 高（完整 Superpowers 功能） |
| Token 消耗 | 低（skills 按需加载） | 中（Superpowers skills 完整） |
