class AddColumnEnterpriseNumberOnCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :enterprise_number, :string, :limit => 13
  end
end
