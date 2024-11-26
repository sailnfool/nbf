#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod, Negros Occidental, 6100 Philippines
########################################################################
#scriptname     :tester.bf.stripquotes
#description    :test the stripquotes function for errors
#args           :
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#attribution01	:https://github.com/dylanaraps/pure-bash-bible
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.1 |REN|04/20/2024| Converted to bf
# 1.0 |REN|08/24/2022| Initial Release
#_____________________________________________________________________

source bf.cwave
source bf.insufficient
source bf.regex
source bf.stripquotes

#TESTNAME00="Test of string function (bf.stripquotes.sh) from "
#TESTNAMELOC="https://github.com/sailnfool/bf"

local_NUMARGS=1
verbosemode="FALSE"
verboseflag=""
_BFUNC_DEBUG=${_DEBUGOFF}
failcode=0

USAGE="\n${0##*/} [-hv] [-d <#>]\n
\t\tTesting bf_split function\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see debug modes/levels\n
\t-h\t\tPrint this message\n
\t-v\t\tTurn on verbose mode\n
"
optionargs="d:hv"
while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ $re_digit ]]
			then
				bf_errecho -e "${USAGE}"
				bf_errecho -e "${_BF_DEBUG_USAGE}"
				exit 1
			fi
			_BFUNC_DEBUG="${OPTARG}"
			export _BFUNC_DEBUG
			if [[ ${_BF_DEBUG} -ge ${_DEBUGNOEX} ]] ; then
				set -v
			fi
			;;
		h)
			echo -e "${USAGE}"
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				bf_errecho -e "${_BF_DEBUG_USAGE}"
			fi
			exit 0
			;;
		v)
			verbosemode="TRUE"
			verboseflag="-v"
			;;
		\?)
			echo -e "invalid option: -${OPTARG}" >&2
			echo -e "${USAGE}" >&2
			exit 1
			;;
	esac
done

shift $((OPTIND-1))

########################################################################
# More tests would be good
# tv short for testvalue
# tr short for testresult
########################################################################
declare -a tv
declare -a tr

tv[0]="\"test \\ \" end \""
tr[0]='\"test \\ \" end \"'

tv[1]=test
tr[1]=test

tv[2]=\"test
tr[2]=\"test

tv[3]='test\"'
tr[3]='test\"'

fail=0

########################################################################
# ti short for testindex
########################################################################
for ((ti=0;ti<${#tv[@]};ti++))
do
	if [[ "${verbosemode}" == "TRUE" ]] ; then
		echo "$(bf_stripquotes ${tv[${ti}]} ) should be " \
			"${tr[${ti}]}"
	fi

	if [[ ! "$(bf_stripquotes ${tv[${ti}]} )" == "${tr[${ti}]}" ]]
	then
		((fail++))
	fi
done

exit ${fail}
