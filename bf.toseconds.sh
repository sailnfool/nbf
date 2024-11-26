#!/bin/bash
########################################################################
# Copyright (C) 2022 Robert E. Novak  All Rights Reserved
# Modesto, CA 95356
########################################################################
#
# toseconds - convert a time to number of seconds.  Has to be
#             flexible for HH:MM:SS or MM:SS or just SS.xx
#
# Author: Robert E. Novak
# email: sailnfool@gmail.com
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
# 1.2 |REN|10/23/2023| Added localNUMARGS localOPTIONARGS and changed
#                    | the function name to bf_toseconds
# 1.1 |REN|10/06/2023| Converted errecho to bf_errecho
# 1.0 |REN|02/01/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bftoseconds}" ]] ; then
	export __bftoseconds=1

	source bf.errecho
	source bf.insufficient

	bf_toseconds()
	{

		local localNUMARGS=1
		local localOPTIONARGS=2
		local -a secondresult
		local tresult
		local result

		if [[ $# -lt ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} "at least " \
				"one argument in time format required"
			exit 1
		fi

		if [[ $# -eq ${localOPTIONARGS} ]] ; then
			if [[ "$1" == "-v" ]] ; then
				local verbosemode="TRUE"
				shift
			else
				bf_errecho "Invalid optional first " \
					"argument, must be -v, got $@"
				exit 2
			fi
		fi
		secondresult[0]=$(echo "$1" | \
			awk -F: '{ if (NF == 1) {print $NF} }' | bc)
		secondresult[1]=$(echo "$1" | \
			awk -F: \
			'{ if (NF == 2) {print $1 "* 60 + " $2} }' | \
				bc)
		secondresult[2]=$(echo "$1" | \
			awk -F: '{ if (NF == 3) {print $1 "*3600+" $2 "*60+" $3} }' | \
				bc)

		for ((i=0;i<${#secondresult[@]};i++))
		do
			tresult="${secondresult[${i}]}"
			if [[ ! -z "${tresult}" ]] ; then
				if [[ "${tresult:0:1}" == "." ]] ; then
					result="0${tresult}"
				else
					result="${tresult}"
				fi
			fi
		done
		if [[ "${result}" == "0" ]] ; then
			result="0.0"
		fi
		echo ${result}
	 }
	export -f bf_toseconds
fi # if [[ -z "${__bftoseconds}" ]]
