#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Alpas, Cebu, Philippines
########################################################################
#scriptname     :bf.gethashtype
#description01  :give a hashurl file (hashname:value) extract the
#description02  :hashname as hashtype
#args           :hashurl
#returns        :hashtype
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
# 1.0 |REN|07/06/2023| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfgethashtype}" ]] ; then
	export __bfgethashtype=1

	source bf.insufficient
	source bf.cwave

	function bf_gethashtype () {
		# bf_gethashtype [-v] hashurl

		local hashurl
		local verbosemode="FALSE"
		local verboseflag=""
    local localNUMARGS=1

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

    hashtype=${hashurl##:*}
    hashvalue=${hashurl##*:}
    if [[ "${verboseflag}" == "TRUE" ]]; then
      echo "${0##/*} hashtype=${hashtype}" >&2
      echo "${0##/*} hashvalue=${hashvalue}" >&2
    fi


    case ${hashtype} in
      Blake2b)
        hashout=$(b2sum ${inputfile})
        hashstring="Blake2b:${hashout:0:128}"
        ;;
      \?)
        echo "Unrecognized hashtype ${hashtype}" >&2
 			  bf_wavexit ${verboseflag}
        exit 1
        ;;
    esac
		bf_wavexit ${verboseflag}
    echo ${hashout}
  }
fi # if [[ -z "${__bfgethashtype}" ]] ; then
