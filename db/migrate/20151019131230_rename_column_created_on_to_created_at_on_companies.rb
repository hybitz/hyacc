class RenameColumnCreatedOnToCreatedAtOnCompanies < ActiveRecord::Migration
  def change
    rename_column :companies, :created_on, :created_at
  end
end
