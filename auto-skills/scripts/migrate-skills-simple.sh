#!/bin/bash

# 简化版技能迁移脚本
# 用法：bash migrate-skills-simple.sh

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

GLOBAL_SKILLS_DIR="$HOME/.claude/skills"

echo -e "${BLUE}=== 技能迁移工具 ===${NC}"
echo ""

# 步骤1：搜索项目
echo -e "${YELLOW}步骤1：搜索项目中的 .agents/skills 目录...${NC}"
echo ""

# 保存找到的技能到临时文件
TEMP_FILE="/tmp/found_skills.txt"
> "$TEMP_FILE"

# 搜索 Desktop 目录
for project_dir in "$HOME/Desktop"/*; do
    if [ -d "$project_dir/.agents/skills" ]; then
        echo "检查项目: $project_dir"
        for skill_dir in "$project_dir/.agents/skills"/*; do
            if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
                skill_name=$(basename "$skill_dir")
                echo -e "  ${GREEN}✓${NC} 发现技能: $skill_name"
                echo "$skill_dir|$skill_name" >> "$TEMP_FILE"
            fi
        done
    fi
done

# 检查是否找到技能
if [ ! -s "$TEMP_FILE" ]; then
    echo "未找到任何技能"
    rm -f "$TEMP_FILE"
    exit 0
fi

echo ""

# 步骤2：显示迁移计划
echo -e "${YELLOW}步骤2：迁移计划${NC}"
echo ""
echo "将把以下技能复制到全局目录: $GLOBAL_SKILLS_DIR"
echo ""

while IFS='|' read -r skill_dir skill_name; do
    echo -e "  ${BLUE}→${NC} $skill_name"
done < "$TEMP_FILE"
echo ""

# 步骤3：执行迁移
echo -e "${YELLOW}步骤3：开始迁移...${NC}"
echo ""

MIGRATED=0
SKIPPED=0

while IFS='|' read -r skill_dir skill_name; do
    target_dir="$GLOBAL_SKILLS_DIR/$skill_name"

    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}⊘${NC} 跳过: $skill_name (已存在)"
        SKIPPED=$((SKIPPED + 1))
    else
        mkdir -p "$target_dir"
        cp -r "$skill_dir"/* "$target_dir/"
        echo -e "${GREEN}✓${NC} 已迁移: $skill_name"
        MIGRATED=$((MIGRATED + 1))
    fi
done < "$TEMP_FILE"

# 清理临时文件
rm -f "$TEMP_FILE"

# 完成
echo ""
echo -e "${GREEN}=== 迁移完成 ===${NC}"
echo ""
echo "迁移了 $MIGRATED 个技能"
echo "跳过了 $SKIPPED 个技能"
echo ""
echo "全局技能目录: $GLOBAL_SKILLS_DIR"
