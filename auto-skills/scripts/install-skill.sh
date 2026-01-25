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

# 在 /tmp 下执行安装，避免污染项目目录
cd /tmp || { echo "Failed to cd to /tmp" >&2; exit 1; }

# 创建临时工作目录
TEMP_WORK_DIR=$(mktemp -d -t skill-install-XXXXXX)
cd "$TEMP_WORK_DIR" || { echo "Failed to cd to temp dir" >&2; exit 1; }

echo "Working in temporary directory: $TEMP_WORK_DIR" >&2

if eval "$install_command" 2>&1; then
    # ===== 自动迁移到全局目录 =====
    GLOBAL_SKILLS_DIR="$HOME/.claude/skills"
    mkdir -p "$GLOBAL_SKILLS_DIR"

    # 等待文件系统同步
    sleep 1

    # 从 /tmp 的临时目录查找 .agents/skills
    if [ -d ".agents/skills" ]; then
        echo "Migrating skill to global directory..." >&2

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
                    echo "✓ Installed '$skill_name' to: ~/.claude/skills/" >&2
                fi
            fi
        done
    fi

    # 清理临时目录
    cd /tmp
    rm -rf "$TEMP_WORK_DIR"
    echo "Cleaned up temporary files." >&2
    # ===== 迁移结束 =====

    echo '{"status": "success", "command": "'"$install_command"'"}'
    exit 0
else
    echo '{"status": "failed", "command": "'"$install_command"'", "error": "installation failed"}' >&2
    exit 1
fi
