class AddColumnEnterpriseNumberOnBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :enterprise_number, :string
  end
end
