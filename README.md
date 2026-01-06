# Skills

磊叔的 skill 合集（适用于 Claude Code、iflow 等支持 skill 的 agent）

## Available Skills

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
