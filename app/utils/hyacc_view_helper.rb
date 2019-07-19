module HyaccViewHelper
  include HyaccConstants
  
  def dc_types
    revert_and_sort( DC_TYPES )
  end

  def depreciation_methods
    revert_and_sort( DEPRECIATION_METHODS )
  end
    
  def exemption_types
    revert_and_sort( EXEMPTION_TYPES )
  end
  
  def financial_account_types
    revert_and_sort( FINANCIAL_ACCOUNT_TYPES )
  end

  def focus_on_completes
    revert_and_sort( FOCUS_ON_COMPLETES )
  end
  
  def mortgage_deduction_types
    revert_and_sort( MORTGAGE_DEDUCTION_TYPES )
  end
  
  def settlement_types
    revert_and_sort( SETTLEMENT_TYPES )
  end

  def tax_management_types
    revert_and_sort( TAX_MANAGEMENT_TYPES )
  end

  def tax_types
    revert_and_sort( TAX_TYPES )
  end
  
  def rent_types
    revert_and_sort( RENT_TYPES )
  end
  
  def rent_usage_types
    revert_and_sort( RENT_USAGE_TYPES )
  end
  
  def rent_status_types
    revert_and_sort( RENT_STATUS_TYPES )
  end

  def report_types
    revert_and_sort( REPORT_TYPES )
  end

  def report_styles
    revert_and_sort( REPORT_STYLES )
  end
  
  def deleted_types
    hash = DELETED_TYPES.invert
  end

  def status_types
    hash = STATUS_TYPES.invert
  end

  def trade_types
    revert_and_sort( TRADE_TYPES )
  end

  def sex_types
    revert_and_sort( SEX_TYPES )
  end
  
  def slip_types
    revert_and_sort( SLIP_TYPES )
  end
  
  def slip_categories
    revert_and_sort( SLIP_CATEGORIES )
  end
  
  def sub_account_types
    revert_and_sort( SUB_ACCOUNT_TYPES )
  end
  
  def closing_status
    revert_and_sort( CLOSING_STATUS )
  end
  
  def company_types
    revert_and_sort( COMPANY_TYPES )
  end

  def consumption_entry_types
    revert_and_sort( CONSUMPTION_ENTRY_TYPES )
  end

  def to_options( collection )
    ret = {}
    
    if collection
      collection.each do | elem |
        ret[ elem.id ] = elem.name
      end
    end
    
    revert_and_sort( ret )
  end
  
  def to_options_code_and_name( collection )
    ret = {}
    
    unless collection.nil?
      collection.each do | elem |
        ret[ elem.id ] = elem.code.to_s + ":" + elem.name
      end
    end
    
    revert_and_sort( ret )
  end

  def to_amount(amount, options = {})
    if amount.to_f == 0
      if options[:show_zero]
          0
      else
        ''
      end
    else
      number_to_currency(amount, unit: options.fetch(:unit, ''), precision: options.fetch(:precision, 0) )
    end
  end
  
  # ヘルパーメソッドcheck_boxを使用するとき第一引数にインスタンス変数を指定する必要がある
  # 指定できない場合に値→checkedの値に変換するときに使用する
  # "1"→true、それ以外はfalse
  def value_of_check_box(value = 0)
    value = value.to_i
    return value == 1 ? true : false
  end

  private

  def revert_and_sort( hash )
    hash.invert.sort_by{|key, value| value}
  end

end
