#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${CURRENT_DIR}/scripts/utils.sh"

main() {
  local -r opt_key="$(get_tmux_option "@pass-key" "b")"
  local -r opt_size="$(get_tmux_option "@pass-window-size" "10")"

  tmux bind-key "$opt_key" \
    run "tmux split-window -l $opt_size \"$CURRENT_DIR/scripts/main.sh '#{pane_id}'\""
}

main "$@"
