class RemoveColumnIsHeadOnBusinessOffices < ActiveRecord::Migration
  def up
    remove_column :business_offices, :is_head
  end
  
  def down
    add_column :business_offices, :is_head, :boolean, default: false, null: false
  end
end
