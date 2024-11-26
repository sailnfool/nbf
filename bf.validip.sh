#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Modesto, CA 95356 USA
########################################################################
#Script Name    :valid_ip v4 [& hopefully soon v6]
#Description    :returns 0 (TRUE) if the address is valid
#args0a         :[-[ipv4|v4|4]] xxx.xxx.xxx.xxx or
#args0b         :[-[ipv6|v6|6]] [xxxx]:[xxxx](:[xxxx]){1,14}]
#author         :Robert E. Novak aka REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#license source :https://creativecommons.org/licenses/by/4.0/legalcode
#license name   :Creative Commons Attribution license
#citationurl    :https://www.linuxjournal.com/
#citationsection:content/validating-ip-address-bash-script 
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|10/01/2023| converted to bf
# 1.0 |REN|08/03/2022| Initial Release
#_____________________________________________________________________

USAGE="\n${0##*/} xxx.xxx.xxx.xxx
\t\tverifies if the IP address is valid\n
"
if [[ -z "${__bfvalidip}" ]] ; then

	__bfvalidip=1

	bf_validip()
	{
		source bf.insufficient
		source bf.regex

		local	ip
		local	stat
		local	numargs

		stat=0
		numargs=1


		bf_waventry
		if [[ "$#" -lt "${numargs}" ]] ; then
			bf_insufficient "${numargs}" $@
			return 1
		fi
		ip=$1
		if [[ ! "${ip}" =~ $bfre_ipv6 ]] ; then
			stat=1
			if [[ "${ip}" =~ ${bfre_ipv4} ]] ; then
				stat=0
			else
				bf_waverr "${ip} Failed ultimate " \
					"ip Regular Expression and " \
					"ipv4 expressions"
			fi
		fi

		if [[ "${stat}" == "0" ]] ; then
			bf_waverr "success  ip=${ip}"
		fi
		bf_wavexit

		return ${stat}
	}
fi # if [[ -z "${__bfvalidip}" ]] 
