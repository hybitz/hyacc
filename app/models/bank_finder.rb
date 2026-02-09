class BankFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include HyaccConst

  attr_accessor :disabled
  
  def disabled_types
    DISABLED_TYPES.invert
  end

  def list
    ret = Bank.where(company_id: company_id, deleted: false)
    ret = ret.where(disabled: BooleanUtils.to_b(disabled)) if disabled.present?
    ret = ret.order('code')
    ret = ret.paginate(page: page, per_page: per_page || DEFAULT_PER_PAGE)
  end

end
