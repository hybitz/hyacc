class RenameTableEmployeeQualificationsToSkills < ActiveRecord::Migration[5.2]
  def change
    rename_table :employee_qualifications, :skills
  end
end
