#! /bin/bash

cd "$(dirname "$0")/../../../" || exit 1
echo "📂 Running from: $(pwd)"
export PYTHONPATH="$(pwd):$(pwd)/src"
echo "🐍 PYTHONPATH set to: $PYTHONPATH"
if ! command -v maestro &> /dev/null
then
    echo "⚠️  Maestro CLI not found, installing..."
    pip install --user maestro
fi

echo "📝 Validating agents.yaml..."
SCHEMA_DIR="$(pwd)/schemas"
PYTHONPATH=$PYTHONPATH maestro validate "$SCHEMA_DIR/agent_schema.json" ./demos/workflows/weather-checker.ai/agents.yaml

echo "📝 Validating workflow.yaml..."
PYTHONPATH=$PYTHONPATH maestro validate "$SCHEMA_DIR/workflow_schema.json" ./demos/workflows/weather-checker.ai/workflow.yaml

echo "🚀 Running workflow..."
PYTHONPATH=$PYTHONPATH maestro run ./demos/workflows/weather-checker.ai/agents.yaml ./demos/workflows/weather-checker.ai/workflow.yaml