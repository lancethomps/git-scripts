#!/usr/bin/env bash
################################################################### SETUP ########################################################################
shopt -s expand_aliases
set -o errexit -o errtrace -o nounset
##################################################################################################################################################
# shellcheck source=bin/.git_scripts_common_copy.sh
source "$_SCRIPT_DIR/.git_scripts_common_copy.sh"

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

if test -z "${GIT_BRANCH_SKIP_REGEX-}"; then
  export GIT_BRANCH_SKIP_REGEX='[[:space:]]((origin/)?(master|main|mature|HEAD|develop)$|origin/pr/)'
fi

GIT_BRANCH_REF_FORMATS=(
  '%(align:50)%(committerdate:format:%Y-%m-%d %H:%M:%S) (%(color:green)%(committerdate:relative)%(color:reset))%(end)'
  '%(color:red)%(objectname:short)%(color:reset)'
  '%(align:30)%(color:blue)%(authorname)%(color:reset)%(end)'
  '%(refname:short)'
)
GIT_BRANCH_REF_FORMAT=''
for format in "${GIT_BRANCH_REF_FORMATS[@]}"; do
  if test -n "${GIT_BRANCH_REF_FORMAT:-}"; then
    GIT_BRANCH_REF_FORMAT="${GIT_BRANCH_REF_FORMAT}%09"
  fi
  GIT_BRANCH_REF_FORMAT="${GIT_BRANCH_REF_FORMAT}${format}"
done

GIT_TAG_REF_FORMAT="$(echo "$GIT_BRANCH_REF_FORMAT" | sed_ext 's/%\((authorname|committerdate|objectname)/%\(*\1/g')"
unset GIT_BRANCH_REF_FORMATS
export GIT_BRANCH_REF_FORMAT
export GIT_TAG_REF_FORMAT

export GIT_BRANCH_SKIP_SIZE_DEFAULT=10
export GIT_URL_REGEX='(?i)^(?:(https|ssh):\/\/)?([^@]+@)?([^\/:]+)(:[0-9]+)?(?:\/|:)(scm\/)?([^\/]+)\/([^\/]+)\.git$'
