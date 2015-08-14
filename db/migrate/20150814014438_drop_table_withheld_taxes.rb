class DropTableWithheldTaxes < ActiveRecord::Migration
  def up
    drop_table :withheld_taxes
  end
  
  def down
    create_table "withheld_taxes", force: true do |t|
      t.integer  "apply_start_ym",  default: 999912, null: false
      t.integer  "apply_end_ym",    default: 999912, null: false
      t.integer  "pay_range_above"
      t.integer  "pay_range_under"
      t.integer  "no_dependent"
      t.integer  "one_dependent"
      t.integer  "two_dependent"
      t.integer  "three_dependent"
      t.integer  "four_dependent"
      t.integer  "five_dependent"
      t.integer  "six_dependent"
      t.integer  "seven_dependent"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
