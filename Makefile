BASH_SCRIPTS := $(shell git grep --name-only '^.!/usr/bin/env bash$$')

check-format:
	shfmt -s -i 2 -ci -sr -d $(BASH_SCRIPTS)

check-scripts:
	# Fail if any of these files have warnings
	shellcheck --source-path "$(dir $(realpath $(firstword $(MAKEFILE_LIST))))dotfiles" $(BASH_SCRIPTS)

lint: check-format check-scripts

format-scripts:
	shfmt -s -i 2 -ci -sr -l $(BASH_SCRIPTS)
	shfmt -s -i 2 -ci -sr -w $(BASH_SCRIPTS)

ci: lint
