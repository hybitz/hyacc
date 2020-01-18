class AddColumnResponsiblePersonIdOnBusinessOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :business_offices, :responsible_person_id, :integer
  end
end
