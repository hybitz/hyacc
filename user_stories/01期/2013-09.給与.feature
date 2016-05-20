# language: ja

機能: 給与

  シナリオ: 給与支払日を設定
    * 給与支払日を翌月7日に設定

  シナリオ: 役員給与の支払
    * 賃金台帳に今月分の給与を登録
      | 年月　　 | 2013-09 |
      | 役員給与 | 250,000 |
    * 税金および保険料は以下のとおり
      | 所得税 | 5,270 |
      | 健康保険 | 13,156 |
      | 厚生年金 | 22,256 |

  シナリオ: 今月の売上
    * 売上を計上
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額       | 貸方　　 | 金額     |
      | 2013-09-30 | 売上　　　　　 | 売掛金　　 | 500,000   | 売上高　 | 500,000  |
    * 取引先からの入金
      | 年月日     | 摘要　　　　　 | 借方　　　 | 金額       | 貸方　　 | 金額     |
      | 2013-10-31 | 入金　　　　　 | 普通預金　 | 500,000   | 売掛金　 | 500,000  |

  シナリオ: 試算表
    * 現時点での残高試算表は以下のとおり
      |   借方    | 勘定科目　　　　　 |   貸方    |
      |     7,000 | 現金　　　　　　　 |           |
      | 3,279,357 | 普通預金　　　　　 |           |
      |         0 | 売掛金　　　　　　 |           |
      |   250,000 | 役員給与　　　　　 |           |
      |    35,412 | 法定福利費　　　　 |           |
      |     1,000 | 旅費交通費　　　　 |           |
      |     2,000 | 新聞図書費　　　　 |           |
      |     1,325 | 支払手数料　　　　 |           |
      |           | 未払費用　　　　　 |    35,412 |
      |           | 未払費用（従業員） |         0 |
      |           | 預り金　　　　　　 |    40,682 |
      |           | 資本金　　　　　　 | 2,000,000 |
      |           | 売上高　　　　　　 | 1,500,000 |
      | 3,576,094 | 合計　　　　　　　 | 3,576,094 |
