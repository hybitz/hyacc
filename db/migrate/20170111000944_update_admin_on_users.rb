class UpdateAdminOnUsers < ActiveRecord::Migration
  def up
    User.update_all(:admin => true)
  end

  def down
  end
end
