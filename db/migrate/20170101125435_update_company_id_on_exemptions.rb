class UpdateCompanyIdOnExemptions < ActiveRecord::Migration
  def up
    raise '会社が複数登録されています' if Company.count > 1
    
    Exemption.update_all(['company_id = ?', Company.first.id])
  end

  def down
  end
end
