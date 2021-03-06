#!/usr/bin/perl
#
# Copyright (C) 2015-2017  Internet Systems Consortium, Inc. ("ISC")
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# server-xml.pl:
# Parses the XML version of the server stats into a normalized format.

use XML::Simple;

my $ref = XMLin("xml.stats");
my $counters = $ref->{server}->{counters};
foreach $group (@$counters) {
    foreach $key (keys %{$group->{counter}}) {
        print $group->{type} . " " . $key . ": ". $group->{counter}->{$key}->{content} . "\n";
    }
}
