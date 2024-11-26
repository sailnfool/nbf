#!/bin/bash
########################################################################
#copyright      :(C) 2022
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Cebu, Philippines 6000
########################################################################
#scriptname01   :regex
#description01  :Define a set of regular expressions for testing
#args01         :N/A
#
##

# Author: Robert E. Novak
# email: sailnfool@gmail.com
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 2.1 |REN|09/30/2023| Converted to bf
# 2.0 |REN|08/05/2022| Converted to bfunc, added ipv4a ipv6 ...
#                    | containsperiods containscolons
# 1.4 |REN|05/27/2022| Added re_hexdigit, re_digit
# 1.3 |REN|05/19/2022| Added re_cryptohash, moved re_nicenumber to
#                    | func.kbytes
# 1.2 |REN|02/20/2022| Modernized to [[]]
# 1.1 |REN|02/01/2022| Tweaked documentation
# 1.0 |REN|03/25/2021| original version
#_____________________________________________________________________
########################################################################
#
# regex - Define a set of regular expressions for various tests 
#         of inputs.  When you want to test a variable, do NOT
#         place the expansion of the bfre_xxxx value in quotes.
#         It will not work.
#
########################################################################
if [[ -z "${__bf_regex}" ]] ; then

	export __bf_regex=1

	################################################################
	# Define a set of regular expressions for various tests of
	# inputs When you want to test a variable, do NOT place the
	# expansion of the bfre_xxxx value in quotes.  It will not work.
	#
	# if [[ "$input_value" =~ $bfre_hexnumber ]]
	# then
	#     echo "$input_value is a valid hex number
	# fi
	#
	# Often used to test arguments passed when using getopts to
	# process Bash script parameters for example the value passed
	# to debug (-d)
	#
	# if [[ "${OPTARG}" =~ $bfre_digit ]]
	# then
	#   debug="${OPTARG}"
	# else
	#   echo -e ${USAGE}
	# fi
	#
	# Note that there is also a "$bfre_nicenumber" found in
	# bf.kbytes
	######################################################################
	export bfre_hexdigit='^[0-9a-fA-F]$'
	export bfre_quotedstring='^["][^"]*["]$'
	export bfre_hexnumber='^[0-9a-fA-F]([0-9a-fA-F])*$'
	export bfre_digit='^[0-9]$'
	export bfre_integer='^[0-9][0-9]*$'
	export bfre_signedinteger='^[+\-][0-9][0-9]*$'
	export bfre_decimal='^[+\-][0-9]*\.[0-9]*$'
	export bfre_cryptohash='^([0-9a-fA-F]){3}:[0-9a-fA-F][0-9a-fA-F]*$'
	export bfre_OCH_number='^([0-9a-fA-F][0-9a-fA-F]*:[0-9a-fA-F][0-9a-fA-F]*$'
	export bfre_variablename='^[a-zA-Z_][a-zA-Z_0-9\-\.]*$'
	export bfre_filedirname='^([\/-_A-Za-z1-9\.]+[-_A-Za-z0-9\.]*)*$'
	export bfre_ipv4='^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$'
# Cribbed from:
#URL:https://stackoverflow.com/
#Question:questions/53497/
#Title:regular-expression-that-matches-valid-ipv6-addresses
#author:David M. Syzdek, bindlebinaries.com, Anchorage AK
	export bfre_ipv6='^(
([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|          # 1:2:3:4:5:6:7:8
([0-9a-fA-F]{1,4}:){1,7}:|                         # 1::                              1:2:3:4:5:6:7::
([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|         # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|  # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|  # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|  # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|  # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|       # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8  
:((:[0-9a-fA-F]{1,4}){1,7}|:)|                     # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::     
fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|     # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
::(ffff(:0{1,4}){0,1}:){0,1}
((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|          # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255  (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
([0-9a-fA-F]{1,4}:){1,4}:
((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])           # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
)$'

fi # if [[ -z "${__bf_regex}" ]]
