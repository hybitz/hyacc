# -*- encoding : utf-8 -*-
class AddColumnCodeOnBankAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    add_column :bank_accounts, "code", :string, :null => false

    # カラム情報を最新にする
    BankAccount.reset_column_information
    
    BankAccount.find(:all).each do |ba|
      ba.code = (ba.id * 100).to_s
      ba.save!
    end
    
    # 補助科目を削除する
    # （ちなみに伝票明細の補助科目ID=1の銀行口座はちょうど銀行口座マスタのID=1と一致するので対応不要
    account = Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT)
    account.sub_account_type = SUB_ACCOUNT_TYPE_SAVING_ACCOUNT
    account.save!
    SubAccount.find(:all, :conditions=>['account_id=?', account.id]).each do |sa|
      sa.destroy
    end
  end

  def self.down
    remove_column :bank_accounts, "code"
  end
end
