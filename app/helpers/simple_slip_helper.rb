module SimpleSlipHelper
  include HyaccConst

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
  
  def get_sub_account_title(account)
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
  
end
