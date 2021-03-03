#!/usr/bin/env bash
################################################################### SETUP ########################################################################
shopt -s expand_aliases
set -o errexit -o errtrace -o nounset
##################################################################################################################################################

function check_command() {
  if command -v "$@" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

if check_command gsed; then
  export _sed_ext_in_place='gsed -i -r'
  export _sed_ext='gsed -r'
else
  export _sed_ext_in_place='/usr/bin/sed -i "" -E'
  export _sed_ext='/usr/bin/sed -E'
fi
# shellcheck disable=SC2139
alias sed_ext_in_place="${_sed_ext_in_place}"
# shellcheck disable=SC2139
alias sed_ext="${_sed_ext}"

if ! check_command realpath; then
  if check_command grealpath; then
    function shell_realpath() { grealpath "$@"; }
  elif check_command greadlink; then
    function shell_realpath() { greadlink -f "$@"; }
  else
    function shell_realpath() { echo "$@"; }
  fi
else
  function shell_realpath() { realpath "$@"; }
fi

function confirm() {
  local response=""
  read -r -p "${1:-Are you sure?}"$'\n'"[Y/n]> " response
  case "$response" in
    [yY][eE][sS] | [yY] | "") true ;;
    [nN][oO] | [nN]) false ;;
    *)
      log_error "Incorrect value entered... Try again."
      confirm "$@"
      ;;
  esac
}
function is_auto_confirm() {
  check_true "${auto_confirm-}"
}
function confirm_with_auto() {
  if is_auto_confirm; then
    echo "AUTO CONFIRMED: ${1:-}"
    return 0
  fi
  confirm "$@"
}

function log_verbose() {
  if check_verbose; then
    echo "$@"
  fi
  return 0
}
function check_verbose() {
  check_true "${verbose:-}"
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
function repeat_char() {
  head -c "$2" </dev/zero | tr '\0' "$1"
}
function get_sep_cols() {
  local sep_cols=160 term_cols
  if check_command 'get_terminal_columns'; then
    term_cols="$(get_terminal_columns)"
    if test -n "$term_cols"; then
      sep_cols="$term_cols"
    fi
  fi
  if test -n "${1-}"; then
    sep_cols="$((sep_cols / $1))"
  fi
  echo -n "$sep_cols"
}
function get_terminal_sep() {
  if test -z "${TERMINAL_SEP:-}"; then
    local rep_count
    rep_count=$(get_sep_cols 2)
    TERMINAL_SEP="$(repeat_char '-' "$rep_count")"
    export TERMINAL_SEP
  fi
  return 0
}
function echo_sep() {
  get_terminal_sep
  echo "$TERMINAL_SEP"
}
function echo_with_sep() {
  echo_sep
  echo "$@"
  echo_sep
}
function echo_with_title_sep() {
  echo
  echo_with_title_sep_no_leading_blank_line "$@"
}
function echo_with_title_sep_no_leading_blank_line() {
  echo "$@"
  echo_sep
}
function exit_fatal() {
  local exit_code="${1-}"
  if test "$#" -le 1; then
    exit_code=1
  else
    shift
  fi
  echo "[FATAL] $*"
  exit "$exit_code"
}
function return_fatal() {
  local exit_code="${1-}"
  if test "$#" -le 1; then
    exit_code=1
  else
    shift
  fi
  echo "[FATAL] $*"
  return "$exit_code"
}

#dotfiles=opts
# shellcheck disable=SC2120
function should_use_pager() {
  if test -n "${use_pager:-}"; then
    if check_true "$use_pager"; then
      return 0
    else
      return 1
    fi
  fi
  if test "${1:-}" = '--no-pager'; then
    return 1
  elif test "${1:-}" = '--pager'; then
    return 0
  elif test -z "${PAGER:-}"; then
    return 1
  elif ! test -t 1; then
    return 1
  fi
  return 0
}
function get_args_quoted() {
  if test -z "${1:-}"; then
    return 1
  fi
  local var
  local all_args=''
  for var in "$@"; do
    if [[ $var =~ ^[\-_=/~a-zA-Z0-9]+$ ]] || [[ $var =~ ^[a-zA-Z0-9_]+= ]]; then
      if [ -z "$all_args" ]; then
        all_args="$var"
      else
        all_args="$all_args $var"
      fi
    else
      var="${var//\\/\\\\}"
      var="${var//\"/\\\"}"
      if test -n "${ESCAPE_VALS-}"; then
        var="$(echo "$var" | sed -E "s/([$ESCAPE_VALS])/\\\\\1/g")"
      fi
      if [ -z "$all_args" ]; then
        all_args="\"$var\""
      else
        all_args="$all_args \"$var\""
      fi
    fi
  done
  echo "$all_args"
}
function ask_user_for_input() {
  local response allow_empty
  allow_empty="${2:-false}"
  read -r -p "${1:-Please input a value.}"$'\n'"> " response
  if test -z "$response" && ! check_true "$allow_empty"; then
    echo "No value entered, please try again."
    ask_user_for_input "$@"
    return $?
  fi
  echo "$response"
}

#dotfiles=os
function get_terminal_columns() {
  if [ -z "${COLUMNS-}" ]; then
    COLUMNS="$(stty -a | head -1 | command grep -ioE 'columns [0-9]+' | sed -E 's/[^0-9]//g')"
    if [ -z "$COLUMNS" ]; then
      COLUMNS="$(stty -a | head -1 | command grep -ioE '[0-9]+ columns' | sed -E 's/[^0-9]//g')"
    fi
    export COLUMNS
  fi
  echo -n "$COLUMNS"
}

#dotfiles=string
function longest_line_length() {
  local str
  if ! test -t 0; then
    str="$(cat)"
  else
    for val in "${@}"; do
      str="${str:-}${val}"$'\n'
    done
  fi
  echo "${str-}" | awk 'length > max_length { max_length = length; longest_line = $0 } END { print max_length }'
}
function join_by_newline() {
  join_by $'\n' "$@"
}
function join_by() {
  local d=$1
  shift
  echo -n "$1"
  shift
  printf "%s" "${@/#/$d}"
}
