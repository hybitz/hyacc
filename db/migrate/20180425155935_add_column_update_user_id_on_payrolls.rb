class AddColumnUpdateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :update_user_id, :integer
  end
end
