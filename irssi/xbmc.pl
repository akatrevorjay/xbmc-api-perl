#!/usr/bin/perl
# SVN: $Id: xbmc.pl 8 2006-04-11 08:47:13Z trevorj $
# ____________
# XBMC::Api Irssi Plugin
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
#	Lucy is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with Lucy; if not, write to the Free Software
#	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#TODO I really hate this script. There has to be a better way.

use Irssi;
use vars qw($VERSION %IRSSI);
use warnings;
use strict;

$VERSION = '0.2';
%IRSSI   = (
	authors     => 'trevorj',
	contact     => 'trevorjoynson\@gmail.com',
	name        => 'XBMC::Api plugin',
	description => 'Returns XBMC Status',
	license     => 'GPL v2',
	url         => 'http://intheskywithdiamonds.net',
	changed     => 'Tue Apr 11 00:41:47 EDT 2006',
	commands    => '/song',
	note        => 'Make sure your xbox hostname is configured!'
);

# unless XBMC::Api is in your @INC, set this to the path of the dir with XBMC/Api.pm in it.
# ( if you are unsure, do it. )
BEGIN {
	unshift( @INC, "/home/trevorj/code/perl/xbmc" );
}
use XBMC::Api;

sub cmd_song {
	my ( $args, $server, $target ) = @_;
	$args =~ s/\s+$//;    #fix unneeded whitespaces after output dest.

	# Grab the tags from our xbmcapi instance
	my $xbmc = XBMC::Api->new( xbox => 'xbox' );
	my %api = $xbmc->gettagsfromcurrentlyplaying() or return;
	undef $xbmc;

	# Output
	my $c0 = "\00314";
	my $c1 = "\017";
	my @output;

### LINE 0 ###
	$output[0] = $c0 . 'XBMC: ';

	# Artist
	$output[0] .= $c1 . $api{Artist} . ' ' . $c0 . '- '
	  if ( exists $api{Artist} );

	# Title
	$output[0] .= $c1 . $api{Title} . ' '
	  if ( exists $api{Title} );

	# Status
	$output[0] .= $c0 . '(' . $c1 . $api{Status} . $c0 . ')';

### LINE 1 ###
	# Time, Duration, Percentage
	$output[1] .=
	    $c0 . 'Time: ' . $c1
	  . $api{Time}
	  . $c0 . '/'
	  . $c1
	  . $api{Duration}
	  . $c0 . ' ('
	  . $c1
	  . $api{Percentage} . '%'
	  . $c0 . '); '
	  if ( exists $api{Time}
		&& exists $api{Duration}
		&& exists $api{Percentage} );

	# Type
	$output[1] .= $c0 . 'Type: ' . $c1 . $api{Type} . $c0 . '; '
	  if ( exists $api{Type} );

	# ID3
	$output[1] .= $c0 . 'Id3: ' . $c1 . $api{ID3}
	  if ( exists $api{ID3} );

	undef %api;
	undef $c0;
	undef $c1;

	if ( !$server || !$server->{connected} ) {    # are we even connected?
		Irssi::print join( "\n", @output );
		undef @output;
		return;
	}
	if ($args) {
		map { $server->command("msg $args $_"); } @output;
	} else {
		map { Irssi::active_win()->command( 'say ' . $_ ); } @output;
	}
	undef @output;
}

Irssi::command_bind( 'song', 'cmd_song' );
