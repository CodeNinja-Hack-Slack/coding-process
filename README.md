# coding-process

> AI 编程工作流编排工具 —— 用自然语言驱动开发任务

coding-process 是一个跨平台 AI 编程流程编排工具，支持 **Claude Code** 和 **OpenCode**。
作为 [Superpowers](https://github.com/obra/superpowers) 的调度器，让你用 `/flow 自然语言描述` 执行各种开发任务。

## 前置依赖

使用前必须先安装 [Superpowers](https://github.com/obra/superpowers)，它提供了所有 skills。

| 平台 | 安装 Superpowers |
|------|------------------|
| **Claude Code** | 启动 Claude Code 后执行：`/plugin install superpowers@claude-plugins-official` |
| **OpenCode** | 在 `opencode.json` 中添加配置（见下方安装步骤），重启 OpenCode 即可 |

## 安装

### Claude Code

在你的项目根目录下执行：

```bash
# 1. 下载 coding-process
git clone https://github.com/void-frost-craft/coding-process.git /tmp/coding-process

# 2. 创建命令目录
mkdir -p .claude/commands

# 3. 复制 /flow 命令
cp /tmp/coding-process/.claude/commands/flow.md .claude/commands/

# 4. 清理
rm -rf /tmp/coding-process
```

然后在 Claude Code 中安装 Superpowers 插件：

```
/plugin install superpowers@claude-plugins-official
```

安装完成后，在 Claude Code 中输入 `/flow` 即可使用。

### OpenCode

在你的项目根目录下执行：

```bash
# 1. 下载 coding-process
git clone https://github.com/void-frost-craft/coding-process.git /tmp/coding-process

# 2. 创建命令目录
mkdir -p .opencode/commands

# 3. 复制 /flow 命令
cp /tmp/coding-process/.opencode/commands/flow.md .opencode/commands/

# 4. 复制 OpenCode 配置（注册 Superpowers 插件）
cp /tmp/coding-process/opencode.json ./opencode.json

# 5. 清理
rm -rf /tmp/coding-process
```

重启 OpenCode，Superpowers 插件会自动加载。

### 安装后验证

| 平台 | 验证方式 |
|------|----------|
| **Claude Code** | 输入 `/flow`，如果显示场景选择菜单则安装成功 |
| **OpenCode** | 输入 `/flow`，如果显示场景选择菜单则安装成功 |

如果提示找不到命令，请检查：
- Claude Code：`.claude/commands/flow.md` 文件是否存在
- OpenCode：`.opencode/commands/flow.md` 和 `opencode.json` 是否存在

## 使用方法

```
/flow 用户登录功能              # 新功能
/flow 修复登录接口 500 错误      # 修 bug
/flow 改一下超时配置            # 快速修改
/flow 审查用户模块代码          # 代码审查
/flow 重构这个函数              # 重构
/flow tdd 写支付模块            # TDD 开发
/flow 并行开发用户管理模块      # 并行开发
```

无参数 `/flow` 显示场景选择菜单。

## 7 种工作流场景

| 场景 | 触发词 | 流程 |
|------|--------|------|
| **新功能** | 功能、feature、添加、创建 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review → finishing |
| **修 bug** | bug、修复、fix、问题、异常 | systematic-debugging → subagent-driven-development → verification-before-completion |
| **快速修改** | 改、typo、配置、调整 | subagent-driven-development → finishing |
| **代码审查** | review、审查、检查 | requesting-code-review |
| **重构** | refactor、重构、优化 | brainstorming → writing-plans → subagent-driven-development → requesting-code-review |
| **TDD 开发** | tdd、测试驱动 | brainstorming → test-driven-development → requesting-code-review → finishing |
| **并行开发** | 并行、parallel、同时 | brainstorming → dispatching-parallel-agents → requesting-code-review → finishing |

AI 会分析你的自然语言描述，自动选择最合适的场景。

## 项目结构

```
your-project/
├── .claude/
│   └── commands/
│       └── flow.md              # /flow 命令（Claude Code 版）
├── .opencode/
│   └── commands/
│       └── flow.md              # /flow 命令（OpenCode 版）
└── opencode.json                # OpenCode 配置（注册 Superpowers 插件）
```

> 注意：根据你使用的平台，只需复制对应的文件。只用 Claude Code 就不需要 `.opencode/` 和 `opencode.json`，反之亦然。

## 特殊命令

| 命令 | 作用 |
|------|------|
| `/flow stop` | 终止当前流程 |
| `/flow status` | 显示当前执行状态 |

## 卸载

删除对应平台的文件即可：

```bash
# Claude Code
rm -rf .claude/

# OpenCode
rm -rf .opencode/ opencode.json

# 两个都删
rm -rf .claude/ .opencode/ opencode.json
```

## 许可证

[MIT](LICENSE)
