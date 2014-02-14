# -*- encoding : utf-8 -*-
class AddColumnDescriptionToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :description, :string
    add_column :accounts, :short_description, :string

    # カラム情報を最新にする
    Account.reset_column_information
    
    # 現時点で必要な説明文を設定
    Account.find_by_code('3170').update_attributes!(:short_description=>'発生した費用の未払分', :description=>'発生した費用に対する未払となっている債務')
    Account.find_by_code('3171').update_attributes!(:short_description=>'従業員が立て替えた費用の未清算分等', :description=>'未払金のうち、従業員が個人の現金・カードなどで立て替えた場合などの、従業員に対する債務')
    Account.find_by_code('3172').update_attributes!(:short_description=>'外注費の未払い等', :description=>'未払金のうち、取引先に対する債務')
    Account.find_by_code('3183').update_attributes!(:short_description=>'社会保険の未払い等', :description=>'継続的に発生する経費に対する未払となっている債務')
    Account.find_by_code('3184').update_attributes!(:short_description=>'給与未払い等', :description=>'未払費用のうち、従業員に対する給与などの、従業員に対する債務')
  end

  def self.down
    remove_column :accounts, :description
    remove_column :accounts, :short_description
  end
end
