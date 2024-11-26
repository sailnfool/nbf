#!bin/bash
########################################################################
# Copyright (C) 2023 Robert E. Novak  All Rights Reserved
# Cebu, Philippines
########################################################################
#
# locker - Creates directories for storing test results.  Each
#          test is give a unique test number.  Implements the
#          following functions:
# bf_getlock - acquire a lock
# bf_release - release a lock
# bf_getcounter - get the current count
# bf_putcounter - modify the counter
# bf_getnextcounter - bump the counter before the next use.
# Set up Global variables for testing scripts
# Define bf_getlock and bf_release to avoid conflicts
#
# Author: Robert E. Novak
# email: sailnfool@gmail.com
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|10/16/2023| Converted to bf format
# 1.1 |REN|03/25/2021| added getcounter putcounter getnextcounter
# 1.0 |REN|03/15/2021| original version
#_____________________________________________________________________

if [[ -z "${__bf_locker}" ]] ; then
	export __bf_locker=1
	
	source bf.errecho
	source bf.insufficient
	source bf.regex

	################################################################	
	# Directories that must be created by bf_setuplocks
	################################################################	
	export BF_HOME_RESULTS=${BF_HOME_RESULTS:-${HOME}/.results}
	export BF_TESTDIR=${BF_TESTDIR:-${BF_HOME_RESULTS}/testdir}
	export BF_ETCDIR=${BF_ETCDIR:-${BF_TESTDIR}/etc}

	################################################################	
	# Files that must be created by bf_setuplocks
	################################################################	
	export BF_LOCKERRS=${BF_ETCDIR}/bf_lockerrs
	export BF_TESTLOG=${BF_HOME_RESULTS}/bf_testlog.txt

	################################################################	
	# The paths to these files must be created by bf_setuplocks
	# but will initially not exist.
	################################################################	
	export LOCKFILE_TESTNUMBERFILE=${BF_HOME_RESULTS}/BF_TESTNUMBER.lock
	export LOCKFILE_BATCHNUMBERFILE=${BF_HOME_RESULTS}/BF_BATCHNUMBER.lock

	################################################################	
	# The maximum number of spins allowed waiting for a lock
	################################################################	
	export BF_MAXSPINS=10
	export BF_SPINWAIT=20

	################################################################	
	# updating the following requires locking
	################################################################	
	export TESTNUMBERFILE=${BF_HOME_RESULTS}/BF_TESTNUMBER
	export BATCHNUMBERFILE=${BF_HOME_RESULTS}/BF_BATCHNUMBER
	################################################################	
	# End of files that need locking
	################################################################	

	################################################################	
	# bf_setuplocks
	################################################################	
	bf_setuplocks()
	{
		mkdir -p ${BF_HOME_RESULTS} ${BF_TESTDIR} ${BF_ETCDIR}
		if [[ ! -d ${BF_HOME_RESULTS} ]] ; then
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Directory BF_HOME_RESULTS = '" \
				"${BF_HOME_RESULTS}' not " \
				"created"
			exit 1
		fi
		if [[ ! -d ${BF_TESTDIR} ]] ; then
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Directory BF_TESTDIR = '" \
				"${BF_TESTDIR}' not " \
				"created"
			exit 1
		fi
		if [[ ! -d ${BF_ETCDIR} ]] ; then
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Directory BF_ETCDIR = '" \
				"${BF_ETCDIR}' not " \
				"created"
			exit 1
		fi
		if [[ -z "${BF_LOCKERRS}" || -z "${BF_TESTLOG}" ]]
		then
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Missing BF_LOCKERRS " \
				"or BF_TESTLOG"
			bf_errecho "BF_LOCKERRS=${BF_LOCKERRS}"
			bf_errecho "BF_TESTLOG=${BF_TESTLOG}"
			exit 1
		fi
		touch ${BF_LOCKERRS} ${BF_TESTLOG}

		if [[ ! -r ${BATCHNUMBERFILE} ]] ; then
			bf_getlock ${LOCKFILE_BATCHNUMBERFILE}
			echo 0 > ${BATCHNUMBERFILE}
			bf_releaselock ${LOCKFILE_BATCHNUMBERFILE}
		fi
		if [[ ! -r ${TESTNUMBERFILE} ]] ; then
			bf_getlock ${LOCKFILE_TESTNUMBERFILE}
			echo 0 > ${TESTNUMBERFILE}
			bf_releaselock ${LOCKFILE_TESTNUMBERFILE}
		fi
	}
	export -f bf_setuplocks

	################################################################	
	# bf_getlock lockfile sleeptime maxspins
	################################################################	
	bf_getlock()
	# bf_getlock lockfile sleeptime maxspins
	{
		local bf_getlock_USAGE
		local localNUMARGS=1
		local lockfile
		local lockcount
		local sleeptime
		local maxspins
		local verbose

		bf_getlock_USAGE="
bf_getlock <lockfile> [<sleeptime> [<maxspins>]]\n
\t\twhere <lockfile> is the lockfile to acquire\n
\t\tand <sleeptime> is the maximum seconds to wait for acquisition\n
\t\tand <maxspins> is the number of times to wait for <sleeptime>\n
"
		lockcount=0
		sleeptime=1
		maxspins="${BF_MAXSPINS}"
		verbosemode="TRUE"
		verboseflag="-v"

		maxspins=${BF_MAXSPINS}

		if [[ "$#" -lt "${localNUMARGS}" ]] ; then

			bf_errecho "${FUNCNAME}:${LINENO} " \
				"No lockfile specified"
			bf_insufficient ${localNUMARGS} ${FUNCNAME} $@
			bf_errecho "${bf_getlock_USAGE}"
			exit 1
		fi

		case $# in
			1)
				lockfile="$1"
				;;
			2)
				lockfile="$1"
				if [[ ! "$2" =~ $bfre_integer ]] ; then
					bf_errecho "${FUNCNAME}:" \
						"${LINENO} " \
						"Not a number - $2"
					bf_errecho "${bf_getlock_USAGE}"
					exit 1
				fi
				sleeptime="$2"
				;;
			3)
				lockfile="$1"
				if [[ ! "$2" =~ $bfre_integer ]]; then
					bf_errecho "${FUNCNAME}:" \
						"${LINENO} " \
						"Not a number - $2"
					bf_errecho "${bf_getlock_USAGE}"
					exit 1
				fi
				sleeptime="$2"
				if [[ ! "$3" =~ $bfre_integer ]]; then
					bf_errecho "${FUNCNAME}:" \
						"${LINENO} " \
						"Not a number - $3"
					bf_errecho "${bf_getlock_USAGE}"
					exit 1
				fi
				maxspins="$3"
				;;
			\?)
				bf_errecho "${FUNCNAME}:${LINENO} " \
					"Invalid arguments $@"
				bf_errecho "${bf_getlock_USAGE}"
				exit 1
				;;
		esac

		while [[ -f "${lockfile}" ]]
		do
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Sleeping on lock acquisition for " \
				"lock owned by"
			bf_errecho "${FUNCNAME}:${LINENO} " \
				$(ls -l "${lockfile}" | cut -d " " -f 3)
			((++lockcount))
			if [[ "${lockcount}" -gt "${maxspins}" ]] ; then
				bf_errecho "${FUNCNAME}:${LINENO} " \
					"Exceeded ${maxspins} spins " \
					"waiting for lock, quitting"
				exit 1
			fi
			sleep ${sleeptime}
		done
		if [[ -z "${lockfile}" ]] ; then
			bf_errecho "${FUNCNAME}:${LINENO} " \
				 "missing lockfile"
			exit 1
		fi
		touch "${lockfile}"

	}
	export -f bf_getlock

	################################################################
	# bf_releaselock lockfile
	################################################################
	bf_releaselock()
	{

		local lockfile

		if [[ $# -eq 0 ]] ; then
			bf_errecho "${FUNCNAME}:${LINENO} " \
					"No lockfile specified"
			exit 1
		fi
		lockfile="$1"
		if [[ -f "${lockfile}" ]] ; then
			rm -f "${lockfile}"
		else
			bf_errecho "${FUNCNAME}:${LINENO} " \
				"Nothing to release, ${lockfile} " \
				"not found"
		fi
	}
	export -f bf_releaselock
	################################################################
	# Get a batch number for batch of tests
	################################################################
	bf_getbatchnumber()
	{
		local value
		value=$(bf_getnextcounter "${LOCKFILE_BATCHNUMBERFIL}" \
			"${BATCHNUMBERFILE}")
		echo "${value}"
	}
	export -f bf_getbatchnumber

	################################################################
	# Get a test number for a test
	################################################################
	bf_gettestnumber()
	{
		local value

		value=$(bf_getnextcounter "${LOCKFILE_TESTNUMBERFILE}" \
			"${TESTNUMBERFILE}")
		echo "${value}"
	}
	export -f bf_gettestnumber

	################################################################	
	# get a counter value
	################################################################	
	bf_getcounter()
	# bf_getcounter lockfile counterfile
	{
		local value
		local localNUMARGS=2

		if [[ $# -ne ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} ${FUNCNAME} $@
		fi
		bf_getlock "$1"
		if [[ ! -r "$2" ]] ; then
			echo 0 > "$2"
		fi
		value=$(cat "$2")
		bf_releaselock "$1"
		echo "${value}"
	}
	export -f bf_getcounter

	################################################################	
	# put a counter value
	################################################################	
	bf_putcounter()
	{
		local localNUMARGS=3

		if [[ $# -ne ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} ${FUNCNAME} $@
		fi
		bf_getlock "$1"
		echo "$3" > "$2"
		bf_release "$1"
	}
	export -f bf_putcounter

	################################################################	
	# get the next counter value
	################################################################	
	bf_getnextcounter()
	{

		local value
		local localNUMARGS=2

		if [[ $# -ne ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} ${FUNCNAME} $@
		fi
		value=$(bf_getcounter "$1" "$2")
		((value++))
		bf_putcounter "$1" "$2" "${value}"
	}
	export -f bf_getnextcounter
fi # if [[ -z "${__bf_locker}" ]]
