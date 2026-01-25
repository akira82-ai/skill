#!/bin/bash

# 脚本：将 npx skills 安装的技能迁移到全局目录
# 用法：bash migrate-skills.sh

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 技能迁移工具 ===${NC}"
echo ""

# 全局技能目录
GLOBAL_SKILLS_DIR="$HOME/.claude/skills"

# 创建临时目录用于搜索
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# 步骤1：查找所有 .agents/skills 目录
echo -e "${YELLOW}步骤1：搜索项目中的 .agents/skills 目录...${NC}"

PROJECT_DIRS=$(find "$HOME/Desktop" "$HOME/Documents" -type d -name ".agents" 2>/dev/null || true)

if [ -z "$PROJECT_DIRS" ]; then
    echo "未找到任何 .agents 目录"
    exit 0
fi

echo "找到的项目："
echo "$PROJECT_DIRS" | while read -r agent_dir; do
    project_dir=$(dirname "$agent_dir")
    echo "  - $project_dir"
done
echo ""

# 步骤2：收集所有已安装的技能
echo -e "${YELLOW}步骤2：收集已安装的技能...${NC}"

FOUND_SKILLS=""

while IFS= read -r agent_dir; do
    skills_dir="$agent_dir/skills"
    if [ -d "$skills_dir" ]; then
        while IFS= read -r skill_dir; do
            skill_name=$(basename "$skill_dir")
            skillmd="$skill_dir/SKILL.md"

            if [ -f "$skillmd" ]; then
                FOUND_SKILLS="$FOUND_SKILLS$skill_dir|$skill_name|$skillmd"$'\n'
                echo -e "  ${GREEN}✓${NC} 发现技能: $skill_name"
                echo "     路径: $skill_dir"
            fi
        done < <(find "$skills_dir" -maxdepth 1 -type d -not -name "skills" 2>/dev/null)
    fi
done < <(echo "$PROJECT_DIRS")

if [ -z "$FOUND_SKILLS" ]; then
    echo "未找到任何技能"
    exit 0
fi

echo ""

# 步骤3：显示迁移计划
echo -e "${YELLOW}步骤3：迁移计划${NC}"
echo ""
echo "将把以下技能移动到全局目录: $GLOBAL_SKILLS_DIR"
echo ""

echo "$FOUND_SKILLS" | while IFS='|' read -r skill_dir skill_name skillmd; do
    [ -z "$skill_dir" ] && continue
    echo -e "  ${BLUE}→${NC} $skill_name"
done
echo ""

# 步骤4：执行迁移
echo -e "${YELLOW}步骤4：开始迁移...${NC}"
echo ""

MIGRATED_COUNT=0
SKIPPED_COUNT=0

echo "$FOUND_SKILLS" | while IFS='|' read -r skill_dir skill_name skillmd; do
    [ -z "$skill_dir" ] && continue

    target_dir="$GLOBAL_SKILLS_DIR/$skill_name"

    # 检查全局目录是否已存在
    if [ -d "$target_dir" ]; then
        echo -e "${YELLOW}⊘${NC} 跳过: $skill_name (全局目录已存在)"
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # 创建目标目录
    mkdir -p "$target_dir"

    # 复制所有文件
    cp -r "$skill_dir"/* "$target_dir/" 2>/dev/null || true

    echo -e "${GREEN}✓${NC} 已迁移: $skill_name"
    echo "     从: $skill_dir"
    echo "     到: $target_dir"
    echo ""

    MIGRATED_COUNT=$((MIGRATED_COUNT + 1))
done

# 步骤5：清理原目录（可选）
echo ""
echo -e "${YELLOW}步骤5：清理选项${NC}"
echo ""
echo "技能已复制到全局目录。"
echo "原项目中的 .agents/skills 目录仍然存在。"
echo ""
read -p "是否删除原项目中的技能目录？(y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$FOUND_SKILLS" | while IFS='|' read -r skill_dir skill_name skillmd; do
        [ -z "$skill_dir" ] && continue
        rm -rf "$skill_dir"
        echo -e "${GREEN}✓${NC} 已删除: $skill_dir"
    done
fi

# 完成
echo ""
echo -e "${GREEN}=== 迁移完成 ===${NC}"
echo ""
echo "迁移了 $MIGRATED_COUNT 个技能"
echo "跳过了 $SKIPPED_COUNT 个技能"
echo ""
echo "全局技能目录: $GLOBAL_SKILLS_DIR"
