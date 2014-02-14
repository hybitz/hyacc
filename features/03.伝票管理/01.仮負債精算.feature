# language: ja

機能: 仮負債精算

  シナリオ: 一覧
    前提 経理次郎がログインしている
    もし 伝票管理をクリックする
    ならば 伝票管理に遷移する
    もし 仮負債精算をクリックする
    ならば 仮負債精算に遷移する
    もし 表示をクリックする
    ならば 仮負債精算の一覧が表示される

  シナリオ: 精算
    前提 経理次郎がログインしている
    前提 仮負債精算の一覧を表示している
    もし 精算日に 2009-08-31 と入力する
    かつ 精算科目に普通預金を選択する
    かつ 補助科目に北海道銀行を選択する
    かつ 任意の伝票の精算をクリックする
    ならば 当該伝票が精算済みになる
