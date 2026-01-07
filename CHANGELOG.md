# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2025-01-07

### Changed
- **descriptive-stats**: 重构图表渲染系统，从 Plotly 切换到 Matplotlib
  - 图表以 base64 编码的静态 PNG 图片嵌入 HTML 报告
  - 改进了中文字体支持
  - 更快的报告生成速度和更好的兼容性
  - 添加模板上下文构建器模块

### Added
- **descriptive-stats**: 新增 `matplotlib_charts.py` 模块
  - 支持创建出版级质量的静态图表
  - 支持直方图、Q-Q图、箱线图、异常值图等
- **descriptive-stats**: 新增 `template_context.py` 模块
  - 集中管理 HTML 报告模板上下文构建
- 更新 `.gitignore` 以排除备份文件

## [1.1.0] - 2025-01-06

### Added
- **descriptive-stats** skill v1.0.0 - 描述性统计分析工具
  - 基础描述统计（均值、中位数、标准差、分位数、偏度、峰度）
  - 分布分析（正态性检验、直方图、密度图、Q-Q图）
  - 异常值检测（IQR 方法、Z-score 方法、共识检测）
  - 分组对比（ANOVA、Kruskal-Wallis 检验、箱线图、小提琴图）
  - 双输出模式（终端彩色表格 + HTML 交互报告）
  - 交互式引导界面

### Changed
- Updated README.md with descriptive-stats documentation
- Added VERSION file (v1.1.0)

## [1.0.0] - 2025-01-06

### Added
- **security-scanner** skill v1.0.0 - 安全扫描器
  - 静态代码分析（AST）
  - 危险函数检测
  - 网络操作检测
  - 文件操作检测
  - 代码混淆检测
  - 数据外泄检测
- Initial project structure
- LICENSE (MIT)
