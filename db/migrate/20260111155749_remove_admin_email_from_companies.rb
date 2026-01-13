class RemoveAdminEmailFromCompanies < ActiveRecord::Migration[7.2]
  def change
    remove_column :companies, :admin_email, :string
  end
end
