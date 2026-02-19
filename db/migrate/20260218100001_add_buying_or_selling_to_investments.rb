class AddBuyingOrSellingToInvestments < ActiveRecord::Migration[7.2]
  def change
    add_column :investments, :buying_or_selling, :integer, null: false
  end
end
