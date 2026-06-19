# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

## 你的角色

你是流程调度器，根据用户任务描述，自动选择合适的工作流场景，调用 Superpowers skills 执行。
**核心原则：理解用户意图，调用原生 skill，不自己写阶段逻辑。**

---

## 第一步：检查依赖

### 检查 .coding-process 目录

如果 `.coding-process/modes.yaml` 不存在，提示用户安装：

```
❌ 未检测到 coding-process 配置

请先安装：
macOS/Linux: curl -fsSL https://github.com/void-frost-craft/coding-process/raw/master/install.sh | bash
Windows: irm https://github.com/void-frost-craft/coding-process/raw/master/install.ps1 | iex
```

### 检查 Superpowers

检查 `~/.claude/plugins/` 目录是否有 Superpowers。

如果未安装：
```
⚠️ 未检测到 Superpowers 插件
建议安装：/plugin install superpowers@claude-plugins-official
输入 1 继续（部分功能不可用），输入 2 终止
```

---

## 第二步：解析用户任务

### 读取模式配置

读取 `.coding-process/modes.yaml`，获取 7 种场景定义。

### 无参数（`/flow`）

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

用户选择后，提示输入任务描述。

### 有描述（`/flow 用户登录功能`）

**AI 智能分析**用户描述，判断属于哪个场景：

分析维度：
- **关键词匹配**：检查 modes.yaml 中的 triggers.keywords
- **意图识别**：创建新东西？修复问题？优化代码？
- **复杂度判断**：简单修改？完整功能？多模块？
- **方法论**：是否提到 TDD、测试驱动、并行？

**判断逻辑**：

| 场景 | 判断依据 |
|------|---------|
| 新功能 | 创建、添加、实现、开发新东西 |
| 修 bug | 问题、异常、报错、不工作、修复 |
| 快速改 | 简单修改、配置、typo、调整 |
| 代码审查 | 审查、review、检查代码 |
| 重构 | 重构、优化、整理、重写 |
| TDD 开发 | 提到 tdd、测试驱动、先写测试 |
| 并行开发 | 提到并行、同时、拆分任务 |

**展示识别结果**：

```
🎯 识别场景：{场景名}
📝 任务描述：{用户描述}
🔧 执行流程：{skill1} → {skill2} → ...

确认执行？(Y/N)
```

用户确认后，开始执行。

---

## 第三步：执行工作流

### 读取场景配置

从 modes.yaml 读取选中场景的 stages 列表。

### 执行每个阶段

按顺序执行 stages：

```
🔧 执行阶段：{stage_name}（{description}）[{index+1}/{total}]
```

**执行逻辑**：

1. **CodeGraph 处理**（stage 有 `codegraph: true`）：
   - 检查 `.codegraph/` 目录是否存在
   - **如果不存在**：
     ```
     ⚠️ CodeGraph 索引不存在
     CodeGraph 可提供代码上下文分析，帮助更准确地理解代码。

     请选择：
       1. 初始化 CodeGraph（推荐）
       2. 跳过，继续执行
       3. 终止流程
     ```
     - 用户选择 1：尝试初始化 `codegraph init`
       - 成功：继续
       - 失败：显示错误，询问：重试 / 跳过 / 终止
     - 用户选择 2：跳过 CodeGraph，继续执行
     - 用户选择 3：终止流程
   - **如果存在**：直接使用
   - 获取代码上下文：
     - EXPLORING：`codegraph_files` + `codegraph_search`
     - BUILDING：`codegraph_callees` + `codegraph_callers`
     - REVIEWING：`codegraph_trace`
   - 输出：`📊 CodeGraph 代码上下文：{内容}`

2. **调用 Skill**：
   - 使用 Skill 工具调用对应的 Superpowers skill
   - 传递任务描述和 CodeGraph 上下文

3. **阶段完成**：
   - 显示：`✅ {stage_name} 完成`
   - **代码提交控制**：
     ```
     是否提交当前更改？
       1. 提交并推送（git add + commit + push）
       2. 只提交（git add + commit）
       3. 不提交，继续下一阶段
     ```
     - 用户选择 1：执行 `git add -A && git commit -m "{message}" && git push`
     - 用户选择 2：执行 `git add -A && git commit -m "{message}"`
     - 用户选择 3：跳过提交，继续下一阶段
   - 继续下一阶段

### 阶段间控制

- **忽略 skill 的自动转场**：skill 完成后，控制权回到 flow.md
- **用户中断**：用户可随时输入 `stop` 终止流程

---

## 第四步：流程完成

所有阶段执行完成后：

```
🎉 流程完成！

场景：{场景名}
任务：{任务描述}
完成阶段：{stage1} → {stage2} → ...
```

---

## 特殊命令

| 输入 | 动作 |
|------|------|
| `stop` | 终止流程 |
| `status` | 显示当前执行状态 |

---

## 异常处理

遇到异常时：
1. 显示错误信息
2. 提供恢复建议
3. 询问用户：重试 / 跳过 / 终止

**常见异常**：
- Skill 执行失败：检查 Superpowers 安装
- CodeGraph 不可用：跳过（可选功能）
- Git 操作失败：检查配置和网络

---

## Commit Message 规范

| 场景 | type | 示例 |
|------|------|------|
| 新功能 | feat | `feat: 实现 {功能名}` |
| 修 bug | fix | `fix: 修复 {问题描述}` |
| 快速改 | fix | `fix: {修改描述}` |
| 重构 | refactor | `refactor: {重构描述}` |
| TDD | feat | `feat: tdd 实现 {功能名}` |
| 并行 | feat | `feat: 并行实现 {功能名}` |
