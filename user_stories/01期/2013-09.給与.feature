# language: ja

機能: 給与

  シナリオ: 給与支払日を設定
    * 給与支払日を翌月7日に設定

  シナリオ: 役員給与の支払
    * 賃金台帳に今月分の給与を登録
      | 役員給与 | 250,000 |
    * 税金および保険料は以下のとおり
      | 所得税 | 5,270 |
      | 健康保険 | 13,156 |
      | 厚生年金 | 22,256 |
