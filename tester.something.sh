#!/bin/bash
scriptname=${0##*/}
#TESTNAME00="Test of FOVA declaration from"
#TESTNAMELOC="https://github.com/sailnfool/bf"
source bf.os
	__FOVA="$(bf_idlike)_$(bf_os)_$(bf_os_version_id)"
	__FOVA="${__FOVA}_$(bf_arch)"
	declare -A OID2hash
	declare -A OID2bin
	declare -A OID2bits
	declare -A OID2hex
	declare -A hash2OID
	declare -A hash2OCH_by_${__FOVA}
	export OID2hash
	export OID2bin
	export OID2bits
	export OID2hex
	export hash2OID
	export hash2OCH_by_${__FOVA}


