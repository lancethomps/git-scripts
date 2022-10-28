#!/usr/bin/env bash
export CI_GITHUB=github
export CI_JENKINS=jenkins
export CI_NONE=none
export CI_TRAVIS=travis

function check_supported_ci_types() {
  if ! command -v is_arg_present >/dev/null 2>&1; then
    # shellcheck source=./.common_copy.sh
    source "${_SCRIPT_DIR}/.common_copy.sh" || exit 1
  fi

  if ! is_arg_present "$(git ci-type)" "$@"; then
    echo "FATAL: CI type not supported. git-ci-type: $(git ci-type) supported: $*"
    exit 1
  fi

  return 0
}
