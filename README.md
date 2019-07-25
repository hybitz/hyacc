環境構築手順
# CentOS 7 を用意
** sudo 権限を付与
<pre><notextile>
（ユーザで）$ su
（ルートで）# echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
</notextile></pre>
** Ruby環境をインストール
<pre><notextile>
$ sudo yum install git
$ git clone [https://github.com/ichylinux/daddy.git または git@github.com:ichylinux/daddy.git]
$ pushd daddy
$ bin/dad local
$ popd
</notextile></pre>
# Hyaccのインストール
** ソースを取得
<pre><notextile>
$ git clone [https://github.com/hybitz/hyacc.git または git@github.com:hybitz/hyacc.git]
$ cd hyacc
</notextile></pre>
** 各種ミドルウェアのインストール
<pre><notextile>
$ bundle install
$ rake dad:setup
</notextile></pre>
** DBの初期化
<pre><notextile>
$ rake dad:db:create
$ rails db:reset
</notextile></pre>
** テスト
<pre><notextile>
$ rails test
$ rake dad:setup:test
$ rake dad:test
</notextile></pre>
** 起動
<pre><notextile>
$ sudo systemctl restart nginx
</notextile></pre>
ブラウザから "http://localhost":http://localhost にアクセスして動作を確認します。
