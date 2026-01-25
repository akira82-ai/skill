# Task 模板参考

## Claude Code Task 结构

### 基本 Task 结构

```json
{
  "subject": "任务标题",
  "description": "详细描述任务需要做什么",
  "activeForm": "正在执行任务时的状态文本"
}
```

### 带依赖关系的 Task

```json
{
  "subject": "去除AI味",
  "description": "调用 humanize-text skill 处理文章去除AI味",
  "activeForm": "正在去除AI味道",
  "addBlockedBy": ["task-1-id"]
}
```

### Task 状态说明

| 字段 | 说明 | 示例 |
|------|------|------|
| `subject` | 任务标题（简短） | "写文章" |
| `description` | 详细描述 | "调用 idea-to-post skill 生成关于..." |
| `activeForm` | 进行时状态 | "正在写文章" |
| `addBlockedBy` | 依赖的任务 ID 列表 | ["task-1-id", "task-2-id"] |

## 依赖关系示例

### 串行任务

```
Task 1: 写文章
  ↓
Task 2: 去除AI味 (依赖 Task 1)
  ↓
Task 3: 保存文件 (依赖 Task 2)
```

```javascript
// Task 1
TaskCreate({
  subject: "写文章",
  description: "...",
  activeForm: "正在写文章"
})

// Task 2
TaskCreate({
  subject: "去除AI味",
  description: "...",
  activeForm: "正在去除AI味",
  addBlockedBy: [task1Id]
})

// Task 3
TaskCreate({
  subject: "保存文件",
  description: "...",
  activeForm: "正在保存文件",
  addBlockedBy: [task2Id]
})
```

## Skill 类型说明

| 类型 | 说明 | 需要安装 |
|------|------|----------|
| `local` | 本地已安装的 skill | 否 |
| `remote` | 需要从 skills.sh 安装 | 是 |
| `manual` | 手动处理，不使用 skill | 否 |
