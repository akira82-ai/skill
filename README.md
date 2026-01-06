# Skills

磊叔的 skill 合集（适用于 Claude Code、iflow 等支持 skill 的 agent）

## Available Skills

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
