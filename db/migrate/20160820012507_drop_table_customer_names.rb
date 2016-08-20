class DropTableCustomerNames < ActiveRecord::Migration
  def up
    drop_table :customer_names
  end
  def down
    create_table "customer_names", force: :cascade do |t|
      t.integer  "customer_id", limit: 4,   null: false
      t.string   "name",        limit: 255, null: false
      t.string   "formal_name", limit: 255, null: false
      t.date     "start_date",              null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
