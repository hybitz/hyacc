class RenameColumnUpdatedOnToUpdatedAtOnCompanies < ActiveRecord::Migration
  def change
    rename_column :companies, :updated_on, :updated_at
  end
end
