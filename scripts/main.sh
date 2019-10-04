#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${CURRENT_DIR}/utils.sh"

OPT_COPY_TO_CLIPBOARD="$(get_tmux_option "@pass-copy-to-clipboard" "off")"
OPT_HIDE_PREVIEW="$(get_tmux_option "@pass-hide-preview" "off")"
OPT_HIDE_PW_FROM_PREVIEW="$(get_tmux_option "@pass-hide-pw-from-preview" "off")"
spinner_pid=""

# ------------------------------------------------------------------------------

# Taken from:
# https://github.com/yardnsm/dotfiles/blob/master/_setup/utils/spinner.sh
show_spinner() {

  local -r MSG="$1"

  local -r FRAMES="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  local -r DELAY=0.05

  local i=0
  local current_symbol

  trap 'exit 0' SIGTERM

  while true; do
    current_symbol="${FRAMES:i++%${#FRAMES}:1}"
    printf "\\e[0;34m%s\\e[0m  %s" "$current_symbol" "$MSG"
    printf "\\r"
    sleep $DELAY
  done

  return $?
}

spinner_start() {
  tput civis
  show_spinner "$1" &
  spinner_pid=$!
}

spinner_stop() {
  tput cnorm
  kill "$spinner_pid" &> /dev/null
  spinner_pid=""
}

# ------------------------------------------------------------------------------

get_items() {
  pushd "${PASSWORD_STORE_DIR:-$HOME/.password-store}" 1>/dev/null || exit 2
  find . -type f -name '*.gpg' | sed 's/\.gpg//' | sed 's/^\.\///' | sort
  popd 1>/dev/null || exit 2
}

get_password() {
  pass show "${1}" | head -n1
}

get_login() {
  local keys="user login username"
  local match

  for candidate in $keys; do
    match=$(pass show "${1}" | grep -i "$candidate" | cut -d ':' -f 2 | xargs)

    if [[ ! -z $match ]]; then break; fi
  done

  echo "$match"
}

# ------------------------------------------------------------------------------

main() {
  local -r ACTIVE_PANE="$1"

  local items
  local sel
  local passwd
  local login
  local header='enter=paste, alt-enter=user, ctrl-e=edit, ctrl-d=delete, tab=preview'
  local preview_hidden
  local preview_cmd

  if [[ "x$OPT_HIDE_PREVIEW" == "xon" ]]; then
    preview_hidden='--preview-window=hidden'
  fi

  if [[ "x$OPT_HIDE_PW_FROM_PREVIEW" == "xon" ]]; then
    preview_cmd='pass show {} | tail -n+2'
  else
    preview_cmd='pass show {}'
  fi

  spinner_start "Fetching items"
  items="$(get_items)"
  spinner_stop

  sel="$(echo "$items" | \
    fzf \
      --inline-info --no-multi \
      --tiebreak=begin \
      --preview="$preview_cmd" \
      $preview_hidden \
      --bind=tab:toggle-preview \
      --header="$header" \
      --bind=alt-enter:accept \
      --expect=enter,ctrl-e,ctrl-d,ctrl-c,esc,alt-enter)"

  if [ $? -gt 0 ]; then
    echo "error: unable to complete command - check/report errors above"
    echo "You can also set the fzf path in options (see readme)."
    read -r
    exit
  fi

  key=$(head -1 <<< "$sel")
  text=$(tail -n +2 <<< "$sel")

  case $key in

    enter)
      spinner_start "Fetching password"
      passwd="$(get_password "$text")"
      spinner_stop

      if [[ "$OPT_COPY_TO_CLIPBOARD" == "on" ]]; then
        copy_to_clipboard "$passwd"
        clear_clipboard 30
      else
        tmux send-keys -t "$ACTIVE_PANE" "$passwd"
      fi
      ;;

    alt-enter)
      spinner_start "Fetching username"
      login="$(get_login "$text")"
      spinner_stop

      if [[ "$OPT_COPY_TO_CLIPBOARD" == "on" ]]; then
        copy_to_clipboard "$login"
      else
        tmux send-keys -t "$ACTIVE_PANE" "$login"
      fi
      ;;

    ctrl-e)
      pass edit "$text"
      ;;

    ctrl-d)
      pass rm "$text"
      ;;

  esac
}

main "$@"
