#!/bin/bash

#
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "📂 Found repo root: $REPO_ROOT"

# Get the workflow directory
WORKFLOW_DIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
echo "📂 Running tests for: $WORKFLOW_DIR"

# Check if kubernets cluster exists
if command -v kubectl &> /dev/null; then
    echo "kubectl is installed."
else
    echo "kubectl is not installed.
    exit 1"
fi
if command -v helm &> /dev/null; then
    echo "helm is installed."
else
    echo "helm is not installed.
    exit 1"
fi
if kubectl get namespace default > /dev/null 2>&1; then
    echo "kubectl get namespace default command was successful."
else
    echo "kubectl get namespace default command failed."
    kubectl create ns default	
    echo "creating..."
fi

if kubectl get crd mcpservers.toolhive.stacklok.dev  > /dev/null 2>&1; then
    echo "kubectl get crd mcpservers command was successful."
else
    echo "kubectl get crd mcpservers command failed."
    echo "installing..."
    helm upgrade -i toolhive-operator-crds oci://ghcr.io/stacklok/toolhive/toolhive-operator-crds	
fi
if kubectl get mcpservers maestro-k  > /dev/null 2>&1; then
    echo "kubectl get mcpservers maestro-k command was successful."
else
    echo "kubectl get mcpservers maestro-k command failed."
    echo "creating..."
    TOOLS_YAML=$(find "$WORKFLOW_DIR" -maxdepth 1 -type f -name "tools.yaml")
    echo $TOOLS_YAML
    find "$WORKFLOW_DIR"
    maestro create "$TOOLS_YAML"
    sleep 10
    kubectl patch service mcp-maestro-k-proxy -p '{"spec":{"type":"NodePort"}}'
    kubectl patch svc mcp-maestro-k-proxy --type=json -p '[{"op":"replace","path":"/spec/ports/0/nodePort","value":30051}]'
fi

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
INSTALLED_MAESTRO_ROOT="$(find $REPO_ROOT/.venv/lib -type d -name "maestro")"
SCHEMA_DIR="$(cd "$INSTALLED_MAESTRO_ROOT/schemas" && pwd)"
if [ ! -d "$SCHEMA_DIR" ]; then
    SCHEMA_DIR="$(cd "$REPO_ROOT/schemas" && pwd)"
fi
AGENT_SCHEMA_PATH="$SCHEMA_DIR/agent_schema.json"
WORKFLOW_SCHEMA_PATH="$SCHEMA_DIR/workflow_schema.json"

echo "🔍 Using schema files:"
echo "   - Agent schema: $AGENT_SCHEMA_PATH"
echo "   - Workflow schema: $WORKFLOW_SCHEMA_PATH"

# Validate YAML files
echo "📝 Validating agents.yaml..."
maestro validate "$AGENT_SCHEMA_PATH" "$AGENTS_YAML" || { echo "❌ Failed to validate agents.yaml!"; exit 1; }

echo "📝 Validating workflow.yaml..."
maestro validate "$WORKFLOW_SCHEMA_PATH" "$WORKFLOW_YAML" || { echo "❌ Failed to validate workflow.yaml!"; exit 1; }

# Run workflow in dry-run mode
# echo "🧪 Running workflow in dry-run mode..."
# echo "" | maestro run --dry-run "$AGENTS_YAML" "$WORKFLOW_YAML" || { echo "❌ Workflow test failed!"; exit 1; }

# Run workflow
echo "🧪 Running workflow..."
echo "" | maestro run "$AGENTS_YAML" "$WORKFLOW_YAML" || { echo "❌ Workflow test failed!"; exit 1; }

# If we get here, the dry-run was successful
echo "✅ Workflow dry-run succeeded!"

# If --real-run is specified, run the workflow for real
if [[ "$2" == "--real-run" ]]; then
    echo "🚀 Running workflow for real..."
    echo "" | maestro run "$AGENTS_YAML" "$WORKFLOW_YAML" || { echo "❌ Workflow test failed (real run)!"; exit 1; }
    echo "✅ Workflow real run succeeded!"
fi

echo "✅ All tests completed successfully!"
