# -*- encoding : utf-8 -*-
require 'journal_detail'

# 過去データには補助科目がない場合があるけど、現時点で補助科目が必須になっている可能性がある。
# 仕訳明細のバリデーションを回避するように拡張する
class JournalDetail
  def validate
  end
end

class RLike
  include JournalUtil
end

class AddColumnsForNameToJournalDetails < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :journal_details, "account_name", :string, :null=>false
    add_column :journal_details, "sub_account_name", :string
    add_column :journal_details, "branch_name", :string
    
    # カラム情報を最新にする
    JournalDetail.reset_column_information

    # 過去データに内部取引仕訳がおかしいデータがある
    rlike = RLike.new.build_rlike_condition(ACCOUNT_CODE_BRANCH_OFFICE, 1, 0)
    JournalHeader.find(:all, :conditions=>['slip_type=? and finder_key rlike ?',
        SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE, rlike]).each do |jh|
      
      transfer_from = JournalHeader.find(jh.transfer_from_id)
          
      print("updating internal trade for journal [#{transfer_from.id.to_s}]\n")
      
      # 内部取引の自動振替仕訳を再作成して保存する
      param = Auto::AutoTransferParamInternalTrade.new( transfer_from )
      factory = Auto::AutoTransferFactory.get_instance( param )
      factory.make_auto_transfers()
      transfer_from.save!
    end

    # 仕訳明細を更新
    JournalDetail.find(:all).each do |jd|
      print("updating journal_details [#{jd.id.to_s}]\n")

      a = Account.find(jd.account_id)
      jd.account_name = a.name
      
      if jd.sub_account_id.to_i > 0
        sa = a.get_sub_account_by_id(jd.sub_account_id)
        jd.sub_account_name = sa.name unless sa.nil?
      end
      
      b = Branch.find(jd.branch_id)
      jd.branch_name = b.name
      
      jd.save!
    end
  end

  def self.down
    remove_column :journal_details, "account_name"
    remove_column :journal_details, "sub_account_name"
    remove_column :journal_details, "branch_name"
  end
end
