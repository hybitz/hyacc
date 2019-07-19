class CreateQualifications < ActiveRecord::Migration[5.2]
  def change
    create_table :qualifications do |t|
      t.integer :company_id, null: false
      t.string :name, null: false
      t.integer :allowance, null: false, default: 0
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
  end
end
