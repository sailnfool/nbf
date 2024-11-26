#!/bin/bash
########################################################################
#copyright      :(C) 2023
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines
########################################################################
#scriptname01   :bf_basename
#description01  :provide inline basename and dirname to give a boost
#description02  :in performance relative to forking a process
#args           :path
#author         :Robert E. Novak
#email          :sailnfool@gmail.com
#inspired by    :https://unix.stackexchange.com/questions/253524/
#inspired by 2  :dirname-and-basename-vs-parameter-expansion
#licenstype     :CC
#licensor       :Sea2Cloud Storage, Inc.
#licenserul     :https://creativecommons.org/
#licensepath    :licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|09/09/2023| Initial Release
#_____________________________________________________________________
if [[ -z "${__bfbasename}" ]] ; then
	export __bfbasename=1

	bf_basename() {
		test -n "$1" || return 0
		local x="$1"
		while :
		do
			case "$x" in
				*/)
					x="${x%?}"
					;;
				*) break;;
			esac
		done
		[ -n "$x" ] || { echo /; return; }
		printf '%s\n' "${x##*/}";
}
export bf_basename
	bf_dirname(){
		test -n "$1" || return 0
		local x="$1"
		while :
		do
			case "$x" in
				*/)
					x="${x%?}"
					;;
				*) break
					;;
			esac
		done
		[ -n "$x" ] || { echo /; return; }
		set -- "$x"
		x="${1%/*}"
		case "$x" in
			"$1")
				x=.
				;;
			"") x=/
				;;
		esac
		printf '%s\n' "$x"
}
export bf_dirname
fi #if [[ -z "${__bfbasename}" ]]
