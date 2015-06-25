# language: ja

機能: 給与所得・退職所得等の所得税徴収高計算書

  シナリオ: 表示
    前提 本店一郎がログインしている
    
    もし 帳票出力をクリックする
    ならば 帳票出力に遷移する
    
    もし 源泉徴収をクリックする
    ならば 源泉徴収に遷移する
    
    もし 以下の検索条件に入力し
      | 従業員　 |                    |
      | 帳票様式 | 給与所得・退職所得等の所得税徴収高計算書 |
    かつ 表示をクリックする
    ならば 源泉徴収に遷移する
    かつ メッセージ「給与所得・退職所得等の所得税徴収高計算書」が表示される
