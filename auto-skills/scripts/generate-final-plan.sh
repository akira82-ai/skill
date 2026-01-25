#!/bin/bash
# Generate final task plan from all task-N.json files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# Get current task directory
task_dir=$(get_current_task_dir)
if [[ -z "$task_dir" ]]; then
    echo "Error: Not in a task directory" >&2
    exit 1
fi

output_file="${task_dir}/task-plan.json"

# Find all task-*.json files and combine them
echo "{" > "$output_file"
echo "  \"tasks\": [" >> "$output_file"

first=true
for task_file in "${task_dir}"/task-*.json; do
    if [[ ! -f "$task_file" ]]; then
        continue
    fi

    if $first; then
        first=false
    else
        echo "," >> "$output_file"
    fi

    # Append the task content (without outer braces)
    tail -n +2 "$task_file" | head -n -1 | sed 's/^/    /' >> "$output_file"
done

echo "" >> "$output_file"
echo "  ]," >> "$output_file"
echo "  \"generatedAt\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"" >> "$output_file"
echo "}" >> "$output_file"

cat "$output_file"
