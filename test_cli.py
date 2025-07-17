#!/usr/bin/env python3
"""
Simple test script to verify the maestro-demos CLI functionality.
"""

import subprocess
import sys
from pathlib import Path


def test_cli_help():
    """Test that the CLI help command works."""
    try:
        result = subprocess.run(
            ["maestro-demos", "--help"],
            capture_output=True,
            text=True,
            check=True
        )
        print("✅ CLI help command works")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ CLI help command failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return False


def test_create_agents_help():
    """Test that the create-agents help command works."""
    try:
        result = subprocess.run(
            ["maestro-demos", "create-agents", "--help"],
            capture_output=True,
            text=True,
            check=True
        )
        print("✅ create-agents help command works")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ create-agents help command failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return False


def test_create_workflow_help():
    """Test that the create-workflow help command works."""
    try:
        result = subprocess.run(
            ["maestro-demos", "create-workflow", "--help"],
            capture_output=True,
            text=True,
            check=True
        )
        print("✅ create-workflow help command works")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ create-workflow help command failed: {e}")
        print(f"stdout: {e.stdout}")
        print(f"stderr: {e.stderr}")
        return False


def test_workflow_files_exist():
    """Test that the workflow files are properly included in the package."""
    try:
        from maestro_demos.cli import get_workflow_paths
        agents_dir, workflow_dir = get_workflow_paths()
        
        agents_yaml = agents_dir / "agents.yaml"
        agents_workflow_yaml = agents_dir / "workflow.yaml"
        workflow_agents_yaml = workflow_dir / "agents.yaml"
        workflow_yaml = workflow_dir / "workflow.yaml"
        
        files_exist = all([
            agents_yaml.exists(),
            agents_workflow_yaml.exists(),
            workflow_agents_yaml.exists(),
            workflow_yaml.exists()
        ])
        
        if files_exist:
            print("✅ All workflow files found in package")
            return True
        else:
            print("❌ Some workflow files missing:")
            print(f"   agents.yaml: {agents_yaml.exists()}")
            print(f"   agents workflow.yaml: {agents_workflow_yaml.exists()}")
            print(f"   workflow agents.yaml: {workflow_agents_yaml.exists()}")
            print(f"   workflow.yaml: {workflow_yaml.exists()}")
            return False
            
    except Exception as e:
        print(f"❌ Error checking workflow files: {e}")
        return False


def test_absolute_paths():
    """Test that the CLI can resolve absolute paths to workflow files."""
    try:
        from maestro_demos.cli import get_workflow_paths
        agents_dir, workflow_dir = get_workflow_paths()
        
        agents_yaml = agents_dir / "agents.yaml"
        agents_workflow_yaml = agents_dir / "workflow.yaml"
        workflow_agents_yaml = workflow_dir / "agents.yaml"
        workflow_yaml = workflow_dir / "workflow.yaml"
        
        # Test that resolve() works and returns absolute paths
        absolute_paths = [
            agents_yaml.resolve(),
            agents_workflow_yaml.resolve(),
            workflow_agents_yaml.resolve(),
            workflow_yaml.resolve()
        ]
        
        all_absolute = all(path.is_absolute() for path in absolute_paths)
        
        if all_absolute:
            print("✅ All workflow files resolve to absolute paths")
            return True
        else:
            print("❌ Some workflow files do not resolve to absolute paths")
            return False
            
    except Exception as e:
        print(f"❌ Error testing absolute paths: {e}")
        return False


def main():
    """Run all tests."""
    print("🧪 Testing maestro-demos CLI...")
    print()
    
    tests = [
        test_cli_help,
        test_create_agents_help,
        test_create_workflow_help,
        test_workflow_files_exist,
        test_absolute_paths,
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        print()
    
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! The CLI tool is working correctly.")
        return 0
    else:
        print("❌ Some tests failed. Please check the output above.")
        return 1


if __name__ == "__main__":
    sys.exit(main()) 