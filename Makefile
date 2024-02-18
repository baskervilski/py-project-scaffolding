# Makefile for a Python project

# Set the shell to bash in case some shell syntax is used.
SHELL := /bin/bash

# Define variables for directories
VENV_DIR := .venv
VENV_BIN := $(VENV_DIR)/bin
VENV_PIP := $(VENV_BIN)/pip
VENV_UV := $(VENV_BIN)/uv
SRC_DIR := src
TEST_DIR := tests
PY_VER = 3.8

# Default command when you run just `make`
all: install

# Setup a virtual environment
venv:
	python3 -m venv $(VENV_DIR)	
	@echo "Virtual environment created at $(VENV_DIR)"
	$(VENV_PIP) install --upgrade pip
	$(VENV_PIP) install uv pre-commit
	$(VENV_BIN)/pre-commit install

venv-sync:
	$(MAKE) requirements
	$(VENV_UV) pip install -r requirements.txt
	$(VENV_UV) pip install -e ".[dev]"
	@echo "Dependencies installed"

requirements:
	$(VENV_UV) pip compile pyproject.toml -o requirements.txt --python-version $(PY_VER)
	@echo "Requirements compiled"

# Run tests
test:
	# Run tests, but don't fail if there are none
	$(VENV_BIN)/pytest $(TEST_DIR)
	@echo "Tests completed"

# Run ruff linter
lint:
	$(VENV_BIN)/ruff $(SRC_DIR) --exit-zero
	@echo "Linting completed"

# Clean up pyc files and __pycache__ directories
clean:
	find . -type f -name "*.pyc" -exec rm -f {} +
	find . -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Cleanup completed"

# Remove the virtual environment
clean-venv:
	rm -rf $(VENV_DIR)
	@echo "Virtual environment removed"

# Command to clean all artifacts
clean-all: clean clean-venv
	@echo "All clean. Fresh start available."

# Make sure these commands are treated as targets, not files
.PHONY: all venv venv-sync requirements install test lint clean clean-venv clean-all
