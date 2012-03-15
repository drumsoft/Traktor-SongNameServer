#!/usr/bin/perl

use strict;
use warnings;
use Traktor::SongNameServer;
use Encode qw/encode/;

my %option = (
	host => 'localhost', # server address
	port => 8000,        # server port

	cue => {
		# Song Name Cue Setting - song names are cued and displayed after delay.
		# delay <bysong> songs to display song names.
		bysong => 1, 
		# delay <bytime> seconds to display song names.
		bytime => 0, 
		# when both <bysong> and <bytime> are not zero, they are summed.
		# when <bysong> is not zero and next song are not coming, 
		# cued songname will be displayed after <nextsongtimeout> seconds.
		# 0 means no timeout.
		nextsongtimeout => 180, 
		# when song played shorter than <ignoreshortplay> seconds, ignore it.
		# 0 means nothing ignored.
		ignoreshortplay => 5,  
	},

	buffer_size => 8192, # stream receive buffer size
	timeout => 1,        # stream receive loop timeout in second
	callback => sub {
		my $song = shift;
		print encode('utf8', qq{[song changed: $song->{ARTIST} / "$song->{TITLE}"]\n});
	},   # callback for song name changed.
	     # an argument is {ARTIST=>'...', TITLE=>'...'}.
);

my $server = Traktor::SongNameServer->new(%option);
$server->run();

