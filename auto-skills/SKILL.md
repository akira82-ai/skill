---
name: auto-skills
description: 自动化技能编排。将用户任务拆解为多个步骤，为每个步骤匹配已安装的 skill 或搜索 skills.sh 安装新的 skill，最终生成 Claude Code task list 执行。适用于复杂任务的多步骤规划和自动化编排。
version: 1.5.0
allowed-tools: Bash, AskUserQuestion, mcp__firecrawl__firecrawl_search, mcp__firecrawl__firecrawl_scrape, TaskCreate
model: claude-sonnet-4-20250514
---

# 自动化技能编排 (Auto-Skills)

## 技能概述

这个 skill 帮助你将复杂任务拆解为多个可执行的步骤，为每个步骤自动匹配合适的工具或 skill，最终生成 Claude Code 的 task list 进行自动化执行。

**核心工作流程：**

1. **创建任务工作目录** - 按日期+任务描述创建独立工作区
2. **扫描本地 skills** - 获取已安装的 skill 列表
3. **任务拆解** - 将用户输入拆解为多个顺序执行的子任务
4. **逐个处理子任务** - 为每个子任务匹配/搜索/安装 skill
5. **生成执行计划** - 创建 Claude Code task list

**设计原则：**
- 所有文件操作、命令执行通过脚本完成
- Prompt 只负责流程控制、逻辑判断、工具调用
- 每一步都有文件记录，可控、可追溯、可恢复

---

## 使用流程

### 步骤 1：理解用户任务

当用户调用这个 skill 时，首先理解用户的完整任务描述。

**示例：**
- "帮我写一篇文章去除AI味然后存到本地"
- "分析这个项目并生成测试用例"

### 步骤 2：创建任务目录

调用 `create-task-dir.sh` 创建工作目录：

```bash
# 生成简化的任务描述（去除"帮我"、"请"等语气词）
# 例如: "写文章去AI味存本地"
bash ~/.claude/skills/auto-skills/scripts/create-task-dir.sh "简化的任务描述"
```

目录格式：`MM-DD-任务描述/`

**注意：** 先用脚本创建目录，然后 `cd` 进入该目录进行后续操作。

### 步骤 3：扫描本地 Skills

```bash
bash ~/.claude/skills/auto-skills/scripts/scan-local-skills.sh > local-skills.json
```

这会输出本地已安装的所有 skill 列表（JSON 格式）。

### 步骤 4：拆解任务

基于 `local-skills.json` 中的可用 skills，将用户任务拆解为多个顺序执行的子任务。

**拆解原则：**
- 每个子任务应该是独立、可执行的步骤
- 子任务之间有明确的先后顺序
- 优先考虑使用本地已安装的 skill

**输出格式：** 写入 `task-breakdown.json`

```json
[
  {"id": 1, "description": "写文章"},
  {"id": 2, "description": "去除AI味"},
  {"id": 3, "description": "存入本地"}
]
```

同时更新 `TODO.md`，添加所有子任务。

### 步骤 5：逐个处理子任务

对 `task-breakdown.json` 中的每个子任务，按以下流程处理：

**每个子任务只弹出一次选择菜单，简化交互。**

#### 5.1 匹配本地 Skill

读取 `local-skills.json`，根据子任务描述进行语义匹配。

**匹配策略：**
- 读取每个 skill 的 `name` 和 `description`
- 分析关键词和功能描述
- 找出最相关的 1-3 个候选 skill

#### 5.2 决策并搜索（如需）

**情况 A：有本地候选**
- 直接进入步骤 5.3，展示本地候选给用户

**情况 B：无本地候选**
- 自动使用 MCP 工具搜索 skills.sh：
- ```javascript
  mcp__firecrawl__firecrawl_search({
    query: "site:skills.sh 搜索关键词",
    limit: 10,
    sources: [{ type: "web" }]
  })
  ```
- 解析搜索结果，提取 skill 名称、仓库、描述、npx 安装命令
- 进入步骤 5.3，展示远程候选给用户

**情况 C：搜索后仍无合适 skill**
- 进入步骤 5.3，仅提供"手动处理"选项

#### 5.3 用户选择（一次性交互）

使用 `AskUserQuestion` 展示候选列表给用户：

