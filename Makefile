BASH_SCRIPTS := $(shell git grep --name-only '^.!/usr/bin/env bash$$' -- ':!./test')
BASH_SCRIPTS_ALL := $(shell git grep --name-only '^.!/usr/bin/env bash$$')

check-format:
	# Fail if any bash scripts not formatted properly using shfmt
	@shfmt -s -i 2 -ci -l $(BASH_SCRIPTS_ALL)
	@shfmt -s -i 2 -ci -d $(BASH_SCRIPTS_ALL)

check-scripts:
	# Fail if any shellcheck warnings
	@shellcheck --source-path "$(dir $(realpath $(firstword $(MAKEFILE_LIST))))dotfiles" $(BASH_SCRIPTS)

lint: check-format check-scripts

format-scripts:
	@shfmt -s -i 2 -ci -l $(BASH_SCRIPTS_ALL)
	@shfmt -s -i 2 -ci -w $(BASH_SCRIPTS_ALL)

test-scripts:
	@test/run_tests

ci: lint test-scripts
