module CareerStatementHelper
  include HyaccConst
  
  def company_label(company_type)
    return '屋号' if company_type == COMPANY_TYPE_PERSONAL
    '会社名'
  end
end
