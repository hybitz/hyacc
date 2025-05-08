# 環境構築手順
## AlmaLinux 8 を用意
### sudo 権限を付与
```
（ユーザで）$ su
（ルートで）# sed -i -e 's/\(\/sbin:\/bin:\/usr\/sbin:\/usr\/bin\)$/&:\/usr\/local\/bin/' /etc/sudoers
（ルートで）# echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
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
$ bundle config without 'itamae'
$ bundle -j2
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
$ bin/rails s
```
ブラウザから http://localhost:3000 にアクセスして動作を確認します。
