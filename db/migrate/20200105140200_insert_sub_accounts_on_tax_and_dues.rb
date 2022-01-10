class InsertSubAccountsOnTaxAndDues < ActiveRecord::Migration[5.2]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_TAX_AND_DUES)
    [SUB_ACCOUNT_CODE_BUSINESS_TAX, SUB_ACCOUNT_CODE_OTHERS].each do |code|
      sa = a.get_sub_account_by_code(code)
      next if sa
      
      sa = SubAccount.new(account_id: a.id, code: code, sub_account_type: SUB_ACCOUNT_TYPE_NORMAL)
      case sa.code
      when SUB_ACCOUNT_CODE_BUSINESS_TAX
        sa.name = '法人事業税'
      when SUB_ACCOUNT_CODE_OTHERS
        sa.name = 'その他'
      end
      sa.save!
    end
    
    a = Account.find_by_code(ACCOUNT_CODE_TAX_AND_DUES)
    sa = a.get_sub_account_by_code(SUB_ACCOUNT_CODE_OTHERS)
    JournalDetail.where(account_id: a.id).update_all(['sub_account_id = ?', sa.id])
  end
  
  def down
  end
end
