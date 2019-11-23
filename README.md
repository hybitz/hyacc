# 環境構築手順
## CentOS 7 を用意
### sudo 権限を付与
```
（ユーザで）$ su
（ルートで）# echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
```
### Ruby環境をインストール
```
$ sudo yum install git
$ git clone [https://github.com/ichylinux/daddy.git または git@github.com:ichylinux/daddy.git]
$ pushd daddy
$ bin/dad local
$ popd
```
## Hyaccのインストール
### ソースを取得
```
$ git clone [https://github.com/hybitz/hyacc.git または git@github.com:hybitz/hyacc.git]
$ cd hyacc
```
### 各種ミドルウェアのインストール
```
$ bundle
$ bundle exec rake dad:setup
```
### DBの初期化
```
$ bundle exec rake dad:db:create
$ bundle exec rails db:reset
```
### テスト
```
$ bundle exec rails test
$ bundle exec rake dad:setup:test
$ bundle exec rake dad:test
```
### 起動
```
$ sudo systemctl restart nginx
```
ブラウザから http://localhost にアクセスして動作を確認します。
