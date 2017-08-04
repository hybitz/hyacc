module CompanyAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :company_id
  end

  def company
    @company ||= Company.find(company_id)
  end

end