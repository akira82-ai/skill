#!/bin/bash

# 简化的技能迁移脚本
# 用法：bash migrate-one-skill.sh <技能源目录> <技能名称>

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SOURCE_DIR="$1"
SKILL_NAME="$2"
GLOBAL_DIR="$HOME/.claude/skills"

if [ -z "$SOURCE_DIR" ] || [ -z "$SKILL_NAME" ]; then
    echo "用法: bash migrate-one-skill.sh <源目录> <技能名称>"
    echo ""
    echo "示例:"
    echo '  bash migrate-one-skill.sh "/Users/agiray/Desktop/test/.agents/skills/vercel-react-best-practices" "vercel-react-best-practices"'
    exit 1
fi

TARGET_DIR="$GLOBAL_DIR/$SKILL_NAME"

echo -e "${BLUE}=== 迁移技能: $SKILL_NAME ===${NC}"
echo ""
echo "源目录: $SOURCE_DIR"
echo "目标目录: $TARGET_DIR"
echo ""

# 检查源目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo "错误: 源目录不存在"
    exit 1
fi

# 检查目标是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo -e "${GREEN}⊘${NC} 技能已存在于全局目录，跳过迁移"
    exit 0
fi

# 创建目标目录
mkdir -p "$TARGET_DIR"

# 复制所有文件
cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"

echo -e "${GREEN}✓${NC} 迁移完成!"
echo ""
echo "技能已复制到: $TARGET_DIR"
echo ""
echo "验证文件:"
ls -la "$TARGET_DIR/SKILL.md" 2>/dev/null && echo -e "${GREEN}✓ SKILL.md${NC}" || echo "✗ SKILL.md 未找到"
