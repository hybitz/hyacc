class Mv::WithheldTaxesController < Base::HyaccController
  view_attribute :title => '源泉徴収税'
  helper_method :finder

  def index
    @list = finder.list if params[:commit]
  end

  protected

  def finder
    unless @finder
      @finder = WithheldTaxFinder.new(params[:withheld_tax_finder])
      @finder.ym = Date.today.strftime("%Y-%m") unless @finder.ym.present?
    end

    @finder
  end

end
