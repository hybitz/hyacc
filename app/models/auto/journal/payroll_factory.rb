module Auto::Journal

  # 給与仕訳ファクトリ
  class PayrollFactory < Auto::AutoJournalFactory
    include PayrollHelper

    def initialize( auto_journal_param )
      super( auto_journal_param )
      @payroll = auto_journal_param.payroll
      @user = auto_journal_param.user
      @credit_amount = 0
    end

    def make_journals
      ret = []
      ret << make_payroll
      ret << make_pay
      ret << make_commission if commissions_required?
      ret
    end

    # 給与明細の取得
    def make_payroll
      employee = Employee.find(@payroll.employee_id)
      salary_account = employee.executive? ?
          Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY) :
          Account.find_by_code(ACCOUNT_CODE_SALARY)

      journal = @payroll.build_payroll_journal
      journal.company_id = employee.company_id

      # 給与日の設定
      journal.ym = @payroll.ym
      journal.day = employee.company.payroll_day(@payroll.ym)
      # 摘要の設定
      journal.remarks = "#{salary_account.name}　#{employee.fullname}　#{@payroll.ym%100}月分"
      journal.slip_type = SLIP_TYPE_AUTO_TRANSFER_PAYROLL
      journal.create_user_id = @user.id
      journal.update_user_id = @user.id

      # 明細の作成
      # ￥０の明細を作成しない

      ## デフォルト部門の取得
      branch_id = employee.default_branch.id
      # 保険料と所得税の取得
      tax = get_tax(@payroll.ym, employee.id, @payroll.base_salary, @payroll.commuting_allowance, @payroll.monthly_standard)
      # 勘定科目の取得
      deposits_received = Account.find_by_code(ACCOUNT_CODE_DEPOSITS_RECEIVED)
      advance_money = Account.find_by_code(ACCOUNT_CODE_ADVANCE_MONEY)

      ## 給与明細
      ### 役員給与・給与手当・通勤手当
      if @payroll.salary_total > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.account = salary_account
        detail.sub_account_id = employee.id
        detail.branch_id = branch_id
        detail.amount = @payroll.salary_total
      end
      ### 法定福利費.健康保険料
      insurance_half = tax.insurance_all.to_i - @payroll.health_insurance
      if insurance_half != 0
        account = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)

        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.account = account
        detail.sub_account_id = account.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE).id
        detail.branch_id = branch_id
        detail.amount = insurance_half
        detail.note = "会社負担保険料"
      end
      ### 法定福利費.厚生年金
      pension_half = tax.pension_all.to_i - @payroll.welfare_pension
      if pension_half != 0
        account = Account.find_by_code(ACCOUNT_CODE_LEGAL_WELFARE)

        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.account = account
        detail.sub_account_id = account.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION).id
        detail.branch_id = branch_id
        detail.amount = pension_half
        detail.note = "会社負担保険料"
      end
      ### 源泉所得税
      if @payroll.income_tax > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_CREDIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX).id
        detail.branch_id = branch_id
        detail.amount = @payroll.income_tax
        detail.note = "源泉所得税"
      end
      ### 健康保険料
      if @payroll.health_insurance > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_CREDIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_HEALTH_INSURANCE).id
        detail.branch_id = branch_id
        detail.amount = @payroll.health_insurance
        detail.note = "個人負担保険料"
      end
      ### 厚生年金
      if @payroll.welfare_pension > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_CREDIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_WELFARE_PENSION).id
        detail.branch_id = branch_id
        detail.amount = @payroll.welfare_pension
        detail.note = "個人負担保険料"
      end
      ### 会社負担社会保険料の未払分
      detail = journal.journal_details.build
      detail.detail_no = journal.journal_details.size
      detail.dc_type = DC_TYPE_CREDIT
      detail.account = Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE)
      detail.branch_id = branch_id
      detail.amount = tax.insurance_all.to_i - @payroll.health_insurance + tax.pension_all.to_i - @payroll.welfare_pension
      detail.note = "会社負担保険料の未払分"
      ### 雇用保険
      if @payroll.employment_insurance > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_CREDIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_EMPLOYMENT_INSURANCE).id
        detail.branch_id = branch_id
        detail.amount = @payroll.employment_insurance
        detail.note = "従業員負担雇用保険料"
      end
      ### 住民税
      if @payroll.inhabitant_tax > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_CREDIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INHABITANT_TAX).id
        detail.branch_id = branch_id
        detail.amount = @payroll.inhabitant_tax
        detail.note = "住民税"
      end
      ### 年末調整分
      if @payroll.annual_adjustment > 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.account = deposits_received
        detail.sub_account_id = deposits_received.get_sub_account_by_code(SUB_ACCOUNT_CODE_INCOME_TAX).id
        detail.branch_id = branch_id
        detail.amount = @payroll.annual_adjustment
        detail.note = "年末調整過払い分"
      end
      ### 振り込み予定額　※仮明細
      detail = journal.journal_details.build
      detail.detail_no = journal.journal_details.size
      detail.dc_type = DC_TYPE_CREDIT
      detail.account = Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE)
      detail.sub_account_id = employee.id
      detail.branch_id = branch_id
      detail.note = "振り込み予定額"
      detail.amount = 0
      # 貸借の金額調整、振り込み予定額で調整する
      debit = 0
      credit = 0
      journal.journal_details.each do |jd|
        if jd.dc_type == DC_TYPE_DEBIT
          debit += jd.amount.to_i
        else
          credit += jd.amount.to_i
        end
      end
      # 振り込み予定額の設定
      detail.amount = debit - credit
      @payroll.transfer_payment = debit - credit

      journal
    end

    # 支払明細の取得
    def make_pay
      employee = Employee.find(@payroll.employee_id)
      salary_account = employee.executive? ?
          Account.find_by_code(ACCOUNT_CODE_DIRECTOR_SALARY) :
          Account.find_by_code(ACCOUNT_CODE_SALARY)

      journal = @payroll.build_pay_journal
      journal.company_id = employee.company.id
      journal.date = @payroll.pay_day
      journal.remarks = "給与支給、立替費用の精算　" + employee.fullname + "　" + (@payroll.ym%100).to_s + "月分"
      journal.slip_type = SLIP_TYPE_AUTO_TRANSFER_PAYROLL
      journal.create_user_id = @user.id
      journal.update_user_id = @user.id

      # 明細の作成

      ## デフォルト部門の取得
      branch_id = employee.default_branch.id
      ## 消費税取り扱い区分を取得
      fy = employee.company.get_fiscal_year(journal.ym)
      raise HyaccException.new(ERR_FISCAL_YEAR_NOT_EXISTS) unless fy

      ## 支払明細
      ### 未払費用.役員報酬、振込み予定額を設定
      if @payroll.transfer_payment.to_i != 0
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.account = Account.find_by_code(ACCOUNT_CODE_ACCRUED_EXPENSE_EMPLOYEE)
        detail.sub_account_id = employee.id
        detail.branch_id = branch_id
        detail.amount = @payroll.transfer_payment
        detail.note = salary_account.name
      end
      ### 未払金（従業員）の残高を部門別に精算
      if @payroll.accrued_liability > 0
        account = VUnpaidEmployee.account
        total_amount = @payroll.accrued_liability
        VUnpaidEmployee.net_sums_by_branch(employee, order: 'amount').each do |branch_id, amount|
          next if amount == 0 # ￥０の明細を作成しない

          detail = journal.journal_details.build
          detail.detail_no = journal.journal_details.size
          detail.dc_type = DC_TYPE_DEBIT
          detail.account = account
          detail.sub_account_id = employee.id
          detail.branch_id = branch_id
          detail.note = "立替費用の精算"
          
          if total_amount > amount
            detail.amount = amount
            total_amount -= amount
          else
            detail.amount = total_amount
            break
          end
        end
      end
      ### 普通預金
      account = Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT)
      detail = journal.journal_details.build
      detail.detail_no = journal.journal_details.size
      detail.dc_type = DC_TYPE_CREDIT
      detail.account = account
      detail.sub_account_id = BANK_ACCOUNT_ID_FOR_PAY
      detail.branch_id = branch_id
      detail.note = "口座引落し額"
      detail.amount = 0
      # 貸借の金額調整、振り込み予定額で調整する
      debit = 0
      credit = 0
      journal.journal_details.each do |jd|
        if jd.dc_type == DC_TYPE_DEBIT
          debit += jd.amount.to_i
        else
          credit += jd.amount.to_i
        end
      end
      @credit_amount = debit - credit
      detail.amount = @credit_amount

      journal
    end

    def commissions_required?
      return calc_commissions > 0
    end
    
    def calc_commissions
      commission = 0
      employee = Employee.find(@payroll.employee_id)
      ba = BankAccount.find(BANK_ACCOUNT_ID_FOR_PAY)
      return 500 if employee.employee_bank_account.nil?
      if ba.bank_id == employee.employee_bank_account.bank_id
        if ba.bank_office_id == employee.employee_bank_account.bank_office_id
          commission = ba.bank.get_commission(@credit_amount, Bank::TO_SAME_OFFICE)
        else
          commission = ba.bank.get_commission(@credit_amount, Bank::TO_OTHER_OFFICE)
        end
      else
        commission = ba.bank.get_commission(@credit_amount, Bank::TO_OTHER_BANK)
      end
      return commission
    end
    
    def make_commission
      employee = Employee.find(@payroll.employee_id)

      journal = @payroll.build_commission_journal
      journal.company_id = employee.company.id
      journal.date = @payroll.pay_day
      journal.remarks = "給与支給、振込手数料　" + employee.fullname + "　" + (@payroll.ym%100).to_s + "月分"
      journal.slip_type = SLIP_TYPE_AUTO_TRANSFER_PAYROLL
      journal.create_user_id = @user.id
      journal.update_user_id = @user.id

      # 消費税率
      tax_rate = TaxJp.rate_on(journal.date)
      Rails.logger.debug "tax_rate=#{tax_rate}, date=#{journal.date}"

      # 明細の作成
      ## ￥０の明細を作成しない

      ## デフォルト部門の取得
      branch_id = employee.default_branch.id
      ## 消費税取り扱い区分を取得
      fy = employee.company.get_fiscal_year(journal.ym)
      raise HyaccException.new(ERR_FISCAL_YEAR_NOT_EXISTS) unless fy

      ## 支払明細
      commission = calc_commissions
      
      ### 支払手数料
      account = Account.find_by_code(ACCOUNT_CODE_COMMISSION_PAID)
      sub_account = account.sub_accounts.find{|sa| sa.name == '振込手数料' }
      detail = journal.journal_details.build
      detail.detail_no = journal.journal_details.size
      detail.dc_type = DC_TYPE_DEBIT
      detail.account = account
      detail.sub_account_id = sub_account.id if sub_account.present?
      detail.branch_id = branch_id
      detail.note = '振込手数料'
      if fy.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
        detail.tax_type = TAX_TYPE_INCLUSIVE
        detail.tax_rate = tax_rate
        detail.amount = commission
      else
        detail.tax_type = TAX_TYPE_NONTAXABLE
        detail.amount = (commission * (1 + tax_rate)).to_i
      end

      ### 支払手数料の消費税
      if fy.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
        detail = journal.journal_details.build
        detail.detail_no = journal.journal_details.size
        detail.dc_type = DC_TYPE_DEBIT
        detail.detail_type = DETAIL_TYPE_TAX
        detail.tax_type = TAX_TYPE_NONTAXABLE
        detail.account = Account.find_by_code(ACCOUNT_CODE_TEMP_PAY_TAX)
        detail.branch_id = branch_id
        detail.amount = (commission * tax_rate).to_i
        detail.note = "振込手数料の消費税"
        detail.main_detail = journal.journal_details.first
      end

      ### 普通預金
      account = Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT)
      detail = journal.journal_details.build
      detail.detail_no = journal.journal_details.size
      detail.dc_type = DC_TYPE_CREDIT
      detail.account = account
      detail.sub_account_id = BANK_ACCOUNT_ID_FOR_PAY
      detail.branch_id = branch_id
      detail.note = "口座引落し額"
      detail.amount = 0
      # 貸借の金額調整、振り込み予定額で調整する
      debit = 0
      credit = 0
      journal.journal_details.each do |jd|
        if jd.dc_type == DC_TYPE_DEBIT
          debit += jd.amount.to_i
        else
          credit += jd.amount.to_i
        end
      end
      detail.amount = debit - credit

      journal
    end
  end
end
