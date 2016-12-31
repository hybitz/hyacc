module Pagination
  extend ActiveSupport::Concern
  include HyaccConstants

  def page
    @page.to_i > 0 ? @page.to_i : 1
  end
  
  def page=(value)
    @page = value
  end

  def per_page
    @per_page.to_i > 0 ? @per_page.to_i : DEFAULT_PER_PAGE
  end

  def per_page=(value)
    @per_page = value
  end
end