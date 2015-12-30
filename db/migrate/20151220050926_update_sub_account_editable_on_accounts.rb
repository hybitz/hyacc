class UpdateSubAccountEditableOnAccounts < ActiveRecord::Migration
  def up
    Account.find_each do |a|
      ac = AccountControl.where(:account_id => a.id).first
      unless ac
        puts "勘定科目の制御情報がありません id=#{a.id}, name=#{a.name}"
        next
      end

      a.update_columns(:sub_account_editable => ac.sub_account_editable?)
    end
  end
  
  def down
  end
end
