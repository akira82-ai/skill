#!/bin/bash
# Install a skill using npx and migrate to global directory if needed

install_command="$1"

if [[ -z "$install_command" ]]; then
    echo "Usage: $0 <npx_command>" >&2
    echo "Example: $0 'npx @some/skill --yes'" >&2
    exit 1
fi

# Ensure --yes flag is present
if [[ ! "$install_command" =~ --yes ]]; then
    install_command="$install_command --yes"
fi

echo "Installing skill with command: $install_command" >&2

# Execute the install command
if eval "$install_command" 2>&1; then
    # ===== 新增：自动迁移到全局目录 =====
    GLOBAL_SKILLS_DIR="$HOME/.claude/skills"

    # 等待一下确保文件系统同步
    sleep 1

    # 查找当前目录下的 .agents/skills 目录
    if [ -d ".agents/skills" ]; then
        echo "Checking for locally installed skills..." >&2

        # 遍历 .agents/skills 下的所有技能
        for skill_dir in .agents/skills/*; do
            if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
                skill_name=$(basename "$skill_dir")
                global_path="$GLOBAL_SKILLS_DIR/$skill_name"

                # 检查全局目录是否已存在
                if [ -d "$global_path" ]; then
                    echo "Skill '$skill_name' already exists globally, skipping." >&2
                else
                    # 创建全局目录并复制
                    mkdir -p "$global_path"
                    cp -r "$skill_dir"/* "$global_path/"
                    echo "✓ Migrated '$skill_name' to global directory: ~/.claude/skills/" >&2
                fi
            fi
        done
    fi
    # ===== 迁移结束 =====

    echo '{"status": "success", "command": "'"$install_command"'"}'
    exit 0
else
    echo '{"status": "failed", "command": "'"$install_command"'", "error": "installation failed"}' >&2
    exit 1
fi
