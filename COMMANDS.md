# coding-process 命令参考

## 目录

- [/flow 命令](#flow-命令)
- [Superpowers Skills](#superpowers-skills)
- [Superpowers Tools 映射](#superpowers-tools-映射)

---

## /flow 命令

### /flow

**作用：** 显示场景选择菜单

```
/flow
```

**输出：**

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

---

### /flow <描述>

**作用：** 自然语言驱动，自动识别场景

```
/flow <描述>
```

**示例：**

```
/flow 用户登录功能              # → 新功能
/flow 修复登录接口 500 错误      # → 修 bug
/flow 改一下超时配置            # → 快速修改
/flow 审查用户模块代码          # → 代码审查
/flow 重构这个函数              # → 重构
/flow tdd 写支付模块            # → TDD 开发
/flow 并行开发用户管理模块      # → 并行开发
```

**AI 识别逻辑：**

| 场景 | 触发词 |
|------|--------|
| 新功能 | 功能、feature、添加、创建 |
| 修 bug | bug、修复、fix、问题、异常 |
| 快速修改 | 改、typo、配置、调整 |
| 代码审查 | review、审查、检查 |
| 重构 | refactor、重构、优化 |
| TDD 开发 | tdd、测试驱动 |
| 并行开发 | 并行、parallel、同时 |

> **💡 自然语言优先**：不需要记触发词，说清楚想做什么就行。AI 会分析你的描述，自动选择最合适的场景。

---

### /flow stop

**作用：** 终止当前流程

```
/flow stop
```

---

### /flow status

**作用：** 显示当前执行状态

```
/flow status
```

---

## Superpowers Skills

所有 skills 由 [Superpowers](https://github.com/obra/superpowers) 插件提供。

### brainstorming

**作用：** 需求探索和设计，通过苏格拉底式对话理清需求

**使用场景：** 新功能、重构的探索阶段

---

### writing-plans

**作用：** 将设计拆分为可执行的实施计划

**使用场景：** 新功能、重构的计划阶段

---

### subagent-driven-development

**作用：** 通过独立子代理执行任务，两阶段审查（spec 合规 + 代码质量）

**使用场景：** 新功能、快速修改、重构的构建阶段

---

### requesting-code-review

**作用：** 派遣代码审查子代理，按严重程度处理问题

**使用场景：** 新功能、重构、TDD、并行的审查阶段

---

### systematic-debugging

**作用：** 系统化调试，4 阶段根因调试法

**使用场景：** 修 bug 的探索阶段

---

### test-driven-development

**作用：** 测试驱动开发，强制 RED-GREEN-REFACTOR 循环

**使用场景：** TDD 开发的计划和构建阶段

---

### dispatching-parallel-agents

**作用：** 并行派遣多个独立 agent 执行任务

**使用场景：** 并行开发的计划和构建阶段

---

### verification-before-completion

**作用：** 完成前验证，确保有证据支持完成声明

**使用场景：** 修 bug、TDD 开发的验证阶段

---

### finishing-a-development-branch

**作用：** 完成开发分支，提供选项（合并/PR/保留/丢弃）

**使用场景：** 新功能、快速修改、TDD、并行的完成阶段

---

## Superpowers Tools 映射

在 OpenCode 中，Superpowers skills 会调用以下工具：

| Superpowers 动作 | OpenCode 工具 | Claude Code 工具 |
|-----------------|--------------|-----------------|
| "Create a todo" / "mark complete" | `todowrite` | `todowrite` |
| "Subagent (general-purpose)" | `task` tool | 子代理 API |
| "Invoke a skill" | `skill` tool | `skill` tool |
| "Read a file" | `read` | `read` |
| "Create a file" / "edit a file" / "delete a file" | `apply_patch` | `edit` / `write` |
| "Run a shell command" | `bash` | `bash` |
| "Search file contents" | `grep` | `grep` |
| "Find files by name" | `glob` | `glob` |
| "Fetch a URL" | `webfetch` | `webfetch` |

---

## 依赖工具

| 平台 | 工具 | 用途 | 安装方式 |
|------|------|------|----------|
| **Claude Code** | [Claude Code](https://claude.ai/code) | AI 编程助手 | 下载安装 |
| **Claude Code** | [Superpowers](https://github.com/obra/superpowers) | 开发方法论 skills | `/plugin install superpowers@claude-plugins-official` |
| **OpenCode** | [OpenCode](https://opencode.ai) | AI 编程助手 | `curl -fsSL https://opencode.ai/install \| bash` |
| **OpenCode** | [Superpowers](https://github.com/obra/superpowers) | 开发方法论 skills | 在 `opencode.json` 中添加 `"plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]` |
