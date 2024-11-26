#!/bin/bash
scriptname=${0##*/}
# Copyright (c) 2023 Sea2Cloud Storage, Inc.  All Rights Reserved
# Cebu, Philippines 6000
#
# dresscodenumber - Given the name of a dress image file, create a
#            unique number given a cryptographic sha512 hash of the
#            image taking the first 4 hex digits and last 4 hex digits
#            and converting them to a decimal number number modulo
#            10,000.
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|04/20/2024| Initial Release
#_____________________________________________________________________
#
#
source bf.insufficient
source bf.sslmacbits
source bf.errecho
source bf.cwave
source bf.hex2dec
	
function bf_dresscodenumber () {
	local dressfilename
	local digestcommand
	local firsthex
	local lasthex
	local moddigits

	local localNUMARGS=5
	local modulus
	local crypthash
	local newhash
	local hexshort
	local deximalfull
	local decimal

	bf_waventry
	if [[ "$#" -lt "${localnumargs}" ]]; then
		bf_insufficient ${localNUMARGS} $@
	fi
	dressfilename="$1"
	if [[ ! -r ${dressfilename} ]]; then
		bf_errecho "Could not read ${dressfilename}"
		bf_wavexit
		exit 1
	fi
	digestcommand="${2}"
	bf_sslmacverify ${digestcommand} 2>&1 >/dev/null
	result=$?
	if [[ ! ${result} ]]; then
		bf_errecho "Could not find ${digestcommand} in openssl"
		bf_wavexit
		exit 1
	fi
	firsthex="${3}"
	if [[ ! "${firsthex}" =~ ${bfre_integer} ]]; then
		bf_errecho "\-f requires an integer number got ${firsthex}"
		bf_wavexit
		exit 1
	fi
	lasthex="${4}"
	if [[ ! "${lasthex}" =~ ${bfre_integer} ]]; then
		bferrecho "\-l requires am integer number got ${lasthex}"
		bf_wavexit
		exit 1
	fi
	moddigits="${5}"
	if [[ ! "${moddigits}" =~ ${bfre_integer} ]]; then
		bf_errecho  "\-m reguires an integer got ${moddigits}"
		bf_wavexit
		exit 1
	fi

	modulus=$(echo "10 ^ ${moddigits}" | bc)
	bf_waverr "modulus=${modulus}"

	################################################################
	# This is where we create the dress design number as an N-digit
	# decimal number formed by taking the first (firsthex) and last
	# 4 (lasthex) hex characters of the cryptographic hash of the
	# dress image file.  Using the concatenation of these, we
	# convert that number to a decimal number and take the moddigits
	# of the decimal number.  Because of this shortening, I feared
	# that we would hit collisions.  There are enough parameters
	# to extend the precision until we don't get collisions.
	################################################################
	# Get the hash
	################################################################
	crypthash="$(openssl ${digestcommand} ${dressfilename})"

	################################################################
	# Strip off the openssl overhead
	################################################################
	newhash="${crypthash##*= }"

	################################################################
	# Now take the first four and last four hex digits and
	# concatenate them together.
	################################################################
	hexshort=$(echo "${newhash:0:${firsthex}}"
	hexshort="${hexshort}${newhash:$((-${lasthex})):${lasthex}}")

	################################################################
	# convert the hex number into a decimal number
	################################################################
	decimalfull=$(bf_hex2dec ${hexshort})

	################################################################
	# Now convert that hex number into a decimal number and trim it
	# down to the number of digits expressed in modulus
	# (see -m above).
	################################################################
	decimal=$(printf "%0${moddigits}d" $(( ${decimalfull} % ${modulus} )) )

	################################################################
	# return the result
	################################################################
	echo ${decimal}
}
