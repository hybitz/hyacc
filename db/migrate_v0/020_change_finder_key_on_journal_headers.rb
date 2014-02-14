# -*- encoding : utf-8 -*-
# 伝票検索キーを勘定科目と計上部門で個別に持っていたのを廃止する。
# 変わりに、勘定科目、補助科目、計上部門をセットにした検索キーを設定する。
class ChangeFinderKeyOnJournalHeaders < ActiveRecord::Migration
  def self.up
    remove_column :journal_headers, "account_finder_key"
    remove_column :journal_headers, "branch_finder_key"
    add_column :journal_headers, "finder_key", :string

    # 既存のレコードの検索キーを更新
    JournalHeader.find(:all).each{ | jh |
      jh.save!
    }
  end

  def self.down
    remove_column :journal_headers, "finder_key"
    add_column :journal_headers, "account_finder_key", :string
    add_column :journal_headers, "branch_finder_key", :string
  end
end
