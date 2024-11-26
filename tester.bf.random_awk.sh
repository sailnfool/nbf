#!/bin/bash
########################################################################
#copyright      :(C) 2024
#copyrightholder:Robert E. Novak  All Rights Reserved
#location       :Bacolod City, Negros Occidental 6100 Philippines
########################################################################
#scriptname     :tester.bf.awkseedrandom
#description    :test random interval for repeatability
#args           :
#author         :Robert E. Novak
#authorinitials :REN
#email          :sailnfool@gmail.com
#license        :CC by Sea2Cloud Storage, Inc.
#licensesource  :https://creativecommons.org/licenses/by/4.0/legalcode
#licensename    :Creative Commons Attribution license
#attribution01	:https://github.com/dylanaraps/pure-bash-bible
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 3.2 |REN|10/06/2024| adopted from tester.bf.bashseedrandom
# 3.1 |REN|06/26/2024| Changed header
# 3.0 |REN|06/11/2024| adopted from hex2dec
# 2.1 |REN|04/20/2024| changed to bf
# 2.0 |REN|08/24/2022| changed to bfunc
# 1.1 |REN|06/04/2022| testing hex2dec
# 1.0 |REN|03/20/2022| testing hex2dec
#_____________________________________________________________________

source bf.debug
source bf.random_awk
source bf.regex
source bf.ansi_colors
source bf.cwave
source bf.errecho

#TESTNAME00="Test of function (bf.random_awk) from"
#TESTNAME01="https://github.com/sailnfool/bf"
#TESTNAMELOC="$HOME/github/bf/tests"
USAGE="\n${0##*/} [-[hv]] [-d <#>]\n
\t\tVerifies that the function will test for invalid inputs\n
\t\tAlso verifies that seeded random number generators generate the\n
\t\tsame sequence of numbers\n
\t\tNormally emits only PASS|FAIL message\n
\t-d\t<#>\tSet the diagnostic levels.\n
\t\t\tUse -vh to see the diagnostic levels.\n
\t-h\t\tPrint this message\n
\t-v\t\tVerbose mode to show values\n
"

optionargs="d:hv"
verbosemode="FALSE"
fail=0
########################################################################	
# For each test, we will retrieve the lower and upper bounds
# of the random number.  The target first use case is for the
# sizes of chunks retrieved from a source file.
########################################################################	
declare lower
declare upper

########################################################################	
# The randomint is a number generate by the random number
# function (in this case 'awk') which must be in the interval
# [lower -- upper]
########################################################################	
declare randomint

########################################################################	
# The result count is to help build correct result arrays tr[x]
# after the first run.
########################################################################	
declare resultcount

while getopts ${optionargs} name
do
	case ${name} in
		d)
			################################################
			# Verify that the -d (debug level) argument is
			# an integer
			################################################
			if [[ ! "${OPTARG}" =~ $bfre_digit ]] ; then
				bf_errecho -e "${ansi_failstring} " \
					"-d requires a decimal " \
					"digit"
				bf_errecho -e "${USAGE}"
				bf_errecho -e "${_BF_DEBUG_USAGE}"
				exit 1
			fi
			_BF_DEBUG="${OPTARG}"
			export _BF_DEBUG
			if [[ $_BF_DEBUG -ge ${_DEBUGSETX} ]] ; then
				set -x
			fi
			;;
		h)
			################################################
			# Print the usage text
			################################################
			bf_errecho -e "${USAGE}"
			if [[ "${verbosemode}" == "TRUE" ]] ; then
				bf_errecho -e "${_BF_DEBUG_USAGE}"
			fi
			exit 0
			;;
		v)
			################################################
			# Turn on Verbose Mode
			################################################
			verbosemode="TRUE"
			;;
		\?)
			bf_errecho -e "invalid option: -${OPTARG}"
			bf_errecho -e "${USAGE}"
			exit 1
			;;
	esac
done

########################################################################
# skip over the optional arguments
########################################################################
shift $(( OPTIND - 1 ))
########################################################################
# More tests would be good
# tv short for testvalue
# tr short for testresult
########################################################################
declare -a tvs # test value seed
declare -a tvl # test value lower range of random range
declare -a tvu # test value upper range of random range
declare -a tr  # test results of 5 queries to get random number in range
declare -a trr # The generated random numbers

tvs[0]="1"
tvl[0]="64"
tvu[0]="512"
tr[0]="1 2 3 4 5"
trr[0]=""

tvs[1]="251" # A prime seed
tvl[1]="61"  # A prime lower range of random numbers
tvu[1]="509" # A prime upper range of random numbers
tr[1]="1 2 3 4 5" # Samples known to be wrong until first test
trr[1]=""

tvs[2]="1"
tvl[2]="64"
tvu[2]="512"
tr[2]="465 221 372 192 140" # Should be correct
trr[2]=""

tvs[3]="251" # A prime seed
tvl[3]="61"  # A prime lower range of random numbers
tvu[3]="509" # A prime upper range of random numbers
tr[3]="129 190 160 246 182" # should be correct
trr[3]=""

fail=0

