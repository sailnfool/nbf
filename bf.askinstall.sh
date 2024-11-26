#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines 6000
########################################################################
#scriptname     :askinstall
#args           : [-[hvy]] [<missing binary>]
#description00  : If the binary file doesn't exist then search the
#description01  : Ubuntu packages to find them
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
# 2.1 |REN|10/06/2023| Changed errecho to bf_errecho
# 2.0 |REN|10/01/2023| Converted to bf
# 1.0 |REN|09/13/2022| Initial Release
#_____________________________________________________________________

if [[ -z "${__bfaskinstall}" ]] ; then
	export __bfaskinstall=1

	source bf.ansi_colors
	source bf.cwave
	source bf.debug
	source bf.insufficient
	source bf.regex

	bf_askinstall() {
		# [-v] <presumed bin path>

		local localNUMARGS
		local missing
		local whichmissing
		local whichresult
		local searchfind
		local pkgname
		local installanswer

		localNUMARGS=1

		if [[ "$#" < "${localNUMARGS}" ]] ; then
			bf_insufficient $localNUMARGS $@
			exit 1
		fi

		
		echo $1 | grep bin - > /dev/null
		if [[ ! "$?" == 0 ]] ; then
			bf_errecho -e "$1 is not in a bin directory"
			exit 3
		fi
		missing=$1
		whichmissing=$(which ${missing})
		whichresult=$?
		if [[ "${whichresult}" == 0 ]] ; then
			# found ${missing}
			return 0
		fi
		tmpdir="/tmp/${0##*/}_$$"
		mkdir -p ${tmpdir}
		apt-file_searchname="apt-file_search.txt"
		apt-file_searchfile="${tmpdir}/${apt-file_searchname}"
		bf_errecho -e "Need superuser privileges to " \
			"insure we can search for ${missing}"
		sudo apt-get install -y apt-file
		sudo apt-get apt-file -y update
		sudo apt-file search ${missing##*/} \
			> "${apt-file_searchfile}"
		searchfind=$(grep ".*bin[^ ]*${missing}")
		if [[ ! "$?" == 0 ]] ; then
			bf_errecho -e "${missing##*/} not found in packages"
			exit 4
		fi
		pkgname=${searchfind%:*}
		bf_errecho -e "${missing} found in package ${pkgname} "
		read -p "Install now (Y/n): " installanswer
		if [[ -z "${installanswer@L}" ]] ; then
			installanswer="y"
		fi
		case ${installanswer} in
			y|yes)
				sudo apt-get install ${pkgname}
				;;
			n|no)
				bf_errecho -e "not installing ${missing} "\
					"from ${pkgname}"
				;;
			\?)
				bf_errecho -e "Invalid answer, exiting"
				exit 5
				;;
		esac
	}
	export -f bf_askinstall
fi # if [[ -z "${__bfaskinstall}" ]] ; then

