#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philipppines 6000
########################################################################
#scriptname01   :bf_insufficient
#description01a :tell the user they have an insufficient number of
#description01b :parameters to a script or function
#args01         :localNUMARGS $@
#scriptname02   :bf_nullparm
#description01a :tell the user they have a null parameter
#args01         :The expected parameter #
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.1 |REN|09/30/2023| migrated to bf
# 3.0 |REN|07/29/2022| migrated to bfunc
# 2.2 |REN|07/29/2022| Remove .vim directive
# 2.1 |REN|04/27/2020| swapped order of parameters to make func first
# 2.0 |REN|11/14/2019| added vim directive and header file
# 1.0 |REN|09/06/2018| original version
#_____________________________________________________________________

if [[ -z "${__bfinsufficient}" ]] ; then

	export __bfinsufficient=1

	source bf.errecho
	source bf.cwave

	################################################################
	# insufficient - tell the user that they have insufficient
	#                parameters to a function
	################################################################

	bf_insufficient()
	{

		local numparms

		bf_waventry
		numparms="$1"
		shift;
		if [[ ! -z "$@" ]] ; then
			bf_errecho "Insufficient parameters, " \
				"need ${numparms}, got $@" >&2
		else
			bf_errecho "Insufficient parameters, " \
				"need ${numparms}, got none" >&2
		fi
		bf_wavexit

		########################################################
		# end of function insufficient
		########################################################
	}
	export -f bf_insufficient

	################################################################
	# nullparm - tell the user that they have a null parameter
	################################################################
	bf_nullparm()
	{

		local parmnum

		bf_waventry
		parmnum="$1"
		bf_errecho "Parameter #${parmnum} is null" >&2
		bf_wavexit
		exit -1

		########################################################
		# end of function nullparm
		########################################################
	}
	export -f bf_nullparm
fi # if [ -z "${__funcinsufficient}" ]
