#!/bin/bash
########################################################################
# Copyright (C) 2023 Robert E. Novak  All Rights Reserved
# Cebu, Philippines 6000
########################################################################
#
# bf_intrandom - return a random positive integer from /dev/random
#
# bf_intrandomrange - return a number in the inerval [0-#)
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.1 |RWN|10/06/2023| changed errecho to bf_errecho
# 2.0 |REN|10/06/2023| Converted to bf, change the maxsignedint
# 1.0 |REN|07/29/2022| Initial Release
#_____________________________________________________________________

########################################################################
# bf_intrandom - return a random positive integer from /dev/random
########################################################################
if [[ -z "$__bfintrandom" ]] ; then
	export __bfintrandom=1

	source bf.errecho
	source bf.regex

	function bf_intrandom() {

	local num

		num=$(od -N4 -i -An /dev/urandom)
		((num=num<0?-num:num))
		echo $num
	}
	export -f bf_intrandom
	
########################################################################
# bf_intrandomrange - return a number in the inerval [0-#)
# The function bf_intrandom returns a 4 byte positive integer
# which is guaranteed to work on 64-bit machines.
########################################################################

	function bf_intrandomrange() {

	local maxsignedint=\
			$(echo "2^$(($(getconf LONG_BIT)-1))-1")
	local checksign

	if [[ ! "${1}" =~ $bfre_decimal ]] ; then
		bf_errecho "Argument is not a decimal number"
		exit 1
	else
		checksign=$(echo "${1} - ${maxsignedint}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho "Argument out of range ${1}"
			bf_errecho "Argument greater than maximum signed integer"
			bf_errecho "${maxsignedint}"
			exit 1
		fi
	fi
	echo $(( $(bf_intrandom) % $1 ))
	}
	export -f bf_intrandomrange
fi # if [[ -z "$__bfintrandom" ]]
