# -*- encoding : utf-8 -*-
# 売上高の補助科目を取引先に変更する
class UpdateAccounts6121 < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    a = Account.find_by_code('6121')
    a.sub_account_type = SUB_ACCOUNT_TYPE_CUSTOMER
    a.save!
  end

  def self.down
    raise HyaccException.new("売上高の伝票を元に戻すのが大変なのでダウングレード不可")
  end
end
