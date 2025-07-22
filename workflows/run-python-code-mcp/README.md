# MCP Walkthrough

This demo shows how to use a Maestro agent and connect to/use an MCP tool to execute Python code in a sandboxed environment using Pydantic's [MCP Run Python Server](https://github.com/pydantic/pydantic-ai/tree/main/mcp-run-python).


## Required Exports

```bash
MAESTRO_MCP_ENDPOINTS="deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto jsr:@pydantic/mcp-run-python stdio"
OPENAI_API_KEY=ollama
OPENAI_BASE_URL="http://localhost:11434/v1"
```

To download the MCP server locally, you will need to have [Deno](https://docs.deno.com/runtime/#install-deno) installed.
Currently, we are running `qwen3:8b` model by default, to change simply adjust in [`agents.yaml`](./agents.yaml).


### Running the Workflow

Edit the prompt in `workflow.yaml` to contain whatever code you want to run:

```yaml
spec:
  template:
    prompt: |
      Run the following code, which is within triple backticks (```):
      ```
      # enter the code you want to run here
      my_var = "hello world!"
      print(my_var)
      ```
    steps:
    - name: step1
```

> Note: the agent will return stdout / stderr, so you will need to use `print` to return output

To run:
`maestro run agents.yaml workflow.yaml`
