#!/usr/bin/perl

use LWP::Simple;
use Net::Twitter;
use Data::Dumper;

my $delay = 1; # tweet will be delayed for N song loadings.
my $pollinginterval = 15; # in seconds
my $postfix = " #HashTagOfMyTraktorPlay"; # postfix of tweets
my $url = "http://localhost:8000/"; # stream url

# create your new application and 
# get information from https://dev.twitter.com/apps
my $nt = Net::Twitter->new(
	traits   => [qw/OAuth API::REST/],
	consumer_key        => '',
	consumer_secret     => '',
	access_token        => '',
	access_token_secret => '',
);

sub main {
	my $prev = "";
	my @cur = ();
	while(1) {
		my $tr = getTrackName();
		if ( defined $tr ) {
			if ($prev ne $tr) {
				unshift @cue, $tr;
				$prev = $tr;
			}
			if (@cue > $delay) {
				$tr = pop @cue;
				tweet($tr);
			}
		}
		sleep($pollinginterval);
	}
}

sub getTrackName {
	my $src = get($url);
	my $artist = $src =~ /<artist>([^<>]+)<\/artist>/ ? 
		$1 : undef;
	my $title  = $src =~ /<title>([^<>]+)<\/title>/   ? 
		$1 : undef;
	return $artist && $title ? 
		qq{$artist / "$title"} : undef;
}

sub tweet {
	my $tw = (shift) . $postfix;
	my $result = $nt->update($tw);
	print $tw . "\n";
}

main();

__END__

TweetFromTraktor.pl

[概要]
twitterに、Traktorでプレイ中の曲名をポストするスクリプトです。

TweetFromTraktor.pl は起動しっぱなしになり、定期的に Traktor からのストリームの曲名をチェックし、変更があったら Twitter にポストします。

曲名の変更はデフォルトで1曲分遅れるので、デッキにセットしてチェック・調整中の曲名が流される事はありません。その曲のプレイが始まって、次にかける曲をチェック・調整し始めたあたりで Tweet が行われます。


[使い方]
1. https://dev.twitter.com/apps にアクセスして、Twitterへポストするための新しいアプリケーションを登録する

2. 同サイトから下記を取得して設定に記入
	Consumer key
	Consumer secret
	Access token
	Access token secret

3. $postfix 等を調整する（イベントのハッシュタグにするとか）

4. CamTwist "icecast Song" plugin のマニュアル記載の方法で修正した icecast を起動し Traktor からストリームを行う（ readme-j.txt 記載の C-1, C-2 の手順）

5. TweetFromTraktor.pl を起動する（起動しっぱなしになる）

