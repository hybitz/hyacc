class SocialExpensesController < Base::HyaccController
  view_attribute :title => '交際費管理'
  view_attribute :finder, :class => SocialExpenseFinder
  view_attribute :ym_list
  view_attribute :branches

  def index
    @journal_headers = finder.list
  end

end
