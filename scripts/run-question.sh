#!/bin/bash
set -euo pipefail

# 1. Validation: Ensure a question name was passed
if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-question.sh \"Question-XX Topic\"" >&2
  exit 1
fi

# 2. Path Resolution: Find the root of the repo (one level up from /scripts)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 3. Target Directory: Use the first argument ($1) as the folder name
QUESTION_DIR="$REPO_ROOT/$1"

# 4. Check if the directory exists
if [[ ! -d "$QUESTION_DIR" ]]; then
  echo "❌ Error: Question directory '$QUESTION_DIR' not found" >&2
  echo "Checking in: $REPO_ROOT" >&2
  exit 1
fi

# 5. Define file paths
SETUP="$QUESTION_DIR/LabSetUp.bash"
QUESTION_TEXT="$QUESTION_DIR/Questions.bash"
SOLUTION="$QUESTION_DIR/SolutionNotes.bash"
CHECK="$QUESTION_DIR/CheckSolution.bash"

# 6. Verify required files exist
[[ -f "$SETUP" ]] || { echo "Missing $SETUP" >&2; exit 1; }
[[ -f "$QUESTION_TEXT" ]] || { echo "Missing $QUESTION_TEXT" >&2; exit 1; }

# 7. Make scripts executable automatically
chmod +x "$SETUP"
[ -f "$SOLUTION" ] && chmod +x "$SOLUTION"
[ -f "$CHECK" ] && chmod +x "$CHECK"

# 8. Execution Flow
echo "==> Running lab setup for $1"
bash "$SETUP"

echo
echo "==> Question Details"
echo "-----------------------------------------------------------------------"
bash "$QUESTION_TEXT"
echo "-----------------------------------------------------------------------"

echo
if [[ -f "$SOLUTION" ]]; then
  echo "💡 Solutions and Notes are available in $SOLUTION"
  echo "To view them, run: cat \"$SOLUTION\""
fi

echo
if [[ -f "$CHECK" ]]; then
  echo "✅ To verify your work, run: bash \"$CHECK\""
fi
