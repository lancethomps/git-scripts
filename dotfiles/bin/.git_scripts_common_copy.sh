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
function repeat_char() {
  head -c "$2" < /dev/zero | tr '\0' "$1"
}
function get_sep_cols() {
  local sep_cols=160
  if check_command 'get_terminal_columns'; then
    local term_cols="$(get_terminal_columns)"
    if [ ! -z "$term_cols" ]; then
      sep_cols="$term_cols"
    fi
  fi
  if [ ! -z "$1" ]; then
    sep_cols="$((sep_cols / $1))"
  fi
  echo -n "$sep_cols"
}
function get_terminal_sep() {
  if [ -z "${TERMINAL_SEP:-}" ]; then
    local rep_count=$(get_sep_cols 2)
    export TERMINAL_SEP="$(repeat_char '-' $rep_count)"
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

#dotfiles=opts
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
  if [ -z "${1:-}" ]; then
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
      if [ ! -z "${ESCAPE_VALS-}" ]; then
        var=$(echo "$var" | sed -E "s/([$ESCAPE_VALS])/\\\\\1/g")
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
  if [ -z "$COLUMNS" ]; then
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
  echo "$str" | awk 'length > max_length { max_length = length; longest_line = $0 } END { print max_length }'
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
