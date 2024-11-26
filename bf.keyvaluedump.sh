#!/bin/bash
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod, Negros Occidental, 6100 Philippines
########################################################################
#scriptname     :bf.keyvaluedump
#description01  :
#description02  :passed as a parameter.
#args           :aaray keyfile
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licensrul      :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensname     :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|08/09/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfkeyvaluedump}" ]] ; then
	export __bfkeyvaluedump=1

	source bf.cwave
	source bf.insufficient

	function bf_keyvaluedump () {
		# bf_keyvaluedump aarray keyfile

		local -n aarray
		local keyfile
		local key
		local value
		local verbosemode="FALSE"
		local verboseflag=""
		local temprefix

		if [[ "$#" -ge 1 ]] && [[ "$1" == "-v" ]] ; then
			verbosemode="TRUE"
			verboseflag=""
			shift
		fi
		bf_waventry ${verboseflag}
		
		if [[ "$#" -lt "${localNUMARGS}" ]] ; then
			bf_insufficient ${localNUMARGS} $@
			exit 1
		fi
		########################################################
		# The first argument to this file is the name of the
		# array to be loaded.  We will refer to it with a
		# name reference local variable.
		########################################################
		aarray=$1

		########################################################
		# The second parameter is a key/value file to be written
		########################################################
		touch ${2}
		if [[ "$?" == 1 ]] ; then
			echo -e "${0##*/} ${FUNCNAME} ${LINENO} " \
				"Could not 'touch' ${2}" >&2
		fi

		if [[ -f ${2} ]] && [[ -w ${2} ]] ; then
			keyfile=$2
		else
			echo -e "${0##*/} ${FUNCNAME} ${LINENO} " \
				"Could not access ${2}" >&2
			bf_wavexit ${verboseflag}
			return 1
		fi
		
		rm -f ${keyfile}
		for key in "${!aarray[@]}"
		do
#			bf_waverr "key=${key}"
			echo -e "${key}\t${aarray["${key}"]}" >> \
				${keyfile}
			bf_waverr "aarray["${key}"]=" \
				"${aarray["${key}"]}"
		done
		sort -o "${keyfile}" "${keyfile}"
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			cat "${keyfile}"
		fi
		bf_wavexit ${verboseflag}
		return 0
	}
	export bf_keyvalue_dump
fi # if [[ -z "${__bfkeyvaluedump}" ]]
