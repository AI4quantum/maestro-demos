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
pip install git+https://github.com/AI4quantum/maestro.git@v0.2.0
```

Note: If using scoring or crewai agents, install:
```bash
pip install "maestro[crewai] @ git+https://github.com/AI4quantum/maestro.git@v0.2.0"
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

### Example environment setup using Podman Desktop, docker-compose, bee-stack, and local Ollama

#### bee-stack setup

From a new terminal, clone the [bee-stack repo](https://github.com/i-am-bee/bee-stack) and navigate into the directory:

```bash
git clone https://github.com/i-am-bee/bee-stack.git
cd bee-stack
```

Before proceeding, the local environment requires a container engine along with compose. In this case Podman Desktop is recommended.

#### Podman Desktop setup

Download Podman Desktop here:
<https://podman-desktop.io/downloads>

Inside of Podman Desktop, make sure the latest version is selected. Then, go to Settings (bottom left) -> Preferences -> scroll down to Experimental (Docker Compatibility) and enable it.

#### docker-compose

Installing podman desktop itself gives a platform to run, but we still need docker-compose itself to run the stack.

Install the matching architecture release of docker-compose: <https://github.com/docker/compose/releases>

Verify the installation by running: \
`docker-compose --version`

##### Possible docker-compose installation errors

1) Move docker-compose to the correct location, using a `sudo` command if neccessary

    `sudo mv ~/Downloads/docker-compose-darwin-aarch64 /usr/local/bin/docker-compose`
2) Make compose executable \
    `sudo chmod +x /usr/local/bin/docker-compose`

3) MacOS GateKeeper Warning: \
    1) System Settings -> Privacy/Security -> Scroll down to find error message and "Allow anyway"

#### Ollama setup

By default, the .env file and api runs on llama version 3.1. Download ollama: <https://ollama.com/>
and navigate to llama3.1 model: <https://ollama.com/library/llama3.1>.

To use a different model, use `ollama pull` and choose from the official models. If using a different model, make sure to define in the agents.yaml file correctly. 

For MCP tools, certain models support tools while others do not. Models that current support tooling that are tested include `llama3.1:8b`, `llama3.3-70b-instruct` and `qwen3:8b`. To note, one of the best performing models we tested `gpt-4o-mini` requires external API credit.

#### Create a Podman machine

`podman machine init`

Connect Podman with docker-compose, set as rootful, allocate enough memory (8GB or more), and then start machine (everytime you restart your computer): \

- `podman machine set --rootful` \
- `podman machine set --memory=12288`\
- `podman machine start`

Setup bee-stack: (Note: if you already have setup before and have created agents, skip this step and directly to start the stack)
`./bee-stack.sh setup`

If desired, use the different commands to run, stop, or clean bee-stack: \
`./bee-stack.sh start` \
`./bee-stack.sh stop`\
`./bee-stack.sh clean`

Navigate to `localhost:3000` in order to run access the UI provided by bee-stack.

To save resources the Podman machine can be stopped and restarted later.
`podman machine stop`

##### Error Logging

Run `podman logs -f bee-stack-bee-api-1` in order to determine further errors with the api.

Test connection using:

```bash
curl -X POST http://localhost:11434/api/generate -d '{         
  "model": "llama3.1",
  "prompt": "Hello, world!"
}'
```

##### Allowing maestro to be run from anywhere

Create wrapper script: `nano ~/.local/bin/maestro`
Set the script path to run relative to your location, whereever in the terminal:

```bash
#!/bin/bash
export PYTHONPATH="/Users/REPLACEwUser/Desktop/work/maestro:$PYTHONPATH"
python3 -m maestro.cli.maestro "$@"
```

Make sure the script is executable: `chmod +x ~/.local/bin/maestro`
Verify maestro is running properly: `maestro --help`

###### SlackBot support

Please set `SLACK_BOT_TOKEN` and `SLACK_TEAM_ID` as environment variables. See `./tests/yamls/agents/slack_agent.yaml` and `./tests/yamls/workflow_agent.yaml` for details. The output of slack message will be whatever is passed into the prompt.

###### Evaluation/Metrics Support

The Metrics Agent integrates Opik's LLM as a judge metrics into our workflows. Automatically route `spec.model` in the agent definition and add to workflow to automatically evaluate using `AnswerRelevance` and `Hallucination` scores. Can also additionally add `context` if the user knows the correct response or format a response should take.

See `./tests/yamls/agents/metrics_agent.py` and `./tests/yamls/workflows/metrics_agents.py` for more details.

There are 2 required exports as we use ollama for backend:
```bash
OPENAI_API_BASE=http://localhost:11434/v1
OPENAI_API_KEY=ollama
```

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

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the Apache License - see the [LICENSE](LICENSE) file for details.

## Related Links

- [Main Maestro Repository](https://github.com/AI4quantum/maestro)
- [Maestro Documentation](https://github.com/AI4quantum/maestro)
- [Original Demos Directory](https://github.com/AI4quantum/maestro/tree/main/demos)
