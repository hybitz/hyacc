class AddColumnCreateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :create_user_id, :integer
  end
end
