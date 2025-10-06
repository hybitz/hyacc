class AddColumnNonResidentOnDependentFamilyMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :dependent_family_members, :non_resident, :boolean, default: false, null: false
  end
end
