# Copyright (C) 2012, 2013, 2016  Internet Systems Consortium, Inc. ("ISC")
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# $Id$

SYSTEMTESTTOP=..
. $SYSTEMTESTTOP/conf.sh
failed () {
	cat verify.out.$n | sed 's/^/D:/';
	echo "I:failed";
	status=1;
}

n=0
status=0

for file in zones/*.good
do
	n=`expr $n + 1`
	zone=`expr "$file" : 'zones/\(.*\).good'`
	echo "I:checking supposedly good zone: $zone ($n)"
	ret=0
	case $zone in
	zsk-only.*) only=-z;;
	ksk-only.*) only=-z;;
	*) only=;;
	esac
	$VERIFY ${only} -o $zone $file > verify.out.$n 2>&1 || ret=1
	[ $ret = 0 ] || failed
done

for file in zones/*.bad
do
	n=`expr $n + 1`
	zone=`expr "$file" : 'zones/\(.*\).bad'`
	echo "I:checking supposedly bad zone: $zone ($n)"
	ret=0
	dumpit=0
	case $zone in
	zsk-only.*) only=-z;;
	ksk-only.*) only=-z;;
	*) only=;;
	esac
	expect1= expect2=
	case $zone in
	*.dnskeyonly)
		expect1="DNSKEY is not signed"
		;;
	*.expired)
		expect1="signature has expired"
		expect2="No self-signed .*DNSKEY found"
		;;
	*.ksk-expired)
		expect1="signature has expired"
		expect2="No self-signed .*DNSKEY found"
		;;
	*.out-of-zone-nsec|*.below-bottom-of-zone-nsec)
		expect1="unexpected NSEC RRset at"
		;;
	*.nsec.broken-chain)
		expect1="Bad NSEC record for.*, next name mismatch"
		;;
	*.bad-bitmap)
		expect1="bit map mismatch"
		;;
	*.missing-empty)
		expect1="Missing NSEC3 record for";
		;;
	unsigned)
		expect1="Zone contains no DNSSEC keys"
		;;
	*.extra-nsec3)
		expect1="Expected and found NSEC3 chains not equal";
		;;
	*)
		dumpit=1
		;;
	esac
	$VERIFY ${only} -o $zone $file > verify.out.$n 2>&1 && ret=1
	grep "${expect1:-.}" verify.out.$n > /dev/null || ret=1
	grep "${expect2:-.}" verify.out.$n > /dev/null || ret=1
	[ $ret = 0 ] || failed
	[ $dumpit = 1 ] && cat verify.out.$n
done

echo "I:exit status: $status"
[ $status -eq 0 ] || exit 1
