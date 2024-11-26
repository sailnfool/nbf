#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
########################################################################
#scriptname     :bf.debug
#description00  :Set up global definitions of debugging levels and 
#description01  :define the _BDEBUG_USAGE string that defines the
#description02  :verbose help string on using bf.debug definitions
#args           :N/A
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#Licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|08/03/2022| Set default for _BF_DEBUG to _DEBUGOFF
#                    | Changed to using (my standardized) naming
#                    | conventions
# 1.2 |REN|07/19/2022| Cleaned up DEBUG_USAGE and removed redundant
#                    | comments
# 1.1 |REN|03/01/2021| Added DEBUGOFF
# 1.0 |REN|07/22/2010| Initial Release
#_____________________________________________________________________
if [[ -z "${__bfdebug}" ]] ; then
  export __bfdebug=1

  export _DEBUGOFF=0
  export _DEBUGWAVE=2
  export _DEBUGWAVAR=3
  export _DEBUGSTRACE=5
  export _DEBUGNOEXECUTE=6
  export _DEBUGNOEX=6
  export _DEBUGSETX=9

  export _BF_DEBUG=${_BF_DEBUG:-${_DEBUGOFF}}

  export _BF_DEBUG_USAGE="\n\tThe '-d'\t<#>\twhere <#> evaluates to a
\t\t\tdecimal integer
\t_DEBUGOFF 0 -\tTurn off debugging
\t_DEBUGWAVE 2 -\tprint indented entry/exit to functions
\t_DEBUGWAVAR 3 -\tprint variable data from functions if enabled
\t_DEBUGSTRACE 5 -\tprefix the executable with strace
\t\t\t(if implemented)
\t_DEBUGNOEXECUTE\tor
\t_DEBUGNOEX 6 -\tgenerate and display the command lines but don't
\t\t\texecute the script
\t_DEBUGSETX 9 -\tturn on set -x to debug
"
fi # if [[ -z "${__funcdebug}" ]]
