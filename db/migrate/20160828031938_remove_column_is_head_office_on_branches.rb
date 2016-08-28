class RemoveColumnIsHeadOfficeOnBranches < ActiveRecord::Migration
  def up
    remove_column :branches, :is_head_office
  end
  def down
    add_column :branches, :is_head_office, :boolean, :null => false, :default => false

    Company.find_each do |c|
      head = Branch.where(:company_id => c.id).where('parent_id is null').first
      head.update_attributes!(:is_head_office => true)
    end
  end
end
