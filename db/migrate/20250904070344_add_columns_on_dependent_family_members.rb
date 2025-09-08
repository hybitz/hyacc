class AddColumnsOnDependentFamilyMembers < ActiveRecord::Migration[6.1]
  def change
    change_table :dependent_family_members, bulk: true do |t|
      t.integer :family_sub_type
      t.string  :non_resident_code
    end
  end
end
