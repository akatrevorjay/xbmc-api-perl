#!/usr/bin/perl
# SVN: $Id: xbmc_helper-irssi.pl 4 2006-04-11 07:01:22Z trevorj $
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

use Irssi;
use vars qw($VERSION %IRSSI);
use strict;

$VERSION = '0.2';
%IRSSI = (
  authors     => 'trevorj',
  contact     => 'trevorjoynson\@gmail.com',
  name        => 'XBMC Plugin',
  description => 'Returns XBMC Status',
  license     => 'GPL v2',
  url         => 'http://intheskywithdiamonds.net',
  changed     => 'Tue Apr 11 00:41:47 EDT 2006',
  commands    => '/song',
  note        => 'Make sure xbmc_helper is configured!'
);

sub cmd_xbmc {
  my ($args, $server, $target) = @_;
  $args =~ s/\s+$//; #fix unneeded whitespaces after output dest.

  my @output;

  open xbmc, '/home/trevorj/.irssi/scripts/xbmc_helper.pl 2>&1 |' || die;
  while (<xbmc>) {
    s/\n//;
    $output[$.] = $_;
  }
  close xbmc;

#  if(!$api{Filename}) {
#    Irssi::print "An error occurred.";
#    die;
#  }

    if(!$server || !$server->{connected}) { # are we even connected?
        Irssi::print join(@output, "\n");
        return;
    }
    if($args) {
        foreach (@output) {
            $server->command("msg $args $_");
        }
    } else {
        foreach (@output) {
            Irssi::active_win()->command('say ' . $_);
        }
    }
}

Irssi::command_bind('song', 'cmd_xbmc');
