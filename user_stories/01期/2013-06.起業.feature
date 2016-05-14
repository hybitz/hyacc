# language: ja

機能: 起業

  シナリオ: 会社の経営を開始
    * Hyaccインストール後の最初のアクセス時に、初期設定が表示される
    * 会社情報を登録
      | 会社名　　　　 | テスト会社 |
      | 事業開始年月日 | 2013-06-15 |
      | 事業形態　　　 | 株式会社 |
      | 消費税　　　　 | 非課税 |
      | 代表者　姓　　 | 経理 |
      | 代表者　名　　 | 太郎 |
      | 性別　　　　　 | 男 |
      | 生年月日　　　 | 1970-02-28 |
      | ログインID　  | keiri |
      | パスワード　　 | testtest |
      | メールアドレス | keiri@example.com |
    * ログイン画面が表示されるので、登録したログインIDとパスワードでログイン

  シナリオ: 本社を登録
    * 法務局に提出する「商業・法人登記申請」に記した本社を登録

  シナリオ: 資本金の登録
    会社の設立に必要な資金を登録する。

    * 金融機関を登録
    * 口座を登録
    * 資本金の仕訳を登録
      | 借方     | 金額      | 貸方   | 金額      |
      | 普通預金 | 2,000,000 | 資本金 | 2,000,000 |

  シナリオ: 試算表
    * 現時点での残高試算表は以下のとおり
      |   借方    | 勘定科目 |   貸方    |
      | 2,000,000 | 普通預金 |           |
      |           | 資本金　 | 2,000,000 |
      | 2,000,000 | 合計     | 2,000,000 |
