class UpdateUpdateUserIdOnPayrolls < ActiveRecord::Migration[5.1]
  def up
    Payroll.update_all(['update_user_id = create_user_id'])
  end
  
  def down
  end
end
