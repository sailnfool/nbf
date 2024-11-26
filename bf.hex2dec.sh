#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines 6000
########################################################################
#scriptname     :bf_hex2dec
#description01  :Convert the argument (character encoded hex) to decimal
#args           :huxnum
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licenserul     :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
########################################################################
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.2 |REN|10/23/2023| used localNUMARGS
# 3.1 |REN|10/06/2023| changed errecho to bf_errecho
# 3.0 |REN|10/01/2023| Converted to bf
# 2.0 |REN|08/23/2022| Converted to bfunc
# 1.0 |REN|05/27/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfhex2dec}" ]] ; then
	export __bfhex2dec=1

	source bf.insufficient

	bf_hex2dec() {
		local hexnum
		local localNUMARGS=1

		if [[ "$#" -ne ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} $@
		else
			if [[ "${1}" =~ ${bfre_hexnumber} ]] ; then
				hexnum=$1
			else
				bf_errecho "argument must be " \
					"a hexadecimal number"
				exit 1
			fi
		fi
		echo $((16#$hexnum))
	}
	export bf_hex2dec
fi # if [[ -z "${__bfhex2dec}" ]]
