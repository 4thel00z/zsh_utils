#! /usr/bin/env zsh
# shellcheck disable=SC2155
# Disabled "Declare and assign separately to avoid masking return values": https://github.com/koalaman/shellcheck/wiki/SC2155

# ANSI escape codes
# https://en.wikipedia.org/wiki/ANSI_escape_code
# https://no-color.org
# https://bixense.com/clicolors

USE_COLOR="true"
if [[ -n "${CLICOLOR_FORCE+defined}" && "${CLICOLOR_FORCE}" != "0" ]]; then
  USE_COLOR="true"
elif [[ -n "${NO_COLOR+defined}" || "${CLICOLOR}" = "0" || ! -t 1 ]]; then
  USE_COLOR="false"
fi
readonly USE_COLOR
# Select Graphic Rendition codes
if [[ "${USE_COLOR}" = "true" ]]; then
  # KISS and use codes rather than tput, avoid dealing with missing tput or TERM.
  readonly SGR_RESET="\033[0m"
  readonly SGR_FAINT="\033[2m"
  readonly SGR_RED="\033[31m"
  readonly SGR_CYAN="\033[36m"
else
  readonly SGR_RESET=
  readonly SGR_FAINT=
  readonly SGR_RED=
  readonly SGR_CYAN=
fi

#
# log <type> <msg>
#

log() {
  printf "  ${SGR_CYAN}%10s${SGR_RESET} : ${SGR_FAINT}%s${SGR_RESET}\n" "$1" "$2"
}

#
# verbose_log <type> <msg>
# Can suppress with --quiet.
# Like log but to stderr rather than stdout, so can also be used from "display" routines.
#

verbose_log() {
  if [[ "${SHOW_VERBOSE_LOG}" == "true" ]]; then
    >&2 printf "  ${SGR_CYAN}%10s${SGR_RESET} : ${SGR_FAINT}%s${SGR_RESET}\n" "$1" "$2"
  fi
}

#
# Exit with the given <msg ...>
#

abort() {
  >&2 printf "\n  ${SGR_RED}Error: %s${SGR_RESET}\n\n" "$*" && exit 1
}

#
# Synopsis: trace message ...
# Debugging output to stderr, not used in production code.
#

function trace() {
  >&2 printf "trace: %s\n" "$*"
}

#
# Synopsis: echo_red message ...
# Highlight message in colour (on stdout).
#

function echo_red() {
  printf "${SGR_RED}%s${SGR_RESET}\n" "$*"
}

#
# Synopsis: std_grep <args...>
# grep wrapper to ensure consistent grep options and circumvent aliases.
#

function std_grep() {
  GREP_OPTIONS='' command grep "$@"
}


#
# Functions used when showing versions installed
#

enter_fullscreen() {
  # Set cursor to be invisible
  tput civis 2> /dev/null
  # Save screen contents
  tput smcup 2> /dev/null
  stty -echo
}

leave_fullscreen() {
  # Set cursor to normal
  tput cnorm 2> /dev/null
  # Restore screen contentsq
  tput rmcup 2> /dev/null
  stty echo
}

handle_sigint() {
  leave_fullscreen
  S="$?"
  kill 0
  exit $S
}

handle_sigtstp() {
  leave_fullscreen
  kill -s SIGSTOP $$
}
