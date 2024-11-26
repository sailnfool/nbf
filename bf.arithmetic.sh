#!/bin/bash
########################################################################
# copyright: (C) 2023 Sea2cloud Storage, Inc.  All Rights Reserved
# location: Cebu, Philippines 6000
########################################################################
#
# arithmetic - define some useful arithmetic functions
#        since the arguments to the int functions are passed as
#        strings, error checking for integers fitting into two's
#        complement 64 bit numbers should be added and abort the
#        functions if invalid arguments are presented since they
#        would produce invalid results.
#
#        bf_intmin - The minimum of two integers
#        bf_intmax - The Maximum of two integers
#        bf_introundup - Round an integer to the specified power
#                           of value.  Note that this can produce
#                           results larger than the maximum signed
#                           integer.  A warning is issued to stderr.
#        bf_factorial - compute an arbitrary precision factorial
#                          of a given argument
#
# author: Robert E. Novak aka REN
# email: sailnfool@gmail.com
# licensor: CC by Sea2Cloud Storage, Inc.
# licensurl: https://creativecommons.org/licenses/by/4.0/legalcode
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.3 |REN|10/23/2023| added localNUMARGS
# 2.2 |REN|10/07/2023| Converted to bf, change errecho to bf_errecho
# 2.1 |REN|09/30/2023| Converted from bfunc.arithmetic
# 2.0 |REN|08/02/2022| Converted from func.arithmetic
# 1.1 |REN|07/29/2022| Added bf_factorial, added additional error
#                    | checks for exceeding the maximum signed integer
# 1.0 |REN|07/24/2022| Initial Release
#_____________________________________________________________________

if [[ -z "$__bfarithmetic" ]] ; then
	export __bfarithmetic=1

	source bf.ansi_colors
	source bf.errecho
	source bf.insufficient
	source bf.regex

	################################################################
	# Return the minimum of two integers
	###############################################################
	bf_intmin()
	{
		local maxsignedint=\
			$(echo "2^$(($(getconf LONG_BIT)-1))-1")
		local checksign

		if [[ ! "${1}" =~ $bfre_integer ]] || \
			[[ ! "${2}" =~ $bfre_integer ]] ; then
			bf_errecho -e \
				"Both arguments must be integers $@"
			exit 1
		fi
		checksign=$(echo "${maxsignedint} - ${1}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e \
				"Argument #1 ${1} is larger than " \
				"the maximum signed integer on a " \
				"64-bit machine." 
			bf_errecho -e "Max signed integer = " \
				"${maxsignedint}"
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		checksign=$(echo "${maxsignedint} - ${2}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e \
				"Argument #2 ${2} is larger than " \
				"the maximum signed integer on a " \
				"64-bit machine."
			bf_errecho -e "Max signed integer = " \
				"${maxsignedint}"
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		echo $(( $1 < $2 ? $1 : $2 ))
	}
	export -f bf_intmin

	################################################################
	# Return the maximum of two integers
	################################################################
	bf_intmax()
	{
		local maxsignedint=\
			$(echo "2^$(($(getconf LONG_BIT)-1))-1")
		local checksign

		if [[ ! "${1}" =~ $bfre_integer ]] || \
			[[ ! "${2}" =~ $bfre_integer ]] ; then
			bf_errecho -e "Both arguments must be " \
				"integers $@"
			exit 1
		fi
		checksign=$(echo "${maxsignedint} - ${1}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e "Argument #1 ${1} is larger " \
				"than the maximum signed integer on"
			bf_errecho -e "a 64-bit machine."
			bf_errecho -e "Max signed integer ="\
				"${maxsignedint}."
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		checksign=$(echo "${maxsignedint} - ${2}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e "Argument #2 ${2} is larger " \
				"than the maximum signed integer on"
			bf_errecho -e "a 64-bit machine."
			bf_errecho -e "Max signed integer ="\
				"${maxsignedint}."
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		echo $(( $1 > $2 ? $1 : $2 ))
	}
	export -f bf_intmax

	################################################################
	# round up a number to the nearest value.  This is only integer
	# arithmetic so, call will look like:
	# bf_introundup number, 100
	# to round a number up to the next multiple of 100.  Similarly
	# for 10 or 1000.
	###############################################################
	bf_introundup()
	{
		local maxsignedint=\
			$(echo "2^$(($(getconf LONG_BIT)-1))-1")
		local checksign

		local number
		local nearest
		local result

		if [[ ! "${1}" =~ $bfre_integer ]] || \
			[[ ! "${2}" =~ $bfre_integer ]] ; then
			bf_errecho -e "Both arguments must be " \
				"integers $@"
			exit 1
		fi

		number=$1
		nearest=$2

		if [[ $nearest -eq 0 ]] ; then
			bf_errecho -e "second argument must be " \
				"integer > 0 $@"
			exit 1
		fi
		checksign=$(echo "${maxsignedint} - ${1}" | bc) 
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e "Argument #1 ${1} is larger " \
				"than the maximum signed integer on"
			bf_errecho -e "a 64-bit machine."
			bf_errecho -e "Max signed integer ="\
				"${maxsignedint}."
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		checksign=$(echo "${maxsignedint} - ${2}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e "Argument #2 ${2} is larger " \
				"than the maximum signed integer on"
			bf_errecho -e "a 64-bit machine."
			bf_errecho -e "Max signed integer ="\
				"${maxsignedint}."
			bf_errecho -e "calculation aborted, result " \
				"would be invalid, use bc"
			exit 2
		fi
		result=$(echo "( ${number} + ${nearest} ) -" \
			"( ${number} % ${nearest} )" | bc )
		checksign=$(echo "${maxsigned} - ${result}" | bc)
		if [[ "${checksign:0:1}" == "-" ]] ; then
			bf_errecho -e "${ansi_warnstring} Result is " \
				"larger than max signed integer."
			bf_errecho -e "Max signed integer = " \
				"${maxsignedint}"
		fi
		echo $result
	}
	export -f bf_introundup 

	################################################################
	# Return the factorial of a number. Requires an integer argument
	# allows arbitrary precision by using 'bc'
	# This function provides a great example of bf_waventry and
	# bf_wavexit (see bf.debug and bf.cwave
	################################################################
	bf_factorial()
	{
		bf_waventry -v

		local sub
		local localNUMARGS=1

		if [[ $# -ne ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit -v
			exit 1
		fi
		if [[ ! "${1}" =~ $bfre_integer ]] ; then
			echo -e "argument is not an integer"
			bf_wavexit -v
			exit 1
		fi
		if [[ "${1}" -le 1 ]] ; then
			bf_wavexit -v
			echo 1
		else
			sub=$(bf_factorial $(( $1 - 1 )) )
			bf_wavexit -v
			echo "$1 * $sub" | bc
		fi
		exit 0
	}
	export -f bf_factorial

fi # if [ -z "$__bfarithmetic" ]
