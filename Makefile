# Makefile for Chainlit Docked Docs (CLDD) Development

# Find the latest available python from pyenv (excluding system/miniconda if possible)
PYTHON_VERSION := $(shell pyenv versions --bare | grep -v 'miniconda' | grep -v 'system' | sort -V | tail -n 1)
# Get absolute path to python executable
PYTHON_BIN := $(shell pyenv prefix $(PYTHON_VERSION))/bin/python

.PHONY: develop run clean

develop:
	@echo "🔍 Detecting Python... Found $(PYTHON_VERSION)"
	@if [ -z "$(PYTHON_VERSION)" ]; then echo "❌ No pyenv python found. Please install one (e.g. pyenv install 3.11)"; exit 1; fi
	
	@echo "🐍 Checking virtual environment..."
	@if [ ! -d ".venv" ]; then \
		echo "   Creating .venv with $(PYTHON_BIN)..."; \
		echo "$(PYTHON_VERSION)" > .python-version; \
		"$(PYTHON_BIN)" -m venv .venv; \
	else \
		echo "   Using existing .venv"; \
	fi
	
	@echo "📦 Installing Chainlit..."
	@.venv/bin/pip install --upgrade pip
	@.venv/bin/pip install chainlit
	
	@echo "📝 Generating dummy app_dev.py..."
	@echo "import chainlit as cl" > app_dev.py
	@echo "" >> app_dev.py
	@echo "@cl.on_message" >> app_dev.py
	@echo "async def main(message: cl.Message):" >> app_dev.py
	@echo "    await cl.Message(content='Hello World! CLDD Dev Mode active.').send()" >> app_dev.py
	
	@echo "⚙️  Generating chainlit config..."
	@rm -rf .chainlit
	@rm -f chainlit.md
	@.venv/bin/chainlit init > /dev/null 2>&1 || true
	
	@echo "🔧 Patching config.toml..."
	@.venv/bin/python -c "import os, re; \
	path = '.chainlit/config.toml'; \
	data = open(path).read(); \
	data = re.sub(r'#\s*custom_css\s*=\s*\".*\"', 'custom_css = \"/public/custom.css\"', data); \
	data = re.sub(r'#\s*custom_js\s*=\s*\".*\"', 'custom_js = \"/public/custom.js\"', data); \
	open(path, 'w').write(data);"
	
	@echo "✅ Development environment ready! Run 'make run' to start."

run:
	@if [ ! -d ".venv" ]; then echo "❌ .venv not found. Run 'make develop' first."; exit 1; fi
	@echo "🚀 Starting Chainlit..."
	@.venv/bin/chainlit run app_dev.py -w

clean:
	@echo "🧹 Cleaning up..."
	@rm -rf .venv
	@rm -f app_dev.py
	@rm -rf .chainlit
	@rm -f chainlit.md
	@rm -f .python-version
	@echo "✨ Cleaned."
