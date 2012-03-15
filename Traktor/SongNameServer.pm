use strict;
use warnings;
use utf8;

package Traktor::SongNameServer;

use IO::Socket;
use IO::Select;

sub new {
	my $class = shift;
	my %options = @_;
	return bless {
		host => $options{host} || 'localhost',
		port => $options{port} || 8000,
		buffer_size => $options{buffer_size} || 8192,
		timeout     => $options{timeout} || 1,
		cueoptions  => $options{cue} || {},
		callback    => $options{callback} || sub{},
		song_artist => '',
		song_title  => '',
	}, $class;
}

sub run {
	my $self = shift;

	my $cue = Traktor::SongNameServer::SongCue->new(
		%{$self->{cueoptions}}, 
		callback => sub {
			my $song = shift;
			$self->{song_artist} = $song->{ARTIST};
			$self->{song_title}  = $song->{TITLE};
			$self->{callback}->($song);
		}
	);

	my $sock_listen = new IO::Socket::INET(Listen=>5,
		LocalAddr => $self->{host},
		LocalPort => $self->{port},
		Proto => 'tcp',
		Reuse => 1);

	die "IO::Socket : $!" unless $sock_listen;

	my %workers;

	my $selector = new IO::Select( $sock_listen );

	while(1) {
		my (@ready) = $selector->can_read($self->{timeout});
		foreach my $sock (@ready) {
			if($sock == $sock_listen) {
				my $newsock = $sock_listen->accept;
				$selector->add($newsock);
				$workers{$newsock} = Traktor::SongNameServer::Worker->new($newsock, $self, $cue, $self->{buffer_size});
			} else {
				if ( ! $workers{$sock}->read() ) {
					$workers{$sock}->finalize();
					delete $workers{$sock};
					$selector->remove($sock);
					$sock->close();
				}
			}
		}
		$cue->noop();
	}

	close($sock_listen);
}


package Traktor::SongNameServer::Worker;
use IO::Socket;
use Encode qw/encode decode/;

sub new {
	my $class = shift;
	my $sock = shift;
	my $server = shift;
	my $cue = shift;
	my $buffer_size = shift;
	my ($cl_port,$cl_iaddr) = unpack_sockaddr_in($sock->peername());

	my $self = bless {
		sock   => $sock,
		server => $server,
		cue    => $cue ,
		buffer_size => $buffer_size,
		client => inet_ntoa($cl_iaddr) . ':' . $cl_port,
		input  => '',
		status => 'start', # 'start', 'header', 'data', 'meta', 'end'
		mode   => 'get'  , # 'source', 'get'
	}, $class;
	return $self;
}

sub read {
	my $self = shift;
	my $buf;
	my $length = sysread($self->{sock}, $buf, $self->{buffer_size});
	if ( $length > 0 ) {
		$self->{input} .= $buf;
	}
	my $keepconnect = $self->process();
	
	return $length && $keepconnect;
}

sub finalize {
	my $self = shift;
	$self->process();
	if ( $self->{mode} eq 'source' ) {
		print "[source disconnected from $self->{client}]\n";
	}
}

sub escape {
	my $s = shift;
	$s =~ s/&/&amp;/;
	$s =~ s/"/&quot;/; #"
	$s =~ s/</&lt;/;
	$s =~ s/>/&gt;/;
	$s;
}

sub response_songname {
	my $self = shift;
	my $out = $self->{sock};
	print  $out "HTTP/1.0 200 OK\r\n\r\n";
	print  $out qq{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\r\n};
	printf $out qq{<status><source><artist>%s</artist><title>%s</title></source></status>\r\n}, 
		encode('utf8',escape($self->{server}->{song_artist})), 
		encode('utf8',escape($self->{server}->{song_title}));
}

sub response_ok {
	my $self = shift;
	my $out = $self->{sock};
	print $out "HTTP/1.0 200 OK\r\n\r\n";
}

sub process {
	my $self = shift;
	while( 1 ) {
		if ( $self->{status} eq 'start' || $self->{status} eq 'header' ) {
			if ($self->{input} =~ s/^(.*?)\r\n//) {
				# print $1, "\n";
				if ( $self->{status} eq 'start' ) {
					$self->{mode} = ($1 =~ /^SOURCE /i) ? 'source' : 'get';
					$self->{status} = 'header';
					if ( $self->{mode} eq 'source' ) {
						print "[source connected from $self->{client}]\n";
					}
				} elsif ( ! defined $1 || $1 eq '' ) { # end of header
					if ( $self->{mode} eq 'source' ) {
						$self->response_ok();
						$self->{status} = 'data';
					} else {
						$self->response_songname();
						$self->{status} = 'end';
						return 0;
					}
				}
			} else {
				last;
			}
		} elsif ( $self->{status} eq 'data' ) {
			if ($self->{input} =~ s/^(?:.*?)(....)(ARTIST|TITLE)=//s) {
				$self->{status} = 'meta';
				$self->{metaname} = decode('utf8', $2);
				$self->{metalength} = unpack('V',$1) - length($self->{metaname}) - 1;
			} else {
				if ( length($self->{input}) > 11 ) {
					$self->{input} = substr($self->{input}, -11);
					$self->{cue}->finish();
				}
				last;
			}
		} elsif ( $self->{status} eq 'meta' ) {
			if ( length($self->{input}) >= $self->{metalength} ) {
				my $metatext = decode('utf8', substr($self->{input}, 0, $self->{metalength}));
				$self->{input} = substr($self->{input}, $self->{metalength});
				$self->{status} = 'data';
				$self->{cue}->add($self->{metaname}, $metatext);
			} else {
				last;
			}
		} else { # end
			return 0;
		}
	}
	return 1;
	#	(4byte/文字数 リトルエンディアン)(文字数byte/"(ARTIST|TITLE)=文字列")
}


package Traktor::SongNameServer::SongCue;

sub new {
	my $class = shift;
	my %options = @_;
	my $self = bless {
		bysong => $options{bysong} || 0,
		bytime => $options{bytime} || 0,
		nextsongtimeout => $options{nextsongtimeout} || 0,
		ignoreshortplay => $options{ignoreshortplay} || 0,
		callback => $options{callback} || undef,
		cue => [],
		new => {},
	}, $class;
	return $self;
}

sub add {
	my ($self, $name, $text) = @_;
	$self->{new}->{$name} = $text;
}

sub finish {
	my $self = shift;
	if (keys %{$self->{new}}) {
		my $now = time();
		if ( $self->{ignoreshortplay} && @{$self->{cue}} && 
		     $self->{ignoreshortplay} > $now - $self->{cue}->[-1]->{time} ) {
			pop @{$self->{cue}};
		}
		$self->{new}->{time} = $now;
		push @{$self->{cue}}, $self->{new};
		$self->{new} = {};
	}
}

sub noop {
	my $self = shift;
	my $now = time();
	if ( @{$self->{cue}} ) {
		if ( $self->{bysong} < @{$self->{cue}} ) {
			if (!$self->{bytime} || 
			     $self->{bytime} < $now - $self->{cue}->[$self->{bysong}]->{time} ) {
				$self->fire();
			}
		}elsif ($self->{nextsongtimeout} && 
		        $self->{nextsongtimeout} < $now - $self->{cue}->[0]->{time} ) {
				$self->fire();
		}
	}
}

sub fire {
	my $self = shift;
	$self->{callback}->(shift @{$self->{cue}});
}

1;


