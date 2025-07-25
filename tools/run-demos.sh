#!/bin/bash

echo "🚀 Running all demos in CI..."
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "📂 Running from: $REPO_ROOT"

WORKFLOWS_DIR="$REPO_ROOT/workflows"
COMMON_DIR="$REPO_ROOT/workflows/common"

if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    echo "❌ Error: Workflows directory not found at $WORKFLOWS_DIR"
    exit 1
fi

if [[ ! -d "$COMMON_DIR" ]]; then
    echo "❌ Error: Common directory not found at $COMMON_DIR"
    exit 1
fi

echo "🔍 Verifying Maestro installation..."

if command -v maestro &>/dev/null; then
    MAESTRO_CMD="maestro"
    echo "✅ Found maestro in PATH"
else
    echo "❌ Error: Neither uv nor maestro found in PATH"
    echo "Please install maestro or uv first."
    exit 1
fi

echo "✅ Maestro is running correctly using: $MAESTRO_CMD"

# Create temporary files to track test counts
TEMP_DIR=$(mktemp -d)
EXPECTED_TESTS_FILE="$TEMP_DIR/expected_tests.txt"
TEST_COUNT_FILE="$TEMP_DIR/test_count.txt"
echo "0" > "$EXPECTED_TESTS_FILE"
echo "0" > "$TEST_COUNT_FILE"

# Helper: check if agents.yaml includes a Slack agent
contains_slack_agent() {
  local agent_file="$1"
  if [[ ! -f "$agent_file" ]]; then
    return 1
  fi
  grep -qiE 'name: slack|custom_agent: slack_agent|app: slack-example' "$agent_file"
}

# Iterate over each demo workflow (skipping the common directory)
find "$WORKFLOWS_DIR" -mindepth 1 -type d -print0 | while IFS= read -r -d '' demo; do
    if [[ "$demo" == "$COMMON_DIR" ]]; then
        echo "⚠️ Skipping common/ directory..."
        continue
    fi

    DEMO_NAME=$(basename "$demo")
    echo -e "\n========================================"
    echo "====== Running demo: $DEMO_NAME ======"
    echo "========================================\n"

    if [[ -f "$demo/agents.yaml" && -f "$demo/workflow.yaml" ]]; then
        if contains_slack_agent "$demo/agents.yaml"; then
            echo "⚠️ Skipping $DEMO_NAME — contains Slack agent"
            continue
        fi

        if [[ "$DEMO_NAME" == "activity-planner.ai" || "$DEMO_NAME" == "cbom.ai" ]]; then
            echo "⚠️ Skipping $DEMO_NAME — this one is broken for now"
            continue
        fi

        echo "🔍 Running tests for demo at: $demo"
        CURRENT_EXPECTED=$(cat "$EXPECTED_TESTS_FILE")
        echo $((CURRENT_EXPECTED + 1)) > "$EXPECTED_TESTS_FILE"
        
        echo "🩺 Running common doctor.sh for demo..."
        bash "$COMMON_DIR/doctor.sh" || { echo "❌ doctor.sh failed for demo at $demo"; exit 1; }

        if [[ -x "$demo/test.sh" ]]; then
            echo "🧪 Running custom test.sh for demo..."
            bash "$demo/test.sh" "$COMMON_DIR/test.sh" "$demo" || { echo "❌ custom test.sh failed for demo at $demo"; exit 1; }
        else
            echo "🧪 Running common test.sh for demo..."
            MAESTRO_DEMO_OLLAMA_MODEL="ollama/llama3.2:3b" bash "$COMMON_DIR/test.sh" "$demo" <<< "" || { echo "❌ test.sh failed for demo at $demo"; exit 1; }
        fi
        
        CURRENT_COUNT=$(cat "$TEST_COUNT_FILE")
        echo $((CURRENT_COUNT + 1)) > "$TEST_COUNT_FILE"
    else
        echo "⚠️ Skipping demo at $demo (missing agents.yaml or workflow.yaml)"
    fi
done

EXPECTED_TESTS=$(cat "$EXPECTED_TESTS_FILE")
TEST_COUNT=$(cat "$TEST_COUNT_FILE")
rm -rf "$TEMP_DIR"

if [[ "$TEST_COUNT" -eq "$EXPECTED_TESTS" && "$EXPECTED_TESTS" -gt 0 ]]; then
    echo "✅ All $EXPECTED_TESTS tests completed successfully!"
else
    echo "❌ Error: Not all expected tests were executed! ($TEST_COUNT/$EXPECTED_TESTS)"
    exit 1
fi
