module Base::AclHandler
  
  # 会社の形態によりコントローラが利用可能かを確認する
  # return true  利用可能
  #        false 利用不可能
  def is_available?(controller_name, user, acl_table)
    # 画面ごとのアクセスコントロールリストを取得
    # 未定義の場合はアクセス可能
    acl = acl_table[controller_name]
    return true unless acl and acl.size > 0
    
    acl.each do |ac|
      type = ac[:type]
      only = ac[:only]
      except = ac[:except]
      raise HyaccException.new('アクセス制御の記述が不正です。') unless type
      raise HyaccException.new('アクセス制御の記述が不正です。') unless only or except
      
      # アクセス制御に利用する値を取得
      value = get_compare_value(type, user)
      
      # アクセスを認める値のリスト
      only = [only] if only and not only.is_a? Array
      
      # アクセスを拒否する値のリスト
      except = [except] if except and not except.is_a? Array
      
      # 判定
      judge = judge_acl(value, only, except)
      if HyaccLogger.debug?
        HyaccLogger.debug "access control for #{controller_name}: type=>#{type} value=>#{value} only=>#{only} except=>#{except} judge=>#{judge}"
      end
      
      # アクセス拒否判定が１つでもあればNG
      return false unless judge
    end
    
    true
  end

private
  # アクセス制御に利用する値を取得
  def get_compare_value(type, user)
    type = type.to_sym
    
    if type == :company_type
      value = user.company.type_of
    elsif type == :branch_mode
      value = user.branch_mode
    elsif type == :consumption_entry_type
      value = user.company.current_fiscal_year.consumption_entry_type
    elsif type == :tax_management_type
      value = user.company.current_fiscal_year.tax_management_type
    end
    
    value
  end

  def judge_acl(value, only, except)      
    if only and except
      only.include?(value) and not except.include?(value)
    elsif only
      only.include?(value)
    elsif except
      not except.include?(value)
    else
      false
    end
  end
end
