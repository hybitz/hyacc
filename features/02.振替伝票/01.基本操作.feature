# language: ja

機能: 振替伝票
  インターネット取引の場合、領収書のHTMLページを保存し、伝票に添付して登録する。

  シナリオ: 一覧
    前提 本店一郎がログインしている
    もし 振替伝票をクリックする
    ならば 振替伝票の一覧に遷移する

  シナリオ: 参照
    前提 本店一郎が振替伝票を表示している
    もし 任意の振替伝票の摘要をクリックする
    ならば 振替伝票の参照ダイアログが表示される

  シナリオ: 追加
    前提 本店一郎が振替伝票を表示している
    もし 追加をクリックする
    ならば 振替伝票の追加ダイアログが表示される
    もし 以下の振替伝票を登録する
      | 年月　　| 日        | 摘要      | 領収書          |      |
      | 200908 | 16        | タクシー代 | receipt.html |      |
      |        |           |           |                |      |
      | 貸借   | 勘定科目　 | 補助科目 | 計上部門   | 金額  |
      | 貸方   | 小口現金　 |          | 管理部 | 2500 |
      | 借方   | 旅費交通費 |          | 管理部 | 2500 |
    ならば 当該伝票が登録される
    かつ 電子領収書も登録されている

  シナリオ: 編集
    前提 本店一郎が振替伝票を表示している
    もし 任意の振替伝票の編集をクリックする
    ならば 振替伝票の編集ダイアログが表示される
    もし 以下の振替伝票に更新する
      | 年月　　| 日        | 摘要      |          |      |
      | 200909 | 17        | 水道代　　 |          |      |
      |        |           |           |          |      |
      | 貸借   | 勘定科目　 | 補助科目 | 計上部門   | 金額  |
      | 貸方   | 小口現金　 |          | 管理部 | 5800 |
      | 借方   | 水道光熱費 |          | 管理部 | 5800 |
    ならば 当該伝票が更新される

  シナリオ: 削除
    前提 本店一郎が振替伝票を表示している
    もし 任意の振替伝票の削除をクリックする
    ならば 当該伝票が削除される
