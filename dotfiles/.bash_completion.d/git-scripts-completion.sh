#!/usr/bin/env bash

function __complete_install_git_hook() {
  local COMPREPLY_ADD
  COMPREPLY=()

  if command -v _allopt >/dev/null 2>&1; then
    COMPLETE_NO_FILEDIR=true _allopt "$@"
  fi

  mapfile -t COMPREPLY_ADD < <(compgen -W "$(command "$1" --list)" -- "${COMP_WORDS[COMP_CWORD]}")
  COMPREPLY+=("${COMPREPLY_ADD[@]}")
}
complete -o bashdefault -o default -F __complete_install_git_hook install_git_hook uninstall_git_hook
