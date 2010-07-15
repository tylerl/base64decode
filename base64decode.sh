#!/bin/bash

# Base64 decoding routine written entirely in bash, with no external dependencies. 
#
# Usage:
#   base64decode < input > output
#
# This code is absurly inefficient; it runs aproximately 12,000 times slower than
# the perl-based decoder. The difference is that this code doesn't require you to
# install any external programs, which may be important in some cases.
#
# To decode using perl instead, use the following:
#  
# base64decode() {
#    perl -e 'use MIME::Base64 qw(decode_base64);$/=undef;print decode_base64(<>);'
# }
#

base64decode() {
	L=0
	A=0
	P=0
	while read -n1 C ; do
		printf -v N %i \'"$C"
		if (( $N == 61 )) ; then
			P=$(( $P + 1 )) # = (padding)
			V=0
		elif (( $N == 43 )) ; then
			V=62 # +
		elif (( $N == 47 )) ; then
			V=63 # /
		elif (( $N < 48 )) ; then
			continue
		elif (( $N < 58 )) ; then
			V=$(( $N + 4 )) # -48 + 52 (0-9)
		elif (( $N < 65 )) ; then
			continue
		elif (( $N < 91 )) ; then
			V=$(( $N - 65 )) # -65 + 0 (A-Z)
		elif (( $N < 97 )) ; then
			continue
		elif (( $N < 123 )) ; then
			V=$(( $N - 71 )) # -97 + 26 (a-z)
		else
			continue
		fi
			
		A=$(( ($A << 6) | $V ))
		L=$(( $L + 1 )) 

		if [ $L == 4 ] ; then
			printf -v X "%x" $(( ($A >> 16) & 0xFF ))
			printf "\x$X"
			if (( $P < 2 )) ; then
				printf -v X "%x" $(( ($A >> 8) & 0xFF ))
				printf "\x$X"
			fi
			if (( $P == 0 )) ; then
				printf -v X "%x" $(( $A & 0xFF ))
				printf "\x$X"
			fi 
			A=0
			L=0
			P=0
		fi
	done
}

base64decode 
