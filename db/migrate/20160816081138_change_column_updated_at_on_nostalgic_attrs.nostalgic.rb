# This migration comes from nostalgic (originally 20160816080822)
class ChangeColumnUpdatedAtOnNostalgicAttrs < ActiveRecord::Migration
  def up
    change_column :nostalgic_attrs, :updated_at, :datetime, :null => true
  end
  def down
    change_column :nostalgic_attrs, :updated_at, :datetime, :null => false
  end
end
