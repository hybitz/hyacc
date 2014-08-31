module SimpleSlipHelper
  include HyaccConstants

  # アクション名からフォームのPOST先を決定する
  def define_action
    return 'create' if ['index', 'create'].include? controller.action_name
    return 'update' if ['show', 'edit', 'update'].include? controller.action_name
    controller.action_name
  end
  
  def define_message_color
    return "red" unless @slip.errors.empty?
    return "red" if flash[:is_error_message]
    "green"
  end
  
  def define_colspan_of_receipt
    if ['index', 'create'].include? controller.action_name
      colspan = 7
    else
      colspan = 4
    end

    colspan += 1 if branch_mode
    colspan
  end
  
  # 検索条件の補助科目のセレクトボックス名を取得する
  def get_sub_account_select_name( account )
    case account.sub_account_type
    when SUB_ACCOUNT_TYPE_NORMAL
      'sub_account_id'
    when SUB_ACCOUNT_TYPE_EMPLOYEE
      'employee_id'
    when SUB_ACCOUNT_TYPE_CUSTOMER
      'customer_id'
    when SUB_ACCOUNT_TYPE_SAVING_ACCOUNT
      'bank_account_id'
    when SUB_ACCOUNT_TYPE_RENT
      'rent_id'
    when SUB_ACCOUNT_TYPE_ORDER_ENTRY
      'customer_id'
    when SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
      'customer_id'
    else
      raise HyaccException.new(ERR_INVALID_SUB_ACCOUNT_TYPE)
    end
  end

  def get_sub_account_title( account )
    case account.sub_account_type
    when SUB_ACCOUNT_TYPE_NORMAL
      '補助科目'
    when SUB_ACCOUNT_TYPE_EMPLOYEE
      '従業員'
    when SUB_ACCOUNT_TYPE_CUSTOMER
      '取引先'
    when SUB_ACCOUNT_TYPE_SAVING_ACCOUNT
      '銀行口座'
    when SUB_ACCOUNT_TYPE_RENT
      '地代家賃契約先'
    when SUB_ACCOUNT_TYPE_ORDER_ENTRY
      '受注先'
    when SUB_ACCOUNT_TYPE_ORDER_PLACEMENT
      '発注先'
    else
      raise HyaccException.new(ERR_INVALID_SUB_ACCOUNT_TYPE)
    end
  end
  
  def find_target_account( journal_header )
    journal_header.normal_details.each do |jd|
      if ['1111','1121','1311','1551', '3171'].include? jd.account.code
        return jd.account
      end
    end
    
    nil
  end
  
end
