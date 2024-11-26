#!/bin/bash
########################################################################
# Copyright (C) 2022 Robert E. Novak  All Rights Reserved
# Modesto, CA 95356
########################################################################
#
# Log entries in a common log file for tracking down problems
# with scripts going astray.
#
#######################################################################
# Log entries willbe single line records and will  contain multiple
# fields and the fields will be separated by a vertical pipe
# character "|" to separate the fields of the record.
#
# EVENT|execname|process#|BATCH#|Test#|TimeSTAMP|Event|Specific|Fields
#
# EVENT Types:
# START Record for when the test begins
# FINISH Record for when the test ends
# DELTA Record that records information about the wall time of the 
#     Test - about the interval between START and FINISH
# RATE Record that tracks information about the rate at which the
#     processes	execute to insure that we are able to
#     schedule/allocate adequate time	for future runs of
#     the application
#
# Author: Robert E. Novak
# email: sailnfool@gmail.com
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|10/23/2023| Switched to bf format
# 1.0 |REN|02/22/2021| Initial Release
#_____________________________________________________________________

if [[ -z "${__bflogger}" ]] ; then
	export __bflogger=1

	source bf.errecho
	source bf.insufficient
	source bf.regex

	function bf_logger()
	{
		if [[ $# -gt 0 ]] ; then
			echo -n "$1" >> ${TESTLOG}
		fi
		shift
		while [[ $# -gt 0 ]]
		do
			echo -n "|$1" >> ${TESTLOG}
			shift
		done
		echo "" >> ${TESTLOG}
	}
	export -f bf_logger
	function bf_old_logger()
	{
		local mod_test_number
		local commontitles
		local starttitles
		local finishtitles
		local deltatitles
		local ratetitles

		####################
		# Since the test number is a global variable stored in
		# the file system, it is passed in.  Every 20 tests,
		# output the titles for the records in the log file
		####################
		# bf_errecho ${FUNCNAME} ${LINENO} "#5=$5"
		if [[ ! $5 =~ bfre_signedinteger ]] ; then
			mod_test_number="999999"
		else
			mod_test_number=$(expr $5 % 20)
		fi
		# bf_errecho ${FUNCNAME} ${LINENO} "#mod_test_number=$mod_test_number"
		if [[ ${mod_test_number} -eq 0 ]] ; then
			####################
			# Initialize the titles
			####################
			commontitles="${commontitles}Executable|"
			commontitles="${commontitles}Process #|"
			commontitles="${commontitles}Batch #|"
			commontitles="${commontitles}Test #|"
			
			starttitles="START|${commontitles}Filesystem|"
			starttitles="${starttitles}Start Time|"
			starttitles="${starttitles}Num Processes|"
			starttitles="${starttitles}Num Nodes|"
	
			finishtitles="FINISH|${commontitles}Filesystem|"
			finishtitles="${finishtitles}Finish Time|"
			finishtitles="${finishtitles}Num Processes|"
			finishtitles="${finishtitles}Num Nodes|"
	
			deltatitles="DELTA|${commontitles}Filesystem|"
			deltatitles="${deltatitles}Duration Time|"
			deltatitles="${deltatitles}Duration Seconds|"
			deltatitles="${deltatitles}Num Processes|"
	
			ratetitles="RATE|${commontitles}Filesystem|"
			ratetitles="${ratetitles}Duration Time|"
			ratetitles="${ratetitles}Num Processes|"
			ratetitles="${ratetitles}Rate Band|"
			ratetitles="${ratetitles}Processes Per Hour|"
		fi

		local localNUMARGS=5
		local logevent
		local logexec
		local logexecbase
		local upper_exec
		local logprocessnumber
		local logbatch
		local logtestnum
		local NUMSTARTARGS
		local logsourcedir
		local logdestdir
		local logdate_began
		local lognumprocs
		local NUMNOTEARGS
	
		####################
		# Check the initial arguments
		####################
		if [[ $# -lt ${NUMARGS} ]] ; then
			bf_insufficient "${FUNCNAME} ${LINENO} "\
				"${localNUMARGS} $@"
		fi
		logevent="$1"
		logexec="$2"
		# logexec="$2"
		# logprocessnumber="$3"
		# logbatch="$4"
		# logtestnum="$5"

		logexecbase=${logexec##*/}
		upper_exec=$(echo ${logexecbase}|tr [:lower:] [:upper:])
		if [[ -z "${TESTLOG}" ]] ; then
			if [[ -z "${TESTDIR}" ]] ; then
				bf_errecho ${FUNCNAME} ${LINENO} \
					"Environment variable " \
					"TESTDIR not set"
				bf_errecho ${FUNCNAME} ${LINENO} \
					"Environment variable " \
					"TESTLOG not set"
				exit 1
			else
				export ETCDIR=${TESTDIR}/etc
				export TESTLOG=${ETCDIR}/testlog.txt
			fi
		fi

				case ${logevent} in
					START | FORK | SLEEPING | 
						COMPLETED)
				# Handle the START Log entry
				####################
				# Write the titles to the log files
				####################
				if [[ ${mod_test_number} -eq 0 ]] ; then
					echo "${starttitles}" >> ${TESTLOG}
				fi

				NUMSTARTARGS=9
				if [[ $# -lt ${NUMSTARTARGS} ]] ; then
					bf_errecho "${FUNCNAME} ${LINENO} " \
						"error in ${logevent} " \
						"parameter count"
					bf_insufficient ${FUNCNAME} ${LINENO} ${NUMSTARTARGS} $@
				fi
# 				logsourcedir="$6"
#				logdestdir="$7"
# 				logdate_began="$8"
# 				lognumprocs="$9"
				if [[ -z "${TESTLOG}" ]] ; then
					bf_errecho ${FUNCNAME} ${LINENO} \
						"TESTLOG not initialized"
					exit 1
				fi
				echo \
					"${1}|${2}|${3}|${4}|${5}|" \
					"${6}|${7}|${8}|" \
					"${9}" >> ${TESTLOG}
				;;
			NOTE)
				if [[ ${mod_test_number} -eq 0 ]] ; then
					echo "${starttitles}" >> ${TESTLOG}
				fi
				NUMNOTEARGS=7
				if [[ $# -lt ${NUMNOTEARGS} ]] ; then
					bf_errecho ${FUNCNAME} ${LINENO} \
						"error in ${logevent} " \
						"parameter count"
					bf_insufficient "${FUNCNAME} " \
						"${LINENO} "\
						"${NUMNOTEARGS}" $@
				fi
				if [[ -z "${TESTLOG}" ]] ; then
					bf_errecho ${FUNCNAME} ${LINENO} \
						"TESTLOG not initialized"
					exit 1
				fi
				echo \
					"${1}|${2}|${3}|${4}|${5}|" \
					"${6}|${7}" >> ${TESTLOG}
				;;
			FINISH)	# Handle the FINISH Log entry
				if [[ ${mod_test_number} -eq 0 ]] ; then

				####################
				# Write the titles to the log files
				####################
					echo "${finishtitles}" >> ${TESTLOG}
				fi
				NUMFINISHARGS=9
				if [[ $# -lt ${NUMFINISHARGS} ]] ; then
					bf_errecho "${FUNCNAME} " \
						"${LINENO} " \
						"error in " \
						"${logevent} " \
						"parameter count"
					bf_insufficient "${FUNCNAME} " \
						"${LINENO} " \
						"${NUMFINISHARGS} $@"
				fi
# 				logsourcedir="$6"
#				logdestdir="$7"
# 				logdate_began="$8"
# 				lognumprocs="$9"
				echo \
					"${1}|${2}|${3}|${4}|${5}|" \
					"${6}|${7}|${8}|" \
					"${9}" >> ${TESTLOG}
				;;
			DELTA)	# Handle the DELTA Log entry
				if [[ ${mod_test_number} -eq 0 ]] ; then
	
					####################
					# Write the titles to the log files
					####################
					echo "${deltatitles}" >> ${TESTLOG}
				fi
				NUMDELTAARGS=11
				if [[ $# -lt ${NUMDELTAARGS} ]] ; then
					bf_errecho "${FUNCNAME} " \
						"${LINENO} " \
						"error in ${logevent} " \
						"parameter count"
					bf_insufficient "${FUNCNAME} " \
						"${LINENO} "\
						"${NUMDELTAARGS} $@"
				fi
# 				logsourcedir="$6"
#				logdestdir="$7"
# 				logdate_began="$8"
# 				lognumprocs="$9"
				echo \
					"${1}|${2}|${3}|${4}|${5}|" \
					"${6}|${7}|${8}|" \
					"${9}" >> ${TESTLOG}
				;;
			\?)
				bf_errecho "${FUNCNAME} ${LINENO} " \
					"Invalid Log Type ${logevent}"
				exit 1
				;;
		esac
	}
	export -f bf_old_logger
fi # if [[ -z "${__bflogger}" ]]
