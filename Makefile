.PHONY: help setup venv lint test check run version clean install-autostart uninstall-autostart

VENV     := .venv
PY       := $(VENV)/bin/python
PIP      := $(VENV)/bin/pip
AUTOSTART := $(HOME)/.config/autostart/metapeek.desktop
SCRIPT   := $(abspath metapeek.py)

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN{FS=":.*?## "}{printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install runtime deps + add user to 'input' group (Arch; needs sudo)
	./setup.sh

venv: ## Create a dev virtualenv with pytest + ruff
	python3 -m venv $(VENV)
	$(PIP) install -q -e ".[dev]"

lint: venv ## Run ruff (lint + import sort)
	$(VENV)/bin/ruff check .

test: venv ## Run the unit test suite
	$(VENV)/bin/pytest -q

check: lint test ## What CI runs: lint + tests

run: ## Launch the overlay (needs system GTK libs + 'input' group)
	python3 metapeek.py

version: ## Print the version
	python3 metapeek.py --version

install-autostart: ## Start MetaPeek automatically on login (XDG autostart)
	@mkdir -p $(dir $(AUTOSTART))
	@printf '%s\n' \
	  '[Desktop Entry]' \
	  'Type=Application' \
	  'Name=MetaPeek' \
	  'Comment=Hold Meta to peek at pinned taskbar shortcuts' \
	  'Exec=python3 $(SCRIPT)' \
	  'X-KDE-autostart-phase=2' \
	  'Terminal=false' > $(AUTOSTART)
	@echo "Installed autostart entry: $(AUTOSTART)"
	@echo "  Exec=python3 $(SCRIPT)"

uninstall-autostart: ## Remove the login autostart entry
	@rm -f $(AUTOSTART) && echo "Removed $(AUTOSTART)"

clean: ## Remove the dev virtualenv and caches
	rm -rf $(VENV) .pytest_cache .ruff_cache __pycache__ tests/__pycache__
