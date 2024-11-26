#!/bin/bash
########################################################################
# Copyright (C) 2024 Robert E. Novak  All Rights Reserved
# Bacolod, Philippines 6000
########################################################################
#
# bf_seedintrandom - seed the awk random number generator
#
# bf_seedintrandomrange - return a number in the inerval [lo-hi]
#                         if already initialized wtih seed, each
#                         sequence generated after the same seed should
#                         be identical
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.0 |REN|06/11/2024| Used awk rand to avoid the asymmetry of bash
#                    | random (i.e. range of 0-32767)
# 2.1 |REN|10/06/2023| changed errecho to bf_errecho
# 2.0 |REN|10/06/2023| Converted to bf, change the maxsignedint
# 1.0 |REN|07/29/2022| Initial Release
#_____________________________________________________________________

########################################################################
# bf_seedintrandom - Set a seed for the awk random number generator
########################################################################
if [[ -z "$__bfseedintrandom" ]] ; then
	export __bfseedintrandom=1

	source bf.errecho
	source bf.regex
	source bf.insufficient

	function bf_seedintrandom() {
		# <integer seed>
                ########################################################
		# Take an integer argument and use it to seed the awk
		# random number generator
                ########################################################

		local NUMARGS=1
		local seednum

		bf_waventry
		if [[ "$#" -ne "${NUMARGS}" ]] ; then
			bf_insufficient ${NUMARGS} "wanted ${NUMARGS} " \
				"got $#" "$@"
			bf_wavexit
		fi
		
                ########################################################
		# Verify that the first argument is an integer
                ########################################################
		if [[ ! "${1}" =~ $bfre_integer ]] ; then
			bf_errecho "Argument 1 (seed) is not " \
				"an integer - ${1}"
			bf_wavexit
			exit 1
		else
			seednum="$1"
		fi
		awk "BEGIN {srand(${seednum})}"
		bf_wavexit
	}
	export -f bf_seedintrandom
	
########################################################################
# bf_seedntrandomrange - return a number in the interval [lo-hi]
# The function bf_seedintrandom returns a 4 byte positive integer
# which is guaranteed to work on 64-bit machines.
########################################################################

	function bf_seedintrandomrange() {

                ########################################################
		# This is the architecture independent way of getting
		# the largest positive integer supported on this
		# machine
                ########################################################
                local maxsignedint=$(echo "2^$(($(getconf LONG_BIT)-1))-1"|bc)
                local checksign
                local NUMARGS=2

               	bf_waventry

		########################################################
		# Check for the number of arguments
		########################################################
		if [[ "$#" -ne "${NUMARGS}" ]] ; then
			bf_insufficient ${NUMARGS} "Wanted ${NUMARGS} " \
				"got $# $@"
			bf_wavexit
		fi

		########################################################
		# Verify that both arguments are integers
		########################################################
                if [[ ! "${1}" =~ $bfre_integer ]] ; then
			bf_errecho "Argument 1 (low limit) ${1} " \
				"is not an integer number"
                        bf_wavexit
                        exit 1
		fi
                if [[ ! "${2}" =~ $bfre_integer ]] ; then
			bf_errecho "Argument 2 (high limit) ${2} " \
				"is not an integer number"
                        bf_wavexit
                        exit 1
		fi

		########################################################
		# Check to see if the argument is in the range of
		# [0 -- MAXINT]
		# subtract the machine-dependent maximum integer from
		# the argument.  If the result is positive, then the
		# argument is larger than MAXINT, then it is invalid
		########################################################
                checksign=$(echo "${1} - ${maxsignedint}" | bc)
                if [[ ! "${checksign:0:1}" == "-" ]] ; then
			bf_waverr "checksign=${checksign}"
                        bf_errecho "Argument 1 out of range ${1}"
                        bf_errecho "Argument greater than maximum "
			bf_errecho "signed integer ${maxsignedint}"
                        bf_wavexit
                        exit 1
		else
                        lo="${1}"
		fi

		########################################################
		# Do the saem for argument #2
		########################################################
                checksign=$(echo "${2} - ${maxsignedint}" | bc)
                if [[ ! "${checksign:0:1}" == "-" ]] ; then
			bf_waverr "checksign=${checksign}"
                        bf_errecho "Argument 2 out of range ${2}"
                        bf_errecho "Argument greater than maximum"
			bf_errecho "signed integer ${maxsignedint}"
                        bf_wavexit
                        exit 1
		else
                       	hi="${2}"
                fi

		########################################################
		# Fetch the random number from awk and multiply it by
		# the interval, then subtract the low value
		########################################################
		awk "BEGIN{print int(rand()*(${hi}-${lo}+1))+${lo}}"
		bf_wavexit
	}

	export -f bf_seedintrandomrange
fi # if [[ -z "$__bfseedintrandom" ]]
