class AddColumnZipOnBusinessOffices < ActiveRecord::Migration
  def change
    add_column :business_offices, :zip_code, :string, :limit => 8
  end
end
