class ChangeColumnUpdateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    change_column_null :payrolls, :update_user_id, false
  end
end
