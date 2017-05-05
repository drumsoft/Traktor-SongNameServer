# Traktor-SongNameServer

includes Traktor::SongNameServer, tweet-from-traktor.pl and CamTwist "Traktor Song" plugin

日本語の説明は readme-j.txt を読んで下さい。

# Outlines

## Traktor::SongNameServer

Traktor::SongNameServer is a kind of "fake" icecast server.  It receives song names from Traktor and provides them for other applications.

songnameserver.pl is a sample server launcher.

It will work with other PCDJ softwares if they send icecast streaming protocols.

## tweet-from-traktor.pl

a script to post song names played by Traktor to twitter.
This script works as Traktor::SongNameServer server launcher. And this is a sample program to use callback mechanism of Traktor::SongNameServer.

## CamTwist "Traktor Song" plugin

a CamTwist plugin to display song names played by Traktor.
This plugin fetches song names from Traktor::SongNameServer by HTTP and XML. You should run it by songnameserver.pl or tweet-from-traktor.pl.

# Tutorials

## running Traktor::SongNameServer by songnameserver.pl and working it with Traktor.

[preparation]
 1. Ensure that Traktor is configured to write to the icecast server. 
 [](documents/traktor-preference-broadcast.jpg?raw=true).

[start playing]
 1. To launch server, execute it in a terminal.
```
perl songnameserver.pl.
```
 2. Start broadcasting in Traktor's recorder panel
 [](documents/traktor-panel-broadcast.jpg?raw=true).

 3. Start playing some songs. The song names will be shown on server terminal with 1 song delay. and You can also get song names as XML format by accessing http://localhost:8000/ .

[advanced info]
 * If you want to change server setting, open and edit songnameserver.pl .

## using tweet-from-traktor.pl

[preparation]
 1. module Net::Twitter required. install it from CPAN.
 2. Access https://dev.twitter.com/apps and subscribe a new application. and get 4 string tokens from the application.
  * Consumer key
  * Consumer secret
  * Access token
  * Access token secret
 3. Open tweet-from-traktor.pl and write the 4 tokens in these key-values.
  * consumer_key        => '',
  * consumer_secret     => '',
  * access_token        => '',
  * access_token_secret => '',
 4. and change '$postfix' for your DJ show. (Event hashtag, your streaming address,...)

[start playing]
 1. Launch tweet-from-traktor.pl (instead of songnameserver.pl)
```
perl tweet-from-traktor.pl
```
 2. start broadcasting in Traktor.
 3. Start playing some songs and check terminal output and your tweets.

## CamTwist "Traktor Song" plugin

[preparation]
 1. Install 'Traktor Song.qtz' in 'the directory CamTwist installed/Effects' or '~/Library/Application Support/CamTwist/Effects' .

[start playing]
 1. Launch songnameserver.pl.
 2. Start broadcasting in Traktor.
 3. Start playing some songs and check terminal output.
 4. Launch CamTwist and add 'Traktor Song' effect and change displaying parameters.

