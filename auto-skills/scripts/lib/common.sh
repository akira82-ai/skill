#!/bin/bash
# Common functions for task-orchestrator scripts

# Get the skills directory
get_skills_dir() {
    echo "$HOME/.claude/skills"
}

# Get current task directory
get_current_task_dir() {
    local pwd=$(pwd)
    if [[ "$pwd" =~ ([0-9]{2}-[0-9]{2}-.+)$ ]]; then
        echo "$pwd"
    else
        echo ""
    fi
}

# Create task directory with template
create_task_directory() {
    local task_name="$1"
    local date_prefix=$(date +%m-%d)
    local dir_name="${date_prefix}-${task_name}"

    # Sanitize directory name
    dir_name=$(echo "$dir_name" | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5_-]/-/g' | sed 's/-\+/-/g')

    local full_path="$(pwd)/${dir_name}"

    if [[ -d "$full_path" ]]; then
        echo "Directory already exists: $full_path" >&2
        echo "$full_path"
        return 1
    fi

    mkdir -p "$full_path/tasks"

    # Create initial TODO.md
    cat > "$full_path/TODO.md" << 'EOF'
# 任务执行计划

## 原始任务
PENDING_USER_INPUT

## 任务列表
EOF

    echo "$full_path"
    return 0
}

# Write JSON file safely
write_json() {
    local file="$1"
    local content="$2"
    echo "$content" > "$file"
}

# Read JSON file
read_json() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cat "$file"
    else
        echo "{}"
    fi
}

# Append task to TODO.md
append_todo_task() {
    local todo_file="$1"
    local task_num="$2"
    local task_desc="$3"
    local status="$4"  # pending, in_progress, done

    local checkbox="[ ]"
    if [[ "$status" == "done" ]]; then
        checkbox="[x]"
    elif [[ "$status" == "in_progress" ]]; then
        checkbox="[~]"
    fi

    cat >> "$todo_file" << EOF

### 任务${task_num}：${task_desc}
${checkbox} 待执行
EOF
}

# Update task status in TODO.md
update_todo_status() {
    local todo_file="$1"
    local task_num="$2"
    local status="$3"
    local details="$4"

    local temp_file="${todo_file}.tmp"
    local in_task=0
    local found=0

    while IFS= read -r line; do
        if [[ "$line" =~ "### 任务${task_num}：" ]]; then
            in_task=1
            found=1
            echo "$line" >> "$temp_file"
            continue
        fi

        if [[ $in_task -eq 1 && "$line" =~ ^\[ ]]; then
            local checkbox="[ ]"
            if [[ "$status" == "done" ]]; then
                checkbox="[x]"
            elif [[ "$status" == "in_progress" ]]; then
                checkbox="[~]"
            fi
            echo "${checkbox} ${details}" >> "$temp_file"
            in_task=0
            continue
        fi

        echo "$line" >> "$temp_file"
    done < "$todo_file"

    if [[ $found -eq 1 ]]; then
        mv "$temp_file" "$todo_file"
    else
        rm -f "$temp_file"
    fi
}

# Extract npx command from skill description
extract_npx_command() {
    local skill_desc="$1"
    if [[ "$skill_desc" =~ npx[[:space:]]+[a-zA-Z0-9/_@.-]+ ]]; then
        echo "$BASH_REMATCH" | sed 's/npx \(.*\)/npx \1 --yes/'
    fi
}

# Sanitize filename
sanitize_filename() {
    echo "$1" | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5_-]/_/g'
}

export -f get_skills_dir
export -f get_current_task_dir
export -f create_task_directory
export -f write_json
export -f read_json
export -f append_todo_task
export -f update_todo_status
export -f extract_npx_command
export -f sanitize_filename
