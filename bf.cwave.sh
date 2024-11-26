#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philipppines 6000
########################################################################
#scriptname01   :cwave define function entry/exit tracking routines
#scriptname02   :that create a "wavy" line of indenting levels
#scriptname01a  :bf_waventry
#description01a :notify that we have entered a function
#args01a        :[-v]
#scriptname01b  :bf_wavexit
#description01b :notify that we have exited a function
#args01b        :[-v]
#scriptname01c  :bf_waverr
#description01c :print the users message(s) on stderr, indented.
#args01c        :[-v] "message" "[...]"
#scriptname01d  :bf_wave
#description01d :print the users message(s) on stdout, indented.
#args01c        :[-v] "message" "[...]"
#
#author: Robert E. Novak aka REN
#email: sailnfool@gmail.com
#licensor: CC by Sea2Cloud Storage, Inc.
#licensurl: https://creativecommons.org/licenses/by/4.0/legalcode
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.1 |REN|10/07/2023| took out loops, used print %xc idiom for indents
# 3.0 |REN|09/30/2023| Converted to bf.cwave
# 2.2 |REN|07/26/2022| added "-v" option to functions.
# 2.1 |REN|07/24/2022| Normalized header file and end the funcenter
#                    | and funcexit functions
# 2.0 |REN|11/13/2019| added vim directive and header file
# 1.0 |REN|09/06/2018| original version
#_____________________________________________________________________

if [[ -z "${__bfwave}" ]] ; then
	export __bfwave=1

	source bf.debug

	################################################################
	# Mark the entry to a function
	################################################################
	bf_waventry ()
	{
		local level    # of spaces to indent based on level 
		               # deep in nesting local xx
			       # Used to create the output string
		local xx       # String to hold the spacing prefix

		if [[ "${_BF_DEBUG}" -ge "${_DEBUGWAVE}" ]] ; then

			################################################
			# Find out how many levels deep we are in
			# the function stack
			################################################
			level=${#FUNCNAME[@]}

			################################################
			# Set the prefix string to null
			################################################
			xx=""

			local FN # FUNCNAME
			local LN # BASH_LINENO
			local SF # BASH_SOURCE
			local CM # COMMAND (arg 0)
#			local i
# 			for ((i=0; i<level; i++))
# 			do
# 				FN=${FUNCNAME[${i}]}
# 				LN=${BASH_LINENO[${i}]}
# 				printf "%${i}c" ">" >&2
# 				echo ${FN}:${LN} >&2
# 			done

			FN=${FUNCNAME[1]}
			LN=${BASH_LINENO[1]}
			SF=${BASH_SOURCE[0]}
			CM=${0##*/}


			################################################
			# skip over this function (which is FUNCNAME[0])
			# creating ">>>>"
			################################################
			xx=$(printf "%${level}c" ">")

			################################################
			# Process the optional verbose argument
			# to emit the source file and command line
			################################################
			if [[ $# -eq 1 ]] && [[ $1 == "-v" ]] ; then
				echo "${xx}${FN}:${LN}" \
					":::${SF}-->${CM}" >&2
				shift 1
			else
				echo "${xx}${FN}:${LN}" >&2
			fi
		fi
	}
	export -f bf_waventry

	bf_wavexit ()
	{
		if [[ "${_BF_DEBUG}" -ge "${_DEBUGWAVE}" ]] ; then
			local FN
			local LN
			local SF
			local CM
			local level
			local xx    # String to hold the spacing prefix
			local j

			xx=""
			################################################
			# Find out how many levels deep we are in the
			# function stack
			################################################
			level=${#FUNCNAME[@]}

# 			local i
# 			for ((i=0; i<=level; i++))
# 			do
# 				FN=${FUNCNAME[$((i+1))]}
# 				LN=${BASH_LINENO[${i}]}
# 				local xx
# 				xx=$(printf "%${i}c" "<")
# 				echo "${xx}${FN}:${LN}">&2
# 			done

			FN=${FUNCNAME[1]}
			LN=${BASH_LINENO[0]}
			SF=${BASH_SOURCE[0]}
			CM=${0##*/}


			################################################
			# skip over this function (which is FUNCNAME[0])
			# Insert the "<<<<"
			################################################
			xx=$(printf "%${level}c" "<")
	
			################################################
			# Process the optional verbose argument
			# to emit the source file and command line
			################################################
			if [[ $# -eq 1 ]] && [[ $1 == "-v" ]] ; then
				echo "${xx}${FN}:${LN}" \
					":::${SF}-->${CM}" >&2
				shift 1
			else
				echo " ${xx}${FN}:${LN}" >&2
			fi
		fi # if [[ "${_BF_DEBUG}" -ge "${_DEBUGWAVE}" ]] ; then
	}
	export -f bf_wavexit

	################################################################
	# Send N indented space(s)  equal to the function call depth
	# then print an argument string to stderr
	################################################################
	bf_waverr ()
	{
		if [[ "${_BF_DEBUG}" -ge "${_DEBUGWAVAR}" ]] ; then
			local FN
			local LN
			local SF
			local CM

			local i
			local j
			for ((i=0; i<level; i++))
			do
				FN=${FUNCNAME[${i}]}
				LN=${BASH_LINENO[${i}]}
				local xx
				xx=$(printf "%${i}c" "<")
				stdbuf -e0 echo -e ${xx}${FN}:${LN} >&2
			done

			FN=${FUNCNAME[1]}
			if [[ "${FN}" == "main" ]] ; then
				FN=${0##*/}
			fi
			LN=${BASH_LINENO[0]}
			SF=${BASH_SOURCE[0]}
			CM=${0##*/}

			local level
			local xx
			local verbosemode
			verbosemode="FALSE"
			xx=""

			if [[ $# -gt 1 ]] && [[ "${1}" == -v ]] ; then
				verbosemode="TRUE"
				shift 1
			fi
			level=${#FUNCNAME[@]}
			xx=$(printf "%${level}c" " ")
#			xx="${xx}@"
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				stdbuf -e0 echo -en "${xx} ${FN}:${LN}:$@\t" >&2
				for ((i=1; i<level; i++))
				do
					local BS=\
						"${BASH_SOURCE[${i}]}:" 
					local BL=\
						"${BASH_LINENO[$((i-1))]}"
					stdbuf -e0 echo -n "${BS}:" \
						"${BL}-> " >&2
				done
				stdbuf -e0 echo "" >&2
			else
				stdbuf -e0 echo -e "${xx} ${FN}:${LN}:$@" >&2
			fi
		fi
	}
	export -f bf_waverr

	################################################################
	# Send N indented space(s) equal to the function call depth
	# followed by the variable in the arguments
	################################################################
	bf_wave ()
	# bf_wave <variable list> replace wavindentvar
	{

		local FN
		local LN
		local SF
		local CM

		FN=${FUNCNAME[1]}
		LN=${BASH_LINENO[0]}
		
		local level
		local xx
		local verbosemode="FALSE"

		if [[ $# -gt 1 ]] && [[ "${1}" == -v ]] ; then
			verbosemode="TRUE"
			shift 1
		fi

		level=${#FUNCNAME[@]}
		xx=$(printf "%${level}c" " ")
		echo $xx
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			local SF
			local CM
			SF=${BASH_SOURCE[0]}
			CM=${0##*/}
			echo "${xx} ${FN}:${LN}:::${SF}-->${CM}:$@"
		else
			echo "${xx} ${FN}:${LN}:$@"
		fi
	}
	export -f bf_wave
	
	################################################################
	# End of cwave functions
	################################################################

fi # if [[ -z "${__bfwave}" ]]
