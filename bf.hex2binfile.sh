#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines 6000
########################################################################
#scriptname     :bf_hex2binfile
#description01  :Convert the argument from Hex to binary and output
#description02  :to a file. -b indicates perform a byteswap
#args           :[-b] hexstring filename
#note01         :This took a long time to debug because I neglected to
#note02         :declare local variables and they overwrote the caller
#note03         :variables... messing things up big time.
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
# 3.2 |REN|10/23/2023| added localNUMARGS and localOPTARGS
# 3.1 |REN|10/06/2023| changed errecho to bf_errecho
# 3.0 |REN|10/01/2023| Converted to bf
# 2.0 |REN|08/23/2022| Converted to bfunc
# 1.1 |REN|07/09/2022| Insured function local variables are local!!!!
# 1.0 |REN|07/08/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfhex2binfile}" ]] ; then
	export __bfhex2binfile=1

	source bf.errecho
	source bf.insufficient
	source bf.regex

	bf_hex2binfile() {
#    [-b] hexstring filename

		local localNUMARGS=2
		########################################################
		# Added simplistic code for the optional argument of
		# "-b" to handle performing byteswaps on output.
		########################################################
		local byteswap="FALSE"
		local localOPTARGS=3
		local h # hexstring
		local i # index
		local s # swapvalue


		########################################################
		# The following declaration insures that the values in
		# the h variable will all be lower case
		########################################################
		declare -l h

		if [[ "$#" -eq "${localOPTARGS}" ]] ; then
			if [[ "${1}" == "-b" ]] ; then
				byteswap="TRUE"
				shift 1
			fi
		fi
		########################################################
		# At this point the optional -b has been shifted out,
		# make sure we still have 2 parameters
		########################################################
		if [[ "$#" -lt "${localNUMARGS}" ]] ; then
			bf_insufficient ${localNUMARGS} $@
			exit 1
		else
			if [[ ! "${1}" =~ ${bfre_hexnumber} ]] ; then
				bf_errecho "first argument must " \
					"be a hexadecimal string"
				exit 1
			fi
			h="${1}"
			touch -c "${2}"
			touchresult=$?
			if [[ ! "${touchresult}" == 0 ]] ; then
				bf_errecho "second argument " \
					"has a filename, but could " \
					"not create the file"
				exit 2
			fi
			filename="${2}"
		fi

		########################################################
		# The practice for managing byte swaps is to save the
		# first byte encountered in the string 's' and then
		# on the next character found emit them as swapped
		# bytes.  If there is no swapping, then we just emit
		# the characters one at a time.
		########################################################
		s=""
		for ((i=0; i<${#h}; i+=2))
		do
			################################################
			# We have to handle the special case that there
			# are an odd number of hex digits.
			################################################
			if [[ "$((${#h} - i ))" -ge 2 ]] 
			then
				if [[ "${byteswap}" == "TRUE" ]] && \
					[[ "${#s}" == 0 ]] ; then
					s="${h:${i}:2}"
				else
					printf "\x${h:${i}:2}${s}" \
						>> ${filename}
					s=""
				fi
			else # if [[ "$((${#h} - i ))" -ge 2 ]]

				########################################
				# At this point we have a trailing
				# single digit. Zero pad a single digit
				# and handle byteswapping correctly
				########################################
				if [[ "${byteswap}" == "TRUE" ]] ; then

					################################
					# The following code sometimes
					# fails when the contents of
					# the h picks up "FALSE" as a
					# string?????  This was due
					# to calling the function with
					# an invalid parameter list.
					################################
					printf "\x0${h:${i}:1}" \
						>> ${filename}
				else
					printf "\x${h:${i}:1}0" \
						>> ${filename}
				fi
			fi # if [[ "$((${#h} - i ))" -gt 2 ]]
		done
	}
	export bf_hex2binfile
fi # if [[ -z "${__bfhex2binfile}" ]]
