module Base::ViewAttributeHandler
  require 'models/name_and_value'
  include HyaccUtil
  include HyaccViewHelper

  protected

  def load_view_attributes
    get_attributes.each do |name, options|
      if action_match?(options[:only], options[:except])
        if name == :banks
          @banks = get_banks(options)
        elsif name == :finder
          @finder = get_finder(options)
        elsif name == :ym_list
          @ym_list = get_ym_select
        elsif name == :cy_list
          @cy_list = get_cy_select
        elsif name == :branches
          @branches = get_branches(options)
        elsif name == :accounts
          @accounts = get_accounts(options)
        elsif name == :account
          @account = get_account(finder)
        elsif name == :sub_accounts
          @sub_accounts = load_sub_accounts(finder, options)
        elsif name == :customers
          @customers = get_customers(options)
        elsif name == :employees
          @employees = get_employees(finder, options)
        elsif name == :report_types
          @report_types = get_report_types
        elsif name == :report_styles
          @report_styles = get_report_styles
        elsif name == :bank_accounts
          @bank_accounts = get_bank_accounts(options)
        elsif name == :title
          @title = options[name]
        end
      end
    end
  end
    
  def get_accounts(options = {})
    if options[:conditions]
      Account.where(options[:conditions]).where(:journalizable => true)
    else
      Account.get_journalizable_accounts
    end
  end

  def get_banks(options = {})
    Bank.all
  end

  def load_bank_offices(bank_id, options={})
    BankOffice.where(:bank_id => bank_id)
  end

  # 勘定科目を取得します。
  # finderがBase::Finderの場合、finder.account_idを使用して検索します。
  # finderが数値の場合、finderを使用して検索します。
  def get_account(finder)
    if finder.is_a? Base::Finder
      account_id = finder.account_id.to_i
    else
      account_id = finder.to_i
    end
    
    account_id > 0 ? Account.get( account_id ) : nil
  end
  
  def load_sub_accounts(finder, options = {})
    account = get_account(finder)
    return [] unless account

    if has_option?(options[:include], :deleted)
      ret = account.sub_accounts_all
    else
      ret = account.sub_accounts
    end

    sort(ret, options[:order])
  end
  
  def get_branches(options = {})
    Branch.get_branches(current_user.company.id, has_option?(options[:include], :deleted))
  end

  # 部門を取得します。
  # finderがBase::Finderの場合、finder.branch_idを使用して検索します。
  # finderが数値の場合、finderを使用して検索します。
  def get_branch(finder)
    if finder.is_a? Base::Finder
      branch_id = finder.branch_id.to_i
    else
      branch_id = finder.to_i
    end
    
    if branch_id > 0
      return Branch.get(branch_id)
    end

    nil
  end

  def get_customers(options = {})
    if options[:conditions]
      Customer.where(options[:conditions])
    else
      Customer.all
    end
  end

  # 検索条件を取得
  def get_finder(options)
    finder_class = options[:class]
    finder = session[finder_class.name]

    unless finder
      finder = finder_class.new( current_user )
      session[finder_class.name] = finder
    end
    
    finder.commit = params['commit']
    finder.page = params['page'].to_i
    
    # ファインダ個別の追加パラメータがあればセットする
    include_params = options[:include_params] 
    if include_params.is_a? Symbol
      finder.__send__(include_params.to_s + '=', params[include_params])
    elsif include_params.is_a? Array
      include_params.each do |ip|
        finder.send(ip.to_s + '=', params[ip])
      end
    end
    
    finder.setup_from_params( params['finder'] )
    finder
  end
  
  def get_report_types
    if controller_name == 'financial_statements'
      types = [
        REPORT_TYPE_BS,
        REPORT_TYPE_PL,
      ]
    elsif controller_name == 'financial_return_statements'
      types = [
        REPORT_TYPE_INCOME,
        REPORT_TYPE_SURPLUS_RESERVE_AND_CAPITAL_STOCK,
        REPORT_TYPE_TAX_AND_DUES,
        REPORT_TYPE_DIVIDEND_RECEIVED,
        REPORT_TYPE_SOCIAL_EXPENSE,
        REPORT_TYPE_TRADE_ACCOUNT_RECEIVABLE,
        REPORT_TYPE_TRADE_ACCOUNT_PAYABLE,
        REPORT_TYPE_RENT,
      ]
    elsif controller_name == 'withholding_slip'
      types = [
        REPORT_TYPE_WITHHOLDING_SUMMARY,
        REPORT_TYPE_WITHHOLDING_DETAILS,
        REPORT_TYPE_WITHHOLDING_CALC,
      ]
    else
      raise HyaccException.new(ERR_INVALID_ACTION)
    end
    
    ret = []
    types.each do |type|
      ret << NameAndValue.new(REPORT_TYPES[type], type)
    end
    ret
  end

  def get_report_styles
    report_styles
  end
  
  def get_bank_accounts(options = {})
    if options[:conditions]
      BankAccount.where(options[:conditions])
    else
      BankAccount.all
    end
  end

  # 年度選択リストを取得する
  # 取得する年度は、創業年度から翌年度まで
  def get_ym_select
    first = current_user.company.founded_fiscal_year.fiscal_year
    last = current_user.company.fiscal_years.last.fiscal_year
    get_ym_list( first, 0, last - first )
  end
  
  # 暦年選択リストを取得する
  def get_cy_select
    first = current_user.company.founded_fiscal_year.fiscal_year
    last = Date.today.year
    get_ym_list( first, 0, last - first )
  end

  # 従業員一覧を取得する
  def get_employees(finder, options = {})
    employees = []
    
    scope = options[:scope] || :all
    
    if scope == :all
      employees = Employee.where(:company_id => current_user.company_id)
      employees = employees.not_deleted unless has_option?(options[:include], :deleted)
    elsif scope == :branch
      branch = get_branch(finder)
      branch ||= current_user.employee.default_branch
      employees = branch.employees
    end
    
    employees
  end

  private

  # optionsの中にoptionがあるかどうか
  def has_option?(options, option)
    if options.is_a? Array
      options.include? option or options.include? option.to_s
    elsif options.is_a? String or options.is_a? Symbol
      options.to_s == option.to_s
    else
      false
    end
  end
  
  # 実行されているアクションが対象に含まれているか
  def action_match?(only, except)
    return true if only.nil? and except.nil?
    
    if only.is_a? String or only.is_a? Symbol
      only = [only.to_s]
    elsif only.is_a? Array
      only.collect!{|a| a.to_s}
    end
    
    if except.is_a? String or except.is_a? Symbol
      except = [except.to_s]
    elsif except.is_a? Array
      except.collect!{|a| a.to_s}
    end
    
    if only.nil? or only.include? action_name
      return true if except.nil?
      return true unless except.include? action_name
    end

    false
  end
end
