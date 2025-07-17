#!/usr/bin/env python3
"""
Maestro Demos CLI Tool

Provides commands to run meta-agents-v2 workflows for generating
agents.yaml and workflow.yaml files from any directory, by launching
maestro serve with the correct packaged workflow files.
"""

import sys
import subprocess
from pathlib import Path

import click


def get_package_root() -> Path:
    """Get the root directory of the maestro_demos package."""
    import maestro_demos
    return Path(maestro_demos.__file__).parent


def get_workflow_paths() -> tuple[Path, Path]:
    """Get the paths to the meta-agents-v2 workflow files."""
    package_root = get_package_root()
    
    agents_generation_dir = package_root / "workflows" / "meta-agents-v2" / "agents_file_generation"
    workflow_generation_dir = package_root / "workflows" / "meta-agents-v2" / "workflow_file_generation"
    
    return agents_generation_dir, workflow_generation_dir


def check_maestro_installed() -> bool:
    """Check if maestro CLI is available."""
    try:
        subprocess.run(["maestro", "--help"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def run_maestro_serve(agents_yaml: Path, workflow_yaml: Path) -> None:
    """Run maestro serve with the specified workflow files."""
    if not check_maestro_installed():
        click.echo("❌ Error: maestro CLI is not installed or not in PATH", err=True)
        click.echo("Please install maestro first: pip install git+https://github.com/AI4quantum/maestro.git@v0.2.0", err=True)
        sys.exit(1)
    
    click.echo(f"🚀 Starting maestro serve with:")
    click.echo(f"   Agents: {agents_yaml}")
    click.echo(f"   Workflow: {workflow_yaml}")
    click.echo()
    
    try:
        subprocess.run([
            "maestro", "serve",
            str(agents_yaml),
            str(workflow_yaml)
        ], check=True)
    except subprocess.CalledProcessError as e:
        click.echo(f"❌ Error running maestro serve: {e}", err=True)
        sys.exit(1)
    except KeyboardInterrupt:
        click.echo("\n👋 Stopped by user")
        sys.exit(0)


@click.group()
@click.version_option(version="0.1.0", prog_name="maestro-demos")
def main():
    """
    Maestro Demos CLI Tool
    
    Run meta-agents-v2 workflows for generating agents.yaml and workflow.yaml files
    from any directory. This tool simply launches maestro serve with the correct
    packaged workflow files, so you do not need to reference any paths manually.
    """
    pass


@main.command()
def create_agents():
    """
    Launch the meta-agents-v2 agents file generation workflow API.
    
    This command runs:
        maestro serve <packaged agents.yaml> <packaged workflow.yaml>
    for the agents_file_generation workflow.
    """
    agents_dir, _ = get_workflow_paths()
    agents_yaml = agents_dir / "agents.yaml"
    workflow_yaml = agents_dir / "workflow.yaml"
    
    if not agents_yaml.exists() or not workflow_yaml.exists():
        click.echo("❌ Error: Required workflow files not found in the package.", err=True)
        sys.exit(1)
    
    run_maestro_serve(agents_yaml.resolve(), workflow_yaml.resolve())


@main.command()
def create_workflow():
    """
    Launch the meta-agents-v2 workflow file generation workflow API.
    
    This command runs:
        maestro serve <packaged agents.yaml> <packaged workflow.yaml>
    for the workflow_file_generation workflow.
    """
    _, workflow_dir = get_workflow_paths()
    agents_yaml = workflow_dir / "agents.yaml"
    workflow_yaml = workflow_dir / "workflow.yaml"
    
    if not agents_yaml.exists() or not workflow_yaml.exists():
        click.echo("❌ Error: Required workflow files not found in the package.", err=True)
        sys.exit(1)
    
    run_maestro_serve(agents_yaml.resolve(), workflow_yaml.resolve())


if __name__ == '__main__':
    main() 