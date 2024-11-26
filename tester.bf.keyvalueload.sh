#!/bin/bash
scriptname=${0##/*}
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
########################################################################
#scriptname     :tester.bfunc.keyvalueload
#description01  :Load any key/value associative array from the file
#description02  :passed as a parameter.
#args           :aaray keyfile
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licensrul      :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensname     :Creative Commons Attribution license
#attribution01  :https://www.colorhexa.com/color-names
########################################################################
#_____________________________________________________________________
# Rev.|Aut| Date		 | Notes
#_____________________________________________________________________
# 2.0 |REN|07/27/2022| used nameref (declare -n) to reference a list
#                    | of associative arrays so that we can use the
#                    | same code in a loop instead of a big case
#                    | statement.
# 1.1 |REN|06/05/2022| Rewritten to use key/value arrays
# 1.0 |REN|05/26/2022| original version
#_____________________________________________________________________


source bf.debug
source bf.regex
source bf.keyvalueload
source bf.keyvaluestore

declare -A goodarray
declare -A dupearray

bf_waventry

#TESTNAME00="Test of hash function (bf.keyvalueload & "
#TESTNAME01="bf.keyvaluestore) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"
failcount=0
localNUMARGS=0

USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t-d\t<#>\tset the debug level to <#>, use -hv to see levels\n
\t-h\t\tPrint this message\r\n
\t-v\t\tVerbose mode to show values\r\n
\t\tVerifies that the function will load Associative arrays with the\n
\t\tcorrect cryptographic values\n
\t\tNormally emits only PASS|FAIL message\r\n
"

optionargs="d:hv"
verbosemode="FALSE"
verboseflag=""
_BF_DEBUG=${_DEBUGOFF}

########################################################################
# Now we are going to create a temporary set of files where we will
# store the key/value information from the Associative Arrays into
# these simple files that can be used for re-loading the arrays by
# other scripts.
#
# Since I got disgusted with the way that systemd has littered up the
# /tmp directory, the following is my convention of temporary files
# created by programs/scripts:
#
# /tmp/<Program Name>   <-- retrieved by ${0##*/} (basename of $0)
########################################################################
tmpdirname="/tmp/${0##*/}_$$"

mkdir -p ${tmpdirname}

########################################################################
# Create the file names. We have embedded the process uniqueness in
# the directory name so the file names are more obvious and less
# convoluted.  First we create the file names and then pre-pend the
# unique directory name.
########################################################################
tmpingoodfilename="sample_good_input.csv"
tmpindupefilename="sample_duplicated_input_.csv"
tmpdumpfilename="dump_output.csv"
tmpscratchfilename="scratch_sort.csv"

tmpingoodfile="${tmpdirname}/${tmpingoodfilename}"
tmpindupefile="${tmpdirname}/${tmpindupefilename}"
tmpdumpfile="${tmpdirname}/${tmpindumpfilename}"
tmpscratchfile="${tmpdirname}/${tmpscratchfilename}"

while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ ${bfre_digit} ]] ; then
				errecho "-d requires a decimal " \
					"digit"
#				echo -e "${0##/*}" "${LINENO}" \
				errecho -e "${USAGE}"
				errecho -e "${_BDEBUG_USAGE}"
				exit 1
			fi
			_BF_DEBUG="${OPTARG}"
			export _BF_DEBUG
			if [[ "${_BF_DEBUG}" -ge ${_DEBUGSETX} ]]
			then
				set -x
			fi
			;;
		h)
			errecho -e ${USAGE}
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				errecho -e "${_BDEBUG_USAGE}"
			fi
			exit 0
			;;
		v)
			verbosemode="TRUE"
			verboseflag="-v"
			;;
		\?)
			errecho -e "invalid option: -${OPTARG}"
			errecho -e "${USAGE}"
			exit 1
			;;
	esac
done

shift $(( ${OPTIND} - 1 ))

if [[ $# -lt "${localNUMARGS}" ]] ; then
	bf_insufficient "${localNUMARGS}" $@
	exit 1
fi

########################################################################
# Create a key/value array with no duplicates
########################################################################
cat > "${tmpingoodfile}" <<EOFgood
Air Force Blue	5d8aa8
Alizarin Crimson	e3s636
Amaranth	e52b50
American Rose	ff033e
Awesome	ff2052
Azure	007fff
EOFgood


########################################################################
# Create a key/value array with a duplicated key
########################################################################
cat > "${tmpindupefile}" <<EOFdupe
Air Force Blue	5d8aa8
Alizarin Crimson	e3s636
Amaranth	e52b50
American Rose	ff033e
Amaranth	ff2052
Azure	007fff
EOFdupe

########################################################################
# First we make sure that the input files are sorted
########################################################################
mv "${tmpingoodfile}" "${tmpscratchfile}"
sort < "${tmpscratchfile}" > "${tmpingoodfile}"
mv "${tmpindupefile}" "${tmpscratchfile}"
sort < "${tmpscratchfile}" > "${tmpindupefile}"

########################################################################
# Load the values from the good file
########################################################################
bf_keyvalueload ${verboseflag} goodarray ${tmpingoodfile}

########################################################################
# Dump the values to a scratch file, then sort the file to tmpdumpfile
# so we can compare to the tmpingoodfile
########################################################################
bf_keyvaluestore ${verboseflag} goodarray ${tmpscratchfile}
sort < "${tmpscratchfile}" > "${tmpdumpfile}"

########################################################################
# If we are in verbose mode, display the diff command and the results
# otherwise only collect the result
########################################################################
if [[ "${verbosemode}" == "TRUE" ]] ; then
	bf_waverr "diff "${tmpingoodfile}" "${tmpdumpfile}""
	diff "${tmpingoodfile}" "${tmpdumpfile}" >&2
	diffresult=$?
else
	diff "${tmpingoodfile}" "${tmpdumpfile}" 2>&1 > /dev/null
	diffresult=$?
fi
((failcount+=diffresult))

########################################################################
# Load the values from the dupe file
########################################################################
bf_waverr "You should see a warning while loading"
bf_keyvalueload ${verboseflag} dupearray ${tmpindupefile}

########################################################################
# Dump the values to a scratch file, then sort the file to tmpdumpfile
# so we can compare to the tmpindupefile
########################################################################
bf_keyvaluestore ${verboseflag} dupearray ${tmpscratchfile}
sort < "${tmpscratchfile}" > "${tmpdumpfile}"

########################################################################
# If we are in verbose mode, display the diff command and the results
# otherwise only collect the result
########################################################################
if [[ "${verbosemode}" == "TRUE" ]] ; then
	bf_waverr "diff "${tmpindupefile}" "${tmpdumpfile}""
	diff "${tmpindupefile}" "${tmpdumpfile}" >&2
	diffresult=$?
else
	diff "${tmpindupefile}" "${tmpdumpfile}" > /dev/null
	diffresult=$?
fi

########################################################################
# This seems perverse, but the test succeeds if the result is a failure
########################################################################
if [[ "${diffresult}" == 0 ]] ; then ((failcount+=1)) ; fi

bf_wavexit
exit "${failcount}"
