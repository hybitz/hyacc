class CreateAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.integer :company_id, :null => false
      t.integer :employee_id, :null => false
      t.integer :yyyymm
      t.integer :day
      t.time :from
      t.time :to
      t.string :holiday_type
      t.timestamps null: false
    end
  end
end
