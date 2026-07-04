# /flow — AI 编程流程编排

用户输入：`$ARGUMENTS`

你是流程调度器，根据用户任务自动选择场景并调用 Superpowers skills。

---

## 命令

| 输入 | 动作 |
|------|------|
| `/flow` | 显示场景选择菜单 |
| `/flow <描述>` | 识别场景并执行 |
| `/flow resume` | 从上次中断处继续 |
| `/flow status` | 显示当前进度 |

---

## 场景选择

无参数时显示菜单：

```
请选择工作流场景：
1. 新功能    2. 修 bug    3. 快速修改    4. 代码审查
5. 重构      6. TDD 开发  7. 并行开发

请输入序号或描述：
```

有描述时按触发词识别场景：

| 场景 | 触发词 |
|------|--------|
| 新功能 | 功能、feature、添加、创建、实现、开发 |
| 修 bug | bug、修复、fix、问题、异常、报错、错误 |
| 快速修改 | 改、typo、配置、调整、修改、简单、快速 |
| 代码审查 | review、审查、检查代码、看看 |
| 重构 | refactor、重构、优化代码、整理、重写 |
| TDD 开发 | tdd、测试驱动、test-driven、先写测试 |
| 并行开发 | 并行、parallel、同时开发、多任务、拆分 |

---

## 执行工作流

按 stages 顺序执行，每个阶段调用对应的 skill：

```
执行阶段：{name}（{description}）[{index+1}/{total}]
```

### 状态管理

**开始执行前**：将状态写入 `.flow-state.json`：

```json
{
  "scenario": "feature",
  "task": "用户登录功能",
  "stage_index": 0,
  "total_stages": 6,
  "stages": ["EXPLORING", "PLANNING", "BUILDING", "REVIEWING", "VERIFYING", "FINISHING"]
}
```

**每个阶段完成后**：更新 `stage_index` 为下一阶段的索引。

**全部完成后**：删除 `.flow-state.json`。

**用户输入 `stop` 时**：保留 `.flow-state.json`，下次可用 `/flow resume` 续接。

### `/flow resume`

读取 `.flow-state.json`，从保存的 `stage_index` 继续执行。如果文件不存在，提示用户。

### `/flow status`

读取 `.flow-state.json`，显示当前进度：

```
场景：{scenario}
任务：{task}
进度：{已完成阶段} → 【当前】{当前阶段} → {剩余阶段}
```

---

## 场景定义

```yaml
feature:  # 新功能
  - { name: EXPLORING, skill: brainstorming, description: 理解需求、设计方案 }
  - { name: PLANNING, skill: writing-plans, description: 制定计划 }
  - { name: BUILDING, skill: subagent-driven-development, description: 实施开发 }
  - { name: REVIEWING, skill: requesting-code-review, description: 代码审查 }
  - { name: VERIFYING, skill: verification-before-completion, description: 验证 }
  - { name: FINISHING, skill: finishing-a-development-branch, description: 收尾 }

bugfix:  # 修 bug
  - { name: EXPLORING, skill: systematic-debugging, description: 调试定位 }
  - { name: BUILDING, skill: subagent-driven-development, description: 实施修复 }
  - { name: VERIFYING, skill: verification-before-completion, description: 验证 }

quick:  # 快速修改
  - { name: BUILDING, skill: subagent-driven-development, description: 直接修改 }
  - { name: FINISHING, skill: finishing-a-development-branch, description: 收尾 }

review:  # 代码审查
  - { name: REVIEWING, skill: requesting-code-review, description: 执行审查 }

refactor:  # 重构
  - { name: EXPLORING, skill: brainstorming, description: 分析现有代码、设计优化方案 }
  - { name: PLANNING, skill: writing-plans, description: 制定重构计划 }
  - { name: BUILDING, skill: subagent-driven-development, description: 执行重构 }
  - { name: REVIEWING, skill: requesting-code-review, description: 审查结果 }
  - { name: VERIFYING, skill: verification-before-completion, description: 验证 }
  - { name: FINISHING, skill: finishing-a-development-branch, description: 收尾 }

tdd:  # TDD 开发
  - { name: EXPLORING, skill: brainstorming, description: 理解需求、设计方案 }
  - { name: PLANNING, skill: test-driven-development, description: 编写测试 }
  - { name: BUILDING, skill: test-driven-development, description: 实现功能 }
  - { name: REVIEWING, skill: requesting-code-review, description: 代码审查 }
  - { name: VERIFYING, skill: verification-before-completion, description: 验证 }
  - { name: FINISHING, skill: finishing-a-development-branch, description: 收尾 }

parallel:  # 并行开发
  - { name: EXPLORING, skill: brainstorming, description: 理解需求、设计方案 }
  - { name: PLANNING, skill: dispatching-parallel-agents, description: 拆分任务 }
  - { name: BUILDING, skill: dispatching-parallel-agents, description: 并行实施 }
  - { name: REVIEWING, skill: requesting-code-review, description: 代码审查 }
  - { name: VERIFYING, skill: verification-before-completion, description: 验证 }
  - { name: FINISHING, skill: finishing-a-development-branch, description: 收尾 }
```
