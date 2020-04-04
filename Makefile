BASH_SCRIPTS := $(shell git grep --name-only '^.!/usr/bin/env bash$$')

check-scripts:
	# Fail if any of these files have warnings
	shellcheck --source-path "$(dir $(realpath $(firstword $(MAKEFILE_LIST))))dotfiles" $(BASH_SCRIPTS)

test: check-scripts
