#!/bin/bash
#########################################################################
# Copyright (C) 2023 Robert E. Novak  All Rights Reserved
# Cebu, Philippines 6000
########################################################################
# multiple functions to support openssl opetations
#
#_____________________________________________________________________
# bf_sslmacverify: Returns "true" (0) if the argument is in openssl
#arg - digest   : The name of a hash digest to be verified
#_____________________________________________________________________
# bf_sslmacbits : Return the integer number of bits generated by the
#               : argument #1 - AKA digest
#arg - digest   : The name of a hash digest supported in openssl
#_____________________________________________________________________
# bf_sslmachexdigits : Return the integer number of hexadecimal
#               : digits returned by the argument #1 - AKA
#               : digestname
#arg - digestname : The name of a hash digest supported in
#               : openssl
#_____________________________________________________________________
# bf_sslmacoptions : generate the openssl options for the maximum
#               : strength digest
#arg - digestname : The name of a hash digest supported in
#               : openssl
#_____________________________________________________________________
#
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.2 |REN|10/16/2029| added documentation and re-ordered functions
# 1.1 |REN|10/06/2023| added bf_sslmacverify
# 1.0 |REN|10/02/2023| Initial Release, a rework of an older paradigm
#                    | of assigning a canonical set of numbers to
#                    | cryptographic hash programs that are tied to
#                    | a process of generating hashes toward a One
#                    | Time Pad.  The whole process was re-done when
#                    | openssl created definitions of a set of message
#                    | authentication codes.  There is a whole lot to
#                    | learn about HMAC vs. KMAC codes.  This is just
#                    | simple algorithm to find the number of bits
#                    | that are generated by an HMAC.
#_____________________________________________________________________
# The following wrapper assumes that this is included in a "source"
# statement and needs guarding against possible multiple includes due
# to nesting
if [[ -z "${__bf_sslmacbits}" ]] ; then
	export __bf_sslmacbits=1

	source bf.cwave
	source bf.errecho
	source bf.insufficient
	source bf.regex

	################################################################
	# bf_sslmacverify: Returns "true" (0) if the argument is in
	# openssl
	#arg - digest   : The name of a hash digest to be verified
	################################################################
	function bf_sslmacverify ()
	# bf_sslmacverify digest
	{
	
		local digestname
		local localNUMARGS=1
		local hashverifyresult

		bf_waventry
		########################################################
		# Now verify that we have a hash program loaded on
		# openssl on this machine.
		########################################################
		if [[ $# -lt ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit
			exit 1
		fi
		digestname=$1

		########################################################
		# Verify that openssl is installed
		########################################################
		command -v openssl > /dev/null
		whichresult=$?
		if [[ "${whichresult}" -eq "1" ]] ; then
			bf_errecho "Requesting elevated privileges " \
				"install openssl"
			sudo apt-get install openssl
		fi
		openssl list -digest-commands -1 | \
			grep "^${digestname}\$" > /dev/null
		hashverifyresult=$?
		bf_wavexit
		return ${hashverifyresult}
	}
	export -f bf_sslmacverify

	################################################################
	# bf_sslmacbits : Return the integer number of bits generated
	#               : by the argument #1 - AKA digestname
	#arg - digestname : The name of a hash digest supported in
	#               : openssl
	################################################################
	function bf_sslmacbits()
		# sslmacbits [-v] digestname
	{
		########################################################
		# The name of the digest as arg #1.
		########################################################
		local digestname

		########################################################
		# The number of arguments and verbose mode
		########################################################
		local localNUMARGS=1
		local verbosemode="FALSE"
		local verboseflag=""

		########################################################
		# A constant to convert number of digest hex characters
		# to the number of bits generated by a digest or
		# vice-versa
		########################################################
		local CHEXBITS=4

		########################################################
		# The digest generated from openssl and the hex string
		# extracted from that.
		########################################################
		local digest
		local digesthex
		
		bf_waventry

		########################################################
		# Check for a "-v" flag
		########################################################
		if [[ $# -gt ${localNUMARGS} ]] && [[ "$1" == "-v" ]]
		then
			verbosemode="TRUE"
			verboseflag="-v"
			_BF_DEBUG=${_DEBUGWAVAR}
			shift
		fi

		if [[ ! $# == ${localNUMARGS} ]]; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit
			exit 1
		fi
		digestname=$1

		########################################################
		# Use the installed copy of openssl to verify the
		# information start by verifying openssl is installed
		########################################################
		command -v openssl > /dev/null
		if [[ ! $? ]]; then
			bf_errecho "openssl appears to be missing"
			bf_errecho "Privileged retrieval of openssl"
			sudo apt-get install openssl
		fi
	
		########################################################
		# Verify that the requested digest exists in the
		# installed copy of openssl.
		########################################################
		bf_sslmacverify ${verboseflag} ${digestname}
		if [[ ! $? ]]; then
			bf_errecho "${digestname} not installed in "\
				"openssl"
			bf_wavexit
			exit 2
		fi
	
		########################################################
		# generate the invocation of openssl for digestname
		# this is important since some openssl hash digests
		# need to have their output size specified different
		# from the digest used for verification.
		########################################################
		chkopenssl="$(bf_sslmacoptions ${digestname})"

		if [[ "${verbosemode}" == "TRUE" ]] ; then
			bf_wave ${chkopenssl}
		fi
	
		########################################################
		# Now we have the correct invocation of openssl for
		# each digest invoke the digest on "Hello World"
		# string and get the result
		########################################################
		digest=$(${chkopenssl} <<< "Hello World" )
	
		########################################################
		# The resulting string in digest contains a string with
		# the uppercase name of the digest, the file name
		# (in this case stdin) in  parentheses, followed by
		# an "= " string and then the hex digits that compose
		# the digest.  E.G.
		# SHA256(/etc/hosts)= 878ab7da...cb0f648b
		# So we use a nice pattern match to strip off the
		# unwanted characters at the front.
		########################################################
		digesthex=${digest##*= }

		########################################################
		# Verify that we only got hexadecimal digits back
		########################################################
		if [[ ! ${digesthex} =~ ${bfre_hexnumber} ]] ; then
			bf_errecho "Digest ${digesthex} is not a " \
				"hex number"
			bf_wavexit
			exit 1
		fi
	
		########################################################
		# Now we count the number of hex generated digits and
		# convert that to the number of bits generated
		########################################################
		bf_wavexit
		echo "$((${#digesthex} / ${CHEXBITS}))"
	}
	export -f bf_sslmacbits

	################################################################
	# bf_sslmachexdigits : Return the integer number of hexadecimal
	#               : digits returned by the argument #1 - AKA
	#               : digestname
	#arg - digestname : The name of a hash digest supported in
	#               : openssl
	################################################################

	function bf_sslmachexdigits ()
		# bf_sslmachexbits digestname
	{
		local digestname
		########################################################
		# A constant to convert number of digest hex characters
		# to the number of bits generated by a digest or
		# vice-versa
		########################################################
		local CHEXBITS=4
		local macbits

		bf_waventry
		if [[ ! $# == 1 ]]; then
			bf_errecho "missing digest name"
			bf_wavexit
			exit 1
		fi
		digestname=$1
		macbits=$(bf_sslmacbits ${digestname})
		echo "$(( macbits * CHEXBITS ))"
		bf_wavexit
	}
	export -f bf_sslmachexdigits

	################################################################
	# bf_sslmacoptions : generate the openssl options for the
	#       : maximum strength digest
	#arg - digestname : The name of a hash digest supported in
	#       : openssl
	################################################################
	function bf_sslmacoptions ()
	#	bf_sslmacoptions digestname
	{
		local digestname
		local chkopenssl
		local localNUMARGS=1

		bf_waventry
		if [[ ! $# == ${localNUMARGS} ]]; then
			bf_insufficient ${localNUMARGS} $@
			bf_wavexit
			exit 1
		fi
		digestname=$1
	
		########################################################
		# Make sure that openssl generates the strongest
		# digest for the shake digests (see -xoflen):
	# https://www.openssl.org/docs/man3.0/man1/openssl-dgst.html
		########################################################
		chkopenssl="openssl ${digestname} -hex"
		case ${digestname} in
			shake128)
				chkopenssl="${chkopenssl} -xoflen 32"
				;;
			shake256)
				chkopenssl="${chkopenssl} -xoflen 64"
				;;
		esac
		echo "${chkopenssl}"
		bf_wavexit
	}
	export -f bf_sslmacoptions
fi # if [[ -z "${__bf_sslmacbits}" ]]
