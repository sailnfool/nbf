#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Cebu 6000 Philippines
########################################################################
#scriptname     :askseed
#args           :[-[hvy]]
#description00  :ask the user to provide a seed for the cryptographic
#description01  :hash.  If the seed does not exist in SIDcheck, then
#description02  :add the short and long hash of the seed to SIDcheck
#description03  :The greatest vulnerability here is that the plain
#description04  :text of the seed is exposed as a parameter to the
#description05	:hash programs.  This must be corrected
#
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licenserul     :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.1 |REN|10/23/2023| Added localNUMARGS, fixed warnstring
# 2.0 |REN|10/06/2023| Converted to bf
# 1.0 |REN|10/03/2022| Initial Release
#_____________________________________________________________________
if [[ -z "${__bfaskseed}" ]] ; then
	export __bfaskseed=1

	source bf.ansi_colors
	source bf.globalorthodox
	source bf.insufficient
	source bf.debug

	bf_askseed() {
		# [-v] <file> "answeryes"

		local answeryes="FALSE"
		local verbosemode="FALSE"
		local verboseflag=""
		local installanswer
		local name
		local localNUMARGS=0
		local hashfile
		local USAGE

		local optionargs="hvy"
		local OPTIND
		local OPTARG
		local missmsg1="${ansi_warnstring} Missing
${YesFSdiretc}/${orthodoxhashfile}, run createorthodox"
		local missmsg2="${ansi_warnstring} Missing
${YesFSdiretc}/${orthodoxhashfile}, exiting"

		USAGE="${FUNCNAME} [-[vy]] <file>\n
\t\t<file> is the orthodox cryptographic hash file\n
\t-h\t\tShow this usage information
\t-v\t\tverbose mode for diagnostics\n
\t-y\t\tanswer yes to questions\n
"

		bf_waventry

		while getopts ${optionargs} name
		do
			case ${name} in
				h)
					echo -e "${USAGE}"
					bf_wavexit
					exit 0
					;;
				v)
					verbosemode="TRUE"
					verboseflag="-v"
					;;
				y)
					answeryes="TRUE"
					;;
				\?)
					echo -e "Invalid option " \
						"-${OPTARG} $@" >&2
					echo -e "${USAGE}" >&2
					bf_wavexit
					exit 1
					;;
			esac
		done

		shift $(( ${OPTIND} - 1 ))

		if [[ "$#" -lt "${localNUMARGS}" ]] ; then
			bf_insufficient "${localNUMARGS} $@"
			bf_wavexit
			exit 1
		fi # if [[ "$#" -ne "${localNUMARGS}" ]]

		########################################################
		# If there is an optional hashfile argument, then make
		# that the hashfile, else use the installed one.
		########################################################
		if [[ "$#" -eq 1 ]] ; then
			hashfile="$1"
			shift 1
		else
			# from bf.globalorthodox
			hashfile="${YesFSdiretc}/${orthodoxhashfile}"
		fi

		if [[ -r "${hashfile}" ]] ; then
			if [[ "${verbosemode}" == "TRUE" ]] && \
				[[ "${FUNC_DEBUG}" -ge \
				"${DEBUGWAVAR}" ]] 
	<F12>		then
				if [[ -f "${hashfile}" ]] ; then
					cat "${hashfile}"
				else
					echo "${0##*/}:${FUNCNAME}:" \
						"${LINENO} " \
						"${hashfile} is not" \
						"a file" >&2
					exit 1
				fi
			fi # if [[ "${verbosemode}" == "TRUE" ]]
		else
			if [[ "${answeryes}" == "FALSE" ]] ; then
				echo "${missmsg1}" >&2
				read -p "Run Now (Y/n) " installanswer
				if [[ -z "${installanswer@L}" ]] ; then
					installanswer="Y"
				fi
				case ${installanswer@L} in
					y|yes)
						createorthodox \
							"${verboseflag}" \
							"${hashfile}"
						;;
					n|no)
						echo "${missmsg2}" >&2
						bf_wavexit
						exit 1
					 ;;
					\?)
					 echo "Invalid answer" >&2
					 bf_wavexit
					 exit 1
					 ;;
				esac
			else
				createorthodox "${verboseflag}" \
					"${hashfile}"
			fi # if [[ "${answeryes}" == "FALSE" ]]
		fi # if [[ -r "${hashfile}" ]]
		bf_wavexit
	}
	export -f bf_askseed
fi #if [[ -z "${__bfaskcreateorthodox}" ]]
