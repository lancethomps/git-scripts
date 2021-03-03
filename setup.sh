#!/usr/bin/env bash
################################################################### SETUP ########################################################################
S="$1"
while [ -h "$S" ]; do
  D="$(cd -P "$(dirname "$S")" && pwd)" && S="$(readlink "$S")" && [[ $S != /* ]] && S="$D/$S"
done
_SCRIPT_DIR="$(cd -P "$(dirname "$S")" && pwd)"
set -o errexit -o errtrace -o nounset
##################################################################################################################################################

BREW_FORMULAS=(
  coreutils
  fzf
  gawk
  gnu-sed
  pcre
)

if ! command -v jq >/dev/null 2>&1; then
  BREW_FORMULAS+=(jq)
fi

echo "Installing required Homebrew formulas..."
brew install "${BREW_FORMULAS[@]}"

echo "To finish setup, add the dotfiles/bin directory to your PATH. You will most likely want to put that in your .bash_profile."
echo "export PATH=\"\${PATH}:${_SCRIPT_DIR}/dotfiles/bin\""
