# Maestro Demos CLI Tool

A command-line interface for launching Maestro meta-agents-v2 workflows from any repository without needing to reference specific file paths.

## Installation

### From Source (Development)

```bash
# Clone the repository
git clone https://github.com/AI4quantum/maestro-demos.git
cd maestro-demos

# Install in development mode
pip install -e .
```

### From PyPI (Future Release)

```bash
pip install maestro-demos
```

## Prerequisites

- Python 3.11 or higher
- Maestro CLI installed: `pip install git+https://github.com/AI4quantum/maestro.git@v0.2.0`
- Access to a Maestro backend (bee-stack, Ollama, etc.)

## Usage

The `maestro-demos` CLI provides two commands for launching meta-agents-v2 workflows:

### 1. Create Agents (`create-agents`)

Launch the agents file generation workflow API.

```bash
maestro-demos create-agents
```

This command runs:
```bash
maestro serve <packaged agents.yaml> <packaged workflow.yaml>
```
for the agents_file_generation workflow.

### 2. Create Workflow (`create-workflow`)

Launch the workflow file generation workflow API.

```bash
maestro-demos create-workflow
```

This command runs:
```bash
maestro serve <packaged agents.yaml> <packaged workflow.yaml>
```
for the workflow_file_generation workflow.

## How It Works

The CLI tool packages the meta-agents-v2 workflows from the maestro-demos repository:

1. **Agents Generation**: Uses the `TaskInterpreter` and `AgentYAMLBuilder` agents to:
   - Parse natural language goals into structured agent requirements
   - Generate valid `agents.yaml` files with appropriate agent definitions

2. **Workflow Generation**: Uses the `WorkflowBuilder` agent to:
   - Take agent definitions and create proper `workflow.yaml` files
   - Sequence the agents correctly and set up the workflow structure

The CLI simply launches `maestro serve` with the correct packaged workflow files, so all the logic is handled by the workflow itself.

## Integration with Other Repositories

Once installed, you can use this CLI tool from any repository:

```bash
# In your project directory
cd /path/to/your/project

# Launch the agents generation API
maestro-demos create-agents

# Launch the workflow generation API
maestro-demos create-workflow
```

The tool will start maestro serve with the appropriate workflow files, and you can then interact with the generated workflow through the Maestro interface.

## Examples

### Example 1: Launch Agents Generation API

```bash
# From any directory
maestro-demos create-agents
```

This launches the API that can generate agents.yaml files from natural language descriptions.

### Example 2: Launch Workflow Generation API

```bash
# From any directory
maestro-demos create-workflow
```

This launches the API that can generate workflow.yaml files from agent definitions.

## Troubleshooting

### Maestro CLI Not Found

If you get an error that maestro CLI is not found:

```bash
pip install git+https://github.com/AI4quantum/maestro.git@v0.2.0
```

### Workflow Files Not Found

If you get an error about missing workflow files, ensure the package was installed correctly:

```bash
pip install -e .
```

### Backend Connection Issues

Make sure you have a Maestro backend running (bee-stack, Ollama, etc.) and that your environment variables are configured correctly.

## Development

To contribute to the CLI tool:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `pip install -e .`
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details. 