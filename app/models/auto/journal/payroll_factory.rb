module Auto::Journal
  
  # 給与仕訳ファクトリ
  class PayrollFactory < Auto::AutoJournalFactory
    include PayrollHelper
    include JournalUtil
    
    def initialize( auto_journal_param )
      super( auto_journal_param )
      @payroll = auto_journal_param.payroll
      @user = auto_journal_param.user
    end

    def make_journals()
      ret = []
      ret << make_payroll
      ret << make_pay
      ret
    end
  
    # 給与明細の取得
    def make_payroll
      journal_header = JournalHeader.new
      # 氏名
      employee = Employee.find(@payroll.employee_id)
      # 給与日の設定
      journal_header.day = Date.new(@payroll.ym/100, @payroll.ym%100, -1).day
      # 摘要の設定
      journal_header.remarks = "役員給与　" + employee.full_name + "　" + (@payroll.ym%100).to_s + "月分"
      journal_header.slip_type = SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION
      journal_header.create_user_id = @user.id
      journal_header.update_user_id = @user.id
      # 年月の設定
      journal_header.ym = @payroll.ym
      journal_header.company_id = @user.company.id
      
      # 明細の作成
      ## デフォルト部門の取得
      branch_id = employee.default_branch.id
      # 保険料と所得税の取得
      tax = get_tax(@payroll.ym, employee.id, @payroll.base_salary)
      
      journal_details = []
      ## ￥０の明細を作成しない
      num_of_details = 0
      # 勘定科目の取得
      deposits_received = Account.get_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
      advance_money = Account.get_by_code(ACCOUNT_CODE_ADVANCE_MONEY)
      ## 給与明細
      ### 役員給与
      if @payroll.base_salary != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_DIRECTOR_SALARY).id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.base_salary
      end
      ### 法定福利費.健康保険料
      insurance_half = tax.insurance_all.to_i - @payroll.insurance.to_i
      if insurance_half != 0
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        account = Account.get_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
        journal_details[num_of_details][:account_id] = account.id
        journal_details[num_of_details][:sub_account_id] = account.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_LEGAL_WELFARE).id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = insurance_half
        journal_details[num_of_details][:note] = "会社負担保険料"
      end
      ### 法定福利費.厚生年金
      pension_half = tax.pension_all.to_i - @payroll.pension.to_i
      if pension_half != 0
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        account = Account.get_by_code(ACCOUNT_CODE_LEGAL_WELFARE)
        journal_details[num_of_details][:account_id] = account.id
        journal_details[num_of_details][:sub_account_id] = account.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_LEGAL_WELFARE).id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = pension_half
        journal_details[num_of_details][:note] = "会社負担保険料"
      end
      ### 源泉所得税
      if @payroll.income_tax != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
        if @payroll.credit_account_type_of_income_tax == Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
          journal_details[num_of_details][:account_id] = deposits_received.id
          journal_details[num_of_details][:sub_account_id] = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX_OF_DEPOSITS_RECEIVED).id
        else
          journal_details[num_of_details][:account_id] = advance_money.id
          journal_details[num_of_details][:sub_account_id] = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX_OF_ADVANCE_MONEY).id
        end
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.income_tax
        journal_details[num_of_details][:note] = "源泉所得税"
      end
      ### 健康保険料
      if @payroll.insurance != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
        if @payroll.credit_account_type_of_insurance == Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
          journal_details[num_of_details][:account_id] = deposits_received.id
          journal_details[num_of_details][:sub_account_id] = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_DEPOSITS_RECEIVED).id
        else
          journal_details[num_of_details][:account_id] = advance_money.id
          journal_details[num_of_details][:sub_account_id] = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE_OF_ADVANCE_MONEY).id
        end
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.insurance
        journal_details[num_of_details][:note] = "個人負担保険料"
      end
      ### 厚生年金
      if @payroll.pension != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
        if @payroll.credit_account_type_of_pension == Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
          journal_details[num_of_details][:account_id] = deposits_received.id
          journal_details[num_of_details][:sub_account_id] = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_DEPOSITS_RECEIVED).id
        else
          journal_details[num_of_details][:account_id] = advance_money.id
          journal_details[num_of_details][:sub_account_id] = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYEES_PENSION_OF_ADVANCE_MONEY).id
        end
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.pension
        journal_details[num_of_details][:note] = "個人負担保険料"
      end
      ### 会社負担保険料の未払分
      num_of_details += 1
      journal_details[num_of_details] = {}
      journal_details[num_of_details][:detail_no] = num_of_details
      journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
      journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE).id
      journal_details[num_of_details][:branch_id] = branch_id
      journal_details[num_of_details][:amount] = tax.insurance_all.to_i - @payroll.insurance.to_i + tax.pension_all.to_i - @payroll.pension.to_i
      journal_details[num_of_details][:note] = "会社負担保険料の未払分"
      ### 住民税
      if @payroll.inhabitant_tax != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
        if @payroll.credit_account_type_of_inhabitant_tax == Payroll::CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
          journal_details[num_of_details][:account_id] = deposits_received.id
          journal_details[num_of_details][:sub_account_id] = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_DEPOSITS_RECEIVED).id
        else
          journal_details[num_of_details][:account_id] = advance_money.id
          journal_details[num_of_details][:sub_account_id] = advance_money.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX_OF_ADVANCE_MONEY).id
        end
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.inhabitant_tax
        journal_details[num_of_details][:note] = "住民税"
      end
      ### 年末調整分
      unless @payroll.year_end_adjustment_liability.nil? or @payroll.year_end_adjustment_liability == '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        journal_details[num_of_details][:account_id] = deposits_received.id
        journal_details[num_of_details][:sub_account_id] = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX_OF_DEPOSITS_RECEIVED).id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.year_end_adjustment_liability
        journal_details[num_of_details][:note] = "年末調整過払い分"
      end
  
      ### 振り込み予定額　※仮明細
      num_of_details += 1
      journal_details[num_of_details] = {}
      journal_details[num_of_details][:detail_no] = num_of_details
      journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
      journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE).id
      journal_details[num_of_details][:sub_account_id] = employee.users.first.id 
      journal_details[num_of_details][:branch_id] = branch_id
      journal_details[num_of_details][:amount] = 0
      journal_details[num_of_details][:note] = "振り込み予定額"
      # 貸借の金額調整、振り込み予定額で調整する
      debit = 0
      credit = 0
      num_of_details.times{|i|
        if journal_details[i+1][:dc_type] == DC_TYPE_DEBIT
          debit = debit + journal_details[i+1][:amount].to_i
        else
          credit = credit + journal_details[i+1][:amount].to_i
        end
      }
      # 振り込み予定額の設定
      journal_details[num_of_details][:amount] = debit - credit
      @payroll.transfer_payment = debit - credit
      
      new_journal_details = []
      num_of_details.times{|i|
        new_journal_details << JournalDetail.new( journal_details[i+1] )
      }
      
      journal_header.journal_details = new_journal_details
      
      return journal_header
    end
  
  
    # 支払明細の取得
    def make_pay
      journal_header = JournalHeader.new
      # 氏名
      employee = Employee.find(@payroll.employee_id)
      # 給与日の設定
      journal_header.day = @payroll.pay_day.split('-').last
      # 摘要の設定
      journal_header.remarks = "給与支給、立替費用の精算　" + employee.full_name + "　" + (@payroll.ym%100).to_s + "月分"
      journal_header.slip_type = SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION
      journal_header.create_user_id = @user.id
      journal_header.update_user_id = @user.id
      # 年月の設定
      journal_header.ym = @payroll.pay_day.split('-')[0..1].join.to_i
      journal_header.company_id = @user.company.id
      
      # 消費税率
      tax_rate = TaxJp.get_rate_on(journal_header.date)
      Rails.logger.debug "tax_rate=#{tax_rate}, date=#{journal_header.date}"

      # 明細の作成
      ## デフォルト部門の取得
      branch_id = employee.default_branch.id
      journal_details = []
      ## 消費税取り扱い区分を取得
      fy = @user.company.get_fiscal_year(journal_header.ym)
      raise HyaccException.new(ERR_FISCAL_YEAR_NOT_EXISTS) unless fy
      ## ￥０の明細を作成しない
      num_of_details = 0
      new_journal_details = []

      ## 支払明細
      ### 未払費用.役員報酬、振込み予定額を設定
      if @payroll.transfer_payment != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE).id
        journal_details[num_of_details][:sub_account_id] = employee.users.first.id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.transfer_payment
        journal_details[num_of_details][:note] = "役員報酬"
        new_journal_details << JournalDetail.new( journal_details[num_of_details] )
      end
      ### 未払金（従業員）.ユーザ
      if @payroll.accrued_liability != '0'
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        account = Account.get_by_code(ACCOUNT_CODE_UNPAID_EMPLOYEE)
        journal_details[num_of_details][:account_id] = account.id
        journal_details[num_of_details][:sub_account_id] = employee.users.first.id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = @payroll.accrued_liability
        journal_details[num_of_details][:note] = "立替費用の精算"
        new_journal_details << JournalDetail.new( journal_details[num_of_details] )
      end
      ### TODO 銀行口座マスタとの連携
      commission = 500
      ### 支払手数料
      num_of_details += 1
      journal_details[num_of_details] = {}
      journal_details[num_of_details][:detail_no] = num_of_details
      journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
      journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_COMMISSION_PAID).id
      journal_details[num_of_details][:branch_id] = branch_id
      journal_details[num_of_details][:note] = "振込手数料"
  
      if fy.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
        journal_details[num_of_details][:tax_type] = TAX_TYPE_INCLUSIVE
        journal_details[num_of_details][:tax_rate] = tax_rate
        journal_details[num_of_details][:amount] = commission
      else
        journal_details[num_of_details][:tax_type] = TAX_TYPE_NONTAXABLE
        journal_details[num_of_details][:amount] = (commission * (1 + tax_rate)).to_i
      end
      new_journal_details << JournalDetail.new( journal_details[num_of_details] )
      ### 支払手数料の消費税
      if fy.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
        num_of_details += 1
        journal_details[num_of_details] = {}
        journal_details[num_of_details][:detail_no] = num_of_details
        journal_details[num_of_details][:dc_type] = DC_TYPE_DEBIT
        journal_details[num_of_details][:detail_type] = DETAIL_TYPE_TAX
        journal_details[num_of_details][:tax_type] = TAX_TYPE_NONTAXABLE
        journal_details[num_of_details][:account_id] = Account.get_by_code(ACCOUNT_CODE_TEMP_PAY_TAX).id
        journal_details[num_of_details][:branch_id] = branch_id
        journal_details[num_of_details][:amount] = (commission * tax_rate).to_i
        journal_details[num_of_details][:note] = "振込手数料の消費税"
        journal_details[num_of_details][:main_journal_detail] = new_journal_details[new_journal_details.size - 1]
        new_journal_details << JournalDetail.new( journal_details[num_of_details] )
      end
      ### 普通預金
      num_of_details += 1
      journal_details[num_of_details] = {}
      journal_details[num_of_details][:detail_no] = num_of_details
      journal_details[num_of_details][:dc_type] = DC_TYPE_CREDIT
      account = Account.get_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT)
      journal_details[num_of_details][:account_id] = account.id
      journal_details[num_of_details][:sub_account_id] = BANK_ACCOUNT_ID_FOR_PAY
      journal_details[num_of_details][:branch_id] = branch_id
      journal_details[num_of_details][:amount] = 0
      journal_details[num_of_details][:note] = "口座引落し額"
      new_journal_details << JournalDetail.new( journal_details[num_of_details] )
      
      # 貸借の金額調整、振り込み予定額で調整する
      debit = 0
      credit = 0
      num_of_details.times{|i|
        if new_journal_details[i].dc_type == DC_TYPE_DEBIT
          debit = debit + new_journal_details[i].amount.to_i
        else
          credit = credit + new_journal_details[i].amount.to_i
        end
      }
      # 口座引き落としで調整
      new_journal_details[num_of_details - 1].amount = debit - credit
      
      journal_header.journal_details = new_journal_details
      journal_header
    end
  end
end
