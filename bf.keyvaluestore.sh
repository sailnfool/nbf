#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Cebu 6000 Philippines
########################################################################
#scriptname     :bf.keyvalue.store
#description01  :store any key/value associative array from the file
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
# 2.1 |REN|10/06/2023| changed errecho to bf_errecho
# 2.0 |REN|09/30/2023| Converted to bf format
# 1.0 |REN|08/09/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfkeyvaluestore}" ]] ; then
	export __bfkeyvaluestore=1

	source bf.cwave
	source bf.errecho
	source bf.insufficient


	function bf_keyvaluestore () {
		# bf_keyvaluestore aarray keyfile

		local -n aarray
		local keyfile
		local key
		local value
		local verbosemode="FALSE"
		local verboseflag=""
		local localNUMARGS=2

		if [[ "$#" -ge 1 ]] && [[ "$1" == "-v" ]] ; then
			verbosemode="TRUE"
			verboseflag=""
			shift
		fi
		bf_waventry ${verboseflag}
		
		if [[ "$#" -lt "${localNUMARGS}" ]] ; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit ${verboseflag}
			exit 1
		fi
		########################################################
		# The first argument to this file is the name of the
		# array to be stored.  We will refer to it with a
		# name reference local variable.
		########################################################
		aarray=$1

		########################################################
		# The second parameter is a key/value file to be
		# written
		########################################################
		if [[ -z "${2}" ]] ; then
			bf_errecho "Second parameter is null"
			bf_wavexit ${verboseflag}
			exit 1
		fi
		touch ${2}
		if [[ "$?" == 1 ]] ; then
			bf_errecho "Could not 'touch' ${2}"
			bf_wavexit ${verboseflag}
			exit 1
		fi

		if [[ -f ${2} ]] && [[ -w ${2} ]] ; then
			keyfile=$2
		else
			bf_errecho "Could not access ${2}"
			bf_wavexit ${verboseflag}
			return 1
		fi
		
		rm -f ${keyfile}
		for key in "${!aarray[@]}"
		do
#			bf_waverr "key=${key}"
			echo -e "${key}\t${aarray["${key}"]}" >> \
				${keyfile}
#			bf_waverr "aarray["${key}"]=" \
#				"${aarray["${key}"]}"
		done
		sort -o "${keyfile}" "${keyfile}"
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			cat "${keyfile}"
		fi
		bf_wavexit ${verboseflag}
		return 0
	}
	export -f bf_keyvaluestore
fi # if [[ -z "${__bfkeyvaluestore}" ]]
