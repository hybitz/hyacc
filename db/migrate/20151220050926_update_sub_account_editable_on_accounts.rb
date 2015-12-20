class UpdateSubAccountEditableOnAccounts < ActiveRecord::Migration
  def up
    Account.find_each do |a|
      unless a.account_control.present?
        puts "勘定科目の制御情報がありません id=#{a.id}, name=#{a.name}"
        next
      end

      a.update_columns(:sub_account_editable => a.account_control.sub_account_editable?)
    end
  end
  
  def down
  end
end
