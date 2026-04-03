class AddColumnRepresentativeOrFamilyTypeOnEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :representative_or_family_type, :integer
  end
end