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

##################################################################################################################################################
################################################################### WRAPPED GIT COMPLETION #######################################################
##################################################################################################################################################
# shellcheck disable=SC2016
_ALLOPT_COMPLETION_CMD='compopt +o nospace; local _git_cmd_args=("${words[0]}-${words[1]}" "${words[@]:2}"); _allopt "${_git_cmd_args[@]}"; '
_ALLOPT_ALSO_COMMANDS=(
  grep-fzf
  pr
)

function maybe_include_allopt() {
  if is_arg_present "$1" "${_ALLOPT_ALSO_COMMANDS[@]}"; then
    echo "$_ALLOPT_COMPLETION_CMD"
  fi
  return 0
}

function _create_wrapped_git_completion_allopt_only() {
  local val

  for val in "$@"; do
    eval "_git_${val//-/_}() { ${_ALLOPT_COMPLETION_CMD} }"
  done
}

function _create_wrapped_git_completion() {
  local git_cmd_type="$1" val
  shift

  for val in "$@"; do
    eval "_git_${val//-/_}() { _git_${git_cmd_type//-/_} \"\$@\"; $(maybe_include_allopt "$val") }"
  done
}

_create_wrapped_git_completion_allopt_only \
  gh-release-tag

_create_wrapped_git_completion branch \
  del-branch \
  diff-to-branch \
  diff-to-branch-files \
  diff-to-branch-fzf \
  merge-branch-fzf \
  pr

_create_wrapped_git_completion grep \
  grep-bash \
  grep-code \
  grep-fzf \
  grep-idea

_create_wrapped_git_completion ls-files \
  ignored \
  select-files

_create_wrapped_git_completion reset \
  undo-merge

##################################################################################################################################################
################################################################### _git_checkout override #######################################################
##################################################################################################################################################

# this overwrites _git_checkout from git-completion included with Homebrew git to include modified files on `git checkout`
_git_checkout() {
  __git_has_doubledash && return

  # shellcheck disable=SC2154,SC2086
  case "$cur" in
    --conflict=*)
      __gitcomp "diff3 merge" "" "${cur##--conflict=}"
      ;;
    --*)
      __gitcomp_builtin checkout
      ;;
    *)
      # check if --track, --no-track, or --no-guess was specified
      # if so, disable DWIM mode
      local flags="--track --no-track --no-guess" track_opt="--track"
      if [ "$GIT_COMPLETION_CHECKOUT_NO_GUESS" = "1" ] ||
        [ -n "$(__git_find_on_cmdline "$flags")" ]; then
        track_opt=''
      fi
      __git_complete_refs $track_opt
      ################################################################### CUSTOM ###########################################################################
      __gitcomp_nl_append "$(__git ls-files --modified)" "$pfx" "$cur"
      # __gitcomp_nl_append "$(compgen -W "$(__git ls-files --modified)" -- "$cur")" "$pfx" "$cur"
      ######################################################################################################################################################
      ;;
  esac
}

unset _ALLOPT_COMPLETION_CMD _ALLOPT_ALSO_COMMANDS maybe_include_allopt _create_wrapped_git_completion_allopt_only _create_wrapped_git_completion
