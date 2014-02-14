# -*- encoding : utf-8 -*-
class AddDataToAccountsAndSubAccounts < ActiveRecord::Migration
  def self.up

    # 法定福利費レコードを作成
    a = Account.new
    a.code = 8441
    a.name = '法定福利費'
    a.dc_type = HyaccConstants::DC_TYPE_DEBIT
    a.account_type = HyaccConstants::ACCOUNT_TYPE_EXPENSE
    
    # 法定福利費の補助科目を作成
    a.sub_accounts << SubAccount.new( :code=>100, :name=>'源泉所得税' )
    a.sub_accounts << SubAccount.new( :code=>200, :name=>'健康保険料' )
    a.sub_accounts << SubAccount.new( :code=>300, :name=>'厚生年金' )
    a.sub_accounts << SubAccount.new( :code=>400, :name=>'児童手当拠出金' )
    
    a.save!
    
  end

  def self.down
    Account.find_by_code('8441').destroy
  end
end
