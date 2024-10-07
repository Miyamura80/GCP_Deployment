# ANSI color codes
GREEN=\033[0;32m
YELLOW=\033[0;33m
RED=\033[0;31m
BLUE=\033[0;34m
RESET=\033[0m

PYTHON=rye run python
TEST=rye run pytest
PROJECT_ROOT=.

########################################################
# Check dependencies
########################################################

check_rye:
	@echo "$(YELLOW)🔍Checking rye version...$(RESET)"
	@if ! command -v rye > /dev/null 2>&1; then \
		echo "$(RED)rye is not installed. Please install rye before proceeding.$(RESET)"; \
		exit 1; \
	else \
		rye --version; \
	fi

check_jq:
	@echo "$(YELLOW)🔍Checking jq version...$(RESET)"
	@if ! command -v jq > /dev/null 2>&1; then \
		echo "$(RED)jq is not installed. Please install jq before proceeding.$(RESET)"; \
		echo "$(RED)brew install jq$(RESET)"; \
		exit 1; \
	else \
		jq --version; \
	fi


########################################################
# Setup githooks for linting
########################################################
setup_githooks:
	@echo "$(YELLOW)🔨Setting up githooks on post-commit...$(RESET)"
	chmod +x .githooks/post-commit
	git config core.hooksPath .githooks

########################################################
# Python dependency-related
########################################################

update_python_dep: check_rye
	@echo "$(YELLOW)🔄Updating python dependencies...$(RESET)"
	@rye sync

view_python_venv_size:
	@echo "$(YELLOW)🔍Checking python venv size...$(RESET)"
	@PYTHON_VERSION=$$(cat .python-version | cut -d. -f1,2) && \
	cd .venv/lib/python$$PYTHON_VERSION/site-packages && du -sh . && cd ../../../
	@echo "$(GREEN)Python venv size check completed.$(RESET)"

view_python_venv_size_by_libraries:
	@echo "$(YELLOW)🔍Checking python venv size by libraries...$(RESET)"
	@PYTHON_VERSION=$$(cat .python-version | cut -d. -f1,2) && \
	cd .venv/lib/python$$PYTHON_VERSION/site-packages && du -sh * | sort -h && cd ../../../
	@echo "$(GREEN)Python venv size by libraries check completed.$(RESET)"

########################################################
# Run Main Application
########################################################

all: update_python_dep setup_githooks
	@echo "$(GREEN)🏁Running main application...$(RESET)"
	@$(PYTHON) server/server.py
	@echo "$(GREEN)✅ Main application run completed.$(RESET)"

########################################################
# Docker
########################################################

CONTAINER_NAME = my-server

build-container:
	docker build -t $(CONTAINER_NAME) .

run-container-local: build-container
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true
	docker run -d -p 5000:5000 --name $(CONTAINER_NAME) $(CONTAINER_NAME)

########################################################
# Terraform CDK Deployment
########################################################

PROJECT_ID = superb-memory-392811
DEPLOY_REGION = europe-west2
ARTIFACT_REGISTRY = $(DEPLOY_REGION)-docker.pkg.dev/$(PROJECT_ID)/$(CONTAINER_NAME)


full-deploy:
	docker system prune -af  # Clean up Docker resources before building
	docker volume prune -f
	docker buildx create --use --name multi-arch-builder || true
	docker buildx use multi-arch-builder
	docker buildx build --platform linux/amd64 \
		-t $(ARTIFACT_REGISTRY)/$(CONTAINER_NAME):latest \
		--push \
		.
	cd tf-cdk && cdktf deploy && cd ..

deploy:
	cd tf-cdk && cdktf deploy && cd ..

destroy:
	cd tf-cdk && cdktf destroy && cd ..


########################################################
# Linting
########################################################

# Linter will ignore these directories
IGNORE_LINT_DIRS = .venv|venv|tf-cdk/node_modules
LINE_LENGTH = 88

lint: check_rye check_jq
	@echo "$(YELLOW)✨Linting project with Black...$(RESET)"
	@rye run black --exclude '/($(IGNORE_LINT_DIRS))/' . --line-length $(LINE_LENGTH)
	@echo "$(YELLOW)✨Linting and formatting JSONs with jq...$(RESET)"
	@count=0; \
	find . \( $(IGNORE_LINT_DIRS:%=-path './%' -prune -o) \) -type f -name '*.json' -print0 | \
	while IFS= read -r -d '' file; do \
		if jq . "$$file" > "$$file.tmp" 2>/dev/null && mv "$$file.tmp" "$$file"; then \
			count=$$((count + 1)); \
		else \
			rm -f "$$file.tmp"; \
		fi; \
	done; \
	echo "$(BLUE)$$count JSON file(s)$(RESET) linted and formatted."; \
	echo "$(GREEN)✅Linting completed.$(RESET)"

