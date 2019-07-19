class CreateEmployeeQualifications < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_qualifications do |t|
      t.integer :employee_id, null: false
      t.integer :qualification_id, null: false
      t.date :qualified_on, null: false
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
  end
end
