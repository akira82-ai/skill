#!/bin/bash
# Record task result to task-N.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

task_num="$1"
task_desc="$2"
skill_name="$3"
skill_type="${4:-local}"  # local, remote, manual
install_cmd="${5:-}"

# Get current task directory
task_dir=$(get_current_task_dir)
if [[ -z "$task_dir" ]]; then
    echo "Error: Not in a task directory" >&2
    exit 1
fi

output_file="${task_dir}/task-${task_num}.json"

cat > "$output_file" << EOF
{
  "taskId": $task_num,
  "description": "$task_desc",
  "skill": "$skill_name",
  "skillType": "$skill_type",
  "installCmd": "$install_cmd",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

echo "$output_file"
