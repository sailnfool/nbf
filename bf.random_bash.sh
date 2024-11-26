#!/bin/bash
########################################################################
# Copyright (C) 2023 Robert E. Novak  All Rights Reserved
# Bacolod City, Negros Occidental, Philippines 6000
########################################################################
#
# bf_randomebashseed - Seed the Bash random number generator with a #
#
# bf_randomebashrange - return a number in the inerval [lo -- hi]
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.2 |REN|06/17/2024| Implemented with Bash RANDOM since I could not
#                    | get awk seeding to work.
# 2.1 |REN|10/06/2023| changed errecho to bf_errecho
# 2.0 |REN|10/06/2023| Converted to bf, change the maxsignedint
# 1.0 |REN|07/29/2022| Initial Release
#_____________________________________________________________________

########################################################################
# bf_intrandom - return a random positive integer from /dev/random
########################################################################
if [[ -z "$__bfrandombash" ]] ; then
	export __bfrandombash=1

	source bf.errecho
	source bf.regex
	source bf.insufficient

	function bf_randombashseed() {

	local numargs=1

	bf_waventry
	if [[ "$#" -ne "${numargs}" ]]; then
		bf_insufficient "Need ${numargs}, got $#" "$@"
		bf_wavexit
		exit 1
	fi
	if [[ ! "$1" =~ ${bfre_integer} ]] ; then
		bf_errecho "Argument 1 must be an integer, got ${1}"
		bf_wavexit
		exit 2
	fi
	bf_waverr "Seed=${1}"
	RANDOM="$1"
	bf_wavexit
	}
	export -f bf_randombashseed
	
########################################################################
# bf_randomebashrange - return a number in the inerval [0-#)
# The function bf_randomebashrange only uses the Bash random interval
# of [0-32767] which is not very random.
########################################################################

	function bf_randombashrange() {

		local lower
		local upper
		local maxrandom=32767

		bf_waventry
		if [[ ( ! "${1}" =~ $bfre_integer )  || \
			("${1}" -gt "${maxrandom}" ) ]] ; then
			bf_errecho "Argument 1 is not an integer number"
			bf_errecho "or Argument 1 is greater " \
				"then maximum ${maxrandom}"
			bf_wavexit
			exit 1
		fi
		if [[ ( ! "${2}" =~ $bfre_integer ) || \
			|| ("${2}" -gt "${maxrandom}" ) ]] ; then
			bf_errecho "Argument 2 is not an integer number"
			bf_errecho "or Argument 2 is greater " \
				"then maximum ${maxrandom}"
			bf_wavexit
			exit 1
		fi
		lower=${1}
		upper=${2}
		result="$(((RANDOM%(upper-lower+1))+lower))"
		bf_waverr "(${lower} -- ${result} -- ${upper})"
		echo "${result}"
		bf_wavexit
	}
	export -f bf_randombashrange
fi # if [[ -z "$__bfrandombash" ]]
