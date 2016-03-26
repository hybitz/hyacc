class AddColumnForWhatOnInvestments < ActiveRecord::Migration
  def change
    add_column :investments, :for_what, :integer, :null => false
  end
end
