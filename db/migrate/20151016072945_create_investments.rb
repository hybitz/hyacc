class CreateInvestments < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.date :yyyymmdd, :null => false
      t.string :name, :null => false
      t.integer :shares, :null => false, :default => 0
      t.integer :trading_value, :null => false, :default => 0
      t.timestamps
    end
  end
end
