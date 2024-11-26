#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philipppines 6000
########################################################################
#scriptname01   :bf_dec2hex
#description01  :Convert the argument from decimal to N digits of zero
#description02  :prefixed hexadecimal digits
#description03  :Although this error checks for integer arguments it
#description04  :does no range checking.
#args           :number hexdigits
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
# 3.1 |REN|10/23/2023| added localNUMARGS
# 3.0 |REN|10/06/2023| Changed errecho to bf_errecho
# 2.0 |REN|08/23/2022| Converted to bfunc
# 1.0 |REN|05/27/2022| Initial Release
#_____________________________________________________________________
if [[ -z "${__bfdec2hex}" ]] ; then
	export __bfdec2hex=1

	source bf.insufficient
	source bf.regex

	bf_dec2hex() {
		local number
		local hexdigits
		local localNUMARGS=1

		case "$#" in
			0)
				bf_insufficient ${localNUMARGS} $@
				;;
			1)
				number="$1"
				hexdigits=""
				;;
			2)
				number="$1"
				hexdigits="$2"
				;;
			\?)
				echo "Bad arg to dec2hex" >&2
				exit 1
				;;
		esac
		if [[ ! "${number}" =~ ${bfre_integer} ]] ; then
			bf_errecho "First arg to bf_dec2hex is not " \
				"an integer ${number}"
			exit 1
		fi
		if [[ ! "${hexdigits}" =~ ${bfre_hexnumber} ]] ; then
			bf_errecho "Second arg to bf_dec2hex is not " \
				"an integer number of digits "\
				"${hexdigits}"
			exit 1
		fi
		printf "%0${hexdigits}x" ${number}
	}
	export bf_dec2hex
fi #if [[ -z "${__bfdec2hex}" ]]
