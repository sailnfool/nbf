#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
########################################################################
#scriptname01   :bf_errecho send an error message to stderr
#description01  :send an error message to stderr
#args01         :[ein] "message" [...]
#
# bf_errecho
#
# bf_errecho is invoked as in the example below:
# bf_errecho "some error message " "with more text"
# The output is only generated if the global variable $__BFUNC_DEBUG
# is defined and greater than 0
# The errecho function takes an optional argument "-e" to tell the
# echo command to add a new line at the end of a line and to process
# any in-line control characters (see man echo)
#
#author: Robert E. Novak aka REN
#email: sailnfool@gmail.com
#licensor: CC by Sea2Cloud Storage, Inc.
#licensurl: https://creativecommons.org/licenses/by/4.0/legalcode
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.3 |REN|05/04/2024| Added missing localUSAGE, simplified some code
# 3.2 |REN|10/23/2023| added localNUMARGS
# 3.1 |REN|08/05/2022| Converted to bf.errecho func.errecho
# 3.0 |REN|08/05/2022| Converted to bfunc.errecho func.errecho
# 2.1 |REN|05/20/2022| removed vim directive.  Added additional
#                    | bash builtins to report the name of the
#                    | source file, the command that is executing
#                    | the name of the function that is throwing
#                    | the error number and the line number
# 2.0 |REN|11/14/2019| added vim directive and header file
# 1.0 |REN|09/06/2018| original version
#_____________________________________________________________________

if [[ -z "${__bferrecho}" ]] ; then
	export __bferrecho=1

	source bf.insufficient

	bf_errecho()
	{
	
		local OPTARG
		local OPTIND
		local name
		local level
		local localNUMARGS=0
		local verbosemode="FALSE"
		local indentmode="FALSE"
		local optionargs="eilntv"
		local xx=""
		local location="TRUE"
		local PL=1
		local pbs=""
		########################################################
		# ED = errordate time
		########################################################
		local ED="$(date '+%Y%m%d_%H:%M:%S')"
		local localUSAGE="
${0##*/} ${ED}
\t-i\t\tGet the name of the calling FUNCNAME
\t-e\t\tAdd the -e option to echo to process non-printing echo chars
\t-l\t\tEmit the line # of the calling FUNCNAME
\t-n\t\tDon\'t put a newline after the error message
\t-t\t\tPut indenting '>' chars before the message
\t-v\t\tVerbose mode
"

	
		while getopts ${optionargs} name
		do
			case ${name} in
				i)
					PL=2
					;;
				e)
					pbs="${pbs} -e "
					;;
				l)
					location="FALSE"
					;;
				n)
					pbs="${pbs} -n "
					;;
				t)
					################################
					# find how many level deep we
					# are, then create a string of
					# '>' leading characters for
					# the message as indentation
					# markers
					################################
					level=${#FUNCNAME[@]}
					for i in $(seq 0 ${level}) \
#					for ((i=0; i<${#FUNCNAME[@]}; \
#						i++))
					do xx="${xx}>"; done
					indentedmode="TRUE"
					;;
				v)
					verbosemode="TRUE"
					;;
				\?)
					stdbuf -e0 echo -e \
						"invalid option: "\
						"-${OPTARG}" >&2
					stdbuf -e0 echo -e ${localUSAGE} >&2
					exit 1
					;;
			esac
		done

		shift $((OPTIND-1))

		if [[ $# -lt ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} $@
			stdbuf -e0 echo "-e" ${localUSAGE} >&2
			exit 2
		fi

		########################################################
		# FN = Function Name of the current calling function
		# LN = Line Number of the parent calling function
		# SF = Source File of the calling function
		# CM = Command Invoking Process
		# ED = Error Date/Time (above)
		########################################################
		local FN=${FUNCNAME[${PL}]}
		if [[ "${FN}" == "main" ]] ; then
			FN="${0##*/}(main)"
		else
			FN="${0##*/}(${FN})"
		fi
		local LN=${BASH_LINENO[$((PL-1))]}
		local SF=${BASH_SOURCE[${PL}]}
		local CM=${0##*/}

		stdbuf -e0 echo "$@" | grep '\\[a-z]' > /dev/null
		grepresult=$?
		if [[ ${grepresult} == "0" ]] ; then
			pbs="-e ${pbs}"
		fi
		if [[ "${verbosemode}" == "TRUE" ]] ; then
			stdbuf -e0 echo -n "${xx}" >&2
			stdbuf -e0 echo ${pbs} -n "${SF}->${CM}:${ED}::${FN}:${LN}:" >&2
			stdbuf -e0 echo ${pbs} "${xx} $@" >&2
		else
			if [[ "${indentedmode}" == "TRUE" ]] ; then
				stdbuf -e0 echo -n "${xx}" >&2
				stdbuf -e0 echo  ${pbs} "${xx} $@" >&2
				stdbuf -e0 echo -n "   ${FN}:${LN}:" >&2
			else
				if [[ "${location}" == "TRUE" ]] ; then
					stdbuf -e0 echo -n ${pbs} "${xx} ${FN}:${LN}:" >&2
				fi
				stdbuf -e0 echo ${pbs} "${xx} $@" >&2
			fi
		fi
	} # End of function bf_errecho
	export -f bf_errecho
fi # if [ -z "${__bferrecho}" ]
