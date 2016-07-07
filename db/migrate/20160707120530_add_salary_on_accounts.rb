class AddSalaryOnAccounts < ActiveRecord::Migration
  include HyaccConstants

  def up
    director_salary = Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY)
    raise '勘定科目 役員給与 が登録されていません。' unless director_salary.present?

    director_salary.update_attributes!('sub_account_editable' => false, 'system_required' => true)

    salary = Account.find_by_code(ACCOUNT_CODE_SALARY)
    return if salary.present?
    
    salary = Account.new(:code => ACCOUNT_CODE_SALARY, :name => '給与手当')
    salary.attributes = director_salary.attributes.slice('dc_type', 'account_type', 'parent_id', 'journalizable', 'trade_type',
        'is_settlement_report_account', 'sub_account_type', 'sub_account_editable', 'tax_type', 'depreciable',
        'is_trade_account_payable', 'company_only', 'personal_only', 'system_required')
    salary.save!
  end

  def down
    salary = Account.find_by_code(ACCOUNT_CODE_SALARY)
    salary.destroy
  end
end
