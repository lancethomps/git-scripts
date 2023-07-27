#!/usr/bin/env bash
################################################################### SETUP ########################################################################
shopt -s expand_aliases
set -o errexit -o errtrace -o nounset
##################################################################################################################################################
# shellcheck source=./.common_copy.sh
source "${_SCRIPT_DIR}/.common_copy.sh"
# shellcheck source=./.git_ci_types.sh
source "${_SCRIPT_DIR}/.git_ci_types.sh"

export GIT_URL_REGEX='(?i)^(?:(https|ssh|git\+ssh):\/\/)?([^@\/]+@)?([^\/:]+)(:[0-9]+)?(?:\/|:)(scm\/)?([^\/]+)\/([^\/]+?)(?:\.git)?(#[^\n]*)?$'

function use_git_pager_if_set() {
  local gitpager
  if gitpager="$(git config core.pager)"; then
    export PAGER="$gitpager"
  fi
  return 0
}

function set_git_branch_target_if_missing() {
  if test -z "${GIT_BRANCH_TARGET-}"; then
    GIT_BRANCH_TARGET="$(git default-branch)"
    export GIT_BRANCH_TARGET
  fi
  return 0
}

function urlencode_git_current_branch() {
  local current_branch
  if test -n "${1-}"; then
    current_branch="$1"
  else
    current_branch="$(git current-branch)"
  fi
  url_encode_py "${current_branch}" "/"
}

function git_branch_skip_regex() {
  if test -z "${GIT_BRANCH_SKIP_REGEX-}"; then
    export GIT_BRANCH_SKIP_REGEX='[[:space:]]((origin/)?(master|main|mature|HEAD|develop)$|origin/pr/)'
  fi
  echo "$GIT_BRANCH_SKIP_REGEX"
}

function git_branch_ref_format() {
  local format ref_format="" ref_formats=(
    '%(align:50)%(committerdate:format:%Y-%m-%d %H:%M:%S) (%(color:green)%(committerdate:relative)%(color:reset))%(end)'
    '%(color:red)%(objectname:short)%(color:reset)'
    '%(align:40)%(color:blue)%(authorname)%(color:reset)%(end)'
    '%(refname:short)'
    "$@"
  )

  for format in "${ref_formats[@]}"; do
    if test -n "${ref_format-}"; then
      ref_format="${ref_format}%09"
    fi
    ref_format="${ref_format}${format}"
  done

  echo "$ref_format"
}

function git_branch_ref_format_full() {
  git_branch_ref_format '%(contents:subject)'
}
