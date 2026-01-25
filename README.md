# Skills

磊叔的 skill 合集（适用于 Claude Code、iflow 等支持 skill 的 agent）

## Available Skills

### auto-skills

自动化技能编排 - 将复杂任务拆解为多个步骤，为每个步骤匹配已安装的 skill 或搜索 skills.sh 安装新 skill，最终生成 Claude Code task list 执行。

**功能特性：**
- 任务拆解：将用户输入拆解为多个顺序执行的子任务
- 本地匹配：优先使用已安装的 skill
- 远程搜索：从 skills.sh 搜索并安装新 skill
- 自动迁移：自动将项目本地 skill 迁移到全局目录
- 任务跟踪：完整的文件记录和状态跟踪
- 依赖管理：自动设置任务之间的依赖关系

**安装方法：**

```bash
# 复制 skill 目录到 Claude Code skills 目录
cp -r auto-skills ~/.claude/skills/
```

**使用方法：**

```
# 描述复杂任务，auto-skills 会自动拆解并执行
帮我写一篇文章去除AI味然后存到本地
分析这个项目并生成测试用例

# auto-skills 会自动：
# 1. 创建任务工作目录
# 2. 扫描本地 skills
# 3. 拆解任务为子任务
# 4. 为每个子任务匹配/搜索 skill
# 5. 生成 Claude Code task list 执行
```

### idea-to-post

灵感扩展推文生成工具 - 将零散的灵感（一句话、几个词、一个模糊的想法）扩展为 90 分+ 的自媒体推文。

**功能特性：**
- 渐进式提问：7-10 轮对话，从方向锁定到深度挖掘
- 框架内化：运用 PREP、SCQA、黄金圈等思考框架，但对话自然
- 信息搜索：初步背景搜索 + 精准深度搜索，整合外部佐证
- 多平台适配：微信公众号、小红书、Twitter/微博、LinkedIn/脉脉
- 90 分+ 标准：核心观点、真实案例、情绪共鸣、独特观点、外部佐证

**安装方法：**

```bash
# 复制 skill 目录到 Claude Code skills 目录
cp -r idea-to-post ~/.claude/skills/
```

**使用方法：**

```
# 扩展零散灵感
帮我把这个想法扩展成推文：todo 是被低估的命令

# 生成推文内容
写一篇关于 AI 改变编程方式的文章

# 写作辅助
我有几个零散的想法，帮我组织成完整的推文
```

### descriptive-stats

描述性统计分析工具 - 产品级的描述性统计分析，支持 CSV 和 Excel 数据的交互式分析。

**功能特性：**
- 基础描述统计：均值、中位数、标准差、分位数、偏度、峰度
- 分布分析：正态性检验、直方图、密度图、Q-Q图
- 异常值检测：IQR 方法、Z-score 方法、共识检测
- 分组对比：ANOVA、Kruskal-Wallis 检验、箱线图、小提琴图
- 双输出模式：终端彩色表格 + HTML 交互报告
- 交互式引导：友好的命令行交互界面

**安装方法：**

```bash
# 复制 skill 目录到 Claude Code skills 目录
cp -r descriptive-stats ~/.claude/skills/

# 安装 Python 依赖
pip install -r descriptive-stats/requirements.txt
```

**使用方法：**

```
# 交互式分析
请分析 data.csv 的统计特征
对数据进行描述性统计分析

# 指定文件分析
分析 /path/to/sales_data.csv 的统计特征

# 分组分析
按部门分组分析薪资数据
比较不同产品类别的评分分布
```

### security-scanner

安全扫描器 - 防御性安全工具，用于检测 Claude Code 自定义 skills 中的潜在恶意代码。

**功能特性：**
- 静态代码分析（AST）
- 危险函数检测
- 网络操作检测
- 文件操作检测
- 代码混淆检测
- 数据外泄检测

**安装方法：**

```bash
# 复制 skill 目录到 Claude Code skills 目录
cp -r security-scanner ~/.claude/skills/

# 安装依赖（可选，用于独立运行扫描器）
pip install -r security-scanner/requirements.txt
```

**使用方法：**

```bash
# 扫描所有 skills
python ~/.claude/skills/security-scanner/scripts/scanner.py

# 扫描指定 skill
python ~/.claude/skills/security-scanner/scripts/scanner.py --skill <skill-name>
```

## License

MIT