```javascript
// 有本地候选时
AskUserQuestion({
  questions: [{
    question: "为子任务「写文章」找到以下候选 skill：",
    header: "选择 Skill",
    options: [
      { label: "idea-to-post", description: "将零散灵感扩展为深度推文" },
      { label: "content-writer", description: "AI 辅助写作工具" },
      { label: "手动处理", description: "不使用 skill，后续手动完成" }
    ],
    multiSelect: false
  }]
})

// 搜索远程候选时
AskUserQuestion({
  questions: [{
    question: "为子任务「去除AI味」从 skills.sh 搜索到以下候选：",
    header: "选择 Skill",
    options: [
      { label: "humanize-text", description: "去除文章AI味道，使语言更自然" },
      { label: "ai-content-rewriter", description: "重写AI生成的内容" },
      { label: "手动处理", description: "不使用 skill，后续手动完成" }
    ],
    multiSelect: false
  }]
})

// 无候选时
AskUserQuestion({
  questions: [{
    question: "为子任务「存入本地」未找到合适的 skill：",
    header: "处理方式",
    options: [
      { label: "手动处理", description: "不使用 skill，后续手动完成" }
    ],
    multiSelect: false
  }]
})
```

#### 5.4 安装 Skill（如果需要）

如果用户选择了远程 skill，使用 `install-skill.sh` 安装：

```bash
bash ~/.claude/skills/auto-skills/scripts/install-skill.sh "npx @xxx/skill --yes"
```

**自动迁移功能：**
- 脚本会自动检测技能是否安装在项目本地 `.agents/skills/` 目录
- 如果是，会自动复制到全局 `~/.claude/skills/` 目录
- 这样所有项目都可以使用这个技能
- 迁移状态会在输出中显示

#### 5.5 记录结果

使用 `record-task-result.sh` 记录该子任务的配置：

```bash
bash ~/.claude/skills/auto-skills/scripts/record-task-result.sh \
  <任务ID> \
  "<任务描述>" \
  "<选中的skill名称>" \
  "<skill类型:local/remote/manual>" \
  "<安装命令(如果有)>"
```

这会生成 `task-N.json` 文件。

#### 5.6 更新 TODO

```bash
bash ~/.claude/skills/auto-skills/scripts/update-todo.sh \
  <任务ID> \
  "done" \
  "使用 xxx-skill"
```

**重要：** 每完成一个子任务，立即更新 TODO.md

### 步骤 6：生成最终执行计划

所有子任务处理完成后，调用：

```bash
bash ~/.claude/skills/auto-skills/scripts/generate-final-plan.sh
```

这会生成 `task-plan.json`，包含所有任务的完整信息。

### 步骤 7：创建 Claude Code Tasks

基于 `task-plan.json`，使用 `TaskCreate` 为每个子任务创建 Claude Code task。

**依赖关系设置：**
- Task 2 依赖 Task 1（`addBlockedBy: ["task-1-id"]`）
- Task 3 依赖 Task 2
- 以此类推...

**Task 描述示例：**
```json
{
  "subject": "写文章",
  "description": "调用 idea-to-post skill 生成文章内容",
  "activeForm": "正在写文章"
}
```

创建完所有 tasks 后，skill 生命周期结束，Claude Code 开始执行 task list。

---

## 脚本工具清单

| 脚本 | 功能 | 输入 | 输出 |
|------|------|------|------|
| `create-task-dir.sh` | 创建任务目录 | 任务描述 | 目录路径 |
| `scan-local-skills.sh` | 扫描本地 skills | 无 | JSON |
| `match-skills.sh` | 匹配 skill | 任务描述 + skills JSON | 匹配结果 |
| `install-skill.sh` | 安装并自动迁移 skill | npx 命令 | 安装结果 + 迁移状态 |
| `record-task-result.sh` | 记录任务结果 | 任务ID + 信息 | task-N.json |
| `update-todo.sh` | 更新 TODO | 任务ID + 状态 | 更新 TODO.md |
| `generate-final-plan.sh` | 生成最终计划 | 无 | task-plan.json |

---

## 输出文件结构

```
0125-写文章去AI味存本地/
├── TODO.md                      # 执行状态跟踪
├── local-skills.json            # 本地 skill 列表
├── task-breakdown.json          # 任务拆解结果
├── task-plan.json               # 最终执行计划
├── task-1.json                  # 任务1 配置
├── task-2.json                  # 任务2 配置
├── task-3.json                  # 任务3 配置
└── tasks/                       # 保留目录
```

---

## 最佳实践

1. **每步操作都有文件记录** - 所有中间结果写入文件，便于追溯和恢复

2. **及时更新 TODO** - 每完成一个子任务立即更新状态

3. **优先使用本地 skill** - 减少安装时间，提高稳定性

4. **清晰的搜索词** - 搜索远程 skill 时使用多种相关词汇，使用 `site:skills.sh` 确保结果来自 skills.sh

5. **用户确认后再操作** - 安装 skill 前务必获得用户确认

6. **保持扁平化执行** - 按顺序一个一个处理子任务，不要嵌套循环

7. **自动迁移技能** - 安装技能后会自动迁移到全局目录，无需手动操作

---

## 示例

查看 `examples/` 目录获取完整的使用示例。
