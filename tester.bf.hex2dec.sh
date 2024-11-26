#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
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
# 2.1 |REN|04/20/2024| changed to bf
# 2.0 |REN|08/24/2022| changed to bfunc
# 1.1 |REN|06/04/2022| testing hex2dec
# 1.0 |REN|03/20/2022| testing hex2dec
#_____________________________________________________________________

source bf.debug
source bf.hex2dec
source bf.regex
source bf.ansi_colors

#TESTNAME00="Test of function (bf.hex2dec) from"
#TESTNAME01="https://github.com/sailnfool/bf"
USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t\tVerifies that the function will convert hexadeximal numbers to
\t\tdecimal numbers\n
\t\tNormally emits only PASS|FAIL message\r\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see the diagnostic levels.\n
\t-h\t\tPrint this message\r\n
\t-v\t\tVerbose mode to show values\r\n
"

optionargs="d:hv"
verbosemode="FALSE"
fail=0

while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ $bfre_digit ]] ; then
				bf_errecho "${ansi_failstring} " \
					"-d requires a decimal " \
					"digit"
				bf_errecho -e ${USAGE}
				bf_errecho -e ${_BF_DEBUG_USAGE}
				exit 1
			fi
			_BF_DEBUG="${OPTARG}"
			export _BF_DEBUG
			if [[ $_BF_DEBUG -ge ${_DEBUGSETX} ]] ; then
				set -x
			fi
			;;
		h)
			echo -e ${USAGE}
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				bf_errecho -e ${_BF_DEBUG_USAGE}
			fi
			exit 0
			;;
		v)
			verbosemode="TRUE"
			;;
		\?)
			bf_errecho -e "invalid option: -$OPTARG"
			bf_errecho -e ${USAGE}
			exit 1
			;;
	esac
done

shift $(( ${OPTIND} - 1 ))
########################################################################
# More tests would be good
# tv short for testvalue
# tr short for testresult
########################################################################
declare -a tv
declare -a tr

tv[0]="00c"
tr[0]=12

tv[1]="00f"
tr[1]=15

tv[2]="0ff"
tr[2]=255

fail=0

########################################################################
# ti short for testindex
########################################################################
for ((ti=0;ti<${#tv[@]};ti++))
do
	if [[ "${verbosemode}" == "TRUE" ]] ; then
		echo "$(bf_hex2dec ${tv[${ti}]} ) should be " \
			"${tr[${ti}]}"
	fi

	if [[ ! "$(bf_hex2dec ${tv[${ti}]} )" == "${tr[${ti}]}" ]]
	then
		((fail++))
	fi
done

exit ${fail}
