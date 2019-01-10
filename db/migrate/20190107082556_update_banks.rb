class UpdateBanks < ActiveRecord::Migration[5.2]
  def up
    Bank.find_each do |b|
      b.save!
    end
  end
  
  def down
  end
end
