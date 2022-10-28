#!/usr/bin/env bash
################################################################### SETUP ########################################################################
shopt -s expand_aliases
set -o errexit -o errtrace -o nounset
##################################################################################################################################################
# shellcheck source=./.common_copy.sh
source "${_SCRIPT_DIR}/.common_copy.sh"
# shellcheck source=./.git_ci_types.sh
source "${_SCRIPT_DIR}/.git_ci_types.sh"

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

if test -z "${GIT_BRANCH_SKIP_REGEX-}"; then
  export GIT_BRANCH_SKIP_REGEX='[[:space:]]((origin/)?(master|main|mature|HEAD|develop)$|origin/pr/)'
fi

GIT_BRANCH_REF_FORMATS=(
  '%(align:50)%(committerdate:format:%Y-%m-%d %H:%M:%S) (%(color:green)%(committerdate:relative)%(color:reset))%(end)'
  '%(color:red)%(objectname:short)%(color:reset)'
  '%(align:40)%(color:blue)%(authorname)%(color:reset)%(end)'
  '%(refname:short)'
)
GIT_BRANCH_REF_FORMATS_FULL=(
  "${GIT_BRANCH_REF_FORMATS[@]}"
  '%(contents:subject)'
)

GIT_BRANCH_REF_FORMAT=''
for format in "${GIT_BRANCH_REF_FORMATS[@]}"; do
  if test -n "${GIT_BRANCH_REF_FORMAT:-}"; then
    GIT_BRANCH_REF_FORMAT="${GIT_BRANCH_REF_FORMAT}%09"
  fi
  GIT_BRANCH_REF_FORMAT="${GIT_BRANCH_REF_FORMAT}${format}"
done

GIT_BRANCH_REF_FORMAT_FULL=''
for format in "${GIT_BRANCH_REF_FORMATS_FULL[@]}"; do
  if test -n "${GIT_BRANCH_REF_FORMAT_FULL:-}"; then
    GIT_BRANCH_REF_FORMAT_FULL="${GIT_BRANCH_REF_FORMAT_FULL}%09"
  fi
  GIT_BRANCH_REF_FORMAT_FULL="${GIT_BRANCH_REF_FORMAT_FULL}${format}"
done

GIT_TAG_REF_FORMAT="$GIT_BRANCH_REF_FORMAT"
unset GIT_BRANCH_REF_FORMATS GIT_BRANCH_REF_FORMATS_FULL format
export GIT_BRANCH_REF_FORMAT
export GIT_TAG_REF_FORMAT

export GIT_BRANCH_SKIP_SIZE_DEFAULT=10
export GIT_URL_REGEX='(?i)^(?:(https|ssh|git\+ssh):\/\/)?([^@\/]+@)?([^\/:]+)(:[0-9]+)?(?:\/|:)(scm\/)?([^\/]+)\/([^\/]+?)(?:\.git)?(#[^\n]*)?$'
