CamTwist "icecast Song" plugin

Traktor でプレイ中の曲名を CamTwist に表示させる事ができます。

他の PCDJ ソフトでも、icecastストリーミングプロトコルに対応しているものであれば動作する筈です。


A.インストール

A-1. icecast2 をインストールする
	MacPorts でインストールする場合
		sudo port install icecast2
	ソースからインストールした場合等は、以下の /opt/local/.. を適宜 /usr/local/.. 等に読み替える事

A-2. icecast2 の status.xsl を同梱の物に置き換える
	MacPorts でインストールした場合は以下にある
		/opt/local/share/icecast/web/

A-3. icecast2 の設定を行う
	/opt/local/etc/icecast.xml を変更する
	authenticationブロックのパスワードを設定する
	必要なら以下も変更する
		hostname
		listen-socket ブロックの port (ポート番号)
	起動時にログファイルの出力先
		/opt/local/var/log/icecast/
	が必要なので、作るか path ブロックのログ出力設定を変更しておく。パーミッション設定にも注意。

A-4. icecast Song.qtz をインストールする
	下記のどちらかにインストール
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
	ブラウザで下記のアドレスを開く（A-3で設定を変えた場合は異なる）
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

1. icecast2 を起動する(参照:B-2)

2. Traktor からストリーミングを開始する(参照:B-3)

3. CamTwist で "icecast Song" エフェクトをADDする

4. "icecast Song" の詳細パラメータ（文字サイズや表示位置など）を変更する


