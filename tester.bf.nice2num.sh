#!/bin/bash
####################
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.0 |REN|06/26/2024| Converted from hard coded tables to generated
#                    | values on the fly
# 2.0 |REN|06/26/2024| Converted from func to bf
# 1.0 |REN|02/08/2022| testing nice2num
#_____________________________________________________________________
#
########################################################################
source bf.nice2num
source bf.errecho
source bf.kbytes

#TESTNAME00="Test of function nice2num (bf.nice2num) "
#TESTNAMELOC="https://github.com/sailnfool/bf"
USAGE="\n${0##*/} [-[hv]]\n
\t\tVerifies that the __kbytesvalue and __kbibytesvalue arrays have\n
\t\tcorrectly initialized.  Normally emits only PASS|FAIL message\n
\t-h\t\tPrint this message\n
\t-v\t\tVerbose mode to show values\n
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

########################################################################
# Converted from hard coded inline files to generated values on the fly
# using declared suffix arrays in kbytes source file
########################################################################
failure=0
if [[ ! "${#__kbytessuffix}" == "${#__kbibytessuffix[@]}" ]]; then
	((failure++))
	if [[ "${verbose_mode}" == "TRUE" ]]; then
		bf_errecho "kbytesuffix=${#__kbytessuffix}" \
			"count Does not match " \
			"kbibytessuffix=${#__kbibytessuffix[@]}"
	fi
fi
for ((kb_i=0; kb_i<${#__kbytessuffix}; kb_i++))
do
	################################################################
	# First test powers of 1000
	################################################################
	kb_bytesuffix=${__kbytessuffix:${kb_i}:1}

	value=$(echo "${1000}^${kb_i}" | bc)
	if [[ "$(nice2num 1${kb_bytesuffix})" != "${value}" ]]; then
		((failure++))
	fi
	if [[ "${verbose_mode}" == "TRUE" ]]; then
		bf_errecho -e "${suffix}\t$(nice2num 1${suffix})"
	fi

	################################################################
	# Next test powers of 1024
	################################################################
	kb_bibytesuffix=${__kbibytessuffix[${kb_i}]}
	value=$(echo "${1024}^${kb_i}" | bc)
	if [[ "$(nice2num 1${kb_bibytesuffix})" != "${value}" ]]; then
		((failure++))
	fi
	if [[ "${verbose_mode}" == "TRUE" ]]
	then
		echo -e "${suffix}\t$(nice2num 1${suffix})"
	fi
done # for suffix in ${nicepow1024suffix}
exit ${failure}
