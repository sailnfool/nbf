#!/bin/bash
########################################################################
# Copyright (C) 2020 Robert E. Novak  All Rights Reserved
# Modesto, CA 95356
########################################################################
#
# hmsout <number> <units>
#        Convert the number in hours, minutes or seconds
#        into H:m:s format
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.1 |REN|07/29/2022| Added conversion of > 24 hours to days.  It may
#                    | break some old usage
# 1.0 |REN|01/15/2020| original version
#_____________________________________________________________________

source bf.errecho

if [[ -z "${__bf_hmsout}" ]] ; then
	export __bf_hmsout=1
	function bf_hmsout() {

		local localNUMARGS=2
		local number
		local units
		local hour
		local mins
		local sec

		if [[ $# -lt ${localNUMARGS} ]] ; then
			bf_insufficient ${localNUMARGS} $@
			exit 1
		fi
		number=$1

		if [[ "${number}" =~ $bfre_number ]] ; then
			bf_errecho "First parameter must be an integer"
			exit 1
		fi

		units=$2
		case ${units} in
			seconds)
				((hour=${number}/3600))
				((mins=(${number}-hour*3600)/60))
				((sec=${number}-((hour*3600) + (mins*60))))
				;;
			minutes)
				((hour=${number}/60))
				((mins=(${number}-hour*60)))
				((sec=0))
				;;
			hours)
				((hour=${number}))
				((mins=0))
				((sec=0))
				;;
			\?)
				bf_errecho "Second argument must be "
					"a unit of time, e.g. ( " \
					"hours, minutes, seconds ) " \
					"Invalid units=${units}"
				exit 1
				;;
		esac
		if [[ "${hour}" -ge "24" ]] ; then
			printf "$d days" $((days / 24))
			((hour=hour%24))
		fi
		printf "%02d:%02d:%02d\n" "${hour}" "${mins}" "${sec}"
	}
fi # if [ -z "${__bf_hmsout}" ]
