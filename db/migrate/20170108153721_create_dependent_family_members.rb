class CreateDependentFamilyMembers < ActiveRecord::Migration
  def change
    create_table :dependent_family_members do |t|
      t.integer :exemption_id, null: false
      t.integer :exemption_type, null: false
      t.string :name, null: false
      t.string :kana, null: false
      t.string :my_number
      t.boolean :live_in, null: false, default: true
      t.timestamps null: false
    end
  end
end
