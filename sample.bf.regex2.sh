#!/bin/bash
scriptname=${0##*/}

bfre_filedirname='^([\/-_A-Za-z1-9\.]+[-_A-Za-z0-9\.]*)*$'

#TESTNAME00="Test of function regex (bf.regex) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"
USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t\tVerifies that the regular expression(s for filedirnames\n
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

while getopts ${optionargs} name
do
	case ${name} in
		h)
			echo -e "${USAGE}" >&2
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				echo -e "${DEBUG_USAGE}" >&2
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
	echo -e "${0##*/} Insufficient arguments, expcted "\
		"${localNUMARGS}, got $@" >&2
	echo -e "${USAGE}" >&2
	exit 2
fi

declare -a tv
declare -a tt
########################################################################
# tv is short for testvalue
# tt is short for testtype
########################################################################
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
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			echo -e "Failed Test of ${tv[${ti}]}, " \
				"expected ${tt[${ti}]}" >&2
		fi
	fi
done

declare -a fv
declare -a ft
########################################################################
# fv is short for failvalue
# ft is short for failtype
########################################################################
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
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			echo -e "Failed Test succeeded with "\
				"${fv[${ti}]},\n" \
				"expected fail for ${ft[${ti}]}" >&2
		fi
	fi
done

exit ${fail}
