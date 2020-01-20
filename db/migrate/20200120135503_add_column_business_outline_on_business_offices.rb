class AddColumnBusinessOutlineOnBusinessOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :business_offices, :business_outline, :string
  end
end
