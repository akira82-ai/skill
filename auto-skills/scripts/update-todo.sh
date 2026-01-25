#!/bin/bash
# Update TODO.md with task status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

task_num="$1"
status="$2"  # pending, in_progress, done
details="${3:-执行中}"

# Get current task directory
task_dir=$(get_current_task_dir)
if [[ -z "$task_dir" ]]; then
    echo "Error: Not in a task directory" >&2
    exit 1
fi

todo_file="${task_dir}/TODO.md"

if [[ ! -f "$todo_file" ]]; then
    echo "Error: TODO.md not found" >&2
    exit 1
fi

update_todo_status "$todo_file" "$task_num" "$status" "$details"

echo "Updated TODO.md for task $task_num: $status"
