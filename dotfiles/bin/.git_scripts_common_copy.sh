#!/usr/bin/env bash
################################################################### SETUP ########################################################################
shopt -s expand_aliases
set -o errexit -o errtrace -o nounset
##################################################################################################################################################

function check_command() {
  if command -v $1 > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

if check_command gsed; then
  alias sed_ext_in_place='gsed -i -r'
  alias sed_ext='gsed -r'
else
  alias sed_ext_in_place='/usr/bin/sed -i "" -E'
  alias sed_ext='/usr/bin/sed -E'
fi

function confirm() {
  local response=""
  read -r -p "${1:-Are you sure?}"$'\n'"[Y/n]> " response
  case "$response" in
    [yY][eE][sS] | [yY] | "") true ;;
    [nN][oO] | [nN]) false ;;
    *)
      echo_error "Incorrect value entered... Try again."
      confirm "$@"
      ;;
  esac
}
function confirm_with_auto() {
  if test "${auto_confirm:-}" = "true"; then
    echo "AUTO CONFIRMED: ${1:-}"
    return 0
  fi
  confirm "$@"
}
function check_debug() {
  check_true "${debug_mode:-}"
}
function check_not_debug() {
  check_true "${debug_mode:-}" && return 1 || return 0
}
function check_true() {
  if test -z "${1:-}"; then
    return 1
  fi
  local val="${1,,}"
  test "$val" = "true" && return 0 || test "$val" = "1" && return 0 || test "$val" = "yes" && return 0 || test "$val" = "y" && return 0 || return 1
}
function check_not_true() {
  if check_true "$@"; then
    return 1
  else
    return 0
  fi
}
function check_false() {
  if test -z "$1"; then
    return 1
  fi
  local val="${1,,}"
  test "$val" = "false" && return 0 || test "$val" = "0" && return 0 || test "$val" = "no" && return 0 || test "$val" = "n" && return 0 || return 1
}
function check_not_false() {
  if check_false "$@"; then
    return 1
  else
    return 0
  fi
}
