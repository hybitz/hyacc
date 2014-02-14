# -*- encoding : utf-8 -*-
# 売掛金の補助科目を取引先に変更する
class UpdateAccounts1551 < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    a = Account.find_by_code('1551')
    a.sub_account_type = SUB_ACCOUNT_TYPE_CUSTOMER
    a.save!
  end

  def self.down
    raise HyaccException.new("売掛金の伝票を元に戻すのが大変なのでダウングレード不可")
  end
end
