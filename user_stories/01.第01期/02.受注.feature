# language: ja

機能: 受注

  シナリオ: 仕事を受注
    * 受注元となる取引先を登録します
      | 取引先コード　　　 | 101 |
      | 取引先名（正式名） | 受注元会社 |
      | 取引先名（省略名） | 受元 |
      | 住所　　　　　　　 | 東京都品川区 |
      | 受注フラグ　　　　 | 有効 |
      | 発注フラグ　　　　 | 無効 |
    * 受注した仕事にかかった経費を計上
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額       | 貸方　   | 金額     |
      | 2013-07-01 | 現金を引き出し | 現金　　　 | 10,000　　 | 普通預金 | 10,000　 |
      | 2013-07-01 | 電車代　　　　 | 旅費交通費 | 1,000      | 現金     | 1,000   |
      | 2013-07-20 | 専門書を購入　 | 新聞図書費 | 2,000 　　 | 現金　　 | 2,000 　 |
    * 売上を計上
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額       | 貸方　　 | 金額     |
      | 2013-07-31 | 売上　　　　　 | 売掛金　　 | 100,000   | 売上高　 | 100,000  |
    