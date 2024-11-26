#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
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
# 1.2 |REN|04/20/2024| Converted to bf.
# 1.1 |REN|07/15/2022| Converted to bfunc.
# 1.0 |REN|07/15/2022| testing hash.createcanonical
#_____________________________________________________________________
#
########################################################################

source bf.createorthodox
source bf.keyvalueload
source bf.keyvaluedump
source bf.debug
source bf.regex

#TESTNAME00="Test of hash script (bf.createorthodox.sh) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"

USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see debug modes/levels\n
\t-h\t\tPrint this message\r\n
\t-v\t\tVerbose mode to show values\r\n
\t\tNormally emits only PASS|FAIL message\r\n
"

optionargs="d:hv"
verbosemode="FALSE"
verboseflag=""
_BF_DEBUG=${_DEBUGOFF}
fail=0

while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ ${bfre_digit} ]] ; then
				bf_errecho "${0##/*}" "${LINENO}" \
					"-d requires a decimal " \
					"digit"
				bf_errecho -e "${USAGE}"
				bf_errecho -e "${DEBUG_USAGE}"
				exit 1
			fi
			_BF_DEBUG="${OPTARG}"
			export _BF_DEBUG
			if [[ "${_BF_DEBUG}" -ge "${_DEBUGSETX}" ]]
			then
				set -x
			fi
			;;
		h)
			bf_errecho -e ${USAGE}
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				bf_errecho -e ${DEBUG_USAGE}
			fi
			exit 0
			;;
		v)
			verbosemode="TRUE"
			;;
		\?)
			bf_errecho -e "invalid option: -$OPTARG"
			bf_errecho -e "${USAGE}"
			exit 1
			;;
	esac
done

shift $(( ${OPTIND} - 1 ))

########################################################################
# Step 1: Check that this file is newer than the 
#         hashcreatecanonicalscript file.
# This whole test needs to be done with wget and touchtime
########################################################################
tmpgit=/tmp/${0##*/}_$$_.git
mkdir -p ${tmpgit}
gitsite=https://raw.githubusercontent.com
gituser=sailnfool
gitrepo=bf
gitbranch=main
gitdir=scripts
gitfile=bf.createorthodox.sh
gitpath="${gitsite}/${gituser}/${gitrepo}/${gitbranch}/${gitdir}"
cd ${tmpgit}
wget "${gitpath}/${gitfile}"
	
orthodox_source=/${YesFSdiretc}/${orthodoxhashfile}
hashcreatecanonicalscript=${HOME}/github/ren/scripts/hashcreatecanonic.sh
hashtester=${HOME}/github/func/tests/tester.hash.createcanonical.sh
git pull 2>&1 >/dev/null
touchtimes func 2>&1 > /dev/null
if [[ ${hashcreatecanonicalscript} -nt ${hashtester} ]] ; then
	bf_errecho "Testing file is out of date"
	bf_errecho "Rebuild 'HERE' files in ${hashtester}"
	bf_errecho "edit ${hashtester}"
	exit 1
fi
########################################################################
# Step 2: Create the temporary copies of the data which will be
#         loaded into the canonical arrays.  Note that if the 
#         canonical hash array is newer than the last date of this
#         file, then these need to be rebuilt and created as HERE
#         files.
########################################################################
tmphash2num=/tmp/${Fhash2num}
tmpnum2bin=/tmp/${Fnum2bin}
tmpnum2bits=/tmp/${Fnum2bits}
tmpnum2hash=/tmp/${Fnum2hash}
tmpnum2hexdigits=/tmp/${Fnum2hexdigits}
tmpOID2OCH${__FOVA}="/tmp/${0##*/}_$$_OID2OCH${__FOVA}.csv"
tmp_hash2OID=/tmp/${0##*/}_$$_hash2OID.csv
tmp_OID2hash=/tmp/${0##*/}_$$_OID2hash.csv
tmp_OID2bin=/tmp/${0##*/}_$$_OID2bin.csv
tmp_OID2bits=/tmp/${0##*/}_$$_OID2bits.csv
tmp_OID2hex=/tmp/${0##*/}_$$_OID2hex.csv
tmp_OID2path=/tmp/${0##*/}_$$_OID2path.csv
tmp_OID2args=/tmp/${0##*/}_$$_OID2args.csv
cat > ${tmp_OID2OCH${__FOVA}} << EOFOID2OCH${__FOVA}
EOFOID2OCH${__FOVA}
cat > ${tmp_hash2OID} << EOFhash2OID
EOFhash2OID
cat > ${tmp_OID2hash} << EOFOID2hash
EOFOID2hash
cat > ${tmp_OID2bin} << EOFOID2bin
EOFOID2bin
cat > ${tmp_OID2bits} << EOFOID2bits
EOFOID2bits
cat > ${tmp_OID2hex} << EOFOID2hex
EOFOID2hex
cat > ${tmp_OID2path} << EOFOID2path
EOFOID2path
cat > ${tmp_OID2args} << EOFOID2args
EOFOID2args

for filesuffix in hash2OID OID2hash OID2bin OID2bits OID2hex \
	OID2path OID2args OID2OCH${__FOVA}
do
	filename=${YesFSdiretc}/${filesuffix}
	if [[ ! -r ${filename} ]] ; then
		echo -e "${warnstring} ${0##*/} ${filename} not found"
		((fail++))
		continue
	fi
	diff /tmp/${filesuffix} ${filename}
	result=$?
	if [[ ! "${result}" -eq 0 ]] ; then
		stderrecho "${warnstring} ${0##*/} "\
			"Comparison failed for ${filesuffix}"
	fi
	((fail += $result ))

	################################################################
	# This should have an additional (perhaps redundant) test to
	# perform a "join" on the tmp files and compare it with 
	# ${orthodoxhashfile}
	################################################################
done
exit ${fail}
