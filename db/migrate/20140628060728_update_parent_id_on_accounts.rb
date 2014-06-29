class UpdateParentIdOnAccounts < ActiveRecord::Migration
  def up
    rename_column :accounts, :parent_id, :parent_id_old
    add_column :accounts, :parent_id, :integer

    Account.transaction do
      Account.update_all(['parent_id = parent_id_old'])
      Account.all.each do |a|
        next unless a.parent_id == 0
        puts "#{a.code}: #{a.name}"
        a.parent_id = nil
        a.save!
      end
    end
  end

  def down
    begin
      remove_column :accounts, :parent_id_old
    rescue
    end
  end
end
