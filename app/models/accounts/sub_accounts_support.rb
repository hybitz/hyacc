module Accounts::SubAccountsSupport
  include HyaccConstants
  
  def initialize_sub_accounts_support
    return if @sub_accounts_cache and @sub_accounts_all_cache
    
    @sub_accounts_cache = []
    @sub_accounts_all_cache = []

    case sub_account_type
    when SUB_ACCOUNT_TYPE_NORMAL
      SubAccount.where(account_id: self.id).order(:code).each do |sa|
        @sub_accounts_cache << sa unless sa.deleted?
        @sub_accounts_all_cache << sa
      end
    when SUB_ACCOUNT_TYPE_BRANCH
      Branch.all.each do |b|
        @sub_accounts_cache << b unless b.deleted?
        @sub_accounts_all_cache << b
      end
    when SUB_ACCOUNT_TYPE_EMPLOYEE
      Employee.all.each do |e|
        @sub_accounts_cache << e unless e.deleted?
        @sub_accounts_all_cache << e
      end
    when SUB_ACCOUNT_TYPE_CUSTOMER
      Customer.all.each do |c|
        @sub_accounts_cache << c unless c.deleted? or c.disabled?
        @sub_accounts_all_cache << c
      end
    when SUB_ACCOUNT_TYPE_SAVING_ACCOUNT
      BankAccount.where(financial_account_type: FINANCIAL_ACCOUNT_TYPE_SAVING).each do |ba|
        @sub_accounts_cache << ba unless ba.deleted?
        @sub_accounts_all_cache << ba
      end
    when SUB_ACCOUNT_TYPE_GENERAL_ACCOUNT
      BankAccount.where(financial_account_type: FINANCIAL_ACCOUNT_TYPE_GENERAL).each do |ba|
        @sub_accounts_cache << ba unless ba.deleted?
        @sub_accounts_all_cache << ba
      end
    when SUB_ACCOUNT_TYPE_RENT
      Rent.all.each do |r|
        @sub_accounts_cache << r if r.status == RENT_STATUS_TYPE_USE
        @sub_accounts_all_cache << r
      end
    when SUB_ACCOUNT_TYPE_ORDER_ENTRY
      Customer.where(is_order_entry: true).each do |c|
        @sub_accounts_cache << c unless c.deleted? or c.disabled?
        @sub_accounts_all_cache << c
      end
    when SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
      Customer.where(is_order_placement: true).each do |c|
        @sub_accounts_cache << c unless c.deleted? or c.disabled?
        @sub_accounts_all_cache << c
      end
    when SUB_ACCOUNT_TYPE_INVESTMENT
      Customer.where(is_investment: true).each do |c|
        @sub_accounts_cache << c unless c.deleted? or c.disabled?
        @sub_accounts_all_cache << c
      end
    when SUB_ACCOUNT_TYPE_SOCIAL_EXPENSE
      SubAccount.where(account_id: self.id).order(:code).each do |sa|
        @sub_accounts_cache << sa unless sa.deleted?
        @sub_accounts_all_cache << sa
      end
    when SUB_ACCOUNT_TYPE_CORPORATE_TAX
      list = []
      CORPORATE_TAX_TYPES.each {|key, value|
        tax = CorporateTax.new(id: key, code: key, name: value)
        @sub_accounts_cache << tax
        @sub_accounts_all_cache << tax
      }
    when SUB_ACCOUNT_TYPE_CONSUMPTION_TAX
      list = []
      CONSUMPTION_TAX_TYPES.each {|key, value|
        tax = ConsumptionTax.new(id: key, code: key, name: value)
        @sub_accounts_cache << tax
        @sub_accounts_all_cache << tax
      }
    else
      raise HyaccException.new(ERR_INVALID_SUB_ACCOUNT_TYPE)
    end
  end

  # コードに一致する補助科目を取得する
  # 論理削除されている補助科目も対象
  def get_sub_account_by_code(code)
    sub_accounts_all.find {|sa| sa.code == code }
  end
  
  # IDに一致する補助科目を取得する
  # 論理削除されている補助科目も対象
  def get_sub_account_by_id(id)
    sub_accounts_all.find {|sa| sa.id == id }
  end
  
  def has_bank_accounts
    self.journalizable and [SUB_ACCOUNT_TYPE_SAVING_ACCOUNT, SUB_ACCOUNT_TYPE_GENERAL_ACCOUNT].include? self.sub_account_type
  end
  
  def has_customers
    self.journalizable and self.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
  end
  
  def has_employees
    self.journalizable and self.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE
  end

  def has_normal_sub_accounts
    self.journalizable and [SUB_ACCOUNT_TYPE_NORMAL, SUB_ACCOUNT_TYPE_SOCIAL_EXPENSE].include? self.sub_account_type 
  end
  
  def has_rents
    self.journalizable and self.sub_account_type == SUB_ACCOUNT_TYPE_RENT
  end
  
  def has_order_entry
    self.journalizable and self.sub_account_type == SUB_ACCOUNT_TYPE_ORDER_ENTRY
  end
  
  def has_order_placement
    self.journalizable and self.sub_account_type == SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
  end
  
  def has_sub_accounts?
    sub_accounts_all.present?
  end

  def sub_accounts
    initialize_sub_accounts_support
    @sub_accounts_cache
  end
  
  def sub_accounts_all
    initialize_sub_accounts_support
    @sub_accounts_all_cache
  end

  def sub_accounts_all=(values)
    @sub_accounts_all = values.reject{|sa| sa.deleted? } 
    @sub_accounts_all_cache = values
  end

end
