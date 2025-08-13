# Maestro Demos

This repository contains demos and use cases for [Maestro](https://github.com/AI4quantum/maestro), a tool for managing and running AI agents and workflows. This repository was originally part of the demos directory in the main Maestro project and has been extracted as a standalone repository for easier access and contribution.

## About This Repository

This repository contains:
- Various workflow demonstrations showcasing Maestro's capabilities
- Agent configurations and examples
- Complete working examples for different use cases
- Documentation and setup guides for each demo

## Prerequisites

To use these demos, you'll need to install Maestro first:

```bash
pip install git+https://github.com/AI4quantum/maestro.git@v0.5.0
```

Note: If using scoring or crewai agents, install:
```bash
pip install "maestro[crewai] @ git+https://github.com/AI4quantum/maestro.git@v0.5.0"
```

## Getting Started

1. Clone this repository:
```bash
git clone https://github.com/your-username/maestro-demos.git
cd maestro-demos
```

2. Navigate to any demo directory and follow its specific README for setup instructions.

3. Run a workflow:
```bash
maestro run <workflow_path>
```

4. Create an agent:
```bash
maestro create <agent_path>
```

5. Validate a workflow or agent:
```bash
maestro validate <path>
```

## Available Demos

Browse the `workflows/` and `agents/` directories to explore various examples:

- **Workflows**: Complete workflow demonstrations
- **Agents**: Individual agent examples and configurations
- **Use Cases**: Real-world application examples

Each demo includes its own README with specific setup and usage instructions.

## Environment Setup

For a detailed guide on using Podman Desktop, docker-compose, and bee-stack see:

- [Podman-based environment setup](docs/podman-setup.md)

## Development

1. Clone the repository:
```bash
git clone https://github.com/your-username/maestro-demos.git
cd maestro-demos
```

2. Install development dependencies:
```bash
uv sync --all-extras
```

3. Run tests:
```bash
uv run pytest
```

4. Run the formatter:
```bash
uv run ruff format
```

5. Run the linter:
```bash
uv run ruff check --fix
```

### Ollama setup

By default, the .env file and api runs on llama version 3.1. Download ollama: <https://ollama.com/>
and navigate to llama3.1 model: <https://ollama.com/library/llama3.1>.

To use a different model, use `ollama pull` and choose from the official models. If using a different model, make sure to define in the agents.yaml file correctly.

For MCP tools, certain models support tools while others do not. Models that current support tooling that are tested include `llama3.1:8b`, `llama3.3-70b-instruct` and `qwen3:8b`.

The .env file should look like this:

```bash
OPENAI_API_BASE=http://localhost:11434/v1
OPENAI_API_KEY=ollama
```

##### SlackBot support

Please set `SLACK_BOT_TOKEN` and `SLACK_TEAM_ID` as environment variables. See `./tests/yamls/agents/slack_agent.yaml` and `./tests/yamls/workflow_agent.yaml` for details. The output of slack message will be whatever is passed into the prompt.

##### Evaluation/Metrics Support

The Metrics Agent integrates Opik's LLM as a judge metrics into our workflows. Automatically route `spec.model` in the agent definition and add to workflow to automatically evaluate using `AnswerRelevance` and `Hallucination` scores. Can also additionally add `context` if the user knows the correct response or format a response should take.

See `./tests/yamls/agents/metrics_agent.py` and `./tests/yamls/workflows/metrics_agents.py` for more details.

If using the metrics, we need to add a opik evaluation key, which can be obtained [here](https://www.comet.com/opik/). Then you can use the dashboard to track metrics generated inside a workflow.

```bash
COMET_API_KEY=placeholder
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details.

## Related Links

- [Main Maestro Repository](https://github.com/AI4quantum/maestro)
- [Maestro Documentation](https://github.com/AI4quantum/maestro)
- [Original Demos Directory](https://github.com/AI4quantum/maestro/tree/main/demos)
