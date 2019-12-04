#!/usr/bin/perl
use warnings;
use strict;
use autodie;

my $lc = 0;
my $fh;
while(my $line=<>) {
	if ($lc % 1000*100 == 0) {
    mkdir "/6BT/AT/ytll-items/" . sprintf("%03d",$lc/100/1000);
    chdir "/6BT/AT/ytll-items/" . sprintf("%03d",$lc/100/1000);
  }
	if ($lc % 100 == 0) {
		#close $fh;
		open $fh, ">", sprintf("%d", ($lc/100) % 1000);
	}
	print $fh $line;
	$lc++
}
