class ChangeColumnCreateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    change_column_null :payrolls, :create_user_id, false
  end
end
