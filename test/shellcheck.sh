#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
  || exit 1

# ------------------------------------------------------------------------------

shellcheck \
  -e SC2181 \
  -e SC1091 \
  ../**/*.sh ../*.tmux
