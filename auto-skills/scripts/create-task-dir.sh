#!/bin/bash
# Create task directory with initial files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

task_name="$1"

if [[ -z "$task_name" ]]; then
    echo "Usage: $0 <task_name>" >&2
    exit 1
fi

result=$(create_task_directory "$task_name")
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    # Create initial files structure
    echo "[]" > "${result}/local-skills.json"
    echo "[]" > "${result}/task-breakdown.json"
    echo "{}" > "${result}/task-plan.json"

    echo "$result"
    exit 0
else
    exit 1
fi
