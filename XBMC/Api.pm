#!/usr/bin/perl
# SVN: $Id: Api.pm 9 2006-05-25 18:45:07Z trevorj $
# _________
# XBMC::Api
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
package XBMC::Api;
use Net::HTTP;
use Carp qw(croak cluck);
use AutoLoader;
use warnings;
use strict;
no strict 'refs';
use vars qw($AUTOLOAD);

# This lets us make up api function names
sub AUTOLOAD {
	my $self   = shift;
	my $method = $AUTOLOAD;
	$method =~ s/^.*://;

	#print "autoload: $method\n";
	# is a regex any faster than substr? or is it faster this way?
	#if (substr($method, 0, 5) eq 'xbmc_') {
	unless ( $self->can($method) ) {
		$self->xbmcapi( $method, @_ );
	} else {
		$self->$method(@_);
	}
}
sub DESTROY { }

# Borrowed from PoCo::IRC::Object
sub new {
	my $class = shift;
	die __PACKAGE__ . "->new() params must be a hash" if @_ % 2;
	my %params = @_;

	my $self = bless \%params, $class;
	$self->init();
	return $self;
}

sub init {
	my $self = shift;
	$self->{xbox} = 'xbox' unless ( defined $self->{xbox} );
}

# striphtml($html)
# - strips $html of, well, html.
#
sub striphtml {
	my ( $self, $ret ) = @_;
	$ret =~ s/<[^>]*>//g;
	return $ret;
}

# parseapi($xbmcapi)
# - parses output of xbmcapi and returns a hash
# - ex: %hash('Filename' => 'proto://host/path/to/filename.ogg')
sub parseapi {
	my ( $self, $api ) = @_;
	$api = $self->striphtml($api);

	my %ret = ();
	my @tmp = split( /\n/, $api );
	foreach (@tmp) {
		if (/^([^:]*):\s*(.*)$/) {
			$ret{$1} = $2;
		}
	}
	undef @tmp;
	undef $api;

	return %ret;
}

# xbmcapi_raw($cmd, $params)
# - grabs the raw output (html) from an httpapi request
#
sub xbmcapi_raw {
	my ( $self, $cmd ) = splice @_, 0, 2;
	my $params = shift;

	# Add params to $cmd, along with some magic.
	if ($params) {

		#TODO array @param ( params are seperated by ;s)
		#map { $_ =~ s/ /\%20/g; } @param;

		$params =~ s/ /\%20/g;
		$cmd .= '&parameter=' . $params;
		undef $params;
	}

	# SSDD
	my $http = Net::HTTP->new( Host => $self->{xbox} )
	  or croak 'Xbox unavailable';
	$http->write_request(
		GET          => '/xbmcCmds/xbmcHttp?command=' . $cmd,
		'User-Agent' => "Mozilla/5.0"
	);
	undef $cmd;
	$http->read_response_headers;

	my $ret;
	while (1) {
		my $buf;
		my $n = $http->read_entity_body( $buf, 1024 ) or last;
		$ret .= $buf;
		undef $buf;
	}

	#print $ret. "\n";
	undef $http;

	return $ret;
}

# xbmcapi($cmd, [$param])
# - wrapper around the api funcs
# - returns the output of parseapi
#
sub xbmcapi {
	my ( $self, $cmd ) = splice @_, 0, 2;
	if ( $cmd eq 'getcurrentlyplaying' ) {
		my %ret = $self->parseapi( $self->xbmcapi_raw( $cmd, shift ) );

	 # I really don't like the way it outputs the status, so lets make it better
	 # wtf??? this isn't in new versions of httpapi???
		if ( exists $ret{Playing} && $ret{Playing} eq 'True' ) {
			if ( exists $ret{Paused} && $ret{Paused} eq 'True' ) {
				$ret{Status} = 'Paused';
			} else {
				$ret{Status} = 'Playing';
			}
		} else {
			$ret{Status} = 'Stopped';
		}

		return %ret;
	} elsif ( $cmd eq 'gettagsfromcurrentlyplaying' ) {
		my %s_curr = $self->getcurrentlyplaying;
		if ( exists $s_curr{'Filename'} ) {
			my %s_tags = $self->gettagfromfilename( $s_curr{'Filename'} );
			if ( exists $s_tags{'Error'} ) {

				# I hate this hack.
				if (   ( $s_curr{'Filename'} =~ /\/([^\/]+)\.[^.]+$/ )
					|| ( $s_curr{'Filename'} =~ /\\([^\\]+)\.[^.\\]+$/ ) )
				{
					$s_tags{'Title'} = $1;
				}
				$s_curr{ID3} = "No";
			} else {
				$s_curr{ID3} = "Yes";
			}
			map { $s_curr{$_} = $s_tags{$_}; } keys(%s_tags);
			undef %s_tags;
			return %s_curr;
		} else {
			return undef;
		}
	} else {
		return $self->parseapi( $self->xbmcapi_raw( $cmd, shift ) );
	}
}

1;
