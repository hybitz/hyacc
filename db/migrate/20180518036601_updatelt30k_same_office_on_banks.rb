class Updatelt30kSameOfficeOnBanks < ActiveRecord::Migration[5.2]
  def change    
    # Hokkaido
    b = Bank.find(1)
    b.lt_30k_same_office = 100
    b.ge_30k_same_office = 100
    b.lt_30k_other_office = 100
    b.ge_30k_other_office = 200
    b.lt_30k_other_bank = 400
    b.ge_30k_other_bank = 500
    b.save!
    
    # Rakuten
    b = Bank.find(2)
    b.lt_30k_same_office = 48
    b.ge_30k_same_office = 48
    b.lt_30k_other_office = 48
    b.ge_30k_other_office = 48
    b.lt_30k_other_bank = 153
    b.ge_30k_other_bank = 239
    b.save!
    
    # MUFG
    b = Bank.find(3)
    b.lt_30k_same_office = 0
    b.ge_30k_same_office = 0
    b.lt_30k_other_office = 0
    b.ge_30k_other_office = 0
    b.lt_30k_other_bank = 200
    b.ge_30k_other_bank = 300
    b.save!
  end
end
