#!/bin/bash
scriptname=${0##*/}
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod, Negros Occidental, 6100 Philippines
########################################################################
#scriptname     :tester.bf.validip
#description    :Test to see if an IP address is vaild for ipv4 or ipv6
#args0a         :[-[ipv4|v4|4]] xxx.xxx.xxx.xxx or
#args0b         :[-[ipv6|v6|6]] [xxxx]:[xxxx](:[xxxx]){1,14}]
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|08/03/2022| Initial Release
#_____________________________________________________________________

source bf.ansi_colors
source bf.cwave
source bf.debug
source bf.insufficient
source bf.regex
source bf.validip

#TESTNAME00="Test of validip function (bf.validip.sh) from"
#TESTNAMELOC="https://github.com/sailnfool/bf"

local_NUMARGS=0
verbosemode="FALSE"
verboseflag=""
_BFUNC_DEBUG=${_DEBUGOFF}

USAGE="\n${0##*/} [-hv] [-d <#>]\n
\t\ttest a set of valid and invalid IP addresses with bf_valid\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see debug modes/levels\n
\t-h\t\tPrint this message\n
\t-v\t\tTurn on verbose mode\n
"

optionargs="d:hv"
while getopts ${optionargs} name
do
	case ${name} in
		d)
			if [[ ! "${OPTARG}" =~ $re_digit ]]
			then
				echo "-d requires a " \
					"decimal digit"
				echo -e "${USAGE}"
				echo -e "${_DEBUG_USAGE}"
				exit 1
			fi
			_BFUNC_DEBUG="${OPTARG}"
			export _BFUNC_DEBUG
			if [[ ${_BFUNC_DEBUG} -ge ${_DEBUGNOEX} ]] ; then
				set -v
			fi
			if [[ ${_BFUNC_DEBUG} -ge ${_DEBUGSETX} ]] ; then
				set -x
			fi
			;;
		h)
			echo -e "${USAGE}"
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				echo -e "${_BDEBUG_USAGE}"
			fi
			exit 0
			;;
		v)
			verbosemode="TRUE"
			verboseflag="-v"
			;;
		\?)
			echo -e "invalid option: -${OPTARG}"
			echo -e "${USAGE}"
			exit 1
			;;
	esac
done

shift $((OPTIND-1))

if [[ $# -lt ${func_NUMARGS} ]] ; then
	bf_insufficient ${func_NUMARGS} $@
	echo -e "${USAGE}"
	exit 2
fi

########################################################################
# tv is short for testvalue
# tr is short for testresult
########################################################################
tv[0]="4.2.2.2"
to[0]="-4"
tr[0]=0

tv[1]="a.b.c.d"
to[1]="-4"
tr[1]=1

tv[2]="192.168.1.1"
to[2]="-4"
tr[2]=0

tv[3]="0.0.0.0"
to[3]="-4"
tr[3]=0

tv[4]="255.255.255.255"
to[4]="-4"
tr[4]=0

tv[5]="255.255.255.256"
to[5]="-4"
tr[5]=1

tv[6]="192.168.0.1"
to[6]="-4"
tr[6]=0

tv[7]="192.168.0"
to[7]="-4"
tr[7]=1

tv[8]="1234.123.123.123"
to[8]="-4"
tr[8]=1

# ::1     ip6-localhost ip6-loopback
tv[9]="::1"
to[9]="-6"
tr[9]=0

# fe00::0 ip6-localnet
tv[10]="fe00::0"
to[10]="-6"
tr[10]=0

# ff00::0 ip6-mcastprefix
tv[11]="ff00::0"
to[11]="-6"
tr[11]=0

# ff02::1 ip6-allnodes
tv[12]="ff00::1"
to[12]="-6"
tr[12]=0

# ff02::2 ip6-allrouters
tv[13]="ff00::2"
to[13]="-6"
tr[13]=0

# IPv6 address for www.cyberciti.biz
tv[14]="2607:f0d0:1002:51::4"
to[14]="-6"
tr[14]=0

# IPv6 address for www.cyberciti.biz
tv[15]="2607:f0d0:1002:0051:0000:0000:0000:0004"
to[15]="-6"
tr[15]=0

# https://ipcisco.com/lesson/ipv6-address/
tv[16]="2345:0425:2CA1:0000:0000:0567:5673:23b5"
to[16]="-6"
tr[16]=0

# https://ipcisco.com/lesson/ipv6-address/
tv[17]="2345:425:2CA1:::567:5673:23b5"
to[17]="-6"
tr[17]=0

fail=0
for ((ti=0; ti<${#tv[@]}; ti++))
do
	bf_validip "${tv[${ti}]}"
	ipresult=$?
	if [[ "${ipresult}" == 0 ]] ; then
		if [[ "${tr[${ti}]}" -eq 1 ]] ; then
			((fail++))
			bf_errecho -e "${ansi_failstring} got ${ansi_passstring} " \
				"for ${tv[${ti}]}, expected " \
				"${ansi_failstring}"
		fi
	elif [[ "${tr[${ti}]}" -eq 0 ]] ; then
		((fail++))
		bf_errecho -e "${ansi_failstring} got ${ansi_failstring} for " \
			"${tv[${ti}]}, expected ${ansi_passstring}"
	fi
done
exit ${fail}
