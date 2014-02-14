# -*- encoding : utf-8 -*-
class AddColumnParantIdToAccounts < ActiveRecord::Migration
  include HyaccConstants

  # 勘定科目区分に対応する親科目
  @parents = [
    { :code=>'1000', :name=>'資産', :dc_type=>DC_TYPE_DEBIT, :account_type=>ACCOUNT_TYPE_ASSET },
    { :code=>'3000', :name=>'負債', :dc_type=>DC_TYPE_CREDIT, :account_type=>ACCOUNT_TYPE_DEBT },
    { :code=>'4000', :name=>'資本', :dc_type=>DC_TYPE_CREDIT, :account_type=>ACCOUNT_TYPE_CAPITAL },
    { :code=>'6000', :name=>'収益', :dc_type=>DC_TYPE_CREDIT, :account_type=>ACCOUNT_TYPE_PROFIT },
    { :code=>'8000', :name=>'費用', :dc_type=>DC_TYPE_DEBIT, :account_type=>ACCOUNT_TYPE_EXPENSE },
  ]

  def self.up
    add_column :accounts, "parent_id", :integer, :default=>0

    # カラム情報を最新にする
    Account.reset_column_information
    
    
    # 親科目の追加
    parents = []
    @parents.each do | parent |
      account = Account.new( parent )
      account.save
      parents << account
    end
    
    # 既存の科目を親科目配下に移動
    Account.find(:all).each do | a |
      if a.account_type == ACCOUNT_TYPE_ASSET
        a.parent_id = parents[0].id
      elsif a.account_type == ACCOUNT_TYPE_DEBT
        a.parent_id = parents[1].id
      elsif a.account_type == ACCOUNT_TYPE_CAPITAL
        a.parent_id = parents[2].id
      elsif a.account_type == ACCOUNT_TYPE_PROFIT
        a.parent_id = parents[3].id
      elsif a.account_type == ACCOUNT_TYPE_EXPENSE
        a.parent_id = parents[4].id
      else
        raise HyaccException.new("予期していない勘定科目区分：code=#{a.code} name=#{a.name} account_type=#{a.account_type}")
      end
      
      # 親科目は更新対象外
      a.save unless a.id == a.parent_id
    end
  end

  def self.down
    raise HyaccException.new("acts_as_treeの導入にともないダウングレード不可")
  end
end
