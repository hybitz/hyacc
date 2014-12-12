class InsurancesController < Base::HyaccController
  view_attribute :title => '健康保険料'
  helper_method :finder

  def index
    @prefectures = TaxJp::Prefecture.all
    @list = finder.list if params[:commit]
  end

  protected

  def finder
    unless @finder
      @finder = InsuranceFinder.new(params[:insurance_finder])
      @finder.ym = Date.today.strftime("%Y-%m") unless @finder.ym.present?
    end

    @finder
  end

end
