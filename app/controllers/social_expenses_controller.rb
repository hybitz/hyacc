class SocialExpensesController < Base::HyaccController
  include JournalUtil
  
  available_for :type => :company_type, :except => COMPANY_TYPE_PERSONAL
  view_attribute :title => '交際費管理'
  view_attribute :finder, :class => SocialExpenseFinder
  view_attribute :ym_list
  view_attribute :branches

  def index
    @journal_headers = finder.list
  end

end
