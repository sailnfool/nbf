#!/bin/bash
####################
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|02/08/2022| testing nice2num
#_____________________________________________________________________
#
########################################################################
source bf.kbytes
source bf.num2nice
source bf.nice2num
source bf.errecho

#TESTNAME00="Test of function num2nice (bf.num2nice) "
#TESTNAMELOC="https://github.com/sailnfool/bf"
USAGE="\r\n${0##*/} [-[hv]]\r\n
\t\tVerfies that a large number can be successfully be converted to a\r\n
\t\tnice number respresentation\r\n
\r\n
\t\tNormally exits with 0 (PASS) or 1 (FAIL)
\t-h\t\tPrint this message\r\n
\t-v\t\tVerbose mode to show values\r\n
"

optionargs="hv"
verbose_mode="FALSE"
failure="FALSE"

while getopts ${optionargs} name
do
	case ${name} in
	h)
		bf_errecho -e ${USAGE}
		exit 0
		;;
	v)
		verbose_mode="TRUE"
		;;
	\?)
		bf_errecho "-e" "invalid option: -$OPTARG"
		bf_errecho "-e" ${USAGE}
		exit 1
		;;
	esac
done
failure=0
for ((i=998;i<1024;i++))
do
	for ((j=0;j<${#__kbytessuffix};j++))
	do
		nicenumber="${i}${__kbytessuffix:${j}:1}"
		number=$(nice2num "$i${__kbytessuffix:$j:1}" )
		if [[ "${nicenumber}" == "$(num2nice $(nice2num ${nicenumber}) )" ]];
		then
			((failure++))
		fi
		if [[ "${verbose_mode}" == "TRUE" ]]; then
			br_errecho "Failure for ${nicenumber}"
		fi
	done # for ((j=0;j<${#__kbytessuffix};j++))
done # for ((i=998;i<1024;i++))
exit ${failure}
