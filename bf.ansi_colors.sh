#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines 6000
########################################################################
#scriptname     :ansi_colors
#description    :Define BASH local/GLOBAL variables to define colors
#args           :
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#NOTE           :attributions were split to live within 72 columns
#attribution01  :https://stackoverflow.com
#attribution02  :/questions
#attribution03  :/10466749/bash-colored-output-with-a-variable
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|08/05/2022| Initial Release
#_____________________________________________________________________

ansi_RESTORE='\033[0m'

ansi_RED='\033[00;31m'
ansi_GREEN='\033[00;32m'
ansi_YELLOW='\033[00;33m'
ansi_BLUE='\033[00;34m'
ansi_PURPLE='\033[00;35m'
ansi_CYAN='\033[00;36m'
ansi_LIGHTGRAY='\033[00;37m'

ansi_BRIGHT_RED='\033[00;91m'
ansi_BRIGHT_GREEN='\033[00;92m'
ansi_BRIGHT_YELLOW='\033[00;93m'
ansi_BRIGHT_BLUE='\033[00;94m'
ansi_BRIGHT_PURPLE='\033[00;95m'
ansi_BRIGHT_CYAN='\033[00;96m'
ansi_BRIGHT_LIGHTGRAY='\033[00;97m'

ansi_BG_BRIGHT_RED='\033[00;101m'
ansi_BG_BRIGHT_GREEN='\033[00;102m'
ansi_BG_BRIGHT_YELLOW='\033[00;103m'
ansi_BG_BRIGHT_BLUE='\033[00;104m'
ansi_BG_BRIGHT_PURPLE='\033[00;105m'
ansi_BG_BRIGHT_CYAN='\033[00;106m'
ansi_BG_BRIGHT_WHITE='\033[00;107m'

ansi_LRED='\033[01;31m'
ansi_LGREEN='\033[01;32m'
ansi_LYELLOW='\033[01;33m'
ansi_LBLUE='\033[01;34m'
ansi_LPURPLE='\033[01;35m'
ansi_LCYAN='\033[01;36m'
ansi_WHITE='\033[01;37m'

ansi_passstring="[${ansi_GREEN}PASS${ansi_RESTORE}]"
ansi_failstring="[${ansi_RED}${ansi_BG_BRIGHTWHITE}FAIL${ansi_RESTORE}]"
ansi_warnstring="[${ansi_BRIGHT_YELLOW}${ansi_BG_BRIGHTWHITE}WARN${ansi_RESTORE}]"
#
export ansi_RESTORE
export ansi_RED
export ansi_GREEN
export ansi_YELLOW
export ansi_BLUE
export ansi_PURPLE
export ansi_CYAN
export ansi_LIGHTGRAY
export ansi_BRIGHT_RED
export ansi_BRIGHT_GREEN
export ansi_BRIGHT_YELLOW
export ansi_BRIGHT_BLUE
export ansi_BRIGHT_PURPLE
export ansi_BRIGHT_CYAN
export ansi_BRIGHT_LIGHTGRAY
export ansi_BG_BRIGHT_RED
export ansi_BG_BRIGHT_GREEN
export ansi_BG_BRIGHT_YELLOW
export ansi_BG_BRIGHT_BLUE
export ansi_BG_BRIGHT_PURPLE
export ansi_BG_BRIGHT_CYAN
export ansi_BG_BRIGHT_WHITE
export ansi_LRED
export ansi_LGREEN
export ansi_LYELLOW
export ansi_LBLUE
export ansi_LPURPLE
export ansi_LCYAN
export ansi_WHITE
export ansi_passstring
export ansi_failstring
export ansi_warnstring
