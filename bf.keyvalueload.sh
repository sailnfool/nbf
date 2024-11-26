#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Cebu 6000 Philippines
########################################################################
#scriptname     :bf.keyvalueload
#description01  :Load any key/value associative array from the file
#description02  :passed as a parameter.
#args           :aaray keyfile
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licenserul     :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.9 |REN|10/06/2023| changed errecho to bf_errecho
# 1.2 |REN|08/16/2023| Changed location, updated comments on headers
# 1.1 |REN|09/21/2022| Added code to skip over lines starting with #
#                    | so that any descriptive headers have to start
#                    | this way with a comment (#) in the first 
#                    | character.
# 1.0 |REN|08/09/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfkeyvalueload}" ]] ; then
	export __bfkeyvalueload=1

	source bf.ansi_colors
	source bf.cwave
	source bf.errecho
	source bf.insufficient

	function bf_keyvalueload () {
		# bf_keyvalueload [-v] aarray keyfile

		local -n aarray
		local keyfile
		local key
		local value
		local verbosemode="FALSE"
		local verboseflag=""

		bf_waventry ${verboseflag}
		if [[ "$#" -ge 1 ]] && [[ "$1" == "-v" ]] ; then
			verbosemode="TRUE"
			verboseflag="-v"
			shift
		fi
		
		if [[ "$#" -lt "${localNUMARGS}" ]] ; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit ${verboseflag}
			exit 1
		fi
		########################################################
		# The first argument to this file is the name of the
		# array to be loaded.  We will refer to it with a
		# name reference local variable.
		########################################################
#		bf_waverr "all args = $@"
		aarray=$1
#		bf_waverr "#1=${1}"

		########################################################
		# The second parameter is a key/value file to be read
		########################################################
		if [[ -f ${2} ]] && [[ -r ${2} ]] ; then
			keyfile=$2
		else
			bf_errecho -e "Could not access ${2}"
			bf_wavexit ${verboseflag}
			exit 0
		fi
#		bf_waverr "#2=${2}, keyfile=${keyfile}"
		if [[ ! -f "${keyfile}" ]] ; then
			bf_errecho -e "${keyfile} is not a file"
			bf_wavexit
			exit 0
		fi
		if [[ "${verboseflag}" == "TRUE" ]] ; then
			cat ${keyfile}
		fi

		while IFS=$'\t' read -r key value
		do
			################################################
			# Skip over comment/headers
			################################################
			if [[ "${key:0:1}" == "#" ]] ; then
				continue
			fi
#			bf_waverr "key=${key}, value=${value}"
			if [ ${aarray[${key}]+_} ]; then
				bf_errecho -e "${ansi_warnstring}" \
					"key=${key} already exists " \
					"with value " \
					"'${aarray[${key}]}'"
				bf_errecho -e "and will " \
					"be replaced by '${value}'"
			fi

			aarray["${key}"]="${value}"

#			bf_waverr "aarray["${key}"]=" \
#				"${aarray["${key}"]}"
		done < ${keyfile}
		bf_wavexit ${verboseflag}
	}
	export -f bf_keyvalueload
fi # if [[ -z "${__bfkeyvalueload}" ]]
