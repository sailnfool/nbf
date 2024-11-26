#!/bin/bash
####################
# Copyright (C) 2022 Sea2cloud
# Bacolod City, Negros Oriental 6100 Philippines
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|02/08/2022| Converted from bfunc to bf
# 1.1 |REN|02/08/2022| Restructured to use arrays
# 1.0 |REN|02/01/2022| testing reconstructed kbytes
#_____________________________________________________________________
#
########################################################################
source bf.errecho
source bf.os

#TESTNAME00="Test of functions bf_os and bf_arch (bf.os) "
#TESTNAMELOC="https://github.com/sailnfool/bf"
USAGE="\n${0##*/} [-[hv]]\n
\t\tVerifies that functions bf_os and bf_arch work.\n
\t\tNormally emits only PASS|FAIL message\n
\t-h\t\tPrint this message\n
\t-v\t\tVerbose mode to show values\n
"

optionargs="hv"
verbose_mode="FALSE"
failure=0

while getopts ${optionargs} name
do
	case ${name} in
	h)
		echo -e ${USAGE}
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

if [[ -z "${__funcos}" ]]
then
	bf_errecho -i "funcos not found"
	((failure++))
	exit ${failure}
fi
if [[ ! -f /etc/os-release ]]
then
	bf_errecho -i "/etc/os-release not found are you on a Debian OS?"
	((failure++))
	exit ${failure}
fi
check_os=$(sed -ne '/^ID=/s/^ID=\(.*\)$/\1/p' < /etc/os-release)
if [[ "${verbose_mode}" == "TRUE" ]]
then
	echo -e "Operating system check \"${check_os}\" vs. \"$(bf_os)\""
	echo -e "Architecture check \"$(uname -m)\" vs. \"$(bf_arch)\""
fi
if [[ "${check_os}" != "$(bf_os)" ]] 
then
	bf_errecho -i "Operating system mismatch \"${check_os}\" vs. \"$(bf_os)\""
	((failure++))
fi
if [[ "$(uname -m)" != "$(bf_arch)" ]]
then
	bf_errecho -i "Architecture mismatch \"$(uname -m)\" vs. \"$(bf_arch)\""
	((failure++))
fi
exit ${failure}
