BASH_SCRIPTS := $(shell git grep --name-only '^.!/usr/bin/env bash$$' -- ':!./test')
BASH_SCRIPTS_ALL := $(shell git grep --name-only '^.!/usr/bin/env bash$$')

check-bash:
	# Fail if any shellcheck warnings
	@shellcheck --source-path "$(dir $(realpath $(firstword $(MAKEFILE_LIST))))dotfiles" $(BASH_SCRIPTS)

format-bash:
	@shfmt -s -i 2 -ci -l $(BASH_SCRIPTS_ALL)
	@shfmt -s -i 2 -ci -w $(BASH_SCRIPTS_ALL)

lint-bash:
	# Fail if any bash scripts not formatted properly using shfmt
	@shfmt -s -i 2 -ci -l $(BASH_SCRIPTS_ALL)
	@shfmt -s -i 2 -ci -d $(BASH_SCRIPTS_ALL)

lint: lint-bash check-bash

test-bash:
	@test/run_tests

ci: lint test-bash
