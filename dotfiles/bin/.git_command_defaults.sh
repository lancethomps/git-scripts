#!/usr/bin/env bash
################################################################### SETUP ########################################################################
if test -n "${DOTFILES-}" || ! test -d "${DOTFILES-}"; then DOTFILES="${HOME}/.dotfiles"; fi
# shellcheck source=.dotfiles/lib/common.sh disable=SC2016
if test -e "${DOTFILES}/lib/common.sh"; then source "${DOTFILES}/lib/common.sh"; else echo '"${DOTFILES}/lib/common.sh" does not exist - resolved to: '"${DOTFILES}/lib/common.sh" && exit 1; fi
set -o errexit -o errtrace
##################################################################################################################################################

function export_if_missing() {
  if test -z "${1:-}"; then
    local val="${3//\"/\\\"}"
    eval "export $2=\"${val}\""
    return $?
  fi
  return 0
}

function use_git_pager_if_set() {
  local gitpager
  if gitpager="$(git config core.pager)"; then
    export PAGER="$gitpager"
  fi
  return 0
}

export_if_missing "${GIT_BRANCH_SKIP_REGEX:-}" GIT_BRANCH_SKIP_REGEX '[[:space:]]((origin/)?(master|mature|HEAD|develop)$|origin/pr/)'
export_if_missing "${GIT_BRANCH_TARGET:-}" GIT_BRANCH_TARGET 'master'

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

GIT_TAG_REF_FORMAT="$(echo "$GIT_BRANCH_REF_FORMAT" | sed_ext -E 's/%\((authorname|committerdate|objectname)/%\(*\1/g')"
unset GIT_BRANCH_REF_FORMATS
export GIT_BRANCH_REF_FORMAT
export GIT_TAG_REF_FORMAT

export GIT_BRANCH_SKIP_SIZE_DEFAULT=10
export GIT_URL_REGEX='(?i)^(?:(https|ssh):\/\/)?([^@]+@)?([^\/:]+)(:[0-9]+)?(?:\/|:)(scm\/)?([^\/]+)\/([^\/]+)\.git$'
