# -*- encoding : utf-8 -*-
class AddCreditAccountTypeToPayrolls < ActiveRecord::Migration
  include HyaccConstants
  SUB_ACCOUNT_CODES = {SUB_ACCOUNT_CODE_INCOME_TAX_OF_ADVANCE_MONEY=>'源泉所得税',
                       SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_ADVANCE_MONEY=>'健康保険料',
                       SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY=>'厚生年金',
                       SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_ADVANCE_MONEY=>'住民税'}
  def self.up
    add_column :payrolls, :credit_account_type_of_income_tax, :string, :null=>false, :limit => 1, :default=>'0'
    add_column :payrolls, :credit_account_type_of_insurance, :string, :null=>false, :limit => 1, :default=>'0'
    add_column :payrolls, :credit_account_type_of_pension, :string, :null=>false, :limit => 1, :default=>'0'
    add_column :payrolls, :credit_account_type_of_inhabitant_tax, :string, :null=>false, :limit => 1, :default=>'0'
    
    # カラム情報を最新にする
    Payroll.reset_column_information
    # 立替金の補助科目を追加
    a = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
    SUB_ACCOUNT_CODES.each_pair{|key, value|
      sa = SubAccount.new( :code => key, :name => value )
      sa.account = a
      sa.save!
    }
    #　立替金は住民税
    Payroll.find(:all).each do |pr|
      # 初期値は預り金
      credit_account_type_of_income_tax = '0'
      credit_account_type_of_insurance = '0'
      credit_account_type_of_pension = '0'
      credit_account_type_of_inhabitant_tax = '0'
      pr.payroll_journal_headers.journal_details.each do | jd |
        # 貸方
        if jd.dc_type == DC_TYPE_CREDIT
          if jd.account_id == a.id
            credit_account_type_of_inhabitant_tax = Payroll::CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
          end
        end
      end
      pr.credit_account_type_of_income_tax = credit_account_type_of_income_tax
      pr.credit_account_type_of_insurance = credit_account_type_of_insurance
      pr.credit_account_type_of_pension = credit_account_type_of_pension
      pr.credit_account_type_of_inhabitant_tax = credit_account_type_of_inhabitant_tax
      pr.save!
    end
  end

  def self.down
    remove_column :payrolls, :credit_account_type_of_inhabitant_tax
    remove_column :payrolls, :credit_account_type_of_pension
    remove_column :payrolls, :credit_account_type_of_insurance
    remove_column :payrolls, :credit_account_type_of_income_tax
  end
end
