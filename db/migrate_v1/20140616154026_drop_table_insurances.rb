class DropTableInsurances < ActiveRecord::Migration
  def up
    drop_table :insurances
  end

  def down
    create_table "insurances", :force => true do |t|
      t.integer  "apply_start_ym",                 :default => 999912, :null => false
      t.integer  "apply_end_ym",                   :default => 999912, :null => false
      t.integer  "grade",                          :default => 0,      :null => false
      t.integer  "pay_range_above"
      t.integer  "pay_range_under"
      t.integer  "monthly_earnings"
      t.integer  "daily_earnings"
      t.float    "health_insurance_all"
      t.float    "health_insurance_half"
      t.float    "health_insurance_all_care"
      t.float    "health_insurance_half_care"
      t.float    "welfare_pension_insurance_all"
      t.float    "welfare_pension_insurance_half"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
