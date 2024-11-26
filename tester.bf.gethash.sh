#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Cebu Philippines
########################################################################
#scriptname     :tester.bf.gethash
#description    :test the bf_gethash function for errors
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
# 1.0 |REN|07/07/2023| Initial Release
#_____________________________________________________________________

source bf.cwave
source bf.insufficient
source bf.regex
source bf.split
source bf.gethash
source bf.gethashtype
source bf.gethashvalue

#TESTNAME00="Test of hash function (bf.gethash.sh) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"

local_NUMARGS=0
verbosemode="FALSE"
verboseflag=""
_BFUNC_DEBUG=${_DEBUGOFF}
failcode=0
declare -a cleanuplist
declare -A testfile
declare -A resultfile

USAGE="\n${0##*/} [-hv] [-d <#>]\n
\t\tTesting bf_gethash function\n
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
				echo -e "${USAGE}" >&2
				echo -e "${_BDEBUG_USAGE}" >&2
				exit 1
			fi
			_BFUNC_DEBUG="${OPTARG}"
			export _BFUNC_DEBUG
			if [[ ${_BFUNC_DEBUG} -ge ${_DEBUGNOEX} ]] ; then
				set -v
			fi
			;;
		h)
			echo -e "${USAGE}"
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				echo -e "${_BDEBUG_USAGE}" >&2
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

if [[ $# -lt ${NUMARGS} ]] ; then
	insufficient ${NUMARGS} $@
	echo -e "${USAGE}" >&2
	exit 2
fi

bf_waventry
########################################################################
# Create the "here" files to check the output
########################################################################
testname="fruit"
testfile[${testname}]="/tmp/${0##*/}_${testname}_$$"
cleanuplist+=("${testfile[${testname}]}")
cat > "${testfile[${testname}]}" <<EOFfruit
apples
oranges
pears
grapes
EOFfruit


for tn in "${!testfile[@]}"
do
	bf_waverr "testfile[${tn}] = ${testfile[${tn}]}"
done

#simple tests
#fruit
testname=fruit
resultfile[${testname}]="/tmp/${0##*/}_${testname}_result_$$"
cleanuplist+=("${resultfile[${testname}]}")
bf_hashvalue Blake2b ${testfile[${testname}]} \
  > ${resultfile[${testname}]}
if [[ "${verboseflag}" == "TRUE" ]]; then
  cat ${resultfile[${testname}]}
fi
bf_waverr "Checking ${testname}"
bf_waverr "testfile[${testname}]" "resultfile[${testname}]"
bf_waverr "diff ${testfile[${testname}]}" "${resultfile[${testname}]}"
diff "${testfile[${testname}]}" "${resultfile[${testname}]}"
result=$?
if [[ ! "${result}" == 0 ]] ; then ((fail++)); fi

for filename in "${cleanuplist[@]}"
do
	bf_waverr "Removing ${filename}"
	rm -f ${filename}
done

bf_wavexit
exit ${result}
if [[ ! "${result}" ]] ; then ((fail++)); fi
