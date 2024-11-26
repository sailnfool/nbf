#!/bin/bash
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
########################################################################
#scriptname     :globalorthodox
#description00  :Set up arrays of orthodox mappings with associative
#description01  :mappings for
#description02  :hash2OID - map a short hash name to an orthodox
#description03  :           ID Number for a hash function
#description04  :OID2bin - Map and Orthodox ID number for a hash
#description05  :          function to the full local path with
#description06  :          arguments to the executable
#description07  :OID2bits - For a given OID the number of bits 
#description08  :           of OID has generated
#description09  :OID2hex - For a given OID the number of hexadecimal
#description10  :          digits (OID2bits * _HEXBITS)
#description11  :OID2hash - Map an OID to the short hash name that
#description12  :           identifies the cryptographic hash program
#args           :N/A
#
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licenserul     :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#More info on orthodox Hash Encoding
#attributionurl :https://www.linkedin.com
#attributionpath:/posts
#attributionfile:/sailnfool_activity-6937946456754466817-Cy--
#attributionlink:?utm_source=linkedin_share
#attrbutionmem  :&utm_medium=member_desktop_web
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.1 |REN|08/15/2022| Added hash2OCH_by.... to help avoid the
#                    | accidental invocation of the wrong hash
#                    | function
# 2.0 |REN|08/08/2022| Switched to bf and to Orthodox
# 1.0 |REN|07/29/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__globalorthodox}" ]] ; then
	export __globalorthodox=1

	source yfunc.global
	source bf.os

	################################################################
	# A constant to convert number of hash bits to the number of 
	# hex digits to represent those bits
	################################################################
	export _HEXBITS=4

	################################################################
	# This needs a bit of explaining.  Kind of like apparmor we
	# are making sure that we are getting the correct binary.
	# for example, b2sum has two different instances:
	# 1) found in GNU coreutils which does not support the
	#    different flavors of Blake2, but only blake2b
	# 2) the version of b2sum found as FOSS on github which
	#    supports blake2s, blake2b and blake2bp
	# The table that maps a short hash name to an OCH (Orthodox
	# Cryptographic Hash) has to be different for each linux
	# Flavor (e.g., Red Hat, Centos, Debian), each different OS
	# (e.g., Ubuntu, Tecmint, etc.), each different OS release
	# (e.g., 21.10, 21.04) and each different architecture
	# (e.g., x86, ARM, RISC-V, PowerPC, MIPS, etc.).
	# We don't do anything fancy here except to collect this
	# as the name of the file which will map a short hash name
	# to a cryptographic hash of the desired binary.  We create
	# the mapping on this machine.  Ideally, we would be able to
	# consult some global website which would contain definitive
	# identifications of this hash value.  This will not only
	# prevent accidental use of the wrong binary, but can detect
	# if your cryptographic hash function has been corrupted or
	# tampered with.  This is NOT a secure implementation. A
	# great deal more work would need to be done to verify
	# the values found on a machine against a signed authoritative
	# list on a global website.
	################################################################
#	__Flavor=$(bf_idlike)
#	__OS=$(bf_os)
#	__Version=$(bf_os_version_id)
#	__Arch=$(bf_arch)
	__FOVA="$(bf_idlike)_$(bf_os)_$(bf_os_version_id)"
	__FOVA="${__FOVA}_$(bf_arch)"
	declare -A OID2OCH_by_${__FOVA}
	declare -A hash2OID
	declare -A OID2hash
	declare -A OID2bin
	declare -A OID2bits
	declare -A OID2hex
	declare -A OID2path
	declare -A OID2args
	export OID2OCH_by_${__FOVA}
	export hash2OID
	export OID2hash
	export OID2bin
	export OID2bits
	export OID2hex
	export OID2path
	export OID2args
	declare -n OID2OCH=OID2OCH_by_${__FOVA}
	export OID2OCH

	################################################################
	# declare the full name of the source file
	################################################################
	export orthodoxhashfile="orthodox_source.csv"

	declare -a OIDarrays
	OIDarrays+=("OID2OCH_by_${__FOVA}")
	OIDarrays+=("hash2OID")
	OIDarrays+=("OID2hash")
	OIDarrays+=("OID2bin")
	OIDarrays+=("OID2bits")
	OIDarrays+=("OID2hex")
	OIDarrays+=("OID2path")
	OIDarrays+=("OID2args")

	export OIDarrays

	################################################################
	# The following array puts the descriptive usage phrases for
	# these associative arrays and the files that contain their
	# contents into an array of associative strings so that the
	# definitions of these usage strings are kept close to the
	# declarations of the arrays.  You will note that at the end
	# of this we add a function that will neatly print this
	# information that can be added to the scripts that use these
	# and can be displayed when verbose help is requested.
	################################################################
	declare -A U_OIDarrays
	U_OIDarrays+=(["OID2OCH_by_${__FOVA}"]="OID to OCH of the binary")
	U_OIDarrays+=(["hash2OID"]="short hash name to OID index")
	U_OIDarrays+=(["OID2hash"]="index to short hash name")
	U_OIDarrays+=(["OID2bin"]="OID index to exec short name")
	U_OIDarrays+=(["OID2bits"]="OID index to hash bits\t")
	U_OIDarrays+=(["OID2hex"]="OID index to hash hex digits")
	U_OIDarrays+=(["OID2path"]="OID index to full exec path")
	U_OIDarrays+=(["OID2args"]="OID index to exec args\t")

	export U_OIDarrays

	usage_orthodox() {
		local aaray

		echo -n -e "\tAbbreviations:
\t\tOID\tOrthodox ID - a sequential number assigned to a
\t\t\thash with given parameters
\t\tOCH\tOrthodox Cryptographic Hash
\t\t\tThe default hash (using sha512sum) for the binary
\t\t\twhich is used for a particular OID

\tThe default files are:
" >&2

		for aaray in "${OIDarrays[@]}"
		do
			echo -e "${U_OIDarrays[${aaray}]}\t${aaray}" >&2
		done
		echo -n -e "
\tin the same directory as the source file, typically:
\t${YesFSdiretc}
\tfiles specific to this machine are place in a subdirectory
\tnamed for the host:$(hostname). Use -vh for more info.

\tThen these files are loaded into the
\tsame directory as the source file

\tNote that:
\tOID2OCH_by_${__FOVA}.csv
\tbelongs in a separate
\t\t${__FOVA}
\tsubdirectory.  Several hosts may share the same binary
\twhich is a function of the (FOVA):
\t\tFlavor\t$(bf_idlike)
\t\tOS\t$(bf_os)
\t\tVersion\t$(bf_os_version_id)
\t\tArch\t$(bf_arch)

" >&2
	}
	export -f usage_orthodox


fi # if [[ -z "${__globalorthodox}" ]]
