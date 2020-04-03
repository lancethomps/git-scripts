#!/usr/bin/env bash
################################################################### SETUP ########################################################################
set -o errexit -o errtrace -o nounset
##################################################################################################################################################

BREW_FORMULAS=(
  coreutils
  fzf
  gawk
  gnu-sed
  jq
  pcre
)

echo "Installing required Homebrew formulas..."
brew install "${BREW_FORMULAS[@]}"

echo "To finish setup, add the dotfiles/bin directory to your PATH. You will most likely want to put that in your .bash_profile, eg 'export PATH=\"\${PATH}:<path_to_repo>/dotfiles/bin\"'"
