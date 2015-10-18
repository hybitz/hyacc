class DropTableDepreciationRates < ActiveRecord::Migration
  def up
    drop_table :depreciation_rates
  end

  def down
    create_table "depreciation_rates", force: true do |t|
      t.integer  "durable_years",     limit: 2,                                         null: false
      t.decimal  "fixed_amount_rate",           precision: 4, scale: 3,                 null: false
      t.decimal  "rate",                        precision: 4, scale: 3,                 null: false
      t.decimal  "revised_rate",                precision: 4, scale: 3,                 null: false
      t.decimal  "guaranteed_rate",             precision: 6, scale: 5,                 null: false
      t.boolean  "deleted",                                             default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
