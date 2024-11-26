#!/bin/bash
########################################################################
# Copyright (C) 2022 Robert E. Novak  All Rights Reserved
# Modesto, CA 95356
########################################################################
#
# bf_os - Debian dependent, report OS release info
#
# bf_idlike - Debian dependent, report a  debia like OS
#
# bf_os_version_id - Debian dependent report a version ID
#
# bf_arch - Debian dependent report the underlying CPU architecture
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|10/06/2023| Made the script easier to read
# 1.0 |REN|01/24/2022| Initial Release
#_____________________________________________________________________

########################################################################
# bf_os
# Find the name of the installled operating system
########################################################################
if [[ -z "${__bfos}" ]] ; then

	export __bfos=1

	bf_os() {
		local searchstring
		local os
		searchstring="^ID="
		os=$(grep "${searchstring}" /etc/os-release)
		echo ${os##*=}
	}
	####################
	# end of function bf_os
	####################
	export -f bf_os
fi # if [[ -z "${__bfos}" ]] ; then

########################################################################
# bf_idlike
# Find the release family
########################################################################
if [[ -z "${__bfidlike}" ]] ; then

	export __bfidlike=1

	bf_idlike() {
		local editstring
		editstring='/^ID_LIKE=/s/^ID_LIKE=\(.*\)$/\1/p'
		echo $(sed -ne ${editstring} < /etc/os-release)
	}
	####################
	# end of function bf_idlike
	####################
	export -f bf_idlike

fi # if [[ -z "${__bfidlike}" ]] ; then

########################################################################
# bf_os_version_id
# Find the name of the installled operating system
########################################################################
if [[ -z "${__bfos_version_id}" ]] ; then

	export __bfos_version_id=1

	bf_os_version_id() {
		local editstring
		local osversion
		editstring='/^VERSION_ID=/s/^VERSION_ID=\(.*\)$/\1/p'
		osversion=$(sed -ne ${editstring} < /etc/os-release)
		# Strip off the "" and change "." to "_"
		echo ${osversion:1:-1}|tr "\." "_"
#		echo $(sed -ne ${editstring} < /etc/os-release)

	}
	####################
	# end of function bf_os_version_id
	####################
	export -f bf_os_version_id

fi # if [[ -z "${__bfos_version_id}" ]] ; then

########################################################################
# bf_arch
# Find the name of the installled operating system
########################################################################
if [[ -z "${__bfarch}" ]] ; then

	export __bfarch=1

	bf_arch() {
		echo $(uname -m)
	}
	####################
	# end of function bf_arch
	####################
	export -f bf_arch
fi # if [[ -z "${__bfarch}" ]] ; then
