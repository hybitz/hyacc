class Mv::EmploymentInsurancesController < Base::HyaccController
  view_attribute :title => '雇用保険料'
  helper_method :finder

  def index
    @list = finder.list
  end

  private

  def finder
    unless @finder
      @finder = EmploymentInsuranceFinder.new
    end

    @finder
  end
end
