#!/bin/bash
scriptname=${0##*/}
########################################################################
# copyright: (C) 2024 Robert E. Novak  All Rights reserved
# location: Bacolod, Negros Occidental 6100 Philippines
########################################################################
#
# tester.bf.regex Test the defined regex values for both valid and
#                    invalid arguments and check detection
#
# author: Robert E. Novak aka REN
# email: sailnfool@gmail.com
# licensor: Sea2Cloud Storage, Inc.
# licenseurl: https://creativecommons.org/licenses/by/4.0/legalcode
# licensename: Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.1 |REN|04/20/2024| Converted from tester.bfunc.regex to
#                    | tester.bf.regex
# 2.0 |REN|08/02/2022| Converted from tester.func.regex
# 1.1 |REN|06/04/2022| Tweaked to exit with number of fails and to
#                    | use arrays for test values and results
# 1.0 |REN|03/20/2022| testing regex
#_____________________________________________________________________

source bf.ansi_colors
source bf.debug
source bf.insufficient
source bf.kbytes
source bf.regex

#TESTNAME00="Test of function regex (bf.regex) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"
USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t\tVerifies that the regular expressions for integers, numbers,\n
\t\thexadecimal numbers, variable name and nicenumbers\n
\t\twork correctly.\n
\t\tNormally emits only PASS|FAIL message\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see the diagnostic levels.\n
\t-h\t\tPrint this message\n
\t-v\t\tVerbose mode to show values\n
"

localNUMARGS=0
optionargs="d:hv"
verbosemode="FALSE"
verboseflag=""
fail=0
_BF__DEBUG=0

while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ $bfre_digit ]] ; then
	    			bf_errecho "-d requires a " \
					"decimal digit"
	    			bf_errecho -e "${USAGE}"
	    			bf_errecho -e "${_BF_DEBUG_USAGE}"
				exit 1
			fi
			_BF_DEBUG="${OPTARG}"
			export _BF_DEBUG
			if [[ ${_BF_DEBUG} -ge \
				${_DEBUGSETX} ]] ; then
					set -x
			fi
			;;
		h)
			bf_errecho -e "${USAGE}" >&2
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				bf_errecho -e "${_BF_DEBUG_USAGE}" >&2
			fi
			exit 0
				;;
			v)
			verbosemode="TRUE"
			verboseflag="-v"
			;;
		\?)
			echo -e "invalid option: -$OPTARG" >&2
			echo -e "${USAGE}" >&2
			exit 1
			;;
	esac
done

shift $(( ${OPTIND} - 1 ))

if [[ $# -lt ${localNUMARGS} ]] ; then
	bf_insufficient ${localNUMARGS} $@
	echo -e "${USAGE}" >&2
	exit 2
fi

declare -a tv
declare -a tt
########################################################################
# tv is short for testvalue
# tt is short for testtype
########################################################################
tv+=("12345")
tt+=(${bfre_integer})

tv+=("+123")
tt+=(${bfre_signedinteger})

tv+=("-123")
tt+=(${bfre_signedinteger})

tv+=("-123.45")
tt+=(${bfre_decimal})

tv+=("face1")
tt+=(${bfre_hexnumber})

tv+=("DEADBeef9")
tt+=(${bfre_hexnumber})

tv+=("1M")
tt+=(${bfre_nicenumber})

tv+=("1MIB")
tt+=(${bfre_nicenumber})

tv+=("1BYT")
tt+=(${bfre_nicenumber})

tv+=("99ZIB")
tt+=(${bfre_nicenumber})

tv+=("Avariable1name")
tt+=(${bfre_variablename})

hash11result=$(sha512sum < /dev/null)
tv+=("01c:${hash11result:0:128}")
tt+=(${bfre_cryptohash})

hash12result=$(sha256sum < /dev/null)
tv+=("01c:${hash12result:0:64}")
tt+=(${bfre_cryptohash})

tv+=("/")
tt+=(${bfre_filedirname})

tv+=("//")
tt+=(${bfre_filedirname})

tv+=("///")
tt+=(${bfre_filedirname})

tv+=("/.")
tt+=(${bfre_filedirname})

tv+=("/./")
tt+=(${bfre_filedirname})

tv+=("/../.")
tt+=(${bfre_filedirname})

tv+=("/usr/bin/b3sum")
tt+=(${bfre_filedirname})

tv+=("/etc/dhcp/dhclient.conf")
tt+=(${bfre_filedirname})

tv+=("/etc/dhcp/dhclient-exit-hooks.d")
tt+=(${bfre_filedirname})

tv+=("/etc/gdm3/config-error-dialog.sh")
tt+=(${bfre_filedirname})


for ((ti=0; ti<${#tv[@]}; ti++))
do
	if [[ ! "${tv[${ti}]}" =~ ${tt[${ti}]} ]] ; then
		((fail++))
		echo -e "${ansi_failstring} got ${failstring} for " \
			"${tv[${ti}]}, " \
			"expected ${ansi_passstring}" >&2
	fi
done

declare -a fv
declare -a ft
########################################################################
# fv is short for failvalue
# ft is short for failtype
########################################################################
hash1result=$(b2sum < /dev/null)
fv+=("01:${hash1result:0:128}")
ft+=(${bfre_cryptohash})

fv+=("013variable")
ft+=(${bfre_variablename})

fv+=("/a bad/filename")
ft+=(${bfre_filedirname})

fv+=("/abad/file^name")
ft+=(${bfre_filedirname})

########################################################################
# In this case if the pattern match succeeds then it
# is broken
########################################################################
for ((ti=0; ti<${#fv[@]}; ti++))
do
	if [[ "${fv[${ti}]}" =~ ${ft[${ti}]} ]] ; then
		((fail++))
		echo -e "${ansi_failstring} got ${passstring} for " \
			"${fv[${ti}]}, " \
			"expected ${ansi_failstring}" >&2
	fi
done

exit ${fail}
