# Changelog

本文档记录 coding-process 项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [4.0.0] - 2026-06-08

### 🎯 第四次迭代：彻底精简架构

### 新增
- **自然语言驱动**：用自然语言描述任务，AI 自动选择合适的工作流场景
- **7 种核心场景**：新功能、修 bug、快速修改、代码审查、重构、TDD 开发、并行开发
- **统一配置文件**：`modes.yaml` 包含所有场景定义

### 变更
- **架构精简**：从 19 种模式精简为 7 种场景
- **文件精简**：从 5 个 YAML 配置文件精简为 1 个
- **文档精简**：README、DESIGN、COMMANDS 全面精简
- **去除项目类型检测**：不再区分前端/后端/全栈，CodeGraph 自动识别
- **去除状态管理**：简化为单次执行流程

### 删除
- **冗余配置文件**
  - `.coding-process/backend-modes.yaml`
  - `.coding-process/frontend-modes.yaml`
  - `.coding-process/fullstack-modes.yaml`
  - `.coding-process/common-modes.yaml`
  - `.coding-process/config.yaml`
- **冗余功能**
  - 项目类型检测（前端/后端/全栈）
  - 复杂状态管理（state.json、active 文件）
  - 前后端联动检测
  - 暂停/恢复/回退功能

### 设计理念
- **核心是 Superpowers**：coding-process 只是 Superpowers 的命令包装器
- **自然语言优先**：不需要记触发词，说清楚想做什么就行
- **CodeGraph 提供上下文**：修改代码时自动分析代码结构
- **极简架构**：一个命令文件 + 一个配置文件

---

## [3.0.0] - 2026-06-07

### 🎯 第三次迭代：依赖简化与 Token 优化

### 新增
- **TDD 工作流模式**（3 个）
  - `tdd-feature`：后端 TDD 功能开发
  - `frontend-tdd`：前端 TDD 开发
  - `fullstack-tdd`：全栈 TDD 开发
- **并行开发模式**（3 个）
  - `parallel-feature`：后端并行功能开发
  - `frontend-parallel`：前端并行开发
  - `fullstack-parallel`：全栈并行开发
- **版本检测逻辑**：使用版本号检测依赖是否安装
- **项目评价文档**：诚实评价项目优缺点

### 变更
- **移除 OpenSpec 依赖**：Superpowers 的 `brainstorming` skill 已覆盖 OpenSpec 功能
- **依赖工具简化**：从 3 个减少到 2 个（Superpowers + CodeGraph）
- **模式文件位置**：从 `.claude/commands/` 移动到 `.coding-process/`
- **Token 优化**：模式文件按需加载，只有 `flow.md` 每次加载
- **文档精简**：`flow.md` 从 457 行减少到 211 行（54%）
- **模式文件精简**：
  - `frontend-modes.yaml`：275 行 → 174 行（37%）
  - `fullstack-modes.yaml`：307 行 → 177 行（42%）

### 删除
- **OpenSpec 相关文件**
  - `.claude/skills/openspec-propose.md`
  - `.claude/skills/openspec-design.md`
  - `.claude/skills/openspec-apply.md`
  - `openspec/` 目录
- **测试文件和空目录**
- **冗余的文档内容**

### 修复
- **依赖检测逻辑**：修复 Superpowers 和 CodeGraph 的版本检测
- **安装脚本**：修复项目级安装逻辑

---

## [2.0.0] - 2026-06-06

### 🎯 第二次迭代：功能完善与模式扩展

### 新增
- **SOP 工作流模式**（4 个）
  - `sop`：执行标准操作流程
  - `sop_proposal`：生成标准提案
  - `sop_task`：创建标准任务
  - `review_flow`：执行代码审查流程
- **快速修复模式**（2 个）
  - `quick-fix`：后端快速修复
  - `frontend-hotfix`：前端紧急修复
- **代码审查模式**
  - `review`：后端代码审查
- **一键安装脚本**
  - `install.sh`：Linux/macOS 安装脚本
  - `install.ps1`：Windows PowerShell 安装脚本
- **依赖检查逻辑**
  - 检查 Superpowers 是否安装
  - 检查 CodeGraph 是否安装
  - 友好提示安装命令

### 变更
- **完善工作流模式**：从 5 个增加到 13 个
- **优化状态管理**：完善 state 文件和 active 文件逻辑
- **改进用户交互**：优化菜单显示和选择流程

---

## [1.0.0] - 2026-06-06

### 🎯 第一次迭代：基础架构建立

### 新增
- **核心调度器**：`flow.md`
  - 状态机模式（7 个阶段）
  - 项目类型检测
  - 模式选择菜单
  - 状态管理
- **基础工作流模式**（5 个）
  - `quick`：快速修改
  - `small-feature`：小功能
  - `feature`：功能开发
  - `bugfix`：Bug 修复
  - `fullstack-feature`：全栈功能
- **项目类型支持**
  - 前端项目
  - 后端项目
  - 全栈项目
- **依赖工具集成**
  - Superpowers：AI 原生 skill 调度器
  - OpenSpec：需求管理工具
  - CodeGraph：代码图谱分析工具

---

## 版本号说明

- **主版本号（MAJOR）**：不兼容的 API 修改
- **次版本号（MINOR）**：向下兼容的功能性新增
- **修订号（PATCH）**：向下兼容的问题修正

---

## 迭代计划

### 短期（1-2 周）
- 测试实际使用效果
- 收集用户反馈
- 修复发现的问题

### 中期（1-2 月）
- 考虑精简模式数量（5-8 种核心模式）
- 添加使用案例
- 优化用户体验

### 长期（3-6 月）
- 支持更多项目类型
- 集成更多工具
- 建立社区
