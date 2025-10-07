class RemoveLiveInFromDependentFamilyMembers < ActiveRecord::Migration[6.1]
  def up
    remove_column :dependent_family_members, :live_in
  end

  def down
    add_column :dependent_family_members, :live_in, :boolean, default: true, null: false
  end
end
