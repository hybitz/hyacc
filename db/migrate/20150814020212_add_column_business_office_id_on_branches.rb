class AddColumnBusinessOfficeIdOnBranches < ActiveRecord::Migration
  def change
    add_column :branches, :business_office_id, :integer
  end
end
