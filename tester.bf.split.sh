#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod, Negros Occidental, 6100 Philippines
########################################################################
#scriptname     :tester.bf.split
#description    :test the bf_split function for errors
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
# 1.1 |REN|04/20/2024| Changed bfunc to bf
# 1.0 |REN|08/05/2022| Initial Release
#_____________________________________________________________________

source bf.cwave
source bf.insufficient
source bf.regex
source bf.split

#TESTNAME00="Test of hash function (bf.script.sh) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"

local_NUMARGS=1
verbosemode="FALSE"
verboseflag=""
_BFUNC_DEBUG=${_DEBUGOFF}
failcode=0
declare -a cleanuplist
declare -A testfile
declare -A resultfile

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

testname="numbers"
testfile[${testname}]="/tmp/${0##*/}_${testname}_$$"
cleanuplist+=("${testfile[${testname}]}")
cat > ${testfile[${testname}]} <<EOFnumbers
1
2
3
4
5
EOFnumbers

testname="multi"
testfile[${testname}]="/tmp/${0##*/}_${testname}_$$"
cleanuplist+=("${testfile[${testname}]}")
cat > ${testfile[${testname}]} <<EOFmulti
hello
world
my
name
is
john
EOFmulti

testname="multi2"
testfile[${testname}]="/tmp/${0##*/}_${testname}_$$"
cleanuplist+=("${testfile[${testname}]}")
cat > ${testfile[${testname}]} <<EOFmulti2
hello
world
my
name
is
john
EOFmulti2

for tn in "${!testfile[@]}"
do
	bf_waverr "testfile[${tn}] = ${testfile[${tn}]}"
done

#simple tests
#fruit
testname=fruit
resultfile[${testname}]="/tmp/${0##*/}_${testname}_result_$$"
cleanuplist+=("${resultfile[${testname}]}")
bf_split "apples,oranges,pears,grapes" \
	"," \
	> "${resultfile[${testname}]}"
bf_waverr "Checking ${testname}"
bf_waverr "testfile[${testname}]" "resultfile[${testname}]"
bf_waverr "diff ${testfile[${testname}]}" "${resultfile[${testname}]}"
diff "${testfile[${testname}]}" "${resultfile[${testname}]}"
result=$?
if [[ ! "${result}" == 0 ]] ; then ((fail++)); fi

#numbers
testname=numbers
resultfile[${testname}]="/tmp/${0##*/}_${testname}_result_$$"
cleanuplist+=("${resultfile[${testname}]}")
bf_split "1, 2, 3, 4, 5" \
	", " \
	> "${resultfile[${testname}]}"
bf_waverr "Checking ${testname}"
diff "${testfile[${testname}]}" "${resultfile[${testname}]}"
result=$?
if [[ ! "${result}" == 0 ]] ; then ((fail++)); fi


# Multi char delimiters work too!
testname=multi
resultfile[${testname}]="/tmp/${0##*/}_${testname}_result_$$"
cleanuplist+=("${resultfile[${testname}]}")
bf_split "hello---world---my---name---is---john" \
	"---" \
	> "${resultfile[${testname}]}"
bf_waverr "Checking ${testname}"
diff "${testfile[${testname}]}" "${resultfile[${testname}]}"
result=$?
if [[ ! "${result}" == 0 ]] ; then ((fail++)); fi

# retest multi with IFS
# Multi char delimiters work too!
IFS=" "
saveIFS="${IFS}"
testname=multi2
resultfile[${testname}]="/tmp/${0##*/}_${testname}_result_$$"
cleanuplist+=("${resultfile[${testname}]}")
bf_split "hello---world---my---name---is---john" \
	"---" \
	> "${resultfile[${testname}]}"
bf_waverr "Checking ${testname}"
diff "${testfile[${testname}]}" "${resultfile[${testname}]}"
result=$?
if [[ ! "${result}" == 0 ]] ; then ((fail++)); fi
if [[ ! "${IFS}" == "${saveIFS}" ]]
then
	echo "${failtest} ${0##*/} failed IFS test" >&2
fi

for filename in "${cleanuplist[@]}"
do
	bf_waverr "Removing ${filename}"
	rm -f ${filename}
done

bf_wavexit
exit ${result}
if [[ ! "${result}" ]] ; then ((fail++)); fi
