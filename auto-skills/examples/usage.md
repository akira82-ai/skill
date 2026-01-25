# 使用示例

## 示例 1：基础用法

### 用户输入

```
/plan 帮我写一篇文章去除AI味然后存到本地
```

### 执行流程

#### 步骤 1：创建任务目录

```bash
bash ~/.claude/skills/task-orchestrator/scripts/create-task-dir.sh "写文章去AI味存本地"
# 输出: /Users/xxx/0125-写文章去AI味存本地
```

#### 步骤 2：扫描本地 skills

```bash
bash ~/.claude/skills/task-orchestrator/scripts/scan-local-skills.sh > local-skills.json
```

```json
// local-skills.json
[
  {
    "name": "idea-to-post",
    "description": "将零散灵感扩展为深度推文...",
    "path": "/Users/xxx/.claude/skills/idea-to-post"
  }
]
```

#### 步骤 3：拆解任务

```json
// task-breakdown.json
[
  {"id": 1, "description": "写文章"},
  {"id": 2, "description": "去除AI味"},
  {"id": 3, "description": "存入本地"}
]
```

```markdown
# TODO.md

## 原始任务
帮我写一篇文章去除AI味然后存到本地

## 任务列表

### 任务一：写文章
[ ] 待执行

### 任务二：去除AI味
[ ] 待执行

### 任务三：存入本地
[ ] 待执行
```

#### 步骤 4：处理任务一

匹配本地 skill → 找到 `idea-to-post`

```
AskUserQuestion: 为任务"写文章"找到以下候选：

1. idea-to-post - 将零散灵感扩展为深度推文
2. 手动处理
```

用户选择: idea-to-post

```bash
bash ~/.claude/skills/task-orchestrator/scripts/record-task-result.sh \
  1 \
  "写文章" \
  "idea-to-post" \
  "local"
```

```bash
bash ~/.claude/skills/task-orchestrator/scripts/update-todo.sh 1 "done" "使用 idea-to-post"
```

#### 步骤 5：处理任务二

匹配本地 skill → 没有候选

搜索 skills.sh：

```javascript
mcp__firecrawl__firecrawl_scrape({
  url: "https://skills.sh/?q=去AI味"
})
```

找到候选：`remove-ai-flavor`

```
AskUserQuestion: 为任务"去除AI味"找到以下候选：

1. remove-ai-flavor - 去除文章AI味道
2. 手动处理
```

用户选择: remove-ai-flavor

```bash
bash ~/.claude/skills/task-orchestrator/scripts/install-skill.sh "npx remove-ai-flavor --yes"
```

```bash
bash ~/.claude/skills/task-orchestrator/scripts/record-task-result.sh \
  2 \
  "去除AI味" \
  "remove-ai-flavor" \
  "remote" \
  "npx remove-ai-flavor --yes"
```

```bash
bash ~/.claude/skills/task-orchestrator/scripts/update-todo.sh 2 "done" "使用 remove-ai-flavor"
```

#### 步骤 6：处理任务三

匹配本地 skill → 没有候选

搜索 skills.sh → 没有合适结果

```
AskUserQuestion: 为任务"存入本地"未找到合适的 skill：

1. 手动处理 - 后续手动保存文件
```

用户选择: 手动处理

```bash
bash ~/.claude/skills/task-orchestrator/scripts/record-task-result.sh \
  3 \
  "存入本地" \
  "" \
  "manual"
```

```bash
bash ~/.claude/skills/task-orchestrator/scripts/update-todo.sh 3 "done" "手动处理"
```

#### 步骤 7：生成最终计划

```bash
bash ~/.claude/skills/task-orchestrator/scripts/generate-final-plan.sh
```

```json
// task-plan.json
{
  "tasks": [
    {
      "taskId": 1,
      "description": "写文章",
      "skill": "idea-to-post",
      "skillType": "local"
    },
    {
      "taskId": 2,
      "description": "去除AI味",
      "skill": "remove-ai-flavor",
      "skillType": "remote",
      "installCmd": "npx remove-ai-flavor --yes"
    },
    {
      "taskId": 3,
      "description": "存入本地",
      "skill": "",
      "skillType": "manual"
    }
  ]
}
```

#### 步骤 8：创建 Claude Code Tasks

```javascript
// Task 1
const task1 = await TaskCreate({
  subject: "写文章",
  description: "调用 idea-to-post skill 生成文章内容",
  activeForm: "正在写文章"
})

// Task 2
const task2 = await TaskCreate({
  subject: "去除AI味",
  description: "调用 remove-ai-flavor skill 处理文章去除AI味",
  activeForm: "正在去除AI味",
  addBlockedBy: [task1.taskId]
})

// Task 3
const task3 = await TaskCreate({
  subject: "保存文件到本地",
  description: "将处理后的文章保存到本地",
  activeForm: "正在保存文件",
  addBlockedBy: [task2.taskId]
})
```

#### 步骤 9：【新增】最终确认

```javascript
// 弹出确认窗口
const response = await AskUserQuestion({
  questions: [{
    question: `已创建 3 个任务：

1. 写文章
2. 去除AI味
3. 保存文件到本地

是否立即开始执行？`,
    header: "确认执行",
    options: [
      {
        label: "立即执行",
        description: "开始执行所有任务，按依赖顺序自动完成"
      },
      {
        label: "稍后执行",
        description: "保持任务为 pending 状态，稍后手动触发执行"
      }
    ],
    multiSelect: false
  }]
})

// 根据用户选择输出相应信息
if (response.confirmExecute === "立即执行") {
  console.log("✅ 已确认，开始执行 3 个任务")
} else {
  console.log("⏸️ 任务已创建，保持 pending 状态")
  console.log("💡 使用以下命令查看任务：/task-list")
}
```

### 最终输出

**用户选择"立即执行"：**
```
✅ 已确认，开始执行 3 个任务
📁 工作目录: 0125-写文章去AI味存本地/
📋 任务将按依赖顺序自动执行...
```

**用户选择"稍后执行"：**
```
⏸️ 任务已创建，保持 pending 状态
💡 使用以下命令查看任务：/task-list
📁 工作目录: 0125-写文章去AI味存本地/
```

---

## 示例 2：复杂任务拆解

### 用户输入

```
/plan 分析这个代码库，生成测试用例，并创建 GitHub Actions CI 配置
```

### 任务拆解

```json
// task-breakdown.json
[
  {"id": 1, "description": "分析代码库结构"},
  {"id": 2, "description": "生成测试用例"},
  {"id": 3, "description": "创建 CI 配置"}
]
```

### 执行要点

1. **分析代码库结构** - 可能有本地的 `code-analyzer` skill
2. **生成测试用例** - 可能需要搜索 `test-generator` skill
3. **创建 CI 配置** - 可能手动处理更合适

---

## 调试技巧

### 查看任务目录内容

```bash
ls -la 0125-写文章去AI味存本地/
```

### 查看本地技能列表

```bash
cat local-skills.json | jq
```

### 查看某个任务的配置

```bash
cat task-1.json | jq
```

### 查看最终执行计划

```bash
cat task-plan.json | jq
```
