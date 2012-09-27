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

my $outType = shift;
my $dir = "./";
my @files;

$outType = 'eps' unless $outType;

opendir(DIR, $dir) || die "ERROR: Cannot open directory \"$dir\": $!\n";
@files = readdir(DIR);
closedir(DIR);

foreach(@files) {
    doGnu($_, $1, $outType) if ($_ =~ /(.+)\.xy*/);
}



sub doGnu {
    my $pltFile = shift;
    my $outFile = shift;
    my $outType = shift;

    my $gnpFile = "tmp.gnp";

    $outType = 'eps' unless $outType;

    open(GNPFILE, ">$gnpFile") || die "ERROR: Cannot open gnuplot file \"$gnpFile\": $!\n";
    if ($outType eq 'png') {
        $outFile .= ".png" unless $outFile =~ /\.png/;
        print GNPFILE "set terminal png size 1000,1000\n";
    }
    else {
        $outFile .= ".eps" unless $outFile =~ /\.eps/;
        print GNPFILE "set terminal postscript enhanced\n";
    }

    print GNPFILE <<End;
set view map
set size ratio 1
set size 1.2,1.2
set origin -0.1,-0.1
set palette defined (1 "red", 2 "blue", 3 "green")
set xlabel 'x_{Box}'
set ylabel 'y_{Box}'
set xrange [0:13]
set yrange [0:13]

set output \"$outFile\"
#splot "$pltFile" u 1:2:3 w p notitle palette pointsize 0.00005 pointtype 5
splot "$pltFile" u 1:2:3 w p notitle palette pointsize 0.05 pointtype 5
End

    close(GNPFILE);

    system("gnuplot $gnpFile");
    system("rm tmp.gnp");
}

