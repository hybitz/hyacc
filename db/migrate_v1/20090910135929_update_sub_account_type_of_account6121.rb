# -*- encoding : utf-8 -*-
# 売上高の補助科目区分を取引先から受注先に変更
# 外注費の補助科目区分を通常から発注先に変更
# 業務委託費の補助科目区分を通常から発注先に変更
class UpdateSubAccountTypeOfAccount6121 < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    a = Account.find_by_code(6121)
    a.sub_account_type = SUB_ACCOUNT_TYPE_ORDER_ENTRY
    a.save!
    
    a = Account.find_by_code(8332)
    a.sub_account_type = SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
    a.save!
    
    a = Account.find_by_code(8342)
    a.sub_account_type = SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
    a.save!
    
    JournalDetail.update_all('sub_account_id=2', 'account_id in (69, 70)')
  end

  def self.down
    a = Account.find_by_code(6121)
    a.sub_account_type = SUB_ACCOUNT_TYPE_CUSTOMER
    a.save!
    
    a = Account.find_by_code(8332)
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.save!
    
    a = Account.find_by_code(8342)
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.save!
    
    JournalDetail.update_all('sub_account_id=null', 'account_id in (69, 70)')
  end
end
