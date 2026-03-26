class AddColumnRelationshipToRepresentativeOnEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :relationship_to_representative, :string
  end
end

