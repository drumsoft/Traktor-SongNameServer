Traktor::SongNameServer, tweet-from-traktor.pl and CamTwist "Traktor Song" plugin

[Traktor::SongNameServer]
Traktor でプレイ中の曲名を受信し、他のソフトから利用できる様にするサーバです。
他の PCDJ ソフトでも、icecastストリーミングプロトコルに対応しているものであれば動作する筈です。
起動するには songnameserver.pl を使ってください。

[tweet-from-traktor.pl]
Traktor::SongNameServer を使って、Traktor でプレイ中の曲名を Twitter にポストします。

[CamTwist "Traktor Song" plugin]
Traktor::SongNameServer と通信して、Traktor でプレイ中の曲名を CamTwist に表示します。


[概要]

Traktor::SongNameServer を起動すると icecast サーバとして動作します。

Traktor でこのサーバを Broadcasting Server に設定する事で、プレイした曲名データが Traktor::SongNameServer に送信されます。

CamTwist "Traktor Song" plugin は Traktor::SongNameServer から曲名情報を取得します。

tweet-from-traktor.pl は Traktor::SongNameServer からコールバックされ、Twitterに曲名情報を含むツイートをポストします。

　　　　　　┌────────────┐Callback┌───────────┐
　　　　　　│Traktor::SongNameServer │------→│tweet-from-traktor.pl │
　　　　　　└────────────┘　　　　└───────────┘
UPSTREAM DJing↑　　　　　↓FETCH song info
　　　　┌──┴─┐　┌─┴───────┐
　　　　│Traktor │　│Traktor Song plugin│
　　　　└────┘　└─────────┘


[マニュアル]
下記 [Adv.] がついている項目は、「よくわかってる人」向けの説明です。


[A: Traktor::SongNameServer を使える様にしよう]

A-1. インストールと設定
	このフォルダを任意の場所に置く
	[Adv.] songnameserver.pl を開いて、設定を変更する
		host, port: サーバの待ち受けアドレスとポート番号
		※ここを変更した場合は以下の "localhost" "8000" を変更した物に読み替える
	（WindowsやLinuxの人は、Perlをインストールしておく）

A-2. Traktor のストリーミング設定を行う
	Preference > Broadcasting > Server Settings
		Address: localhost  Port: 8000
		Password: 空白
		Format: Ogg Vorbis, 11025 Hz, 32kBit/s

A-3. Traktor::SongNameServer を起動
	ターミナルで perl songnameserver.pl を実行

A-4. Traktor でストリーミングを開始する
	AUDIO RECORDER ペインを開き、STREAMINGボタンを押す
	ストリーミングに成功するとボタンが光る
	（失敗すると、ボタンは点滅する）

A-5. 曲名を更新させて、表示を確認する
	曲を 2, 3 曲再生すると、曲名が更新される。
	更新された曲名は songnameserver.pl を実行中のターミナルに表示される。
	また、ブラウザで http://localhost:8000/ にアクセスすると曲名が表示される。


[B: CamTwist "Traktor Song" plugin を使おう]

B-1. Traktor Song.qtz をインストール
	下記のどちらかに Traktor Song.qtz ファイルを置く
		・ CamTwist インストールフォルダの Effects フォルダ
		・ ~/Library/Application Support/CamTwist/Effects

B-2. Traktor からストリーミングを開始する
	A-3, A-4 を行ってください。

B-3. CamTwist で "Traktor Song" エフェクトをADDして、好みの表示設定にする
	[Adv.] ホストやポート名の設定を変えた場合は "icecast URL" を変更する
	文字サイズや表示位置などを調整する

曲名が更新されると CamTwist の画面に反映されます。
二回目以降は B-2 から行ってください。


[C: tweet-from-traktor.pl を使おう]

C-1. Net::Twitter モジュールのインストール
	cpan や cpanm を使い Net::Twitter をインストールする

C-2. Twitter アプリケーションを登録
	https://dev.twitter.com/apps にアクセスして、Twitterへポスト
	するための新しいアプリケーションを登録する
	登録したアプリケーションのページから、以下を取得する
		Consumer key
		Consumer secret
		Access token
		Access token secret

C-2. tweet-from-traktor.pl を設定
	tweet-from-traktor.pl を開き、取得した4つの文字列を
	consumer_key        => '',
	consumer_secret     => '',
	access_token        => '',
	access_token_secret => '',
	に設定する。
	また A-1 で行った設定があれば、 songnameserver.pl にも同じ設定を行う。
	【重要】 $postfix をいい感じにする（イベントのハッシュタグとか）

C-3. tweet-from-traktor.pl を起動
	ターミナルで perl tweet-from-traktor.pl を実行
	(tweet-from-traktor.pl が Traktor::SongNameServer を起動するので、
	 songnameserver.pl は使いません)

C-4. Traktor からストリーミングを開始する
	A-4 を行ってください。

曲名が更新されると、Twitterにポストされます。
二回目以降は C-3 から行ってください。


[D: songnameserver.pl や tweet-from-traktor.pl の設定項目]

("cue" 内、曲名変更キューの動作)
Traktor からの曲名の送信は「次の曲をデッキにロードして、再生ボタンを押してから数秒後」に行われます。このため、Traktorから曲名を受信した直後に曲名表示を更新してしまうと、リスナーがまだ耳にしていない、次の曲が表示されてしまう事になります。
これを回避するため Traktor::SongNameServer は曲名の更新を遅延させるキューを持っています。以下の設定項目は、このキューの動作を設定します。

bysong: 曲名の更新を、n曲分遅らせる
bytime: 曲名の更新を、n秒遅らせる
両方を設定すると、加算された時間遅れます。bysong => 1, bytime => 30 の場合、次の曲が再生され始めて約30秒後に、現在の曲名が表示される様になります。

nextsongtimeout: "bysong" が設定されている時、次の曲がn秒プレイされなかったら、その設定を無視して曲名を更新する - 最後にかけた曲の曲名が更新されない問題を防ぐ為の設定項目です。 0 にすると設定が無効になり、永遠に次の曲を待ちます。
ignoreshortplay: n秒未満しか再生されなかった曲は、プレイされなかった事にする - デッキに乗せて再生したが、モニタで確認してかけるのをやめた曲の曲名を表示させないための設定項目です。 0 にすると設定が無効になり、プレイ時間がどれだけ短い曲名でも表示されます。

(ネットワーク設定)
host: 待ち受けIPアドレス
port: 待ち受けポート番号
(動作設定)
buffer_size: 読み出しバッファのサイズ
timeout:     select システムコールの待ち時間(秒)
callback:    曲名変更時に呼ばれるコールバック
