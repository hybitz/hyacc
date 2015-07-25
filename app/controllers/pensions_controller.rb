class PensionsController < Base::HyaccController
  view_attribute :title => '厚生年金保険料'
  helper_method :finder

  def index
    @list = finder.list if params[:commit]
  end

  private

  def finder
    unless @finder
      @finder = PensionFinder.new(params[:pension_finder])
      @finder.ym = Date.today.strftime("%Y-%m") unless @finder.ym.present?
    end

    @finder
  end

end
