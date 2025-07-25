#!/bin/bash

echo "🔍 Checking environment..."

echo "🔍 Verifying Maestro installation..."

if command -v maestro &>/dev/null; then
    MAESTRO_CMD="maestro"
    echo "✅ Found maestro in PATH"
else
    echo "❌ Error: maestro not found"
    echo "Please install maestro first."
    exit 1
fi

# Check workflow directory structure
echo "📂 Checking workflow directory structure..."
if [[ -d "$(dirname "$0")" ]]; then
    echo "$(dirname "$0")"
    echo "✅ Environment check passed!"
else
    echo "❌ Error: workflow directory not found"
    echo "$(dirname "$0")"
    exit 1
fi
