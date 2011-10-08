CamTwist "icecast Song" plugin

Traktor でプレイ中の曲名を CamTwist に表示させる事ができます。

他の PCDJ ソフトでも、icecastストリーミングプロトコルに対応しているものであれば動作する筈です。

TweetFromTraktor.pl を追加しました。これはプレイ中の曲名をさらに twitter にポストする為のスクリプトです。


[概要]

"icecast Song" は TRAKTOR(等のPCDJ)で再生中の曲名情報を icecast2 サーバから取得します。
TRAKTORはプレイ中のサウンドを曲名情報と一緒に icecast2 サーバにストリーミング送信します。

　　　　　　┌───────┐
　　　　　　│icecast2サーバ│
　　　　　　└───────┘
UPSTREAM DJing↑　　　　　↓FETCH song info
　　　　┌──┴─┐　┌─┴────────┐
　　　　│TRAKTOR │　│icecast Song plugin │
　　　　└────┘　└──────────┘

icecast2 は MacPorts からインストールすると簡単です。
MacPortsの使い方は検索して下さい。


[マニュアル]
下記 [Adv.] がついている項目は、 icecast2 を Macports を使わずにインストールしたり、サーバのポート番号を変更したりといった事をする「よくわかってる人」向けの説明です。


A.インストール

A-1. icecast2 をインストールする
	MacPorts でインストールする場合
		sudo port install icecast2

	[Adv.]ソースからインストールした場合等は、以下の /opt/local/.. を適宜 /usr/local/.. 等に読み替える事

A-2. icecast2 の status.xsl を同梱の物に置き換える
	status.xsl は以下にインストールされているので、これを置き換える
		/opt/local/share/icecast/web/

A-3. icecast2 の設定を行う
	/opt/local/etc/icecast.xml を変更する
	authenticationブロックのパスワードを設定する(必須)

	[Adv.]もしも必要なら以下も変更する
		hostname
		listen-socket ブロックの port (ポート番号)
		ここを変更した場合は以下の "localhost" "8000" を変更した物に読み替える事

A-4. icecast2 のログ出力先を作る
	icecast2のログファイルの出力先
		/opt/local/var/log/icecast/
	が必要なのでこれを作る
		mkdir -p /opt/local/var/log/icecast
	自分が書き込めるパーミッションを設定する。

A-5. icecast Song.qtz をインストールする
	下記のどちらかに icecast Song.qtz ファイルを置く
		CamTwist インストールフォルダの Effects フォルダ
		~/Library/Application Support/CamTwist/Effects


B.icecast2 のテスト

B-1. Traktor のストリーミング設定を行う
	Preference > Broadcasting > Server Settings
		Address: localhost  Port: 8000
		Password: A-3で設定したもの
		Format: 音は聴かないので何でも良い

B-2. icecast2 を起動する
	icecast -c /opt/local/etc/icecast.xml

B-3. Traktor でストリーミングを開始する
	AUDIO RECORDER ペインを開き、STREAMINGボタンを押す
	ストリーミングに成功するとボタンが光る

B-4. ブラウザでストリーミングの曲名を確認する
	ブラウザで下記のアドレスを開く
		http://localhost:8000/
	下記の様な曲名を載せたXMLファイルが見えたら成功
	<status>
		<source>
			<mountpoint>/</mountpoint>
			<artist>takuya</artist>
			<title>364 Nights</title>
		</source>
	</status>

	なお、曲名が更新されるタイミングは「新しく曲をデッキにロードして、デッキを再生してしばらく後」なので、テストの際はストリーミング開始後に必ず曲をデッキにロードしてから再生する必要がある


C. "icecast Song" プラグインの使用手順

C-1. icecast2 を起動する(参照:B-2)

C-2. Traktor からストリーミングを開始する(参照:B-3)

C-3. CamTwist で "icecast Song" エフェクトをADDする

C-4. [Adv.] A-3でホストやポート名の設定を変えた場合は "icecast URL" を変更する

C-5. 必要なら "icecast Song" の文字サイズや表示位置などを調整する

