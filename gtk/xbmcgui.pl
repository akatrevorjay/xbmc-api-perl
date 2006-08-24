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
package main;

# unless XBMC::Api is in your @INC, set this to the path of the dir with XBMC/Api.pm in it.
# ( if you are unsure, it's not in @INC, so do it. )
BEGIN {
	unshift( @INC, "/home/trevorj/code/perl/xbmc" );
}
use XBMC::Api;
use warnings;
use strict;

# for glade files using gnome widgets, you must initialize Gnome2
# before loading the glade file.
use Gnome2;
use Gtk2::GladeXML;

my $appname = 'xbmcgui';
my $version = '0.01';

# this call also initializes gtk+ for us
Gnome2::Program->init( $appname, $version );
my $gladexml = Gtk2::GladeXML->new('xbmc.glade');

# Grab an xbmcapi instance
my $xbmc = XBMC::Api->new( xbox => 'xbox' );

# cache some widgets
my $label_artist   = $gladexml->get_widget('label_artist');
my $label_title    = $gladexml->get_widget('label_title');
my $label_duration = $gladexml->get_widget('label_duration');
my $progressbar1   = $gladexml->get_widget('progressbar1');
my $label_id3      = $gladexml->get_widget('label_id3');
my $label_status   = $gladexml->get_widget('label_status');

# set up a 'refresh' timer to check for new files
Glib::Timeout->add( 3000, \&update_currentlyplaying );
$gladexml->signal_autoconnect_from_package('main');

Gtk2->main;
exit 0;

use Data::Dumper;
sub update_currentlyplaying {
	my %api = $xbmc->gettagsfromcurrentlyplaying() or return 1;

	$label_artist->set_text( $api{Artist} );
	$label_title->set_text( $api{Title} );
	$label_duration->set_text( $api{Time} . '/' . $api{Duration} );

	$label_id3->set_text(
		( defined $api{ID3} && $api{ID3} eq 'Yes' ) ? 'ID3' : '' );
	$label_status->set_text( ( defined $api{Status} ) ? $api{Status} : 'wtf' );

print Dumper( \%api );

	$progressbar1->set_fraction( int( $api{Percentage} ) / 100 )
	  if defined $api{Percentage};
	return 1;
}

sub on_button1_clicked {
	my ( $widget, $event ) = @_;
	update_currentlyplaying();
}

# Handles window-manager-quit: shuts down gtk2 lib
# To quit the application
sub on_window1_delete_event {
	Gtk2->main_quit;
}

1;
