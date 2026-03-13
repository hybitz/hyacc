class RemoveBuyingOrSellingFromInvestments < ActiveRecord::Migration[8.1]
  def change
    remove_column :investments, :buying_or_selling, :integer
  end
end
