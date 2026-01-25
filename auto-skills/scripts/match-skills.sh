#!/bin/bash
# Match skills based on task description

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

task_description="$1"
local_skills_json="$2"

if [[ -z "$task_description" || -z "$local_skills_json" ]]; then
    echo "Usage: $0 <task_description> <local_skills_json>" >&2
    exit 1
fi

# This is a simple keyword-based matching
# For better semantic matching, we could use embeddings or LLM
# For now, we return the JSON for the calling process (SKILL.md) to do semantic matching

# Output the task description and skills for LLM to analyze
cat << EOF
{
  "task": "$task_description",
  "skills": $(cat "$local_skills_json")
}
EOF
