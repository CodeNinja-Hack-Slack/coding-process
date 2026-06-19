# coding-process 设计文档

> 版本：4.0
> 日期：2026-06-08
> 状态：精简架构

---

## 1. 项目概述

### 1.1 项目定位

coding-process 是一个 AI 编程流程编排工具，用自然语言驱动 Superpowers skills 执行开发任务。

**核心价值**：不用记 Superpowers 繁琐的 skill 命令，用 `/flow 自然语言描述` 即可。

### 1.2 解决的问题

Superpowers 有 14 个 skills，名字又长又难记：
- `brainstorming` / `writing-plans` / `subagent-driven-development`
- `requesting-code-review` / `finishing-a-development-branch`
- `systematic-debugging` / `test-driven-development`
- ...

coding-process 把这些 skill 按场景分组，用户说任务，AI 自动选 skill。

### 1.3 工具选型

| 工具 | 定位 | 提供能力 |
|------|------|---------|
| **Superpowers** | 执行纪律 | TDD、subagent 开发、代码审查、调试、验证、分支管理 |
| **CodeGraph** (MCP) | 代码分析 | 代码搜索、调用链追踪、影响分析 |

### 1.4 核心设计原则

1. **自然语言驱动** — 用户说任务，AI 自动选择场景和 skills
2. **调用原生 skill** — flow.md 只负责调度，阶段执行全部委托
3. **CodeGraph 提供上下文** — 修改代码时自动分析代码结构
4. **极简架构** — 一个命令文件 + 一个配置文件

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

用户可通过编辑 `.coding-process/modes.yaml` 自定义场景：

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

---

## 3. 阶段设计

### 3.1 阶段与 Skill 映射

| 阶段 | 说明 | 可用 Skill | CodeGraph |
|------|------|-----------|-----------|
| EXPLORING | 探索/调试 | `brainstorming`、`systematic-debugging` | ✅ |
| PROPOSING | 需求设计 | `brainstorming` | ❌ |
| PLANNING | 计划拆分 | `writing-plans`、`test-driven-development`、`dispatching-parallel-agents` | ❌ |
| BUILDING | 代码实现 | `subagent-driven-development`、`test-driven-development`、`dispatching-parallel-agents` | ✅ |
| REVIEWING | 代码审查 | `requesting-code-review` | ✅ |
| VERIFYING | 验证 | `verification-before-completion` | ❌ |
| FINISHING | 完成 | `finishing-a-development-branch` | ❌ |

### 3.2 CodeGraph 集成

| 阶段 | CodeGraph 工具 | 用途 |
|------|---------------|------|
| EXPLORING | `codegraph_files` + `codegraph_search` | 获取项目结构和相关符号 |
| BUILDING | `codegraph_callees` + `codegraph_callers` | 分析函数调用关系 |
| REVIEWING | `codegraph_trace` | 追踪完整调用路径 |

**降级策略**：用户未安装 CodeGraph MCP 时，跳过代码上下文注入，不影响流程执行。

---

## 4. 文件结构

```
your-project/
├── .claude/
│   └── commands/
│       └── flow.md          # /flow 命令（调度器）
└── .coding-process/
    └── modes.yaml           # 场景配置（7 种工作流）
```

### 4.1 flow.md

核心调度器，负责：
- 检查依赖（Superpowers、CodeGraph）
- 解析用户自然语言
- 识别场景
- 执行 stages
- 调用 Superpowers skills
- 集成 CodeGraph 上下文

### 4.2 modes.yaml

场景配置文件，定义：
- 7 种工作流场景
- 每种场景的触发词
- 每种场景的 stages 和对应 skill

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
