class UpdateCompanyIdOnBanks < ActiveRecord::Migration[5.1]
  def up
    raise '会社が複数登録されています。' unless Company.count <= 1
    
    company_id = Company.first.id
    Bank.update_all(['company_id = ?', company_id])
  end
  
  def down
  end
end
