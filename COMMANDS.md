# coding-process 命令参考

## 目录

- [/flow 命令](#flow-命令)
- [Superpowers Skills](#superpowers-skills)
- [CodeGraph MCP 工具](#codegraph-mcp-工具)

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

## CodeGraph MCP 工具

### codegraph_files

**作用：** 获取项目文件树结构

```
mcp__codegraph__codegraph_files(projectPath: "...")
```

---

### codegraph_search

**作用：** 按名称搜索符号

```
mcp__codegraph__codegraph_search(query: "divide", projectPath: "...")
```

---

### codegraph_context

**作用：** 获取任务的代码上下文

```
mcp__codegraph__codegraph_context(task: "修复除零错误", projectPath: "...")
```

---

### codegraph_callees

**作用：** 列出指定符号调用的函数

```
mcp__codegraph__codegraph_callees(symbol: "divide", projectPath: "...")
```

---

### codegraph_callers

**作用：** 列出调用指定符号的函数

```
mcp__codegraph__codegraph_callers(symbol: "divide", projectPath: "...")
```

---

### codegraph_impact

**作用：** 分析修改影响

```
mcp__codegraph__codegraph_impact(symbol: "divide", projectPath: "...")
```

---

### codegraph_trace

**作用：** 追踪两个符号之间的调用路径

```
mcp__codegraph__codegraph_trace(from: "calculate", to: "divide", projectPath: "...")
```

---

### codegraph_status

**作用：** 检查索引健康状态

```
mcp__codegraph__codegraph_status(projectPath: "...")
```

---

## 依赖工具

| 工具 | 用途 | 安装方式 |
|------|------|----------|
| Superpowers | 开发方法论 skills | `/plugin install superpowers@claude-plugins-official` |
| CodeGraph MCP | 代码上下文分析 | Claude Code MCP 配置 |
