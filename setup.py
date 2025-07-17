from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="maestro-demos",
    version="0.1.0",
    author="Maestro Demos Team",
    author_email="team@maestro-demos.com",
    description="CLI tool for running Maestro meta-agents workflows",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/AI4quantum/maestro-demos",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.11",
    install_requires=[
        "maestro>=0.2.0",
        "click>=8.0.0",
        "pyyaml>=6.0",
    ],
    entry_points={
        "console_scripts": [
            "maestro-demos=maestro_demos.cli:main",
        ],
    },
    include_package_data=True,
    package_data={
        "maestro_demos": [
            "workflows/meta-agents-v2/agents_file_generation/*.yaml",
            "workflows/meta-agents-v2/workflow_file_generation/*.yaml",
        ],
    },
) 