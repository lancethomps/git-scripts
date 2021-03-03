BASH_SCRIPTS := $(shell git grep --name-only '^.!/usr/bin/env bash$$' -- ':!./test')

check-format:
	# Fail if any bash scripts not formatted properly using shfmt
	@shfmt -s -i 2 -ci -sr -d $(BASH_SCRIPTS)

check-scripts:
	# Fail if any shellcheck warnings
	@shellcheck --source-path "$(dir $(realpath $(firstword $(MAKEFILE_LIST))))dotfiles" $(BASH_SCRIPTS)

lint: check-format check-scripts

format-scripts:
	@shfmt -s -i 2 -ci -sr -l $(BASH_SCRIPTS)
	@shfmt -s -i 2 -ci -sr -w $(BASH_SCRIPTS)

test-scripts:
	@test/run_tests

ci: lint test-scripts
