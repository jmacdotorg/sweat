#!/usr/bin/env perl

use warnings;
use strict;
use v5.10;

use FindBin;

use Sweat;

use Test::More;

my $sweat = Sweat->new(
    drill_count => 13,
    speech_program => "$FindBin::Bin/bin/noop",
    drill_length => 0,
    rest_length => 0,
    side_switch_length => 0,
    drill_prep_length => 0,
    entertainment => 0,
);

$sweat->sweat;

ok(1);

done_testing();
