class AddColumnGainsOnInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :investments, :gains, :integer, null: false, default: 0
  end
end
