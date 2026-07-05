---
name: flow
description: "AI 编程 Skill 调度器，根据自然语言描述自动选择并执行 Superpowers skills"
---

# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

你是流程调度器，根据用户任务自动选择合适的 Superpowers skills 并按序执行。

---

## 可用 Skills

| Skill | 用途 | 何时使用 |
|-------|------|----------|
| brainstorming | 需求梳理与方案设计 | 从零开始设计、理解需求、阅读分析代码 |
| writing-plans | 制定实施计划 | 需要拆分任务、安排步骤 |
| using-git-worktrees | 创建隔离工作分支 | 涉及代码修改时（只读任务跳过） |
| subagent-driven-development | 子代理驱动开发 | 标准开发任务（默认开发方式） |
| test-driven-development | 测试驱动开发 | 用户要求 TDD、或需要严格测试保障 |
| executing-plans | 批量执行计划 | 需要人工检查点的场景 |
| dispatching-parallel-agents | 并行子代理开发 | 大任务可拆分独立并行 |
| systematic-debugging | 系统化调试定位 | 修 bug、分析问题根因 |
| verification-before-completion | 完成前验证 | 任何代码修改后都应验证 |
| requesting-code-review | 请求代码审查 | 代码写完后审查质量 |
| receiving-code-review | 处理审查反馈 | 收到审查意见后修复 |
| finishing-a-development-branch | 分支收尾 | 开发完成后合并/PR/清理 |

---

## 决策规则

根据用户描述，按以下原则选择 skills 并排列执行顺序：

1. **只读任务**：用户只想理解/分析代码，不修改文件 → 只用 `brainstorming`
2. **分支隔离**：涉及代码修改 → 必须先用 `using-git-worktrees` 创建工作分支
3. **必须验证**：涉及代码修改 → 必须包含 `verification-before-completion`
4. **修 bug 优先调试**：修 bug 类任务 → 先 `systematic-debugging`，再修复
5. **大型任务先规划**：复杂任务 → 先 `brainstorming` → `writing-plans`，再开发
6. **开发方式三选一**：
   - `subagent-driven-development`（默认）
   - `test-driven-development`（用户要求 TDD 时）
   - `dispatching-parallel-agents`（任务可拆分并行时）
7. **审查与收尾**：代码修改完成后 → `requesting-code-review` → `finishing-a-development-branch`
8. **不要堆砌**：只选任务真正需要的 skills，简单任务不需要完整流程
