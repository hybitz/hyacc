# -*- encoding : utf-8 -*-
class InsertDataOnSubAccounts < ActiveRecord::Migration
  include HyaccConstants
  def self.up
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    a.sub_accounts_all.each do |s|
      s.destroy
    end
    sa = SubAccount.new( :code => '101', :name => 'ハイビッツ' )
    sa.account = a
    sa.save!
    sa = SubAccount.new( :code => '102', :name => 'ICHY' )
    sa.account = a
    sa.save!
    sa = SubAccount.new( :code => '103', :name => 'HIRO' )
    sa.account = a
    sa.save!
    
  end

  def self.down
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_DEBT)
    a.sub_accounts.each do |s|
      s.destory!
    end
  end
end
