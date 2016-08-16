# This migration comes from nostalgic (originally 20160807101438)
class CreateNostalgicAttrs < ActiveRecord::Migration
  def change
    create_table :nostalgic_attrs do |t|
      t.string :model_type, null: false
      t.integer :model_id, null: false
      t.string :name, null: false
      t.string :value
      t.date :effective_at, null: false
      t.timestamps null: false
    end
  end
end
