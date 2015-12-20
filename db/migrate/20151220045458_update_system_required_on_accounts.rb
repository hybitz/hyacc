class UpdateSystemRequiredOnAccounts < ActiveRecord::Migration
  def up
    Account.find_each do |a|
      unless a.account_control.present?
        puts "勘定科目の制御情報がありません id=#{a.id}, name=#{a.name}"
        next
      end

      a.update_columns(:system_required => a.account_control.system_required?)
    end
  end
  
  def down
  end
end
