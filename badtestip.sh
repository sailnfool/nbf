#!/bin/bash
scriptname=${0##*/}
declare -a dummy4
declare -a dummy6
re_integer='^[0-9][0-9]*$'
re_less255='^((2[0-4][0-9])|(25[0-5])|(1[0-9]{2})|([0-9]{1,2}))$'
re_ipv4='^(((2[0-4][0-9])|(25[0-5])|(1[0-9]{2})|([0-9]{1,2})).){3}((2[0-4][0-9])|(25[0-5])|(1[0-9]{2})|([0-9]{1,2}))$'
re_hexnum4='^[0-9a-fA-F]{1,4}$'
bre_ipv4a='^(2[0-4][0-9]|25[0-5]|1[0-9]{2}|[0-9]{1,2}).{3}(2[0-4][0-9]|25[0-5]|1[0-9]{2}|[0-9]{1,2})$'
bre_ipv6='^((([0-9a-fA-F]){0,4})|0)(:(([0-9a-fA-F]){0-4})|0){1,15}$'

# for ((i=0; i<256; i++))
# do
# 	for ((j=0; j<256; j++))
# 	do
# 		for ((k=0; k<256; k++))
# 		do
# 			for ((l=0; l<256; l++))
# 			do
# 				ipv4="$i.$j.$k.$l"
# 				if [[ ! "${ipv4}" =~ $re_ipv4 ]]
# 				then
# 					echo "Fail for ${ipv4}"
# 				else
# 					echo "Success for ${ipv4}"
# 				fi
# 			done
# 		done
# 	done
# done
# exit 0

#	if [[ "$i" =~ $re_integer ]]
#	then
#		echo success $i re_integer
#	else
#		echo fail $i re_integer
#	fi
# 	if [[ "$i" =~ $re_less255 ]]
# 	then
# 		echo success $i re_less255
# 	else
# 		echo fail $i re_less255
# 	fi
#done
tip4="192.168.0"
if [[ "${tip4}" =~ $re_ipv4 ]] ; then
	echo "Success ipv4 for ${tip4}"
else
	echo "Fail bre_ipv4a for ${tip4}"
fi
OIFS=$IFS
IFS='.'
dummy4=($tip4)
IFS=$OIFS
success=0
fail=0
for j in "${dummy4[@]}"
do
	echo "j='$j'"
	if [[ "$j" =~ $re_integer ]] || [[ "$j" -le 255 ]]
	then 
		((success++))
	else
		((fail++))
	fi
done
echo $tip4
echo "success=$success"
echo "fail=$fail"

tip6="fe00::0"
if [[ "${tip6}" =~ $bre_ipv6 ]] ; then
	echo "Success ipv6 for ${tip6}"
else
	echo "Fail bre_ipv6 for ${tip6}"
fi
OIFS=$IFS
IFS=':'
dummy6=($tip6)
IFS=$OIFS

success=0
fail=0
for j in "${dummy6[@]}"
do
	echo "j='$j'"
	if [[ "$j" =~ $re_hexnum4 ]] || [[ -z "$j" ]]
	then 
		((success++))
	else
		((fail++))
	fi
done
echo $tip6
echo "success=$success"
echo "fail=$fail"
