#!/usr/bin/perl
# SVN: $Id: xbmc_helper.pl 4 2006-04-11 07:01:22Z trevorj $
# ____________
# XBMC::Api Irssi Script
# ~trevorj <[trevorjoynson@gmail.com]>
#
#	Copyright 2006 Trevor Joynson
#
#	This file is part of XBMC::Api.
#
#	XBMC::Api is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	XBMC::Api is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with XBMC::Api; if not, write to the Free Software
#	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

# unless XBMC::Api is in your @INC, set this to the path of the dir with XBMC/Api.pm in it.
# ( if you are unsure, it's not in @INC, so do it. )
BEGIN {
	unshift( @INC, "/home/trevorj/code/perl/xbmc" );
}
use XBMC::Api;

# Grab the tags from our xbmcapi instance
my $xbmc = XBMC::Api->new( xbox => 'xbox' );
my %api = $xbmc->gettagsfromcurrentlyplaying() or die;
undef $xbmc;

# Percentage
my $t_per;
$t_per = ' \00314(\017' . $api{Percentage} . '%\00314)'
  if ( exists $api{Percentage} );

# Title
my $t_title = $api{Title} || 'Weird';
if ( exists $api{Artist} ) {
	$t_title = $api{Artist} . ' \00314- \017' . $t_title;
}

# Color test
#my @colors = ("\0031","\0035","\0033","\0037","\0032","\0036","\00310","\0030","\00314","\0034","\0039","\0038","\00312","\00313","\00311","\00315","\017");
#$output[0] = join("omg color", @colors);

# Output
my $output;
$output =
    '\00314XBMC: \017$t_title \00314(\017'
  . $api{Status}
  . '\00314)' . "\n"

  # Line 2
  . '\00314Time: \017'
  . $api{Time}
  . '\00314/\017'
  . $api{Duration}
  . $t_per
  . '\00314; Type: \017'
  . $api{Type}
  . '\00314; Id3: \017'
  . $api{ID3}
  . '\00314;';
undef %api;
undef $t_per;
undef $t_title;

print $output;
undef $output;
