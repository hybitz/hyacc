# language: ja

機能: 賃金台帳

  シナリオ: 一覧
    前提 営業花子がログインしている

    もし 人事労務のメニューから賃金台帳をクリックする
    ならば 賃金台帳の一覧に遷移する
    かつ 検索条件の初期値は以下の通りである
      | 年度　 | 本年度　　　　 |
      | 部門　 | デフォルト部門 |
      | 従業員 | ログインユーザ |
    
    もし 表示をクリックする
    ならば 賃金台帳が表示される
