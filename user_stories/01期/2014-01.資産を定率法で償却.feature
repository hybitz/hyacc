# language: ja

機能: 資産を定率法で償却

  シナリオ: 関西支店を新設
    * 部門 関西支店 を登録

  シナリオ: 従業員を雇用
    * 従業員 次郎 を登録
      | ログインID　  | jirou |
      | パスワード　　 | testtest |
      | メールアドレス | jirou@example.com |
      | 姓　　　　　　 | 開発 |
      | 名　　　　　　 | 次郎 |
      | 性別　　　　　 | 男 |
      | 生年月日　　　 | 1979-05-01 |
      | 入社日　　　　 | 2014-01-04 |
      | 所属部門　　　 | 関西支店 |

  シナリオ: 関西支店の活動資金
    * 本店から資金を異動
      | 年月日     | 摘要　　　　　 | 借方　　　 | 部門　　 | 金額       | 貸方　　 | 部門　　 | 金額　     |
      | 2014-01-04 | 預金の振替　　 | 普通預金　 | 関西支店 | 2,000,000  | 普通預金 | 本店　　 | 2,000,000 |
      | 2014-01-05 | 現金の引き出し | 現金　　　 | 関西支店 |   100,000  | 普通預金 | 関西支店 |   100,000 |

  シナリオ: サーバマシンを購入
    * 関西支店でサーバマシンを購入
      | 年月日     | 摘要　　　　　 | 借方　　　　 | 金額       | 貸方　　　 | 金額　     |
      | 2014-01-08 | サーバ　　　　 | 工具器具備品 | 600,000    | 普通預金　 | 600,000   |
    * 耐用年数 4 年で定率法による償却

  シナリオ: 今月の実績
    * 本店の実績
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額      | 貸方　　 | 金額      |
      | 2014-01-02 | 飛行機代　　　 | 旅費交通費 |  60,000   | 普通預金 |  60,000  |
      | 2014-01-30 | 売上　　　　　 | 売掛金　　 | 500,000   | 売上高　 | 500,000  |
      | 2014-02-28 | 入金　　　　　 | 普通預金　 | 500,000   | 売掛金　 | 500,000  |
    * 関東支店の実績
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額      | 貸方　　 | 金額      |
      | 2014-01-15 | 電車代　　　　 | 旅費交通費 | 4,000     | 現金　　 | 4,000    |
      | 2014-01-30 | 売上　　　　　 | 売掛金　　 | 300,000   | 売上高　 | 300,000  |
      | 2014-02-28 | 入金　　　　　 | 普通預金　 | 300,000   | 売掛金　 | 300,000  |

  シナリオ: 給与
    * 各従業員の 2014-01 分の給与を登録
      | 部門　　 | 従業員 | 給与　　 | 所定時間外割増賃金 | 通勤手当 | 住宅手当 | 所得税 | 健康保険 | 厚生年金 | 雇用保険 | 振込手数料 |
      | 本店　　 | 太郎　 | 250,000 |                     |        |         | 5,270 |  13,156  |  22,256 |          | 525       |
      | 関東支店 | 花子　 | 200,000 |                     |        |         | 3,770 |  10,120  |  17,120 |    1,000 | 525       |
      | 関西支店 | 次郎　 | 180,000 |                     | 15,000 |         | 3,050 |  10,120  |  17,120 |      975 | 525       |

  シナリオ: 試算表
    * 現時点での残高試算表は以下のとおり
      |   借方     | 勘定科目　　　　　 |   貸方     |
      |    399,000 | 現金　　　　　　　 |            |
      |  3,312,680 | 普通預金　　　　　 |            |
      |          0 | 売掛金　　　　　　 |            |
      |    475,000 | 工具器具備品　　　 |            |
      |  3,000,000 | 支店勘定　　　　　 |            |
      |  1,250,000 | 役員給与　　　　　 |            |
      |    795,000 | 給与手当　　　　　 |            |
      |    286,020 | 法定福利費　　　　 |            |
      |    166,500 | 旅費交通費　　　　 |            |
      |      2,000 | 新聞図書費　　　　 |            |
      |      5,525 | 支払手数料　　　　 |            |
      |    325,000 | 減価償却費　　　　 |            |
      |            | 未払費用　　　　　 |    286,020 |
      |            | 未払費用（従業員） |          0 |
      |            | 未払金（従業員）　 |          0 |
      |            | 預り金　　　　　　 |    330,705 |
      |            | 資本金　　　　　　 |  2,000,000 |
      |            | 売上高　　　　　　 |  4,400,000 |
      |            | 本店勘定　　　　　 |  3,000,000 |
      | 10,016,725 | 合計　　　　　　　 | 10,016,725 |
