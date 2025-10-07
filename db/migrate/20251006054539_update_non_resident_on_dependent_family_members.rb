class UpdateNonResidentOnDependentFamilyMembers < ActiveRecord::Migration[6.1]
  def up
    DependentFamilyMember.reset_column_information
    DependentFamilyMember.where(live_in: false).update_all(non_resident: true)
  end

  def down
    DependentFamilyMember.reset_column_information
    DependentFamilyMember.update_all("live_in = NOT non_resident")
  end
end