########################################################################
# ti short for testindex
# First we verify that the output of setting the seed is NULL
########################################################################
for ((ti=0;ti<${#tvs[@]};ti++))
do
#	bf_waverr -e "seeding: ti=${ti}"
#	if [[ "${verbosemode}" == "TRUE" ]] ; then
#		RANDOM=${tvs[${ti}]}
#		bf_errecho -e "${ansi_passstring} " \
#			"\$(bf_awkseedrandom \${tvs[${ti}]} ) should " \
#			"be '' - the NULL String"
#	fi

########################################################################
# Now for each seed, we set a lower and upper range and then verify
# that the generated random chunk size is both in the interval and that
# the sequence of chunk sizes is the same for the seed each time we
# re-initialize with the seed.  The very first time you run this test
# you will have no idea what random sequence will be generated so you
# will have to capture it and hard-code it in the variables above.
# As a further test, you should test seeding the algorithm, getting
# the test result, then seeding with a different number and then return
# to verifying that the second time you seed with the same number that
# the result is still the same.
########################################################################
# Start by iterating through the test cases to check the seed
# initialization
########################################################################
	bf_waverr "seed tvs[${ti}] = ${tvs[${ti}]}"
	################################################################	
	# First seed with the given value
	################################################################	
	RANDOM=${tvs[${ti}]}
#	if [[ ! "$(bf_awkseedrandom ${tvs[${ti}]} )" == "" ]]; then
#		((fail++))
#	fi

	################################################################	
	# We will use the space separated list of predicted results to
	# generate the loop to process the results for the N samples
	# in tr array
	# find out how many times we will look for a random result by
	# looping through the space separated results in the tr array
	# (see above: tr[x]="1 2 3" is a sample)
	################################################################	
	resultcount=0
	
	################################################################	
	# the list of space separated results will be in the tr string
	################################################################	
	bf_waverr "Expected Results: for tr[${ti}]=${tr[${ti}]}"
	for expectedresult in ${tr[${ti}]}
	do

		########################################################	
		# Get the lower and upper values from the test value
		# arrays
		########################################################	
		lower=${tvl[${ti}]}
		upper=${tvu[${ti}]}
		bf_waverr "lower=${lower}"
		bf_waverr "upper=${upper}"
		bf_waverr "expectedresult=${expectedresult}"

		########################################################	
		# Now we retrieve the randomly generated number
		# from the seeded random number generator.
		# The bounds are placed in double quotes, which may be
		# overkill, but it leaves the error checking to the
		# called function to insure that they are integers in
		# case they contain non integer digits
		########################################################	
		randomint="$(bf_awkrandomrange ${lower} ${upper} )"
		
		########################################################	
		# diagnostic to print the computed random number in the
		# range.
		########################################################	
		bf_waverr "randomint=${randomint}"

		########################################################	
		# Save the computed Pseudo Random Number (PRN) in the
		# trr array string.
		########################################################	
#		trr[${ti}]="${trr[${ti}]} ${randomint}"
		trr[${ti}]+="${randomint}"
#		bf_waverr "Checking for leading blank=${trr[${ti}]}"

# 		########################################################	
# 		# If there is a leading blank, delete it
# 		########################################################	
# 		if [[ "${trr[${ti}]:0:1}" == " " ]]; then
# 			trr[$ti]="${trr[${ti}]:1}"
# 			bf_waverr "should be no leading blank=${trr[${ti}]}"
# 		fi

		########################################################	
		# Show that we saved the result
		########################################################	
		bf_waverr "trr[${ti}]=${trr[${ti}]}"
		
		########################################################	
		# Verify that the randomint is in the interval
		# These tests are not guarded by verbosemode since
		# these should shake out during testing and will only
		# provide a small overhead.
		########################################################	
		if [[ "${randomint}" -lt "${lower}" ]]; then
			bf_errecho -e "${ansi_failstring} " \
				"randomint ${randomint} " \
				"is less than ${lower}"
			((fail++))
		fi
		if [[ "${randomint}" -gt "${upper}" ]]; then
			bf_errecho -e "${ansi_failstring} " \
				"randomint ${randomint} " \
				"is greater than ${upper}"
			((fail++))
		fi
		
		########################################################	
		# Verify that the seeded, random result is the expected
		# result.  The error messages here is more verbose
		# than is strictly needed for testing, so we guard it
		# with verbose mode
		########################################################
		predicted=$(echo ${tr[${ti}]} | cut -d ' ' -f $((ti+1)))
		bf_waverr "predicte=${predicted}, got ${randomint}"
		if [[ ! "${predicted}" == "${randomint}" ]]; then
			if [[ "${verbosemode}" == "TRUE" ]]; then
				bf_errecho -e "${ansi_failstring} " \
					"Test #${ti} with " \
					"seed ${tvs[${ti}]} " \
					"for result ${resultcount} " \
					"should be ${expectedresult}, " \
					"got ${randomint}."
			fi
			((fail++))
		else
			if [[ "${verbosemode}" == "TRUE" ]]; then
				bf_errecho -e "${ansi_passstring} " \
					"Test #${ti} with " \
					"seed ${tvs[${ti}]} " \
					"for result ${resultcount} " \
					"is correct with ${randomint}."
			fi
		fi
	done # for result in ${tr[${ti}]}
	bf_waverr "Generated Number: ${randomint}"
done # for ((ti=0;ti<${#tvs[@]};ti++))
exit "${fail}"
