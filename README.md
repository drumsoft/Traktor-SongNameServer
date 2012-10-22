Traktor::SongNameServer, tweet-from-traktor.pl and CamTwist "Traktor Song" plugin

日本語の説明は readme-j.txt を読んで下さい。


[Traktor::SongNameServer]
Traktor::SongNameServer is a kind of "fake" icecast server.  It receives song
names from Traktor and provides them for other applications.

It will work with other PCDJ softwares if they send icecast streaming protocols.

To run the script you need to ensure that Traktor is configured to write to the icecast server.

![](https://atmos-s3itch.s3.amazonaws.com/skitched-20121022-122238.jpg)

Enable broadcasting in Traktor's recorder panel.

![](https://atmos-s3itch.s3.amazonaws.com/Traktor-20121022-122913.jpg)

To launch server, execute it in a terminal and start playing some songs.

```
perl songnameserver.pl.
```

[tweet-from-traktor.pl]
a script to post song names played by Traktor to twitter.
This script works as server using Traktor::SongNameServer.

[CamTwist "Traktor Song" plugin]
a CamTwist plugin to display song names played by Traktor.
This plugin fetches song names from Traktor::SongNameServer. then you should run it by songnameserver.pl or tweet-from-traktor.pl.

