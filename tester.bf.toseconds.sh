#!/bin/sh
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod City, Negros Occidental 6100 Philippines
########################################################################
#	sailnfool@gmail.com
#	skype:sailnfool.ren
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.0 |REN|06/26/2024| Converted from func to bf
# 1.0 |REN|02/02/2022| testing reconstructed kbytes
#_____________________________________________________________________
#
########################################################################
source bf.toseconds

declare -a tv
declare -a tr
#TESTNAME00="Test of function toseconds (bf.toseconds) "
#TESTNAMELOC="https://github.com/sailnfool/bf"
tv[0]="40.25"
tr[0]="40.25"
tv[1]="10:40.25"
tr[1]="640.25"
tv[2]="5:15:20.4"
tr[2]="18920.4"
tv[3]="20:10:40.25"
tr[3]="72640.25"
tv[4]=".08"
tr[4]="0.08"
failure=0
#for i in {0..4}
for ((i=0;i<${#tv};i++))
do
	answer=$(toseconds "${tv[${i}]}")
	echo "answer=${answer}; test=${tv[${i}]}"
	if [[ ! "${answer}" == "${tr[${i}]}" ]]
	then
		((failure++))
	fi
done
exit ${failure}
