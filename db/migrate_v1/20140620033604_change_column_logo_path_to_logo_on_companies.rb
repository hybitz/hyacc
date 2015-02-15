class ChangeColumnLogoPathToLogoOnCompanies < ActiveRecord::Migration
  def up
    rename_column :companies, :logo_path, :logo
  end

  def down
    rename_column :companies, :logo, :logo_path
  end
end
