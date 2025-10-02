class AddColumnsOnDependentFamilyMembers < ActiveRecord::Migration[6.1]
  def up
    change_table :dependent_family_members, bulk: true do |t|
      t.integer :family_sub_type
      t.string  :non_resident_code
    end
  end

  def down
    change_table :dependent_family_members, bulk: true do |t|
      t.remove :family_sub_type
      t.remove :non_resident_code
    end
  end
end
