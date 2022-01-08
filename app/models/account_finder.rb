class AccountFinder
  include ActiveModel::Model
  include HyaccConst

  attr_accessor :account_type
  attr_accessor :leaf_only
  
  def leaf_only?
    self.leaf_only.to_i == 1
  end

  def account_types
    ACCOUNT_TYPES.invert
  end

  def account_type_debt?
    self.account_type.to_i == ACCOUNT_TYPE_DEBT
  end

  def account_type_capital?
    self.account_type.to_i == ACCOUNT_TYPE_CAPITAL
  end

  def list
    return unless self.account_type.to_i > 0
    
    ret = Account.where(:account_type => self.account_type).order('path')
    ret = ret.select{|a| a.is_leaf} if leaf_only?
    ret
  end

end
