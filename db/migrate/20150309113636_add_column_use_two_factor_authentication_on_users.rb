class AddColumnUseTwoFactorAuthenticationOnUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_two_factor_authentication, :boolean, :null => false, :default => false
    User.update_all(['use_two_factor_authentication = ?', true])
  end
end
