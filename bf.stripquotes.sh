#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Cebu 6000 Philippines
########################################################################
#scriptname     :strip_quotes
#description01  :remove first and last quotes if present
#description02  :This is based on an answer in Stackoverflow (see
#description03  :attriburl01 below) by Gene Pavlovsky on 7/12/2017.
#description04	:I was unsatisfied with the answer since the ${!1}
#description05  :is a construct not often used.  (see attriburl02)
#description06  :I also felt that the script needed a simple error
#description07  :check and I chose to use a regular expression for
#description08  :readability
#args           :"quoted string"
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#Licensename    :Creative Commons Attribution license
#attriburl01    :https://stackoverflow.com
#attribquesion01:/questions/9733338
#attribdesc01   :/shell-script-remove-first-and-last-quote-from-a-variable
#attriburl02	:https://www.gnu.org/software/bash/manual
#attribsect02   :/bash.html#Positional-Parameters
#attribdesc02	:3.5.3 Shell Parameter Expansion
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|08/16/2023| Converted to bf subroutines.
# 1.0 |REN|08/24/2022| see #attriburl01
#_____________________________________________________________________
if [[ -z "${__bfstripquotes}" ]] ; then
	export __bfstripquotes=1

	bf_stripquotes() {
		while [[ $# -gt 0 ]]; do
			local re_quotedstring
			re_quotedstring='^\".*\"$'

			################################################
			# see 3.5.3 Shell Parameter Expansion in the
			# BASH manual
			################################################
			local value=${!1}
			local len=${#value}
			
			if [[ ! ${value} =~ ${re_quotedstring} ]] ; then
				echo "${FUNCNAME}:${LINENO} " \
					"invalid string " \
					"argument not " \
					"quoted ${value}" >&2
				echo "${FUNCNAME}:${LINENO} " \
					"variable not modified" >&2
				exit 1
			else

				########################################
				# Reformatted from Gene Pavlovsky on 
				# 7/12/2017
 	        		# [[ ${value:0:1} == \" && \
				# ${value:$len-1:1} == \" ]] && \ 
				# declare -g $1="${value:1:$len-2}"
				########################################
				# See 4.2 Bash Builtin Commands in the
				# BASH manual for "-g"
				# "The -g option forces variables to be
				# created or modified at the global
				# scope, even when declare is executed
				# in a shell function. It is ignored
				# in all other cases."
				########################################
	        		declare -g $1="${value:1:$len-2}"
			fi
	        shift
	    done
	}
	export -f bf_stripquotes
fi # if [[ -z "${__bfstripquotes}" ]] ; then
