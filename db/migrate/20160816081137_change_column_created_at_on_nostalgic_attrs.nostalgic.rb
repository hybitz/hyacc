# This migration comes from nostalgic (originally 20160816080815)
class ChangeColumnCreatedAtOnNostalgicAttrs < ActiveRecord::Migration
  def up
    change_column :nostalgic_attrs, :created_at, :datetime, :null => true
  end
  def down
    change_column :nostalgic_attrs, :created_at, :datetime, :null => false
  end
end
