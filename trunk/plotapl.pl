#!/usr/bin/perl -w

# Copyright 2012 Thomas H. Schmidt & Christian Kandt
#
# This file is part of InflateGRO2.
#
# InflateGRO2 is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# InflateGRO2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with InflateGRO2; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;

my $gnuplotFile = "plotapl.gnu";

my $pDataFile   = "areaperlipid.dat";
my $pRefApl     = 0.65741691015625;
my $pTerminal   = "postscript enhanced color";
my $pOutputFile = "areaperlipid.eps";
my $pTitle      = "Area per lipid during membrane shrinking";
my $pXLabel     = "Shrinking step";
my $pYLabel     = "A_{L} / nm^2";


unless (-e $pDataFile) {
    die "ERROR: Cannot find the plot data file \"$pDataFile\"\n";
}

### Create file ################################################################
open(GNUFILE, ">$gnuplotFile") || die "ERROR: Cannot open gnuplot file \"gnuplotFile\": $!\n";
print GNUFILE<<EOF;
set terminal $pTerminal
set title "$pTitle"
set xlabel "$pXLabel"
set ylabel "$pYLabel"

set output "$pOutputFile"
plot "$pDataFile" u 5 w lp t "Upper leaflet", "$pDataFile" u 7 w lp t "Lower leaflet"
f(x)=$pRefApl
set output "$pOutputFile"
replot f(x)
EOF
close(GNUFILE);
################################################################################


### Plot the gnuplot file ######################################################
system("gnuplot $gnuplotFile");
system("rm $gnuplotFile");
################################################################################

