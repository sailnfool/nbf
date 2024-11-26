#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Alpas, Cebu, Philippines
########################################################################
#scriptname     :bf.gethash
#description01  :compute the Cryptographic hash of a file using the
#description02  :hash algorithm passed as a parameter.
#args           :hashtype file
#returns        :hashurl tagged hex digits of hash
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
# 1.0 |REN|07/14/2023| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfgethash}" ]] ; then
	export __bfgethash=1

	source bf.insufficient
	source bf.cwave

	function bf_gethash () {
		# bf_gethash [-v] hashtype inputfile

		local -n hashtype
		local inputfile
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
		# The first argument to this function is the name of
		# the hash program used to compute the hash.
		########################################################
    hashtype=$1
		bf_waverr "#1=${1}"

		########################################################
		# The second parameter is a file/object for which we will
    # compute the hash value of the file.
		########################################################
		if [[ -f ${2} ]] && [[ -r ${2} ]] ; then
			inputfile=$2
		else
			echo -e "${0##*/} ${FUNCNAME} Could not "\
				"access ${2}" >&2
			exit 1
		fi
		bf_waverr "#2=${2}, inputfile=${inputfile}"
		if [[ ! -f "${inputfile}" ]] ; then
			echo -e "${0##*/}:${FUNCNAME}:${LINENO} " \
				"${inputfile} is not a file" >&2
			exit 1
		fi
		if [[ "${verboseflag}" == "TRUE" ]] ; then
			cat ${inputfile}
		fi

    case ${hashtype} in
      Blake2b)
        hashout=$(b2sum ${inputfile})
        hashstring="Blake2b:${hashout:0:128}
        ;;
      \?)
        echo "Unrecognized hashtype ${hashtype}" >&2
        exit 1
        ;;
    esac
    echo ${hashout}
  }
fi # if [[ -z "${__bfgethash}" ]] ; then
