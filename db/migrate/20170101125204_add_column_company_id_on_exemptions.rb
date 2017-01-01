class AddColumnCompanyIdOnExemptions < ActiveRecord::Migration
  def change
    add_column :exemptions, :company_id, :integer, :null => false
  end
end
