#!/bin/bash

# Get the workflow directory
WORKFLOW_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
echo "📂 Running tests for: $WORKFLOW_DIR"

# Find YAML files
AGENTS_YAML=$(find "$WORKFLOW_DIR" -maxdepth 1 -type f -name "agents.yaml")
WORKFLOW_YAML=$(find "$WORKFLOW_DIR" -maxdepth 1 -type f -name "workflow.yaml")

if [[ -z "$AGENTS_YAML" ]]; then
    echo "❌ Error: Missing agents.yaml in $WORKFLOW_DIR"
    exit 1
fi

if [[ -z "$WORKFLOW_YAML" ]]; then
    echo "❌ Error: Missing workflow.yaml in $WORKFLOW_DIR"
    exit 1
fi

# Find schema files
SCHEMA_DIR="$(cd "$WORKFLOW_DIR/../../../../schemas" && pwd)"
if [ ! -d "$SCHEMA_DIR" ]; then
    SCHEMA_DIR="$(cd "$WORKFLOW_DIR/../../../schemas" && pwd)"
fi
AGENT_SCHEMA_PATH="$SCHEMA_DIR/agent_schema.json"
WORKFLOW_SCHEMA_PATH="$SCHEMA_DIR/workflow_schema.json"

echo "🔍 Using schema files:"
echo "   - Agent schema: $AGENT_SCHEMA_PATH"
echo "   - Workflow schema: $WORKFLOW_SCHEMA_PATH"

# Validate YAML files
echo "📝 Validating agents.yaml..."
uv run maestro validate "$AGENT_SCHEMA_PATH" "$AGENTS_YAML" || { echo "❌ Failed to validate agents.yaml!"; exit 1; }

echo "📝 Validating workflow.yaml..."
uv run maestro validate "$WORKFLOW_SCHEMA_PATH" "$WORKFLOW_YAML" || { echo "❌ Failed to validate workflow.yaml!"; exit 1; }

# Run workflow in dry-run mode
echo "🧪 Running workflow in dry-run mode..."
echo "" | uv run maestro run --dry-run "$AGENTS_YAML" "$WORKFLOW_YAML" || { echo "❌ Workflow test failed!"; exit 1; }

# If we get here, the dry-run was successful
echo "✅ Workflow dry-run succeeded!"

# If --real-run is specified, run the workflow for real
if [[ "$2" == "--real-run" ]]; then
    echo "🚀 Running workflow for real..."
    echo "" | uv run maestro run "$AGENTS_YAML" "$WORKFLOW_YAML" || { echo "❌ Workflow test failed (real run)!"; exit 1; }
    echo "✅ Workflow real run succeeded!"
fi

echo "✅ All tests completed successfully!"