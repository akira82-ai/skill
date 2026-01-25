#!/bin/bash
# Scan local installed skills and output JSON

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

SKILLS_DIR=$(get_skills_dir)

if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "[]"
    exit 0
fi

output="["

for skill_dir in "$SKILLS_DIR"/*; do
    if [[ ! -d "$skill_dir" ]]; then
        continue
    fi

    skill_file="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_file" ]]; then
        continue
    fi

    # Extract metadata from SKILL.md
    name=$(basename "$skill_dir")
    description=$(grep -E "^description:" "$skill_file" | sed 's/description: //' | sed 's/"//g')

    if [[ -z "$description" ]]; then
        description=$(grep -A 5 "^## 技能概述" "$skill_file" | head -1 | sed 's/^## 技能概述//')
    fi

    # Escape quotes in description
    description=$(echo "$description" | sed 's/"/\\"/g')

    if [[ "$output" != "[" ]]; then
        output="${output},"
    fi

    output="${output}
  {
    \"name\": \"$name\",
    \"description\": \"$description\",
    \"path\": \"$skill_dir\"
  }"
done

output="${output}
]"

echo "$output"
