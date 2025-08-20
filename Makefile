.PHONY: install test lint type-check clean rename

# Directory for the virtual environment
VENV ?= .venv

# Default rule
all: install

# Create the virtual environment and install project (including dev deps)
install: $(VENV)

$(VENV): pyproject.toml
	uv venv $(VENV)
	. $(VENV)/bin/activate && uv pip install -e ".[dev]"
	touch $(VENV)

# Run the test suite using pytest
# (pytest must be in the dev dependencies of pyproject.toml)
test: install
	$(VENV)/bin/pytest -q

# Lint: format code, run lint checks, and perform type checking in one go
lint: install
	$(VENV)/bin/ruff format .
	$(VENV)/bin/shfmt -i 4 -w $(shell find . -name '*.sh')
	$(VENV)/bin/toml-sort -i pyproject.toml
	$(VENV)/bin/ruff check .
	$(VENV)/bin/ty check .

# Stand-alone type checking target (optional)
type-check: install
	$(VENV)/bin/ty check .

# Remove the virtual environment and other caches
clean:
	rm -rf $(VENV) **/__pycache__

# ------------------------------------------------------------------------------
# Project scaffolding helpers
# ------------------------------------------------------------------------------

# Usage: make rename NEW=my_cool_lib
# Replaces occurrences of the default package name (python_base) in pyproject and
# source tree and moves the package directory. Run once immediately after
# cloning the template.
rename:
	@if [ -z "$(NEW)" ]; then \
		echo "ERROR: provide a new package name, e.g. 'make rename NEW=my_lib'"; \
		exit 1; \
	fi
	@echo "Renaming python_base -> $(NEW)"
	@grep -RIl 'python_base' pyproject.toml src | xargs sed -i "s/python_base/$(NEW)/g"
	@mv src/python_base src/$(NEW)
	@echo "Rename complete. Remember to run 'make clean install' to rebuild the venv."
