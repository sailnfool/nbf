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
# 3.0 |REN|09/13/2022| Added compression and uncompression
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
	declare -A OID2bits
	declare -A OID2hex
	declare -A OID2path
	declare -A OID2args
	export OID2OCH_by_${__FOVA}
	export hash2OID
	export OID2hash
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

	################################################################
	# Like above, but this is to handle a set of compression and
	# uncompression routines.  These routines don't need bits or 
	# counts of hexdigits.  Unlike above (and this may change in
	# the above there are no "bin" and "path" as separate args.  We
	# will only consider path and always invoke by the path, but we
	# will also verify the path's hash before invoking.
	################################################################
	declare -A CID2OCH_by_${__FOVA}
	declare -A comp2CID
	declare -A CID2comp
	declare -A CID2uncomp
	declare -A CID2path
	declare -A CID2args
	export CID2OCH_by_${__FOVA}
	export comp2CID
	export CID2comp
	export CID2uncomp
	export CID2path
	export CID2args
	declare -n CID2OCH=CID2OCH_by_${__FOVA}
	export CID2OCH
	
	export compressioncapfile="compression_source.csv"

	declare -a CIDarrays
	CIDarrays+=("CID2OCH_by_${__FOVA}")
	CIDarrays+=("comp2CID")
	CIDarrays+=("CID2comp")
	CIDarrays+=("CID2uncomp")
	CIDarrays+=("CID2path")
	CIDarrays+=("CID2args")

	export CIDarrays

	declare -A U_CIDarrays
	U_CIDarrays+=(["CID2OCH_by_${__FOVA}"]="CID to OCH of the binary")
	U_CIDarrays+=(["comp2CID"]="short compression name to CID index")
	U_CIDarrays+=(["CID2comp"]="index to short compression name")
	U_CIDarrays+=(["CID2uncomp"]="index to short uncompression name")
	U_CIDarrays+=(["CID2path"]="CID index to full exec path")
	U_CIDarrays+=(["CID2args"]="CID index to exec args\t")

	export U_CIDarrays

	usage_compression() {
		local aaray

		echo -n -e "\tAbbreviations:
\t\tCID\tCompression ID - a sequential number assigned to a
\t\t\tcapability with given parameters
\t\tOCH\tOrthodox Cryptographic Hash
\t\t\tThe default hash (using sha512sum) for the binary
\t\t\twhich is used for a particular CID

\tThe default files are:
" >&2

		for aaray in "${CIDarrays[@]}"
		do
			echo -e "${U_CIDarrays[${aaray}]}\t${aaray}" >&2
		done
		echo -n -e "
\tin the same directory as the source file, typically:
\t${YesFSdiretc}
\tfiles specific to this machine are place in a subdirectory
\tnamed for the host:$(hostname). Use -vh for more info.

\tThen these files are loaded into the
\tsame directory as the source file

\tNote that:
\tCID2OCH_by_${__FOVA}.csv
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
	export -f usage_compression

	
	################################################################
	# Now we do the same for uncompression
	################################################################
	declare -A UID2OCH_by_${__FOVA}
	declare -A uncomp2UID
	declare -A UID2uncomp
	declare -A UID2comp
	declare -A UID2path
	declare -A UID2args
	export UID2OCH_by_${__FOVA}
	export uncomp2UID
	export UID2uncomp
	export UID2comp
	export UID2path
	export UID2args
	declare -n UID2OCH=UID2OCH_by_${__FOVA}
	export UID2OCH

	export uncompressioncapfile="uncompression_source.csv"

	declare -a UIDarrays
	UIDarrays+=("UID2OCH_by_${__FOVA}")
	UIDarrays+=("uncomp2UID")
	UIDarrays+=("UID2comp")
	UIDarrays+=("UID2uncomp")
	UIDarrays+=("UID2path")
	UIDarrays+=("UID2args")

	export UIDarrays

	declare -A U_UIDarrays
	U_UIDarrays+=(["UID2OCH_by_${__FOVA}"]="UID to OCH of the binary")
	U_UIDarrays+=(["uncomp2UID"]="short uncompression name to UID index")
	U_UIDarrays+=(["UID2uncomp"]="index to short uncompression name")
	U_UIDarrays+=(["UID2comp"]="index to short compression name")
	U_UIDarrays+=(["UID2path"]="UID index to full exec path")
	U_UIDarrays+=(["UID2args"]="UID index to exec args\t")

	export U_UIDarrays

	usage_uncompression() {
		local aaray

		echo -n -e "\tAbbreviations:
\t\tUID\tUncompression ID - a sequential number assigned to a
\t\t\tcapability with given parameters
\t\tOCH\tOrthodox Cryptographic Hash
\t\t\tThe default hash (using sha512sum) for the binary
\t\t\twhich is used for a particular UID

\tThe default files are:
" >&2

		for aaray in "${UIDarrays[@]}"
		do
			echo -e "${U_UIDarrays[${aaray}]}\t${aaray}" >&2
		done
		echo -n -e "
\tin the same directory as the source file, typically:
\t${YesFSdiretc}
\tfiles specific to this machine are place in a subdirectory
\tnamed for the host:$(hostname). Use -vh for more info.

\tThen these files are loaded into the
\tsame directory as the source file

\tNote that:
\tUID2OCH_by_${__FOVA}.csv
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
	export -f usage_uncompression

fi # if [[ -z "${__globalorthodox}" ]]
